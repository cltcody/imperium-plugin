---
description: Open a draft pull request for early feedback while implementation is still in progress
argument-hint: [optional short title]
---

# Draft PR

Open a draft pull request early in a feature so the team can review direction while you keep working. Catches "I'd have done it differently" before it's baked in. Use `/cc:github:pr` when the work is complete.

## Steps

1. **Branch check.** `git branch --show-current` — must be a feature branch, not `main`. Commit current in-progress work through `/cc:release:commit` (a `wip:` or scoped partial commit is fine; the gate still applies).
2. **Push.** `git push -u origin <branch>`.
3. **Compose a draft body** that makes the work-in-progress state obvious:
   - `## What this does` — the goal and what is implemented so far.
   - `## Still TODO` — checklist of remaining work (keep this current as you push).
   - `## Questions for reviewers` — the specific design decisions you want feedback on. A draft without questions wastes reviewers' time — always include at least one.
   - `Refs #<issue>` if an issue exists (not `Closes` — the work isn't done).
   - End with: `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.
4. **Create as draft.** `gh pr create --draft --title "WIP: <title>" --body "<body>" --base main`. Report the URL and tag reviewers if the user names them (`gh pr edit <number> --add-reviewer <user>`).
5. **Iterate.** As feedback arrives (`gh pr view <number> --comments`): apply it, commit via `/cc:release:commit`, `git push` (auto-updates the PR), reply to threads. Update the TODO list in the body with `gh pr edit <number> --body-file <file>`.
6. **Promote when complete.** All TODOs done and `/cc:verify:run` green → retitle without "WIP:" (`gh pr edit <number> --title "<final title>"`), switch `Refs` to `Closes` — at promotion, enumerate every open issue the final diff completes and give each its own `Closes #<n>` line (or declare `Advances #<n> — closes nothing` explicitly) — then `gh pr ready <number>` to request formal review.

## Output

A draft PR URL with explicit TODO list and reviewer questions; later, the same PR promoted to ready-for-review.

## Quality checklist

- [ ] Created with `--draft` and a `WIP:` title
- [ ] Body separates done from TODO honestly
- [ ] At least one concrete question for reviewers
- [ ] Issue referenced with `Refs`; at promotion every completed issue gets its own `Closes` line (or an explicit closes-nothing declaration)
- [ ] Promoted to ready only after validation passes and TODOs are cleared

## Handoff

**Chain:** draft PRs are inherently interactive — pause the chain here and resume `/cc:implement:execute` as feedback lands; the chain completes through the commit gate and `gh pr ready`.
**Solo:** suggest `/cc:verify:run` and `/cc:verify:code` before promoting the draft, and `/cc:github:sync` if main moves while drafting.
**Abort rules:** direction rejected in early feedback → close the PR (`gh pr close <number> --comment "<reason>"`) and route back to `/cc:plan:feature` rather than patching a wrong design. Uncommitted work → the commit gate comes first, always.
