---
description: Draft a POC evaluation plan with use cases, success criteria, owners, and timeline
argument-hint: [use cases or objectives]
disable-model-invocation: true
---

Draft a POC/POV evaluation plan for: **$ARGUMENTS**

## Output: POC Evaluation Plan

### POC Objective
[One sentence: what does success look like for this POC?]

### Use Cases in scope
| # | Use case | Description | Owner (customer) | Owner (${user_config.company}) |
|---|----------|-------------|-----------------|------------|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |

### Success criteria
Each criterion must be:
- Measurable (a number, not "better")
- Agreed and signed off by the customer champion before the POC starts
- Tied to a use case

| Criterion | Measurement method | Target | Use case | Status |
|-----------|------------------|--------|----------|--------|
| | | | | Not started |

**The gate question:** Before starting, ask:
*"If we complete all use cases and satisfy all these criteria, will you select ${user_config.company} as your vendor of choice?"*
If the answer is anything other than yes — clarify what's missing before proceeding.

### Timeline
| Milestone | Date | Owner |
|-----------|------|-------|
| Kick-off | | |
| Environment ready | | |
| Use case 1 complete | | |
| Use case 2 complete | | |
| Use case 3 complete | | |
| Results review | | |
| Decision | | |

### Out of scope
[What this POC does NOT cover — important to protect scope]

### Assumptions and risks
| Assumption/Risk | Mitigation |
|----------------|------------|
| Customer provides test data by [date] | Escalate to champion if delayed |
| IT resources available for integration | Confirm resourcing before kick-off |

Confidence-tag: mark any criterion not yet agreed with the customer as 🔴 Unknown.
