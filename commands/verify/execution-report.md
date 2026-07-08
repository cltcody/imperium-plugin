---
description: Write the execution report — plan vs actual, classified divergences, validation results — before the commit gate
argument-hint: [plan path — defaults to newest in ${user_config.workspace_dir}/plans/]
---

# Execution Report

Compare what the plan said against what was actually built, classify every divergence, and record validation results. This is the last artifact before the commit gate, and the input `/cc:verify:system` needs to improve the process later. Honesty over polish: an accurate report of a messy implementation beats a clean report of fiction.

## Steps

1. **Load the plan.** Use `$ARGUMENTS` or the most recently modified file in `${user_config.workspace_dir}/plans/`. Extract what was promised: features, files, architecture, validation criteria.
2. **Gather the actuals** from the working tree, not memory:
   ```
   git status
   git diff HEAD --stat
   git diff HEAD --numstat
   git ls-files --others --exclude-standard
   ```
   List files added/modified/deleted and total lines changed.
3. **Collect validation results** from the `/cc:verify:run` and `/cc:verify:code` runs in this session — the `test`, `typecheck`, `lint`, `format:check`, `build`, and `smoke` step outcomes **per component**, plus the review verdict and any fix loops used. Resolve which steps apply from the project's `STACK.md` per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`; skip steps a component does not map. No `STACK.md` → auto-detect once and recommend `/cc:setup:stack`. If validation hasn't run, run `/cc:verify:run` now — a report without validation results is incomplete.
4. **Walk the plan item by item** and mark each: ✅ done as planned / 🔀 diverged / ⏭️ skipped.
5. **Classify every divergence:**
   - **Good ✅ (justified by discovery)** — the plan assumed something untrue of the codebase; a better existing pattern was found; a real security/performance issue forced a change.
   - **Bad ❌ (shortcut)** — ignored an explicit constraint, invented new architecture instead of following existing patterns, took a shortcut creating tech debt, misread the requirement.
   For each: planned vs actual, reason, classification. Skipped items get a stated reason — never silence.
6. **Optional metrics.** Where useful for reviewers, add quick numbers. Take file stats
   from git, and resolve any `coverage`/`test` step from `STACK.md` per
   `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` — run each from its
   component's `working_dir`; skip components that don't map the step:
   ```bash
   git diff HEAD --stat   # files changed
   ```
   - Test lines added: count added lines in the diff under the component's test path
     (read it from the project's layout — do not assume a language-specific directory).
   - Coverage before/after: run the component's `coverage` step (from `STACK.md`) when
     mapped, and report the totals.

   Report files changed, tests added, and coverage before/after when available.
7. **Reflect on the process:** what went smoothly, what was hard, and what should improve next time (plan template, command instructions, CLAUDE.md additions).
8. **Save** to `${user_config.workspace_dir}/execution-reports/<plan-name>.md` (same kebab name as the plan file).

## Output

`${user_config.workspace_dir}/execution-reports/<plan-name>.md`:

```markdown
# Execution Report: <Feature>
**Plan:** ${user_config.workspace_dir}/plans/<name>.md | **Date:** YYYY-MM-DD

## Files Changed          ← added / modified / deleted, +A −D
## Validation Results     ← per component (from STACK.md): smoke / test / typecheck / lint / format:check / build outcomes (pass/fail counts), review verdict, fix loops used; skip unmapped steps
## Plan vs Actual         ← per item: done / diverged / skipped
## Divergences            ← each: planned, actual, reason, Good ✅ / Bad ❌
## Skipped Items          ← what and why
## Metrics (optional)     ← files changed, tests added, coverage before/after
## What Went Well / Challenges
## Recommendations        ← plan, command, and CLAUDE.md improvements
```

## Quality checklist

- [ ] Every plan item accounted for — done, diverged, or skipped with reason
- [ ] Every divergence classified Good/Bad with the actual reason, not a rationalization
- [ ] Validation results are from real runs in this session, not assumed
- [ ] File stats taken from git, not estimated
- [ ] Saved to `${user_config.workspace_dir}/execution-reports/<plan-name>.md`

## Handoff

**Chain:** after saving the report, immediately invoke `/cc:release:commit` — do not present a separate approval request here. `/cc:release:commit` is the chain's **single approval gate**; it uses this report as the work-summary input for that gate.
**Solo:** suggest the user review the report, then run `/cc:release:commit` when satisfied.
**Abort rules:** if validation is RED or any Bad ❌ divergence touches a plan constraint marked critical, do NOT invoke `/cc:release:commit` — stop the chain, state the problem prominently, and recommend `/cc:verify:code-review-fix` or `/cc:verify:debug`. Never present a RED state as ready to commit.
