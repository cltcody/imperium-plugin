---
description: Archive completed workspace docs — move finished plans, reports, and reviews out of the active [WORKSPACE_DIR] folders into [WORKSPACE_DIR]/completed/ when a feature ships, or run the `sweep` mode to auto-archive every Status-closed, PR-merged plan into [WORKSPACE_DIR]/archive/<year>/
argument-hint: [feature-name (default: current branch) | all | sweep]
disable-model-invocation: true
size-budget: exempt — three-mode lifecycle (feature/all/sweep) with archive procedure
---

# Maintain: Archive Workspace Docs

Run this when a feature's code is complete and you're opening its PR. It sweeps the finished
work-product documents out of the active `[WORKSPACE_DIR]` folders into
`[WORKSPACE_DIR]/completed/<subfolder>/`, keeping the active workspace lean while preserving
every plan, report, and review under one archive root that mirrors the source layout.

It **moves, never deletes** — and previews every move before touching a file. It is manual by
design: nothing archives as a side effect of opening a PR.

`$ARGUMENTS == sweep` runs a different, automated mode instead — see **Sweep mode** below. It
is the periodic housekeeping pass (ADR-002 D3); the per-feature flow above stays for archiving
a single feature's docs the moment its PR opens.

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

## Sweep mode (`$ARGUMENTS == sweep`) — ADR-002 D3

The periodic housekeeping pass. Unlike the per-feature flow above, it runs unattended over the
whole workspace and only moves an artifact when **both** signals agree: the plan is
Status-closed **and** its work is merged. Convention: `[WORKSPACE_DIR]/archive/<year>/<sub>/`,
preserving the subdir it came from (`archive/2026/plans/`, `archive/2026/code-reviews/`,
`archive/2026/execution-reports/`, `archive/2026/system-reviews/`) — `<year>` is the current
year at sweep time. Never touches `reference/`, `test-runs/`, or `completed/`.

### S1 — Find closed plans

A plan is **Status-closed** when its first 5 lines carry `implemented` / `superseded` / `done`
— either the bold form (`**implemented**`) or the status-line form (`Status: implemented`,
asterisks stripped before matching) — the exact convention `global/hooks/piv_state.py`'s
`_plan_done()` machine-reads. Scan `[WORKSPACE_DIR]/plans/*.md` only (top-level — `archive/`
is never re-scanned).

### S2 — Confirm each closed plan's work is merged

For each Status-closed plan, in order:

1. **Branch/PR named in the plan** (header or body mentions a `#<number>` PR or an explicit
   branch name) → `gh pr list --state merged --search "<number-or-branch>"` (or
   `gh pr view <number> --json state,mergedAt`). Merged if the PR shows as merged.
2. **No PR named, but commits plausibly reference the plan** → `git log --oneline --all
   --grep="<plan-kebab-name>"` on `main`; treat as merged only when a matching commit is
   reachable from `main`.
3. **Neither signal resolves it** → do not guess. Leave the plan in place, list it under
   "Skipped (ambiguous)" in the report, and ask the user to confirm merge status if they want
   it archived this run.

### S3 — Move the plan and its same-named artifacts

For each plan confirmed closed-and-merged:

```bash
YEAR=$(date +%Y)
dest="[WORKSPACE_DIR]/archive/$YEAR/plans"
mkdir -p "$dest"
git mv "[WORKSPACE_DIR]/plans/<name>.md" "$dest/<name>.md"

# Same kebab name in code-reviews/, execution-reports/, system-reviews/ archives alongside it —
# only because the plan it belongs to just archived, never on its own.
for sub in code-reviews execution-reports system-reviews; do
  src="[WORKSPACE_DIR]/$sub/<name>.md"
  [ -f "$src" ] || continue
  mkdir -p "[WORKSPACE_DIR]/archive/$YEAR/$sub"
  git mv "$src" "[WORKSPACE_DIR]/archive/$YEAR/$sub/<name>.md"
done
```

Skip (do not archive) a `code-reviews/` / `execution-reports/` / `system-reviews/` file whose
same-named plan is still live or ambiguous — those folders only follow an archived plan, they
are never swept independently.

### S4 — Report

Print a table, not prose:

```
Sweep — [WORKSPACE_DIR] (<date>)
─────────────────────────────────────────────
Moved 23 files → [WORKSPACE_DIR]/archive/2026/

  plan                              status        merged        →  archive/2026/plans/
  ────────────────────────────────  ────────────  ────────────  ──────────────────────
  piv-state-staleness               implemented   PR #34        plans/, code-reviews/, execution-reports/
  fold-global-commands-into-cc      implemented   PR #21        plans/
  ...

  Skipped (ambiguous): domain-trade-radar-research-valuation.md — no PR/branch named, no
    matching commit on main; confirm merge status to archive.
  Left live: harness-hardening-backlog.md (Status: in-progress)
```

## Handoff

Run at PR time — after `/cc:verify:execution-report`, alongside or just before
`/cc:github:pr`. Pair with `/cc:maintain:audit` to keep the plugin itself clean. Run `sweep`
periodically (e.g. from `/cc:verify:system` or a standalone housekeeping pass) — it is safe to
re-run; already-archived files are never re-scanned.
