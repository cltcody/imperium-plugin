---
description: Recurring GitHub issue-hygiene sweep — zombie issues shipped by merged PRs, consolidation orphans, metadata gaps, stale status labels, duplicate suspects — batched close/fold/relabel recommendations, never auto-closing
argument-hint: [repo as owner/name, or blank for the current repo]
---

# Maintain: Issue Hygiene Sweep

Sweep the issue tracker for drift — issues that shipped but stayed open, donors "absorbed" into other issues but never closed, orphans with no metadata, stale status labels, duplicates. Drift accumulates silently for weeks; run this on a recurring cadence (monthly, alongside `/cc:maintain:audit`) or after any burst of consolidation/shipping activity. This command is stack-agnostic and `gh`-based; it **recommends in batches and never closes, relabels, or edits anything without the user's per-batch go**.

**Setup.** Resolve the target repo (`$ARGUMENTS` as `owner/name`, else `gh repo view --json nameWithOwner`). Probe what taxonomy actually exists — every later check degrades gracefully around what's missing:

```bash
gh label list --json name,description --limit 100
gh api repos/<owner>/<repo>/milestones --jq 'length' 2>/dev/null || echo 0   # 0 → skip milestone checks
gh project list --owner <owner> 2>/dev/null | head -5                        # empty/error → skip board check
```

Pull the working set once: `gh issue list --state open --json number,title,labels,milestone,comments,updatedAt --limit 500`.

## Steps

### 1 — Retired/deprecated label scan

Some labels get retired from the taxonomy but linger on old issues. Ask the user for (or read from a project convention doc, if one names them) the list of retired label names; skip with a note if none are known. For each open issue carrying one: recommend the replacement label per the current taxonomy, or plain removal.

### 2 — Metadata gaps (type / priority / milestone)

For every open issue, check it carries the project's required metadata — typically one type label, one priority, and a milestone where the repo uses milestones (adapt to the taxonomy found in Setup; label names are examples, not requirements). List gaps per issue. Recommendation: a triage batch (hand off to the project's triage skill/agent if one exists) rather than guessing labels inline.

### 3 — Stale status labels (decision already posted)

Issues carrying an open-question/needs-decision-style status label whose discussion has actually concluded. For each such issue, read the latest comments (`gh issue view <n> --comments`): if a decision has been posted (look for a decision verdict — "DECISION", "decided", "we'll go with", an approved option), the status label is stale — flag it for label drop, and ask whether the decision also resolves the issue entirely (→ close candidate).

### 4 — Zombie scan (shipped but still open)

Open issues referenced by **merged** PRs. For each open issue:

```bash
gh pr list --state merged --search "<issue-number> in:body" --json number,title,mergedAt --limit 10
# plus the reverse: gh issue view <n> --json title,body then gh search prs "<key title terms>" --repo <owner/name> --merged
```

A mention alone proves nothing — **read the referencing line** in each merged PR's body/commits and judge closing intent: `Closes/Fixes/Resolves #N` or prose like "implements #N fully" = the work shipped (zombie — close candidate, citing the PR); "Refs #N", "advances #N", "part of #N" = intentionally partial (leave open, note remaining scope). When the line is ambiguous, compare the PR diff against the issue's acceptance criteria before recommending.

### 5 — Consolidation orphans

Open issues whose recent comments say they were absorbed elsewhere:

```bash
gh issue list --state open --json number,title --limit 500  # then per candidate:
gh issue view <n> --comments | grep -inE "absorbed|consolidat|folded into|merged into|superseded by|moved to #"
```

For each hit, read the comment: if it declares the issue absorbed/folded into #X and #X actually tracks the scope (verify #X is open or was completed), the donor should have been closed in the same action — close candidate, with a closing comment pointing at #X. (Protocol rule going forward: an "absorbed into #X" comment and closing the donor are ONE action, never two.)

### 6 — Duplicate suspects

Pairwise title similarity across open issues (shared distinctive terms, same feature/bug phrasing) plus shared comment content (the same error text, screenshot description, or reporter quote appearing on both). `gh search issues --repo <owner/name> --state open "<key terms>"` per cluster to confirm. Recommend fold direction (older/better-specified issue survives; the duplicate gets an "absorbed into #X" close — one action, per step 5's rule). Present as suspects, never as certainties.

### 7 — Project-board coverage

Only if Setup found a board: list open issues not on the board (`gh project item-list <number> --owner <owner>` diffed against the open-issue set). Recommend additions in the board's intake column. No board → report "n/a" and move on.

### 8 — Report and gated execution

Produce one report, grouped into **batches by action type** — the user approves or rejects per batch, and only then do you execute that batch's `gh` commands:

```
Issue Hygiene Sweep — <date> — <owner/repo>
────────────────────────────────────────────
Open issues scanned:    91
1. Retired labels:       3 issues → relabel batch A
2. Metadata gaps:       12 issues → triage batch B
3. Stale status labels:  2 issues → relabel batch C (1 also a close candidate)
4. Zombies:              7 issues → CLOSE batch D (each cites its merged PR + the referencing line)
5. Consolidation orphans:4 issues → CLOSE batch E (each cites its absorber)
6. Duplicate suspects:   3 pairs  → FOLD batch F (direction proposed per pair)
7. Board coverage:       n/a — no project board
```

Under each batch, list `#N — title — evidence — proposed action` (for closes: the exact `gh issue close <n> --comment "..."` that will run). **⛔ Never auto-close: every close/fold/relabel batch waits for the user's explicit go, batch by batch.** Rejected items get a one-line note in the final summary so the next sweep doesn't re-litigate them blind.

## Quality checklist

- [ ] Taxonomy probed, not assumed — milestone/board checks skipped gracefully where absent
- [ ] Every zombie verdict quotes the referencing line from the merged PR, not just a mention count
- [ ] Every consolidation-orphan close cites the absorbing issue
- [ ] Duplicates presented as suspects with a proposed fold direction, not auto-folded
- [ ] Nothing closed, relabeled, or edited without the user's per-batch approval
