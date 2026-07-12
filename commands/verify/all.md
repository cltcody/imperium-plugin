---
description: One-shot "run everything" verification orchestrator — sequences the verify:* gate and reviews, then reports a single scorecard with a GO / FIX FIRST verdict
argument-hint: "[--quick (default) | --full | --release]"
allowed-tools: Read, Grep, Bash, Agent, SlashCommand
---

# Verify: All

Run the whole verification sweep in one shot and report a single scorecard. This is a
**thin orchestrator, not a reimplementation** — every check below is an existing
`/cc:verify:*` (or `/cc:release:*`) command invoked via the `SlashCommand` tool; it only
sequences, parallelizes, and aggregates.

**Relationship to `/cc:release:validate`:** `/cc:release:validate` *is* the resolved gate for
a release (tests, types, lint, build, local server, container). `/cc:verify:all` is gate +
reviews: at `--release` tier its gate resolves to `/cc:release:validate` (a strict superset of
`/cc:verify:run`), then layers reviews on top. Use `/cc:release:validate` alone for just the
gate; use `/cc:verify:all` for the gate plus a one-shot review sweep with a single verdict.

## Tiers

| Tier | Gate (fail-fast) | Reviews (parallel once gate is green) | Scope |
|------|-------------------|----------------------------------------|-------|
| `--quick` (default) | `/cc:verify:run` | `/cc:verify:code` | diff (uncommitted) — the pre-commit sweep |
| `--full` | `/cc:verify:run` | `/cc:verify:code`, `/cc:verify:security`, `/cc:verify:dependencies`, `/cc:verify:coverage`, `/cc:verify:design` | diff |
| `--release` | `/cc:release:validate` (supersedes `/cc:verify:run` — see above) | same 5 reviews + `/cc:verify:pr` | branch (vs `main`) |

E2E is deliberately outside every tier — `/cc:verify:e2e` is opt-in (STACK.md `e2e:*`) and runs separately, after all source edits land.

## Steps

### 1. Resolve the tier

Parse `$ARGUMENTS` for `--quick`, `--full`, or `--release`; default to `--quick` if none or
unrecognized. State the resolved tier and scope before running anything.

### 2. Run the gate first — fail-fast

Invoke the tier's gate via `SlashCommand`:
- `--quick` / `--full` → `/cc:verify:run`
- `--release` → `/cc:release:validate`

**This is the one hard stop in this command.** If the gate comes back RED/FAIL:
- Do **not** run any review — reviewing code behind a broken build wastes the reviewer's
  time and the user's.
- Report a **partial scorecard**: the gate row only, with its verdict and top failure.
- Route to `/cc:verify:debug` via `SlashCommand` (chain) or suggest it (solo) — never attempt
  a fix here.
- Stop. The overall verdict is `FIX FIRST`.

Only proceed to step 3 if the gate is GREEN/PASS.

### 3. Run the tier's reviews — in parallel where there's more than one

The reviews in a tier are independent of each other — run them concurrently instead of
burning wall-clock time in series.

- **`--quick`** — only one review (`/cc:verify:code`, default diff scope). Invoke it directly
  via `SlashCommand`; no parallelization needed for a single check.
- **`--full`** — 5 independent reviews. Dispatch them as **parallel `Agent` tool calls in a
  single message** (per the Agent tool's own guidance: multiple independent calls sent
  together run concurrently). Each agent's job is to run exactly one command via
  `SlashCommand` and report back compactly — for example:
  - Agent 1: "Invoke `/cc:verify:code` (default diff scope) via the SlashCommand tool. Report
    back in under 150 words: verdict (CLEAN or FINDINGS with counts by severity) and the
    single highest-severity finding with its `file:line`, or 'none' if clean."
  - Agent 2: same shape for `/cc:verify:security` (diff scope).
  - Agent 3: same shape for `/cc:verify:dependencies`.
  - Agent 4: same shape for `/cc:verify:coverage`.
  - Agent 5: same shape for `/cc:verify:design` (diff scope) — note it is relevance-gated, so
    "CLEAN" here often means "all heads N/A (no UX/AI/systems surface in the diff)".

  This works because `/cc:verify:code`, `/cc:verify:security`, and `/cc:verify:design` already
  delegate their heavy lifting to subagents internally — running them as sibling `Agent` calls
  costs nothing extra in depth and cuts wall-clock time roughly 5x.
- **`--release`** — the same 5 reviews, plus `/cc:verify:pr`, dispatched the same way (6
  parallel `Agent` calls). Pass `/cc:verify:code` the `branch` argument so it diffs against
  `main` instead of just uncommitted work. `/cc:verify:security`'s diff scope already unions
  uncommitted changes with `git diff main...HEAD`, so it needs no scope change to cover the
  branch. `/cc:verify:dependencies` and `/cc:verify:coverage` are project-wide by nature and
  take no scope argument at any tier. `/cc:verify:pr` reviews the whole branch against `main`
  by default — no argument needed.

Use `subagent_type: general-purpose` for these dispatches (full tool access, including
`SlashCommand`). Each agent should return a compact verdict, not the full report — the raw
report already lives wherever the invoked command writes it
(`${user_config.workspace_dir}/code-reviews/`, `${user_config.workspace_dir}/reports/security/`,
`${user_config.workspace_dir}/reports/dependencies-*.md`); this command aggregates, it doesn't duplicate.

### 4. Aggregate the scorecard

Collect every check that ran (gate + reviews) into one table: check, scope, verdict, top
finding. Compute the overall verdict:

- **GO** — gate GREEN/PASS and every review is clean (no CRITICAL/HIGH findings, no CVEs at
  HIGH+, no `NEEDS CHANGES` from `/cc:verify:pr`). Coverage gaps below target are advisory,
  not a pass/fail gate — reported but don't alone block GO.
- **FIX FIRST** — gate RED (already stopped at step 2), or any review surfaces a
  CRITICAL/HIGH finding, a CRITICAL/HIGH dependency CVE, or `/cc:verify:pr` returns
  `NEEDS CHANGES`.

Never soften a CRITICAL/HIGH finding into GO.

## Output

```
VERIFY: ALL — <tier> (scope: <diff|branch>)
────────────────────────────────────────────
CHECK                 SCOPE     VERDICT                TOP FINDING
verify:run            project   ✅ GREEN                —
verify:code           diff      ⚠️  FINDINGS (2 MED)     src/foo.py:42 — missing null check
verify:security       diff      ✅ PASS                 —
verify:dependencies   project   ❌ 1 CRITICAL CVE        requests==2.1.0 — CVE-2023-XXXXX
verify:coverage       project   ⚠️  72% (target 80%)     src/bar.py — 45%, missing error paths

Overall: 🔴 FIX FIRST — verify:dependencies (1 CRITICAL CVE) blocks
         🟢 GO — ready for /cc:release:commit
```

Adapt rows to whatever checks the resolved tier ran; a `--quick` run has only two rows.

## Quality checklist

- [ ] Tier resolved and stated before anything runs (default `--quick`)
- [ ] Gate run first; on RED, stopped immediately with no reviews run and a partial scorecard
- [ ] `--release` tier resolves its gate to `/cc:release:validate`, not a redundant
      `/cc:verify:run` + `/cc:release:validate` double-run
- [ ] Independent reviews (2+) dispatched as parallel `Agent` calls, not run one at a time
- [ ] Scorecard lists every check that actually ran, with scope and top finding
- [ ] Overall verdict is exactly `GO` or `FIX FIRST` — never invented, never softened past a
      CRITICAL/HIGH finding
- [ ] This command itself never edits code and never commits — findings route to
      `/cc:verify:code-review-fix`, gate failures route to `/cc:verify:debug`

## Handoff

**Chain:** on `GO`, invoke `/cc:release:commit` next. On `FIX FIRST` from a gate failure,
invoke `/cc:verify:debug`. On `FIX FIRST` from a review finding, invoke
`/cc:verify:code-review-fix` with the relevant report path, then re-run `/cc:verify:all` at
the same tier to confirm.

**Solo:** report the scorecard and verdict. On `GO`, suggest `/cc:release:commit` (or
`/cc:release:deploy` after a `--release` run). On `FIX FIRST`, point at
`/cc:verify:code-review-fix` for findings or `/cc:verify:debug` for gate failures — this
command never fixes anything itself.

**Abort rules:** a RED/FAIL gate stops the chain before any review runs. Any CRITICAL finding
from a parallel review forces `FIX FIRST` regardless of the other reviews. If a review's
`Agent` dispatch fails or times out, report that check as `⚠️ NOT RUN` — never mark it clean
by omission.
