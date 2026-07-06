# GDPR Compliance Report Template

Copy this structure into `[WORKSPACE_DIR]/reports/gdpr/gdpr-report-YYYY-MM-DD.md`. Replace every `<placeholder>`. Delete sections only when genuinely not applicable, and say why in the gap analysis.

---

# GDPR Compliance Assessment — <Project / Feature Name>

**Classification:** Internal — Privacy Review
**Prepared for:** <DPO / GDPR officer / privacy team>
**Assessor:** <name> (engineering-level assessment via Claude Code)
**Date:** <YYYY-MM-DD>
**Scope:** <whole project | feature X | change-set Y>
**Commit:** `<short hash>` on branch `<branch>`

> **Caveat:** This is an engineering-level assessment intended to prepare the
> conversation with the DPO/GDPR officer. It is based on code, schemas, configs,
> and logs as of the commit above. It is **not legal advice** and does not replace
> a formal legal review or DPO sign-off.

---

## Executive Summary

<3–6 paragraphs for a DPO/GDPR officer who has not seen the code:
- What the system/feature does and who its data subjects are.
- What personal data it processes and where that data flows (incl. any LLM/AI providers).
- Overall posture in one sentence (e.g. "broadly sound, with N gaps, M of them high risk").
- The 3–5 items that need attention first.
- Whether a DPIA is indicated.>

**Overall result:** <X COMPLIANT / Y PARTIAL / Z GAP / W NOT APPLICABLE> across 11 dimensions.
**Highest risk finding:** <GDPR-00X — one line>.
**DPIA screening:** <indicated | not indicated | cannot determine from code>.

---

## Data Inventory

| Data element | Category | Source | Storage | Retention | Recipients |
|--------------|----------|--------|---------|-----------|------------|
| <e.g. email address> | Direct identifier | <signup form / API> | <users table, Postgres EU> | <UNKNOWN> | <Sendgrid (US), app DB> |
| <e.g. IP address> | Online identifier | <request middleware> | <access logs> | <90 days / UNKNOWN> | <Datadog (US)> |
| ... | ... | ... | ... | ... | ... |

`UNKNOWN` means the value could not be verified from code or config — see Gap Analysis.

## Processing-Activity Summary

| Activity | Purpose | Data subjects | Data categories | Lawful basis (claimed/assumed) | New to ROPA? |
|----------|---------|---------------|-----------------|-------------------------------|--------------|
| <e.g. account management> | <provide the service> | <customers> | <identifiers, contact data> | <contract Art. 6(1)(b) — to confirm with DPO> | <yes/no> |
| ... | ... | ... | ... | ... | ... |

---

## Status Dashboard

| # | Dimension | Status | Findings |
|---|-----------|--------|----------|
| 1 | Lawful basis & purpose limitation | <COMPLIANT / PARTIAL / GAP / NOT APPLICABLE> | <GDPR-00X or —> |
| 2 | Data minimisation | <status> | <—> |
| 3 | Storage limitation & retention | <status> | <—> |
| 4 | International transfers | <status> | <—> |
| 5 | Processor relationships & DPAs | <status> | <—> |
| 6 | Data subject rights support | <status> | <—> |
| 7 | Special category data | <status> | <—> |
| 8 | Privacy by design & default | <status> | <—> |
| 9 | Records of processing (ROPA) impact | <status> | <—> |
| 10 | Breach-notification readiness | <status> | <—> |
| 11 | Logging & telemetry hygiene | <status> | <—> |

---

## Detailed Findings

### GDPR-001 — <one-line title>

| Field | Value |
|-------|-------|
| **Status** | <PARTIAL / GAP> |
| **Dimension** | <dimension name> |
| **Article(s)** | <e.g. Art. 5(1)(e), Art. 17> |
| **Risk** | <CRITICAL / HIGH / MEDIUM / LOW> |
| **Effort** | <S / M / L> |

**Evidence:** <file:line, schema field, config key, or log statement — concrete and reproducible>

**Why it matters:** <plain-language impact on data subjects and the organisation>

**Remediation:** <concrete, implementable action — what to change, where>

<repeat per finding: GDPR-002, GDPR-003, …>

---

## DPIA Screening Result

**Result:** <DPIA indicated | DPIA not indicated | cannot determine from code>

| Criterion (Art. 35 / WP248) | Fires? | Evidence |
|------------------------------|--------|----------|
| Systematic/extensive profiling or automated decisions with significant effect | <yes/no/unknown> | <…> |
| Large-scale special category or criminal-offence data | <yes/no/unknown> | <…> |
| Systematic monitoring at scale | <yes/no/unknown> | <…> |
| New technologies on personal data (incl. novel AI/LLM use) | <yes/no/unknown> | <…> |
| Dataset matching/combining, vulnerable subjects, or rights-preventing processing | <yes/no/unknown> | <…> |

<If indicated: state that a DPIA should be initiated with the DPO before launch. Do not include a full DPIA here unless requested.>

---

## Gap Analysis — Not Assessable From Code

Items that require organisational, contractual, or legal knowledge. These are open
questions for the DPO/legal — they are NOT rated compliant by assumption.

| # | Open question | Why it cannot be verified here | Who can answer |
|---|---------------|-------------------------------|----------------|
| 1 | <e.g. Is there an executed DPA with <vendor>, and are LLM inputs excluded from training?> | <contract, not code> | <DPO / procurement> |
| 2 | <e.g. Is this activity already covered by an existing ROPA entry?> | <org register, not code> | <DPO> |
| ... | ... | ... | ... |

---

## Remediation Backlog

Ordered by priority: risk first, then effort.

| Priority | Finding | Risk | Effort | Action | Suggested owner |
|----------|---------|------|--------|--------|-----------------|
| 1 | GDPR-00X | <CRITICAL> | <S> | <one-line action> | <engineering / DPO> |
| 2 | GDPR-00Y | <HIGH> | <M> | <…> | <…> |
| ... | ... | ... | ... | ... | ... |

To execute the engineering items, convert this backlog into a PIV plan with `/cc:plan:task`.

---

## Sign-Off

> <One-paragraph closing statement: scope reviewed, number of findings, overall
> recommendation from the engineering side. The decision below belongs to the
> DPO/GDPR officer.>

**Decision:** ☐ Cleared ☐ Cleared with conditions ☐ Blocked

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Assessor (engineering) | <name> | <date> | |
| DPO / GDPR officer | | | |
| Information Security (if required) | | | |

**Conditions (if cleared with conditions):**
- <condition 1>
- <condition 2>

---

*Generated by the `gdpr-check` skill (Claude Code) against the repository state at
commit `<short hash>` on <date>. This document does not constitute legal advice.*
