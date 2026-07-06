---
name: osd-architect
description: |
  Generates a full Optimal Solution Design (OSD) from discovery notes and POC results,
  following the ${user_config.company} Industry Solutions OSD template -- every claim tagged
  🟢 Confirmed / 🟡 Proposed / 🔴 Assumption.
  Use when moving from technical validation to solution design, preparing the PS handover
  package, or you say "OSD", "draft the OSD", "solution design", or "technical proposal".
---

# OSD Architect

Generates a full Optimal Solution Design following the Industry Solutions OSD template.
Every claim confidence-tagged. Every assumption flagged.

---

## Step 1 — Intake

Collect (ask if not provided):
1. **Discovery summary** — the confirmed pains, metrics, CBI, stakeholders
2. **POC results** (if available) — use cases tested, outcomes, gaps
3. **Products in scope**: ${user_config.product_a} | ${user_config.product_b} | ${user_config.product_c} | ${user_config.product_d} | subset
4. **Integration landscape**: ERP (SAP, Oracle, other), TMS, customs broker, internal systems
5. **Customer's target go-live or key date** (drives implementation timeline)
6. **Decision-maker and champion** (for executive summary framing)
7. **Prior OSD or proposal** (if this is a revision, paste it)

---

## Step 2 — OSD structure (IS template)

Generate each section in order. Tag every claim per `${CLAUDE_PLUGIN_ROOT}/skills/confidence-tagger/references/confidence-tagging.md`.

---

### Section 1 — Executive Summary (1 page)

```
## Executive Summary

[Customer name] operates [brief description of their trade/supply chain footprint].
🟢/🟡 [Source + confidence]

Their primary challenges are:
1. [Pain 1 — from discovery] 🟢 Confirmed — stated by [name], [date]
2. [Pain 2 — from discovery] 🟢 Confirmed — stated by [name], [date]
3. [Pain 3 — from discovery] 🟡 Inferred — based on [signal]

This Optimal Solution Design proposes [product(s)] to address these challenges,
targeting [key metric outcome] 🟡 Inferred — based on ${user_config.company} reference customers.

Proposed go-live: [date/quarter] 🔴 Unknown — subject to customer IT resourcing

Recommended next step: [specific action]
```

---

### Section 1b — Supply Chain & Trade Map

Include this visual anchor section between the Executive Summary and Current State.
It maps the customer's actual trade footprint — countries, lanes, volumes, flows —
so the solution is grounded in their specific operation, not a generic pitch.

```
## Supply Chain & Trade Map

### Trade Footprint
| Dimension | Detail | Confidence |
|-----------|--------|------------|
| Import countries (top 5) | [list] | 🟢/🟡 |
| Export countries (top 5) | [list] | 🟢/🟡 |
| Annual shipment volume | [estimate] | 🟢/🟡 |
| Annual customs entries | [estimate] | 🟢/🟡 |
| ${user_config.product_d}-eligible trade lanes | [list] | 🟡 Inferred |
| Customs broker(s) | [name(s)] | 🟢/🟡 |

### Product Classification Scope
| Dimension | Detail | Confidence |
|-----------|--------|------------|
| Product categories | [list — apparel, electronics, chemicals, etc.] | 🟢/🟡 |
| HS chapters in scope | [estimated range] | 🟡 Inferred |
| Annual new SKU volume | [estimate] | 🟢/🟡 |
| Current classification method | [manual / GTS / other] | 🟢/🟡 |

### Restricted Party Screening Scope
| Dimension | Detail | Confidence |
|-----------|--------|------------|
| Screening lists in scope | [OFAC, EU, UN, other] | 🟢/🟡 |
| Monthly screening volume | [counterparties screened] | 🟡 Inferred |
| Current false positive rate | [%] | 🟡 Inferred |

### Supply Chain Map Narrative
[2-3 sentences describing the customer's trade flow in plain language:
where goods originate, how they move, where compliance risk concentrates.
Use their exact words from discovery where possible.]

> ⚠️ All volumes and trade footprint data are 🟡 Inferred from public sources and
> discovery conversation unless marked 🟢 Confirmed.
```

---

### Section 2 — Current State Assessment

```
## Current State

### Business Context
[Describe the customer's trade compliance and GTM operational context]
[Confidence-tag every assertion]

### Key Pain Points
For each pain:
| Pain | Business Impact | Current Workaround | Confidence |
|------|----------------|-------------------|------------|
| [pain] | [metric or qualitative impact] | [how they manage today] | 🟢/🟡/🔴 |

### Systems Landscape (as understood)
| System | Function | Status |
|--------|----------|--------|
| [system] | [what it does] | 🟢 Confirmed / 🟡 Inferred |

### Critical Business Issue
[One paragraph: the top-level business problem this solution addresses.
This is the "why now" — regulatory change, audit finding, M&A, cost pressure.]
Confidence: 🟢 Confirmed / 🟡 Inferred
```

---

### Section 3 — Proposed Solution

```
## Proposed Solution

### Solution Overview
[3-4 sentence summary: which ${user_config.company} products, in what configuration, solving which pains]

### Module 1: [Product Name — e.g. ${user_config.product_a} / Automated Product Classification]

**What it does:**
[Description of the product capability, referenced to the customer's specific pain]

**How it addresses [Pain 1]:**
[Specific workflow: current state → with ${user_config.company} → outcome]

**Key capabilities in scope:**
- [Capability 1] 🟢 Confirmed — product documentation, [date]
- [Capability 2] 🟢 Confirmed — product documentation, [date]
- [Capability 3] 🟡 Proposed — subject to configuration in implementation

**Out of scope for Phase 1:**
- [Item] — rationale

---

### Module 2: [Product Name]
[Same structure as Module 1]

---

### Integration Architecture
[Describe how ${user_config.company} connects to the customer's existing systems]

| Integration point | Method | Status |
|------------------|--------|--------|
| [ERP] ↔ ${user_config.company} | [API/flat file/connector] | 🟢 Standard connector / 🟡 TBC |
| [TMS] ↔ ${user_config.company} | [method] | 🟡 Subject to IT scoping |

[Note any integration assumptions explicitly as 🔴 items]
```

---

### Section 4 — Value Case

```
## Value Case

### Value Driver 1: [Name — e.g. Duty Savings]
Type: Hard value (directly measurable)
Confidence: 🟡 Inferred

Calculation:
- Annual import volume: [X entries] 🟢/🟡 [source]
- Current error rate (misclassification): [Y%] 🟡 Inferred — industry norm; customer has not confirmed
- Average tariff rate: [Z%] 🟡 Inferred — based on product category
- Estimated annual duty exposure: $[A]
- Expected reduction with ${user_config.product_a}: [B%] 🟡 Inferred — ${user_config.company} reference customers

**Estimated annual duty savings: $[C]** 🟡 Inferred — validate with customer

---

### Value Driver 2: [Name — e.g. Manual Effort Reduction]
Type: Hard value
Confidence: 🟡 Inferred

Calculation:
- Classification team size: [N FTE] 🟢/🟡 [source]
- % of time on manual classification: [X%] 🟡 Inferred
- Expected AI-assisted time reduction: [Y%] 🟡 Inferred — ${user_config.company} reference: up to 90%
- FTE savings equivalent: [Z]

---

### Value Driver 3: [Name — e.g. Risk Reduction / Compliance Posture]
Type: Soft value (qualitative)
Confidence: 🟡 Inferred

[Description of risk reduction: audit exposure, penalty avoidance, reputational]

---

### Summary
| Value driver | Type | Annual estimate | Confidence |
|-------------|------|----------------|------------|
| [Driver 1] | Hard | $[X] | 🟡 Inferred |
| [Driver 2] | Hard | $[X] | 🟡 Inferred |
| [Driver 3] | Soft | Qualitative | 🟡 Inferred |

> ⚠️ All value figures are indicative estimates based on ${user_config.company} reference customers
> and industry benchmarks. Confirmed figures require customer data validation.
```

---

### Section 5 — Implementation Approach

```
## Implementation Approach

### Phasing
| Phase | Scope | Duration | Key milestone |
|-------|-------|----------|---------------|
| Phase 1 | [products/use cases] | [X weeks] | Go-live 🔴 TBC |
| Phase 2 | [if applicable] | [X weeks] | 🔴 TBC |

### Key Assumptions
List every assumption that affects scope, timeline, or cost. Each is 🔴 until confirmed.

1. Customer will provide [data/access/resource] by [date]
2. ERP integration uses standard API connector (no custom development)
3. IT change-freeze window does not conflict with go-live target
4. [other assumption]

### Risks
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| [risk] | H/M/L | H/M/L | [mitigation] |

### Success Criteria (from POC / discovery)
These are the criteria agreed with the customer. Each should be signed off before go-live.
1. [Criterion 1] — stated by [name], [date]
2. [Criterion 2] — 🟡 Proposed; not yet confirmed by customer
```

---

### Section 6 — Next Steps

```
## Next Steps

| Action | Owner | Target date |
|--------|-------|------------|
| OSD review session with [customer] | [SC name] + [customer sponsor] | [date] |
| Confirm integration architecture | [customer IT] | [date] |
| Confirm success criteria | [customer champion] | [date] |
| Commercial proposal | [AE name] | [date] |
| SOW / contract | [PS + legal] | [date] |
```

---

## Step 3 — Confidence review pass

After completing all sections, run the confidence-tagger:
- Every claim should have a tag
- Every 🔴 Unknown should be in the assumptions or next-steps list
- No value figure presented without a 🟡 or 🟢 tag
- Banner added to any section that is entirely proposed/unconfirmed

---

## Quality checklist

- [ ] Executive summary ≤1 page
- [ ] Every pain sourced to a discovery call date + attendee
- [ ] Every value figure tagged 🟡 Inferred with calculation shown
- [ ] All assumptions listed in Section 5 as 🔴
- [ ] Integration architecture shows confidence level per connection point
- [ ] Success criteria traceable to POC or discovery conversation
- [ ] Next steps have owners and dates (not "TBD")
- [ ] No value figures fabricated — all based on calculation with stated inputs
- [ ] Confidence review pass completed (confidence-tagger skill run)
