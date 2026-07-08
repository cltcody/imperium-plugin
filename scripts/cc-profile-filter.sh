#!/usr/bin/env bash
# cc-profile-filter.sh — apply an install profile's exclude list to an already-
# installed plugin cache copy, and regenerate its INVENTORY.md.
#
# Called by install.sh after cc-publish.sh has run a normal full install. This
# deliberately does NOT touch plugin.json/marketplace.json "name" fields (that
# rename is a cc-mirror.sh-only concept for public distribution variants) — a
# profile install stays "cc"/"imperium" so /cc:* commands keep working
# unchanged; only the shipped skill/command content shrinks.
#
# Why post-install rather than pre-install staging (as cc-mirror.sh does): the
# installed marketplace registration (~/.claude/plugins/known_marketplaces.json)
# pins to the SOURCE PATH it was first added from, and cc-publish.sh calls
# `marketplace update` (not re-`add`) on every subsequent run once a name is
# registered — so pointing the marketplace at a throwaway staged tree would
# leave future `install.sh` runs (profile or full) trying to refresh from a
# path that may no longer exist. Filtering the installed CACHE copy in place
# keeps the marketplace source pinned at the real repo (global/) always, and
# is idempotent: safe to re-run any time content or the profile definition
# changes.
#
# Usage:
#   bash scripts/cc-profile-filter.sh <profile-name>
#
# Reads scripts/mirror-profiles/<profile-name>.json's "exclude" list (the same
# schema/field cc-mirror.sh --profile consumes) from the WORKING TREE (not git
# HEAD — this runs against local, possibly-uncommitted edits, unlike the
# mirror publish gate which only ever ships committed state).

set -euo pipefail

PROFILE="${1:?usage: cc-profile-filter.sh <profile-name>}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=global/scripts/lib/cc-filter.sh
source "$SCRIPT_DIR/lib/cc-filter.sh"

PROFILE_FILE="$ROOT/scripts/mirror-profiles/$PROFILE.json"
if [[ ! -f "$PROFILE_FILE" ]]; then
  echo "Error: no profile definition at $PROFILE_FILE" >&2
  echo "Known profiles: $(cd "$ROOT/scripts/mirror-profiles" && ls -- *.json 2>/dev/null | sed 's/\.json$//' | tr '\n' ' ')" >&2
  exit 1
fi

MARKETPLACE="$(python3 -c "import json; print(json.load(open('$ROOT/.claude-plugin/marketplace.json'))['name'])")"
PLUGIN="$(python3 -c "import json; print(json.load(open('$ROOT/.claude-plugin/plugin.json'))['name'])")"
VERSION="$(python3 -c "import json; print(json.load(open('$ROOT/.claude-plugin/plugin.json'))['version'])")"
# $VERSION scopes the rm -rf targets below — an empty value would aim them at the cache root.
if [[ ! "$VERSION" =~ ^[0-9A-Za-z][0-9A-Za-z.+-]*$ ]]; then
  echo "Error: implausible plugin version '$VERSION' in plugin.json — refusing to filter." >&2
  exit 1
fi

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
TARGET="$CLAUDE_DIR/plugins/cache/$MARKETPLACE/$PLUGIN/$VERSION"

if [[ ! -d "$TARGET" ]]; then
  echo "Error: installed plugin not found at $TARGET — run cc-publish.sh (or install.sh) first." >&2
  exit 1
fi

REMOVED=0
while IFS= read -r path; do
  [[ -z "$path" ]] && continue
  # exclude entries drive rm -rf under $TARGET — refuse absolute paths and .. traversal
  case "$path" in
    /*|*..*)
      echo "Warning: profile '$PROFILE' exclude '$path' is not a safe relative path — skipping." >&2
      continue ;;
  esac
  if [[ -e "$TARGET/$path" ]]; then
    rm -rf "$TARGET/$path"
    REMOVED=$((REMOVED + 1))
  else
    echo "Warning: profile '$PROFILE' excludes '$path' but it is not present in the installed copy (already missing or stale profile entry) — skipping." >&2
  fi
done < <(cc_profile_exclude_paths < "$PROFILE_FILE")

# Regenerate INVENTORY.md against the filtered copy, so the local catalog
# documents what actually shipped (mirrors cc-mirror.sh --profile behavior).
if [[ -f "$TARGET/scripts/cc-inventory.sh" ]]; then
  bash "$TARGET/scripts/cc-inventory.sh" >/dev/null
fi

SKILL_COUNT="$(find "$TARGET/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')"
CMD_COUNT="$(find "$TARGET/commands" -mindepth 1 -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"
echo "  profile '$PROFILE' applied: $REMOVED path(s) removed — $SKILL_COUNT skills, $CMD_COUNT commands remain in $TARGET"
