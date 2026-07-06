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
#   bash global/scripts/cc-mirror.sh <mirror-remote-url> [branch]
#   bash global/scripts/cc-mirror.sh https://github.com/cltcody/imperium-plugin.git
#
# Pre-flight gates (any failure aborts the push):
#   1. clean working tree (mirror only ever publishes committed state)
#   2. cc-audit green
#   3. claude plugin validate --strict green
#   4. leak scans on the shipped tree: structure, brand terms, secrets

set -euo pipefail

REMOTE="${1:?usage: cc-mirror.sh <mirror-remote-url> [branch]}"
BRANCH="${2:-main}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
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

# ── 4. Leak-scan the shipped tree ─────────────────────────────────────────────
# The shipped tree is HEAD:global — exactly what the snapshot commit will carry.
TREE="$(git rev-parse "HEAD:global")"

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

# ── 5. Snapshot commit and push ───────────────────────────────────────────────
VERSION="$(python3 -c "import json; print(json.load(open('global/.claude-plugin/plugin.json'))['version'])")"

step "Building snapshot commit (cc $VERSION)"
# Parent = the mirror's current branch head, so releases chain into a clean
# one-commit-per-release history. First publish has no parent.
PARENT="$(git ls-remote "$REMOTE" "refs/heads/$BRANCH" | cut -f1 || true)"
MSG="cc $VERSION — mirror snapshot of imperium global/ @ $(git rev-parse --short HEAD)"
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

✅ Mirror published — plugin version $VERSION at $REMOTE ($BRANCH).

   Reminder: marketplace installs only update when plugin.json "version" is
   bumped. If this publish carries user-facing changes, confirm the version
   changed since the last mirror push.

   Consumers install with:
     /plugin marketplace add <owner>/<mirror-repo>
     /plugin install cc@imperium
EOF
