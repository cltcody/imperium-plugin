---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work.

**Where to save it:** if the cross-machine memory store exists (`~/.claude/memory-store/`, set up
via imperium's `docs/memory-sync-runbook.md`), save the handoff there so it syncs to your other
machines automatically:

```
~/.claude/memory-store/_handoffs/<project-or-topic>-<YYYY-MM-DD-HHMM>.md
```

Create the `_handoffs/` directory if needed. Files in the store ride the `SessionEnd` push (and the
denylist gate, which holds back anything matching work/TR terms), so the doc is available on your
other Mac on its next `SessionStart` pull. If the store does **not** exist, fall back to a sensible
local directory and tell the user where you saved it.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information
(this is in addition to — not a replacement for — the store's denylist gate).

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
