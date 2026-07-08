#!/usr/bin/env bash
# repo-autoupdate.sh — keep configured git repos current at SessionStart, and auto-run
# their install.sh (idempotent) after a successful pull so the plugin cache never drifts
# from main (ADR-002 D1).
#
# Pairs with memory-sync.sh: it syncs your *memory*; this keeps your *tooling* (e.g. the
# imperium plugin) current so you don't have to remember to `git pull` + reinstall on the
# machine you switched to. It only ever PULLS (fast-forward) — authoring (commit/PR/merge)
# stays deliberate; a non-fast-forward (diverged) remote is refused, never reconciled
# automatically. Repos with install.sh are only auto-reinstalled if their origin matches
# the canonical remote (ADR-002 D4) — a mismatched remote is skipped, not trusted. It
# never blocks a session: all problems are surfaced, then it exits 0.
#
# Usage:
#   repo-autoupdate.sh check          # SessionStart action: ff-pull each repo, raise notices
#   repo-autoupdate.sh add <repo>     # register a repo (absolute path) for auto-update
#   repo-autoupdate.sh list           # show configured repos
#   repo-autoupdate.sh help
#
# Config: $HOME/.claude/repo-autoupdate.conf — one absolute repo path per line, '#' comments.
# (Per-machine, NOT synced — paths differ across machines.)

set -euo pipefail

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
CONF="${REPO_AUTOUPDATE_CONF:-$CLAUDE_HOME/repo-autoupdate.conf}"

command -v git &>/dev/null || exit 0   # no git -> nothing to do, never block the session

# D4 trust guard: repos that ship an install.sh get auto-reinstalled after a pull, which
# means whoever controls that remote executes code on this machine at next session start.
# Only trust the canonical imperium remote for that step (ssh or https form). Overridable
# via env for the test harness (no network / real GitHub remote involved there).
CANONICAL_REMOTE_RE="${REPO_AUTOUPDATE_CANONICAL_REMOTE_RE:-^(https://github\.com/cltcody/imperium(\.git)?|git@github\.com:cltcody/imperium(\.git)?|ssh://git@github\.com/cltcody/imperium(\.git)?)$}"

conf_repos() {
  [[ -f "$CONF" ]] || return 0
  grep -vE '^[[:space:]]*(#|$)' "$CONF" 2>/dev/null || true
}

cmd_add() {
  [[ $# -ge 1 ]] || { echo "add needs a repo path" >&2; exit 1; }
  local repo; repo="$(cd "$1" 2>/dev/null && pwd || echo "$1")"
  mkdir -p "$(dirname "$CONF")"
  touch "$CONF"
  if grep -qxF "$repo" "$CONF" 2>/dev/null; then
    echo "already registered: $repo"
  else
    printf '%s\n' "$repo" >> "$CONF"
    echo "registered for auto-update: $repo"
  fi
}

cmd_list() {
  echo "auto-update repos ($CONF):"
  conf_repos | sed 's/^/  /' || true
}

# check one repo: ff-pull if clean & behind; raise a notice on update / divergence / dirty.
check_one() {
  local repo="$1" name branch local_sha remote_sha n
  name="$(basename "$repo")"
  [[ -d "$repo/.git" ]] || { echo "  ⚠ $name: not a git repo ($repo) — skipped"; return 0; }

  # dirty working tree -> never clobber WIP
  if ! git -C "$repo" diff --quiet 2>/dev/null || ! git -C "$repo" diff --cached --quiet 2>/dev/null; then
    echo "  ℹ $name: local changes present — auto-update skipped (commit/stash to enable)"
    return 0
  fi

  # D4 trust guard: only for repos that would get auto-reinstalled (have install.sh) —
  # a mismatched origin means we'd be trusting an unverified remote to run code here.
  if [[ -f "$repo/install.sh" ]]; then
    local origin_url; origin_url="$(git -C "$repo" remote get-url origin 2>/dev/null || true)"
    if [[ -n "$origin_url" ]] && ! [[ "$origin_url" =~ $CANONICAL_REMOTE_RE ]]; then
      echo "  ⚠ $name: origin ($origin_url) is not the canonical remote — auto-update skipped"
      return 0
    fi
  fi

  branch="$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null || echo HEAD)"
  if ! git -C "$repo" fetch --quiet origin "$branch" 2>/dev/null; then
    echo "  ⚠ $name: fetch failed (offline or no upstream) — skipped"
    return 0
  fi

  local_sha="$(git -C "$repo" rev-parse HEAD 2>/dev/null || true)"
  remote_sha="$(git -C "$repo" rev-parse "origin/$branch" 2>/dev/null || true)"
  [[ -z "$remote_sha" ]] && { echo "  ⚠ $name: no origin/$branch — skipped"; return 0; }
  [[ "$local_sha" == "$remote_sha" ]] && return 0   # up to date — stay quiet

  if git -C "$repo" merge-base --is-ancestor "$local_sha" "$remote_sha" 2>/dev/null; then
    if git -C "$repo" pull --ff-only --quiet 2>/dev/null; then
      n="$(git -C "$repo" diff --name-only "$local_sha" "$remote_sha" | wc -l | tr -d ' ')"
      echo "  ▲ $name auto-updated ${local_sha:0:7}..${remote_sha:0:7} ($n file(s) changed)"
      # D1: reinstall automatically (idempotent) instead of nagging the user to do it.
      if [[ -f "$repo/install.sh" ]]; then
        if (cd "$repo" && bash install.sh) &>/dev/null; then
          echo "     → reinstalled (bash install.sh) — run /reload-plugins to pick it up mid-session"
        else
          echo "     → install failed, run manually: bash \"$repo/install.sh\""
        fi
      fi
    else
      echo "  ⚠ $name: fast-forward pull failed — reconcile manually (git -C \"$repo\" status)"
    fi
  else
    echo "  ⚠ $name has DIVERGED from origin/$branch (local commits not on remote) — reconcile manually"
  fi
}

cmd_check() {
  local repos; repos="$(conf_repos)"
  [[ -n "$repos" ]] || exit 0
  local any=0
  echo "[repo-autoupdate]"
  while IFS= read -r repo; do
    [[ -n "$repo" ]] || continue
    check_one "$repo"
    any=1
  done <<< "$repos"
  [[ "$any" -eq 1 ]] || true
  exit 0   # never block the session
}

# print the leading comment block only (stop at the first non-comment line, so code never leaks)
usage() { awk 'NR<2{next} /^#/{sub(/^# ?/,"");print;next}{exit}' "${BASH_SOURCE[0]}"; }

main() {
  local cmd="${1:-help}"; shift || true
  case "$cmd" in
    check) cmd_check "$@" ;;
    add)   cmd_add "$@" ;;
    list)  cmd_list "$@" ;;
    help|-h|--help) usage ;;
    *) echo "unknown command: $cmd (try 'help')" >&2; exit 1 ;;
  esac
}

main "$@"
