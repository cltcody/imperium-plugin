---
description: Pick up a GitHub issue end-to-end — read, plan, branch, run the PIV chain, link the PR back
argument-hint: [issue-number]
---

# Work on an Issue

Take a GitHub issue from open to pull request using the full PIV chain. This is the chain entry point for issue-driven work: it sets up the branch and context, then hands off to `/cc:plan:feature` and lets the loop run to the commit gate.

## Steps

1. **Read the issue.** `gh issue view <number>` (ask for the number if not given as argument). Read title, body, labels, linked issues, and all comments. Check `gh auth status` works first; if `gh` is missing or unauthenticated, stop and tell the user.
2. **Classify and scope.**
   - **Bug** → consider the fast path `/cc:github:fix` instead; for complex bugs run `/cc:verify:rca` first.
   - **Feature/enhancement** → continue here.
   - **Unclear scope** → ask clarifying questions on the issue (`gh issue comment`) before writing code.
   Check for prior art: `git branch -a` for an existing `issue-<number>-*` branch, `git log --oneline --all -i --grep "<keyword>"` for related commits.
3. **Comment the plan.** Post a short implementation plan as an issue comment (`gh issue comment <number> --body "..."`) so the team sees the approach. Optionally assign yourself: `gh issue edit <number> --add-assignee @me`.
4. **Branch from fresh main.** `git checkout main`, `git pull origin main`, then `git checkout -b issue-<number>-<short-kebab-description>`.
5. **Run the PIV chain.** Invoke `/cc:plan:feature` with the issue context via the SlashCommand tool. The chain proceeds hands-off: `/cc:plan:feature` → `/cc:implement:execute` → `/cc:verify:run` → `/cc:verify:code` → `/cc:verify:execution-report` → ⛔ commit gate at `/cc:release:commit`. Ensure the commit message includes `Fixes #<number>` (or `Refs #<number>` for partial work).
6. **Open the PR.** After the commit gate, invoke `/cc:github:pr`. The PR body must reference the issue (`Closes #<number>`) so GitHub links and auto-closes it on merge.
7. **Close the loop.** Post the PR URL back on the issue: `gh issue comment <number> --body "PR opened: <url>"`.

## Output

A branch `issue-<number>-<description>` with reviewed, validated, committed work; a PR linked to the issue; plan and PR comments on the issue. Plan artifact in `${user_config.workspace_dir}/plans/`, execution report in `${user_config.workspace_dir}/execution-reports/`.

## Quality checklist

- [ ] Issue fully read, including comments, before planning
- [ ] Implementation plan posted on the issue before coding
- [ ] Branch created from up-to-date main with `issue-<number>-` prefix
- [ ] Full PIV chain ran: plan → execute → validate → code review → report → commit gate
- [ ] Commit and PR reference the issue number
- [ ] No scope creep beyond what the issue asks

## Handoff

**Chain:** this command starts a chain — after setup (steps 1–4), immediately invoke `/cc:plan:feature` with the SlashCommand tool; after the commit gate, invoke `/cc:github:pr`.
**Solo:** the chain is the point of this command; if the user only wants analysis, suggest `/cc:verify:rca` (bugs) or `/cc:plan:feature` (features) directly.
**Abort rules:** issue too vague to plan → comment questions on the issue and stop. Validation fails twice in the chain → route to `/cc:verify:debug` and pause. Critical code-review or security finding → stop the chain, report, do not open a PR.
