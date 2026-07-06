# TMS Discovery Questions — Transport Management System

Based on the [COMPANY] TMS Discovery Document.
7 sections — work through them in order. Not all sections need equal depth on every call.
Section 05 (Project Objectives) is the most commercially critical — never skip it.

---

## SECTION 01 — Transportation Environment
*Modes · Volumes · Carriers · Processes*

### 1.1 — Freight Flow & Volume

| # | Question | Notes |
|---|----------|-------|
| T.1.1 | What is your annual freight spend (USD)? | Core ROI baseline |
| T.1.2 | What is your annual shipment volume? (number of loads or shipments/year) | |
| T.1.3 | What is your inbound vs. outbound split? (e.g. 30% inbound / 70% outbound) | |
| T.1.4 | What is your intercompany or transfer volume (% of total or # of moves)? | |
| T.1.5 | What are your peak seasons? | Implementation timing risk |
| T.1.6 | What is your average load weight? | |
| T.1.7 | Average load cube/volume — does your freight cube-out or weight-out more often? | |

### 1.2 — Transportation Modes & Service Types

| # | Question | Modes / Types |
|---|----------|---------------|
| T.1.8 | Which transportation modes do you use? | TL / LTL / Intermodal / Rail / Parcel / Air / Ocean / Private Fleet / Bulk |
| T.1.9 | Which service types apply? | Ambient / Reefer / Frozen / Flatbed / Bulk / Tanker / Oversized / Hazmat / White Glove |
| T.1.10 | For LTL: what is your freight class range? (Class 50–200 — any density-based auto-classification needs?) | |
| T.1.11 | For Intermodal/Rail: which rail ramp locations do you use? | |
| T.1.12 | For Ocean: which trade lanes? (Trans-Pacific, Trans-Atlantic, Intra-Asia) | |
| T.1.13 | For Air freight: what triggers air shipments? (expedites, weight threshold, lane-specific) | |

### 1.3 — Carrier Base

| # | Question | Notes |
|---|----------|-------|
| T.1.14 | How many active carriers do you work with? | |
| T.1.15 | How many brokers or 3PLs do you use? | |
| T.1.16 | Do you use a third party for carrier management (3PM)? | |
| T.1.17 | Do you have CPU (shipper-load) or collect programs? | Billing complexity |
| T.1.18 | Who are your top 5 carriers? (Name + SCAC code if known) | |
| T.1.19 | What carrier contract structures do you use? (spot, contract, tariff, dynamic pricing) | |
| T.1.20 | Do you have carrier rate files available? | Data readiness |
| T.1.21 | Do you have fuel surcharge schedules for your carriers? | |
| T.1.22 | Do you use spot market / load board platforms? (DAT, Truckstop, Convoy, Uber Freight) | |

### 1.4 — Routing Guides & Carrier Selection

| # | Question | Notes |
|---|----------|-------|
| T.1.23 | Do you have a routing guide in place? (formal, informal, or none) | |
| T.1.24 | How many tiers does your routing guide have? (Primary, Secondary, Spot) | |
| T.1.25 | How many active lanes do you have (approximately)? | |
| T.1.26 | How often is the routing guide reviewed? (annual RFP, quarterly, ad hoc) | |
| T.1.27 | How are carriers selected today — manual or automated? | |
| T.1.28 | Do you run a formal bid or RFP process? What tool do you use? | |

### 1.5 — Appointment Scheduling

| # | Question | Notes |
|---|----------|-------|
| T.1.29 | How are appointments scheduled today? (phone, email, portal, automated) | |
| T.1.30 | Do you manage inbound appointments? Outbound appointments? | |
| T.1.31 | Can carriers self-schedule appointments today? | |
| T.1.32 | Do any retail customers require third-party scheduling? (which retailers?) | |
| T.1.33 | How many dock doors does your largest DC have? Average appointment slots per day? | |
| T.1.34 | Do you have dwell or detention issues? Estimate frequency and cost. | |

### 1.6 — Freight Audit, Pay & Settlement

| # | Question | Notes |
|---|----------|-------|
| T.1.35 | Describe your freight audit process. (in-house, outsourced, or both) | |
| T.1.36 | What is your monthly invoice volume? | |
| T.1.37 | What is your average invoice error rate? (% or $) | ROI driver |
| T.1.38 | If outsourced, who is your audit provider? | |
| T.1.39 | What are your standard payment terms? (Net 30, Net 45) | |
| T.1.40 | Do carriers send EDI 210 invoices? | Integration readiness |
| T.1.41 | How are freight costs allocated to GL codes/cost centres? | ERP integration complexity |
| T.1.42 | Do you use any freight payment platforms? (WebSettle, APEX, other) | |

### 1.7 — OS&D (Overages, Shortages & Damages)

| # | Question | Notes |
|---|----------|-------|
| T.1.43 | What is your estimated OS&D volume per month? | |
| T.1.44 | How do you manage claims today? (manual, software, outsourced) | |
| T.1.45 | What is your average claim value? | |
| T.1.46 | Do you maintain carrier scorecards or KPIs? (OTP, damage rate, tender acceptance) | |

### 1.8 — Sample Data Availability

| # | Question | Notes |
|---|----------|-------|
| T.1.47 | Is shipment data available for analysis? Format? Period? NDA required? | |
| T.1.48 | Are carrier rate files available? | Critical for rate optimisation demo |
| T.1.49 | Is order/PO data available? | |

---

## SECTION 02 — Facilities & Locations
*Network · DCs / Plants · WMS / YMS*

### 2.1 — Network Overview

| # | Question | Notes |
|---|----------|-------|
| T.2.1 | How many ship-from locations? (DCs, plants, supplier DCs) | |
| T.2.2 | How many ship-to locations? (customers, stores, end consumers) | |
| T.2.3 | What is your domestic geography? (CONUS, Canada, Mexico) | |
| T.2.4 | Do you have international lanes? Which regions? | |
| T.2.5 | What is your network type? (Direct / 3PL / Mixed) | |
| T.2.6 | Do you have cross-border requirements? (customs, CTPAT, broker) | |
| T.2.7 | Do you use pool or break-bulk points? Cross-dock? | |
| T.2.8 | Do you have drop trailer programs? At which locations? | |
| T.2.9 | Is a location list or network map available? Format? NDA required? | |

### 2.2 — Facility Types

Confirm which facility types are in scope: Distribution Centre / Manufacturing/Plant / Cross-Dock / Retail Store / Cold Storage / Outdoor Yard / 3PL-Operated / Port/Rail Ramp / Supplier

### 2.3 — Systems at Facilities

| # | Question | Notes |
|---|----------|-------|
| T.2.10 | What WMS is in use? (Name + version) | |
| T.2.11 | Is a Yard Management System (YMS) in use? Which one? | |
| T.2.12 | Is a dock scheduling system in use? Which one? | |
| T.2.13 | What TMS is currently in use? (Name, version, go-live date) | |
| T.2.14 | Why is the existing TMS being replaced? (end of contract, functional gaps, cost, other) | |

---

## SECTION 03 — Order & PO Process
*ERP · Order Flow · Lead Times · Changes*

### 3.1 — Order Entry & Management

| # | Question | Notes |
|---|----------|-------|
| T.3.1 | What is the ERP system and version? (SAP, Oracle, JDE, Dynamics, other) | |
| T.3.2 | Is there a separate OMS? | |
| T.3.3 | How are orders entered? (manual, EDI, API, portal) | |
| T.3.4 | What is the sales order volume per day? Purchase order volume per day? | |
| T.3.5 | Average lines per order? | |
| T.3.6 | What % of orders are international? | |

### 3.2 — Lead Times & Order Changes

| # | Question | Notes |
|---|----------|-------|
| T.3.7 | What is the average order-to-ship lead time? | |
| T.3.8 | What % of orders get modified after entry? What are the most common change types? | |
| T.3.9 | How are order changes communicated? (EDI 860, email, manual) | |
| T.3.10 | Is EDI integration in place for orders (850/856)? | |
| T.3.11 | Is order splitting required? (by weight, cube, pallet) | |
| T.3.12 | Do you have "must-go-together" ship-with requirements? | |

### 3.3 — Commodity & Product Profile

| # | Question | Notes |
|---|----------|-------|
| T.3.13 | What product categories are you shipping? (food, consumer goods, chemicals, industrial) | |
| T.3.14 | Do you ship Hazmat / Dangerous Goods? Which classes? | |
| T.3.15 | Is any freight temperature-sensitive? (Ambient / Reefer / Frozen) | |
| T.3.16 | Are there perishable / shelf-life constraints? | |
| T.3.17 | Are there oversized or special handling requirements? | |
| T.3.18 | Any regulatory compliance needs? (FDA, DOT, USDA, Export Control) | |
| T.3.19 | Are there commodity mixture restrictions? (products that can't co-load) | |

---

## SECTION 04 — Transportation Team
*Org Structure · Users · Responsibilities*

### 4.1 — Team Structure

| Role | Count |
|------|-------|
| Total estimated TMS users | |
| Load planners | |
| Dispatchers | |
| Freight auditors | |
| Carrier management users | |
| Customer service users | |
| IT/Admin users | |
| Executive/Reporting users | |

### 4.2 — Roles & Locations

| # | Question | Notes |
|---|----------|-------|
| T.4.1 | Is the team centralised or distributed across regions? | |
| T.4.2 | What % of users are remote? | |
| T.4.3 | Do carriers need a portal? Suppliers? 3PLs/clients? | |

### 4.3 — Key Stakeholders

| Role | Name / Title |
|------|-------------|
| Executive Sponsor | |
| Project Champion | |
| IT Lead | |
| Finance / Procurement Lead | |
| Carrier Management Lead | |
| Other key stakeholder | |

---

## SECTION 05 — Project Objectives & Business Case
*Goals · ROI · Timeline · Budget*

**This section is the most commercially critical. Never skip it.**

### 5.1 — Drivers & Motivation

Ask the prospect to rank their top 3 drivers:

| Driver | Rank (1=top) |
|--------|-------------|
| Reduce freight cost | |
| Improve carrier visibility / tracking | |
| Automate manual processes | |
| Replace legacy / end-of-life TMS | |
| Improve on-time performance | |
| Support business growth / expansion | |
| Better reporting & analytics | |
| Supplier / vendor compliance | |
| International / global expansion | |
| ERP / WMS integration | |
| Support private fleet | |
| Customer service improvement | |

Key discovery questions:
- "What is the single biggest pain point today — the #1 problem this project must solve?"
- "What happens if you do nothing / stay with the status quo?"
- "Why now? What is driving the urgency?"

### 5.2 — Success Metrics & ROI

| Metric | Target |
|--------|--------|
| Freight cost reduction target | e.g. 5–8% of annual spend |
| On-time performance improvement | e.g. from 82% → 92% |
| Carrier tender acceptance target | e.g. >90% first tender |
| Invoice error rate target | e.g. <1% |
| Load planning time reduction | e.g. 30% fewer manual touches |
| Appointment self-scheduling target | e.g. 50% self-scheduled |
| Expected payback period | e.g. <18 months |
| Expected annual savings | |

### 5.3 — Budget & Timeline

| # | Question | Notes |
|---|----------|-------|
| T.5.1 | Is budget approved, in process, or not yet allocated? | Qualification gate |
| T.5.2 | What is the budget range? | <$150K / $150–$400K / $400K+ |
| T.5.3 | Capex or Opex preference? (SaaS/subscription vs. perpetual licence) | |
| T.5.4 | What is the target go-live date? | |
| T.5.5 | What is the expected implementation timeframe? | 3 months / 6 months / 9+ months |
| T.5.6 | What is the fiscal year end? | Budget cycle timing |
| T.5.7 | Is board or executive approval required, and at what spend threshold? | |

### 5.4 — Competitive Landscape

| # | Question | Notes |
|---|----------|-------|
| T.5.8 | Are other TMS vendors being evaluated? Which ones? | Competitive positioning |
| T.5.9 | What stage is the evaluation at? (RFI, RFP, demo, shortlist) | |
| T.5.10 | When do you plan to select a vendor? | |
| T.5.11 | What are the top 3 decision criteria? (cost, functionality, integration, support, references) | |
| T.5.12 | Do you want customer references in the same industry? | |
| T.5.13 | Is a proof of concept or pilot desirable? | |

---

## SECTION 06 — IT & Integration
*Systems · Architecture · Data · Resources*

### 6.1 — System Landscape

| System | Name & Version |
|--------|---------------|
| ERP | |
| WMS | |
| YMS | |
| OMS / Order system | |
| Current TMS (if any) | |
| Accounting / AP system | |
| BI / Analytics platform | |
| Other relevant systems | |

### 6.2 — Integration Requirements

| # | Question | Notes |
|---|----------|-------|
| T.6.1 | Is ERP integration required? Phase 1 or Phase 2? | |
| T.6.2 | Integration method for ERP? (API, EDI, flat file, middleware) | |
| T.6.3 | Is WMS integration required? Phase 1 or Phase 2? | |
| T.6.4 | Is an EDI carrier network in use? Which provider? (SPS Commerce, OpenText, DiCentral) | |
| T.6.5 | Is real-time tracking integration required? (project44, FourKites, Macropoint) | |

EDI transactions in use (confirm which apply):
- 204 Load Tender / 990 Carrier Response / 214 Shipment Status / 210 Freight Invoice
- 856 ASN / 850 Purchase Order / 810 Invoice / 997 Functional Acknowledgement

### 6.3 — IT Resources & Governance

| # | Question | Notes |
|---|----------|-------|
| T.6.6 | Is there an internal IT team? Integration skillset? | |
| T.6.7 | Is middleware / ESB in use? (MuleSoft, Boomi, TIBCO, Azure) | |
| T.6.8 | Cloud or on-premise preference? | |
| T.6.9 | Is SSO / SAML required? | |
| T.6.10 | Security / compliance requirements? (SOC 2, ISO 27001, FedRAMP) | |
| T.6.11 | Data residency requirements? (US, EU, APAC) | |
| T.6.12 | Custom development appetite? (minimal / moderate / significant) | |

### 6.4 — Data & Reporting

| # | Question | Notes |
|---|----------|-------|
| T.6.13 | What standard reports are needed? (OTP, freight cost, lane analysis) | |
| T.6.14 | Custom / ad hoc reporting required? | |
| T.6.15 | BI tool integration? (Power BI, Tableau, Looker) | |
| T.6.16 | Data retention requirements? (7 years, 10 years) | |
| T.6.17 | Will historical data be migrated from the current TMS? Scope and volume? | |

---

## SECTION 07 — Risks, Opportunities & Next Steps

### 7.1 — Identified Risks

Document any risks that could affect implementation, timeline, or adoption:
- Integration complexity
- Data quality / availability
- Resource constraints (customer side)
- Change management appetite
- Contractual / legal constraints
- Incumbent TMS political protection

### 7.2 — Opportunities & Quick Wins

Document standout opportunities:
- Low-hanging fruit (e.g. freight audit automation immediately saving $X)
- Strategic differentiators
- Expansion potential (new modes, regions, entities)

### 7.3 — [COMPANY] TMS Fit Assessment

| Capability | Fit |
|-----------|-----|
| Routing Guide | High / Med / Low |
| Appointment Scheduling | High / Med / Low |
| Freight Audit / Pay | High / Med / Low |
| Carrier Integration | High / Med / Low |
| ERP Integration | High / Med / Low |
| Reporting / Analytics | High / Med / Low |
| Overall fit notes | |

### 7.4 — Next Steps

| # | Action | Owner | Due Date |
|---|--------|-------|----------|
| 1 | | | |
| 2 | | | |
| 3 | | | |
| 4 | | | |
