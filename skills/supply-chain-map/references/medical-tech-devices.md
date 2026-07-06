# Medical Tech Devices — Sector Reference for Supply Chain Mapping

**Cluster:** High Tech
**Representative Companies:** Intuitive Surgical, Philips Healthcare, Medtronic, Becton Dickinson, Stryker, Boston Scientific, Siemens Healthineers
**Taxonomy description:** Complicated digital things that are pointed at human biological systems

---

## Typical Make/Buy Split
- High-complexity devices (surgical robots, imaging): 60–80% in-house manufacturing; 20–40% critical sub-assembly outsourced
- Mid-complexity (implants, catheters): 50–70% in-house; rest CMs with strict qualification
- Diagnostics consumables: 40–60% in-house; co-manufacturers for high-volume commoditised items
- Key signal: "sole-source supplier", "critical component", "qualified manufacturing site" in 10-K / MDR filings
- Contract manufacturers must be FDA-registered / ISO 13485 certified — limits CM pool significantly

## Inbound Raw Materials — Typical Modal Split
| Material | Mode | Notes |
|----------|------|-------|
| Specialty metals (titanium, cobalt-chrome) | Air or Ocean FCL | High purity; implant grade; limited suppliers |
| Semiconductors / ASICs | Air | High value; critical function; shortage-sensitive |
| Optical components (lenses, fibre) | Air or Road FTL | Precision; shock-sensitive |
| Plastics / polymers (medical grade) | Road FTL or Ocean FCL | FDA-approved grades only |
| Sterile packaging materials | Road FTL (local) | Sterilisation near point of pack preferred |
| Software / firmware (OTA) | Digital | Increasingly significant; regulatory-controlled updates |

## Distribution Norms
- Strictly regulated distribution: GDP (Good Distribution Practice); ISO 13485 for distributors
- Hospital / IDN (integrated delivery network): direct-to-hospital or through GPO (Group Purchasing Organisation)
- UDI (Unique Device Identification): mandatory in US (FDA), EU (EUDAMED), China — full traceability required
- Consignment at hospital: high-value implants (hip, knee, spinal) often held on consignment at hospital — huge working capital impact
- Field service / loaner sets: surgical instruments shipped to OR for each procedure — complex logistics orchestration
- Cold chain: some biologics-adjacent products require 2–8°C chain

## Outbound Modal Split
| Channel | Mode | Notes |
|---------|------|-------|
| Hospital (acute care) | Road express + courier | UDI-tracked; often same-day for implants |
| Surgery centre (ASC) | Road LTL or courier | Smaller, scheduled volumes |
| GPO / distributor | Road FTL | Bulk contracted supply |
| Home healthcare | Parcel B2C | Wound care, monitoring devices, diagnostics |
| Export (EM/developing markets) | Ocean FCL or Air | Regulatory clearance per country critical |
| Field service (repair parts) | Air express | Uptime SLA; imaging / large capital equipment |

## Air Freight Use Cases (structurally significant — patient safety driver)
- Urgent implant delivery: patient in OR, specific implant size needed — next-flight-out
- Capital equipment parts: MRI, CT scanner downtime unacceptable — parts air-freighted
- Product recall / FSCA: Field Safety Corrective Action requires rapid product retrieval and replacement
- Launch supply: regulatory approval-to-market window is extremely tight

---

## Typical Strategic Ambitions
| Dimension | Typical targets |
|-----------|----------------|
| **Growth** | Expand robotic surgery platform; grow recurring revenue (consumables + services); enter home health and remote monitoring |
| **Efficiency** | Reduce consignment inventory value by 20%; cut emergency logistics spend; improve field service first-time fix rate |
| **New Business Models** | Procedure-based pricing (pay-per-use robotic surgery); integrated service contracts; digital health data monetisation |
| **Market Share** | Win new hospital system contracts; defend installed base against new entrants (Chinese medical devices); expand in APAC and LATAM |
| **Innovation** | AI-assisted diagnostics; next-gen minimally invasive surgical platforms; connected devices with real-world evidence |
| **Digitalisation** | Real-time consignment inventory visibility; automated surgical tray management; UDI-enabled end-to-end traceability |

---

## Common Supply Chain Platforms
| SC Function | Typical Platforms |
|-------------|------------------|
| **Demand Planning** | SAP IBP, o9, Kinaxis, Infor (procedure-based demand signals from hospital data) |
| **Supply Planning** | SAP IBP, OMP Plus, o9 (complex BOM; strict lot-traceability requirements) |
| **Logistics Planning** | Oracle TMS, SAP TM, Blue Yonder (with cold chain and UDI extensions) |
| **Visibility** | FourKites, project44, Descartes (cold chain + GDP compliance tracking) |
| **Control Tower** | o9, SAP IBP, Infor Nexus |
| **Global Trade & Compliance** | SAP GTS, E2open, Descartes (medical device import licences by country) |
| **Supplier Collaboration (VMI-type)** | E2open, Infor Nexus, TraceLink (for serialisation and supplier compliance) |
| **Customer Collaboration (CPFR-type)** | Proprio (surgical planning), Salesforce Health Cloud, hospital system integrations |
| **Scenario Planning** | o9, Kinaxis, Anaplan (capital equipment demand; procedure volume forecasting) |
| **Risk & Resilience** | Resilinc, riskmethods, Everstream (sole-source component risk critical) |
| **Procurement (Direct Materials)** | SAP Ariba, Coupa, Ivalua (qualified supplier management; audit trails required) |

---

## Top 10 Use Cases (Business-Driven)
1. **Implant Availability** — Achieve >99.5% on-time implant availability for scheduled surgical procedures, eliminating OR cancellations
2. **Consignment Working Capital** — Reduce consignment inventory value at hospitals by 25% through real-time usage visibility and automated replenishment
3. **Gross Margin Stability** — Keep product gross margin within ±2% despite component cost increases and logistics cost volatility
4. **Launch on Time** — Bring new device to first clinical use within <4-week variance of regulatory clearance date
5. **Revenue at Risk from Stockout** — Keep revenue at risk from product unavailability below 1% of quarterly procedure volume
6. **Field Service Uptime** — Achieve <4-hour response time for capital equipment (imaging, robotics) critical failures
7. **Recall Execution Speed** — Execute a Field Safety Corrective Action (recall) across all affected customers within 48 hours of decision
8. **Regulatory Compliance Rate** — Achieve 100% UDI capture and lot traceability across all distributed products
9. **Model & React to Supply Disruption** — Re-route production to alternate qualified site within 72 hours of primary site disruption
10. **Home Health Expansion** — Enable cost-effective last-mile delivery to home health patients with >98% on-time, cold-chain-compliant delivery

---

## Regulatory & Compliance Considerations
- FDA 21 CFR Part 820 (QSR) / EU MDR 2017/745: quality system requirements for manufacturing and distribution
- ISO 13485: quality management system standard — required for all manufacturing and distribution partners
- UDI: Unique Device Identification mandatory in US, EU, China — full chain traceability
- EUDAMED: EU device database registration required for market access
- GDP (Good Distribution Practice): mandated for distribution in EU and most regulated markets
- Sterility assurance: validated sterilisation processes (EtO, gamma, e-beam); cold chain for some biologics

## Sustainability Signals to Watch For
- Single-use plastics reduction commitments (surgical drapes, packaging)
- Reusable instrument programmes vs single-use
- Carbon footprint per procedure
- Packaging reduction and recyclability targets
- Supplier diversity and ESG audit programme coverage

## Key Search Queries
```
<company> manufacturing supply chain 10-K sole-source qualified
<company> hospital direct distribution GPO consignment
<company> UDI serialisation traceability compliance
<company> field service loaner set surgical instrument logistics
<company> product recall FSCA field safety corrective action
<company> supply chain planning o9 SAP IBP Kinaxis
<company> contract manufacturer ISO 13485 FDA registered
<company> sustainability single-use circular medical devices
```
