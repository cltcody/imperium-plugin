---
description: Run the full autonomous PIV loop on a feature — plan, implement, verify, gate, commit
argument-hint: [feature-description]
---

# Loop — Autonomous PIV Chain

Take a feature from description to commit-ready, hands-off. Every step is invoked via the SlashCommand tool without asking the user. There is exactly one approval gate: before `git commit`. Use this when the user wants the full loop; use individual commands for surgical work.

## Feature

$ARGUMENTS

If no feature description was given, ask for one now — then run the rest without pausing.

## Steps

Execute this chain in order. After each step, evaluate its result against the abort rules before continuing.

1. **`/cc:prime`** — load project context and detect the validation commands.
2. **`/cc:plan:feature <feature>`** — produce `${user_config.workspace_dir}/plans/<kebab-name>.md`. If the plan's confidence score is below 9/10 (the bar /cc:plan:feature itself enforces), surface its open questions to the user before implementing; otherwise continue.
3. **`/cc:implement:execute ${user_config.workspace_dir}/plans/<kebab-name>.md`** — execute the plan task by task.
4. **`/cc:verify:run`** — run the project's full validation suite (tests, types, lint).
   - Fails → fix and re-run once. Fails again → invoke `/cc:verify:debug`, then STOP the chain and report.
5. **`/cc:verify:code`** — review the diff. If findings:
   - Invoke `/cc:verify:code-review-fix`, then re-run `/cc:verify:run`. Maximum 2 fix→re-validate loops; if findings persist after that, STOP and report the remaining findings.
   - Any CRITICAL finding → STOP immediately and report.
6. **`/cc:verify:security`** — quick security scan of the diff. Any CRITICAL finding → STOP and report.
7. **`/cc:verify:design`** — relevance-gated architecture review (UX / AI / systems heads); on an infra-only or non-product diff all heads report N/A and it's a clean no-op. Any CRITICAL/BLOCK → STOP and report; CRITICAL/HIGH → `/cc:verify:code-review-fix` within the same 2-loop fix budget as step 5.
8. **`/cc:verify:execution-report`** — write the execution report to `${user_config.workspace_dir}/execution-reports/`, then hand off directly to `/cc:release:commit`.
9. **`/cc:release:commit` — ⛔ THE GATE.** Its gate step is the chain's single stop: it presents the work summary (from the execution report), `git diff --stat`, validation results, resolved findings, and the proposed commit message(s) with file lists — then waits for explicit approval. Do NOT commit without it.
10. Offer **`/cc:verify:system`** as an optional post-commit process review.

## Output

A committed, validated feature; a plan in `${user_config.workspace_dir}/plans/`; an execution report in `${user_config.workspace_dir}/execution-reports/`; and a final summary of the whole run.

## Quality checklist

- [ ] Every step invoked via SlashCommand — no step skipped, no mid-chain questions
- [ ] Validation green before the gate
- [ ] Review findings either fixed (≤ 2 loops) or explicitly reported
- [ ] Gate presented with summary, diff stats, validation results, findings
- [ ] No commit without explicit user approval

## Handoff

**Chain:** this command IS the chain — it owns the sequencing above.
**Solo:** n/a — `/cc:piv:loop` is always a chain.
**Abort rules:** validation fails twice → `/cc:verify:debug`, then stop. CRITICAL security or review finding → stop and report. User rejects at the gate → stop, summarise state, leave the working tree intact for manual follow-up.
