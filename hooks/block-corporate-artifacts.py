"""
PreToolUse hook: Block sales/deal/radar artifacts from being written into a
repo classified `corporate`.

Backstop for the redirect-first safeguard described in
`references/dev/repo-classification.md`: commands resolve sales/deal/radar
output to the deals workspace at prompt time, but this hook catches any Write
or Edit that still lands under an `accounts/`, `deals/`, or `radar/` path
segment inside a repo whose root `STACK.md` declares `class: corporate`.

This is a guardrail against ACCIDENTAL or habitual writes, not a security
boundary — same philosophy as `hooks/block-secrets.py`: a determined bypass
is possible; the goal is that no absent-minded action lands sales artifacts
in a corporate tree. It fails OPEN on every error (unreadable file,
permission error, unexpected exception, no repo found, no STACK.md, no
`class:` field, or any value other than `corporate` case/quote-insensitively)
— the hook only ever acts on an explicit corporate declaration, which is also
what keeps it from blocking writes into the deals workspace itself (whose own
tree has `accounts/`, `deals/`, `radar/` dirs but is never classified
corporate).

Two deliberate permissiveness rules, both because this is a corporate-artifact
guardrail where permissive PARSING fails toward protection (finding more
`class: corporate` declarations, not fewer), even though the hook overall
still fails OPEN on any error:

- **Frontmatter scan is tolerant, not anchored.** `read_class()` looks for the
  first `---`-delimited block ANYWHERE in STACK.md — a preamble (a title, a
  comment) before the frontmatter is tolerated, matching
  `memory-sync.sh`'s `get_repo_class()` exactly (both are documented as
  mirroring each other's read).
- **Every enclosing repo root is checked, not just the nearest.** A nested
  `.git` (vendored dependency, forgotten `git init` in a subfolder, an
  unregistered submodule) with no STACK.md of its own must not shadow an
  outer corporate classification, so the walk continues to the filesystem
  root collecting every ancestor that has a `.git` entry, and denies if ANY
  of them declares `class: corporate`.

Exit codes:
  0 = allow (tool proceeds normally, including on any error — fail-open)
  2 = block (stderr shown to Claude as feedback)
"""

import json
import os
import re
import sys

# Segment-anchored: matches `<repo>/accounts/x`, `<repo>/deals/`, `.../radar/state.json`
# but NOT `src/accounts_ui/` or `webpack/radar.config.js` (no bare segment boundary).
_ARTIFACT_SEGMENT_RE = re.compile(r"(^|/)(accounts|deals|radar)(/|$)")

# First `---`-delimited block ANYWHERE in STACK.md (YAML frontmatter) — NOT anchored
# to byte 0. A preamble line (title, comment) before the block is tolerated; this is
# the tolerant/permissive read, matching memory-sync.sh's get_repo_class() awk logic
# exactly (see module docstring: permissive parsing fails toward protection here).
# Closing --- may end with \n or EOF; an unclosed block runs to EOF — both match the
# awk semantics in memory-sync.sh's get_repo_class() (R1 alignment).
_FRONTMATTER_RE = re.compile(
    r"^---[ \t]*$\n(.*?)(?:^---[ \t]*(?:\n|\Z)|\Z)", re.DOTALL | re.MULTILINE
)

# `class:` field within the frontmatter block.
_CLASS_FIELD_RE = re.compile(r"^class:\s*(\S+)", re.MULTILINE)

DENY_MESSAGE = (
    "Blocked: this repo is classified 'corporate' (STACK.md class:). "
    "Sales/deal/radar artifacts never write into corporate trees — write to "
    "the deals workspace instead (paths.deals_workspace, default "
    "~/code/deals-workspace). Wrong classification? Edit 'class:' in STACK.md."
)


def find_all_repo_roots(start_dir: str) -> list[str]:
    """Walk parent directories from start_dir looking for `.git` entries
    (directory for a normal clone, file for a worktree). Unlike a single
    nearest-match walk, this collects EVERY ancestor repo root, nearest
    first, all the way to the filesystem root — a nested `.git` (vendored
    dependency, forgotten `git init`, unregistered submodule) must not
    shadow an enclosing repo's own corporate classification. Returns an
    empty list if no `.git` is found anywhere above start_dir."""
    roots = []
    d = os.path.abspath(start_dir)
    while True:
        if os.path.exists(os.path.join(d, ".git")):
            roots.append(d)
        parent = os.path.dirname(d)
        if parent == d:
            break
        d = parent
    return roots


def read_class(repo_root: str) -> str | None:
    """Return the normalized `class:` value declared in repo_root/STACK.md's
    frontmatter (lowercased, surrounding quotes stripped — `Corporate`,
    `CORPORATE`, and `"corporate"` all read back as `corporate`), or None if
    the file/frontmatter/field is absent. Frontmatter is the first
    `---`-delimited block anywhere in the file (tolerant read — see
    `_FRONTMATTER_RE`), not required to be the file's literal first bytes."""
    stack_path = os.path.join(repo_root, "STACK.md")
    if not os.path.isfile(stack_path):
        return None
    with open(stack_path, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
    fm_match = _FRONTMATTER_RE.search(content)
    if not fm_match:
        return None
    class_match = _CLASS_FIELD_RE.search(fm_match.group(1))
    if not class_match:
        return None
    value = class_match.group(1).strip().strip("'\"").lower()
    return value or None


def check(tool_name: str, tool_input: dict) -> str | None:
    """Return the deny message, or None to allow."""
    if tool_name not in ("Write", "Edit"):
        return None

    file_path = tool_input.get("file_path", "")
    if not file_path:
        return None

    # realpath (not abspath): a symlink inside a corporate tree pointing outside it
    # resolves to its true target — no false-block; a symlink INTO a corporate tree
    # resolves inside it and is still denied (R2 refinement).
    abspath = os.path.realpath(os.path.abspath(file_path))
    # Match on forward-slash segments regardless of platform path separator.
    test_path = abspath.replace(os.sep, "/")
    if not _ARTIFACT_SEGMENT_RE.search(test_path):
        return None

    repo_roots = find_all_repo_roots(os.path.dirname(abspath))
    if not repo_roots:
        return None

    # Deny if ANY enclosing repo root (nearest to outermost) declares
    # class: corporate — closes the nested-.git shadow (Finding #2).
    for repo_root in repo_roots:
        if read_class(repo_root) == "corporate":
            return DENY_MESSAGE

    return None


def main() -> None:
    try:
        hook_input = json.load(sys.stdin)
        tool_name = hook_input.get("tool_name", "")
        tool_input = hook_input.get("tool_input", {})
        if not isinstance(tool_input, dict):
            tool_input = {}
        reason = check(tool_name, tool_input)
    except Exception:
        # Fail-open: this hook is a backstop, not a security boundary. Any
        # unexpected error (malformed JSON, permission error, etc.) must not
        # brick every Write/Edit on the machine.
        sys.exit(0)

    if reason:
        print(reason, file=sys.stderr)
        sys.exit(2)

    sys.exit(0)


if __name__ == "__main__":
    main()
