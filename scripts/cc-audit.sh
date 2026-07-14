#!/usr/bin/env bash
# cc-audit.sh — Mechanical quality gate for the cc plugin (deterministic half of /cc:maintain:audit).
#
# Runs a fixed set of checks against global/ (and, for the stale-pattern/CRLF check,
# gtm-local/) and prints PASS/FAIL/WARN/NOTICE per check. Exits non-zero if any
# ERROR-level check found something.
#
# Bash 3.2-compatible (macOS default): no associative arrays, no mapfile, no `${x,,}`.
# Heavy text/JSON logic is delegated to python3 (already a hard requirement elsewhere
# in this repo — see scripts/cc-apply.sh).
#
# Each python3 block is defined as a `_ccpy_*` helper function and captured via
# `VAR="$(_ccpy_foo)"` — do NOT inline the heredoc back into the command substitution as
# `VAR="$(python3 - <<'PYEOF' ... PYEOF)"`. bash 3.2's $() lexer tries to token-balance the
# heredoc BODY (its backticks, apostrophes, and parens) and aborts with "unexpected EOF
# looking for matching `" at parse time; bash 4+/5 (CI, Homebrew) parse it fine, so the
# breakage is invisible until someone runs the gate with the stock macOS /bin/bash.
#
# Usage:
#   bash scripts/cc-audit.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"          # .../global
REPO_ROOT="$(cd "$ROOT/.." && pwd)"           # repo root (parent of global/)

ERRORS=0
WARNINGS=0
NOTICES=0

if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: python3 is required" >&2
  exit 1
fi

# ── Output helpers ────────────────────────────────────────────────────────────
rule() { printf '\n\033[1m%s\033[0m\n%s\n' "$1" "──────────────────────────────────────────────────────────────"; }
ok()      { printf '✅ %s\n' "$1"; }
err()     { printf '❌ %s\n' "$1"; ERRORS=$((ERRORS + 1)); }
warn()    { printf '⚠️  %s\n' "$1"; WARNINGS=$((WARNINGS + 1)); }
notice()  { printf 'ℹ️  %s\n' "$1"; NOTICES=$((NOTICES + 1)); }
detail()  { printf '     %s\n' "$1"; }

echo "Command Center Audit — $(date '+%Y-%m-%d %H:%M:%S')"
echo "Root: $ROOT"

# ══════════════════════════════════════════════════════════════════════════════
# (a) Reference existence — ${CLAUDE_PLUGIN_ROOT}/... paths in skills/commands/agents
# ══════════════════════════════════════════════════════════════════════════════
rule "1. Reference existence (\${CLAUDE_PLUGIN_ROOT}/... paths)"

_ccpy_REF_OUT() { python3 - "$ROOT" "$REPO_ROOT" <<'PYEOF'
import os, re, sys

root = sys.argv[1]
repo_root = sys.argv[2]
scan_dirs = ["skills", "commands", "agents"]

# Capture the run of path-ish characters right after ${CLAUDE_PLUGIN_ROOT}.
# Includes {, <, *, $ for template detection; stops at whitespace/quotes/backticks/parens.
ref_re = re.compile(r"\$\{CLAUDE_PLUGIN_ROOT\}(/[A-Za-z0-9_\-./{}<>*$]*)")

broken = []
checked = 0

for d in scan_dirs:
    base = os.path.join(root, d)
    if not os.path.isdir(base):
        continue
    for dirpath, dirnames, filenames in os.walk(base):
        dirnames[:] = [dn for dn in dirnames if dn != ".git"]
        for fn in filenames:
            fpath = os.path.join(dirpath, fn)
            try:
                with open(fpath, "r", encoding="utf-8", errors="strict") as fh:
                    lines = fh.readlines()
            except (UnicodeDecodeError, OSError):
                continue
            for lineno, line in enumerate(lines, start=1):
                for m in ref_re.finditer(line):
                    raw = m.group(1)
                    if not raw:
                        continue
                    path = raw.rstrip(".")
                    if not path:
                        continue
                    checked += 1
                    segments = [s for s in path.split("/") if s != ""]

                    def is_template_segment(seg):
                        if any(c in seg for c in ("{", "<", "*")):
                            return True
                        if "$ARGUMENTS" in seg:
                            return True
                        if seg and set(seg) == {"."}:
                            return True
                        return False

                    template_idx = None
                    for i, seg in enumerate(segments):
                        if is_template_segment(seg):
                            template_idx = i
                            break

                    if template_idx is not None:
                        parent_segments = segments[:template_idx]
                        if not parent_segments:
                            # Nothing concrete to check (e.g. ${CLAUDE_PLUGIN_ROOT}/{x})
                            continue
                        target = os.path.join(root, *parent_segments)
                        kind = "parent dir of template"
                    else:
                        target = os.path.join(root, *segments)
                        kind = "path"

                    if not os.path.exists(target):
                        rel_source = os.path.relpath(fpath, root)
                        broken.append(f"{rel_source}:{lineno} → {path}  [missing {kind}: {os.path.relpath(target, root)}]")

# ── (a2) Markdown-relative *.md link integrity ──────────────────────────────
# Scope: references/, skills/, commands/ prose. Only resolves EXPLICIT markdown
# link syntax `[text](target.md)` — not bare backtick mentions like `foo.md`.
# Empirically (this corpus), bare-backtick `*.md` mentions are overwhelmingly
# informal citations to *other* repos/tools (e.g. "the Archon CLI repository",
# TOC/BBiT source material, a sibling project's generated STACK.md) rather than
# repo-relative links, and flagging them was all false positives. Real markdown
# links are a much higher-confidence signal of "this points at a repo file".
# External URLs, ${CLAUDE_PLUGIN_ROOT} paths (handled above), and template-
# looking tokens are excluded. Content inside fenced ``` code blocks is skipped
# — those are frequently illustrative "what your SKILL.md might look like"
# examples, not real links from the file they appear in. Heading anchors
# (#section) are not validated — file existence is the floor.
md_link_re = re.compile(r"\[[^\]\n]*\]\(([^()\s]+)\)")
fence_re = re.compile(r"```.*?```", re.DOTALL)

def is_skippable_target(raw):
    if raw.startswith(("http://", "https://", "mailto:", "#")):
        return True
    if "${CLAUDE_PLUGIN_ROOT}" in raw or "${" in raw:
        return True
    if any(c in raw for c in ("{", "<", "*", "[", "]")):
        return True
    return False

link_scan_dirs = ["references", "skills", "commands"]
md_checked = 0
for d in link_scan_dirs:
    base = os.path.join(root, d)
    if not os.path.isdir(base):
        continue
    for dirpath, dirnames, filenames in os.walk(base):
        dirnames[:] = [dn for dn in dirnames if dn != ".git"]
        for fn in filenames:
            if not fn.endswith(".md"):
                continue
            fpath = os.path.join(dirpath, fn)
            try:
                with open(fpath, "r", encoding="utf-8", errors="strict") as fh:
                    text = fh.read()
            except (UnicodeDecodeError, OSError):
                continue
            # Blank out fenced code-block bodies (keep line/offset alignment intact
            # for accurate line numbers) so example snippets aren't scanned.
            text_scan = fence_re.sub(lambda m: re.sub(r"[^\n]", " ", m.group(0)), text)
            # skills/<name>/... files may write paths relative to the skill's own
            # root (e.g. `guides/cli.md` from within skills/archon/guides/setup.md,
            # meaning skills/archon/guides/cli.md) rather than their own directory.
            skill_root = None
            rel_from_skills = os.path.relpath(dirpath, os.path.join(root, "skills"))
            if not rel_from_skills.startswith(".."):
                skill_name = rel_from_skills.split(os.sep)[0]
                skill_root = os.path.join(root, "skills", skill_name)

            seen_on_line = set()
            for m in md_link_re.finditer(text_scan):
                raw = m.group(1).strip()
                if is_skippable_target(raw):
                    continue
                path_part, _, _anchor = raw.partition("#")
                path_part = path_part.strip()
                if not path_part.endswith(".md"):
                    continue
                if path_part.startswith("/"):
                    continue  # absolute/root-relative — out of scope, avoid false positives
                lineno = text_scan[: m.start()].count("\n") + 1
                md_checked += 1
                # This corpus mixes authoring conventions: paths relative to the
                # source file's own dir (`./sibling.md`), relative to `global/`
                # (`references/piv/foo.md` written from a sibling dir), relative to
                # the repo root (`docs/foo.md`, the imperium-repo-level docs/ beside
                # global/), and relative to a skill's own root. Accept a match
                # against any before calling it broken.
                candidates = [
                    os.path.normpath(os.path.join(dirpath, path_part)),
                    os.path.normpath(os.path.join(root, path_part)),
                    os.path.normpath(os.path.join(repo_root, path_part)),
                ]
                if skill_root:
                    candidates.append(os.path.normpath(os.path.join(skill_root, path_part)))
                if not any(os.path.exists(c) for c in candidates):
                    rel_source = os.path.relpath(fpath, root)
                    key = (rel_source, lineno, path_part)
                    if key in seen_on_line:
                        continue
                    seen_on_line.add(key)
                    broken.append(f"{rel_source}:{lineno} → missing {path_part}")

print(f"CHECKED\t{checked + md_checked}")
for b in broken:
    print(f"BROKEN\t{b}")
PYEOF
}
REF_OUT="$(_ccpy_REF_OUT)"

ref_checked=$(printf '%s\n' "$REF_OUT" | grep '^CHECKED' | cut -f2)
ref_broken=$(printf '%s\n' "$REF_OUT" | grep '^BROKEN' | cut -f2-)

if [[ -z "$ref_broken" ]]; then
  ok "Reference existence: all ${ref_checked:-0} \${CLAUDE_PLUGIN_ROOT}/... refs resolve"
else
  broken_count=$(printf '%s\n' "$ref_broken" | grep -c .)
  err "Reference existence: $broken_count broken ref(s) out of ${ref_checked:-0}"
  printf '%s\n' "$ref_broken" | while IFS= read -r line; do
    [[ -n "$line" ]] && detail "$line"
  done
fi

# ══════════════════════════════════════════════════════════════════════════════
# (b) Stale-pattern denylist + CRLF
# ══════════════════════════════════════════════════════════════════════════════
rule "2. Stale-pattern denylist"

denylist_hits=0

run_denylist() {
  local label="$1" mode="$2" pattern="$3"
  local out
  # ':(exclude)' skips this script itself — its denylist literals are not content.
  out="$(git -C "$REPO_ROOT" grep -n -I "$mode" "$pattern" -- global gtm-local ':(exclude)global/scripts/cc-audit.sh' 2>/dev/null || true)"
  if [[ -n "$out" ]]; then
    local n
    n=$(printf '%s\n' "$out" | grep -c .)
    err "Stale pattern '$label': $n hit(s)"
    printf '%s\n' "$out" | while IFS= read -r line; do
      [[ -n "$line" ]] && detail "$line"
    done
    denylist_hits=$((denylist_hits + n))
  fi
}

run_denylist '</invoke>' -F '</invoke>'
run_denylist '${SKILL_ROOT}' -F '${SKILL_ROOT}'
run_denylist 'setup-claude-code' -F 'setup-claude-code'
run_denylist 'Task tool' -F 'Task tool'
run_denylist 'pinned model ID (claude-*-4-N)' -E 'claude-(opus|sonnet|haiku)-4-[0-9]'

# CRLF — git grep -I can miss it depending on regex support across grep builds, so
# check byte-for-byte in python instead.
_ccpy_CRLF_OUT() { python3 - "$REPO_ROOT" <<'PYEOF'
import subprocess, sys, os

repo_root = sys.argv[1]
out = subprocess.run(
    ["git", "-C", repo_root, "ls-files", "--", "global", "gtm-local"],
    capture_output=True, text=True, check=False,
)
hits = []
for rel in out.stdout.splitlines():
    fpath = os.path.join(repo_root, rel)
    if not os.path.isfile(fpath):
        continue
    try:
        with open(fpath, "rb") as fh:
            data = fh.read()
    except OSError:
        continue
    if b"\x00" in data[:8000]:
        continue  # binary
    if b"\r" in data:
        hits.append(rel)

for h in hits:
    print(h)
PYEOF
}
CRLF_OUT="$(_ccpy_CRLF_OUT)"

if [[ -z "$CRLF_OUT" ]]; then
  ok "CRLF check: no CRLF line endings in tracked global/ or gtm-local/ files"
else
  crlf_count=$(printf '%s\n' "$CRLF_OUT" | grep -c .)
  err "CRLF check: $crlf_count file(s) with CRLF line endings"
  printf '%s\n' "$CRLF_OUT" | while IFS= read -r line; do
    [[ -n "$line" ]] && detail "$line"
  done
  denylist_hits=$((denylist_hits + crlf_count))
fi

if [[ "$denylist_hits" -eq 0 ]]; then
  ok "Stale-pattern denylist: clean"
fi

# ══════════════════════════════════════════════════════════════════════════════
# (c) Frontmatter — description: required
# ══════════════════════════════════════════════════════════════════════════════
rule "3. Frontmatter validation"

_ccpy_FM_OUT() { python3 - "$ROOT" <<'PYEOF'
import os, sys

root = sys.argv[1]
targets = []

cmd_dir = os.path.join(root, "commands")
if os.path.isdir(cmd_dir):
    for dirpath, dirnames, filenames in os.walk(cmd_dir):
        for fn in filenames:
            if fn.endswith(".md"):
                targets.append(os.path.join(dirpath, fn))

skills_dir = os.path.join(root, "skills")
if os.path.isdir(skills_dir):
    for name in sorted(os.listdir(skills_dir)):
        skill_md = os.path.join(skills_dir, name, "SKILL.md")
        if os.path.isfile(skill_md):
            targets.append(skill_md)

agents_dir = os.path.join(root, "agents")
if os.path.isdir(agents_dir):
    for fn in sorted(os.listdir(agents_dir)):
        if fn.endswith(".md"):
            targets.append(os.path.join(agents_dir, fn))

bad = []
checked = 0
for fpath in targets:
    checked += 1
    try:
        with open(fpath, "r", encoding="utf-8", errors="strict") as fh:
            lines = [l.rstrip("\r\n") for l in fh.readlines()]
    except (UnicodeDecodeError, OSError) as e:
        bad.append((fpath, f"unreadable: {e}"))
        continue

    if not lines or lines[0] != "---":
        bad.append((fpath, "does not start with '---' frontmatter fence"))
        continue

    end_idx = None
    for i in range(1, len(lines)):
        if lines[i] == "---":
            end_idx = i
            break
    if end_idx is None:
        bad.append((fpath, "frontmatter fence never closes"))
        continue

    block = lines[1:end_idx]
    has_description = any(l.startswith("description:") for l in block)
    if not has_description:
        bad.append((fpath, "missing 'description:' key in frontmatter"))

    # Value validation: model:/effort: are OPTIONAL (absence = inherit), but WHEN
    # present their value must be from the allowed set. See
    # references/dev/model-routing.md → "The real levers".
    VALID_MODELS = {"haiku", "sonnet", "opus", "fable", "best", "opusplan"}
    VALID_EFFORTS = {"low", "medium", "high", "xhigh", "max"}

    def strip_value(raw):
        v = raw.strip()
        if len(v) >= 2 and v[0] == v[-1] and v[0] in ("'", '"'):
            v = v[1:-1].strip()
        return v

    for l in block:
        if l.startswith("model:"):
            val = strip_value(l[len("model:"):])
            base = val
            if base.endswith("[1m]"):
                base = base[: -len("[1m]")]
            if base not in VALID_MODELS:
                bad.append((fpath, f"frontmatter model: '{val}' not in {{{','.join(sorted(VALID_MODELS))}}} (optionally suffixed with [1m])"))
        elif l.startswith("effort:"):
            val = strip_value(l[len("effort:"):])
            if val not in VALID_EFFORTS:
                bad.append((fpath, f"frontmatter effort: '{val}' not in {{{','.join(sorted(VALID_EFFORTS))}}}"))

print(f"CHECKED\t{checked}")
for fpath, reason in bad:
    rel = os.path.relpath(fpath, root)
    print(f"BAD\t{rel}: {reason}")
PYEOF
}
FM_OUT="$(_ccpy_FM_OUT)"

fm_checked=$(printf '%s\n' "$FM_OUT" | grep '^CHECKED' | cut -f2)
fm_bad=$(printf '%s\n' "$FM_OUT" | grep '^BAD' | cut -f2-)

if [[ -z "$fm_bad" ]]; then
  ok "Frontmatter: all ${fm_checked:-0} command/skill/agent files have '---' + description:"
else
  fm_bad_count=$(printf '%s\n' "$fm_bad" | grep -c .)
  err "Frontmatter: $fm_bad_count file(s) missing frontmatter or description:"
  printf '%s\n' "$fm_bad" | while IFS= read -r line; do
    [[ -n "$line" ]] && detail "$line"
  done
fi

# ══════════════════════════════════════════════════════════════════════════════
# (d) Placeholder sync — [A-Z_]+ tokens vs cc.config.json placeholders map
# ══════════════════════════════════════════════════════════════════════════════
rule "4. Placeholder sync (cc.config.json)"

_ccpy_PH_OUT() { python3 - "$ROOT" <<'PYEOF'
import json, os, re, sys

root = sys.argv[1]
config_path = os.path.join(root, "cc.config.json")

try:
    with open(config_path) as fh:
        cfg = json.load(fh)
except (OSError, json.JSONDecodeError) as e:
    print(f"CONFIG_ERROR\t{e}")
    sys.exit(0)

placeholders = set(cfg.get("placeholders", {}).keys())
# Loaded content (SKILL.md, command .md) references config as ${user_config.<key>}
# (the plugin userConfig mechanism); map keys back to their placeholder token so
# those references count as uses. Key = last segment of the config path.
key_to_ph = {path.split(".")[-1]: tok for tok, path in cfg.get("placeholders", {}).items()}

# Documented allowlist: bracket tokens that are NOT cc.config.json substitution
# targets — TOC/BBiT logic notation (single letters), generation-time fill-in
# stubs the model completes at runtime, and severity/acronym literals. A token
# belongs here only if cc-apply.sh must never substitute it.
# Note: all-underscore fill-in stubs like [___] no longer need listing here —
# token_re requires a leading A-Z, so they are never captured in the first place.
NON_CONFIG_TOKENS = {
    "[XX]",
    "[DATE]", "[TITLE]", "[TOPIC]", "[PERSONA]", "[GOAL]", "[METHOD]",
    "[CRITICAL]", "[HIGH]", "[PLACEHOLDER]",
    "[ERP]", "[TMS]", "[WMS]", "[OSD]", "[FTQ]", "[WOSR]",
    "[INDUSTRY]", "[SUITE]",
    # linkedin-post Script/Podcast stage directions (runtime markup, not config)
    "[TRANSITION]", "[PAUSE]", "[GUEST]",
}
# 1-2 letter algebra/notation vars ([A], [N], [X], BBiT cloud nodes [NA]/[WB],
# [XX], [AE]...) are never config tokens — real config tokens are full words.
single_letter_re = re.compile(r"^\[[A-Z]{1,2}\]$")

# Intentionally spare schema slots: placeholders kept in cc.config.json (and the
# plugin.json userConfig schema) with zero current uses, so a brand instance can
# adopt them without a schema change. Decision recorded in
# .specify/plans/cody-followups-2026-07.md (2026-07-08) — zero uses is expected,
# not drift. Remove a token from this set the moment content starts using it.
SPARE_PLACEHOLDERS = {"[PRODUCT_E]", "[SOLUTION_SUITE_2]"}

def is_non_config(tok):
    return tok in NON_CONFIG_TOKENS or single_letter_re.match(tok)

# Mirror cc-apply.sh's TARGET_DIRS / extensions / exclusions, scoped to skills+commands+agents
target_dirs = ["skills", "commands", "agents"]
extensions = (".md", ".json", ".py", ".css", ".html", ".js", ".vue", ".jsx")

# [A-Z][A-Z0-9_]* — digits allowed after the first char so numbered tokens
# like [SOLUTION_SUITE_1] are seen by both the undefined and unused checks.
token_re = re.compile(r"\[[A-Z][A-Z0-9_]*\]")
uc_re = re.compile(r"\$\{user_config\.([a-z0-9_]+)\}")
uses = {}  # token -> list of "relpath:lineno"

for d in target_dirs:
    base = os.path.join(root, d)
    if not os.path.isdir(base):
        continue
    for dirpath, dirnames, filenames in os.walk(base):
        for fn in filenames:
            if not fn.endswith(extensions):
                continue
            fpath = os.path.join(dirpath, fn)
            rel = os.path.relpath(fpath, root)
            # Mirror cc-apply.sh exclusions
            if rel.startswith("commands/setup/"):
                continue
            if rel.startswith("commands/maintain/"):
                continue
            try:
                with open(fpath, "r", encoding="utf-8", errors="strict") as fh:
                    lines = fh.readlines()
            except (UnicodeDecodeError, OSError):
                continue
            for lineno, line in enumerate(lines, start=1):
                for m in token_re.finditer(line):
                    tok = m.group(0)
                    uses.setdefault(tok, []).append(f"{rel}:{lineno}")
                for m in uc_re.finditer(line):
                    # unknown keys fall through as-is and get reported UNDEFINED
                    tok = key_to_ph.get(m.group(1), "${user_config." + m.group(1) + "}")
                    uses.setdefault(tok, []).append(f"{rel}:{lineno}")

used_tokens = {t for t in uses if not is_non_config(t)}
undefined = sorted(used_tokens - placeholders)
unused = sorted(placeholders - used_tokens - SPARE_PLACEHOLDERS)
spare = sorted((placeholders - used_tokens) & SPARE_PLACEHOLDERS)

for tok in undefined:
    examples = uses[tok][:3]
    print(f"UNDEFINED\t{tok}\t{'; '.join(examples)}\t{len(uses[tok])}")
for tok in unused:
    print(f"UNUSED\t{tok}")
for tok in spare:
    print(f"SPARE\t{tok}")
PYEOF
}
PH_OUT="$(_ccpy_PH_OUT)"

ph_config_error=$(printf '%s\n' "$PH_OUT" | grep '^CONFIG_ERROR' | cut -f2-)
ph_undefined=$(printf '%s\n' "$PH_OUT" | grep '^UNDEFINED')
ph_unused=$(printf '%s\n' "$PH_OUT" | grep '^UNUSED')
ph_spare=$(printf '%s\n' "$PH_OUT" | grep '^SPARE')

if [[ -n "$ph_config_error" ]]; then
  err "Placeholder sync: cannot read cc.config.json ($ph_config_error)"
else
  if [[ -z "$ph_undefined" ]]; then
    ok "Placeholder sync: every [A-Z_] bracket token used has a cc.config.json placeholders entry"
  else
    ph_undef_count=$(printf '%s\n' "$ph_undefined" | grep -c .)
    err "Placeholder sync: $ph_undef_count token(s) used but not in cc.config.json placeholders map"
    printf '%s\n' "$ph_undefined" | while IFS=$'\t' read -r _ tok examples count; do
      [[ -n "$tok" ]] || continue
      detail "$tok — $count use(s), e.g. $examples"
    done
  fi

  if [[ -z "$ph_unused" ]]; then
    ok "Placeholder sync: every cc.config.json placeholders entry is used (or intentionally spare)"
  else
    ph_unused_count=$(printf '%s\n' "$ph_unused" | grep -c .)
    warn "Placeholder sync: $ph_unused_count placeholders map entry(ies) with zero uses"
    printf '%s\n' "$ph_unused" | while IFS=$'\t' read -r _ tok; do
      [[ -n "$tok" ]] && detail "$tok"
    done
  fi

  if [[ -n "$ph_spare" ]]; then
    ph_spare_count=$(printf '%s\n' "$ph_spare" | grep -c .)
    notice "Placeholder sync: $ph_spare_count intentionally spare slot(s) with zero uses (expected)"
    printf '%s\n' "$ph_spare" | while IFS=$'\t' read -r _ tok; do
      [[ -n "$tok" ]] && detail "$tok"
    done
  fi
fi

# ══════════════════════════════════════════════════════════════════════════════
# (e) JSON validity
# ══════════════════════════════════════════════════════════════════════════════
rule "5. JSON validity"

JSON_FILES=""
for f in "$ROOT"/.claude-plugin/*.json "$ROOT/cc.config.json"; do
  [[ -f "$f" ]] && JSON_FILES="$JSON_FILES$f"$'\n'
done
while IFS= read -r f; do
  [[ -n "$f" ]] && JSON_FILES="$JSON_FILES$f"$'\n'
done < <(find "$ROOT" -type f \( -iname '*settings*.json' -o -iname '*hooks*.json' \) 2>/dev/null)

json_bad=0
json_checked=0
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  json_checked=$((json_checked + 1))
  rel="${f#"$ROOT"/}"
  errmsg="$(python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f" 2>&1 >/dev/null)"
  if [[ -n "$errmsg" ]]; then
    err "JSON validity: $rel is not valid JSON"
    detail "$errmsg"
    json_bad=$((json_bad + 1))
  fi
done < <(printf '%s' "$JSON_FILES" | sort -u)

if [[ "$json_bad" -eq 0 ]]; then
  ok "JSON validity: all $json_checked JSON file(s) parse cleanly"
fi

# ══════════════════════════════════════════════════════════════════════════════
# (f) Fenced-bash lint (shellcheck over extracted ```bash blocks)
# ══════════════════════════════════════════════════════════════════════════════
rule "6. Fenced-bash lint"

if ! command -v shellcheck >/dev/null 2>&1; then
  notice "shellcheck not on PATH — skipping fenced-bash lint"
else
  BASH_TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/cc-audit-bash.XXXXXX")"
  trap 'rm -rf "$BASH_TMP_DIR"' EXIT

  _ccpy_MANIFEST() { python3 - "$ROOT" "$BASH_TMP_DIR" <<'PYEOF'
import os, re, sys

root, tmp_dir = sys.argv[1], sys.argv[2]
scan_dirs = ["commands", "skills"]
fence_re = re.compile(r"```bash\n(.*?)```", re.DOTALL)
# Illustrative-template detectors: a `<free text>` angle-bracket placeholder anywhere
# in the block, or a line that is *entirely* a `[free text]` bracket placeholder (the
# fill-in-the-blank style used by sop-creator/how-to templates). Either marks the whole
# block as documentation, not real bash, so it's excluded from shellcheck.
angle_placeholder_re = re.compile(r"<[^<>\n]+>")
bracket_line_re = re.compile(r"^\s*\[[^\[\]\n]+\]\s*$")


def is_illustrative(block):
    if angle_placeholder_re.search(block):
        return True
    for line in block.splitlines():
        if bracket_line_re.match(line):
            return True
    return False

idx = 0
for d in scan_dirs:
    base = os.path.join(root, d)
    if not os.path.isdir(base):
        continue
    for dirpath, dirnames, filenames in os.walk(base):
        for fn in filenames:
            if not fn.endswith(".md"):
                continue
            fpath = os.path.join(dirpath, fn)
            try:
                with open(fpath, "r", encoding="utf-8", errors="strict") as fh:
                    text = fh.read()
            except (UnicodeDecodeError, OSError):
                continue
            for m in fence_re.finditer(text):
                block = m.group(1)
                if is_illustrative(block):
                    continue  # illustrative template block
                if not block.strip():
                    continue
                idx += 1
                lineno = text[: m.start()].count("\n") + 1
                tmp_path = os.path.join(tmp_dir, f"block_{idx}.sh")
                with open(tmp_path, "w") as out:
                    out.write(block)
                rel = os.path.relpath(fpath, root)
                print(f"{tmp_path}\t{rel}:{lineno}")
PYEOF
  }
  MANIFEST="$(_ccpy_MANIFEST)"

  sc_bad=0
  sc_checked=0
  if [[ -n "$MANIFEST" ]]; then
    while IFS=$'\t' read -r tmp_path source_ref; do
      [[ -z "$tmp_path" ]] && continue
      sc_checked=$((sc_checked + 1))
      sc_out="$(shellcheck -S error --shell=bash "$tmp_path" 2>&1)"
      sc_rc=$?
      if [[ "$sc_rc" -ne 0 ]]; then
        err "Fenced bash: shellcheck finding(s) in $source_ref"
        printf '%s\n' "$sc_out" | while IFS= read -r line; do
          [[ -n "$line" ]] && detail "$line"
        done
        sc_bad=$((sc_bad + 1))
      fi
    done <<< "$MANIFEST"
  fi

  if [[ "$sc_bad" -eq 0 ]]; then
    ok "Fenced bash: $sc_checked block(s) extracted, shellcheck -S error clean"
  fi
fi

# ══════════════════════════════════════════════════════════════════════════════
# (g) INVENTORY drift (via cc-inventory.sh --check)
# ══════════════════════════════════════════════════════════════════════════════
rule "7. INVENTORY.md drift"

INVENTORY_SCRIPT="$SCRIPT_DIR/cc-inventory.sh"
if [[ ! -f "$INVENTORY_SCRIPT" ]]; then
  notice "scripts/cc-inventory.sh not found — skipping INVENTORY drift check"
else
  inv_out="$(bash "$INVENTORY_SCRIPT" --check 2>&1)"
  inv_rc=$?
  if [[ "$inv_rc" -eq 0 ]]; then
    ok "INVENTORY.md: up to date with frontmatter"
  else
    err "INVENTORY.md: drift detected — run 'bash scripts/cc-inventory.sh' to regenerate"
    inv_lines=$(printf '%s\n' "$inv_out" | grep -c .)
    printf '%s\n' "$inv_out" | head -30 | while IFS= read -r line; do
      [[ -n "$line" ]] && detail "$line"
    done
    if [[ "$inv_lines" -gt 30 ]]; then
      detail "… $((inv_lines - 30)) more line(s). Run 'bash scripts/cc-inventory.sh --check' for the full diff."
    fi
  fi
fi

# ══════════════════════════════════════════════════════════════════════════════
# (h) Model-routing tier coverage — mechanical commands should carry model:/effort:
# ══════════════════════════════════════════════════════════════════════════════
rule "8. Model-routing tier coverage"

_ccpy_MR_OUT() { python3 - "$ROOT" <<'PYEOF'
import os, sys

root = sys.argv[1]

# Conservative allowlist of mechanical command filename stems that policy says should
# carry model:/effort: frontmatter (see references/dev/model-routing.md → "Tier policy"
# and "Applied tags"). Seeded from the four already-tagged examples, plus `digest` whose
# own body describes it as a "deterministic, script-driven board". Matched on the *exact*
# filename stem — never a substring — so judgment-heavy commands can't false-positive.
# This is a policy nudge (warn), not a bug (err): false positives are worse than misses,
# so the list stays narrow. To extend, add a stem here only when it's genuinely mechanical.
MECHANICAL_STEMS = {
    "list",              # github/list
    "worktree",          # github/worktree
    "worktree-cleanup",  # github/worktree-cleanup
    "changelog",         # release/changelog
    "digest",            # github/digest
}

cmd_dir = os.path.join(root, "commands")
checked = 0
missing = []

if os.path.isdir(cmd_dir):
    for dirpath, dirnames, filenames in os.walk(cmd_dir):
        dirnames[:] = [dn for dn in dirnames if dn != ".git"]
        for fn in sorted(filenames):
            if not fn.endswith(".md"):
                continue
            stem = fn[:-3]
            if stem not in MECHANICAL_STEMS:
                continue
            fpath = os.path.join(dirpath, fn)
            checked += 1
            try:
                with open(fpath, "r", encoding="utf-8", errors="strict") as fh:
                    lines = [l.rstrip("\r\n") for l in fh.readlines()]
            except (UnicodeDecodeError, OSError):
                continue
            # Same frontmatter parse the frontmatter-validation pass (section 3) uses:
            # first line must be '---', block runs to the next '---'.
            if not lines or lines[0] != "---":
                block = []
            else:
                end_idx = None
                for i in range(1, len(lines)):
                    if lines[i] == "---":
                        end_idx = i
                        break
                block = lines[1:end_idx] if end_idx is not None else []
            has_model = any(l.startswith("model:") for l in block)
            has_effort = any(l.startswith("effort:") for l in block)
            absent = []
            if not has_model:
                absent.append("model:")
            if not has_effort:
                absent.append("effort:")
            if absent:
                rel = os.path.relpath(fpath, root)
                missing.append(f"{rel}\t{', '.join(absent)}")

print(f"CHECKED\t{checked}")
for m in missing:
    print(f"MISSING\t{m}")
PYEOF
}
MR_OUT="$(_ccpy_MR_OUT)"

mr_checked=$(printf '%s\n' "$MR_OUT" | grep '^CHECKED' | cut -f2)
mr_missing=$(printf '%s\n' "$MR_OUT" | grep '^MISSING' | cut -f2-)

if [[ -z "$mr_missing" ]]; then
  ok "Model-routing tier coverage: all ${mr_checked:-0} allowlisted mechanical command(s) carry model: + effort:"
else
  mr_missing_count=$(printf '%s\n' "$mr_missing" | grep -c .)
  warn "Model-routing tier coverage: ${mr_checked:-0} allowlisted command(s) checked, $mr_missing_count missing model:/effort: tag(s)"
  printf '%s\n' "$mr_missing" | while IFS=$'\t' read -r rel absent; do
    [[ -n "$rel" ]] && detail "$rel — missing $absent"
  done
fi

# ══════════════════════════════════════════════════════════════════════════════
# (i) CLAUDE.md line budget — Layer 1 cap (references/dev/context-engineering.md)
# ══════════════════════════════════════════════════════════════════════════════
rule "9. CLAUDE.md line budget"

CLAUDE_MD_BUDGET=500
claude_md_checked=0

for cmd_md in "$ROOT/CLAUDE.md" "$REPO_ROOT/CLAUDE.md" "$REPO_ROOT/gtm-local/CLAUDE.md"; do
  [[ -f "$cmd_md" ]] || continue          # absence is fine — only presence+over-budget matters
  claude_md_checked=$((claude_md_checked + 1))
  rel="${cmd_md#"$REPO_ROOT"/}"
  n_lines=$(wc -l < "$cmd_md" | tr -d ' ')
  if [[ "$n_lines" -le "$CLAUDE_MD_BUDGET" ]]; then
    ok "CLAUDE.md line budget: $rel within cap"
    detail "$n_lines / $CLAUDE_MD_BUDGET lines"
  else
    warn "CLAUDE.md line budget: $rel exceeds the ${CLAUDE_MD_BUDGET}-line Layer 1 cap"
    detail "$n_lines / $CLAUDE_MD_BUDGET lines"
  fi
done

if [[ "$claude_md_checked" -eq 0 ]]; then
  notice "CLAUDE.md line budget: no CLAUDE.md files found to check"
fi

# ══════════════════════════════════════════════════════════════════════════════
# (j) Per-command size budget — command bodies are injected verbatim per
#     invocation, and chains pay duplication multiplicatively (ADR-002 D6).
#     Legitimately long commands (embedded templates, scaffolds, multi-mode
#     runbooks) declare `size-budget: exempt — <reason>` in frontmatter; the
#     reason is mandatory so every exemption stays a recorded judgment, and a
#     file back under budget with a lingering marker is flagged as stale.
# ══════════════════════════════════════════════════════════════════════════════
rule "10. Per-command size budget"

CMD_LINE_BUDGET=150
cmd_budget_checked=0
cmd_over=""
cmd_exempt=""
cmd_bad_marker=""

# print the size-budget: line from the leading frontmatter block, if any
size_budget_marker() {
  awk 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} /^size-budget:/{print; exit}' "$1"
}

if [[ -d "$ROOT/commands" ]]; then
  while IFS= read -r cmd_file; do
    [[ -z "$cmd_file" ]] && continue
    cmd_budget_checked=$((cmd_budget_checked + 1))
    rel="${cmd_file#"$ROOT"/}"
    n_lines=$(wc -l < "$cmd_file" | tr -d ' ')
    marker="$(size_budget_marker "$cmd_file")"
    if [[ "$n_lines" -gt "$CMD_LINE_BUDGET" ]]; then
      # the reason must contain at least one alphanumeric — a bare "exempt —" is reasonless
      if [[ "$marker" =~ ^size-budget:[[:space:]]*exempt[[:space:]]+.*[[:alnum:]] ]]; then
        cmd_exempt="$cmd_exempt$rel	$n_lines"$'\n'
      elif [[ -n "$marker" ]]; then
        cmd_bad_marker="$cmd_bad_marker$rel	missing reason (want: size-budget: exempt — <reason>)"$'\n'
        cmd_over="$cmd_over$rel	$n_lines"$'\n'
      else
        cmd_over="$cmd_over$rel	$n_lines"$'\n'
      fi
    elif [[ -n "$marker" ]]; then
      cmd_bad_marker="$cmd_bad_marker$rel	stale exemption ($n_lines lines is within budget — drop the marker)"$'\n'
    fi
  done < <(find "$ROOT/commands" -type f -name '*.md' | sort)
fi

if [[ -z "$cmd_over" ]]; then
  ok "Per-command size budget: all $cmd_budget_checked command file(s) within the ${CMD_LINE_BUDGET}-line budget (or exempt with reason)"
else
  cmd_over_count=$(printf '%s' "$cmd_over" | grep -c .)
  warn "Per-command size budget: $cmd_over_count of $cmd_budget_checked command file(s) exceed the ${CMD_LINE_BUDGET}-line budget"
  printf '%s' "$cmd_over" | while IFS=$'\t' read -r rel n_lines; do
    [[ -n "$rel" ]] && detail "$rel — $n_lines lines"
  done
fi

if [[ -n "$cmd_bad_marker" ]]; then
  cmd_bad_count=$(printf '%s' "$cmd_bad_marker" | grep -c .)
  warn "Per-command size budget: $cmd_bad_count malformed/stale size-budget marker(s)"
  printf '%s' "$cmd_bad_marker" | while IFS=$'\t' read -r rel why; do
    [[ -n "$rel" ]] && detail "$rel — $why"
  done
fi

if [[ -n "$cmd_exempt" ]]; then
  cmd_exempt_count=$(printf '%s' "$cmd_exempt" | grep -c .)
  notice "Per-command size budget: $cmd_exempt_count command(s) exempt by declared reason"
  printf '%s' "$cmd_exempt" | while IFS=$'\t' read -r rel n_lines; do
    [[ -n "$rel" ]] && detail "$rel — $n_lines lines"
  done
fi

# ══════════════════════════════════════════════════════════════════════════════
# (k) Duplicate stack-resolution boilerplate — the ~80-word fallback paragraph
#     should live once, in references/dev/stack-resolution.md, with commands
#     pointing at it. Warn if the distinctive fingerprint reappears in >1 command
#     file (ADR-002 D6). Scoped to commands/ so this script's own literal below
#     is not counted.
# ══════════════════════════════════════════════════════════════════════════════
rule "11. Duplicate stack-resolution boilerplate"

BOILERPLATE_FINGERPRINT='auto-detect once from project markers'
dup_files=""
if [[ -d "$ROOT/commands" ]]; then
  dup_files="$(grep -rlF "$BOILERPLATE_FINGERPRINT" "$ROOT/commands" 2>/dev/null | sort)"
fi
dup_count=0
[[ -n "$dup_files" ]] && dup_count=$(printf '%s\n' "$dup_files" | grep -c .)

if [[ "$dup_count" -le 1 ]]; then
  ok "Duplicate stack-resolution boilerplate: fingerprint in $dup_count command file(s) (≤1 — deduped to the reference)"
else
  warn "Duplicate stack-resolution boilerplate: fingerprint in $dup_count command files — collapse each to the canonical pointer sentence (references/dev/stack-resolution.md)"
  printf '%s\n' "$dup_files" | while IFS= read -r line; do
    [[ -n "$line" ]] && detail "${line#"$ROOT"/}"
  done
fi

# ══════════════════════════════════════════════════════════════════════════════
# (l) Install/mirror profile definitions — scripts/mirror-profiles/*.json
# ══════════════════════════════════════════════════════════════════════════════
rule "12. Profile definitions (scripts/mirror-profiles/*.json)"

PROFILE_DIR="$SCRIPT_DIR/mirror-profiles"
if [[ ! -d "$PROFILE_DIR" ]]; then
  notice "scripts/mirror-profiles/ not found — skipping profile validation"
else
  _ccpy_PROFILE_OUT() { python3 - "$ROOT" "$PROFILE_DIR" <<'PYEOF'
import json, os, sys

root, profile_dir = sys.argv[1], sys.argv[2]

checked = 0
for fn in sorted(os.listdir(profile_dir)):
    if not fn.endswith(".json"):
        continue
    checked += 1
    fpath = os.path.join(profile_dir, fn)
    rel = os.path.relpath(fpath, root)
    try:
        with open(fpath, "r", encoding="utf-8") as fh:
            data = json.load(fh)
    except (OSError, UnicodeDecodeError) as e:
        print(f"ERR\t{rel}\tunreadable: {e}")
        continue
    except json.JSONDecodeError as e:
        print(f"ERR\t{rel}\tinvalid JSON: {e}")
        continue

    for field in ("pluginName", "pluginDescription", "marketplaceName", "marketplaceDescription"):
        val = data.get(field)
        if not isinstance(val, str) or not val.strip():
            print(f"ERR\t{rel}\tmissing or empty required field: {field}")

    exclude = data.get("exclude")
    if not isinstance(exclude, list):
        print(f"ERR\t{rel}\t\"exclude\" must be a list")
        continue
    for path in exclude:
        if not isinstance(path, str):
            print(f"ERR\t{rel}\tnon-string exclude entry: {path!r}")
            continue
        if not os.path.exists(os.path.join(root, path)):
            print(f"ERR\t{rel}\texcludes '{path}' but no such path exists under global/ — stale entry")

print(f"CHECKED\t{checked}")
PYEOF
  }
  PROFILE_OUT="$(_ccpy_PROFILE_OUT)"

  profile_checked=$(printf '%s\n' "$PROFILE_OUT" | grep '^CHECKED' | cut -f2)
  profile_errs=$(printf '%s\n' "$PROFILE_OUT" | grep '^ERR')

  if [[ -z "$profile_errs" ]]; then
    ok "Profile definitions: ${profile_checked:-0} profile(s) valid (JSON parses, exclude paths exist, descriptions non-empty)"
  else
    profile_err_count=$(printf '%s\n' "$profile_errs" | grep -c .)
    err "Profile definitions: $profile_err_count issue(s) across ${profile_checked:-0} profile(s)"
    printf '%s\n' "$profile_errs" | while IFS=$'\t' read -r _tag rel msg; do
      [[ -n "$rel" ]] && detail "$rel — $msg"
    done
  fi
fi

# ══════════════════════════════════════════════════════════════════════════════
# (m) Baked-substitution guard — the tracked tree must keep its ${user_config.*}
#     tokens. cc-apply must only ever run against installed copies; if it runs
#     against the source tree, tokens silently become literal config values (the
#     2026-07-08 incident: ~57 files baked in an agent worktree). Value-matching
#     can't catch this (defaults like "MEDDPICC" appear legitimately), so we
#     compare per-file token-bearing line counts against git HEAD instead: a
#     working-tree count BELOW HEAD's is the baking signature. ERROR, not warn —
#     it's a clean-room violation. No-op on committed state (worktree == HEAD)
#     and skipped outside a git checkout (installed cache copies).
# ══════════════════════════════════════════════════════════════════════════════
rule "13. Baked-substitution guard (tracked \${user_config.*} tokens survive in the working tree)"

if ! git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  notice "Baked-substitution guard: not a git checkout — skipped (source-repo check only)"
else
  _ccpy_BAKE_OUT() { cd "$REPO_ROOT" && python3 - <<'PYEOF'
import os, subprocess

TOKEN = "${user_config."

head = subprocess.run(
    ["git", "grep", "-c", "-F", TOKEN, "HEAD", "--", "global/"],
    capture_output=True, text=True,
).stdout

checked = 0
for line in head.splitlines():
    # format: HEAD:path:count
    try:
        _, path, cnt = line.split(":", 2)
        head_cnt = int(cnt)
    except ValueError:
        continue
    checked += 1
    if not os.path.exists(path):
        continue  # deleted/renamed — other checks own file lifecycle
    wt_cnt = 0
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            for l in fh:
                if TOKEN in l:
                    wt_cnt += 1
    except OSError:
        continue
    if wt_cnt < head_cnt:
        print(f"BAKED\t{path}\t{head_cnt}\t{wt_cnt}")
print(f"CHECKED\t{checked}")
PYEOF
  }
  BAKE_OUT="$(_ccpy_BAKE_OUT)"

  bake_checked=$(printf '%s\n' "$BAKE_OUT" | grep '^CHECKED' | cut -f2)
  bake_hits=$(printf '%s\n' "$BAKE_OUT" | grep '^BAKED' || true)

  if [[ -z "$bake_hits" ]]; then
    ok "Baked-substitution guard: ${bake_checked:-0} token-bearing tracked file(s) intact vs HEAD"
  else
    bake_count=$(printf '%s\n' "$bake_hits" | grep -c .)
    err "Baked-substitution guard: $bake_count file(s) lost \${user_config.*} tokens vs HEAD — cc-apply likely ran against the source tree; restore with git checkout -- <file> (intentional token removals clear once committed)"
    printf '%s\n' "$bake_hits" | while IFS=$'\t' read -r _tag path head_cnt wt_cnt; do
      [[ -n "$path" ]] && detail "$path — token lines $head_cnt at HEAD → $wt_cnt in working tree"
    done
  fi
fi

# ══════════════════════════════════════════════════════════════════════════════
# (n) Tracked settings shape — .claude/settings.json files this repo ships must
#     match the shapes Claude Code validates at load time. A schema violation
#     makes Claude Code skip the ENTIRE file (not just the bad key), which
#     silently killed one-prompt plugin enablement when the marketplace-source
#     schema moved from bare strings to typed objects (2026-07-08 incident).
#     Offline by design: we validate the structural rules for the keys this
#     repo actually uses, not the full upstream schema.
# ══════════════════════════════════════════════════════════════════════════════
rule "14. Tracked settings shape (.claude/settings.json load-time validity)"

_ccpy_SETTINGS_OUT() { python3 - "$REPO_ROOT" <<'PYEOF'
import json, os, sys

repo = sys.argv[1]
VALID_SOURCE_TYPES = {
    # discriminator -> required companion field
    "directory": "path",
    "local": "path",
    "github": "repo",
    "git": "url",
    "url": "url",
}

candidates = [
    os.path.join(repo, ".claude", "settings.json"),
    os.path.join(repo, "global", ".claude", "settings.json"),
]

checked = 0
for fpath in candidates:
    if not os.path.isfile(fpath):
        continue
    checked += 1
    rel = os.path.relpath(fpath, repo)
    try:
        with open(fpath, encoding="utf-8") as fh:
            data = json.load(fh)
    except (OSError, json.JSONDecodeError) as e:
        print(f"ERR\t{rel}\tinvalid JSON (Claude Code will skip the whole file): {e}")
        continue
    if not isinstance(data, dict):
        print(f"ERR\t{rel}\ttop level must be an object")
        continue

    mkts = data.get("extraKnownMarketplaces")
    if mkts is not None:
        if not isinstance(mkts, dict):
            print(f"ERR\t{rel}\textraKnownMarketplaces must be an object")
        else:
            for name, entry in mkts.items():
                where = f"extraKnownMarketplaces.{name}"
                if not isinstance(entry, dict):
                    print(f"ERR\t{rel}\t{where} must be an object")
                    continue
                src = entry.get("source")
                if not isinstance(src, dict):
                    print(f"ERR\t{rel}\t{where}.source must be an OBJECT "
                          f"(e.g. {{\"source\": \"directory\", \"path\": \"./global\"}}) — "
                          f"got {type(src).__name__}; the bare-string form is rejected "
                          f"and Claude Code skips the entire file")
                    continue
                stype = src.get("source")
                if stype not in VALID_SOURCE_TYPES:
                    print(f"ERR\t{rel}\t{where}.source.source must be one of "
                          f"{sorted(VALID_SOURCE_TYPES)} — got {stype!r}")
                    continue
                needed = VALID_SOURCE_TYPES[stype]
                if not isinstance(src.get(needed), str) or not src[needed].strip():
                    print(f"ERR\t{rel}\t{where}.source ({stype}) requires a non-empty "
                          f"string field \"{needed}\"")

    plugins = data.get("enabledPlugins")
    if plugins is not None:
        if not isinstance(plugins, dict):
            print(f"ERR\t{rel}\tenabledPlugins must be an object")
        else:
            for pname, val in plugins.items():
                if not isinstance(val, bool):
                    print(f"ERR\t{rel}\tenabledPlugins.{pname} must be a boolean — got {val!r}")

print(f"CHECKED\t{checked}")
PYEOF
}
SETTINGS_OUT="$(_ccpy_SETTINGS_OUT)"

settings_checked=$(printf '%s\n' "$SETTINGS_OUT" | grep '^CHECKED' | cut -f2)
settings_errs=$(printf '%s\n' "$SETTINGS_OUT" | grep '^ERR' || true)

if [[ "${settings_checked:-0}" -eq 0 ]]; then
  notice "Tracked settings shape: no tracked .claude/settings.json found — skipped"
elif [[ -z "$settings_errs" ]]; then
  ok "Tracked settings shape: ${settings_checked} settings file(s) load-time valid"
else
  settings_err_count=$(printf '%s\n' "$settings_errs" | grep -c .)
  err "Tracked settings shape: $settings_err_count issue(s) — Claude Code skips a whole settings file on any schema violation"
  printf '%s\n' "$settings_errs" | while IFS=$'\t' read -r _tag rel msg; do
    [[ -n "$rel" ]] && detail "$rel — $msg"
  done
fi

# ══════════════════════════════════════════════════════════════════════════════
# Summary
# ══════════════════════════════════════════════════════════════════════════════
rule "Summary"
printf '  Errors:   %d\n' "$ERRORS"
printf '  Warnings: %d\n' "$WARNINGS"
printf '  Notices:  %d\n' "$NOTICES"
echo ""

if [[ "$ERRORS" -gt 0 ]]; then
  echo "❌ cc-audit FAILED — $ERRORS error(s) found."
  exit 1
else
  echo "✅ cc-audit PASSED — 0 errors ($WARNINGS warning(s), $NOTICES notice(s))."
  exit 0
fi
