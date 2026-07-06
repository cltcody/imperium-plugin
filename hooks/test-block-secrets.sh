#!/usr/bin/env bash
# test-block-secrets.sh — fixture harness for hooks/block-secrets.py.
#
# Pipes small JSON PreToolUse fixtures into the hook and asserts the exit
# code matches what's expected (0 = allow, 2 = block). Run directly:
#   bash global/hooks/test-block-secrets.sh
#
# Every case here maps to one of the Phase 1.5 hardening changes:
#   (a) secrets.yaml/.yml/.toml no longer allowlisted
#   (b) awk/sed/sort/cut/dd/tr/mv readers of sensitive files now caught
#   (c) heredoc / xargs-cat blocks now require an actual sensitive reference
# plus a handful of baseline regression checks so we don't silently widen
# the allowlist while fixing the false-positive/gap issues.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/block-secrets.py"

pass=0
fail=0
declare -a results=()

# run_case NAME EXPECTED_EXIT JSON
run_case() {
  local name="$1" expected="$2" json="$3"
  local actual
  echo "$json" | python3 "$HOOK" >/tmp/block-secrets-test-out.txt 2>&1
  actual=$?
  if [[ "$actual" == "$expected" ]]; then
    results+=("PASS|$name|expected=$expected|actual=$actual")
    pass=$((pass + 1))
  else
    results+=("FAIL|$name|expected=$expected|actual=$actual")
    fail=$((fail + 1))
  fi
}

json_read() {
  # json_read PATH
  printf '{"tool_name":"Read","tool_input":{"file_path":%s}}' "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$1")"
}

json_bash() {
  # json_bash COMMAND
  printf '{"tool_name":"Bash","tool_input":{"command":%s}}' "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$1")"
}

# --- (a) SECRET_FALSE_POSITIVES: .yml/.yaml/.toml no longer allowlisted ---
run_case "read k8s secrets.yaml -> block" 2 "$(json_read "k8s/secrets.yaml")"
run_case "read secrets.yml -> block" 2 "$(json_read "config/secrets.yml")"
run_case "read app_secrets.toml -> block" 2 "$(json_read "app_secrets.toml")"
run_case "read normal README.md -> allow" 0 "$(json_read "README.md")"
run_case "read .env -> block (baseline)" 2 "$(json_read ".env")"
run_case "read .env.example -> allow (baseline)" 0 "$(json_read ".env.example")"

# --- (b) generic readers/movers of sensitive files ---
run_case "awk on .env -> block" 2 "$(json_bash "awk '{print}' .env")"
run_case "awk on normal file -> allow" 0 "$(json_bash "awk '{print \$1}' access.log")"
run_case "sed -n on .env -> block" 2 "$(json_bash "sed -n '1,5p' .env")"
run_case "sed -n on normal file -> allow" 0 "$(json_bash "sed -n '1,5p' README.md")"
run_case "sort .env -> block" 2 "$(json_bash "sort .env")"
run_case "cut on credentials.json -> block" 2 "$(json_bash "cut -d: -f1 credentials.json")"
run_case "cut on normal csv -> allow" 0 "$(json_bash "cut -d, -f1 data.csv")"
run_case "dd if=.env -> block" 2 "$(json_bash "dd if=.env of=/tmp/out bs=1")"
run_case "tr < .env -> block" 2 "$(json_bash "tr -d '\\r' < .env")"
run_case "tr < normal file -> allow" 0 "$(json_bash "tr -d '\\r' < README.md")"
run_case "mv .env elsewhere -> block" 2 "$(json_bash "mv .env /tmp/backup")"
run_case "mv normal file -> allow" 0 "$(json_bash "mv README.md README.old.md")"
run_case "cp credentials.json -> block (broadened)" 2 "$(json_bash "cp credentials.json /tmp/backup.json")"
run_case "cp normal file -> allow" 0 "$(json_bash "cp package.json /tmp/backup.json")"

# --- (c) heredoc block now scoped to actual sensitive references ---
run_case "cc-apply.sh's own python3 - <<'PYEOF' heredoc -> allow" 0 "$(json_bash 'SUBS=$(python3 - "$CONFIG" <<'"'"'PYEOF'"'"'
import json, sys
with open(sys.argv[1]) as f:
    cfg = json.load(f)
print(cfg)
PYEOF
)')"
run_case "benign python heredoc, no sensitive content -> allow" 0 "$(json_bash "python3 - <<'PYEOF'
import json
print(json.dumps({'ok': True}))
PYEOF")"
run_case "python heredoc dumping os.environ -> block" 2 "$(json_bash "python3 <<'PYEOF'
import os
print(os.environ)
PYEOF")"
run_case "python heredoc referencing .env -> block" 2 "$(json_bash "python3 <<'PYEOF'
print(open('.env').read())
PYEOF")"

# --- (c) xargs-cat block now requires a sensitive-path operand ---
run_case "find .env piped to xargs cat -> block" 2 "$(json_bash "find . -name '.env' | xargs cat")"
run_case "find *.log piped to xargs cat -> allow (relaxed)" 0 "$(json_bash "find . -name '*.log' | xargs cat")"

# --- baseline regressions: pre-existing protections still work ---
run_case "cat .env -> block (baseline)" 2 "$(json_bash "cat .env")"
run_case "printenv -> block (baseline)" 2 "$(json_bash "printenv")"
run_case "python -c os.environ -> block (baseline)" 2 "$(json_bash "python3 -c 'import os; print(os.environ)'")"
run_case "cat README.md -> allow (baseline sanity)" 0 "$(json_bash "cat README.md")"
run_case "ls -la -> allow (baseline sanity)" 0 "$(json_bash "ls -la")"

echo ""
echo "=== block-secrets.py test results ==="
printf "%-6s | %-55s | %s\n" "RESULT" "CASE" "EXPECTED/ACTUAL"
printf -- "-------|--------------------------------------------------------|-----------------\n"
for r in "${results[@]}"; do
  IFS='|' read -r status name info <<< "$r"
  printf "%-6s | %-55s | %s\n" "$status" "$name" "$info"
done
echo ""
echo "Passed: $pass  Failed: $fail  Total: $((pass + fail))"

rm -f /tmp/block-secrets-test-out.txt

if [[ "$fail" -gt 0 ]]; then
  exit 1
fi
exit 0
