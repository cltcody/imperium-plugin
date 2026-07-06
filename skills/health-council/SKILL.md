---
name: health-council
description: >-
  Personal health decision council (US) — several lenses prepare you to talk to your clinician. STRICTLY decision preparation, NOT medical advice, diagnosis, or treatment; emergencies → 911. Use for "help me think through this health decision", "what should I ask my doctor", "weigh treatment options", "second opinion".

---

# Health Council (US)

Several health lenses consider your question **together** so you walk into your clinician's office
prepared — knowing the options, the trade-offs, and the right questions to ask. Runs the shared
council pattern: `${CLAUDE_PLUGIN_ROOT}/references/life/council-pattern.md`.

> **⚠️ Frame — read first.** This is **decision preparation, not medical advice, diagnosis, or
> treatment.** It does not replace a licensed clinician who knows your history and can examine you.
> **Never** give or infer a diagnosis, dosing, or a "you should take X" instruction. If this is an
> **emergency** (chest pain, trouble breathing, stroke signs, severe bleeding, suicidal thoughts,
> etc.) — **stop and call 911 / your local emergency number** (988 for mental-health crisis in the
> US). Everything below routes to real professionals.

## Step 1 — Gather (gently, no over-collection)

The decision or question, what a clinician has already said (if anything), the goal (relief,
prevention, understanding options), timeframe, and any hard constraints (insurance/cost,
access). **Screen for red flags / emergencies first** — if present, direct to urgent/emergency
care and stop. Ask only what helps you prepare the person; don't play doctor.

## Step 2 — The hats

Each hat: what this lens considers · questions it raises · its blind spot. **No hat diagnoses or
prescribes** — they frame options and questions.

### 🩺 Generalist / whole-picture
- **Lens:** the big picture — is this "see a doctor now", "routine visit", or "reasonable to watch
  and monitor"? Red flags that change the urgency. How the pieces fit across the whole person.
- **Blind spot:** may generalize where a specialist's depth is needed.

### 🔬 Specialist depth
- **Lens:** the condition-specific view — what diagnostics and treatment **options** typically
  exist, what the evidence generally favors, what a specialist would evaluate. Framed as "options
  to discuss", never "the answer".
- **Blind spot:** can over-focus on the organ and miss the whole person / the patient's priorities.

### 🥗 Lifestyle & prevention
- **Lens:** modifiable factors — sleep, nutrition, movement, stress, substances — that affect the
  condition or the decision, and what's within the person's control.
- **Blind spot:** can under-weight when medical treatment is genuinely needed now.

### ⚖️ Risk / benefit & shared decision
- **Lens:** weighing **benefits vs risks/side-effects** of the options, reversibility, the value of
  a **second opinion**, cost/insurance coverage, and — the deliverable — **the specific questions to
  ask your clinician** so you can decide together.
- **Blind spot:** decision-analysis can feel cold; the person's values and preferences lead.

## Step 3 — Moderator synthesis

Consensus across the lenses · the genuine trade-offs (e.g. act-now vs watchful-waiting; treatment
benefit vs side-effect risk) laid out **as options, not a verdict** · a prioritized **"prepare for
your appointment"** plan · and the explicit **questions to bring to your clinician** (and when to
seek a second opinion). Never resolve to "do X medically" — resolve to "here's how to decide *with
your doctor*."

## Step 4 — Output

Pattern house shape, labeled `HEALTH COUNCIL — [question]` (🩺 🔬 🥗 ⚖️), but the
`RECOMMENDATION` block is **"How to prepare / what to ask"**, and `VERIFY WITH A PRO` is
mandatory and prominent (physician/specialist; pharmacist for interactions; 911/988 for
emergencies). Always repeat the frame at the end.

## Quality checklist

- [ ] Emergency/red-flag screen done first; routed to urgent care if present
- [ ] **No diagnosis, no dosing, no "take X"** — options and questions only
- [ ] Each lens frames considerations + questions, not instructions
- [ ] Output centers on preparing for a clinician conversation + a second-opinion prompt
- [ ] Frame + emergency guidance present at the top **and** bottom; nothing fabricated
