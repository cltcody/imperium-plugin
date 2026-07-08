---
description: Auto-fix CRITICAL/HIGH and obvious MEDIUM findings from the latest code review, then re-validate
argument-hint: [path to review file — defaults to newest in ${user_config.workspace_dir}/code-reviews/] [optional scope to limit fixes]
---

# Fix Review Findings

Take a code-review report and fix everything that doesn't require a design decision: all CRITICAL and HIGH findings, plus MEDIUM findings with an obvious mechanical fix. Anything judgment-heavy is listed for the user instead of guessed at. Always ends by re-running validation. This command is **stack-agnostic**: the concrete cleanup and validation commands come from the project's `STACK.md`, not from this file.

## Steps

1. **Load the review.** Use the path in `$ARGUMENTS` if one was given; otherwise pick the most recently modified file in `${user_config.workspace_dir}/code-reviews/`. Read it in full before touching code — even if the findings look like one-liners, the surrounding context matters. If a scope was also passed in `$ARGUMENTS`, restrict all fixes to that scope (the named files/area). If the report says the review passed clean, report that and skip to the handoff.
2. **Triage every finding** into exactly one bucket, per the "who acts" column of the canonical ladder in `${CLAUDE_PLUGIN_ROOT}/references/dev/severity-and-rubrics.md`:
   - **Fix now** — all HIGH; CRITICAL findings whose fix is mechanical, local, and safe (a CRITICAL that isn't lands in the defer bucket and triggers the abort rule below); and MEDIUM findings whose fix is mechanical and local (rename, missing null check, unused import, missing error handling on one path, off-by-one).
   - **Defer to user** — anything requiring a design decision: API shape changes, architectural restructuring, behaviour trade-offs, fixes that would touch files outside the review scope, or any finding you cannot fix without inventing requirements. Also defer LOW findings by default (batch them into a later cleanup pass).
3. **Fix one finding at a time.** For each: state what was wrong, apply the minimal fix at the cited `file:line`, and run the nearest relevant test (or add one if the bug had no coverage). Fix root causes — never suppress with a type-ignore directive, a blanket exception catch, or skipped tests.
4. **Run mechanical cleanups** the project's tooling supports. Resolve the component's `format` (or formatter-fix) and `lint --fix` commands from `STACK.md` per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` and run them from the component's `working_dir` so formatting/import findings clear in one pass — only on files already in the change set. Skip a component that maps no such command. No `STACK.md` → auto-detect the formatter/linter once and recommend `/cc:setup:stack`.
5. **Annotate the review file.** Mark each finding `FIXED` or `DEFERRED (reason)` so the report doubles as the fix log.
6. **Re-validate.** Invoke `/cc:verify:run` to confirm the fixes broke nothing. That gate resolves the stack itself and runs `smoke → test → typecheck → lint → format:check` per component from each component's `working_dir`, skipping unmapped steps.

## Output

- Code fixes applied in place (uncommitted — the commit gate comes later).
- The review file in `${user_config.workspace_dir}/code-reviews/` updated with FIXED/DEFERRED status per finding.
- A short summary: N fixed, N deferred (with one-line reasons), validation result.

## Quality checklist

- [ ] Every CRITICAL and HIGH finding is either FIXED or explicitly escalated — none silently skipped
- [ ] No fix suppresses an error instead of resolving it
- [ ] Deferred items each have a stated reason and are surfaced to the user
- [ ] Each fix verified by a test where feasible
- [ ] `/cc:verify:run` re-run after all fixes

## Handoff

**Chain:** after fixes, immediately invoke `/cc:verify:run`. Track the loop count: this fix→validate cycle may run **at most 2 times** in one chain. On a GREEN re-validate, the chain continues from validate as normal (review → security → report).
**Solo:** suggest `/cc:verify:run` to confirm, then `/cc:verify:code` for a clean re-review.
**Abort rules:** if validation is still RED after the second fix loop, stop the chain and escalate to the user with the remaining failures and deferred findings. If any CRITICAL finding lands in the defer bucket, stop and ask before continuing — the chain must not pass a known critical issue.
