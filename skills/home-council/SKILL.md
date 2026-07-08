---
name: home-council
description: >-
  Housing decision council (US) — money / life-fit / property / market-timing hats weigh
  buy-vs-rent, renovate, relocate, or refinance. Decision prep, NOT financial or real-estate
  advice. Use for "should I buy or rent", "renovate or move", "home council", "is this house worth
  it".
---

# Home Council (US)

Four housing experts weigh your buy / rent / renovate / relocate decision **together**; the
moderator surfaces where they conflict and resolves it for *your* situation. Runs the shared
council pattern: `${CLAUDE_PLUGIN_ROOT}/references/life/council-pattern.md`.

> **Frame:** decision **preparation**, not financial, tax, or real-estate advice. Rates, tax, and
> market figures are orientation and **change — confirm current values**. For anything binding →
> a mortgage broker, a buyer's agent, a home inspector, and a CPA for relocation tax. Reuses the
> money hats from `finance-council`; if the decision is mostly "where should my money go", start there.

## Step 1 — Gather

The decision (buy / rent / renovate / relocate / refinance), budget & income, current housing
cost, **how long you expect to stay**, down payment available, debts/credit, and what's driving
it (space, job, family, market). Ask for what's missing; tag assumptions 🟡.

## Step 2 — The hats

### 🏦 The Money hat
- **Mandate:** does the math work?
- **Framework:** **buy-vs-rent** — total monthly cost of owning (mortgage P&I + property tax +
  insurance + PMI if <20% down + HOA + **maintenance reserve ~1%/yr**) vs rent **plus the
  opportunity cost of the down payment** → price-to-rent ratio → mortgage (rate, points, DTI) →
  closing costs (~2–5%) → **break-even horizon** (the "~5-year rule": buying rarely wins if you'll
  move sooner). For refinance: break-even months = closing costs ÷ monthly savings.
- **Blind spot:** ignores that a home is also where you live, not just an asset.

### 🧭 The Life-fit hat
- **Mandate:** does this fit your life, not just the spreadsheet?
- **Framework:** expected time in place → job/family/relationship stability → flexibility vs roots
  → commute, schools, space, proximity to people who matter → the real reason you want to move.
- **Blind spot:** can rationalize an expensive emotional choice → let the Money hat check it.

### 🔧 The Property hat (buy / renovate)
- **Mandate:** the physical asset and its costs.
- **Framework:** condition & **inspection** (roof, HVAC, foundation, electrical, plumbing, water
  intrusion) → age of big-ticket systems → for renovation: **ROI by project** (kitchens/baths/
  systems tend to pay back; pools/luxury add-ons rarely do) → don't over-improve for the block →
  maintenance reserve.
- **Blind spot:** focuses on the building, not whether you should buy at all.

### 📍 The Market & Timing hat
- **Mandate:** where and when.
- **Framework:** local market (buyer's vs seller's), rate environment (don't assume you can
  refinance later), **don't bank on appreciation** to justify the deal → for relocation: cost of
  move + **property-tax and state-income-tax differences** (a lower sticker price can hide a higher
  tax state, and vice versa) → contingency for selling the current place.
- **Blind spot:** timing the market is mostly a losing game → weight fundamentals over prediction.

## Step 3 — Moderator synthesis

Consensus · the conflicts (classic ones: Money "renting wins for your horizon" vs Life-fit "you
want to stop moving"; Property "this needs $40k of work" vs Market "but it's underpriced") and
which wins **for you**, with reasoning · one prioritized recommendation · the points to **verify
with a broker / agent / inspector / CPA**.

## Step 4 — Output

Pattern house shape, labeled `HOME COUNCIL — [decision]` (🏦 🧭 🔧 📍), with `CONFLICTS`,
`RECOMMENDATION (prioritized)`, and `VERIFY WITH A PRO`. End with the frame above.

## Quality checklist

- [ ] Buy-vs-rent computed with **total** ownership cost + opportunity cost, not just mortgage vs rent
- [ ] Expected time-in-place drives the break-even call
- [ ] Property condition / renovation ROI addressed when relevant; maintenance reserve included
- [ ] Relocation tax differences surfaced (property + state income tax)
- [ ] One prioritized recommendation; figures flagged "confirm current"; frame present
