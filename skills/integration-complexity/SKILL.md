---
name: integration-complexity
description: |
  Assesses a prospect's integration landscape and rates the complexity and risk of connecting to
  ${user_config.company} — maps ERP/WMS/TMS/carrier/customs systems and produces an SC effort
  estimate for PoC and OSD scoping. Use on "assess integration complexity" or "map their
  integrations".
---

# Integration Complexity Assessor

Maps a prospect's system landscape and rates integration complexity before committing to a PoC or OSD.
Stops scope surprises post-sale by making integration risk visible to SC and delivery early.

---

## Connected Tools

| Tool | What it does for you |
|------|---------------------|
| **Salesforce** | Pulls discovery notes and any systems mentioned in opportunity or account records |
| **Confluence** | Checks prior integration patterns for this ERP or WMS version from past deals |

No connections? List the systems you know about below.

---

## Step 0 — Detect before you assess

If the prospect's ERP/WMS/TMS/customs-software landscape is largely unknown, don't leave
Step 1 full of 🔴 Unknowns — spend a few minutes discovering it first:

- **Job postings** — current and recent requisitions (their careers page, LinkedIn Jobs,
  Indeed) routinely name the exact systems in the "requirements" or "nice to have" section
  (e.g. "experience with SAP S/4HANA", "familiarity with Descartes or MIC"). Confidence:
  🟡 — a posting names a system in use or in an active RFP, not necessarily the
  production system of record; corroborate before treating as confirmed.
- **Engineering blogs / case studies** — the prospect's own tech blog, conference talks, or
  a vendor's published customer case study naming them can confirm ERP/middleware choices
  directly. Confidence: 🟡 if third-party (vendor case study may be dated or superseded);
  🟢 only if it's the prospect's own current-tense engineering content.
- **Integration-partner directories** — ERP/TMS vendor partner-and-customer directories
  (e.g. an ERP vendor's implementation-partner marketplace listing the prospect, or a
  systems-integrator's public client list) can surface which platform they run. Confidence:
  🟡 — directory listings lag reality and don't confirm version or scope.
- **LinkedIn role titles** — current employees' titles and "About" sections
  ("SAP GTS Analyst," "NetSuite Administrator," "Descartes Customs Specialist") are a
  strong signal of what's actually operated day-to-day. Confidence: 🟡 — a title implies a
  system is in use, not which version or how central it is.

Treat every system surfaced this way as 🟡 Likely in Step 1's inventory, never 🟢 Confirmed,
until validated directly with the prospect (discovery call, RFP response, or IT contact).

---

## Step 1 — System inventory

Collect what is known. Mark confidence for each system.

```
SYSTEM LANDSCAPE — [Account]

ERP:
  System: [SAP S/4HANA / SAP ECC / Oracle ERP Cloud / Oracle EBS / Microsoft D365 / NetSuite / Other: ___]
  Version / release: [___]   Confidence: 🟢 Confirmed / 🟡 Likely / 🔴 Unknown
  Hosting: Cloud / On-premise / Hybrid
  Customisation level: Heavy / Standard / Unknown

WMS (if relevant):
  System: [Manhattan Active / Blue Yonder / SAP EWM / Warehouse Advantage / Other: ___]
  Version: [___]   Confidence: 🟢/🟡/🔴

TMS (if relevant):
  System: [Oracle TMS / Blue Yonder TMS / Transplace / MercuryGate / Other: ___]
  Version: [___]   Confidence: 🟢/🟡/🔴

Customs / Trade Compliance (current state):
  System: [AEB / SAP GTS / Descartes / MIC / Manual / None / Other: ___]
  Confidence: 🟢/🟡/🔴

Carrier and logistics connections:
  Carrier count: [~N]
  Connection method: EDI / API / 3PL portal / Manual
  Existing 3PL integrations: [list if known]

Other relevant systems:
  [BI / reporting tools, customs portals, government filing systems, e-commerce platforms, etc.]

Integration middleware:
  [MuleSoft / Dell Boomi / SAP PI/PO / Azure Integration Services / IBM MQ / None / Unknown]
```

---

## Step 2 — Complexity rating per integration

Rate each integration on two axes: technical complexity and business risk.

| System | Integration direction | Technical complexity | Business risk | Pre-built connector? | Notes |
|--------|----------------------|---------------------|---------------|----------------------|-------|
| [ERP] | Outbound shipment / classification data | 🔴 High / 🟡 Medium / 🟢 Low | 🔴 High / 🟡 Medium / 🟢 Low | Yes / No / Check with delivery | |
| [WMS] | Inbound status updates | | | | |
| [Carrier EDI] | Standard B2B messages (214, 856, etc.) | | | | |
| [Customs / GTS] | Data migration + live feed | | | | |
| [Government portal] | Filing and status callbacks | | | | |

**Technical complexity drivers:**
- 🔴 High: unsupported ERP version, no standard API, heavy customisation, unknown middleware, legacy architecture
- 🟡 Medium: standard system but older version, partial API coverage, some configuration required
- 🟢 Low: modern cloud ERP/WMS, standard REST/SOAP API available, pre-built connector exists

**Business risk drivers:**
- 🔴 High: integration is on the critical go-live path, no fallback, customer has no IT resource available
- 🟡 Medium: important but can be phased, IT resource available, test environment confirmed
- 🟢 Low: secondary integration, manual fallback available during cutover, can be deferred post-go-live

---

## Step 3 — Overall complexity assessment

```
INTEGRATION COMPLEXITY SUMMARY — [Account]

Overall complexity rating: 🔴 High / 🟡 Medium / 🟢 Low
Primary risk driver: [The single thing most likely to delay go-live]

High-risk integrations (must be explicitly scoped in OSD):
  1. [System + reason]
  2. [System + reason]

Pre-built connectors confirmed available:
  [List — each one reduces SC and delivery effort materially]

Custom development likely required: Yes / Possible / No / Unknown
  If yes: [Which integrations and why]

Relative effort estimate:
  Standard profile (pre-built connectors, modern cloud stack): [Low SC days / Standard delivery]
  Custom profile (legacy systems, non-standard API, unknown middleware): [High SC days / Extended delivery]
  This account's estimated profile: [Low / Medium / High] — confidence: 🟢/🟡/🔴

Discovery questions still unanswered (must resolve before OSD):
  1. [e.g. "Which SAP module owns master data for HS codes?"]
  2. [e.g. "Is there a test environment available for integration testing during PoC?"]
  3. [e.g. "Who owns the middleware layer — internal IT or a managed service provider?"]
```

---

## Step 4 — Risk flags and SC actions

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INTEGRATION RISK FLAGS — [Account]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[ ] Legacy ERP version with no standard API — requires custom connector scoping with delivery
[ ] IT resource unavailable or not yet allocated — delivery risk from day one
[ ] No test / dev environment confirmed — blocks PoC and pre-go-live validation
[ ] Integration middleware not confirmed — may add cost and dependency risk
[ ] Carrier EDI connections required at scale (> 20 carriers) — significant ongoing effort
[ ] Government portal integration required — timeline outside our direct control
[ ] Data migration from legacy customs system — consistently underestimated in deals
[ ] Heavy ERP customisation — standard connector may need modification

Flags found: [list]

RECOMMENDED SC ACTIONS:

Before PoC kickoff:
  [What must be confirmed before starting — e.g. test environment, IT resource, API access]

Before OSD:
  [What must be in scope explicitly — e.g. carrier EDI count, migration scope, middleware owner]

If raising with AE:
  [Any integration risk that affects deal commercials or timeline commitments]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Quality checklist

- [ ] Every major system has a confidence tag — all 🔴 unknowns are on the next discovery call agenda
- [ ] Pre-built connector availability has been verified with delivery or product team, not assumed
- [ ] High-risk integrations are named explicitly — not buried in a footnote
- [ ] Customer's IT availability and test environment status have been asked about directly
- [ ] AE is aware of any integration complexity that affects pricing or timeline commitments
