---
description: Build a value/ROI business case with 3+ value drivers
argument-hint: [account] or paste discovery metrics
---

Build a value/ROI business case for: **$ARGUMENTS**

Paste any confirmed metrics from discovery (team size, volume, error rate, FTE count, etc.).

## Step — Resolve applicable valuation levers (trade/customs/supply-chain deals)

If the discovered pains are trade/customs/supply-chain in nature, match the customer's own
language against the pain→lever map in
`${CLAUDE_PLUGIN_ROOT}/references/domains/trade/valuation/_index.md` before drafting drivers.
For each matched lever, open its file and build the driver from its formula, inputs table, and
worked-example structure rather than inventing one. Before summing more than one lever into the
total, check that index's stacking & double-count matrix — never stack a ⛔ pair, and split
⚠️ pairs per the described rule. Any range pulled from a lever file that hasn't been validated
against this customer's own deal data stays 🟡 per the lever's banner, carried through into the
Summary Table below. Don't inline the library here — resolve, cite the lever file, move on.

## Value Formula (always show this)

```
Value = Potential Value × Probability of Project Success
      = (Benefits – Costs) × Risk Factor

Where:
  Benefits    = hard value (savings, duty reduction, FTE) + soft value (risk, speed)
  Costs       = implementation + licensing + internal resourcing
  Risk Factor = 0.0–1.0 based on: executive sponsorship, champion strength,
                IT complexity, competing priorities, vendor track record
```

Present the Risk Factor explicitly. An unqualified opportunity with a weak champion
and complex IT has a Risk Factor of 0.3–0.5 — the final value case is much smaller
than the raw benefits calculation. Hiding this loses credibility with CFOs.

---

## Output: Value Business Case

### Context
[Customer name, product(s) in scope, deal stage]

### Value Driver 1: [Name — e.g. Duty Savings]
Type: ☐ Hard  ☐ Soft
Confidence: 🟢/🟡

Inputs (confirm with customer or tag 🟡 Inferred):
- [Input 1]: [value] [confidence tag]
- [Input 2]: [value] [confidence tag]

Calculation: [show the math]
**Annual value: $[X]** [confidence tag]

---

### Value Driver 2: [Name — e.g. Manual Effort Reduction]
[Same structure]

---

### Value Driver 3: [Name — e.g. Risk/Compliance Posture]
[Same structure — soft value OK here]

---

### Summary Table
| Value driver | Type | Annual estimate | Confidence |
|-------------|------|----------------|------------|
| [1] | Hard | $[X] | 🟡 |
| [2] | Hard | $[X] | 🟡 |
| [3] | Soft | Qualitative | 🟡 |
| **Total hard value** | | **$[X]** | |

### Caveats
All figures are estimates based on inputs stated above. Confirm with customer before presenting externally.

### Next step to harden the case
[What specific data do we need from the customer to move from 🟡 Inferred to 🟢 Confirmed?]

${user_config.company} reference anchors (tag 🟡 until validated for this customer):
- ${user_config.product_a}: up to 90% reduction in manual classification effort
- ${user_config.product_d}: millions in duty savings for companies with significant ${user_config.product_d}-eligible trade
- ${user_config.product_c}: 80%+ false positive reduction, freeing analyst capacity
- ${user_config.product_b}: near-zero manual re-keying on covered document types
