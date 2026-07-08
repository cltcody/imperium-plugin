#!/usr/bin/env bash
# cc-apply.sh — Apply cc.config.json substitutions across all skills, commands, agents, and references.
# Safe to re-run: resolves current placeholder values before writing, so repeated runs are idempotent.
#
# Usage:
#   bash scripts/cc-apply.sh           # dry-run (shows what would change)
#   bash scripts/cc-apply.sh --apply   # write changes

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=global/scripts/lib/cc-filter.sh
source "$SCRIPT_DIR/lib/cc-filter.sh"
# Prefer a local, gitignored override (your real values) over the tracked template.
CONFIG="$ROOT/cc.config.json"
[[ -f "$ROOT/cc.config.local.json" ]] && CONFIG="$ROOT/cc.config.local.json"
DRY_RUN=true

if [[ "${1:-}" == "--apply" ]]; then
  DRY_RUN=false
fi

# ── Require python3 for JSON parsing ─────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
  echo "Error: python3 is required" >&2; exit 1
fi

# ── Read substitution map from config ────────────────────────────────────────
# Produces lines: PLACEHOLDER<TAB>value (see lib/cc-filter.sh).
SUBS=$(cc_build_substitution_map "$CONFIG")

if [[ -z "$SUBS" ]]; then
  echo "No substitutions found in $CONFIG"; exit 0
fi

echo "Substitution map:"
while IFS=$'\t' read -r placeholder value; do
  printf "  %-30s → %s\n" "$placeholder" "$value"
done <<< "$SUBS"
echo ""

# Skip placeholders whose value is still unfilled
has_unfilled=false
while IFS=$'\t' read -r placeholder value; do
  if [[ "$value" == \[* ]]; then
    echo "⚠️  Skipping unfilled placeholder: $placeholder = $value"
    has_unfilled=true
  fi
done <<< "$SUBS"
[[ "$has_unfilled" == "true" ]] && echo ""

# ── Find target files ─────────────────────────────────────────────────────────
TARGET_DIRS=("$ROOT/skills" "$ROOT/commands" "$ROOT/agents" "$ROOT/.claude" "$ROOT/references")
FILES=()
while IFS= read -r -d '' f; do
  FILES+=("$f")
done < <(find "${TARGET_DIRS[@]}" -type f \( -name "*.md" -o -name "*.json" -o -name "*.py" -o -name "*.css" -o -name "*.html" -o -name "*.js" -o -name "*.vue" -o -name "*.jsx" \) -print0 2>/dev/null)

echo "Scanning ${#FILES[@]} files in skills/, commands/, agents/, .claude/, references/..."
echo ""

changed=0
for file in "${FILES[@]}"; do
  # Skip files that intentionally contain literal placeholders:
  # the config, the docs that document placeholders, and the
  # setup/maintain meta-commands (their grep patterns rely on them).
  [[ "$file" == *"cc.config.json"* ]] && continue
  [[ "$file" == *"WHAT_TO_UPDATE"* ]] && continue
  [[ "$file" == *"BRAND_SETUP"* ]] && continue
  [[ "$file" == *"/commands/setup/"* ]] && continue
  [[ "$file" == *"/commands/maintain/"* ]] && continue

  original=$(cat "$file")
  # Apply the substitution map (escaping/skip-unfilled quirks live in the lib).
  updated=$(cc_substitute_tokens "$original" "$SUBS")

  if [[ "$updated" != "$original" ]]; then
    rel="${file#$ROOT/}"
    if [[ "$DRY_RUN" == "true" ]]; then
      echo "  [dry-run] would update: $rel"
    else
      printf '%s\n' "$updated" > "$file"
      echo "  updated: $rel"
    fi
    ((changed++)) || true
  fi
done

echo ""
if [[ "$DRY_RUN" == "true" ]]; then
  echo "Dry run complete. $changed file(s) would be updated."
  echo "Run with --apply to write changes: bash scripts/cc-apply.sh --apply"
else
  echo "Done. $changed file(s) updated."
fi
