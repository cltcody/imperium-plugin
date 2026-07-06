# Mode skeletons

The structure and output rules for each mode. These are **brand-independent** — compose
them with the selected profile's **brand block** from `brand-profiles.md` (which supplies
Role, Audience, Topics, Voice, Stance, Hashtags, Footer, Banned words, Grounding). On any
conflict, the brand block wins.

These skeletons are the writing engine, generalised across profiles. Aim for high-quality,
specific prose; topic extraction (Ideate) is lightweight.

> **You are the generator** — there is no UI consuming JSON here, so produce clean Markdown
> directly in the conversation, not a JSON envelope.

When a **writing profile** is supplied, append it under `## Writing Style Profile`. When
**source material / grounding** is supplied (pasted text, URL content, or MCP-pulled facts),
prepend it as a `## Context` block: "Use these excerpts naturally to inform the writing",
build on them, never quote verbatim or list mechanically.

> **The structures below are defaults, not cages.** The single most recognizable AI tell is
> format-perfect symmetry: the same arc, the same triad, the same emoji bullets, every time.
> Pick a structure that fits the idea, vary it between pieces, and **after drafting always run
> `references/humanization.md`** and consult `references/voice-examples.md`. Emoji bullets and
> the closing question are optional, not required.

---

## Post

A standalone, scroll-stopping LinkedIn post. The first 2 lines decide whether anyone reads
on, so optimise them ruthlessly.

**Start from intent, not a template.** Decide what you are actually doing before choosing a
structure:
- **Story** — you experienced something; tell what happened (specific moment, the messy
  middle, details that couldn't be invented). Kills it: hero's-journey arc, tidy generic lesson.
- **Observation** — you noticed something others miss; grounded in a real launch / conversation
  / data point. Can be 3-4 sentences. Kills it: the obvious dressed up as insight.
- **Take** — you believe something and explain why; acknowledge where you might be wrong.
  Kills it: "unpopular opinion:" framing, contrarian-for-engagement.
- **Teach** — you know how to do a specific thing you've actually done recently; concrete,
  actionable steps + edge cases. Kills it: abstract frameworks you've only read about.
- **React** — you respond to something timely; add your angle, not just a summary.
- **Ask** — you genuinely want to learn from your audience; a real, specific question.
  Kills it: rhetorical questions as engagement bait.

**Structure options (pick one that fits, don't default to the same one every time)**
- **(a) Single story** — one real moment told start to finish, with the point landing at the end.
- **(b) One sharp claim** — open with a defensible opinion, then back it with one example.
- **(c) Observation / contrarian** — name a thing everyone does, then say why it's wrong.
- **(d) Light list** — only when the content is genuinely enumerable; keep it short.

**Building blocks (compose as the chosen structure needs)**
1. **Hook** — line 1, max 140 characters (all LinkedIn shows before "see more"). Pick a
   style that fits: bold claim · question · story opener · surprising stat.
2. **One idea or lesson** — name the reader's real pain or moment; be specific, not
   generically empathetic.
3. **Emoji bullets** — *optional*. Use only when they earn their place; if used, 0-3, choose
   2-3 marks (🎯 💡 🔍 ✅), each ≤ 15 words. A rainbow of bullets is an AI tell.
4. **The "so what"** — why it matters in practice. State it; you need not signpost it.
5. **Ending** — a clear CTA, a question, *or* a confident flat statement. A flat close is
   often stronger than a question; do not force engagement-bait.

**Output rules**
- Length per the option (default 150-300 words). Blank line between every section.
- **Hashtags / links are per profile.** Branded profiles (e.g. `company`):
  4-6 hashtags from the profile's set, footer applied. `personal`: **no hashtags, no footer,
  and no external link in the post body** (a URL goes in a first comment, never the body).
- Apply the **profile's stance** (promote vs not).
- No em dashes; avoid the banned words and patterns (see quality gate).
- After drafting, run `references/humanization.md`.

---

## Article (+ companion teaser post)

A long-form article plus a short teaser post that drives people to it.

**Article structure (choose one; vary between pieces)**
- **(default) Insight arc** — Hook → Problem → 2-4 key insights (vary the count, don't always
  do three) → real example → so-what. Each insight backed by a specific example, not abstraction.
- **(alt) Narrative case** — tell one real engagement end to end; let the lessons emerge from
  the story rather than listing them.
- **(alt) Myth vs reality** — name a widely-held belief, dismantle it, replace it with what
  actually works in the field.

Whichever you pick:
1. **Hook** — a counterintuitive truth, surprising fact, or concrete failure scenario. First
   2-3 sentences must stop the scroll. No "Welcome to my article" openers.
2. **Problem** — name the challenge, pain, or risk the reader faces; be specific.
3. **Substance** — the insights / story / argument, each anchored to a concrete, real example.
4. **So What / CTA** — practical takeaways; end with a genuine question *or* a sharp statement.

**Article formatting**
- Markdown (`##` headers, `**bold**`). Short paragraphs (2-3 sentences). Subheading every
  250-300 words. Max 2 bullet lists; bullets ≤ 15 words.
- Bold lead-ins (**Actionable Tip:** etc.) are *optional* and easily overused; prefer them
  rarely. A **Key Takeaways** section is *optional*, not required, and is itself a mild AI tell.
- Length per option (default 1,000-2,000 words).
- After drafting, run `references/humanization.md`.

**Companion teaser post (≤ 4,000 chars)**
- Hook in line 1 (≤ 140 chars). Tease the article's sharpest point, don't summarise all of it;
  emoji bullets optional (0-3 if used). End with a question or a flat statement. 4-6 hashtags
  from the profile's set. Apply profile stance.

---

## Script (LinkedIn Live)

A fully scripted Live session with precise timing, transitions, and stage directions. Write
every word as it would be spoken — contractions, energy, natural rhythm.

**Structure (30 min default — rescale for a custom duration)**
1. **[INTRO — 3 MIN]** strong hook (never "Welcome everyone") · why this matters now ·
   preview the 3 things viewers leave with.
2. **[SEGMENT 1 — 7 MIN]** open with **[AUDIENCE QUESTION]** · first insight + concrete
   example · practical takeaway · **[TRANSITION]**.
3. **[SEGMENT 2 — 7 MIN]** escalate · **[AUDIENCE QUESTION]** · second insight + case ·
   takeaway · **[TRANSITION]**.
4. **[SEGMENT 3 — 7 MIN]** the most actionable/surprising insight · **[AUDIENCE QUESTION]** ·
   the "so what" — what to do differently tomorrow · takeaway.
5. **[Q&A — 6 MIN]** 3-4 scripted Q&As · one that challenges a common misconception · one
   inviting a real audience experience.
6. **[OUTRO — 2 MIN]** recap the 3 takeaways in one sentence each · single clear CTA · warm
   sign-off (no "That's all folks").

**Formatting & rules**
- Label every section with its timing. Stage directions in brackets: `[PAUSE]`,
  `[LOOK AT CAMERA]`, `[SHOW SLIDE: title]`. `[AUDIENCE QUESTION]` / `[TRANSITION]` on their
  own line. No bullet lists in the body (it's a speaking script). No em dashes, use a pause
  or comma. Apply the profile's stance and voice. After drafting, run
  `references/humanization.md` (rhythm and one risky claim apply to spoken scripts too).

When the user supplies named **participants**, add:
```
## Session Participants
This is a <N>-person discussion. Write with these named participants:
- <name> (<role>)
```
For a custom **duration**, rescale the segment timings proportionally from 3/7/7/7/6/2.

---

## Podcast

A podcast episode package. Produces **three artefacts** in one response — the spoken episode,
the show notes, and a promo post to launch it. Solo or interview format (use the
**participants** option for guests; use **duration** to size the run, default 30 min).

**1. Episode script / outline** (spoken style — contractions, natural rhythm)
1. **[COLD OPEN — 1 MIN]** a sharp hook or pulled-forward moment; never "Welcome to the podcast".
2. **[INTRO — 2 MIN]** who's on, why this episode matters now, the one thing listeners leave with.
3. **[SEGMENTS — the body]** 3-5 talking-point blocks; for an interview, list the **guest
   questions** in order with the angle each is meant to open. One concrete example per block.
4. **[OUTRO — 2 MIN]** recap, where to go next, single clear CTA (per-profile stance).
- Label segments with timing; stage directions in brackets (`[PAUSE]`, `[AD BREAK]`,
  `[GUEST]`). No bullet lists inside spoken passages. No em dashes.

**2. Show notes**
- 2-3 sentence episode summary, a **[timestamps]** placeholder list of the segments, key
  links/resources (for `personal`, links live here, not in any promo post body), and a one-line
  guest bio per participant.

**3. Promo / audiogram teaser post**
- Hook in line 1 (≤ 140 chars) · one pull-quote from the episode · a clear listen CTA. Apply
  the **profile's** hashtag/footer/link rules: branded profiles add hashtags + footer;
  `personal` adds none and keeps links out of the body.

After drafting all three, run `references/humanization.md` (rhythm and one risky claim apply to
the spoken script and the teaser).

---

## Ideate (topic discovery)

Extract **3-6** topics from the supplied source material (article, transcript, notes, feed
item). Only include topics genuinely useful to the **profile's audience**, within the
**profile's topic areas**. For each topic write a summary explaining what it is and **why it
matters** — the "so what".

If the user gives keywords, only surface topics relating to them; skip the rest.

**Output:** one topic per line as `**Title** — 2-3 sentences explaining the topic and its
practical importance`.
