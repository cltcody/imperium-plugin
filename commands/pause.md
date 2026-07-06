---
description: Save a lightweight cursor of where you stopped — task, in-flight files, next action — so /cc:prime --resume can pick it back up next session
argument-hint: [optional note — why you're pausing, or what to flag for next time]
disable-model-invocation: true
---

# Pause — Save Session Cursor

Write a small "you are here" marker before ending a session mid-task, so the next session
(yours, tomorrow, on this machine or another) can resume without re-deriving context from
scratch.

This is the lightweight, cross-**session** sibling of the `handoff` skill (`/cc:handoff`),
which is cross-**person**/cross-**machine**: `/cc:handoff` compacts a whole conversation into
a redacted narrative and saves it to `~/.claude/memory-store/_handoffs/`, where it rides the
`SessionEnd` push / `SessionStart` pull to sync across machines (see
`docs/memory-sync-runbook.md`). `/cc:pause` does neither. It writes one small file,
`${user_config.workspace_dir}/session.md`, inside the project itself — a normal tracked file that travels
via **git** (commit, push, branch checkout), never through the memory-sync store. Use
`/cc:pause` when you're stopping mid-task and will pick the same repo back up via its git
history; use `/cc:handoff` when you want a portable narrative that isn't tied to one repo's
working tree.

## Steps

1. **Decide if there's anything worth pausing.** Check for evidence of in-flight work:
   `git status --short` (uncommitted changes), and — per `/cc:next`'s technique — whether
   `${user_config.workspace_dir}/plans/` has an entry newer than its matching `${user_config.workspace_dir}/execution-reports/`
   entry (a plan without a report means work is mid-flight), and whether
   `${user_config.workspace_dir}/code-reviews/` has open findings. If the tree is clean and nothing is
   in flight, stop here — see Abort rules.
2. **Capture git state.** `git branch --show-current`, `git log -1 --oneline`, and a
   *summary* of `git status --short` — counts grouped by status (modified / added / deleted /
   untracked), not the full diff pasted in.
3. **Identify where work stopped.** Name the task in progress and the `file:line` where it
   was interrupted — from the conversation itself (the last file edited, or the specific
   spot under discussion). If that isn't clear from context, fall back to the most recently
   modified tracked file from step 2 as the best-effort anchor.
4. **Note open threads.** Decisions still pending, questions raised but not answered, and
   approaches already tried and abandoned — so next session doesn't retry them blind.
5. **State the next action.** One concrete, executable step: a command to run, a file to
   edit, a check to perform. "Keep working on X" is not a next action.
6. **Link active docs.** The newest relevant file in `${user_config.workspace_dir}/plans/`,
   `${user_config.workspace_dir}/execution-reports/`, and `${user_config.workspace_dir}/code-reviews/`, if any exist.
7. **Write `${user_config.workspace_dir}/session.md`, overwriting it in full.** It's a cursor, not a
   log — each pause replaces the previous state entirely rather than appending to it.

## Output

`${user_config.workspace_dir}/session.md` (overwritten), target **under ~60 lines** — precision over
completeness:

```markdown
# Session Cursor
**Paused:** <YYYY-MM-DD HH:MM> · **Branch:** <branch>

## Stopped at
<task name> — `<file>:<line>`
<one-sentence description of exactly what was being done>

## In flight (uncommitted)
<N> modified, <N> added, <N> deleted
- <path> — <one-clause state/reason>
- <path> — <one-clause state/reason>

## Open threads
- <decision pending / question unresolved / approach already tried and abandoned>

## Next action
<one concrete, executable next step>

## Links
- Plan: `${user_config.workspace_dir}/plans/<name>.md`
- Review: `${user_config.workspace_dir}/code-reviews/<name>.md`
```

## Quality checklist

- [ ] Nothing written when the tree is clean and no plan/review is in flight
- [ ] Uncommitted work is a summary (counts + one clause per file), not a pasted diff
- [ ] "Stopped at" names a task and a `file:line`, not a vague area
- [ ] Next action is a single concrete step, executable without re-reading the whole session
- [ ] Links point at files that actually exist
- [ ] Output stays under ~60 lines and the file is fully overwritten, not appended

## Handoff

**Chain:** not a normal PIV chain step — a manual session-boundary action. If a chain paused
itself (e.g. the confidence gate stopped it), write the cursor anyway so `/cc:next` or
`/cc:prime --resume` can pick the work back up next session.
**Solo:** confirm the file was written (or that there was nothing to pause) and suggest
`/cc:prime --resume` at the start of the next session to continue.
**Abort rules:** working tree clean and no plan/review newer than the last commit → report
"nothing to pause" and stop — do not write or overwrite `session.md` (a genuine prior cursor
should never be clobbered by a no-op).
