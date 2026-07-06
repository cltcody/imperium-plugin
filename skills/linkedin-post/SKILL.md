---
name: linkedin-post
description: >-
  LinkedIn content engine — ideate, posts, articles, Live scripts, podcast notes, and style reviews, with config-driven voice profiles (personal or company). Use on "write a LinkedIn post/article", "turn this into a post", "draft a Live script", "topic ideas", "review this post".

---

# LinkedIn Content Engine

Create LinkedIn content that sounds like a person, not a template. One engine, several output
modes; the **profile** sets the voice and rules. Personal-voice craft (sound like yourself,
reach-optimized) lives in the `personal` profile and `references/voice-and-tone.md`.

## Philosophy

**What makes content resonate:**
- **Specificity**: concrete details that couldn't be templated (dates, numbers, names, tools)
- **Voice**: your actual way of speaking, not prescribed phrases
- **Genuine intent**: sharing because you have something to say
- **Earned insight**: lessons from actual experience, not theory
- **Personal stakes**: enthusiasm or scepticism signals you care

**What kills content:** templates and formulas, prescribed phrases ("Here's the truth…"),
engagement-bait CTAs, performative vulnerability, abstract advice without grounding.

See `references/style-guide.md` for the full voice & tone guide with examples.

## Step 0 — Pick the profile (required, first thing)

Every request runs under exactly one profile. Infer it from the ask ("a personal post in my
voice", "a post for the company"); if ambiguous, ask. Each profile is defined in
`references/brand-profiles.md` — load its block before drafting. Two ship by default:

- `personal` — your own voice, no brand, no hashtags, no body links.
- `company` — config-driven (`${user_config.company}` / `${user_config.company_product}` from `cc.config.json`); may name
  the product and make an honest CTA.

The profile block overrides Role, Audience, Topics, Voice, Stance, Hashtags, Footer, and Banned
words; it wins on any conflict with the generic mode rules.

## Step 0.5 — Mine the specifics (required before drafting)

Generic, interchangeable content is the #1 reason a post reads as AI-written. Before drafting
any Post / Article / Script / Podcast, secure at least:
- **one real number** (a metric, date, count, price, duration),
- **one real moment or anecdote** (a specific situation, not "a client I worked with"), and
- **one defensible opinion** the reader could disagree with.

Pull these from the source material or by **asking the user**. If they have none and want to
proceed, you may write a more generic piece — but say so and **flag unverifiable claims** rather
than inventing anecdotes, metrics, or testimonials. Never fabricate specifics.

## Step 1 — Pick the mode

| Mode | Output |
|------|--------|
| **Ideate** | 3-6 topics from source material, each a title + 2-3 sentence "so what" |
| **Post** | Standalone post — start from **intent** (see the intents below), hook (line 1 ≤ 140 chars), one idea, optional emoji bullets, ending, per-profile hashtags |
| **Article** | Long-form article (a chosen structure: insight arc / narrative case / myth-vs-reality) + companion teaser post |
| **Script** | Fully scripted LinkedIn Live session — timed segments, stage directions, audience questions |
| **Podcast** | Package — episode script/outline + show notes + promo/teaser post (solo or interview via `participants`) |
| **Review** | Run an existing draft through the (profile-aware) quality gate + humanization pass |

The **structure & output rules** for each mode live in `references/system-prompts.md`. They are
largely profile-independent — compose them with the profile block from Step 0.

## Step 2 — Ground the content (where facts come from)

- **personal:** the author's **real experience** — ask for it, plus `references/voice-and-tone.md`.
  If the user offers no real specifics, ask; never fabricate.
- **company:** real product facts the user supplies (product docs, discovery notes, the value /
  demo / discovery skills). Never invent features, metrics, or customer quotes — flag unverified.
- **custom profile:** whatever grounding source its block names.

## Step 2.5 — Sample the voice (recommended)

To not sound like every other post, sound like one specific person. If the user supplies past
posts or a writing profile, **extract their idiolect** — sentence length, how they open,
punctuation habits, signature phrases, whether they use lists at all — and write to it. See
`references/voice-examples.md` for before/after rewrites per profile. With no sample, fall back to
the profile's voice block, but still apply the humanization pass.

## Step 3 — Compose and generate

1. Load the **mode** structure/output rules from `references/system-prompts.md`.
2. Load the selected **profile block** from `references/brand-profiles.md` — it overrides Role,
   Audience, Topics, Voice, Stance, Hashtags, Footer, Banned words. The profile block wins on any
   conflict (`personal` suppresses hashtags, footer, and body links).
3. If the user gives a **writing profile / extra context**, append it — it refines, never
   overrides, the profile voice.
4. Generate directly in the conversation as clean Markdown.
5. Self-run the **quality gate** (`references/quality-gate.md`) for that profile and fix every
   violation before presenting.
6. Run the **humanization pass** (`references/humanization.md`) on Post / Article / Script /
   Podcast — it runs the `humanize` skill's AI-tell scan, then applies LinkedIn-specific rhythm
   moves. This is what stops the draft reading as AI-generated.

---

## Post-mode intents

For the **Post** mode, start with intent — what are you trying to do?

### Story
You experienced something. You're sharing what happened.
- Starts in a specific moment with real details; includes the messy middle, not just failure →
  success; details that couldn't be made up.
- **Kills it:** hero's-journey arc, performative vulnerability, generic takeaway.

### Observation
You noticed something others might miss.
- Grounded in something specific; your interpretation adds value beyond reporting; can be short.
- **Kills it:** obvious observations framed as unique insights.

### Take
You believe something and want to explain why.
- You actually believe it; you explain your reasoning; you acknowledge where you might be wrong.
- **Kills it:** "Unpopular opinion:" openers, contrarian positioning without substance.

### Teach
You know how to do something specific.
- You've done this recently, in a real context; steps are specific; you acknowledge edge cases.
- **Kills it:** abstract frameworks, teaching things you've only read about.

### React
You're responding to something happening in the world.
- Timely; adds your angle beyond summarising.
- **Kills it:** hot takes without substance, trend-chasing for visibility.

### Ask
You genuinely want to learn something from your audience.
- You actually don't know the answer; the question is specific enough to get useful responses.
- **Kills it:** rhetorical questions disguised as engagement bait.

## Universal requirements (all modes)

### Specificity
Every piece needs at least 2 concrete details: a date/timeframe, a number, a name, a quote, or a
specific place/context. If you can't include specifics, ask whether it's real experience or
abstraction.

### Experience attribution
Be clear about what's yours vs. secondhand: "I tested X and found Y" vs. "Jason Zhou reported X".

### Voice check
Before finalising: "Would I say this exact phrase to a colleague?" · "Does this sound like me or
like a LinkedIn post?" · "Am I using phrases from template guides?" Conversational markers
(parenthetical asides, natural qualifiers, honest admissions) are features, not bugs.

### Endings
End with a value reveal or a flat honest statement — or just stop. **Bad endings:** "Agree or
disagree?" / "What would you add?" / "Thoughts?" (engagement bait).

## Anti-patterns

**Structural signals (readers see these instantly):** emoji at start/end, perfectly parallel
bullets, "broetry" (one sentence per line, every line), a visibly templated hook + body + CTA.

**Rhythm tells:** **em dashes are an LLM giveaway — avoid entirely** (commas, parentheses, or
restructure). Over-punchy staccato is equally suspicious; one punchy moment per post, not a whole
post of them.

**AI/template phrases (kill these):** "I'm thrilled/excited to announce", "Here's what I
learned:", "The lesson?", "This changed everything", "Game-changing", "Deep dive", "Unpack", "At
the end of the day", "It's not about X, it's about Y", "Contrarian take:", "Unpopular opinion:".

**Engagement bait:** "Agree or disagree?", "What would you add?", "Like if you…", "Tag a friend
who…".

## Formatting

Short paragraphs (1-2 sentences); line breaks for readability; no hashtags for `personal`;
**no external links in the post body** (kills ~60% of reach — add the URL as a comment after
engagement builds); no performative bold/symbols.

## Repurposing long-form content

When turning a discovery summary, demo debrief, or win/loss into a post:
- **Do:** follow the same core argument; make the post fully standalone (complete value without
  clicking); adapt pacing for LinkedIn but keep the framing and conclusions.
- **Don't:** summarise into a bland overview; write "Just posted a debrief about…"; make it a
  teaser with no standalone value; include external links in the body.

## Output

- **Ideate:** numbered list of 3-6 topics, each `**Title**` + 2-3 sentence "so what".
- **Post:** post body, blank line between sections; hashtags last for `company`, none for
  `personal` (any URL goes in a first comment).
- **Article:** `# Title`, the Markdown article, then a `---`-separated **Teaser post**.
- **Script:** labelled, timed, spoken script with stage directions.
- **Podcast:** three `---`-separated blocks — **Episode script**, **Show notes**, **Teaser post**.
- **Review:** the corrected draft + a short findings list (what changed and why).

## Quality checklist

- [ ] **Profile chosen** (`personal` / `company` / custom) and its block loaded before drafting
- [ ] Mode structure composed with the profile block (profile block wins conflicts)
- [ ] Grounding source used per profile (`company` → real facts or flagged; `personal` → real experience)
- [ ] **Stance correct:** `personal` = no pitch; `company` = product/CTA allowed, no unfounded promises
- [ ] **Specifics mined** (real number + moment + opinion) — or generic content explicitly flagged, never fabricated
- [ ] **Voice sampled** when the user provided past posts / a writing profile
- [ ] No em dashes; profile-specific banned words *and patterns* avoided
- [ ] **Hashtags/footer/links per profile** — `company` = set; `personal` = none, no link in body
- [ ] Every insight answers "so what?"; hook ≤ 140 chars where required
- [ ] Profile-aware quality gate run and violations fixed
- [ ] **Humanization pass run** (`references/humanization.md`, which invokes the `humanize` skill)

## Related

- `references/style-guide.md` — the full voice & tone guide with examples (Post mode).
- `references/voice-and-tone.md` — personal-voice craft; consulted by the humanization pass and `personal`.
- `humanize` skill — the lexical/punctuation AI-tell scan the humanization pass runs.
- `docx-generator`, `diagram`, `pptx-generator` — export & visuals.
