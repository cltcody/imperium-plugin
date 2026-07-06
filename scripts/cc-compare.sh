#!/usr/bin/env bash
# cc-compare.sh — Compare the Command Center plugin against your CURRENT global
# (user-level) commands and skills, so you can see overlap, gaps, and duplicates.
#
# Compares:
#   cc plugin           : <repo>/global/commands + skills   (this folder)
#   your global setup   : ~/.claude/commands + ~/.claude/skills
#
# Usage: bash scripts/cc-compare.sh

set -u  # no -e/-pipefail: this is a read-only report; empty diffs are normal

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
USER_CMDS="$HOME/.claude/commands"
USER_SKILLS="$HOME/.claude/skills"

# Normalized comparison key: strip dir + .md + separators, lowercase
keyof() { echo "$1" | sed -E 's|.*/||; s|\.md$||; s|[-_.]||g' | tr 'A-Z' 'a-z'; }
# Namespaced display name relative to a base: base/sub/name.md -> sub:name
nsof()  { echo "${1#$2/}" | sed -E 's|\.md$||; s|/|:|g'; }

rule() { printf '\n\033[1m%s\033[0m\n────────────────────────────────────────────────────────────\n' "$1"; }

# Build the set of cc command keys (one per line)
CC_KEYS=$(while IFS= read -r f; do keyof "$f"; done \
          < <(find "$ROOT/commands" -name '*.md') | sort -u)
CUR_KEYS=$(while IFS= read -r f; do keyof "$f"; done \
          < <(find "$USER_CMDS" -name '*.md' 2>/dev/null) | sort -u)

rule "COMMANDS — fuzzy overlap (same base name, ignoring prefix / - / _ / .)"
comm -12 <(echo "$CC_KEYS") <(echo "$CUR_KEYS") | sed 's/^/  ~ /'

rule "COMMANDS — only in your current global (~/.claude/commands)"
while IFS= read -r f; do
  grep -qxF "$(keyof "$f")" <<<"$CC_KEYS" || echo "  /$(nsof "$f" "$USER_CMDS")"
done < <(find "$USER_CMDS" -name '*.md' 2>/dev/null | sort) | sort -u

rule "COMMANDS — only in cc plugin (/cc:*)"
while IFS= read -r f; do
  grep -qxF "$(keyof "$f")" <<<"$CUR_KEYS" || echo "  /cc:$(nsof "$f" "$ROOT/commands")"
done < <(find "$ROOT/commands" -name '*.md' | sort) | sort -u

# ── Skills ────────────────────────────────────────────────────────────────────
CC_SK=$(ls -1 "$ROOT/skills" 2>/dev/null | sort -u)
CUR_SK=$(ls -1 "$USER_SKILLS" 2>/dev/null | grep -v '\.md$' | sort -u)

rule "SKILLS — overlap (same dir name)"
comm -12 <(echo "$CC_SK") <(echo "$CUR_SK") | sed 's/^/  ~ /'

rule "SKILLS — only in your current global"
comm -13 <(echo "$CC_SK") <(echo "$CUR_SK") | sed 's/^/  /'

rule "SKILLS — only in cc plugin"
comm -23 <(echo "$CC_SK") <(echo "$CUR_SK") | sed 's/^/  /'

# ── Summary ───────────────────────────────────────────────────────────────────
rule "SUMMARY"
printf "  cc commands: %3s   your global commands: %3s   fuzzy overlap: %s\n" \
  "$(echo "$CC_KEYS" | grep -c .)" "$(echo "$CUR_KEYS" | grep -c .)" \
  "$(comm -12 <(echo "$CC_KEYS") <(echo "$CUR_KEYS") | grep -c .)"
printf "  cc skills:   %3s   your global skills:   %3s   overlap:       %s\n" \
  "$(echo "$CC_SK" | grep -c .)" "$(echo "$CUR_SK" | grep -c .)" \
  "$(comm -12 <(echo "$CC_SK") <(echo "$CUR_SK") | grep -c .)"

cat <<'EOF'

Note: command overlap is name-based and fuzzy. Two tools with different names can
still do the same job (e.g. cc's plan:feature vs your core_piv_loop:plan-feature).
Treat this as a starting map, not a final verdict.
EOF
