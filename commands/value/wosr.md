---
description: Deal Review [WOSR] — cross-department deal alignment agenda
argument-hint: [opportunity name]
disable-model-invocation: true
---

Build the WOSR (Weekly Opportunity Solution Review) agenda for: **$ARGUMENTS**

The WOSR is a recurring internal call across SC, AE, Product Management, Development,
and Professional Services. Its purpose is cross-department qualification — qualify in
or qualify out — and to align on what each function needs to do to win the deal.

Paste the current deal status, ${user_config.qualification_framework} scores, and any open questions.

---

## WOSR — [Opportunity Name] | [Date]

**Opportunity owner (AE):** [name]  
**Solution Consultant:** [name]  
**Attendees:** AE, SC, Product Management, PS, [Development if needed]  
**Duration:** 30-45 min  

---

### Agenda

#### 1. Deal snapshot (5 min — AE)

| Field | Value |
|-------|-------|
| Account | |
| Deal value (ARR) | |
| Current stage | |
| Proposed close | |
| Products in scope | |
| Compelling event | |
| Last customer interaction | |

---

#### 2. ${user_config.qualification_framework} health check (10 min — SC + AE)

Current ${user_config.qualification_framework} scores (from `/cc:qualify`):

| Element | Score | Gap | Who owns the fix |
|---------|-------|-----|-----------------|
| Metrics | /5 | | |
| Economic Buyer | /5 | | |
| Decision Criteria | /5 | | |
| Decision Process | /5 | | |
| Paper Process | /5 | | |
| Implicate Pain | /5 | | |
| Champion | /5 | | |
| Competition | /5 | | |
| **Total** | **/40** | | |

**Qualify in / qualify out recommendation:** [INVEST / CONDITIONAL / PAUSE — from FTQ if run]

---

#### 3. Product + development flags (10 min — PM + Dev)

Questions for Product Management:
- Are there any capability gaps between what the customer needs and what's in the product roadmap?
- Are there pending features that could be pulled forward for this deal?
- Are there any known bugs or limitations that could surface in a POC?

Questions for Development (if technical POC or custom requirements):
- Feasibility of [specific requirement]?
- Timeline for [specific fix/feature] if this deal requires it?

**Product team actions:**
| Action | Owner | Due date |
|--------|-------|----------|
| | | |

---

#### 4. PS readiness (5 min — PS)

- Is there PS capacity for an implementation in the proposed timeline?
- Are there known implementation risks for this customer (integration complexity, data quality)?
- Is there an existing PS relationship with this account?

**PS actions:**
| Action | Owner | Due date |
|--------|-------|----------|
| | | |

---

#### 5. SC next steps (5 min — SC)

- Demo status: [not started / scheduled / completed / follow-up outstanding]
- POC status: [not started / scoping / in progress / complete]
- OSD status: [not started / in draft / under review / presented]
- Open technical questions: [list]

**SC actions:**
| Action | Owner | Due date |
|--------|-------|----------|
| | | |

---

#### 6. Decision: qualify in or out (5 min — all)

**Recommendation:** [QUALIFY IN — continue investment / QUALIFY OUT — too early / EXIT — wrong fit]

**Rationale:**
[One paragraph explaining the recommendation based on FTQ + ${user_config.qualification_framework} scores]

**If qualifying in: commit to next WOSR date:** [date]
**If pausing: re-qualification trigger:** [what needs to be true to re-engage]

---

Confidence-tag all intelligence: 🟢 Confirmed / 🟡 Inferred / 🔴 Unknown.
