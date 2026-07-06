---
description: Systematically diagnose a failing test or error — reproduce, classify, hypothesize, fix the root cause with a regression test
argument-hint: [test path, error message, or description of the failure]
---

# Debug a Failing Test or Error

Diagnose a failing test, error, or unexpected behaviour through a disciplined loop: reproduce, classify, isolate, hypothesize, verify, then apply the minimal fix to the root cause. Use this when `/cc:verify:run` fails repeatedly or any error resists a quick fix.

This command is **stack-agnostic**: the concrete commands come from the project's `STACK.md`, not from this file. Resolve steps per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` — read `STACK.md` at the project root and run each component's mapped command from its `working_dir`. Skip any step a component does not map (not an error). If there is no `STACK.md`, auto-detect once from project markers and recommend the user run `/cc:setup:stack` to persist a manifest.

## Steps

1. **Reproduce — capture the exact error.** Run the failing thing with maximum signal. Use the `test` step for the failing component (the manifest's command already carries that stack's verbose/traceback flags), and pull runtime errors from however the project surfaces logs:
   - `test` step for the affected component, scoped to the failing test/path with full output
   - runtime logs from the running app (container logs, dev-server output, or log files — whatever this stack uses)

   Never work from a paraphrased error — read the full output, untruncated. If you cannot reproduce it, stop and gather more context before theorizing.

2. **Classify the error** before attempting anything — the class tells you where to look. The signals and locations below are illustrative; map them to the project's actual language and framework:

   | Type | Signals | Where to look |
   |------|---------|---------------|
   | Type error | `typecheck` output, attribute/property errors | Function signatures, type/schema definitions |
   | Import/module error | "module not found", unresolved import | Dependency manifest, package init/index files |
   | DB error | DB driver / ORM in traceback | Model definitions, migration state, session/connection usage |
   | Validation error | request rejected, validation/schema error | Request/response schema, payload shape |
   | Config/env error | settings failures at startup | `.env`, config module |
   | Test setup error | missing fixture/helper, test harness in trace | Test config (conftest/setup), test markers/tags |
   | Logic error | assertion fails, wrong value | Service function, business logic |

3. **Isolate.** Find the *first* stack frame in project code (not library code) and read that file. Read the test that triggered it. If DB-related, check migration state with the `migrate` step (or the stack's tool-neutral equivalent for showing current migration/schema state). Check what changed recently: `git log --oneline -15` and `git diff` against the last known-good state. Narrow to the smallest reproduction — one test, one input, one code path.

4. **Hypothesize — state it before changing anything:**
   > "The error is caused by X because Y. If true, Z will confirm it."

   If several causes are plausible, list them ranked by likelihood and test the cheapest-to-check first. Confirm or eliminate each with evidence (a probe, a log line, a minimal input) — not by guessing fixes at the code.

5. **Verify the root cause.** Demonstrate the mechanism — show the exact line and condition that produces the failure. "It stopped failing" is not a root cause.

6. **Apply the minimal fix.** Fix only what is broken — no opportunistic refactoring. Add a regression test that would have caught this. Remove all temporary debug probes.

   **Forbidden anti-patterns — never acceptable:**
   - Wrapping in `try/except` (or the stack's equivalent) to silence the error
   - Adding a type-suppression directive to make type errors disappear
   - Mocking away the failure instead of understanding it
   - Deleting or skipping the test
   - Fixing symptoms instead of root causes

7. **Confirm.** Re-run the failing case, then the surrounding suite, to verify the fix and check for collateral damage. For the affected component, from its `working_dir`:
   - `test` step (scoped to the failing case, then the full suite)
   - `typecheck` and `lint` steps

   Skip any step the component does not map.

## Output

In the conversation: root cause (one sentence with `file:line`), the mechanism, the minimal fix applied, and the regression test added. No file is written — if this incident warrants a durable document (recurring, production, or multi-cause), follow up with `/cc:verify:rca`.

## Quality checklist

- [ ] Failure reproduced before any code change
- [ ] Error classified by type before isolating
- [ ] Hypothesis stated explicitly before editing
- [ ] Root cause demonstrated at `file:line`, not inferred from "it passes now"
- [ ] Fix is minimal and includes a regression test
- [ ] Debug probes removed; no suppression anti-patterns introduced

## Handoff

**Chain:** after the fix, immediately invoke `/cc:verify:run` to confirm the full suite is green; the chain resumes from there.
**Solo:** suggest `/cc:verify:run` to confirm nothing else broke.
**Abort rules:** cannot reproduce the failure, or three hypotheses eliminated without finding the cause → stop and report findings to the user rather than churning. Bug is recurring or has production impact → escalate to `/cc:verify:rca` for a full analysis.
