---
description: Create and manage pull requests with gh — push, PR body with summary and test plan, review handling, merge
argument-hint: [pr-number for managing, or empty to create]
---

# Create or Manage a PR

Create a well-formed pull request from the current branch, or manage an existing one (status, review responses, merge). PR bodies follow a consistent summary + test plan format so reviewers can act fast.

## Steps

### Create (no argument)

1. **Branch check.** `git branch --show-current` — if on `main`/`master`, stop and create a feature branch first. `git status --short` must show a clean tree; any modified-but-unstaged (`M`) files may belong in this PR — review and stage/amend them before continuing (uncommitted work → route to `/cc:release:commit`). Review what the PR will contain: `git log origin/main..HEAD --oneline` and `git diff origin/main --stat`.
2. **Sync check.** `git fetch origin main`; if the branch is behind in a way that will conflict, run `/cc:github:sync` first.
3. **Pre-push validation (hard gate).** Run the project-detected checks (type-check, lint, tests) and do not push until all pass. Fix and re-run any failures — never skip or work around them.
4. **Push.** `git push -u origin <branch>`.
5. **Compose the body** from the actual commits and diff (and `${user_config.workspace_dir}/execution-reports/` if one exists for this work). **Enumerate completed issues first (required):** check which open issues this diff completes — `gh issue list --state open --search "<key terms>"` on the branch/commit topics. Work tracked under a plan or feature name still maps back to issues, and one PR can complete several. Then use the repo's `.github/PULL_REQUEST_TEMPLATE.md` if present; otherwise:
   - `## Summary` — what changed and why, 1–3 bullets.
   - `## Test plan` — checklist of how it was verified (project-detected checks, manual steps).
   - One `Closes #<n>` line per issue the diff completes; if it completes none, an explicit `Advances #<n> — closes nothing` (or `No related issues`) line instead. Never leave linkage implicit — PRs shipped without it leave zombie issues (done but still open).
   - End the body with: `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.
6. **Create.** `gh pr create --title "<conventional title>" --body "<body>" --base main`. Write the body via a temp file (`--body-file`) if quoting is awkward in the shell. Report the PR URL.
7. **Watch CI (hard gate).** `gh pr checks <number> --watch` (or `gh run list --branch <branch>`). On red, investigate the logs immediately (`gh run view <run-id> --log-failed`), fix, commit, push, and confirm CI goes green before reporting the PR as ready.

### Manage (argument = PR number)

8. **Status:** `gh pr view <number>` and `gh pr checks <number>`. **Reviews:** `gh pr view <number> --comments`; address feedback, commit via `/cc:release:commit`, `git push` (auto-updates the PR), reply to threads with `gh pr comment`.
9. **Merge** only when checks are green, required approvals exist, and threads are resolved: `gh pr merge <number> --squash --delete-branch` (squash preferred for clean history). Ask before merging unless the user already told you to. **Close without merging:** `gh pr close <number> --comment "<reason>"`.

## Output

A pull request URL with a summary + test plan body and Claude Code attribution, or an updated/merged PR with review threads addressed.

## Quality checklist

- [ ] Not raised from main; working tree clean before push
- [ ] Pre-push checks (type-check, lint, tests) all green before pushing
- [ ] PR title is conventional and matches the actual change
- [ ] Body has Summary, Test plan, a `Closes #n` line per completed issue (or an explicit closes-nothing declaration), and the attribution line
- [ ] CI checks green (or failures explained to the user)
- [ ] Merge only with green checks and resolved threads, squash by default

## Handoff

**Chain:** in a PIV chain this runs after the commit gate; once the PR is open, the chain ends — report the URL and suggest `/cc:verify:system` for an optional process review.
**Solo:** suggest `/cc:verify:pr` for a full branch self-review before requesting human reviewers, and `/cc:github:sync` if main moves while the PR is open.
**Abort rules:** uncommitted changes → route to `/cc:release:commit` first. Push rejected (diverged) → route to `/cc:github:sync`; never force-push without the user's say-so. CI fails on the PR → route to `/cc:verify:debug` rather than merging around it.
