---
description: One-page executive summary of a deal or account for leadership
argument-hint: [deal name or account]
---

Generate a one-page executive summary for: **$ARGUMENTS**

Paste deal context, CRM data, or discovery/OSD notes. Or describe the deal situation.

**When saving:** this prints inline by default; if asked to save it, write to
`<deals-workspace>/deals/exec-summary-<name>.md` per the Command Integration Contract in
`${CLAUDE_PLUGIN_ROOT}/references/presales/deals-workspace.md` (config → env → default
`~/code/deals-workspace`) — never into this repo. In a `corporate`-classed repo
(`${CLAUDE_PLUGIN_ROOT}/references/dev/repo-classification.md`), print the one-line
redirect notice first.

## Executive Summary — [Deal/Account Name]

**Date:** [today]  
**Prepared by:** [SC name]  
**Stage:** [current pipeline stage]

### Situation
[2-3 sentences: who is the customer, what do they do, why are they talking to us?]
Confidence-tagged.

### Critical Business Issue
[The top-level problem they need to solve — and why now (compelling event)?]

### Proposed Solution
[Products / modules / scope in 2-3 sentences. Not a feature list — a business outcome statement.]

### Value Case
| Driver | Estimate | Type | Confidence |
|--------|---------|------|------------|
| [Driver 1] | $[X] | Hard | 🟡 Inferred |
| [Driver 2] | $[X] | Hard | 🟡 Inferred |
| [Driver 3] | Qualitative | Soft | 🟡 Inferred |

### Deal Status
| Metric | Status |
|--------|--------|
| ${user_config.qualification_framework} score | [X]/40 |
| Champion identified | Yes / No |
| Economic buyer engaged | Yes / No |
| Compelling event | [date/event] |
| Proposed close | [date] |
| Key risk | [top risk in one line] |

### Recommended Next Step
[One specific action — who does what by when]

---

Format: one page, executive-ready. No jargon. Confidence-tag every metric.
