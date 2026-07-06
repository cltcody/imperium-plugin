---
description: Solution Design [OSD] — generate an Optimal Solution Design from discovery notes and POC results
argument-hint: [account name]
---

Generate an Optimal Solution Design (OSD) for: **$ARGUMENTS**

Run the **osd-architect** skill. Paste discovery summary and POC results if available.

The skill will produce a full OSD following the IS OSD template:
1. Executive summary (1 page)
2. Current state assessment (pains, systems, CBI)
3. Proposed solution (modules, integration architecture)
4. Value case (3+ drivers, hard and soft, tagged 🟡 Inferred)
5. Implementation approach (phasing, assumptions, risks, success criteria)
6. Next steps (with owners and dates)

Every solution claim will be tagged: 🟢 Confirmed / 🟡 Proposed / 🔴 Assumption.
Every assumption listed explicitly.

If discovery summary is not available, the skill will ask for it before generating.
