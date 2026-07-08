---
name: council
description: >-
  Convene a personal decision council for any dilemma — assemble expert "hats", resolve the
  conflicts into one recommendation. Use on "help me decide", "should I…", "I'm torn between", or
  any genuine trade-off. Money, purchases, home, and recurring costs have dedicated councils —
  prefer those.
---

# Personal Decision Council (general engine)

Bring any real decision; this convenes the **right** panel for it, reasons from each expert lens,
and — the part that matters — **resolves the conflicts between the lenses** into one clear
recommendation. It runs the shared **council pattern**:
`${CLAUDE_PLUGIN_ROOT}/references/life/council-pattern.md` — read it and follow the contract.

Use this when there's no dedicated council. If the decision is squarely financial, a purchase, a
home question, or a recurring-cost review, route to the specific skill (they carry curated hats +
US anchors): `finance-council`, `big-purchase-council`, `subscriptions-audit`, `home-council`.

## How it works

1. **Frame the decision** (pattern Step 1). Get the specific choice, the goal & timeframe, the
   hard constraints/numbers, and the context. Ask for what's missing; don't guess.
2. **Assemble the panel.** Pick 3–5 hats that genuinely bear on *this* decision — invent the
   roster to fit the question. Each hat needs a **mandate**, a **framework**, and a named
   **blind spot**. Examples of hats to draw from (not a fixed list — compose what fits):
   - **The Numbers hat** — cost/benefit, opportunity cost, downside math.
   - **The Risk hat** — what breaks, worst case, reversibility, insurance against it.
   - **The Values hat** — does this fit what the person actually wants long-term, not just the optimal spreadsheet answer.
   - **The Time hat** — effort, timing, second-order time costs, "future you".
   - **The Skeptic** — steelmans *not* doing it / the status-quo option.
   - **The Domain expert** — whatever specialist the decision demands (a clinician, a lawyer, a mechanic, a recruiter…), flagged as orientation not professional advice.
   State which hats you convened and why; a lens with nothing to add abstains explicitly.
3. **Run the hat round** (pattern Step 2) — each hat: analysis, a call, its blind spot, 1–2 questions back.
4. **Moderate** (pattern Step 3) — consensus, the **conflicts and how they resolve for THIS
   person's situation**, one prioritized recommendation, and — if the decision touches money,
   health, law, or insurance — a "verify with a pro" list.
5. **Output** in the house shape from the pattern; end with the liability frame when relevant.

## Notes

- The value is in the **conflicts**, not the summary. If the hats all agree, you probably picked
  too-similar hats — add a genuine skeptic or a different lens.
- Match effort to the decision: a small choice gets the **quick check** mode (one line per hat +
  a call); a life decision gets the full council.
- Never fabricate specifics (numbers, deadlines, medical/legal thresholds) — ask, or mark 🟡 and
  route to a professional.

## Quality checklist

- [ ] Panel fits *this* decision (composed to the question, not a boilerplate roster)
- [ ] Each hat has a mandate, a call, and a named blind spot
- [ ] At least one real conflict surfaced and resolved for the person's situation
- [ ] One prioritized recommendation; effort matched to the decision's weight
- [ ] Specifics asked for, never invented; liability frame present when money/health/law/insurance is in play
