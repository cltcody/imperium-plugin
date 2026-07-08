---
description: Fast-path bug fix from a GitHub issue — reproduce, minimal fix, validate, PR
argument-hint: [issue-number or error description]
---

# Fix an Issue

The bug-fix fast path: reproduce, fix minimally, prove it, ship a PR referencing the issue. For features or large changes use `/cc:github:issue`; for bugs whose cause is genuinely unclear, run `/cc:verify:rca` first and come back with the RCA.

## Steps

1. **Read the bug report.** `gh issue view <number>` (pull title, body, labels, comments, state). If there is no issue, get from the user: the exact error message, where it occurs, and steps to reproduce.
2. **Confirm it's in scope.** Proceed only if the issue is open, is a bug (not a feature request that needs a PRD/plan), and has no PR already linked. Stop and report instead if: it's closed, it's a large feature → route to `/cc:github:issue`; a PR already addresses it; or the cause is genuinely unclear → run `/cc:verify:rca` first and resume from the RCA.
3. **Reproduce it.** Run the failing path — the failing test, a script, or a manual invocation. Use the project's own tooling: resolve the relevant step (e.g. `test`) from `STACK.md` per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`, or auto-detect from project markers if no `STACK.md` exists. **If you cannot reproduce the bug, stop and ask for more context — never fix what you can't see fail.** Capture the failing output as the "before" evidence.
4. **Find the root cause.** Check in order: the stack trace (what line threw), recent changes (`git log --oneline -10 -- <relevant-paths>` — did a recent commit introduce it?), the code at the failing line, and whether the test/expectation itself is wrong. Read the full surrounding context, not just the failing line, and confirm the bug hasn't already been fixed. If this takes more than a quick diagnosis, escalate to `/cc:verify:rca` (writes `${user_config.workspace_dir}/reports/` RCA) and resume from its proposed fix — but validate the proposed fix against the actual code first; if it doesn't hold up, stop and say why rather than implementing a bad fix.
5. **Branch from clean, up-to-date main.** Verify the working tree is clean (`git status --porcelain`) — stash or commit stray changes first. Then `git checkout -b fix/<issue-number>-<short-kebab-description>` and pull/rebase onto latest main.
6. **Fix minimally.** Apply the smallest change that fixes the root cause, mirroring existing code style and patterns — no drive-by refactoring, no scope creep, no formatting changes to untouched lines.
7. **Add a regression test.** Write an Arrange/Act/Assert test that fails without the fix and passes with it, named/commented so it traces to the issue. If the project has no test harness, document manual verification steps in the PR instead.
8. **Validate.** Invoke `/cc:verify:run` to run the gate (tests, types, lint, build) — it is stack-agnostic and resolves the concrete commands from the project's `STACK.md` per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. No `STACK.md` → it auto-detects once; recommend `/cc:setup:stack`. Everything green, including the new regression test. Re-confirm the original reproduction now passes and no related functionality regressed.
9. **Sync before shipping.** Re-fetch main; if the branch is behind, rebase onto it and re-run validation. Then commit via the gate: invoke `/cc:release:commit` — message `fix(<scope>): <what was broken>` with `Fixes #<number>` in the body. The gate presents the diff for user approval before committing.
10. **Open the PR.** `git push -u origin fix/<description>` (use `--force-with-lease` if you rebased) then `gh pr create` with a body containing: Root Cause (one sentence), Fix (one sentence), Regression Test (path/name), Validation results, `Fixes #<number>`, and the Claude Code attribution line. Post the PR URL on the issue and, if the project uses them, update the issue's labels (e.g. add `fixed`).

## Output

A `fix/<description>` branch with a minimal fix plus regression test, validated, committed through the gate, and a PR that auto-closes the issue on merge.

## Quality checklist

- [ ] Issue confirmed in scope (open, a bug, not already PR'd) before any work
- [ ] Bug reproduced before any code was changed
- [ ] Fix addresses the root cause, not the symptom
- [ ] Diff is minimal — no unrelated changes, no reformatting of untouched lines
- [ ] Regression test fails without the fix, passes with it
- [ ] Full validation green (tests, types, lint, build) and original repro now passes
- [ ] Branch rebased onto current main before push
- [ ] Commit and PR reference the issue (`Fixes #<number>`)

## Handoff

**Chain:** this is the bug fast path of the PIV chain — after step 6 succeeds, immediately invoke `/cc:release:commit` (the gate), then `/cc:github:pr` if a fuller PR flow is needed.
**Solo:** suggest `/cc:verify:code` for a review of the fix before the commit gate on riskier changes.
**Abort rules:** cannot reproduce → stop, ask for context, do not guess-fix. Root cause unclear after quick diagnosis → route to `/cc:verify:rca`. Validation fails twice after the fix → route to `/cc:verify:debug`. Fix grows beyond minimal → stop and restart through `/cc:github:issue` with a proper plan.
