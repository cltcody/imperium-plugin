---
name: workshop-agenda-builder
description: |
  Builds a structured, time-boxed customer workshop or EBC agenda from a modular section
  library -- Visioning, Value Drivers, Fishbone, Capability Review, Prioritisation, Next
  Steps -- plus facilitator briefs, materials lists, and a pre-workshop checklist.
  Use when you say "build a workshop agenda", "plan an EBC", "customer discovery day", or
  "plan a customer visit", for anything from a half-day session to a 3-day workshop.
---

# Workshop Agenda Builder

Builds a structured, time-boxed agenda for any customer workshop format — from a half-day discovery session to a 3-day EBC. Uses a modular section library with proven facilitation guidance (activities, roles, materials, outputs) for each block.

Use this when you need more than a slide deck: a day with the customer where you want structured outputs — a prioritised problem list, a capability gap heat map, or a roadmap they co-created.

---

## Artifact Mode (Claude.ai)

If running in Claude.ai with artifact rendering available, render the interactive React component from `references/agenda_builder.tsx`. The user configures customer context, selects a duration preset, enables/disables sections, and adjusts timings — the tool generates a live agenda with timestamps and a formatted summary.

---

## Conversational Mode

### Step 1 — Workshop intake

Ask for:
- **Customer name**
- **Industry**
- **Workshop duration** — Half day (4h) / Full day (8h) / 1.5 days / 2 days / 3 days
- **Primary objectives** — what must this workshop achieve?
- **Participants on their side** — titles and seniority
- **Our team** — SC, AE, exec sponsor, facilitator?
- **Known context** — any discovery notes, pain points, or prior conversations to build from?

If any of this was provided earlier in the conversation, proceed without asking again.

---

### Step 2 — Section selection

Based on duration and objectives, recommend which sections to include. Confirm with the user or adjust.

**Section library**

| Section | Category | Default time | When to include |
|---------|----------|-------------|-----------------|
| Welcome & introductions | Intro | 15 min | Always |
| Outside-in perspectives | Inspire | 45 min | Customer needs an external trigger or industry benchmark |
| Visioning & ambitions | Vision | 45 min | Aligning on strategic direction before problem-solving |
| Value drivers | Value | 45 min | Building a shared view of what success looks like |
| Fishbone analysis | Problem | 60 min | Surfacing root causes, not just symptoms |
| Problem statements | Problem | 45 min | After fishbone — converts causes into actionable problem statements |
| Capability review | Capability | 60 min | Assessing current vs. required capability gaps |
| Criteria definition | Prioritise | 30 min | Building a weighted scoring model for initiative ranking |
| Prioritisation & ranking | Prioritise | 60 min | Ranking multiple initiatives with the customer |
| Next steps & roadmap | Next steps | 30 min | Always |
| Closing & reflections | Closing | 15 min | Always |
| Morning break | Break | 15 min | Every ~90 min |
| Lunch break | Break | 45 min | Full day+ only |
| Afternoon break | Break | 15 min | Full day+ only |

**Duration guidance:**
- **Half day (4h):** Welcome + 2–3 substantive sections + Next steps + Closing
- **Full day (8h):** Welcome + Outside-in + Visioning + Value Drivers + Fishbone + Next steps + Closing (+ breaks)
- **1.5 days:** Full day programme + Capability Review + Prioritisation on day 2
- **2–3 days:** Full programme with all sections; use extra time for deep dives and working sessions

---

### Step 3 — Timed agenda

Produce a time-boxed agenda starting at 09:00 (or as specified). Include timestamps, section name, category, duration, and session owner.

```
WORKSHOP AGENDA — [Customer Name]
[Date] | [Location/Virtual] | [Duration]

TIME     SECTION                        CAT         DUR    OWNER
─────────────────────────────────────────────────────────────────
09:00    Welcome & introductions        Intro       15m    Facilitator + Sponsor
09:15    Outside-in perspectives        Inspire     45m    SC / SME
10:00    Visioning & ambitions          Vision      45m    Facilitator
10:45    ☕ Morning break               Break       15m    —
11:00    Value drivers                  Value       45m    Facilitator
11:45    Fishbone analysis              Problem     60m    Facilitator
12:45    🍽 Lunch                       Break       45m    —
13:30    Problem statements             Problem     45m    Facilitator
14:15    Capability review              Capability  60m    SC + Facilitator
15:15    ☕ Afternoon break             Break       15m    —
15:30    Prioritisation & ranking       Prioritise  60m    Facilitator
16:30    Next steps & roadmap           Next steps  30m    AE + Facilitator
17:00    Closing & reflections          Closing     15m    Sponsor
─────────────────────────────────────────────────────────────────
TOTAL: 8h
```

---

### Step 4 — Section briefs

For each enabled section, produce a facilitator brief:

---

**Welcome & introductions** *(15 min)*
- **Objective:** Set context, build rapport, align on the day's purpose
- **Activities:** Sponsor welcome (2 min) → Participant introductions (name + role + one expectation) → Ground rules → Agenda walkthrough
- **Tips:** Keep intros tight — name + role + one expectation only. Display the agenda visually. Set up a parking lot for off-topic items.
- **Roles:** Sponsor (welcome), Facilitator (agenda)
- **Materials:** Printed agenda, name tents, ground rules poster, parking lot flipchart
- **Output:** Aligned group with shared expectations

---

**Outside-in perspectives** *(45 min)*
- **Objective:** Inspire with external perspective before internal problem-solving
- **Activities:** Industry landscape + trends overview → Emerging operating models → AI/technology spotlight → 2–3 provocative "what if?" questions → Open Q&A
- **Tips:** Tailor to the customer's specific industry — generic slides fall flat. End with a question that carries into Visioning.
- **Roles:** SC / SME (presenter), Facilitator (moderator)
- **Materials:** Tailored industry deck, printed key stats handout
- **Output:** Inspired group with shared external context; 2–3 provocative questions for Visioning

---

**Visioning & ambitions** *(45 min)*
- **Objective:** Align on a shared supply chain vision
- **Activities:** Silent keyword writing — individual (3 min) → Keyword clustering on vision map → Dot voting on top themes → Consensus check
- **Tips:** Let the sponsor vote last to avoid anchoring bias. Aim for 3–5 validated clusters. No explanations during voting — just keywords.
- **Roles:** Facilitator (lead), Sponsor (last voter), All participants
- **Materials:** Vision keyword map (A0 poster), sticky notes, dot stickers, sharpies
- **Output:** Prioritised vision keyword map with 3–5 validated clusters

---

**Value drivers** *(45 min)*
- **Objective:** Map strategic imperatives to measurable business outcomes
- **Activities:** Value tree introduction → Small group mapping (3–4 per group) → Cross-group share-back and challenge → Prioritisation
- **Tips:** Challenge vague drivers — push for specificity. Link every driver back to the vision clusters.
- **Roles:** Facilitator, small groups, note-taker per group
- **Materials:** Value tree templates (A1), markers, timer
- **Output:** Completed value tree with ranked strategic drivers

---

**Fishbone analysis** *(60 min)*
- **Objective:** Surface root causes, not just symptoms
- **Activities:** Problem statement framing → Category brainstorm (6M framework: Man, Machine, Method, Material, Measurement, Milieu) → Root cause deep-dive per category → Cross-pollination and pattern identification
- **Tips:** Keep the group in "problem mode" — reject solutions during the fishbone. Use 5-Why if causes are too surface-level. Don't let one person dominate.
- **Roles:** Facilitator (lead), category leads (1 per arm), all participants rotating
- **Materials:** Fishbone template (A0), coloured sticky notes per category, markers
- **Output:** Completed fishbone diagram with prioritised root causes

---

**Problem statements** *(45 min)*
- **Objective:** Transform fishbone outputs into actionable problem statements
- **Activities:** Problem statement writing (individual, "How might we…" format) → Peer review in pairs → Group validation and deduplication → Final statement selection
- **Tips:** Reject statements that are solutions in disguise. Push for specificity — "How might we reduce forecast error below 15%?" not "How might we improve forecasting?"
- **Roles:** Facilitator, all participants (individual + pairs)
- **Materials:** Problem statement cards, pens, validation checklist
- **Output:** 5–8 validated, actionable problem statements

---

**Capability review** *(60 min)*
- **Objective:** Assess current vs. required capabilities against the problem statements
- **Activities:** Capability maturity introduction (1–5 scale) → Current-state assessment per domain → Target-state definition → Gap heat map creation
- **Tips:** Focus on capabilities (what the organisation can do), not tools (what software it runs). Use a capability framework (what the organisation can do, by domain) as the taxonomy.
- **Roles:** Facilitator, SC (capability framework), domain experts, all participants
- **Materials:** Capability matrix template, heat map stickers, scoring guide
- **Output:** Capability gap heat map with priority areas

---

**Criteria definition** *(30 min)*
- **Objective:** Establish and weight evaluation criteria for initiative prioritisation
- **Activities:** Criteria brainstorm → Grouping and selection → Pairwise weighting exercise → Sponsor validation
- **Tips:** Limit to 5–7 criteria maximum. Get sponsor buy-in on weightings before the prioritisation session.
- **Roles:** Facilitator, Sponsor (validation), all participants
- **Materials:** Criteria cards, weighting matrix
- **Output:** Weighted evaluation criteria set (5–7 criteria)

---

**Prioritisation & ranking** *(60 min)*
- **Objective:** Score and rank initiatives with the customer
- **Activities:** Silent scoring (individual, 5 min) → Calibration discussion on outliers → Ranking matrix completion → Top-5 deep dive and validation
- **Tips:** Use silent scoring first, then discuss outliers only. The sponsor breaks ties — not the facilitator.
- **Roles:** Facilitator, Sponsor (tie-breaker), all participants (scorers)
- **Materials:** Scoring matrix, calculators or spreadsheet, ranking board
- **Output:** Prioritised initiative ranking with scores and rationale

---

**Next steps & roadmap** *(30 min)*
- **Objective:** Define actions, assign owners, build a 90-day roadmap
- **Activities:** Action item definition per initiative → Owner assignment and commitment → Timeline mapping (30/60/90-day) → Closing round and reflections
- **Tips:** Every action needs an owner AND a deadline. Don't overcommit — focus on top 3–5 actions. Confirm follow-up meeting date before people leave.
- **Roles:** Facilitator, AE (commercial next step), Sponsor (commitment)
- **Materials:** Action plan template, timeline board, commitment cards
- **Output:** Signed-off action plan with owners, deadlines, and 90-day roadmap

---

### Step 5 — Pre-workshop checklist

```
PRE-WORKSHOP CHECKLIST — [Customer Name]

LOGISTICS
  [ ] Agenda confirmed with sponsor 48h before
  [ ] Room/virtual setup confirmed (breakout rooms, screen sharing)
  [ ] Participant list and roles confirmed
  [ ] Catering confirmed (breaks + lunch if applicable)

MATERIALS
  [ ] Printed agendas for all participants
  [ ] Name tents
  [ ] Ground rules poster
  [ ] Parking lot flipchart
  [ ] Vision keyword map (A0 poster)
  [ ] Fishbone template(s) (A0 format, 1 per group)
  [ ] Value tree templates (A1, 1 per group)
  [ ] Sticky notes (multiple colours)
  [ ] Dot stickers for voting
  [ ] Sharpies and markers
  [ ] Criteria cards + scoring matrix
  [ ] Feedback forms

CONTENT
  [ ] Outside-in presentation tailored to [Industry]
  [ ] Industry benchmarks and statistics confirmed
  [ ] Capability framework ready
  [ ] ${user_config.company} product demos ready (if capability review includes demo slot)
  [ ] Action plan template prepared

OUR TEAM
  [ ] Roles briefed: Facilitator / SC / AE / Sponsor
  [ ] SC has reviewed the capability framework for this account
  [ ] AE has confirmed commercial next step to propose
```

---

## Connected Tools

| Tool | What it adds |
|------|-------------|
| **exec-briefing-prep** | Use for C-suite one-on-ones — structured facilitation is less appropriate for 1:1 EB meetings |
| **demo-storyboard** | If the workshop includes a demo slot, use demo-storyboard to plan the Tell-Show-Tell for that slot |
| **supply-chain-map** | Outside-in section is stronger with a pre-built supply chain map for the customer's industry |

---

## Quality checklist

- [ ] Total time fits within the agreed duration (within 15 min)
- [ ] No section runs >90 min without a break
- [ ] Every section has a named output (what the group leaves with)
- [ ] Materials list is specific and actionable
- [ ] Sponsor role is defined for each major section
- [ ] Outside-in content is industry-tailored, not generic
- [ ] Action plan template is ready before the Next Steps session
- [ ] Follow-up meeting is proposed as part of the Closing
