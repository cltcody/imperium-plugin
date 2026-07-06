#!/usr/bin/env bash
# cc-publish.sh — Publish the Command Center plugin to your global (user-scope)
# Claude Code install, so /cc:* commands and skills are available in every project.
#
# The repo (this folder) stays the single source of truth. Claude Code copies the
# plugin into ~/.claude/plugins/cache on install, so this script re-syncs that copy
# whenever you've edited the plugin. Safe to re-run any time.
#
# Usage:
#   bash scripts/cc-publish.sh                # apply config, publish, then restore source
#   bash scripts/cc-publish.sh --skip-config  # publish as-is (no cc-apply)
#   bash scripts/cc-publish.sh --keep-applied # apply + publish but leave baked values in source
#
# By default the source stays config-neutral: cc-apply bakes values, the install copies the
# baked content into the plugin cache, then the source is git-restored — so the repo never
# accumulates substituted values. (Only happens in a git repo with a clean source to begin with.)
#
# After it finishes, restart Claude Code (or run /reload-plugins) to pick up changes.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

MARKETPLACE="imperium"   # marketplace.json "name"
PLUGIN="cc"                    # plugin.json "name"
REF="${PLUGIN}@${MARKETPLACE}"

SKIP_CONFIG=false
KEEP_APPLIED=false
for arg in "$@"; do
  case "$arg" in
    --skip-config)  SKIP_CONFIG=true ;;
    --keep-applied) KEEP_APPLIED=true ;;
  esac
done

step() { printf '\n\033[1m▸ %s\033[0m\n' "$1"; }

# ── Require the claude CLI ────────────────────────────────────────────────────
if ! command -v claude &>/dev/null; then
  echo "Error: the 'claude' CLI is not on PATH." >&2
  exit 1
fi

# ── 1. Validate manifests (fail fast on schema errors) ────────────────────────
step "Validating plugin & marketplace manifests"
claude plugin validate "$ROOT" --strict

# ── Record whether the source is clean, so we can safely restore it afterward ──
IN_GIT=false
SRC_WAS_CLEAN=false
if git -C "$ROOT" rev-parse --is-inside-work-tree &>/dev/null; then
  IN_GIT=true
  [[ -z "$(cd "$ROOT" && git status --porcelain -- skills commands agents .claude references 2>/dev/null)" ]] && SRC_WAS_CLEAN=true
fi

# ── 2. Bake in config substitutions (unless skipped) ──────────────────────────
if [[ "$SKIP_CONFIG" == "false" ]]; then
  step "Applying cc.config.json substitutions"
  bash "$SCRIPT_DIR/cc-apply.sh" --apply
else
  echo "(skipping cc-apply.sh — publishing as-is)"
fi

# ── 3. Register or refresh the marketplace (user scope) ───────────────────────
step "Registering marketplace '$MARKETPLACE'"
if claude plugin marketplace list 2>/dev/null | grep -qE "(^|[^a-z-])${MARKETPLACE}[[:space:]]*$"; then
  echo "Marketplace already registered — refreshing from source"
  claude plugin marketplace update "$MARKETPLACE"
else
  echo "Adding marketplace from $ROOT"
  claude plugin marketplace add "$ROOT" --scope user
fi

# ── 4. (Re)install the plugin at user scope ───────────────────────────────────
# Uninstall first so same-version content edits are guaranteed to re-copy.
step "Installing '$REF' at user scope"
claude plugin uninstall "$REF" 2>/dev/null || true
claude plugin install "$REF" --scope user

# ── 4b. Keep the repo config-neutral: restore the source cc-apply just baked ───
# The install above copied the baked content into the plugin cache, so reverting the
# source here is safe — the live plugin keeps the substituted values; the repo does not.
if [[ "$SKIP_CONFIG" == "false" && "$KEEP_APPLIED" == "false" && "$IN_GIT" == "true" ]]; then
  step "Restoring source (keeping the repo config-neutral)"
  if [[ "$SRC_WAS_CLEAN" == "true" ]]; then
    if ( cd "$ROOT" && git restore -- skills commands agents .claude references 2>/dev/null ); then
      echo "  reverted applied substitutions — source stays token-pristine; install keeps the values"
    else
      echo "  (nothing to restore)"
    fi
  else
    echo "  ⚠ source had uncommitted changes before publish — NOT auto-restoring (your edits are safe)."
    echo "    Run 'git restore -- global/skills global/commands global/agents global/.claude global/references' to revert baked values when ready,"
    echo "    or re-run with --keep-applied to intentionally keep them."
  fi
fi

# ── 5. Confirm ────────────────────────────────────────────────────────────────
step "Installed plugins"
claude plugin list 2>/dev/null | grep -i "$PLUGIN" || claude plugin list

cat <<EOF

✅ Published $REF at user scope (available in every project).
   The installed copy has your config baked in; the repo source stays token-pristine
   (use --keep-applied to keep baked values in the source instead).
   Restart Claude Code or run /reload-plugins to load the latest.
   Then try:  /cc:setup:configure   or   /cc:maintain:audit
EOF
