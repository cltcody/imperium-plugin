#!/usr/bin/env bash
# Behavioral tests for imperium's install/distribution shell scripts.
#
# Plain bash asserter — no bats dependency (not assumed to be installed).
# Run: bash global/scripts/__tests__/test_scripts.sh
#
# Hermetic: every fixture lives under a `mktemp -d` directory; nothing here
# writes to the real ~/.claude, the real plugin cache, or the network. Cleaned
# up via a trap regardless of pass/fail.
#
# Covers:
#   1. cc-profile-filter.sh — each profile in mirror-profiles/*.json yields the
#      expected catalog shape against a *fixture* installed-plugin tree (never
#      the real ~/.claude/plugins/cache).
#   2. install.sh idempotency — run twice, diff the resulting state. Because
#      install.sh's CC-publish path shells out to the real `claude` CLI
#      against the user's actual global install (marketplace registration,
#      `--scope user` plugin install), a true hermetic test cannot invoke that
#      binary — doing so would mutate the real ~/.claude, which these tests
#      must never touch. Instead, a minimal stub `claude` executable is placed
#      first on PATH; it implements just enough of `plugin validate|marketplace
#      list/add/update|install/uninstall/list` to record state to a scratch
#      dir. This still exercises install.sh's REAL control flow (flag parsing,
#      cc-publish.sh's already-registered-marketplace detection, the
#      uninstall-then-reinstall idempotency dance) — only the terminal `claude`
#      binary is faked. CLAUDE_HOME and CLAUDE_CONFIG_DIR point at a scratch dir
#      so the hook-refresh and cache force-sync steps never touch the real one.
#   3. GAP A (2026-07-08): a flagless install refreshes an already-installed
#      ~/.claude/scripts/repo-autoupdate.sh (so the D1 auto-reinstall updates the
#      hook itself), but never freshly installs hooks the machine didn't opt into.
#   4. GAP B (2026-07-08): cc-publish.sh force-syncs the version-keyed plugin
#      cache dir, so same-version edits go live (preserving the .in_use marker).
#   5. Profile persistence: --profile is recorded per machine and re-applied on
#      flagless reinstalls; --profile full resets it.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

PASS=0
FAIL=0

ok()   { PASS=$((PASS + 1)); printf 'PASS  %s\n' "$1"; }
bad()  { FAIL=$((FAIL + 1)); printf 'FAIL  %s\n' "$1"; }
assert_eq() { [[ "$1" == "$2" ]] && ok "$3" || { bad "$3 (expected [$2], got [$1])"; }; }
assert_true() { if eval "$1"; then ok "$2"; else bad "$2"; fi; }

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

# ── 1. cc-profile-filter.sh ─────────────────────────────────────────────────
# Real marketplace/plugin identity comes from the repo's own manifests (the
# script reads these unconditionally); only the *installed cache copy* is
# faked, at a throwaway CLAUDE_CONFIG_DIR.
MARKETPLACE="$(python3 -c "import json; print(json.load(open('$REPO_ROOT/global/.claude-plugin/marketplace.json'))['name'])")"
PLUGIN="$(python3 -c "import json; print(json.load(open('$REPO_ROOT/global/.claude-plugin/plugin.json'))['name'])")"
VERSION="$(python3 -c "import json; print(json.load(open('$REPO_ROOT/global/.claude-plugin/plugin.json'))['version'])")"

for profile_file in "$REPO_ROOT"/global/scripts/mirror-profiles/*.json; do
  profile="$(basename "$profile_file" .json)"
  fake_home="$TMP_ROOT/profile-$profile"
  target="$fake_home/plugins/cache/$MARKETPLACE/$PLUGIN/$VERSION"
  mkdir -p "$target/skills" "$target/commands"

  # A marker path no profile excludes — must survive every profile's filter.
  mkdir -p "$target/skills/__always_keep__"
  touch "$target/skills/__always_keep__/SKILL.md"

  # Materialize every excluded path from the profile as a fixture file/dir.
  first_excluded=""
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    [[ -z "$first_excluded" ]] && first_excluded="$path"
    if [[ "$path" == *.md ]]; then
      mkdir -p "$target/$(dirname "$path")"
      touch "$target/$path"
    else
      mkdir -p "$target/$path"
      touch "$target/$path/SKILL.md"
    fi
  done < <(python3 -c "import json; [print(p) for p in json.load(open('$profile_file'))['exclude']]")

  if [[ -z "$first_excluded" ]]; then
    bad "cc-profile-filter.sh: profile '$profile' has a non-empty exclude list to test against"
    continue
  fi

  out="$(CLAUDE_CONFIG_DIR="$fake_home" bash "$REPO_ROOT/global/scripts/cc-profile-filter.sh" "$profile" 2>&1)"
  rc=$?
  assert_eq "$rc" "0" "cc-profile-filter.sh ($profile): exits 0"

  if [[ -e "$target/$first_excluded" ]]; then
    bad "cc-profile-filter.sh ($profile): excluded path '$first_excluded' is removed"
  else
    ok "cc-profile-filter.sh ($profile): excluded path '$first_excluded' is removed"
  fi

  if [[ -f "$target/skills/__always_keep__/SKILL.md" ]]; then
    ok "cc-profile-filter.sh ($profile): non-excluded marker path survives"
  else
    bad "cc-profile-filter.sh ($profile): non-excluded marker path survives"
  fi
done

# ── 2. install.sh idempotency (stubbed `claude` CLI; see header) ───────────
STATE_DIR="$TMP_ROOT/install-state"
BIN_DIR="$TMP_ROOT/install-bin"
WORK_DIR="$TMP_ROOT/install-work"
FAKE_HOME="$TMP_ROOT/install-home"   # stands in for ~/.claude (CLAUDE_HOME + CLAUDE_CONFIG_DIR)
mkdir -p "$STATE_DIR" "$BIN_DIR" "$WORK_DIR" "$FAKE_HOME/scripts"

# GAP A fixture: a stale previously-installed hook script that a flagless install
# must refresh. memory-sync.sh is deliberately ABSENT — refresh must not wire it fresh.
printf '#!/usr/bin/env bash\n# stale pre-D1 hook\n' > "$FAKE_HOME/scripts/repo-autoupdate.sh"

# GAP B fixture: a stale same-version cache copy (version-keyed; `plugin install`
# never re-copies it) that cc-publish's force-sync must bring current.
CACHE_DIR="$FAKE_HOME/plugins/cache/$MARKETPLACE/$PLUGIN/$VERSION"
mkdir -p "$CACHE_DIR/skills/__stale_only__"
echo "stale" > "$CACHE_DIR/skills/__stale_only__/SKILL.md"
echo "stale" > "$CACHE_DIR/CLAUDE.md"
touch "$CACHE_DIR/.in_use"          # Claude Code's own marker — must survive the sync

cat > "$BIN_DIR/claude" <<'STUB'
#!/usr/bin/env bash
# Hermetic stand-in for the real `claude` CLI, used ONLY by
# global/scripts/__tests__/test_scripts.sh to test install.sh's control flow
# without ever touching the tester's real ~/.claude. State is recorded under
# $STATE_DIR (set by the test) so a second invocation behaves idempotently:
# an already-registered marketplace is "update"d, not re-"add"ed.
set -euo pipefail
: "${STATE_DIR:?STATE_DIR must be set by the caller}"
mkdir -p "$STATE_DIR"

if [[ "${1:-}" != "plugin" ]]; then
  exit 0
fi
shift
case "${1:-}" in
  validate)
    exit 0
    ;;
  marketplace)
    shift
    case "${1:-}" in
      list)
        [[ -f "$STATE_DIR/marketplace" ]] && cat "$STATE_DIR/marketplace"
        exit 0
        ;;
      add)
        echo "imperium" > "$STATE_DIR/marketplace"
        exit 0
        ;;
      update)
        exit 0
        ;;
    esac
    ;;
  uninstall)
    rm -f "$STATE_DIR/plugin"
    exit 0
    ;;
  install)
    echo "cc@imperium" > "$STATE_DIR/plugin"
    exit 0
    ;;
  list)
    [[ -f "$STATE_DIR/plugin" ]] && cat "$STATE_DIR/plugin"
    exit 0
    ;;
esac
exit 0
STUB
chmod +x "$BIN_DIR/claude"

run_install() {
  ( cd "$WORK_DIR" && PATH="$BIN_DIR:$PATH" STATE_DIR="$STATE_DIR" \
      CLAUDE_HOME="$FAKE_HOME" CLAUDE_CONFIG_DIR="$FAKE_HOME" \
      bash "$REPO_ROOT/install.sh" --cc-only --skip-config "$@" )
}

run1_out="$(run_install 2>&1)"; rc1=$?
assert_eq "$rc1" "0" "install.sh (--cc-only --skip-config): first run exits 0"

cp -r "$STATE_DIR" "$STATE_DIR.snap1"

run2_out="$(run_install 2>&1)"; rc2=$?
assert_eq "$rc2" "0" "install.sh (--cc-only --skip-config): second run exits 0"

if diff -r "$STATE_DIR.snap1" "$STATE_DIR" >"$TMP_ROOT/install-idempotency.diff" 2>&1; then
  ok "install.sh: second run produces an identical state tree (idempotent)"
else
  bad "install.sh: second run produces an identical state tree (idempotent)"
  cat "$TMP_ROOT/install-idempotency.diff"
fi

# ── 3. GAP A — a flagless install refreshes previously installed hook scripts ──
if cmp -s "$REPO_ROOT/global/scripts/repo-autoupdate.sh" "$FAKE_HOME/scripts/repo-autoupdate.sh"; then
  ok "install.sh (flagless): stale installed repo-autoupdate.sh is refreshed to the repo version"
else
  bad "install.sh (flagless): stale installed repo-autoupdate.sh is refreshed to the repo version"
fi
if [[ -e "$FAKE_HOME/scripts/memory-sync.sh" ]]; then
  bad "install.sh (flagless): refresh is update-only — absent memory-sync.sh is NOT freshly installed"
else
  ok "install.sh (flagless): refresh is update-only — absent memory-sync.sh is NOT freshly installed"
fi
if [[ -e "$FAKE_HOME/scripts/repo-autoupdate.sh.tmp" ]]; then
  bad "install.sh (flagless): no .tmp leftover from the atomic hook swap"
else
  ok "install.sh (flagless): no .tmp leftover from the atomic hook swap"
fi

# ── 4. GAP B — same-version cache copy is force-synced by cc-publish ──────────
if cmp -s "$REPO_ROOT/global/CLAUDE.md" "$CACHE_DIR/CLAUDE.md"; then
  ok "cc-publish.sh: stale same-version cache content is force-synced from source"
else
  bad "cc-publish.sh: stale same-version cache content is force-synced from source"
fi
if [[ -e "$CACHE_DIR/skills/__stale_only__" ]]; then
  bad "cc-publish.sh: cache-only leftovers are removed by the sync"
else
  ok "cc-publish.sh: cache-only leftovers are removed by the sync"
fi
if [[ -f "$CACHE_DIR/.in_use" ]]; then
  ok "cc-publish.sh: Claude Code's .in_use marker survives the sync"
else
  bad "cc-publish.sh: Claude Code's .in_use marker survives the sync"
fi

# ── 5. Profile persistence — flagless reinstall re-applies the recorded profile ──
# (Without this, the cache force-sync would silently un-filter a profiled machine
# on every auto-reinstall after a pull.)
PERSIST_PROFILE="business"
first_excluded="$(python3 -c "
import json, os
for p in json.load(open('$REPO_ROOT/global/scripts/mirror-profiles/$PERSIST_PROFILE.json'))['exclude']:
    if os.path.exists('$REPO_ROOT/global/' + p):
        print(p); break
")"
if [[ -z "$first_excluded" ]]; then
  bad "profile persistence: profile '$PERSIST_PROFILE' excludes at least one path that exists in global/"
else
  ok "profile persistence: profile '$PERSIST_PROFILE' excludes at least one path that exists in global/"

  run3_out="$(run_install --profile "$PERSIST_PROFILE" 2>&1)"; rc3=$?
  assert_eq "$rc3" "0" "install.sh --profile $PERSIST_PROFILE: exits 0"
  assert_eq "$(cat "$FAKE_HOME/cc-install-profile" 2>/dev/null)" "$PERSIST_PROFILE" \
    "install.sh --profile $PERSIST_PROFILE: profile recorded in cc-install-profile"
  if [[ -e "$CACHE_DIR/$first_excluded" ]]; then
    bad "install.sh --profile $PERSIST_PROFILE: excluded path '$first_excluded' removed from cache"
  else
    ok "install.sh --profile $PERSIST_PROFILE: excluded path '$first_excluded' removed from cache"
  fi

  run4_out="$(run_install 2>&1)"; rc4=$?
  assert_eq "$rc4" "0" "install.sh (flagless after profile): exits 0"
  if [[ -e "$CACHE_DIR/$first_excluded" ]]; then
    bad "install.sh (flagless after profile): recorded profile re-applied — '$first_excluded' stays excluded"
  else
    ok "install.sh (flagless after profile): recorded profile re-applied — '$first_excluded' stays excluded"
  fi

  run5_out="$(run_install --profile full 2>&1)"; rc5=$?
  assert_eq "$rc5" "0" "install.sh --profile full: exits 0"
  assert_eq "$(cat "$FAKE_HOME/cc-install-profile" 2>/dev/null)" "full" \
    "install.sh --profile full: resets the recorded profile"
  if [[ -e "$CACHE_DIR/$first_excluded" ]]; then
    ok "install.sh --profile full: full catalog restored by the force-sync"
  else
    bad "install.sh --profile full: full catalog restored by the force-sync"
  fi
fi

# ── Summary ──────────────────────────────────────────────────────────────────
echo
echo "test_scripts.sh: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
