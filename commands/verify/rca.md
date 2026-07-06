---
description: Write a root cause analysis document for a complex or recurring bug — timeline, evidence, 5 whys, prevention
argument-hint: [short incident name or description]
---

# Root Cause Analysis

Produce a durable RCA document for a bug that deserves more than a fix: recurring failures, production incidents, or anything whose cause spans multiple changes or systems. Where `/cc:verify:debug` fixes the code, this command fixes the understanding — and feeds prevention back into the process.

**The root-cause test:** for any candidate cause, ask *"if I changed THIS, would the bug be prevented?"* If the answer is "maybe" or "partially", you haven't reached the root cause — keep digging until you can point at the exact code, config, or decision that, once changed, makes the symptom impossible.

## Steps

1. **Classify and define the incident.** First determine what you're handed: a **raw symptom** (error, stack trace, vague report → you must *investigate*) or a **pre-diagnosis** that already names a location/cause (→ you must *validate and expand* — confirm it, then check whether the same flaw exists elsewhere). Then establish: observed behaviour (exact error, wrong output, impact), when it started (commit hash, deploy, "always"), reproducibility, scope (who/what is affected), and severity (P0–P2). Restate the symptom in one sentence.
2. **Build the timeline.** Reconstruct the sequence from evidence — `git log` / `git blame` around the onset, deploy/CI history, log timestamps, issue reports. Establish when the problematic code was introduced and whether it's a regression, an original bug, or a long-standing issue. Every timeline entry must be sourced, not remembered.
3. **Gather evidence — test, don't just read.** Reading code tells you what it's *supposed* to do; running it tells you what it *actually* does. Diff against the last known-good state, then prove the behaviour empirically. Resolve the project's tooling from its `STACK.md` per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`: run the failing case in isolation with the affected component's `test` step from that component's `working_dir` (narrow it to the single case where the runner allows), execute the suspect path with edge-case inputs, and collect the relevant log excerpts. Skip components a step doesn't map. If there is no `STACK.md`, auto-detect the runner once from project markers and recommend `/cc:setup:stack` to persist a manifest. Quote evidence verbatim in the document.
4. **Form and test hypotheses.** List 2–4 candidate causes ranked by likelihood, with evidence for and against each. Confirm or eliminate each one empirically — the surviving hypothesis must explain *all* the evidence, including why the bug appeared *when* it did.
5. **Run the 5 whys** from symptom down to root cause. Every "because" must carry concrete evidence (a `file:line` reference, command output you ran, or a test you executed) — no step survives on speculation. Use more or fewer than five levels as needed; stop at the level the team can act on (a process or design decision, or code you can change), not at "human error". If a step can't be proven, run something to prove it or omit it.
6. **Validate the root cause** before declaring victory: **causation** (does it lead to the symptom through your evidence chain?), **necessity** (if it didn't exist, would the symptom still occur?), **sufficiency** (is it enough alone, or are there co-factors?). If any test fails, go deeper or broader.
7. **Identify contributing factors** — conditions that didn't cause the bug but let it happen or made it worse: missing tests, weak validation gates, unclear ownership, config drift, time pressure.
8. **Define prevention actions.** Each one concrete and assignable: the regression test to add, the validation gate to extend, the lint rule, the doc/CLAUDE.md update, the process change. An RCA without prevention actions is a story, not an analysis.
9. **Write the document** to `${user_config.workspace_dir}/reports/rca-<kebab-name>.md` using the structure below.

## Common patterns to check (stack-agnostic)

These are failure *categories* — map each to your stack's concrete form (async/await vs. promises vs. threads; the project's type system; its migration and dependency tooling) when investigating.

**Concurrency / async issues** — unawaited or unjoined work; shared state mutated across tasks; a resource read after it was closed, committed, or invalidated.
**Type / contract mismatches at runtime** — a null/absent value not handled at the boundary; a field name or shape that drifted between the schema, the model, and the caller.
**Migration / state drift** — schema migrated but the code (or vice versa) not updated; the applied version differs from the expected head. Confirm with the project's `migrate` tooling, not by assumption.
**Import / module-resolution errors** — circular dependencies across modules or feature boundaries; a missing module-init or barrel file; a path/alias that resolves differently across environments.
**Environment / config issues** — a missing or misnamed variable (diff the live env against the project's example/template file); a value pointing at the wrong endpoint, driver, or mode for the environment.

## Output

`${user_config.workspace_dir}/reports/rca-<name>.md`:

```markdown
# RCA: <Short Name>
**Date:** YYYY-MM-DD | **Severity:** P0/P1/P2 | **Status:** root cause confirmed / suspected | **Confidence:** High/Medium/Low

## What happened          ← 2–3 sentences, observable impact; reproduction verified yes/no
## Timeline               ← timestamped, sourced events; when the code was introduced (git blame)
## Evidence               ← verbatim errors, diffs, log excerpts, command output you ran
## 5 Whys                 ← symptom → root cause chain, evidence on every step
## Root Cause             ← one paragraph: what is actually broken and why
## Contributing Factors   ← what allowed/amplified it
## Fix                    ← what was (or must be) changed; files + the correct behaviour
## Prevention Actions     ← checklist: test / gate / doc / process items
```

**Exemplar:** match the shape and bar of `${CLAUDE_PLUGIN_ROOT}/references/dev/exemplars/rca-exemplar.md` — not its content.

## Evidence standards (strict)

Every claim in the chain must rest on proof, not deduction:

- VALID: a `file:line` reference with the actual code, output from a command you ran, or a test you executed.
- INVALID: "likely…", "probably…", "may cause…", logical deduction without code proof, or explaining how a technology works in general.

If you can't prove a step, run something to prove it or omit it.

## Quality checklist

- [ ] Input classified (raw symptom → investigated / pre-diagnosis → validated)
- [ ] Timeline entries sourced from git/logs/CI, not memory; onset commit identified
- [ ] At least one hypothesis confirmed by execution, not reading alone
- [ ] Root cause passes causation, necessity, and sufficiency tests, and explains the timing of onset
- [ ] 5-whys chain ends at an actionable process/design level, evidence on every step
- [ ] Every prevention action is concrete enough to start today
- [ ] Document saved to `${user_config.workspace_dir}/reports/rca-<name>.md`

## Handoff

**Chain:** this command starts the bug-fix fast path. If the fix is not yet implemented, immediately invoke `/cc:plan:feature` with the RCA as input to plan it (then execute → validate → commit gate as usual).
**Solo:** suggest `/cc:plan:feature` to plan the fix, or `/cc:verify:run` if the fix already landed and only confirmation remains.
**Abort rules:** if no hypothesis survives the evidence, publish the RCA with status "root cause suspected", list what would confirm it, and escalate to the user — do not assert an unproven cause.
