# Quality gate

**Self-run this gate before presenting any draft and fix every violation** — don't just flag it.

**The gate is profile-aware.** The universal rules apply to every profile; the product-mention
and hashtag/footer rules come from the selected profile in `brand-profiles.md`.

## Universal hard rules (all profiles — auto-fail)

1. **No em dashes (`—`).** Replace with a comma, or rewrite the sentence. Applies to body
   text and stage directions alike.
2. **No hype/AI words** (see blocked list below).
3. **Voice matches the profile** and every insight answers "so what?".

## Per-profile stance

| Profile | Product mentions | English | Hashtags / footer |
|---------|-----------------|---------|-------------------|
| `company` | **Allowed** — name `[COMPANY]` / `[COMPANY_PRODUCT]`, features, honest CTA; no unfounded outcome promises ("guaranteed", "cure", "10x overnight") | your configured variant | company set |
| `personal` | **None** — no product/brand pitch; share because it's worth saying | author's own | **None** — no hashtags, no footer, **no link in the post body** (URL goes in a first comment) |

Pull the exact hashtag list, footer, and any brand-specific banned words from the profile
block in `brand-profiles.md` before running the gate. **Hashtags are profile-conditional:**
branded (`company`) profiles use the set; `personal` requires none (their presence is itself a
fail for `personal`).

## AI patterns to detect and rewrite

This is **pattern detection, not a frozen wordlist.** The words below are current examples;
the underlying tells drift over time, so also flag any newer phrasing that reads as
machine-generated. For the full, maintained lexical/punctuation scan, defer to the **`humanize`
skill** (`${CLAUDE_PLUGIN_ROOT}/skills/humanize/references/ai-tells.md`) — this list is the
LinkedIn-specific quick check.

**Structural tells (the strongest giveaways — rewrite, don't just trim):**
- Forced triads: three parallel items because three "feels complete".
- "It's not X. It's Y." constructions.
- Staccato one-line-paragraphs stacked for false drama.
- Rhetorical question immediately answered in the next line.
- A summary row of emoji bullets; a rainbow of emoji marks.
- Engagement-bait closers ("What are your thoughts? Comment below 👇").
- Scene-setting openers ("In today's fast-paced world", "We've all been there").
- Format-perfect symmetry where every piece marches through the identical arc.

**AI-sounding openers / hype words:**
delve, dive into, unlock, leverage, elevate, explore, craft, navigate, revolutionise,
revolutionize, game-changer, transformative, cutting-edge, groundbreaking.

**Banned post/article openers:**
"I'm excited to share", "Check out my", "Check out my latest article", "Welcome to my
article". For scripts: "Welcome everyone", "I'm so excited to be here".

**Credibility-weakening phrases:**
"honestly", "to be honest", "trust me", "I guarantee", "it depends", "our product is the
best", "it's intuitive", "simple to use", "quick fix", "no problem", "we believe", "I think".

## Structural checks by mode

| Mode | Check |
|------|-------|
| Post | Line 1 hook ≤ 140 chars · 150-300 words (or per length option) · intent chosen (story/observation/take/teach/react/ask) · emoji bullets *optional* (0-3) ≤ 15 words each · "so what" present · ending may be CTA, question, *or* a flat statement · hashtags **per profile** (company: 4-6 from the set; personal: none, no body link) · blank line between sections |
| Article | A coherent structure from system-prompts.md (insight arc / narrative case / myth vs reality) · subheading every 250-300 words · ≤ 2 bullet lists · bullets ≤ 15 words · "Key Takeaways" *optional* · companion teaser ≤ 4,000 chars with its own ≤140-char hook |
| Script | Every section labelled with timing · `[AUDIENCE QUESTION]` opens each segment · `[TRANSITION]` between segments · spoken style, contractions · no bullet lists in the body · timings sum to the target duration |
| Podcast | Three artefacts present (episode script + show notes + teaser) · spoken style, segments labelled with timing · interview questions listed when participants given · show notes carry a `[timestamps]` placeholder + links · teaser hook ≤ 140 chars · teaser hashtags/links **per profile** |
| Ideate | 3-6 topics · each has a clear "so what" · all within the topic areas · keyword filter respected if given |

## Universal checks

- Every insight answers **"so what?"** — a concrete, actionable implication.
- Concrete beats abstract: name regulations, numbers, anonymised scenarios.
- Source material built on naturally — never quoted verbatim or listed mechanically.

## Humanization pass (required after the gate)

The checks above remove what is wrong. They do **not** make a piece sound human. After the
gate passes, run `references/humanization.md` on every Post / Article / Script / Podcast and
rewrite: vary the rhythm, cut the throat-clearing, land one risky claim, break one structural
default, thin the parallelism tics, and confirm every specific is real (not fabricated). A
draft that passes this gate but skips the humanization pass is not finished.

## Article footer (publish-ready only)

Add a footer **only** when the user asks for the publish-ready article, never inside the
drafting prompt. Use the **selected profile's footer** from `brand-profiles.md`:

- `company` → the company footer defined in the profile block (e.g. `[COMPANY] — <tagline / link>`)
- `personal` → **no footer**

Substitute the real URL. If none is given, leave the footer off and note it can be added at
publish time.
