---
description: One-glance status of every memory/context-persistence surface for this project — session cursor, cross-machine store, task-list, native auto-memory
model: haiku
effort: low
allowed-tools: Bash, Read, Glob
disable-model-invocation: true
---

# Memory — Unified Status View

Report what this project already remembers, from where, and how fresh — a single
read-only glance across every persistence surface this plugin and Claude Code itself
maintain. No side effects: never write, edit, sync, or push anything.

See `references/dev/context-engineering.md` → "Native memory & caching" for what each
surface is and why there are several instead of one unified store.

## Steps

1. **Session cursor.** Check `${user_config.workspace_dir}/session.md` (the `/cc:pause` cursor).
   - If present: read its `**Paused:**` header line, compute age in days.
   - Also check `${user_config.workspace_dir}/session.auto.md` (the PreCompact safety-net snapshot —
     see `pre-compact-snapshot.py`). If it exists AND is newer than `session.md` (or
     `session.md` is absent), flag it: a compaction happened since the last real pause,
     or no real pause exists yet and only an auto-snapshot does.
   - If neither exists: report "none — nothing paused."

2. **Cross-machine memory store.** Run `memory-sync.sh status` and `memory-sync.sh doctor`
   (both read-only verbs; script lives at `${CLAUDE_PLUGIN_ROOT}/scripts/memory-sync.sh`,
   defaulting to `bash "$HOME/.claude/scripts/memory-sync.sh"` if that's where it's
   installed — check both locations). Pass through their summary lines verbatim: store
   path, linked/not-linked for this project, any denylist review-needed flags. If the
   script isn't found anywhere, report "memory-sync not installed — see
   `docs/memory-sync-runbook.md`."

3. **Task-list registration.** Check `.claude/archon/sessions/task-lists.jsonl` for an
   entry matching this project's path, and whether the `~/.claude/tasks/<id>/` directory
   it points to still exists on disk. Report registered-and-present, registered-but-missing
   (stale), or none.

4. **Native auto-memory.** Locate `~/.claude/projects/<encoded-cwd>/memory/MEMORY.md`
   (encode the current absolute path the same way `memory-sync.sh encode` does — sanitize
   `/` and `.` to `-`; you can shell out to `memory-sync.sh encode "$(pwd)"` rather than
   re-implementing the substitution). If present: report its line count and byte size
   against the ~200-line / 25KB session-start load budget (flag if over), and list any
   topic files alongside it. If absent: report "no native auto-memory yet for this
   project" and note whether `autoMemoryEnabled` looks configured (best-effort — this may
   not always be introspectable; don't guess if it isn't).

## Output

A compact four-row status block, e.g.:

```
Memory status — <project name>

session cursor:    session.md, 2 days old, clean handoff to next action
                    (session.auto.md also present, 1 day newer — compaction since last pause)
cross-machine sync: linked → ~/.claude/memory-store/imperium, no review-needed items
task-list:          none registered
native auto-memory: MEMORY.md, 140 lines / 6.1KB (under budget), 2 topic files
```

Keep it to these four rows plus at most one flag line per row — this is a status glance,
not a report. If a row has nothing to say, print "none" rather than omitting the row (an
absent row reads as "not checked," which is wrong).

## Quality checklist

- [ ] Every row reflects a real check (file existence, script output) — never fabricated
- [ ] No Write/Edit/sync/push side effects of any kind
- [ ] Flags (compaction-since-pause, stale task-list, over-budget auto-memory) are only
      raised when the underlying evidence actually supports them
- [ ] Falls back gracefully (reports "not installed"/"none") when a surface doesn't exist
      in this project, rather than erroring

## Handoff

**Chain:** not a normal PIV chain step — an on-demand diagnostic, usually run at session
start alongside or instead of `/cc:prime`.
**Solo:** end with the status block; if the session-cursor row shows a stale or
compaction-flagged pause, suggest `/cc:prime --resume`.
**Abort rules:** none — this command always produces its four-row report, falling back to
"none"/"not installed" per row rather than aborting.
