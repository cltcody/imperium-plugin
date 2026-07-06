---
description: Technical Qualify [FTQ] — 7-dimension scoring before committing SC resources
argument-hint: [opportunity name or description]
---

Run a Functional Technical Qualification (FTQ) assessment for: **$ARGUMENTS**

FTQ is a pre-investment gate. Run it before committing significant SC time (demo
prep, POC, OSD). A deal can look pipeline-positive on ${user_config.qualification_framework} but still fail FTQ —
meaning investing SC resources is premature or risky.

Paste what you know about the opportunity, or answer the questions below interactively.

---

## FTQ Assessment — [Opportunity Name] | [Date]

### Scoring guide
- **5** — Fully confirmed, no risk
- **4** — Mostly confirmed, minor gaps
- **3** — Partially confirmed, notable gaps to fill
- **2** — Largely unknown, significant assumptions
- **1** — Unknown / major red flag

Score ≥ 28 of 35 → **Invest** (proceed with SC resources)  
Score 21–27 → **Conditional** (address gaps before deep investment)  
Score ≤ 20 → **Pause** (qualify further before committing SC time)

---

### Dimension 1: Strategic Fit

Does this opportunity align with our go-to-market motion and product capability?

| Question | Score | Notes |
|---------|-------|-------|
| The customer's use cases map to our products (${user_config.product_a} / ${user_config.product_b} / ${user_config.product_c} / ${user_config.product_d}) | 1-5 | |
| The opportunity is in an industry we actively serve | 1-5 | |
| The deal is within our typical size/complexity range | 1-5 | |

**Subtotal: [X]/15**

---

### Dimension 2: Technical Requirements

Can we actually deliver what they need?

| Question | Score | Notes |
|---------|-------|-------|
| Integration requirements are understood and within standard scope | 1-5 | |
| No showstopper technical requirements (e.g. on-premise only, unsupported platform) | 1-5 | |
| Data availability for AI products (${user_config.product_a}, ${user_config.product_b}) is sufficient | 1-5 | |

**Subtotal: [X]/15**

---

### Dimension 3: Workflow Analysis

Are their processes compatible with how our products work?

| Question | Score | Notes |
|---------|-------|-------|
| Current-state workflows are understood well enough to map to our flows | 1-5 | |
| Change management appetite is present (someone will own adoption) | 1-5 | |
| No major process re-engineering required before they can use the product | 1-5 | |

**Subtotal: [X]/15**

---

### Dimension 4: Pain Points

Is the pain real, urgent, and owned?

| Question | Score | Notes |
|---------|-------|-------|
| A Critical Business Issue (CBI) has been confirmed and quantified | 1-5 | |
| The pain is felt at leadership level (not just a user-level complaint) | 1-5 | |
| There is a compelling event driving urgency (regulatory, audit, M&A, cost) | 1-5 | |

**Subtotal: [X]/15**

---

### Dimension 5: Competitive Situation

Can we win?

| Question | Score | Notes |
|---------|-------|-------|
| We know who else is being evaluated | 1-5 | |
| We have a credible differentiated position | 1-5 | |
| No entrenched incumbent with political protection | 1-5 | |

**Subtotal: [X]/15**

---

### Dimension 6: Implementation Complexity

Can we deliver successfully post-sale?

| Question | Score | Notes |
|---------|-------|-------|
| Implementation complexity is within PS capacity | 1-5 | |
| Customer has internal resourcing available for implementation | 1-5 | |
| Timeline expectation is realistic | 1-5 | |

**Subtotal: [X]/15**

---

### Dimension 7: Culture & Relationship

Is this a customer we can work with and win?

| Question | Score | Notes |
|---------|-------|-------|
| A champion exists who has the will and power to advocate internally | 1-5 | |
| The relationship with the key contact is positive / trust is established | 1-5 | |
| Executive sponsor is accessible or reachable | 1-5 | |

**Subtotal: [X]/15**

---

## FTQ Summary

| Dimension | Score | Max |
|-----------|-------|-----|
| Strategic Fit | | 15 |
| Technical Requirements | | 15 |
| Workflow Analysis | | 15 |
| Pain Points | | 15 |
| Competitive Situation | | 15 |
| Implementation Complexity | | 15 |
| Culture & Relationship | | 15 |
| **TOTAL** | | **105** |

**Weighted recommendation (≥70% = invest):**
- ≥ 74: **INVEST** — proceed with full SC engagement
- 53–73: **CONDITIONAL** — address [top gap] before deep investment
- ≤ 52: **PAUSE** — qualify further; do not commit to demo/POC yet

---

## Top 3 gaps to address before next stage:
1. [Gap + recommended action]
2. [Gap + recommended action]
3. [Gap + recommended action]

---

Confidence-tag every score: 🟢 Confirmed / 🟡 Inferred / 🔴 Unknown.
Every 🔴 score is a gap that needs a plan.
