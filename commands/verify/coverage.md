---
description: Analyse test coverage, find gaps, and generate targeted suggestions for missing tests
allowed-tools: Read, Grep, Glob, Bash, Agent, SlashCommand
---

# Test Coverage

Analyse test coverage, find gaps, and generate targeted suggestions for missing tests. This
is **stack-agnostic**: the concrete coverage and test commands come from the project's
`STACK.md`, not from this file.

## Steps

### 1. Resolve the stack

Read the project's `STACK.md` and resolve commands per
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. This command runs the `coverage`
step **for each component** from that component's `working_dir`; if a component does not map
`coverage`, fall back to its `test` step (coverage numbers will be unavailable for that
component — note it).

Skip any component that maps neither `coverage` nor `test` (not an error). If there is no
`STACK.md`, auto-detect once from project markers and recommend the user run
`/cc:setup:stack` to persist a manifest.

### 2. Run the coverage report

For each component, run its `coverage` step (falling back to `test`) from its `working_dir`:

```
coverage  → test (fallback)
```

A coverage run typically produces:
- Terminal output with line-level gaps
- A visual report (e.g. an HTML coverage directory) for inspection, if the tool emits one

If the run fails, stop — see **Abort rules** below.

### 3. Find untested files

From the coverage report, identify:
- Files with 0% coverage
- Files below the project's coverage target (default 80%)

Read the terminal/summary output for per-file percentages rather than assuming a format —
different coverage tools report differently.

### 4. Find untested functions

Cross-reference source functions against test functions using `Grep`, scoped to each
component's `working_dir` and source layout. Find:
- All exported/public functions in the source tree
- All test functions in the test tree

Map each source function to a corresponding test. Flag any source function with no test.
Adapt the patterns to the component's language (function/method declaration syntax, test
naming convention, file extensions) — do not assume a single language.

### 5. Assess quality of existing tests

Use `Read` on each test file. Check:
- Are tests only asserting happy paths?
- Are failure / error cases tested (invalid input, not-found, unauthorized, conflict)?
- Are integration tests marked or separated from unit tests, per the project's convention?
- Are unit tests actually unit (dependencies mocked) or secretly integration?

### 6. Generate missing test suggestions

For each gap found, produce a specific test stub in the component's own test style — mirror
the existing tests' framework, assertion library, fixtures, and naming convention. Cover the
gap concretely (e.g. a missing error-path test and a missing not-found test for an
endpoint), not just a placeholder.

## Output

A coverage report in this format, plus concrete test stubs for every gap. Adapt the rows to
whatever components and source layout the project's `STACK.md` actually defines:

```
COVERAGE REPORT — <stack> (from STACK.md)
─────────────────────────────────────────
backend  (uv)   overall XX%  (target: 80%+)
frontend (npm)  coverage unmapped — ran test only (no %)

Files below target:
  <component>/<path>   45%  — missing: error paths, edge cases
  <component>/<path>   60%  — missing: not-found, invalid-input responses

Untested functions:
  - <component>/<path>:update_item  (no test at all)
  - <component>/<path>:delete_item  (no test at all)

Suggested tests to write:  <N>
Use the tester agent (${user_config.workspace_dir}/agents/tester.md) or write manually in the component's test dir.
```

## Quality checklist

- [ ] Coverage measured per component against the 80%+ target (or `test`-only noted where
      `coverage` is unmapped)
- [ ] Every file below target listed with what's missing
- [ ] Every untested source function flagged
- [ ] Failure / error cases checked, not just happy paths
- [ ] Each gap has a concrete, runnable test stub suggestion in the component's own style

## Handoff

**Chain:** If gaps are found, write the missing tests (spawn a tester agent using `${user_config.workspace_dir}/agents/tester.md`, or run `/cc:plan:task` for a test-writing task), then invoke `/cc:verify:run` to confirm the new tests pass.

**Solo:** Report the coverage summary and suggested stubs; suggest writing the tests and re-running `/cc:verify:coverage` to confirm the target is met.

**Abort rules:** If the coverage run itself fails (broken tests, missing coverage tooling), stop the analysis and route to `/cc:verify:debug` first — coverage numbers from a failing suite are meaningless.
