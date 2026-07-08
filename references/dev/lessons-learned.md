# Lessons Learned — Transferable Engineering Rules

> Harvested 2026-07 from `anger-app-source/LESSONS.md` (~60 dated, incident-driven
> rules earned 2026-03 → 2026-07). Only project-agnostic lessons are generalized here;
> that app's React-Native/Expo-specific rules stay in its own LESSONS.md. This file is
> the cross-project layer: `/cc:prime` reads each project's `LESSONS.md`; this
> reference holds the rules that apply everywhere. Dates mark when the lesson was
> earned, not when it was harvested.

---

## 1. Git & parallel-work hygiene

- **A branch name does not isolate uncommitted work.** A feature branch with zero
  commits has its tip at `main`; its "changes" live only in the shared working tree,
  and switching branches carries the dirty tree (and all untracked files) along. Two
  independent uncommitted change-sets cannot coexist in one working tree. Before
  starting a second parallel work-stream (second agent, or your own context switch),
  the first stream's work must be **committed to its branch or in a separate git
  worktree**. A commit is not a merge — committing preserves any pre-merge review
  gate. (2026-07-04)
- **Choose worktree isolation by file overlap.** Parallel agents in separate worktrees
  are clean only when the tasks share zero files; if they touch the same files (shared
  components, locale JSONs, config), worktrees just convert the conflict into manual
  copy-back work. Shared files → one tree, sequential access to the shared files.
  Zero overlap → worktrees. (2026-03-29)
- **Stale-branch merge discipline.** A branch behind `main` by one or more merged
  features can silently clobber the newer feature at merge time if both sides touched
  shared files. Detect: `git merge-base --is-ancestor <other-feature-commit> HEAD` —
  "not an ancestor" while the commit is in main means the branch is stale. A
  `git diff origin/main..HEAD` showing the other feature's files as *deletions* is a
  staleness artifact, not a real change. Fix BEFORE review: `git merge origin/main` on
  the branch, resolve locally (purely-additive conflicts, e.g. locale keys: keep both
  sides). Verify after: `git diff origin/main HEAD --name-status | grep <other-feature>`
  is empty, and the full test suite count *rises* as the other feature's suites return.
  (2026-06-20)
- **Branch → PR → merge, always** — hotfixes and one-liners included. Direct pushes to
  main bypass review and traceability. (2026-03-24)
- **Check CI on main after every merge.** Red main = create a hotfix branch immediately,
  before merging anything else. (2026-04-03)
- **Commit the manifest and its lockfile together** (`package.json` +
  `package-lock.json`, or the ecosystem's equivalent) — a mismatched pair fails clean
  installs in CI within seconds, with a cryptic error. (2026-05-13)
- **Commit plans/specs with the feature branch they produced** — the planning artifact
  is the audit trail of the decisions in the diff. (2026-03-25)

## 2. CI & test-runner discipline

- **Bound test-worker memory; reproduce CI's constraints locally.** A heavy module
  graph (bundled assets, big fixtures) can OOM CI workers (exit 134, "heap limit
  Allocation failed") while passing on a 16 GB+ dev box. The crash is not an assertion
  failure, and the log noise above it is a red herring. Fix at the runner level (jest:
  `maxWorkers: '50%'` + `workerIdleMemoryLimit: '512MB'` so workers recycle).
  Reproduce locally by imposing CI's limit: `node --max-old-space-size=2048 <runner>`.
  General form: a CI-only failure means *replicate CI's constraint locally* — don't
  debug the assertions. (2026-06-20)
- **Setting `process.env.TZ` at the top of a test file is too late.** The runner's own
  bootstrap constructs `Date`/`Intl` before your file's first line, and V8/ICU caches
  timezone resolution on first use. If a test genuinely needs a different timezone, set
  it at the process boundary (`TZ=Europe/Berlin <runner> ...` in the npm/CI script) or
  use a library that patches `Date`/`Intl` prototypes — or better, write TZ-agnostic
  tests: construct dates from local components (`new Date(y, m, d)`), and assert on
  the code path itself (e.g. count `'localtime'` occurrences in generated SQL) instead
  of on a specific zone's calendar. Verify the *mechanism*, not the symptom: prove the
  shell-level env var works before concluding your in-file recipe was mis-ordered.
  (2026-07-05)
- **Encode lessons as invariant-based gates, and run a negative control.** A regression
  gate should check the invariant (e.g. "no value re-export in this barrel reaches a
  module that `require`s a bundled asset"), never a hardcoded name list that rots.
  Then deliberately break it once and watch it go red — an untested gate is a
  decoration. Regex gates must match real syntax, not prose: `require(\s*['"]`, not
  `/require\(/`, or the gate trips on its own doc comments. (2026-07-04)
- **Green-baseline known failures.** When a new gate discovers pre-existing bugs,
  don't silently pass them and don't block CI: record them in a checked-in baseline
  file. CI stays green today, but fails the moment someone fixes one without updating
  the baseline — or introduces a new instance. A gate's first real run finding real
  bugs is the pattern working, not a reason to loosen it. (2026-07-03)
- **When extending an audit/check to a new surface, the measurement half ports for
  free; the pass/fail model does not.** Each surface's "window" must be re-derived
  from that surface's actual cutoff/selection code, never assumed by analogy — the
  analogous model is sometimes silently right by luck, which is worse than wrong.
  (2026-07-03)

## 3. Module-graph & import hygiene

- **Barrels couple every consumer to the heaviest transitive import.** If an index
  re-exports asset-carrying or side-effectful modules, importing the lightweight
  service drags the whole graph into every test worker and into app startup. Split:
  the barrel keeps the service and all `export type` re-exports (type re-exports are
  elided at runtime — they cost nothing), heavy *value* exports move to direct
  deep-path imports. The type-checker makes every missed value-import loud, so zero
  errors after the rewrite proves the consumer inventory is complete. (2026-07-04)
- **Check for tooling coupled to file-naming conventions before renaming/moving.** A
  build script that scans `*Registry.ts` will silently stop tracking a file renamed
  to `*Source.ts` — grep the scripts for glob patterns before restructuring, and
  verify the tool's output count afterwards. (2026-07-04)

## 4. Resource lifecycle & concurrency

- **Release long-running resources on every deactivation edge, not just destruction.**
  Audio, timers, subscriptions, polling loops owned by a screen/component must stop on
  *navigation-away/blur* and on *app-background*, not only on unmount — UI frameworks
  keep inactive screens mounted, so an unmount-only cleanup never fires, a backgrounded
  instance keeps consuming the shared resource, and a second instance can orphan it.
  Gate BOTH the resource and any timer driving it on the same background/blur flag.
  (2026-06-17, 2026-06-20)
- **Don't trust synchronous reads of async state flags.** When several effects in the
  same tick check "is the resource busy?" via a flag the resource sets asynchronously
  (e.g. `player.playing` after `play()`), they all see `false` and race. Track a
  timestamp at acquisition and treat "acquired within the last N ms" as busy.
  (2026-04-04)

## 5. Side-effect safety

- **A blanket env/config loader can turn a "read-only" run into an outward action.**
  A loader that ingests *every* key from an env file will pick up credentials that
  gate side effects (issue filing, publishing, billing) the current action never
  asked for. Load only the keys the current action needs; make side-effecting paths
  strictly opt-in flags that provision their own credentials. And never declare a run
  "safe"/"read-only" until you have enumerated what it will consume — key names only:
  `sed -E 's/=.*/=***/' .env.file`. The token that turns a dry run wet is often
  already sitting in a gitignored file. (2026-07-01)
- **Mark dev shortcuts and sweep before commit.** Shortened timers, stub data, forced
  flags used for QA get a `// TODO: REMOVE - dev shortcut` marker at creation time,
  and a pre-commit search for that marker. (2026-04-03)

## 6. Debugging discipline

- **Log the controlling value FIRST.** For any "component/state appears wrong" bug,
  one log of the value that controls the behavior beats rounds of speculative logic
  rewrites — the logic is often correct and the input is not what you assume.
  (2026-05-08)
- **Check the arithmetic before assuming a logic bug.** An element that "won't hide"
  may simply have an offset smaller than `position + size`. Do the math on paper
  before touching state machines. (2026-05-08)
- **A clean revert that still fails exonerates your diff.** Don't trust the first
  plausible cause. If reverting to a previously-green state — dependencies, lockfile,
  caches, all layers verified — still fails identically, the cause is environmental
  (toolchain, compiler, host update), not the repo. Stop changing the repo; check
  toolchain versions against the dependency's supported range. (2026-06-25)
- **Interpreted-layer CI cannot validate compiled-layer changes.** Type-check, lint,
  and unit tests all green does NOT mean a dependency bump touching a native/compiled
  layer works — only an actual build of that layer does. Any dep change with a
  native/compiled component is incomplete until the full rebuild chain has run.
  (2026-06-25)

## 7. Planning & QA discipline

- **A fallback must not systematically dominate the primary signal.** When a ranking
  or comparison falls back to a second data source (fs mtime behind git commit time,
  a default behind a computed value), check whether the fallback lands on the *winning*
  side of every real comparison — mtime in a fresh worktree is checkout time ≈ now and
  beats all history, turning "degraded" into "deterministically wrong." Clamp fallbacks
  below the primary signal's range. Same trap in tests: fixtures must place the
  fallback value on the dominating side, or the coverage is vacuous — a fixture whose
  scrambled mtimes were *older* than the commit dates would have passed with the fix
  disabled. (2026-07-07)
- **"Registered" ≠ "reachable."** That a route/feature/tool is registered in a catalog
  proves it *can* be navigated to, not that a visible affordance exists on the screen
  a plan claims. Before writing "open X from Y" into a plan or QA checklist, trace the
  *render/selection* logic that decides what is actually shown. And wrong facts
  propagate: QA checklists seeded from plan sections inherit the plan's errors — fix
  the plan first, then everything downstream. (2026-06-28)
- **Grep the whole codebase before declaring anything unimplemented or dead** —
  i18n keys, config flags, exports. "Not used in the file under review" is not
  evidence; building a duplicate of something that exists is the usual cost.
  (2026-04-04)
- **A pre-existing field that looks like the data you need is not evidence it is
  correct.** Boolean-ish flags (`premium`, `isFree`, `enabled`) silently drift from
  the real product decision; both the wrong flag and the right one type-check and
  render. Before wiring authority to an existing field, verify its values against the
  ratified decision line-by-line — then designate ONE source of truth and make every
  consumer read it. (2026-07-03)
- **Read the semantics, not the labels, before bulk mutations in external systems.**
  Column/field names lie; query their descriptions first. And know the mutation's
  replacement semantics — an "update options" call that requires the FULL array
  deletes whatever you omit. (2026-05-26)
- **Right-size the planning artifact.** Plan-only: bounded fixes, behavior tweaks,
  data updates, UI polish. PRD-first: open UX/design questions, external/stakeholder
  sign-off required, 4+ screens or a new data layer, or architectural/AI decisions
  whose reasoning must outlast the conversation. (2026-04-19)

## 8. Keeping a LESSONS.md (meta)

- **Format** (proven over 4 months in anger-app):
  `- **[tag]: one-line rule** (YYYY-MM-DD) - incident, root cause, fix, generalized rule.`
  under three sections: `Critical Rules (cost us real debugging time)`,
  `Patterns That Worked`, `Package Gotchas`.
- **Write it at the moment of the burn**, with the mechanism verified — a lesson that
  records only the symptom teaches the wrong rule.
- **It gets read every session** — `/cc:prime` step 2 reads the project's LESSONS.md;
  a lesson not in the file does not exist.
- **Promote upward**: when a project lesson turns out to be project-agnostic, move its
  generalized form into this reference and leave the project-specific residue (exact
  files, exact APIs) in the project's own LESSONS.md.
