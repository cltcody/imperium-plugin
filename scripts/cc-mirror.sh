#!/usr/bin/env bash
# cc-mirror.sh — publish the plugin (global/ subtree) as the ROOT of a public
# mirror repo, so strangers can install with:
#   /plugin marketplace add <owner>/<mirror-repo>
#   /plugin install cc@imperium
#
# The imperium repo itself stays private (it carries work-local content the
# plugin must never ship).
#
# Publish model: SNAPSHOT COMMITS, never history. Each release pushes one new
# commit whose tree is exactly HEAD:global — imperium's commit history (which
# was never vetted for public release and has contained secrets) does not
# ship. The mirror's log is one commit per release.
#
# Usage:
#   bash global/scripts/cc-mirror.sh [--profile <name>] [--dry-run] <mirror-remote-url> [branch]
#   bash global/scripts/cc-mirror.sh https://github.com/cltcody/imperium-plugin.git
#   bash global/scripts/cc-mirror.sh --profile business https://github.com/cltcody/imperium-plugin-business.git
#
# Profiles (scripts/mirror-profiles/<name>.json) publish a FILTERED variant of
# the plugin: the listed skill/command paths are dropped from the snapshot tree
# and the plugin/marketplace manifests are renamed, so a distinct audience
# (e.g. business users on claude.ai chat / Cowork, where only skills/ surface)
# installs a curated catalog instead of the full dev+sales+life set.
# --dry-run runs every gate and builds the tree, prints what would ship, and
# exits before contacting the remote.
#
# Pre-flight gates (any failure aborts the push):
#   1. clean working tree (mirror only ever publishes committed state)
#   2. cc-audit green
#   3. claude plugin validate --strict green
#   4. leak scans on the shipped tree: structure, brand terms, secrets

set -euo pipefail

PROFILE=""
DRY_RUN=false
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) PROFILE="${2:?--profile requires a name}"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --*) echo "Error: unknown flag $1" >&2; exit 1 ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done
REMOTE="${POSITIONAL[0]:?usage: cc-mirror.sh [--profile <name>] [--dry-run] <mirror-remote-url> [branch]}"
BRANCH="${POSITIONAL[1]:-main}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=global/scripts/lib/cc-filter.sh
source "$SCRIPT_DIR/lib/cc-filter.sh"
cd "$REPO_ROOT"

step() { printf '\n\033[1m▸ %s\033[0m\n' "$1"; }

# ── 1. Clean tree ─────────────────────────────────────────────────────────────
step "Checking working tree"
if [[ -n "$(git status --porcelain -- global/)" ]]; then
  echo "Error: uncommitted changes under global/ — commit first, the mirror publishes HEAD." >&2
  exit 1
fi

# ── 2. Audit gate ─────────────────────────────────────────────────────────────
step "Running cc-audit"
bash global/scripts/cc-audit.sh

# ── 3. Manifest validation ────────────────────────────────────────────────────
step "Validating plugin manifests (--strict)"
if command -v claude &>/dev/null; then
  claude plugin validate global --strict
else
  echo "Warning: claude CLI not on PATH — skipping manifest validation." >&2
fi

# ── 4. Build the shipped tree ─────────────────────────────────────────────────
# Default: exactly HEAD:global. With --profile: HEAD:global minus the profile's
# excluded paths, with plugin.json/marketplace.json renamed for the variant.
TREE="$(git rev-parse "HEAD:global")"

if [[ -n "$PROFILE" ]]; then
  PROFILE_FILE="global/scripts/mirror-profiles/$PROFILE.json"
  # Profile is read from HEAD, not the working tree — same rule as the content.
  if ! git cat-file -e "HEAD:$PROFILE_FILE" 2>/dev/null; then
    echo "Error: profile not found at $PROFILE_FILE (must be committed)." >&2
    exit 1
  fi

  step "Applying profile: $PROFILE"
  TMPIDX="$(mktemp -u)"
  trap 'rm -f "$TMPIDX"' EXIT
  GIT_INDEX_FILE="$TMPIDX" git read-tree "$TREE"

  # Drop excluded paths. Every entry must match something — a stale entry means
  # the profile has drifted from the tree, which should fail loudly, not ship.
  while IFS= read -r path; do
    if ! GIT_INDEX_FILE="$TMPIDX" git ls-files --error-unmatch -- "$path" >/dev/null 2>&1; then
      echo "Error: profile excludes '$path' but the tree has no such path — fix $PROFILE_FILE." >&2
      exit 1
    fi
    GIT_INDEX_FILE="$TMPIDX" git ls-files -z -- "$path" \
      | GIT_INDEX_FILE="$TMPIDX" git update-index -z --force-remove --stdin
  done < <(git cat-file blob "HEAD:$PROFILE_FILE" | cc_profile_exclude_paths)

  # Rewrite the manifests so the variant installs under its own name.
  for MF in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
    NEW_BLOB="$(
      { git cat-file blob "$TREE:$MF"; printf '\f'; git cat-file blob "HEAD:$PROFILE_FILE"; } \
      | python3 -c '
import json, sys
manifest_raw, profile_raw = sys.stdin.read().split("\f")
m, p = json.loads(manifest_raw), json.loads(profile_raw)
if "plugins" in m:  # marketplace.json
    m["name"] = p["marketplaceName"]
    m["description"] = p["marketplaceDescription"]
    m["plugins"][0]["name"] = p["pluginName"]
    m["plugins"][0]["description"] = p["pluginDescription"]
    if "tags" in p: m["plugins"][0]["tags"] = p["tags"]
else:               # plugin.json
    m["name"] = p["pluginName"]
    m["description"] = p["pluginDescription"]
print(json.dumps(m, indent=2, ensure_ascii=False))
' | git hash-object -w --stdin
    )"
    GIT_INDEX_FILE="$TMPIDX" git update-index --cacheinfo "100644,$NEW_BLOB,$MF"
  done

  TREE="$(GIT_INDEX_FILE="$TMPIDX" git write-tree)"

  # Regenerate INVENTORY.md against the filtered tree, so the variant's catalog
  # documents what it actually ships (cc-inventory.sh reads the filesystem, so
  # excluded skills/commands drop out of the generated tables).
  TMPTREE="$(mktemp -d)"
  trap 'rm -f "$TMPIDX"; rm -rf "$TMPTREE"' EXIT
  git archive "$TREE" | tar -x -C "$TMPTREE"
  bash "$TMPTREE/scripts/cc-inventory.sh" >/dev/null
  INV_BLOB="$(git hash-object -w "$TMPTREE/INVENTORY.md")"
  GIT_INDEX_FILE="$TMPIDX" git update-index --cacheinfo "100644,$INV_BLOB,INVENTORY.md"
  TREE="$(GIT_INDEX_FILE="$TMPIDX" git write-tree)"

  # Profile overrides: any file under mirror-profiles/<name>/ replaces the same
  # path in the shipped tree root (e.g. a variant-specific README.md). Applied
  # last, so an override wins over generated content too.
  OVERRIDE_DIR="scripts/mirror-profiles/$PROFILE"
  if git cat-file -e "HEAD:global/$OVERRIDE_DIR" 2>/dev/null; then
    while IFS= read -r rel; do
      OV_BLOB="$(git rev-parse "HEAD:global/$OVERRIDE_DIR/$rel")"
      GIT_INDEX_FILE="$TMPIDX" git update-index --add --cacheinfo "100644,$OV_BLOB,$rel"
      echo "  override: $rel"
    done < <(git ls-tree -r --name-only "HEAD:global/$OVERRIDE_DIR")
    TREE="$(GIT_INDEX_FILE="$TMPIDX" git write-tree)"
  fi

  SKILL_COUNT="$(git ls-tree --name-only "$TREE:skills" | wc -l | tr -d ' ')"
  echo "  filtered tree: $TREE ($SKILL_COUNT skills shipped, INVENTORY regenerated)"
fi

# ── 5. Leak-scan the shipped tree ─────────────────────────────────────────────
step "Leak-scanning the shipped tree ($TREE)"

# Structural: nothing outside the plugin should exist in the tree (top-level
# anchors — plugin references may legitimately mention these names in filenames)
if git ls-tree -r --name-only "$TREE" | grep -qiE "^gtm-local/|^docs/|^evals/|^install\.sh$"; then
  echo "Error: shipped tree contains non-plugin paths — aborting." >&2
  exit 1
fi

# Brand/work terms must not appear anywhere in the shipped tree.
# Scanners are exempt from their own patterns: maintain/audit.md and this
# script both carry the terms as grep patterns, not as content.
LEAKS="$(git grep -il -e wisetech -e cargowise -e easyclass -e docai -e graphik "$TREE" -- \
  | grep -vE "supply-chain-map|BRAND_SETUP|WHAT_TO_UPDATE|cc.config|commands/maintain/audit|scripts/cc-mirror" || true)"
if [[ -n "$LEAKS" ]]; then
  echo "Error: brand/work terms found in shipped tree:" >&2
  echo "$LEAKS" >&2
  exit 1
fi

# Secrets: digit-anchored patterns so docs placeholders (xoxb-your-bot-token,
# T00000000/...) don't false-positive, but real credentials do. GitHub push
# protection is the backstop; this gate catches it before anything leaves.
SECRET_PATTERNS=(
  -e 'hooks\.slack\.com/services/T[A-Z0-9]{5,}/B[A-Z0-9]{5,}/[A-Za-z0-9]{16,}'
  -e 'xox[baprs]-[0-9]{8,}-'
  -e 'AKIA[0-9A-Z]{16}'
  -e 'ghp_[A-Za-z0-9]{30,}'
  -e 'github_pat_[A-Za-z0-9_]{30,}'
  -e 'sk-ant-[A-Za-z0-9-]{30,}'
  -e '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY'
)
SECRETS="$(git grep -lE "${SECRET_PATTERNS[@]}" "$TREE" -- | grep -v "scripts/cc-mirror" || true)"
if [[ -n "$SECRETS" ]]; then
  echo "Error: secret-shaped content found in shipped tree:" >&2
  echo "$SECRETS" >&2
  echo "Remove the credential (use an env var), rotate it, then re-run." >&2
  exit 1
fi
echo "  clean (structure, brand terms, secrets)."

# ── 6. Snapshot commit and push ───────────────────────────────────────────────
# Name/version come from the tree being shipped, so profile renames carry through.
PLUGIN_NAME="$(git cat-file blob "$TREE:.claude-plugin/plugin.json" | python3 -c "import json,sys; print(json.load(sys.stdin)['name'])")"
MARKETPLACE_NAME="$(git cat-file blob "$TREE:.claude-plugin/marketplace.json" | python3 -c "import json,sys; print(json.load(sys.stdin)['name'])")"
VERSION="$(git cat-file blob "$TREE:.claude-plugin/plugin.json" | python3 -c "import json,sys; print(json.load(sys.stdin)['version'])")"

if $DRY_RUN; then
  step "Dry run — tree that would ship ($PLUGIN_NAME $VERSION)"
  echo "  skills:   $(git ls-tree --name-only "$TREE:skills" 2>/dev/null | wc -l | tr -d ' ')"
  echo "  commands: $(git ls-tree -r --name-only "$TREE:commands" 2>/dev/null | wc -l | tr -d ' ')"
  git ls-tree --name-only "$TREE:skills" 2>/dev/null | sed 's/^/    skill: /'
  echo "Dry run complete — nothing pushed."
  exit 0
fi

step "Building snapshot commit ($PLUGIN_NAME $VERSION)"
# Parent = the mirror's current branch head, so releases chain into a clean
# one-commit-per-release history. First publish has no parent.
PARENT="$(git ls-remote "$REMOTE" "refs/heads/$BRANCH" | cut -f1 || true)"
MSG="$PLUGIN_NAME $VERSION — mirror snapshot of imperium global/ @ $(git rev-parse --short HEAD)${PROFILE:+ (profile: $PROFILE)}"
if [[ -n "$PARENT" ]]; then
  git fetch -q "$REMOTE" "refs/heads/$BRANCH"
  if [[ "$(git rev-parse "$PARENT^{tree}")" == "$TREE" ]]; then
    echo "Mirror already up to date (tree unchanged) — nothing to push."
    exit 0
  fi
  SNAP="$(git commit-tree "$TREE" -p "$PARENT" -m "$MSG")"
else
  SNAP="$(git commit-tree "$TREE" -m "$MSG")"
fi
echo "  snapshot commit: $SNAP"

step "Pushing to mirror: $REMOTE ($BRANCH)"
git push "$REMOTE" "$SNAP:refs/heads/$BRANCH"

cat <<EOF

✅ Mirror published — $PLUGIN_NAME version $VERSION at $REMOTE ($BRANCH).

   Reminder: marketplace installs only update when plugin.json "version" is
   bumped. If this publish carries user-facing changes, confirm the version
   changed since the last mirror push.

   Consumers install with:
     /plugin marketplace add <owner>/<mirror-repo>
     /plugin install $PLUGIN_NAME@$MARKETPLACE_NAME
EOF
