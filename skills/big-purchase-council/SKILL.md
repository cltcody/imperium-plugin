---
name: big-purchase-council
description: A quick council for a significant purchase — car, appliance, gear, tech, anything big enough to think twice about. Four hats (total cost of ownership, need-vs-want, timing & financing, risk & regret) weigh it, then a moderator gives a buy / wait / skip / alternative call. Use for "should I buy [X]", "is [X] worth it", "buy vs lease", "new vs used", "should I finance this", "help me decide on this purchase", "talk me out of / into buying".
---

# Big-Purchase Council

A fast, four-lens gut-check before a meaningful purchase, so you buy for the right reasons or
walk away without regret. Runs the shared council pattern:
`${CLAUDE_PLUGIN_ROOT}/references/life/council-pattern.md`. Default to the pattern's **quick
check** mode (one line per hat + a call) unless the purchase is large or the user wants depth.

## Step 1 — Gather

What it is and the **price**, how it'll be paid (cash / finance / lease), how often it'll get
used, the problem it solves, and what's driving the timing. Ask only what's missing.

## Step 2 — The hats

### 💵 Total Cost of Ownership
- **Mandate:** the real number, not the sticker.
- **Framework:** purchase + financing interest + insurance + maintenance/consumables + energy/
  operating cost + **depreciation/resale** − trade-in. Cost **per use** or per year, not headline.
- **Blind spot:** can talk you out of things that are worth it for non-financial reasons.

### 🧩 Need vs Want
- **Mandate:** is this solving a real problem?
- **Framework:** frequency of use → does a cheaper option do 90% of the job → **buy vs rent /
  borrow / repair** the old one → will this actually get used (be honest).
- **Blind spot:** overly ascetic — a want can be a legitimate reason if named as one.

### ⏳ Timing & Financing
- **Mandate:** when and how to pay.
- **Framework:** buy now vs wait (price cycles, model refreshes, sales) → **new vs used /
  open-box** → cash vs finance (compare the **APR to the return you'd give up**, and factor
  0% promos vs their catches) → lease only when the math and usage fit.
- **Blind spot:** analysis-paralysis; sometimes "good enough now" beats "optimal later".

### 🛡️ Risk & Regret
- **Mandate:** what if it's wrong.
- **Framework:** reliability/reviews → warranty & **return policy** → resale/exit → is it a
  **one-way door or reversible** → the regret test (more likely to regret buying, or not buying?).
- **Blind spot:** over-indexes on worst case; most purchases are reversible.

## Step 3 — Moderator

Consensus · the conflict (usually Numbers vs Need, or Timing vs Regret) resolved for this person ·
one call: **BUY / WAIT / SKIP / ALTERNATIVE** with the one reason that decides it, and the single
thing to check first (price, return window, or a cheaper option).

## Step 4 — Output

Pattern house shape, labeled `BIG-PURCHASE COUNCIL — [item]`, ending in the BUY/WAIT/SKIP/
ALTERNATIVE verdict. Money is in play, so if financing is involved, note "confirm the APR and any
promo catch."

## Quality checklist

- [ ] True cost of ownership computed, not just sticker price
- [ ] Need-vs-want named honestly; a cheaper alternative considered
- [ ] Timing + pay-method addressed (APR vs opportunity cost when financing)
- [ ] One clear verdict (BUY/WAIT/SKIP/ALTERNATIVE) + the deciding reason
- [ ] Effort matched to the purchase size (quick check for small, full for large)
