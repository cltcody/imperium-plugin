---
description: Diagnose where you are in the PIV cycle and run (or recommend) the right next step
argument-hint: [optional goal — e.g. "finish the auth feature" or "get this released"]
---

# Next — Orchestrated Step

Figure out the correct next move from the project's *actual* state and either run it or
recommend it. This is the command form of the `piv-orchestrator` skill — use it whenever
you are unsure which command comes next, returning to work after a break, or want the
loop to keep moving without remembering the sequence yourself.

## Steps

1. **Load the orchestrator.** Apply the `piv-orchestrator` skill's full workflow: diagnose
   state from evidence (never ask what can be detected):
   - `git status` / `git branch` / `git log --oneline -5` — uncommitted work? fresh branch?
   - `${user_config.workspace_dir}/plans/` vs `${user_config.workspace_dir}/execution-reports/` — a plan without a matching report
     means work is in flight; compare modification times.
   - `${user_config.workspace_dir}/code-reviews/` — open findings not yet marked FIXED?
   - Was `/cc:verify:run` run this session? With what verdict?
   - `gh pr list` / `gh issue list` if the `gh` CLI is available.
2. **Map evidence → phase** using the orchestrator's decision table. Examples:
   - No plan for the stated goal → `/cc:plan:feature` (or `/cc:plan:task` for small work)
   - Plan exists, no execution report → `/cc:implement:execute`
   - Uncommitted changes, validation unknown → `/cc:verify:run`
   - Open review findings → `/cc:verify:code-review-fix`
   - Everything green and uncommitted → `/cc:verify:execution-report` then the commit gate
   - Nothing in flight + goal given → offer `/cc:piv:loop "<goal>"`
   - Release imminent → `/cc:release:deploy`
3. **Act.** State ONE primary next step with a one-line why (plus at most 2 alternatives).
   If `$ARGUMENTS` stated a goal or the user said "just continue", invoke the step
   immediately with the SlashCommand tool. Never auto-invoke `/cc:release:commit` —
   that gate always belongs to the user.

## Output

A one-line state diagnosis, the chosen next command (invoked or recommended), and up to
two alternatives. No file is written.

## Quality checklist

- [ ] Diagnosis based on detected evidence, not questions to the user
- [ ] Exactly one primary recommendation, with the reason stated
- [ ] Step auto-invoked only when the user asked to proceed/continue
- [ ] `/cc:release:commit` never auto-invoked

## Handoff

**Chain:** this command IS the router — it hands off to whatever step the diagnosis selects.
**Solo:** same behavior; solo is its normal mode.
**Abort rules:** if the state is ambiguous (e.g. two plans in flight), present the ambiguity
and let the user pick instead of guessing.
