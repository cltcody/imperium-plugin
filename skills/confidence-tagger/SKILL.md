---
name: confidence-tagger
description: |
  Applies the ${user_config.company} confidence-tagging standard to presales output — every claim
  labelled 🟢 Confirmed, 🟡 Inferred, or 🔴 Unknown — as a final quality pass before material leaves
  the team. Use on "tag this", "confidence check", or "what do we actually know".
---

# Confidence Tagger

Applies the Industry Solutions confidence-tagging standard to any presales output.
Reference spec: `${CLAUDE_PLUGIN_ROOT}/skills/confidence-tagger/references/confidence-tagging.md`

---

## Step 1 — Intake

Ask (or infer from context):
1. What type of output is this? (account brief / discovery summary / OSD / ROI case / battlecard / other)
2. What sources does the user have available? (CRM data, call transcript, public research, internal data)

---

## Step 2 — Scan for untagged claims

Read through the entire input and identify every claim that makes a factual assertion:
- Numeric figures (revenue, team size, volume, cost, percentage)
- System/technology assertions ("they use SAP S/4HANA")
- Timeline or commitment statements ("go-live Q3 2026")
- Customer pain statements ("they spend 3 days per product launch")
- Value/ROI assertions ("will reduce effort by 80%")
- Competitive statements ("competitor X cannot do Y")
- Market/industry statements ("industry norm is 15% error rate")

---

## Step 3 — Apply tags

For each claim:

**🟢 Confirmed** — apply when:
- Sourced from an annual report, press release, or official filing
- Customer stated it directly on a call (cite date + attendee)
- In the CRM and marked as confirmed
- User supplies internal data in this conversation

Format: `[claim] 🟢 Confirmed — [source, date]`

**🟡 Inferred** — apply when:
- Consistent with industry norms for this sector/company size
- Logical implication of a confirmed data point
- Based on indirect signals (job posts, press coverage, analyst estimates)

Format: `[claim] 🟡 Inferred — [reasoning in one line]`

**🔴 Unknown** — apply when:
- Not publicly available
- Not in CRM
- Not supplied by the user
- Required for the output but missing

Format: `[claim] 🔴 Unknown — [what specifically is missing and why it matters]`

---

## Step 4 — Build the gap list

At the end of the output, add a **Gap List** section:

```
## 🔴 Data Gaps (fill these before presenting to customer)

| Gap | Why it matters | How to fill |
|-----|---------------|-------------|
| [description] | [impact on deal/output] | [call, CRM, ZoomInfo, internal SME] |
```

Sort by impact: gaps that affect the core value case first.

---

## Step 5 — Return the tagged output

Return the full document with inline tags added.
Do not rewrite or reorganise the content — only insert tags and the gap list.

If a section is entirely unverifiable (e.g., a speculative competitive claim), flag the whole section with a banner:

```
> ⚠️ This section is entirely inferred. Validate before using in customer materials.
```

---

## Quality checklist

- [ ] Every numeric claim tagged
- [ ] Every technology/system assertion tagged
- [ ] Every customer pain statement tagged (stated vs assumed)
- [ ] Every value/ROI driver tagged (hard vs soft, and confidence level)
- [ ] Gap list present with at least one entry per 🔴 tag
- [ ] No 🟡 claim presented as 🟢 in the gap list
- [ ] No fabricated figures left untagged
