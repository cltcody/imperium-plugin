#!/usr/bin/env bash
# cc-statusline.sh — lean Claude Code statusline: model | repo ⎇ branch± | PIV phase → next
#
# Claude Code pipes a JSON object on stdin on EVERY render (fields include
# model.display_name and workspace.current_dir / a top-level cwd, among others
# we don't use). This script must print exactly ONE line to stdout, fast, and
# must never exit nonzero or write to stderr in the happy path — a broken
# statusline command breaks every render, forever, until someone notices.
#
# Parsing is defensive and layered: jq (fast, if installed) -> python3
# (always available in this repo's toolchain) -> grep/sed (last resort, in
# case neither is on PATH). Unknown/missing JSON fields never break output —
# every field has a safe default.
#
# PIV segment: shells out once to global/hooks/piv_state.py --cwd <cwd>,
# which prints a tab-separated `phase<TAB>last<TAB>next` line. That script is
# also the SessionStart PIV hook's source of truth, so the statusline and the
# hook can never disagree. If piv_state.py is missing, or the cwd isn't a PIV
# project (empty phase), the PIV segment is OMITTED entirely — no noise.
#
# Non-git cwd: print just the model segment.
#
# Wiring: opt-in via `bash install.sh --with-statusline` (merges the
# `statusLine` key into ~/.claude/settings.json) — see global/README.md.
#
# Lean scope (owner-declined): no drift flag, no context-%, no cost segment.
# See docs/adr/ADR-002-harness-hardening.md decision D7.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIV_STATE_PY="$SCRIPT_DIR/../hooks/piv_state.py"

INPUT="$(cat 2>/dev/null || true)"

MODEL=""
CWD=""

if command -v jq >/dev/null 2>&1; then
  MODEL="$(printf '%s' "$INPUT" | jq -r '.model.display_name // empty' 2>/dev/null)"
  CWD="$(printf '%s' "$INPUT" | jq -r '.workspace.current_dir // .cwd // empty' 2>/dev/null)"
elif command -v python3 >/dev/null 2>&1; then
  PARSED="$(printf '%s' "$INPUT" | python3 -c '
import json, sys

try:
    data = json.load(sys.stdin)
except Exception:
    data = {}
if not isinstance(data, dict):
    data = {}

model = ""
try:
    model = (data.get("model") or {}).get("display_name") or ""
except Exception:
    pass

cwd = ""
try:
    cwd = (data.get("workspace") or {}).get("current_dir") or data.get("cwd") or ""
except Exception:
    pass

sys.stdout.write(str(model) + "\n" + str(cwd) + "\n")
' 2>/dev/null)"
  MODEL="$(printf '%s\n' "$PARSED" | sed -n '1p')"
  CWD="$(printf '%s\n' "$PARSED" | sed -n '2p')"
else
  # Last-resort grep/sed extraction — good enough for well-formed, single-line-ish JSON.
  MODEL="$(printf '%s' "$INPUT" | grep -o '"display_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)"$/\1/')"
  CWD="$(printf '%s' "$INPUT" | grep -o '"current_dir"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)"$/\1/')"
  if [[ -z "$CWD" ]]; then
    CWD="$(printf '%s' "$INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)"$/\1/')"
  fi
fi

MODEL_SEG="${MODEL:-Claude}"
CWD="${CWD:-$PWD}"

GIT_SEG=""
if command -v git >/dev/null 2>&1 && git -C "$CWD" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  TOPLEVEL="$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null)"
  REPO_BASENAME="$(basename "${TOPLEVEL:-$CWD}")"
  BRANCH="$(git -C "$CWD" branch --show-current 2>/dev/null)"
  DIRTY=""
  if [[ -n "$(git -C "$CWD" status --porcelain 2>/dev/null)" ]]; then
    DIRTY="±"
  fi
  if [[ -n "$BRANCH" ]]; then
    GIT_SEG="${REPO_BASENAME} ⎇ ${BRANCH}${DIRTY}"
  else
    GIT_SEG="$REPO_BASENAME"
  fi
fi

PIV_SEG=""
if [[ -n "$GIT_SEG" && -f "$PIV_STATE_PY" ]] && command -v python3 >/dev/null 2>&1; then
  PIV_OUT="$(python3 "$PIV_STATE_PY" --cwd "$CWD" 2>/dev/null)"
  if [[ -n "$PIV_OUT" ]]; then
    # `read -d $'\t'`/IFS=$'\t' both eat a leading empty field (tab counts as
    # IFS whitespace even when IFS is set to just tab) — cut doesn't.
    PHASE="$(printf '%s' "$PIV_OUT" | cut -f1)"
    NEXT="$(printf '%s' "$PIV_OUT" | cut -f3)"
    if [[ -n "$PHASE" ]]; then
      if [[ -n "$NEXT" ]]; then
        PIV_SEG="PIV ${PHASE} → ${NEXT}"
      else
        PIV_SEG="PIV ${PHASE}"
      fi
    fi
  fi
fi

LINE="$MODEL_SEG"
[[ -n "$GIT_SEG" ]] && LINE="$LINE | $GIT_SEG"
[[ -n "$PIV_SEG" ]] && LINE="$LINE | $PIV_SEG"

printf '%s\n' "$LINE"
exit 0
