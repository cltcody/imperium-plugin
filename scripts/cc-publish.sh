#!/usr/bin/env bash
# cc-publish.sh — Publish the Command Center plugin to your global (user-scope)
# Claude Code install, so /cc:* commands and skills are available in every project.
#
# The repo (this folder) stays the single source of truth. Claude Code copies the
# plugin into a VERSION-KEYED cache dir on install
# (~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/) — and a reinstall at the
# same version does NOT re-copy content (verified empirically 2026-07-08), so
# `marketplace update` + uninstall/reinstall alone would leave same-version edits
# stale. Step 4a therefore force-syncs the current version's cache dir from the
# source after install, so edits go live without a version bump. Safe to re-run
# any time.
#
# Usage:
#   bash scripts/cc-publish.sh                # bake config into a throwaway copy, publish that
#   bash scripts/cc-publish.sh --skip-config  # publish the source as-is (no cc-apply)
#   bash scripts/cc-publish.sh --keep-applied # bake cc.config INTO the source and keep it
#
# By default the TRACKED SOURCE TREE IS NEVER MODIFIED: cc-apply bakes a throwaway copy of
# global/ in a tempdir, and the install/cache-sync ships that copy — so the repo can never
# accumulate substituted values, even if this script fails or is killed mid-run. This is the
# durable fix for the recurring "source left baked" incidents (2026-07-08/09/14): there is no
# bake-then-restore window to lose, and no clean-check for a stray file to defeat.
# --keep-applied opts back into an in-place bake for anyone who wants a permanently-configured fork.
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

# ── 2. Produce the tree to publish — baked config, WITHOUT touching the source ──
# The tracked tree is a config-neutral template; only the CACHE copy should carry baked
# values. Rather than bake global/ in place and git-restore it afterward (the foot-gun that
# left the repo baked whenever a `claude plugin` call, a ^C, or a killed headless install
# interrupted the window — and that a single untracked file silently defeated), bake a
# THROWAWAY COPY. The source is never mutated: nothing to restore, no clean-check to get
# wrong, and a hard kill leaves only tmp garbage.
BAKED=""
# preserve the pending exit status: as an EXIT trap this is the last thing to run, and a
# bare `[[ … ]] &&` that short-circuits (BAKED empty on --skip-config/--keep-applied) would
# otherwise make the whole script exit non-zero.
cleanup() { local rc=$?; [[ -n "$BAKED" && -d "$BAKED" ]] && rm -rf "$BAKED"; return "$rc"; }
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Snapshot the tracked source up front (tracked files only, -uno) so the end-of-run tripwire
# can prove we never touched it. Non-empty only if the caller already had uncommitted work.
IN_GIT=false
SRC_SNAPSHOT=""
if git -C "$ROOT" rev-parse --is-inside-work-tree &>/dev/null; then
  IN_GIT=true
  SRC_SNAPSHOT="$(cd "$ROOT" && git status --porcelain -uno -- skills commands agents .claude references 2>/dev/null || true)"
fi

if [[ "$SKIP_CONFIG" == "true" ]]; then
  echo "(skipping cc-apply.sh — publishing the source as-is)"
  PUBLISH_SRC="$ROOT"
elif [[ "$KEEP_APPLIED" == "true" ]]; then
  # Opt-in: bake config INTO the tracked source and keep it (a permanently-configured fork).
  step "Applying cc.config.json substitutions IN PLACE (--keep-applied)"
  CC_PUBLISH_CONTEXT=1 bash "$SCRIPT_DIR/cc-apply.sh" --apply
  PUBLISH_SRC="$ROOT"
else
  # Default: bake a throwaway copy of global/; the tracked source is never touched.
  step "Baking config into a throwaway copy (source stays token-pristine)"
  BAKED="$(mktemp -d "${TMPDIR:-/tmp}/cc-publish.XXXXXX")"
  if command -v rsync &>/dev/null; then
    rsync -a --exclude '.git' "$ROOT/" "$BAKED/"
  else
    cp -R "$ROOT/." "$BAKED/"; rm -rf "$BAKED/.git"
  fi
  # cc-apply self-roots via BASH_SOURCE, so the copy's own script bakes the COPY (reading the
  # copy's cc.config[.local].json, carried by the rsync). CC_PUBLISH_CONTEXT sanctions --apply.
  CC_PUBLISH_CONTEXT=1 bash "$BAKED/scripts/cc-apply.sh" --apply
  PUBLISH_SRC="$BAKED"
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

# ── 4a. Force-sync the version-keyed cache copy from the baked tree ────────────
# `plugin install` does not re-copy content into an existing <version> cache dir, so a
# same-version publish would silently leave the live copy stale. Mirror the baked tree
# ($PUBLISH_SRC — the throwaway copy by default) over it directly, preserving Claude Code's
# own `.in_use` marker. Direct cache manipulation is an established seam here —
# cc-profile-filter.sh already edits this dir in place.
step "Force-syncing the cache copy (same-version edits go live)"
if command -v python3 &>/dev/null; then
  VERSION="$(python3 -c "import json; print(json.load(open('$ROOT/.claude-plugin/plugin.json'))['version'])")"
  # $VERSION names the rsync --delete / rm -rf target below — an empty or malformed value
  # would aim the delete at the cache ROOT (every installed version). Refuse, don't guess.
  if [[ ! "$VERSION" =~ ^[0-9A-Za-z][0-9A-Za-z.+-]*$ ]]; then
    echo "  ⚠ implausible plugin version '$VERSION' in plugin.json — refusing cache sync" >&2
    exit 1
  fi
  CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  CACHE="$CLAUDE_DIR/plugins/cache/$MARKETPLACE/$PLUGIN/$VERSION"
  if [[ -d "$CACHE" ]]; then
    if command -v rsync &>/dev/null; then
      rsync -a --delete --exclude '.in_use' "$PUBLISH_SRC/" "$CACHE/"
    else
      find "$CACHE" -mindepth 1 -maxdepth 1 ! -name '.in_use' -exec rm -rf {} +
      cp -R "$PUBLISH_SRC/." "$CACHE/"
    fi
    echo "  synced $PUBLISH_SRC -> $CACHE"
  else
    echo "  (no cache dir at $CACHE — nothing to sync)"
  fi
else
  echo "  ⚠ python3 not found — cannot resolve the plugin version; cache copy may be stale at the same version"
fi

# ── 4b. Tripwire — prove the tracked source was never touched (defense in depth) ──
# In the default/--skip path we publish a copy, so the tracked tree must be byte-identical to
# how we found it. If some future change ever reintroduces an in-place mutation, fail LOUD
# here instead of silently leaving the repo baked. Compared against the up-front snapshot, so
# a caller's PRE-existing uncommitted work is fine — only a change WE caused trips it.
if [[ "$KEEP_APPLIED" == "false" && "$IN_GIT" == "true" ]]; then
  SRC_NOW="$(cd "$ROOT" && git status --porcelain -uno -- skills commands agents .claude references 2>/dev/null || true)"
  if [[ "$SRC_NOW" != "$SRC_SNAPSHOT" ]]; then
    echo "" >&2
    echo "❌ cc-publish BUG: the tracked source tree changed during publish — it must not." >&2
    echo "   Inspect: git -C \"$ROOT\" status -- skills commands agents .claude references" >&2
    echo "   Revert:  git -C \"$ROOT\" restore -- skills commands agents .claude references" >&2
    exit 1
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
