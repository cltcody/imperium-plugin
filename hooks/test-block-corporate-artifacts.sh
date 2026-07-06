#!/usr/bin/env bash
# test-block-corporate-artifacts.sh — fixture harness for
# hooks/block-corporate-artifacts.py.
#
# Same run_case NAME EXPECTED_EXIT JSON pattern as test-block-secrets.sh, but
# using temp-dir fixture repos (a real `.git` entry + an optional STACK.md
# with a `class:` frontmatter field) since this hook's deny decision depends
# on the repo the target path lives under, not just the path text. Run
# directly:
#   bash global/hooks/test-block-corporate-artifacts.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/block-corporate-artifacts.py"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0
declare -a results=()

# run_case NAME EXPECTED_EXIT JSON
run_case() {
  local name="$1" expected="$2" json="$3"
  local actual
  echo "$json" | python3 "$HOOK" >/tmp/block-corporate-artifacts-test-out.txt 2>&1
  actual=$?
  if [[ "$actual" == "$expected" ]]; then
    results+=("PASS|$name|expected=$expected|actual=$actual")
    pass=$((pass + 1))
  else
    results+=("FAIL|$name|expected=$expected|actual=$actual")
    fail=$((fail + 1))
  fi
}

json_write() {
  # json_write PATH
  printf '{"tool_name":"Write","tool_input":{"file_path":%s,"content":"x"}}' \
    "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$1")"
}

json_edit() {
  # json_edit PATH
  printf '{"tool_name":"Edit","tool_input":{"file_path":%s,"old_string":"a","new_string":"b"}}' \
    "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$1")"
}

# --- fixture repos ---

# corporate: a normal repo (.git dir) with STACK.md class: corporate
CORP="$TMP/corp-repo"
mkdir -p "$CORP/.git" "$CORP/accounts" "$CORP/src/accounts_ui" "$CORP/radar"
cat > "$CORP/STACK.md" <<'EOF'
---
stack: python
class: corporate
components:
  - name: api
---
# Corp Repo
EOF

# personal: a normal repo with STACK.md class: personal
PERSONAL="$TMP/personal-repo"
mkdir -p "$PERSONAL/.git" "$PERSONAL/accounts"
cat > "$PERSONAL/STACK.md" <<'EOF'
---
stack: node
class: personal
---
# Personal Repo
EOF

# shared-oss: a normal repo with STACK.md class: shared-oss
SHARED="$TMP/shared-oss-repo"
mkdir -p "$SHARED/.git" "$SHARED/deals"
cat > "$SHARED/STACK.md" <<'EOF'
---
stack: python
class: shared-oss
---
EOF

# no-stack: a repo with .git but no STACK.md at all
NOSTACK="$TMP/no-stack-repo"
mkdir -p "$NOSTACK/.git" "$NOSTACK/accounts"

# no-repo: a plain directory tree with NO .git anywhere above it inside $TMP
# (the walk stops at the filesystem root without finding one — this is
# inherently best-effort in a test sandbox since a real .git may exist above
# $TMP; we assert only that the hook does not crash and denies nothing when
# no corporate STACK.md is discoverable).
NOREPO="$TMP/no-repo-standalone/accounts"
mkdir -p "$NOREPO"

# deals-workspace-shaped: a repo whose tree mirrors the deals workspace
# layout (accounts/, deals/, radar/) but carries NO class field at all —
# this is the fixture that proves the hook never blocks the workspace itself.
WORKSPACE="$TMP/deals-workspace-shaped"
mkdir -p "$WORKSPACE/.git" "$WORKSPACE/deals" "$WORKSPACE/radar"
cat > "$WORKSPACE/STACK.md" <<'EOF'
---
stack: none
---
EOF

# worktree-style corporate repo: `.git` is a FILE (as git worktrees use),
# not a directory, and must still be discovered by the repo-root walk.
WORKTREE="$TMP/worktree-corp-repo"
mkdir -p "$WORKTREE/accounts"
printf 'gitdir: /tmp/somewhere/.git/worktrees/wt\n' > "$WORKTREE/.git"
cat > "$WORKTREE/STACK.md" <<'EOF'
---
stack: python
class: corporate
---
EOF

# preamble-before-frontmatter: STACK.md has a title/preamble line BEFORE the
# `---`-delimited frontmatter block. read_class() must be tolerant (scan for the
# first `---` block ANYWHERE, not anchored to byte 0) — a corporate-artifact
# guardrail's parsing fails toward protection. (Finding #1)
PREAMBLE="$TMP/preamble-corp-repo"
mkdir -p "$PREAMBLE/.git" "$PREAMBLE/accounts"
cat > "$PREAMBLE/STACK.md" <<'EOF'
# Project Notes

Some preamble text before the frontmatter block.

---
stack: python
class: corporate
---
EOF

# nested classless repo inside a corporate repo: the OUTER repo root has a
# STACK.md declaring class: corporate; a NESTED `.git` further down (vendored
# dependency, forgotten `git init`, unregistered submodule) has no STACK.md of
# its own. The write lands under the nested root, but the outer corporate
# classification must not be shadowed by it. (Finding #2)
NESTED_OUTER="$TMP/nested-outer-corp"
mkdir -p "$NESTED_OUTER/.git"
cat > "$NESTED_OUTER/STACK.md" <<'EOF'
---
stack: python
class: corporate
---
EOF
mkdir -p "$NESTED_OUTER/vendor/lib/.git" "$NESTED_OUTER/vendor/lib/accounts"

# standalone workspace nested under a NON-corporate ancestor: proves walking
# every ancestor repo root doesn't introduce a false block — a classless
# deals-workspace-shaped repo nested under a personal-classed outer repo still
# allows. (Finding #2, false-positive direction)
NESTED_WS_OUTER="$TMP/nested-outer-personal"
mkdir -p "$NESTED_WS_OUTER/.git"
cat > "$NESTED_WS_OUTER/STACK.md" <<'EOF'
---
stack: none
class: personal
---
EOF
mkdir -p "$NESTED_WS_OUTER/deals-workspace/.git" "$NESTED_WS_OUTER/deals-workspace/deals"

# case/quote fragility: `class: Corporate` (capitalized) and `class: "corporate"`
# (quoted) must trigger the same deny as the plain lowercase literal. (Finding #3)
CORP_MIXED_CASE="$TMP/corp-repo-mixed-case"
mkdir -p "$CORP_MIXED_CASE/.git" "$CORP_MIXED_CASE/accounts"
cat > "$CORP_MIXED_CASE/STACK.md" <<'EOF'
---
stack: python
class: Corporate
---
EOF

CORP_QUOTED="$TMP/corp-repo-quoted"
mkdir -p "$CORP_QUOTED/.git" "$CORP_QUOTED/accounts"
cat > "$CORP_QUOTED/STACK.md" <<'EOF'
---
stack: python
class: "corporate"
---
EOF

# --- (1) minimum spec cases ---

run_case "corporate + accounts/ write -> block" 2 \
  "$(json_write "$CORP/accounts/brief.md")"

run_case "personal + accounts/ write -> allow" 0 \
  "$(json_write "$PERSONAL/accounts/brief.md")"

run_case "corporate + src/accounts_ui/ write -> allow (not segment-anchored)" 0 \
  "$(json_write "$CORP/src/accounts_ui/component.tsx")"

run_case "no STACK.md -> allow" 0 \
  "$(json_write "$NOSTACK/accounts/brief.md")"

run_case "malformed stdin -> allow" 0 \
  '{not valid json'

run_case "deals-workspace-shaped (no class) + deals/ write -> allow" 0 \
  "$(json_write "$WORKSPACE/deals/proposal-acme.md")"

# --- (2) additional coverage ---

run_case "corporate + deals/ write -> block" 2 \
  "$(json_write "$CORP/deals/proposal-acme.md")"

run_case "corporate + radar/ write -> block" 2 \
  "$(json_write "$CORP/radar/state.json")"

run_case "corporate + accounts/ Edit -> block (Edit tool, not just Write)" 2 \
  "$(json_edit "$CORP/accounts/brief.md")"

run_case "shared-oss + deals/ write -> allow (only literal 'corporate' triggers)" 0 \
  "$(json_write "$SHARED/deals/proposal-acme.md")"

run_case "corporate + non-artifact path (README.md) -> allow" 0 \
  "$(json_write "$CORP/README.md")"

run_case "corporate worktree (.git is a file) + accounts/ write -> block" 2 \
  "$(json_write "$WORKTREE/accounts/brief.md")"

run_case "no .git anywhere -> allow (fails open, no repo found)" 0 \
  "$(json_write "$NOREPO/brief.md")"

run_case "absent file_path -> allow" 0 \
  '{"tool_name":"Write","tool_input":{}}'

run_case "unrelated tool_name (Read) -> allow (hook only guards Write/Edit)" 0 \
  "$(printf '{"tool_name":"Read","tool_input":{"file_path":%s}}' "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$CORP/accounts/brief.md")")"

run_case "webpack radar.config.js in corporate repo -> allow (segment-anchored)" 0 \
  "$(json_write "$CORP/webpack/radar.config.js")"

# --- (3) tolerant-frontmatter / nested-.git / case-quoting regressions ---

run_case "preamble before frontmatter, corporate + accounts/ write -> block (tolerant scan)" 2 \
  "$(json_write "$PREAMBLE/accounts/brief.md")"

run_case "nested classless .git inside corporate repo -> block (outer class not shadowed)" 2 \
  "$(json_write "$NESTED_OUTER/vendor/lib/accounts/notes.md")"

run_case "classless workspace nested under non-corporate parent -> allow" 0 \
  "$(json_write "$NESTED_WS_OUTER/deals-workspace/deals/proposal.md")"

run_case "class: Corporate (capitalized) + accounts/ write -> block (case-insensitive)" 2 \
  "$(json_write "$CORP_MIXED_CASE/accounts/brief.md")"

run_case "class: \"corporate\" (quoted) + accounts/ write -> block (quote-insensitive)" 2 \
  "$(json_write "$CORP_QUOTED/accounts/brief.md")"

# relative file_path: must resolve via os.path.abspath against the HOOK's
# own cwd (not the harness's) — invoke with the hook's cwd actually set to
# the corporate fixture, unlike the other cases which pass absolute paths.
name="corporate + relative accounts path resolved via hook's cwd -> block"
actual="$(cd "$CORP" && echo '{"tool_name":"Write","tool_input":{"file_path":"accounts/relative-brief.md","content":"x"}}' | python3 "$HOOK" >/tmp/block-corporate-artifacts-test-out.txt 2>&1; echo $?)"
if [[ "$actual" == "2" ]]; then
  results+=("PASS|$name|expected=2|actual=$actual")
  pass=$((pass + 1))
else
  results+=("FAIL|$name|expected=2|actual=$actual")
  fail=$((fail + 1))
fi


# --- (4) R1/R2 fix-round-2 regression cases ---

# R1: closing --- at EOF (no trailing newline) — awk counts it; python must too.
CORP_EOF="$TMP/corp-eof"; mkdir -p "$CORP_EOF/accounts"; git init -q "$CORP_EOF"
printf -- '---\nclass: corporate\n---' > "$CORP_EOF/STACK.md"
run_case "R1: closing --- at EOF (no newline) corporate -> block" 2 \
  "$(json_write "$CORP_EOF/accounts/brief.md")"

# R1: unclosed frontmatter running to EOF — awk treats as frontmatter; python must too.
CORP_UNCLOSED="$TMP/corp-unclosed"; mkdir -p "$CORP_UNCLOSED/deals"; git init -q "$CORP_UNCLOSED"
printf -- '---\nclass: corporate\nstack: node\n' > "$CORP_UNCLOSED/STACK.md"
run_case "R1: unclosed frontmatter to EOF corporate -> block" 2 \
  "$(json_write "$CORP_UNCLOSED/deals/x.md")"

# R2: symlink INSIDE a corporate repo pointing OUTSIDE it — realpath resolves out; allow.
OUTSIDE="$TMP/outside-plain"; mkdir -p "$OUTSIDE/accounts"
ln -s "$OUTSIDE/accounts" "$CORP/accounts-link" 2>/dev/null || true
if [[ -L "$CORP/accounts-link" ]]; then
  run_case "R2: symlink in corporate repo -> outside target -> allow" 0 \
    "$(json_write "$CORP/accounts-link/note.md")"
fi

# R2 inverse: symlink OUTSIDE pointing INTO the corporate tree — still denied.
ln -s "$CORP/accounts" "$TMP/into-corp-link" 2>/dev/null || true
if [[ -L "$TMP/into-corp-link" ]]; then
  run_case "R2: symlink into corporate tree -> block" 2 \
    "$(json_write "$TMP/into-corp-link/brief.md")"
fi

echo ""
echo "=== block-corporate-artifacts.py test results ==="
printf "%-6s | %-70s | %s\n" "RESULT" "CASE" "EXPECTED/ACTUAL"
printf -- "-------|----------------------------------------------------------------------|-----------------\n"
for r in "${results[@]}"; do
  IFS='|' read -r status name info <<< "$r"
  printf "%-6s | %-70s | %s\n" "$status" "$name" "$info"
done
echo ""
echo "Passed: $pass  Failed: $fail  Total: $((pass + fail))"

rm -f /tmp/block-corporate-artifacts-test-out.txt

if [[ "$fail" -gt 0 ]]; then
  exit 1
fi
exit 0
