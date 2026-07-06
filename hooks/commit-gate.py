#!/usr/bin/env python3
"""PreToolUse commit gate: run the repo's validation before any `git commit`.

Bundled with the cc plugin (hooks/hooks.json). A repo opts in by committing
`.claude/piv-gate.json` with exactly one key:

    {"validate": "<literal shell command>"}

Contract:
  * Matches PreToolUse Bash calls whose command invokes `git commit`
    (word-boundary match AFTER stripping quoted substrings — `git commit`
    inside a `-m "..."` message must not trigger).
  * `PIV_SKIP_GATE=1` -> one stderr notice, exit 0 (kill-switch).
  * Gate file read from **HEAD** (`git show HEAD:.claude/piv-gate.json`) so
    an uncommitted edit cannot weaken the gate:
      - absent at HEAD -> exit 0, zero output (scratch repos stay silent)
      - present but unparseable at HEAD -> exit 2 (a broken gate fails CLOSED)
      - working-tree copy differs from HEAD -> exit 2 ("commit it alone first")
  * Runs the literal HEAD command; non-zero -> exit 2 with the output tail.
  * `git` unavailable / not a repo -> exit 0 (nothing to gate).

Design rules: stdlib only, no network; fail OPEN on unexpected internal
errors except a present-but-broken gate file, which fails CLOSED.
`--self-test` exercises the pure functions (matcher, gate parsing) with
embedded fixtures — no real git mutation.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys

GATE_PATH = ".claude/piv-gate.json"

# Matches `git commit` as an invocation: `git` at a word start, optional
# global flags (e.g. `git -C x commit`, `git -c a=b commit`), then `commit`.
_GIT_COMMIT_RE = re.compile(r"(?:^|[;&|(`]|\bthen\s|\bdo\s)\s*git\s+(?:-\S+\s+|-[cC]\s+\S+\s+)*commit\b")

_QUOTED_RE = re.compile(
    r"""'(?:[^'\\]|\\.)*'|"(?:[^"\\]|\\.)*\"""",
    re.DOTALL,
)


def strip_quoted(command: str) -> str:
    """Remove single/double-quoted substrings so quoted text can't match."""
    return _QUOTED_RE.sub(" ", command)


def is_git_commit(command: str) -> bool:
    """True if the bash command invokes `git commit` outside quotes."""
    if not command:
        return False
    return bool(_GIT_COMMIT_RE.search(strip_quoted(command)))


def parse_gate(raw: str) -> str | None:
    """Gate file text -> validate command. Raises ValueError if broken."""
    data = json.loads(raw)
    if (
        not isinstance(data, dict)
        or set(data.keys()) != {"validate"}
        or not isinstance(data["validate"], str)
        or not data["validate"].strip()
    ):
        raise ValueError("gate file must be exactly {\"validate\": \"<command>\"}")
    return data["validate"]


def _git_show_head_gate(cwd: str) -> tuple[bool, str]:
    """Returns (exists_at_head, content). Raises on git being unusable."""
    out = subprocess.run(
        ["git", "show", f"HEAD:{GATE_PATH}"],
        cwd=cwd, capture_output=True, text=True, timeout=5,
    )
    if out.returncode != 0:
        return False, ""
    return True, out.stdout


def block(message: str) -> None:
    print(f"PIV COMMIT GATE: {message}", file=sys.stderr)
    sys.exit(2)


def main() -> None:
    try:
        hook_input = json.load(sys.stdin)
    except Exception:
        sys.exit(0)  # malformed/absent stdin: not ours to judge

    try:
        if not isinstance(hook_input, dict):
            sys.exit(0)
        tool_input = hook_input.get("tool_input", {}) or {}
        command = tool_input.get("command", "") if isinstance(tool_input, dict) else ""
        if not is_git_commit(command):
            sys.exit(0)

        if os.environ.get("PIV_SKIP_GATE") == "1":
            print("piv commit gate: gate skipped by PIV_SKIP_GATE", file=sys.stderr)
            sys.exit(0)

        cwd = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
        try:
            exists, head_raw = _git_show_head_gate(cwd)
        except Exception:
            sys.exit(0)  # git unavailable / not a repo: nothing to gate
        if not exists:
            sys.exit(0)  # no gate at HEAD: silent no-op

        try:
            validate_cmd = parse_gate(head_raw)
        except Exception:
            block(f"{GATE_PATH} at HEAD is unparseable — a present-but-broken "
                  "gate fails closed. Fix the gate file, commit it alone, then retry.")

        try:
            tree_raw = open(os.path.join(cwd, GATE_PATH), encoding="utf-8").read()
        except FileNotFoundError:
            tree_raw = ""
        if tree_raw.strip() != head_raw.strip():
            block("gate file modified in the working tree — commit it alone first "
                  "so the gate command itself is reviewed.")

        result = subprocess.run(
            validate_cmd, shell=True, cwd=cwd,
            capture_output=True, text=True, timeout=300,
        )
        if result.returncode != 0:
            tail = ((result.stdout or "") + (result.stderr or "")).strip().splitlines()[-15:]
            block("validation failed — fix before committing:\n" + "\n".join(tail))
        sys.exit(0)
    except SystemExit:
        raise
    except Exception:
        sys.exit(0)  # unexpected internal error outside the gate logic: fail open


def _self_test() -> int:
    msg_cmd = 'git add -A && git log --grep "run git commit now"'
    fixtures: list[tuple[str, bool, bool]] = [
        # (name, matcher input is a commit?, expected)
        ("plain git commit matches", is_git_commit("git commit -m 'x'"), True),
        ("chained commit matches", is_git_commit("git add -A && git commit"), True),
        ("git -C path commit matches", is_git_commit("git -C sub commit"), True),
        ("quoted phrase does not match", is_git_commit('echo "please git commit later"'), False),
        ("commit inside -m message does not match",
         is_git_commit('git commit -m "revert: git commit gate"'), True),  # outer commit still real
        ("grep for phrase does not match", is_git_commit(msg_cmd), False),
        ("git status does not match", is_git_commit("git status"), False),
        ("empty command does not match", is_git_commit(""), False),
    ]
    parse_cases: list[tuple[str, str, bool]] = [
        ("valid gate parses", '{"validate": "bash global/scripts/cc-audit.sh"}', True),
        ("extra key rejected", '{"validate": "x", "also": 1}', False),
        ("wrong type rejected", '{"validate": 3}', False),
        ("garbage rejected", "not json", False),
        ("empty command rejected", '{"validate": "  "}', False),
    ]

    failures = 0
    for name, got, expected in fixtures:
        ok = got == expected
        print(f"{'PASS' if ok else 'FAIL'}  {name}")
        failures += 0 if ok else 1
    for name, raw, should_parse in parse_cases:
        try:
            parse_gate(raw)
            parsed = True
        except Exception:
            parsed = False
        ok = parsed == should_parse
        print(f"{'PASS' if ok else 'FAIL'}  {name}")
        failures += 0 if ok else 1
    total = len(fixtures) + len(parse_cases)
    print(f"self-test: {total - failures}/{total} passed")
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    if "--self-test" in sys.argv:
        sys.exit(_self_test())
    main()
