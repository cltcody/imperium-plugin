---
description: Archive completed workspace docs — move finished plans, reports, and reviews out of the active [WORKSPACE_DIR] folders into [WORKSPACE_DIR]/completed/ when a feature ships
argument-hint: [feature-name (default: current branch) | all]
disable-model-invocation: true
---

# Maintain: Archive Workspace Docs

Run this when a feature's code is complete and you're opening its PR. It sweeps the finished
work-product documents out of the active `[WORKSPACE_DIR]` folders into
`[WORKSPACE_DIR]/completed/<subfolder>/`, keeping the active workspace lean while preserving
every plan, report, and review under one archive root that mirrors the source layout.

It **moves, never deletes** — and previews every move before touching a file. It is manual by
design: nothing archives as a side effect of opening a PR.

## Scope

Work-product folders it archives (each mirrored under `completed/`):
`plans/`, `execution-reports/`, `code-reviews/`, `reports/`, `qa/`, `system-reviews/`.

Never touched: `[WORKSPACE_DIR]/reference/` (imported source material),
`[WORKSPACE_DIR]/test-runs/` (historical vetting logs), and anything already under
`[WORKSPACE_DIR]/completed/`.

## Steps

### 1 — Resolve which feature to archive

- Default: derive the feature's kebab-name from the current branch (strip a leading
  `feat/`, `fix/`, `chore/`, `docs/` prefix). `$ARGUMENTS` overrides it.
- `all` → archive every doc in the work-product folders (use when tidying a backlog).
- If the branch is `main`/`develop` or no docs match, confirm an explicit name with the user
  before proceeding — do not guess.

```bash
BRANCH=$(git branch --show-current 2>/dev/null)
# arg wins; else strip ONLY a known type prefix from the branch (not nested segments)
DERIVED=$(printf '%s' "$BRANCH" | sed -E 's#^(feat|fix|chore|docs)/##')
case "$BRANCH" in main|master|develop|"") DERIVED="" ;; esac   # no per-feature default on a base/detached branch
FEATURE="${ARGUMENTS:-$DERIVED}"
# Hard-stop on empty: never let a blank name fall through to `-name "*"` (that would match everything)
[ -n "$FEATURE" ] || { echo "No feature resolved — pass a name explicitly, or 'all' to sweep the workspace."; exit 1; }
echo "Archiving docs for: $FEATURE"
```

`all` is honored only when passed **literally**; an empty/unresolved name never falls back to
sweeping everything.

### 2 — Discover candidate docs

For each work-product subfolder, list files whose name matches the feature kebab-name (or
every file when scope is `all`). Match loosely — a feature's plan, report, and reviews share
its kebab-name but may carry suffixes (`-rca`, `-review`, a date).

```bash
SUBS="plans execution-reports code-reviews reports qa system-reviews"
for sub in $SUBS; do
  dir="[WORKSPACE_DIR]/$sub"
  [ -d "$dir" ] || continue
  if [ "$FEATURE" = "all" ]; then
    find "$dir" -maxdepth 1 -type f -name '*.md'
  else
    find "$dir" -maxdepth 1 -type f -name "*${FEATURE}*"
  fi
done
```

### 3 — Preview (dry-run)

Print the planned moves as `source → [WORKSPACE_DIR]/completed/<sub>/<file>` and **stop for
confirmation**. No file moves until the user approves. If nothing matched, report that and
suggest re-running with an explicit name or `all` — do not fall back to archiving everything.

### 4 — Archive

On approval, create each destination dir and move the files, preserving git history when a
file is tracked:

```bash
# for each approved source file:
sub=$(basename "$(dirname "$src")")
dest_dir="[WORKSPACE_DIR]/completed/$sub"
mkdir -p "$dest_dir"

# Never overwrite: derive a non-colliding destination name (foo.md → foo-2.md → foo-3.md …)
base=$(basename "$src"); name="${base%.*}"; ext="${base##*.}"
target="$dest_dir/$base"; n=2
while [ -e "$target" ]; do target="$dest_dir/${name}-${n}.${ext}"; n=$((n+1)); done

if git ls-files --error-unmatch "$src" >/dev/null 2>&1; then
  git mv "$src" "$target"        # tracked — keep history
else
  mv "$src" "$target"            # untracked — plain move
fi
[ "$target" = "$dest_dir/$base" ] || echo "collision: $base → $(basename "$target")"
```

The loop computes the target before moving, so an existing archived doc is never clobbered
(`mv`) nor does the move abort (`git mv` to an existing path) — collisions are renamed and
reported in Step 5.

### 5 — Report

```
Workspace Archive — <feature | all> (<date>)
────────────────────────────────────────────
Moved 4 docs → [WORKSPACE_DIR]/completed/

  plans/             1  →  completed/plans/
  execution-reports/ 1  →  completed/execution-reports/
  code-reviews/      2  →  completed/code-reviews/

  Skipped: nothing matched in qa/, reports/, system-reviews/
  Renamed: code-reviews/foo.md → foo-2.md (collision)
```

If scope resolved to nothing, report `No matching docs — active workspace already clean.`

## Output

A tidied `[WORKSPACE_DIR]/` with the feature's finished docs relocated to
`[WORKSPACE_DIR]/completed/<sub>/`, history preserved for tracked files, plus a summary of
exactly what moved and any collisions handled.

## Quality checklist

- [ ] Scope resolved (feature name or `all`) and confirmed when the branch is ambiguous
- [ ] Every move previewed before any file was touched
- [ ] Tracked files moved with `git mv` (history preserved); untracked with `mv`
- [ ] `reference/`, `test-runs/`, and `completed/` left untouched
- [ ] No file overwritten — collisions suffixed and reported

## Handoff

Run at PR time — after `/cc:verify:execution-report`, alongside or just before
`/cc:github:pr`. Pair with `/cc:maintain:audit` to keep the plugin itself clean.
