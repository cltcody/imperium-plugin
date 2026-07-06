# Humanization pass (LinkedIn)

Run this **after** the quality gate, on every Post / Article / Script / Podcast. The gate removes
what's *wrong*; this makes the piece sound like a person.

## Step 1 — Run the `humanize` skill's scan (don't duplicate it here)

The lexical + punctuation AI-tell catalogue lives in one place: the **`humanize` skill**. Run its
deterministic grep pass against the draft —
`${CLAUDE_PLUGIN_ROOT}/skills/humanize/references/ai-tells.md` (English) or `ai-tells-de.md`
(German) — and fix every hit (em dashes, stock vocabulary, "not just X but Y"). This file does
**not** re-list those tokens; the humanize skill is the single source of truth for them.

## Step 2 — LinkedIn-specific rhythm & voice moves

These are the craft moves the grep can't catch, tuned for the feed:

- **Vary the rhythm.** LinkedIn rewards a real cadence, not uniform 15–20-word lines and not
  wall-to-wall staccato one-liners. One punchy line per post is good; a whole post of them reads
  fake. Merge two short lines, break one long one.
- **Cut the throat-clearing opener.** Delete "In today's…", "We've all been there", "I'm excited
  to share". Open *inside* the moment or on the arguable claim.
- **Land one risky claim.** Every strong post has at least one line the reader could disagree
  with. If nothing here is contestable, it's a summary, not a point.
- **Break one structural default.** Kill a forced triad, drop the emoji-bullet summary row, or
  remove the rhetorical-question-then-answer. Don't let the piece march the identical arc.
- **Confirm every specific is real.** Numbers, dates, names, quotes must come from the source or
  the user — never invented to fill the "be concrete" instruction. Flag anything unverifiable.
- **Endings:** value reveal or a flat honest statement — never engagement bait ("Thoughts?",
  "Agree?", "Tag someone…").

## Step 3 — Read it aloud

Consecutive sentences of near-identical length and shape are a fail. If you wouldn't say the line
to a colleague out loud, rewrite it. See `references/voice-and-tone.md` for the personal-voice
craft (most important for the `personal` profile) and `references/voice-examples.md` for
before/after moves.
