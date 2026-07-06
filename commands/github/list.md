---
description: List and filter open issues and PRs to pick what to work on next
argument-hint: [filter e.g. "bugs", "mine", "unassigned", "prs", or gh-style flags]
model: haiku
effort: low
allowed-tools: Bash, SlashCommand
disable-model-invocation: true
---

# GitHub: List Issues and PRs

Survey the repository's open work — issues and pull requests — filtered and prioritized so you can pick the next thing to do and jump straight into `/cc:github:issue` or `/cc:github:fix`.

## Steps

1. **Interpret the filter argument** (default: open issues, recently updated first):
   - "bugs" → `gh issue list --label bug`
   - "mine" → `gh issue list --assignee @me`
   - "unassigned" → `gh issue list --search "no:assignee is:open"`
   - "prs" → `gh pr list`
   - free text → `gh issue list --search "<text>"`
   gh-style flags pass through directly — see Filter syntax reference below.
2. **Fetch the data.** Use `--json` with `--limit 30` for clean output:
   - Issues: `gh issue list --state open --json number,title,labels,assignees,updatedAt,comments --limit 30`
   - PRs: `gh pr list --json number,title,isDraft,reviewDecision,statusCheckRollup,updatedAt --limit 30`
   Useful refinements: `--label <name>`, `--assignee <user>`, `--search "<terms>"`, `--state all|closed`, `--sort created|comments`.
3. **Present a prioritized table.** Don't dump raw JSON — render: number, title, labels, assignee, last activity. Order by priority signal: priority labels (`p0`/`critical` first), then blocked items flagged, then recency. For PRs, surface review state and CI status — **a red PR awaiting fixes often beats starting new work.**
4. **Recommend next actions.** Highlight 1–3 candidates with reasoning (e.g. "unassigned p1 bug, effort/low") and map each to a command:
   - Bug → `/cc:github:fix <number>`
   - Feature → `/cc:github:issue <number>`
   - PR with review feedback or red CI → `/cc:github:pr <number>`
   - Unlabeled issues piling up → `/triage`
5. **Drill down on request.** `gh issue view <number>` / `gh pr view <number>` for any item the user wants to inspect before committing to it.

## Filter syntax reference

```bash
/cc:github:list                              # open issues (default)
/cc:github:list --state all                  # open + closed
/cc:github:list --label bug,critical         # bug OR critical
/cc:github:list --assignee @me               # your assigned issues
/cc:github:list --search "authentication"    # search title + body
/cc:github:list --label "p0,critical" --assignee unassigned   # unassigned critical work
/cc:github:list --label feature --sort comments               # most-demanded features
```

## Label conventions (this project)

| Label | Meaning |
|-------|---------|
| `bug` | Something broken |
| `feature` | New capability |
| `enhancement` | Improve existing feature |
| `docs` / `chore` / `test` | Documentation / maintenance / QA |
| `p0` / `critical` | Must fix ASAP |
| `p1` / `high` | Important, schedule soon |
| `p2` / `medium` | Important, but can wait |
| `p3` / `low` | Nice-to-have |
| `blocked` | Can't start until something else is done |
| `good first issue` / `help wanted` | Good for newcomers / needs input |
| `area:auth` / `area:api` / `area:frontend` | Area of the codebase |
| `effort/low` / `effort/medium` / `effort/high` | < 2h / 2–8h / 8h+ |

## Pro tips

- **Check unassigned items regularly:** `--assignee unassigned --state open` finds work that's ready but unclaimed.
- **Find stale issues:** sort by `updated` and look at the bottom of the list.
- **Monitor one area:** `--label "area:auth" --state open`.
- **Plan capacity:** `--label "effort/high" --state open` shows the big rocks.

## Output

A prioritized, readable table of open issues/PRs matching the filter, plus a short "recommended next" section that maps each candidate to the command that starts it.

## Quality checklist

- [ ] Filter interpreted correctly (or default applied and stated)
- [ ] Output is a summarized table, not raw JSON
- [ ] Priority/blocked labels and PR CI state surfaced
- [ ] Red-CI or review-pending PRs surfaced before new work
- [ ] Each recommendation names the follow-up command with the issue/PR number
- [ ] Result limited to a digestible count (≤30) with the filter stated

## Handoff

**Chain:** not part of an autonomous chain — this is the picker that starts one: when the user selects an item, invoke `/cc:github:issue <number>` or `/cc:github:fix <number>` with the SlashCommand tool.
**Solo:** end by asking which item to pick up, with the mapped command per candidate.
**Abort rules:** `gh` unauthenticated or no GitHub remote → report how to fix (`gh auth login`) and stop. Empty result set → say so and suggest broadening the filter (`--state all`, drop labels).
