# GTM Discovery Questions — Global Trade Management

Based on the [COMPANY] GTM Discovery Questionnaire v4 and the FTD methodology.
Modules: Partner Compliance ([PRODUCT_C]) | Product Classification (HTS & ECN) |
         Export Management | Import Management | Trade Agreements ([PRODUCT_D]) | Direct Filing

Use only the modules in scope. Always ask the General section first.
For value calculation, use the volume and maturity fields to seed the ROI model.

---

## MODULE 00 — General (All GTM)

### Scope & Profile

| # | Question | Notes for SC |
|---|----------|-------------|
| G.1 | How many Partners are in your master data? (suppliers, customers, banks, forwarders, employees — any unique partner ID) | Drives [PRODUCT_C] screening volume |
| G.2 | How many Products / SKUs are in your master data? | Drives classification scope |
| G.3 | How many Transactions (export + import combined) per year? (Sales Orders, Deliveries, Shipments, Customs Entries, Commercial Invoices) | Core volume metric for all modules |
| G.4 | How many countries do you export to and import from? | Determines country-specific rule sets needed |
| G.5 | How many Bill of Materials (BOMs) are in scope? | Relevant for [PRODUCT_D] rules-of-origin |
| G.6 | Which ERP systems and versions are in use? (SAP, Oracle, JDE, Dynamics, other) | Drives integration approach |
| G.7 | Are there other systems to integrate? (webshop, PLM, WMS, MDM, other) | Integration scope |
| G.8 | Preferred integration type? (API, XML/EDI, SAP Add-On, flat file) | |
| G.9 | Do you use a middleware or ESB? (MuleSoft, Boomi, TIBCO, Azure, other) | |
| G.10 | Is Single Sign-On (SSO) required? | |
| G.11 | Do external parties (brokers, forwarders) need access to the system? | |
| G.12 | Is IT managed internally or via a third party? | |
| G.13 | Do you use Logistics Service Providers (LSPs) or customs brokers? Which software/providers? | |

### Value Calculation Inputs (General)

| # | Field | Industry Average | Unit |
|---|-------|-----------------|------|
| V.G.1 | What is your industry? (Technology, Manufacturing, Retail, etc.) | — | Text |
| V.G.2 | Average working hours per year | 1,600–2,400 hrs/year | hrs |
| V.G.3 | Full-burdened FTE cost (salary + benefits + overhead) | Varies by country | USD/EUR |

---

## MODULE 01 — Partner Compliance / Restricted Party Screening ([PRODUCT_C])

### Process & Scope

| # | Question | Notes for SC |
|---|----------|-------------|
| R.1 | Describe your current process and systems for denied party / restricted party screening. | Manual, Excel, dedicated tool, outsourced? |
| R.2 | Which screening lists are you checking today? (IMEX standard, premium banking/law enforcement, Dow Jones, Kharon, Acuris, other) | Gaps in list coverage = compliance risk |
| R.3 | Which partner types do you screen? (customers, vendors, banks, visitors, freight forwarders) | Coverage gaps = risk exposure |
| R.4 | Is transactional screening in scope? (webshop one-time buyers, one-time deliver-to addresses) | Only if non-master-data partners exist |
| R.5 | Do you manage grey/blacklists internally? | |

### Volume & Performance

| # | Question | Industry Benchmark |
|---|----------|--------------------|
| R.6 | How do you screen today — manual lookup, periodic batch, or 24/7 continuous? | Best-in-class: 24/7 continuous |
| R.7 | What % of your partners are NOT screened today? | Risk of regulatory fine if >0% |
| R.8 | What is your current false positive rate? | Typical: 5–25% — [COMPANY] [PRODUCT_C]: ~1% |
| R.9 | How long does it take to clear / investigate a screening match? | Benchmark: 15–45 min per match |
| R.10 | How many FTEs are dedicated to screening today? | |
| R.11 | What % of your transactions involve partners not in master data (one-time partners)? | Only if transactional screening is in scope |
| R.12 | What % of your goods go to high-risk countries? (Russia, China, North Korea, certain African regions) | Benchmark: 5–10% triggers higher scrutiny |

### Value Calculation Inputs — [PRODUCT_C]

| # | Field | Notes |
|---|-------|-------|
| V.R.1 | Maturity of current screening process | 1=Manual, 2=Legacy, 3=Stand-alone, 4=Best-of-Breed |
| V.R.2 | % of parties not screened today | Used to quantify fine exposure |
| V.R.3 | % of false positives in current solution | Goes directly to cost-of-screening |
| V.R.4 | Time to clear/process a screening match (minutes) | Benchmark: 15–45 min |
| V.R.5 | FTE load for denied party screening | |

---

## MODULE 02 — Product Classification (HTS & ECCN)

### Scope & Process

| # | Question | Notes for SC |
|---|----------|-------------|
| C.1 | Do products have variants? (different colours, sizes, military vs. civil use under one Product ID) | Affects classification complexity |
| C.2 | Are products single-source or multi-source? | Multi-source may require different classifications per supplier |
| C.3 | What are the distinct sources of product data? Will [COMPANY] send classification responses back to each source system? | Data integration scope |
| C.4 | Do you classify for HTS (import tariff), ECCN (export control), or both? | Determines which modules are needed |
| C.5 | Describe your current organisation, process, and systems for HTS and ECCN classification. | Manual? SAP GTS? Spreadsheet? Outsourced? |
| C.6 | What are your main HS chapters / product families? | Scopes classification complexity |
| C.7 | Are any products subject to other government regulations? (REACH, FDA, DOT, USDA, dual-use, etc.) | % of products affected |
| C.8 | Do you want to identify government licensing requirements for products? | Export license determination scope |
| C.9 | Are products subject to specific documentation, specification, or labelling requirements? | % of products affected |
| C.10 | How many countries require import/export HS/ECN classification? | Drives country rule-set count |

### Volume & Performance

| # | Question | Benchmark |
|---|----------|-----------|
| C.11 | How many products are currently classified with ECN/AL codes? | |
| C.12 | How many export licences are used per year? | |
| C.13 | What % of your products are controlled / licensable? | Risk indicator |
| C.14 | How many FTEs work on product classification? | |
| C.15 | How many FTEs work on export license management? | |

### Value Calculation Inputs — Classification

| # | Field | Benchmark |
|---|-------|-----------|
| V.C.1 | How do you classify today? | 1=Manual, 2=Legacy, 3=Stand-alone, 4=Best-of-Breed |
| V.C.2 | Time to check / correct a false HTS/ECN code | Benchmark: 1–10 min per code |
| V.C.3 | % of HTS/ECN codes currently wrong in the system | Typical: 1–20% |
| V.C.4 | New HTS codes added per year (as % of total SKUs) | Typical: 5–10% |
| V.C.5 | Time to fully classify a new product for all countries | Benchmark: 5–20 min per SKU |
| V.C.6 | Number of unique HS codes across all SKUs and countries | |

---

## MODULE 03 — Export Management

### Organisation & Scope

| # | Question | Notes for SC |
|---|----------|-------------|
| E.1 | Describe your export compliance organisation. (Number of staff, locations, centralised or distributed?) | |
| E.2 | What is your Trade Export Profile — which processes are in scope? | 1=Screening only / 2=Screening + Documents / 3=Screening + Consolidation + Documents / 4=Full with Direct Filing |
| E.3 | What export transaction types do you handle? (orders, deliveries, shipments, consolidated shipments) | |
| E.4 | Describe your process for export license determination. How do you decide which product/shipment requires a licence? | |
| E.5 | Do you have Export Licences (ECCN/HTS-based)? How many? Do you plan to manage them in [COMPANY] GTM? | |
| E.6 | Do your goods cross multiple countries (multi-leg export)? How do you handle that today? | |
| E.7 | Do you want to screen export transactions against import regulations in the destination country? | |
| E.8 | How do you consolidate export shipments? (order → delivery → shipment → consolidated shipment, or none) | |
| E.9 | Describe your document generation process. What standard documents? What exceptions? Who generates them and how are they distributed? | |
| E.10 | How often are export shipments delayed due to compliance issues? What are the main reasons? | |

### Value Calculation Inputs — Export

| # | Field | Benchmark |
|---|-------|-----------|
| V.E.1 | How do you do export checks today? | 1=Manual, 2=Legacy, 3=Stand-alone, 4=Best-of-Breed |
| V.E.2 | Number of export/cross-border transactions per day | |
| V.E.3 | Average value of export shipments | |
| V.E.4 | Number of delayed shipments per day (compliance-related) | |
| V.E.5 | Number of documents created manually per shipment | |
| V.E.6 | Average time to generate documents per shipment | Benchmark: 5–10 min |
| V.E.7 | Number of documents created by freight forwarder per shipment | If FF handles docs |
| V.E.8 | Forwarder document management fee per shipment | Benchmark: $3–5 per packet |
| V.E.9 | Average time to clear a shipment on hold | Benchmark: 10–20 min worst case |
| V.E.10 | FTE load for export management | |

---

## MODULE 04 — Import Management

### Organisation & Scope

| # | Question | Notes for SC |
|---|----------|-------------|
| I.1 | Describe your import compliance organisation. (Number of staff, locations, centralised or distributed?) | |
| I.2 | What is your Trade Import Profile — which processes are in scope? | 1=Global Product Master + Broker integration / 2=Customs Entry Visibility + Auditing / 3=Full Import with broker prep / 4=Full Import with self-filing |
| I.3 | What import shipment types do you handle? | 1=Intra-company / 2=Supplier shipments / 3=Both |
| I.4 | Are incoming shipments consolidated to reduce the number of entries? How is this managed? | |
| I.5 | Describe your process for import licence/permit determination. | |
| I.6 | How often are import shipments delayed due to compliance issues? What are the reasons? | |

### Value Calculation Inputs — Import

| # | Field | Benchmark |
|---|-------|-----------|
| V.I.1 | How do you do import checks today? | 1=Manual, 2=Legacy, 3=Stand-alone, 4=Best-of-Breed |
| V.I.2 | Number of import transactions/entries per day | |
| V.I.3 | Average entry value | |
| V.I.4 | % of shipments handled by external agents/brokers | |
| V.I.5 | Time per shipment to send information to a filing agent | |
| V.I.6 | Average cost per entry | |
| V.I.7 | % of inbound shipments currently on hold | |
| V.I.8 | Average delay per hold | Benchmark: 1–5 days |
| V.I.9 | Labour time per delayed shipment (country-of-origin research, document research) | Benchmark: 10–30 min |
| V.I.10 | FTE load for post-import review | |

---

## MODULE 05 — Trade Agreements / Free Trade Agreements ([PRODUCT_D])

### Scope & Process

| # | Question | Notes for SC |
|---|----------|-------------|
| T.1 | Are you systematically claiming Free Trade Agreements today? If not, what's preventing it? | Duty savings left on the table |
| T.2 | Which FTAs are relevant to your trade lanes? (USMCA, EU-UK, EU-Japan, CPTPP, ASEAN, etc.) | |
| T.3 | How do you currently calculate and document rules of origin for each product? | Manual? SAP GTS? Outsourced? |
| T.4 | Do you have the bill of materials data needed to support [PRODUCT_D] calculations? (BOM lines, supplier country of origin) | Key data dependency |
| T.5 | Do you issue supplier declarations / long-term supplier declarations (LTSDs)? How is this managed? | |
| T.6 | Have you ever been audited on [PRODUCT_D] claims? What did that process look like? | Risk indicator |
| T.7 | What are your primary [PRODUCT_D] export trade lane scenarios? (origin country + destination country + product category) | Needed for [PRODUCT_D] configuration scope |
| T.8 | What are your primary [PRODUCT_D] import trade lane scenarios? | |
| T.9 | What % of your export shipments could qualify for [PRODUCT_D] preference but are not currently claimed? | Opportunity quantification |
| T.10 | What % of your import shipments are claiming [PRODUCT_D] preference today? | Baseline for improvement |

### Value Calculation Inputs — [PRODUCT_D]

| # | Field | Benchmark |
|---|-------|-----------|
| V.T.1 | Annual import duty spend | Drives potential [PRODUCT_D] savings |
| V.T.2 | % of imports that could qualify for [PRODUCT_D] | |
| V.T.3 | Current [PRODUCT_D] claim rate | |
| V.T.4 | Average duty rate on non-preferential lanes | |
| V.T.5 | Time to prepare rules-of-origin documentation per product | |

---

## MODULE 06 — Customs Direct Filing

### Organisation & Scope

| # | Question | Notes for SC |
|---|----------|-------------|
| F.1 | Describe your customs filing organisation. (Number of staff, locations, use of brokers) | |
| F.2 | How do you want to integrate customs filing? | 1=Manual / 2=Semi-automated / 3=Fully automated |
| F.3 | Do you have any special customs authorisations? (Inward Processing / IPR, Outward Processing / OPR, Customs Warehouse / FTZ) | |
| F.4 | In which countries are you filing directly vs. using a broker? | Use the country matrix template |
| F.5 | What declaration types are in scope? | See country matrix: NCTS, import, export, ECS, etc. |

### Value Calculation Inputs — Filing

| # | Field | Benchmark |
|---|-------|-----------|
| V.F.1 | How do you file today? | 1=Manual, 2=Semi-automated, 3=All broker, 4=All self-filing |
| V.F.2 | Number of export declarations per day | |
| V.F.3 | % of export declarations via external broker | |
| V.F.4 | Broker filing fee per export shipment | |
| V.F.5 | Time per shipment for self-filing today | |
| V.F.6 | Number of import entries per day | |
| V.F.7 | % of import filings via external broker | |
| V.F.8 | Broker filing cost per import entry | |
| V.F.9 | Time to send information to broker | Benchmark: 5–15 min |
| V.F.10 | FTE load for export declaration management | |
| V.F.11 | FTE load for import declaration management | |
