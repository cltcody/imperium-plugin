# RFP Reference Library

This folder holds approved prior RFP responses that all three RFP commands use automatically:

- `/cc:rfp:analyze` — searches for prior bids against this account or similar requirements
- `/cc:rfp:respond` — checks here before drafting any response section
- `/cc:rfp:present` — pulls proof points and prior win narratives

When this folder is populated, Claude will check it **before generating anything from scratch**, using proven language rather than generic output.

---

## What to add here

Each file should be a single approved response — either a complete RFP response or a reusable section. Name files clearly so Claude can identify them:

```
<AccountName>_<Year>_<RFP-topic>.md      e.g. Maersk_2025_GTM-RFP.md
section_<topic>.md                        e.g. section_implementation-methodology.md
section_<product>_capabilities.md         e.g. section_[PRODUCT_A]-capabilities.md
```

---

## File format

Use this structure so the RFP commands can parse and use each file efficiently:

```markdown
---
account: [Account name or "Generic"]
year: [YYYY]
rfp_topic: [Brief description — e.g. "Global Trade Management Platform"]
outcome: [Won / Lost / No-bid]
products: [[PRODUCT_A], [PRODUCT_B], [PRODUCT_C], [PRODUCT_D] — whichever were in scope]
---

# [Account] RFP Response — [Year]

## Executive Summary
[The approved executive summary text]

## Section: [Section name from the original RFP]
[The approved response text for this section]

## Section: [Next section]
[Approved response text]

## Key proof points used
- [Proof point 1]
- [Proof point 2]

## What worked / lessons learned
[Optional — notes for the team on what resonated with the evaluators]
```

---

## Confidentiality note

These files contain approved commercial content. Treat them as **Internal — Confidential**:
- Do not include specific pricing figures (use ranges or "provided separately")
- Anonymize customer names in proof points unless the customer is a public reference
- Do not include content marked "Not for disclosure" from the original RFP

---

## Getting started

No responses yet? Start with these high-value files:

1. **`section_company-overview.md`** — approved boilerplate about [COMPANY]/[COMPANY]
2. **`section_[PRODUCT_A]-capabilities.md`** — standard [PRODUCT_A] capability description
3. **`section_implementation-methodology.md`** — standard implementation approach
4. **`section_security-and-compliance.md`** — standard security, data protection, SLA text

Ask your RFP / bid management team for approved versions of these sections.
