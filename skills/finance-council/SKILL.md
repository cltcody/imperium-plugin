---
name: finance-council
description: >-
  Personal finance advisory council (US) — investment / budget / planner / tax hats weigh a money decision, then resolve the conflicts into prioritized next steps. Decision preparation, NOT financial or tax advice. Use for "should I invest / pay down debt / buy vs rent", "Roth conversion", "money decision", "finance council".

---

# Finance Council (US)

Four financial experts think about your money decision **together**. Each has its own mandate and
framework; the moderator makes the conflicts between them visible — that's where the real decision
is. Runs the shared council pattern:
`${CLAUDE_PLUGIN_ROOT}/references/life/council-pattern.md` — follow its contract.

> **Frame:** decision **preparation**, not financial, tax, or investment advice. US figures below
> (contribution limits, brackets, thresholds) are orientation and **change yearly — confirm
> current values**. For anything binding → a fee-only CFP and a CPA. The council preps you for
> exactly that conversation.

## Step 1 — Gather (per the pattern)

The decision (specific — "invest $50k", "buy a $500k house"), goal & horizon, income + monthly
surplus, existing assets/debts (with interest rates), emergency fund, and context (risk
tolerance, dependents, job stability; default US). Ask for what's missing; tag assumptions 🟡.

## Step 2 — The hats

Each hat: analysis · a clear call · its blind spot · 1–2 questions back.

### 🎯 Investment Strategist
- **Mandate:** return and risk over the horizon.
- **Framework:** goal → horizon → risk tolerance → asset allocation (stocks/bonds/cash/real
  assets) → diversification → expense ratios (low-cost index default) → **account location**
  (tax-advantaged vs taxable) → rebalancing rule.
- **Watches for:** concentration risk, market-timing illusion, high fees, missing diversification.
- **Blind spot:** ignores liquidity needs and life situation → let the planner check it.

### 🏦 Budget & Cash-flow
- **Mandate:** the household budget and whether the cash actually works.
- **Framework:** income vs expenses → savings rate → **emergency fund (3–6 months of expenses)**
  → for a home: down payment, closing costs (~2–5%), DTI ratio, rate/term, maintenance reserve,
  rent-vs-buy math (don't forget opportunity cost of the down payment).
- **Watches for:** thin buffer, over-stretched financing, forgotten recurring costs.
- **Blind spot:** under-weights the emotional pull of a goal — names only the numbers.

### 🧭 Holistic Planner (fee-only mindset)
- **Mandate:** the whole picture and the right **order of operations**.
- **Framework:** (1) high-interest debt → (2) emergency fund → (3) **capture the full employer
  401(k) match** (free money) → (4) essential insurance (disability, term life if dependents,
  umbrella) → (5) tax-advantaged investing (HSA, Roth/traditional IRA, 401k) → (6) taxable.
  Checks over- and under-insurance.
- **Watches for:** gaps (no disability coverage!), commission-biased products (neutralized here).
- **Blind spot:** can be too conservative → let the strategist push back.

### 🧾 Tax hat (US)
- **Mandate:** the tax consequence of the decision.
- **Framework:** marginal-bracket effect → **pre-tax vs Roth** (tax now vs later) → HSA
  triple-advantage → long-term vs short-term capital gains (LT = held >1 year) → tax-loss
  harvesting & wash-sale rule → backdoor/mega-backdoor Roth where relevant → deduction vs
  standard. All figures: **confirm the current tax year**.
- **Watches for:** avoidable tax, missed account types, wash sales, IRMAA/phase-out cliffs.
- **Blind spot:** optimizes taxes even when it hurts total return ("the tax tail wagging the
  investment dog").

## Step 3 — Moderator synthesis (per the pattern)

Consensus · the **conflicts** and which side wins **in your situation** (e.g. Tax says "buy for
the deduction" vs Strategist says "concentration risk") · one **prioritized** recommendation ·
the 2–4 points to **verify with a fee-only CFP / CPA**.

## Step 4 — Output

Use the pattern's house shape, labeled `FINANCE COUNCIL — [decision]`, with a `THE HATS` block
(🎯 🏦 🧭 🧾), `CONFLICTS`, `RECOMMENDATION (prioritized)`, and `VERIFY WITH A PRO`. Always end
with the frame above.

## Quality checklist

- [ ] Enough numbers gathered to be concrete — else asked (assumptions 🟡)
- [ ] Each hat gives a call **and** its blind spot; abstentions explicit
- [ ] At least one real conflict named and resolved for this situation
- [ ] Order-of-operations respected (debt → emergency fund → match → insurance → tax-advantaged → taxable)
- [ ] US figures flagged "confirm current year"; nothing fabricated
- [ ] "Verify with a pro" list is specific; frame present in the output
