#!/usr/bin/env bash
# memory-sync.sh — Sync Claude Code project memory across machines via a git-backed store.
#
# Claude stores project memory at ~/.claude/projects/<encoded-abs-path>/memory/. The encoded
# name embeds the absolute project path (hence the username), so the same project produces a
# DIFFERENTLY-named memory folder on each machine. This tool sidesteps that entirely: each
# project's memory dir becomes a SYMLINK into a shared git "store" under a stable canonical
# LABEL you choose. Different machines (even different usernames or OSes) point their own
# memory folders at the same label, so memory is shared without relocating any repo.
#
# Only */memory/ subtrees are ever touched — never session transcripts.
#
# A block-and-hold DENYLIST gate runs on every push: any memory file matching a term in
# <store>/.memory-denylist is HELD BACK (kept local, never pushed) and flagged for review.
#
# `link` REFUSES a project whose root STACK.md declares `class: corporate` — work-derived
# memory must not sync to a personal remote (the safeguard matrix in
# references/dev/repo-classification.md). This is a command-level courtesy check, fail-open
# when STACK.md or its `class:` field is absent; the denylist gate above remains the actual
# security backstop, unaffected by this check. shared-oss and personal-classed (or classless)
# projects are unaffected.
#
# Usage:
#   memory-sync.sh encode <abs-project-path>          # print the Claude-encoded folder name
#   memory-sync.sh status                             # what's in the store, links, review flags
#   memory-sync.sh link  <abs-project-path> [label]   # symlink a project's memory into the store
#   memory-sync.sh adopt <abs-project-path> [label]   # union existing memory into the store (no link)
#   memory-sync.sh pull                               # git pull the store (SessionStart hook)
#   memory-sync.sh push                               # gate + commit + push the store (SessionEnd hook)
#   memory-sync.sh doctor                             # read-only diagnosis: orphans, denylist holds, divergence, ...
#   memory-sync.sh install-hooks                      # install script + wire user-scope hooks
#   memory-sync.sh help
#
# label defaults to the basename of the project path (e.g. /Users/x/code/imperium -> "imperium").
#
# Config (env overrides):
#   CLAUDE_MEMORY_STORE   default $HOME/.claude/memory-store
#   CLAUDE_HOME           default $HOME/.claude

set -euo pipefail

STORE="${CLAUDE_MEMORY_STORE:-$HOME/.claude/memory-store}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
PROJECTS="$CLAUDE_HOME/projects"
HOST="$(hostname -s 2>/dev/null || echo unknown)"

step() { printf '\n\033[1m▸ %s\033[0m\n' "$1"; }
info() { printf '  %s\n' "$1"; }
warn() { printf '\033[33m  ! %s\033[0m\n' "$1" >&2; }
die()  { printf '\033[31mError: %s\033[0m\n' "$1" >&2; exit 1; }

command -v git &>/dev/null || die "git is not on PATH"

# encode <abs-path> -> Claude-encoded folder name (sanitize '/' and '.' to '-').
encode() {
  [[ $# -ge 1 ]] || die "encode needs an absolute path"
  printf '%s' "$1" | sed -E 's#[/.]#-#g'
}

# label_for <abs-path> [label] -> the explicit label, or the path's basename.
label_for() {
  if [[ $# -ge 2 && -n "$2" ]]; then printf '%s' "$2"; else basename "$1"; fi
}

# get_repo_class <project-root> -> prints the STACK.md frontmatter's normalized `class:`
# value on stdout (lowercased, surrounding quotes stripped), or nothing (return 1) when
# STACK.md, its frontmatter, or the field is absent. Mirrors
# hooks/block-corporate-artifacts.py's read_class() — same fail-open contract, same
# "first `---`-delimited block ANYWHERE in the file counts" tolerant rule (no NR==1
# anchor — a preamble before the frontmatter is tolerated on both sides), same
# case/quote-insensitive value comparison — in shell instead of Python.
get_repo_class() {
  local stack fm line value
  stack="$1/STACK.md"
  [[ -f "$stack" ]] || return 1
  fm="$(awk '
    /^---[[:space:]]*$/ { c++; if (c == 2) exit; next }
    c == 1 { print }
  ' "$stack")"
  [[ -n "$fm" ]] || return 1
  line="$(printf '%s\n' "$fm" | grep -m1 -E '^class:[[:space:]]*' || true)"
  [[ -n "$line" ]] || return 1
  value="$(printf '%s\n' "$line" | sed -E 's/^class:[[:space:]]*([^[:space:]]+).*/\1/')"
  # normalize like read_class() in block-corporate-artifacts.py: strip one layer of
  # surrounding quotes, case-fold — "corporate", CORPORATE, Corporate all match.
  value="${value%\"}"; value="${value#\"}"
  value="${value%\'}"; value="${value#\'}"
  printf '%s\n' "${value,,}"
}

# Seed a default denylist into the store if absent (tracked, so it syncs across machines).
ensure_denylist() {
  local f="$STORE/.memory-denylist"
  [[ -f "$f" ]] && return 0
  mkdir -p "$STORE"
  cat > "$f" <<'EOF'
# memory-sync denylist — case-insensitive extended regex (grep -iE), one per line.
# Any store file matching a line is HELD BACK from push (kept local) until you remove
# the term. '#' lines and blank lines are ignored. Over-matching is safe (it just parks a
# file for review). Add customer names and your cc.config work-brand tokens here.

# --- work / confidential terms ---
thomson reuters
(^|[^a-z])tr([^a-z]|$)
saffron

# --- accidental secrets (high-signal prefixes; NOT a generic hex/base64 catch-all,
#     which would false-match git SHAs in dev memory). Defense-in-depth on top of the
#     block-secrets hook + handoff redaction. ---
gh[oprsu]_[0-9a-z]{20,}
sk-[a-z0-9_-]{20,}
xox[baprs]-[0-9a-z-]{10,}
akia[0-9a-z]{16}
-----begin [a-z ]*private key-----
aws_secret_access_key
EOF
}

# Keep the review flag (and noise) out of git. Appends entries missing from an
# existing .gitignore so upgrades pick up new ones (e.g. .sync-failed).
ensure_store_gitignore() {
  local f="$STORE/.gitignore" entry
  mkdir -p "$STORE"
  [[ -f "$f" ]] || : > "$f"
  # a hand-edited file may lack a final newline — appending would glue onto its last pattern
  if [[ -s "$f" && -n "$(tail -c 1 "$f")" ]]; then printf '\n' >> "$f"; fi
  for entry in 'REVIEW_NEEDED.txt' '.DS_Store' '.sync-failed'; do
    grep -qxF "$entry" "$f" || printf '%s\n' "$entry" >> "$f"
  done
}

# Union one memory dir's files into the store, non-destructively.
#   $1 src memory dir (may not exist)   $2 dest memory dir (created)
# Copies files only if absent; on same-name divergence, writes <name>.from-$HOST and warns.
union_into() {
  local src="$1" dest="$2" f base out saved
  [[ -d "$src" ]] || return 0
  mkdir -p "$dest"
  saved="$(shopt -p nullglob dotglob || true)"   # restore caller's glob state afterward (|| true: shopt -p returns 1 when unset)
  shopt -s nullglob dotglob
  for f in "$src"/*; do
    [[ -f "$f" ]] || continue   # only files; memory is flat markdown
    base="$(basename "$f")"
    if [[ ! -e "$dest/$base" ]]; then
      cp -p "$f" "$dest/$base"
    elif ! cmp -s "$f" "$dest/$base"; then
      # keep conflict copies in the .md namespace so they're visible to memory tooling
      if [[ "$base" == *.md ]]; then out="${base%.md}.from-$HOST.md"; else out="$base.from-$HOST"; fi
      cp -p "$f" "$dest/$out"
      warn "divergent: $base kept as $out (reconcile manually)"
    fi
  done
  eval "$saved"
}

cmd_status() {
  step "Memory store: $STORE"
  [[ -d "$STORE" ]] || { info "(store does not exist yet)"; return 0; }
  if [[ -d "$STORE/.git" ]]; then
    info "git: $(git -C "$STORE" remote get-url origin 2>/dev/null || echo '(no origin)')"
  else
    info "git: (not a git repo yet)"
  fi
  local d label proj enc found=0 saved
  saved="$(shopt -p nullglob || true)"
  shopt -s nullglob
  for d in "$STORE"/*/memory; do
    label="$(basename "$(dirname "$d")")"
    [[ "$label" == ".git" ]] && continue
    found=1
    # report any local symlink that points at this label
    local linked=""
    for proj in "$PROJECTS"/*/memory; do
      [[ -L "$proj" && "$(readlink "$proj")" == "$d" ]] && linked="$(basename "$(dirname "$proj")")"
    done
    if [[ -n "$linked" ]]; then
      printf '  %-20s linked from %s\n' "$label" "$linked"
    else
      printf '  %-20s in store, not linked on this machine\n' "$label"
    fi
  done
  eval "$saved"
  [[ "$found" -eq 0 ]] && info "(no labels in store yet)"
  if [[ -f "$STORE/REVIEW_NEEDED.txt" ]]; then
    warn "REVIEW NEEDED — files held from sync (denylist hits):"
    sed 's/^/    /' "$STORE/REVIEW_NEEDED.txt" >&2
  fi
}

cmd_link() {
  [[ $# -ge 1 ]] || die "link needs an absolute project path [and optional label]"
  local path="$1" label enc proj target repo_class
  # normalize first — a trailing slash or ./.. segment would corrupt the encoded name
  [[ -d "$path" ]] && path="$(cd "$path" && pwd)"
  label="$(label_for "$path" "${2:-}")"

  repo_class="$(get_repo_class "$path")" || repo_class=""
  if [[ "$repo_class" == "corporate" ]]; then
    die "refusing to link '$path': its root STACK.md declares class: corporate. Work-derived memory must not sync to a personal remote — see the safeguard matrix in references/dev/repo-classification.md. This is a command-level courtesy check (fail-open when STACK.md/class is absent); the denylist gate remains the actual backstop. Misclassified? Fix STACK.md's class: field."
  fi

  enc="$(encode "$path")"
  proj="$PROJECTS/$enc/memory"
  target="$STORE/$label/memory"
  mkdir -p "$target" "$PROJECTS/$enc"
  # record the real source path so doctor never has to guess it back from the encoded name
  # (written even when already linked, so re-running `link` upgrades legacy entries)
  printf '%s\n' "$path" > "$PROJECTS/$enc/.memory-source-path"
  ensure_denylist; ensure_store_gitignore

  if [[ -L "$proj" ]]; then
    info "already linked: $enc -> $(readlink "$proj")"
    return 0
  fi
  if [[ -d "$proj" ]]; then
    info "migrating existing memory into store/$label"
    union_into "$proj" "$target"
    mv "$proj" "$proj.bak-$(date +%s)"
    info "backed up old dir to ${proj}.bak-*"
  fi
  ln -s "$target" "$proj"
  info "linked $proj -> $target"
}

cmd_adopt() {
  [[ $# -ge 1 ]] || die "adopt needs an absolute project path [and optional label]"
  local path="$1" label enc src
  label="$(label_for "$@")"
  enc="$(encode "$path")"
  src="$PROJECTS/$enc/memory"
  [[ -d "$src" || -L "$src" ]] || { warn "no memory at $src — nothing to adopt"; return 0; }
  mkdir -p "$STORE/$label/memory"
  ensure_denylist; ensure_store_gitignore
  step "adopt $enc -> store/$label"
  union_into "$src" "$STORE/$label/memory"
  info "adopted into store/$label/memory (live copy left intact; run 'link $path $label' to cut over)"
}

cmd_pull() {
  [[ -d "$STORE/.git" ]] || exit 0
  # local-only store (no remote yet) — nothing to pull, and not a failure
  git -C "$STORE" remote get-url origin &>/dev/null || exit 0
  if ! git -C "$STORE" pull --rebase --quiet 2>/dev/null; then
    git -C "$STORE" rebase --abort >/dev/null 2>&1 || true
    touch "$STORE/.sync-failed"
    echo "memory-sync: PULL FAILED (conflict or network) — memory may be stale; run 'memory-sync.sh pull' manually" >&2
  else
    rm -f "$STORE/.sync-failed"
  fi
}

# BENIGN_TR_CONTEXTS — shell-command uses of the Unix tr(1) utility (and the "tr;dr" joke on
# tl;dr) that must NOT trip the denylist's word-bounded `tr` term. That term exists to catch the
# employer abbreviation ("the TR deal"), but plain `tr -d`, `| tr`, `tr [a-z]`, etc. are common in
# dev-memory shell snippets and would otherwise be held back on every push. Tightening the
# denylist regex itself risks reopening the false negatives the word-boundary was added to close
# (grep -E has no lookaround to say "tr, but not shell-usage tr"), so instead each known-benign
# phrase is blanked out of a SCRATCH COPY of the content before the denylist regex runs — a line
# about `tr -d` never matches, but a line about "the TR deal" still does. Applied case-insensitively
# via explicit [Tt][Rr] character classes (not sed's GNU-only /I flag) so this stays portable to
# BSD sed on macOS, one of the two machines this script targets.
BENIGN_TR_CONTEXTS=(
  '[Tt][Rr][[:space:]]+-[A-Za-z]+'         # tr -d, tr -s, tr -cd, ...
  '[Tt][Rr][[:space:]]*<'                  # tr < file            (redirection)
  '\|[[:space:]]*[Tt][Rr]([[:space:]]|$)'  # ... | tr              (piped into tr)
  '[Tt][Rr][[:space:]]*\['                 # tr [a-z] [A-Z]        (char-class args)
  '[Tt][Rr];[Dd][Rr]'                      # tr;dr                 (tl;dr joke/typo)
)

# Blank BENIGN_TR_CONTEXTS matches out of a file's content (replaced with a space, so line
# structure and every OTHER denylist term's matchability is untouched) before denylist matching.
scrub_benign_tr() {
  local f="$1" pat content
  [[ -f "$f" ]] || return 0
  content="$(cat -- "$f" 2>/dev/null || true)"
  for pat in "${BENIGN_TR_CONTEXTS[@]}"; do
    content="$(printf '%s\n' "$content" | sed -E "s/$pat/ /g")"
  done
  printf '%s\n' "$content"
}

# Blank wiki-link [[slug]] STRUCTURE out of a content stream before denylist matching.
# A link slug is a memory filename, never a secret — but a slug such as
# [[feedback-ask-clarifying-questions]] false-matches the sk-<20+> API-key pattern and
# would park the whole file from sync. Scrub ONLY [[...]] (not markdown ](url) targets,
# which could legitimately carry a secret-bearing URL) so this kills the false-positive
# class without weakening real secret detection. Reads stdin.
scrub_link_slugs() {
  sed -E 's/\[\[[^]]*\]\]/ /g'
}

# Echo store-relative paths of files that hit the denylist. Scans the SAME set `git add -A`
# would commit (all file types, any subdir incl. _handoffs/) — not just *.md — so nothing slips
# the gate by extension. Excludes .git/ and the control files (the denylist would self-match).
# Each file is scrubbed of BENIGN_TR_CONTEXTS + wiki-link slugs (see above) before matching.
denylist_hits() {
  local patterns f
  patterns="$(grep -vE '^[[:space:]]*(#|$)' "$STORE/.memory-denylist" 2>/dev/null || true)"
  [[ -n "$patterns" ]] || return 0
  ( cd "$STORE" && while IFS= read -r f; do
      scrub_benign_tr "$f" | scrub_link_slugs | grep -qiE -f <(printf '%s\n' "$patterns") && printf '%s\n' "${f#./}"
    done < <(find . -type f ! -path './.git/*' ! -name '.memory-denylist' ! -name 'REVIEW_NEEDED.txt' 2>/dev/null) )
}

cmd_push() {
  [[ -d "$STORE/.git" ]] || exit 0
  ensure_denylist; ensure_store_gitignore
  cd "$STORE"

  # block-and-hold: find denylist hits and keep them out of the commit entirely
  local held=() f
  while IFS= read -r f; do [[ -n "$f" ]] && held+=("$f"); done < <(denylist_hits)

  git add -A || true
  for f in "${held[@]:-}"; do
    [[ -n "$f" ]] || continue
    git restore --staged -- "$f" 2>/dev/null || git reset -q -- "$f" 2>/dev/null || true
  done

  if [[ "${#held[@]}" -gt 0 && -n "${held[0]:-}" ]]; then
    local patterns; patterns="$(grep -vE '^[[:space:]]*(#|$)' "$STORE/.memory-denylist" 2>/dev/null || true)"
    {
      echo "Held back from sync — contains denylisted terms. Edit these, then push again:"
      for f in "${held[@]}"; do
        scrub_benign_tr "$f" | scrub_link_slugs | grep -inE -f <(printf '%s\n' "$patterns") 2>/dev/null | sed "s#^#  $f:#"
      done
    } > "$STORE/REVIEW_NEEDED.txt"
    warn "${#held[@]} file(s) held from sync (denylist) — see: $STORE/REVIEW_NEEDED.txt"
  else
    rm -f "$STORE/REVIEW_NEEDED.txt"
  fi

  if ! git diff --cached --quiet 2>/dev/null; then
    git commit -q -m "memory: $HOST $(date -u +%FT%TZ)" || true
  fi
  # push the current branch explicitly so no pre-configured upstream is required
  if git remote get-url origin &>/dev/null; then
    if git push --quiet origin HEAD 2>/dev/null; then
      rm -f "$STORE/.sync-failed"
    else
      touch "$STORE/.sync-failed"
      echo "memory-sync: PUSH FAILED — memory NOT synced to remote; run 'memory-sync.sh push' manually" >&2
    fi
  fi
}

# reconstruct the abs project path a Claude-encoded folder name most likely came from. Best-effort
# only: encode() maps both '/' and '.' to '-', so a literal '-' or '.' in the original path is
# ambiguous here — good enough for a diagnostic, not for anything destructive.
guess_path_for_encoded() {
  printf '/%s' "$(tr '-' '/' <<<"${1#-}")"
}

# Does SOME existing directory decode from a Claude-encoded name? Decoding is ambiguous
# (encode() flattens '/' and '.' to '-', and literal '-' passes through), so instead of
# guessing the path back, walk the REAL filesystem and encode each directory forward: at every
# level, a child dir whose encoded name is a token-aligned prefix of the remaining suffix is a
# viable branch. Exact w.r.t. encode(), so '-Users-x-code-anger-app-source' resolves to
# /Users/x/code/anger-app-source. Used only to soften doctor warnings for legacy links that
# predate the .memory-source-path record.
_resolves_from() {
  local cur="$1" rest="$2" d base e
  [[ -z "$rest" ]] && return 0
  while IFS= read -r d; do
    base="${d##*/}"
    e="${base//./-}"                       # encode() applied to one component
    if [[ "$rest" == "$e" ]]; then
      return 0
    elif [[ "$rest" == "$e"-* ]]; then
      _resolves_from "$d" "${rest#"$e"-}" && return 0
    fi
  done < <(find -L "$cur" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
  return 1
}

encoded_path_resolves() {
  [[ "$1" == -?* ]] || return 1            # encoded absolute paths always start with '-'
  _resolves_from / "${1#-}"
}

cmd_doctor() {
  step "memory-sync doctor — read-only diagnosis (never modifies anything; always exits 0)"
  local store_exists=0 saved proj target enc guess label linked found f size

  # (a) store existence, git-repo-ness, remote reachability
  step "Store"
  if [[ -d "$STORE" ]]; then
    store_exists=1
    info "path: $STORE"
    if [[ ! -d "$STORE/.git" ]]; then
      warn "not a git repo yet — fix: git -C \"$STORE\" init && git -C \"$STORE\" remote add origin <url>"
    else
      local origin; origin="$(git -C "$STORE" remote get-url origin 2>/dev/null || true)"
      if [[ -z "$origin" ]]; then
        info "git repo, no 'origin' remote configured (local-only store) — pull/push no-op until one is added"
      else
        info "remote: $origin"
        local tcmd=()
        command -v timeout &>/dev/null && tcmd=(timeout 5)
        # bash 3.2 (macOS default) aborts on "${empty[@]}" under `set -u`; timeout(1) is usually
        # absent on macOS, so tcmd stays empty here. The ${arr[@]+…} form expands to nothing when
        # empty and to the quoted elements when set — portable across bash 3.2 and 4+/5.
        if GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh -o BatchMode=yes -o ConnectTimeout=5}" \
            ${tcmd[@]+"${tcmd[@]}"} git -C "$STORE" ls-remote --exit-code origin &>/dev/null; then
          info "remote reachable (git ls-remote OK)"
        else
          warn "remote unreachable right now — offline, network hiccup, or auth issue (not fatal; pull/push will just retry next session)"
        fi
      fi
    fi
  else
    info "no store at $STORE — memory sync isn't set up on this machine yet. See docs/memory-sync-runbook.md Phase A/B."
  fi

  # (b) .sync-failed marker
  step ".sync-failed marker"
  if [[ -f "$STORE/.sync-failed" ]]; then
    warn "present — the last pull or push failed. Fix: bash \"${BASH_SOURCE[0]}\" pull   (then, if needed) push"
  else
    info "none — last pull/push (if any) succeeded"
  fi

  # (c) orphaned links: the linked project's source dir no longer exists (moved-repo gotcha).
  # Trusts the .memory-source-path recorded by `link`; legacy links without one fall back to
  # decoding the folder name, which is ambiguous for hyphenated names — those only get a
  # softer "possibly orphaned" once the greedy resolver also comes up empty.
  step "Orphaned links (moved-repo gotcha)"
  found=0
  saved="$(shopt -p nullglob || true)"; shopt -s nullglob
  local srcfile src
  for proj in "$PROJECTS"/*/memory; do
    [[ -L "$proj" ]] || continue
    target="$(readlink "$proj")"
    [[ "$target" == "$STORE"/* ]] || continue   # only care about store-linked memories
    enc="$(basename "$(dirname "$proj")")"
    label="$(basename "$(dirname "$target")")"
    srcfile="$(dirname "$proj")/.memory-source-path"
    if [[ -f "$srcfile" ]]; then
      src="$(head -n1 "$srcfile")"
      [[ -d "$src" ]] && continue
      found=1
      warn "orphaned: $proj -> store/$label (recorded source project '$src' doesn't exist — moved or deleted)"
    else
      encoded_path_resolves "$enc" && continue
      found=1
      guess="$(guess_path_for_encoded "$enc")"
      warn "possibly orphaned: $proj -> store/$label (no recorded source path and no existing dir decodes from '$enc'; naive guess was '$guess'. Decoding is best-effort, so this can be a false alarm)"
    fi
    info "  fix: bash \"${BASH_SOURCE[0]}\" link <current-path-of-$label> $label   # re-points AND records the current path (silences a false alarm too)"
    info "  (link refuses if that path's STACK.md declares class: corporate — see references/dev/repo-classification.md)"
    info "  fix: rm -f \"$proj\" && rm -rf \"$(dirname "$proj")\"   # retire this stale entry — NOTE: that dir also holds the project's old session transcripts"
  done
  eval "$saved"
  [[ "$found" -eq 0 ]] && info "none found"

  # (d) store labels with no local symlink on this machine
  step "Store labels not linked on this machine"
  found=0
  if [[ "$store_exists" -eq 1 ]]; then
    saved="$(shopt -p nullglob || true)"; shopt -s nullglob
    local d
    for d in "$STORE"/*/memory; do
      label="$(basename "$(dirname "$d")")"
      [[ "$label" == ".git" ]] && continue
      linked=""
      for proj in "$PROJECTS"/*/memory; do
        [[ -L "$proj" && "$(readlink "$proj")" == "$d" ]] && linked=1
      done
      if [[ -z "$linked" ]]; then
        found=1
        info "$label — in store, not linked here. If this project lives on this machine: bash \"${BASH_SOURCE[0]}\" link <path-to-$label> $label"
        info "  (link refuses if that project's STACK.md declares class: corporate — see references/dev/repo-classification.md)"
      fi
    done
    eval "$saved"
  fi
  if [[ "$found" -eq 0 ]]; then
    [[ "$store_exists" -eq 1 ]] && info "none — every store label is linked on this machine" || info "(no store — skipped)"
  fi

  # (e) divergence files (*.from-<host>)
  step "Divergence files (*.from-<host>)"
  found=0
  if [[ "$store_exists" -eq 1 ]]; then
    while IFS= read -r f; do
      found=1
      size="$(wc -c < "$f" 2>/dev/null | tr -d '[:space:]')"
      info "${f#"$STORE"/} (${size:-?} bytes) — reconcile: diff against the base file, merge by hand, delete the .from-* copy"
    done < <(find "$STORE" -type f -name '*.from-*' 2>/dev/null)
  fi
  if [[ "$found" -eq 0 ]]; then
    [[ "$store_exists" -eq 1 ]] && info "none found" || info "(no store — skipped)"
  fi

  # (f) denylist holds — mirror what the next push would hold back, read-only
  step "Denylist holds (would be held back on next push)"
  found=0
  if [[ "$store_exists" -eq 1 && -f "$STORE/.memory-denylist" ]]; then
    local patterns match
    patterns="$(grep -vE '^[[:space:]]*(#|$)' "$STORE/.memory-denylist" 2>/dev/null || true)"
    if [[ -n "$patterns" ]]; then
      while IFS= read -r f; do
        [[ -n "$f" ]] || continue
        found=1
        match="$(scrub_benign_tr "$STORE/$f" | scrub_link_slugs | grep -inE -f <(printf '%s\n' "$patterns") 2>/dev/null | head -n1)"
        warn "$f — matched: ${match:-<term>}"
        info "  fix: edit to remove the term, then 'push' again"
      done < <(denylist_hits)
    fi
  fi
  if [[ "$found" -eq 0 ]]; then
    [[ "$store_exists" -eq 1 ]] && info "none — nothing currently held" || info "(no store — skipped)"
  fi

  # (g) dangling symlinks under the projects dir
  step "Dangling symlinks under $PROJECTS"
  found=0
  saved="$(shopt -p nullglob || true)"; shopt -s nullglob
  for proj in "$PROJECTS"/*/memory; do
    if [[ -L "$proj" && ! -e "$proj" ]]; then
      found=1
      warn "dangling: $proj -> $(readlink "$proj") (target missing)"
      info "  fix: rm -f \"$proj\"   # then re-link if this project should stay synced: bash \"${BASH_SOURCE[0]}\" link <path> <label>"
    fi
  done
  eval "$saved"
  [[ "$found" -eq 0 ]] && info "none found"

  # (h) broken wiki-links — a [[slug]] whose target memory file is missing but whose
  # hyphen->underscore normalization resolves (a format typo — the same class that can
  # false-match a secret pattern and park a file; see scrub_link_slugs). Genuinely dangling
  # links (no normalized match) are intentional placeholders per the memory convention and
  # are NOT flagged, to keep this signal actionable.
  step "Broken wiki-links (hyphenated slug where an underscore memory exists)"
  found=0
  if [[ "$store_exists" -eq 1 ]]; then
    saved="$(shopt -p nullglob || true)"; shopt -s nullglob
    local mdir slug norm
    for mdir in "$STORE"/*/memory; do
      [[ -d "$mdir" ]] || continue
      for f in "$mdir"/*.md; do
        [[ -f "$f" ]] || continue
        while IFS= read -r slug; do
          [[ -n "$slug" ]] || continue
          [[ -f "$mdir/$slug.md" ]] && continue
          norm="${slug//-/_}"
          if [[ "$norm" != "$slug" && -f "$mdir/$norm.md" ]]; then
            found=1
            warn "${f#"$STORE"/}: [[${slug}]] does not resolve — did you mean [[${norm}]]?"
          fi
        done < <(grep -oE '\[\[[^]]+\]\]' "$f" 2>/dev/null | sed -E 's/^\[\[//; s/\]\]$//')
      done
    done
    eval "$saved"
  fi
  [[ "$found" -eq 0 ]] && info "none found"

  return 0
}

cmd_install_hooks() {
  command -v python3 &>/dev/null || die "python3 required for hook merge"
  local srcdir self repoauto dest_self dest_repoauto repo_root="${1:-}"
  srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  self="$srcdir/$(basename "${BASH_SOURCE[0]}")"
  repoauto="$srcdir/repo-autoupdate.sh"
  dest_self="$CLAUDE_HOME/scripts/memory-sync.sh"
  dest_repoauto="$CLAUDE_HOME/scripts/repo-autoupdate.sh"

  step "Installing scripts -> $CLAUDE_HOME/scripts/"
  mkdir -p "$CLAUDE_HOME/scripts"
  [[ "$self" != "$dest_self" ]] && cp "$self" "$dest_self"
  [[ -f "$repoauto" && "$repoauto" != "$dest_repoauto" ]] && cp "$repoauto" "$dest_repoauto"
  chmod +x "$dest_self" "$dest_repoauto" 2>/dev/null || true

  step "Merging SessionStart/SessionEnd hooks into $CLAUDE_HOME/settings.json"
  # Hook commands are written against a LITERAL $HOME (the shell expands it when the hook
  # runs), so a settings.json migrated to another machine or username keeps working instead
  # of failing with "No such file or directory". Only a non-standard CLAUDE_HOME falls back
  # to a baked absolute path.
  local hook_base
  if [[ "$CLAUDE_HOME" == "$HOME/.claude" ]]; then
    hook_base='$HOME/.claude'
  else
    hook_base="$CLAUDE_HOME"
  fi
  CLAUDE_HOME="$CLAUDE_HOME" HOOK_BASE="$hook_base" python3 - <<'PY'
import json, os, re

home = os.environ["CLAUDE_HOME"]
base = os.environ.get("HOOK_BASE") or home
path = os.path.join(home, "settings.json")

import time, shutil
data = {}
if os.path.exists(path):
    try:
        with open(path) as f:
            data = json.load(f)
    except json.JSONDecodeError:
        bak = "%s.bak-%d" % (path, int(time.time()))
        shutil.copy2(path, bak)          # never silently discard real user config
        print("  ! settings.json was not valid JSON — backed up to %s, starting fresh" % bak)
        data = {}
if not isinstance(data, dict):
    data = {}

hooks = data.setdefault("hooks", {})
if not isinstance(hooks, dict):
    hooks = data["hooks"] = {}

def ensure(event, cmd):
    entries = hooks.get(event)
    if not isinstance(entries, list):   # tolerate odd-but-valid JSON shapes
        entries = hooks[event] = []
    for block in entries:
        if not isinstance(block, dict):
            continue
        for h in block.get("hooks", []):
            if isinstance(h, dict) and h.get("command") == cmd:
                return False
    entries.append({"hooks": [{"type": "command", "command": cmd, "timeout": 15}]})
    return True

def upgrade(event, script, arg, newcmd):
    """Rewrite stale variants of this hook — e.g. an absolute home path baked in by an older
    install, possibly carried over from another machine — to newcmd, then drop the duplicate
    blocks a rewrite can create. Only touches commands shaped exactly like ours."""
    entries = hooks.get(event)
    if not isinstance(entries, list):
        return []
    pat = re.compile(r'^bash "[^"]+/scripts/%s" %s$' % (re.escape(script), re.escape(arg)))
    migrated = []
    for block in entries:
        if not isinstance(block, dict):
            continue
        for h in block.get("hooks", []):
            if (isinstance(h, dict) and isinstance(h.get("command"), str)
                    and h["command"] != newcmd and pat.match(h["command"])):
                migrated.append(h["command"])
                h["command"] = newcmd
    if migrated:
        seen = False
        kept = []
        for block in entries:
            hs = block.get("hooks") if isinstance(block, dict) else None
            only_new = bool(hs) and all(
                isinstance(h, dict) and h.get("command") == newcmd for h in hs)
            if only_new:
                if seen:
                    continue
                seen = True
            kept.append(block)
        hooks[event] = kept
    return migrated

added, migrated = [], []
for event, script, arg in (
    ("SessionStart", "memory-sync.sh",     "pull"),
    ("SessionStart", "repo-autoupdate.sh", "check"),
    ("SessionEnd",   "memory-sync.sh",     "push"),
):
    cmd = 'bash "%s/scripts/%s" %s' % (base, script, arg)
    migrated += upgrade(event, script, arg, cmd)
    if ensure(event, cmd):
        added.append("%s->%s %s" % (event, script, arg))

with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")

msg = []
if migrated: msg.append("migrated %d stale hook path(s)" % len(migrated))
if added:    msg.append("added " + ", ".join(added))
print("  " + ("; ".join(msg) if msg else "hooks already present (no change)"))
PY

  # register the repo we were installed from (e.g. imperium) for auto-update
  if [[ -n "$repo_root" && -d "$repo_root/.git" ]]; then
    step "Registering $repo_root for auto-update"
    bash "$dest_repoauto" add "$repo_root" 2>&1 | sed 's/^/  /' || true
  fi
  info "done — restart Claude Code to load the hooks"
}

# print the leading comment block only (stop at the first non-comment line, so code never leaks)
usage() { awk 'NR<2{next} /^#/{sub(/^# ?/,"");print;next}{exit}' "${BASH_SOURCE[0]}"; }

main() {
  local cmd="${1:-help}"; shift || true
  case "$cmd" in
    encode)        encode "$@"; echo ;;
    status)        cmd_status "$@" ;;
    link)          cmd_link "$@" ;;
    adopt)         cmd_adopt "$@" ;;
    pull)          cmd_pull "$@" ;;
    push)          cmd_push "$@" ;;
    doctor)        cmd_doctor "$@" ;;
    install-hooks) cmd_install_hooks "$@" ;;
    help|-h|--help) usage ;;
    *) die "unknown command: $cmd (try 'help')" ;;
  esac
}

main "$@"
