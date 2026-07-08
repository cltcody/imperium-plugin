---
name: demo-storyboard
description: |
  Builds a Tell-Show-Tell demo storyboard with Limbic Persona-Based Selling and
  Pain-Capability-Value logic for any ${user_config.company} GTM product. Use on "demo prep",
  "storyboard", "demo script", or "build a demo flow".
---

# Demo Storyboard

Builds a modular, outcome-first demo using Tell-Show-Tell, PIV Loop, and Limbic
Persona-Based Selling. One value module per customer pain. No feature tours.

**Critical rule:** Every SHOW section is narrated in FIRST PERSON as the persona.
"I am Sarah. I open ${user_config.product_a}. I see my queue. I click Run."
NEVER say "you can", "you would", or "you should". The SC steps into the role.

---

## Step 1 — Intake

Collect (ask if not provided):
1. **Discovery summary or pains list** — paste the key pains from the discovery call
2. **Products to demo**: ${user_config.product_a} | ${user_config.product_b} | ${user_config.product_c} | ${user_config.product_d} | full GTM suite
3. **Primary persona in the room** — name, title, company (drives the Limbic character)
4. **Demo type**: Look & Feel (first impression, 20-30 min) | Deep Dive (technical, 45-60 min) | Q&A Session | RFX/Tender Demo
5. **Time available** (typical: 30 min / 45 min / 60 min)
6. **What they've already seen** (prior demo, competitor demo, etc.)
7. **Compelling event** (regulatory deadline, audit, product launch — drives urgency)

**Demo type guidance:**
- **Look & Feel** — first meeting, broad audience, 2-3 modules maximum, emotional impression counts as much as features
- **Deep Dive** — technical evaluators, 4-6 modules, show integration depth, edge cases, config options
- **Q&A Session** — customer drives agenda; have all modules ready but follow their questions
- **RFX Demo** — requirement-mapped, every module traces to a numbered RFP line item

---

## Step 2 — Create the Limbic Persona

Before building any module, define the first-person character for the SHOW narration.

```
DEMO PERSONA
Name: [e.g. Sarah]
Title: [Trade Compliance Director at {company}]
Department: [Global Trade Compliance]
Their stated pain: [exact words from discovery call]
What a great day looks like for them: [the outcome they want]
What a bad day looks like for them: [the pain they live with today]

In the demo, I (the SC) become Sarah. I say:
  "I am Sarah. I run trade compliance for [company]."
  "I have [N] markets, [X] people, and [Y] shipments a month."
  "My problem today is [pain in their own words]."
  "Watch what I do every Monday morning..."
```

---

## Step 3 — Picture Pitch (Opening, 3-5 minutes)

The Picture Pitch anchors the demo in their world before any product is shown.
It is a single image or simple slide that maps to their current-state pain.

```
PICTURE PITCH STRUCTURE

Slide / visual: [one image that resonates — a supply chain map, a document pile,
               a compliance dashboard in chaos, a tariff schedule]

Spoken:
"Before I show you the product, I want to paint a picture of where Sarah's team is today."

"[Current state in 2-3 sentences — use their exact words from discovery if possible]"

"The question we're here to answer today is: what if this could look like [future state]
instead? Let me show you exactly that."

→ Transition: "Sarah — that's me right now — opens ${user_config.product_a} on a Monday morning..."
```

---

## Step 4 — Map pains to value modules (PCV Loop)

For each confirmed or inferred pain from discovery, build one module:

| Pain (from discovery) | Capability (what product does it) | Value (measurable outcome) |
|----------------------|----------------------------------|---------------------------|
| [paste pain 1] | [product feature / workflow] | [time, cost, risk reduction] |
| [paste pain 2] | [product feature / workflow] | [time, cost, risk reduction] |

**Rules:**
- Maximum 3 modules per 30 minutes of demo time (one per confirmed pain)
- Order by: most compelling pain first — not by product feature order
- Each module must stand alone: pain → capability → value, complete in itself
- Never demo a capability without a pain that motivated it

**Reference ${user_config.company} value anchors (tag 🟡 Inferred until confirmed with this customer):**
- Up to 90% reduction in manual classification effort (AI-assisted ${user_config.product_a})
- Millions in duty savings from ${user_config.product_d} optimisation
- 80%+ reduction in ${user_config.product_c} false positives
- ${user_config.product_b}: near-zero manual document re-keying for covered document types

---

## Step 5 — Build the storyboard (Tell-Show-Tell per module)

For each module, complete this template:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MODULE [N]: [Pain name]
Time allocation: [X] minutes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

TELL (the need) — 60 seconds
"Sarah mentioned in our last call that [pain statement in their exact words].
That costs [metric or consequence]. This next module addresses that directly."

SHOW (the capability) — [X-2] minutes
⚠️ FIRST PERSON ONLY. SC narrates AS Sarah, not about her.

"I am Sarah. It's Monday morning. I log into ${user_config.product_a}."
"I have [N] new product classifications waiting in my queue."
"Normally this takes my team three days per SKU. Watch what happens when I click Run."
→ [action 1 — what Sarah does, first person]
→ [action 2 — what Sarah sees, react as Sarah would]
→ [action 3 — the moment of delight — pause here, let it land]
"I just classified that product in 45 seconds — with a confidence score and a full
audit trail that my customs broker can see. Not three days. 45 seconds."

TELL (the value) — 60 seconds
"For Sarah's team running 50 new product launches a year, that's [X days] returned
to higher-value work. 🟡 Inferred — ${user_config.company} reference customers; not yet confirmed for this account.
And the audit trail means Sarah has defensible documentation if customs ever asks."

Pause. 3-5 seconds of silence.
Ask: "Does that match the problem Sarah — and your team — are living with today?"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**The deliberate pause after each second TELL is mandatory.**
Silence after "does that match..." is fine. It is not awkward. Wait for them.

---

## Step 6 — Build the full demo run order

```
DEMO OUTLINE — [Account] | [Date] | [Time available]
Products: [list]
Persona: [primary — name + title]
Demo type: [Look & Feel / Deep Dive / Q&A / RFX]

PICTURE PITCH (3-5 min)
→ One image. Current-state pain. Transition into first-person character.

SITUATION SLIDE (optional — 2 min, show before demo modules if audience is unfamiliar)
"Before I show you the product, let me confirm my understanding of where you are today..."
[one slide: current state → pain → proposed outcome]

MODULE 1: [Name] (X min)
  TELL → SHOW (first-person) → TELL → Pause → "Does that match...?"

MODULE 2: [Name] (X min)
  TELL → SHOW (first-person) → TELL → Pause → "Does that match...?"

MODULE 3: [Name] (X min)
  TELL → SHOW (first-person) → TELL → Pause → "Does that match...?"

SUMMARY VALUE CLOSE (5 min)
"We've shown you three things today. Let me summarise what Sarah — and your team —
would get out of this:
  1. [Module 1 outcome in one line]
  2. [Module 2 outcome in one line]
  3. [Module 3 outcome in one line]
On a scale of 1-10, how well did that address what you described as your biggest challenges?"
→ If <8: "What would make it closer to a 10?"
→ If 8+: "What would need to be true for this to become a priority for you?"
Next step offer: [specific — POC, OSD session, exec briefing] — ask for commitment, not "we'll follow up"
```

---

## Step 7 — Generate the full script

For each module, expand the storyboard into a word-for-word script using first-person narration:

```
[MODULE 1 SCRIPT — ${user_config.product_a} / Classification]

[TELL — spoken]
"Sarah told us in our last conversation that classifying a new product takes her team
three days per SKU — and with 50 new launches a year, that's 150 days of classification
work. Let me show you what that looks like when Sarah uses ${user_config.product_a}."

[SHOW — first-person narration, SC becomes Sarah]
"I am Sarah. It's Monday morning. I open ${user_config.product_a}."
→ Navigate to: Classifications → New Classification Request
"I have a new electronics component that just came into scope — it arrived from our
sourcing team this morning. Normally, I'd spend two to three days researching the HS code,
cross-checking tariff schedules, and documenting my reasoning."
→ Upload sample product spec (use pre-loaded demo file: [filename])
"I click Run. ${user_config.product_a} analyses the product description against the tariff schedule."
→ AI classification runs: pause, let the audience watch the progress indicator
"In 45 seconds — I have an HS code recommendation, a confidence score, the reasoning
behind it, and a full audit trail. I click Accept."
→ One-click accept workflow: show the audit trail generated automatically
"Done. The customs broker already has the documentation in their system."

[TELL — spoken]
"For Sarah's team, that's 50 new product launches classified in hours, not months.
The audit trail means she has defensible documentation if customs ever questions the
classification — and the team's capacity goes back to exceptions and strategy,
not data entry."
[Confidence: up to 90% time reduction — 🟡 Inferred — ${user_config.company} reference customers]

[Pause — 3-5 seconds]
"Does that address the classification cycle time problem your team is dealing with?"
```

---

## Step 8 — Confidence-tag the value claims

Apply `${CLAUDE_PLUGIN_ROOT}/skills/confidence-tagger/references/confidence-tagging.md` to all value statements in the script.

Mark every proof point and metric:
- 🟢 Confirmed — customer stated the metric in discovery
- 🟡 Inferred — based on ${user_config.company} reference customers; not yet confirmed for this account
- 🔴 Unknown — value driver exists but we haven't quantified it yet

---

## Quality checklist

- [ ] Demo type selected and script calibrated to that format (Look & Feel vs Deep Dive vs RFX)
- [ ] Picture Pitch drafted — one image anchored to their current-state pain
- [ ] Limbic persona created — name, title, pain in their words
- [ ] Every SHOW section uses first-person narration: "I am Sarah. I do. I execute."
- [ ] Zero instances of "you can", "you would", "you should" in the SHOW sections
- [ ] Each module follows TELL → SHOW (first-person) → TELL with deliberate pause
- [ ] Maximum 3 modules per 30 min (adjust for available time)
- [ ] All value anchors confidence-tagged
- [ ] Summary Value Close lists all 3 outcomes before asking the 1-10 question
- [ ] Close includes a specific next-step offer with commitment ask (not "we'll follow up")
- [ ] Demo order is: most compelling pain first (not product feature order)
- [ ] Situation slide drafted if persona is unfamiliar with current-state framing
