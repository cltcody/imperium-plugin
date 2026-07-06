# Semiconductors — Sector Reference for Supply Chain Mapping

**Cluster:** High Tech
**Representative Companies:** Infineon, Intel, TSMC, Samsung Semiconductor, ASML, NXP, Qualcomm, AMD
**Taxonomy description:** Unbelievably complicated digital things, sold to businesses to put in other digital things

---

## Typical Make/Buy Split
- **Fabless model** (Qualcomm, AMD, Apple silicon): 100% outsourced to foundries (TSMC, Samsung, GlobalFoundries)
- **IDM model** (Intel, Infineon, NXP): 50–80% own fabs; remainder at external foundries for overflow/specialty nodes
- **Pure-play foundry** (TSMC): 100% contract manufacturing — no own product design
- Key signal: "fabless" vs "IDM" classification in company filings; foundry partner named in risk factors
- Packaging and test (OSAT): typically outsourced to ASE, Amkor, JCET even for IDMs

## Inbound Raw Materials — Typical Modal Split
| Material | Mode | Notes |
|----------|------|-------|
| Silicon wafers | Road FTL or Air | Ultra-pure; shock-sensitive; regional sourcing preferred |
| Specialty gases (high-purity) | Pipeline or Road (cryogenic tanker) | On-site or very short-haul |
| Photomasks | Air (specialist courier) | High-value, precision — never ocean |
| Chemical mechanical planarization (CMP) slurries | Road FTL | Bulk liquid, weight-sensitive |
| Rare metals (cobalt, tungsten, ruthenium) | Air or Ocean FCL | High value; geopolitical sensitivity |
| Packaging substrates | Air or Ocean FCL | Critical path; substrate shortage = chip shortage |
| Lead frames / wire bond | Ocean FCL | Commodity; regional near OSAT |

## Distribution Norms
- Wafer-level to die-level: internal wafer logistics between fab → OSAT (usually regional Air or road)
- Finished chip to customer: predominantly Air for high-value; Ocean FCL for commodity/mature nodes
- Hub model: bonded warehouse in SG, NL, or US — customer pulls to order
- Consignment at customer (VMI at customer fab) common for strategic accounts
- Extremely tight temperature and humidity controls throughout chain (cleanroom packaging)

## Outbound Modal Split
| Channel | Mode | Notes |
|---------|------|-------|
| OEM / Tier 1 (automotive, industrial) | Air or Road | JIT pull; zero tolerance for line stoppage |
| EMS / ODM (electronics assembly) | Air (short-term) / Ocean (long-term) | Depends on allocation and lead time |
| Distribution (Avnet, Arrow, Future) | Ocean FCL or Air | Franchise distribution; stocking agreements |
| Direct to fabless customers | Air (priority) | Wafer/die shipped directly under NDA |

## Air Freight Use Cases (structurally high vs other sectors)
- New node ramp: first production lots air-freighted to anchor customer for qualification
- Allocation crises: any shortage situation — chips fly to prevent automotive/medical line stoppage
- Sample / engineering lots: always air (time to market critical for customer design-in)
- End-of-life (EOL) orders: customers air-freight last-time-buy (LTB) stock

---

## Typical Strategic Ambitions
| Dimension | Typical targets |
|-----------|----------------|
| **Growth** | Win new design-ins at hyperscalers and automotive OEMs; expand into adjacent node capabilities |
| **Efficiency** | Improve fab utilisation above 85%; reduce cycle time; lower COGS per wafer start |
| **New Business Models** | Chiplet architectures; IP licensing revenue; foundry-as-a-service for captive demand |
| **Market Share** | Capture next-generation automotive (EV/ADAS), AI/ML accelerator, and IoT socket wins |
| **Innovation** | Accelerate node shrink roadmap; develop 3D packaging; co-design with anchor customers |
| **Digitalisation** | Real-time fab visibility; AI-driven yield optimisation; digital twin of wafer process |

---

## Common Supply Chain Platforms
| SC Function | Typical Platforms |
|-------------|------------------|
| **Demand Planning** | o9, Kinaxis, SAP IBP, Anaplan, proprietary capacity planning tools |
| **Supply Planning** | Kinaxis, OMP Plus, o9, proprietary fab scheduling systems (MES-linked) |
| **Logistics Planning** | Oracle TMS, SAP TM, Blue Yonder, DHL MySupplyChain |
| **Visibility** | FourKites, project44, Descartes (for high-value Air shipments) |
| **Control Tower** | Kinaxis, o9, SAP IBP, E2open |
| **Global Trade & Compliance** | SAP GTS, E2open, Descartes, MIC (critical: export controls, EAR/ITAR, Wassenaar) |
| **Supplier Collaboration (VMI-type)** | E2open, Infor Nexus, proprietary supplier portals |
| **Customer Collaboration (CPFR-type)** | E2open, proprietary VMI portals at customer fab; Salesforce-based order visibility |
| **Scenario Planning** | Kinaxis, o9, Anaplan |
| **Risk & Resilience** | Resilinc, Everstream, D&B Supply Chain Intelligence, SEMI Risk tools |
| **Procurement (Direct Materials)** | SAP Ariba, Coupa, Ivalua (wafer, gas, chemical contracts) |

---

## Top 10 Use Cases (Business-Driven)
1. **Fab Utilisation Optimisation** — Maintain fab utilisation above 85% while absorbing ±25% demand variability without excess inventory build
2. **Allocation Management** — Allocate constrained supply fairly across customers with <2% revenue at risk from mis-allocation
3. **Cycle Time Compression** — Reduce wafer-to-ship cycle time by 10% without yield impact to improve cash conversion
4. **Yield Ramp on New Node** — Hit target yield on new process node within 6 months of production ramp
5. **Working Capital Reduction** — Reduce WIP inventory by 15% through better fab scheduling and hot-lot prioritisation
6. **Customer Revenue at Risk** — Keep allocated customer revenue at risk from supply disruptions below 2% per quarter
7. **Export Compliance Speed** — Process export license applications and end-user screening with <4hr approval lag
8. **Long-Range Capacity Planning** — Commit capacity to customers 18–24 months ahead with <5% forecast miss at node level
9. **Single-Fab Outage Response** — Model and re-allocate production within 4 hours of unplanned fab outage
10. **Sustainability per Wafer** — Reduce fab water and energy consumption by 10% per wafer through real-time monitoring and planning

---

## Regulatory & Compliance Considerations
- Export controls: extremely high-risk sector — EAR (US Bureau of Industry & Security), Wassenaar Arrangement, entity list screening
- CHIPS Act implications: domestic production incentives affecting investment decisions (US, EU, Japan)
- Environmental: fab effluent (PFCs, ultra-pure water), chemical waste — local environmental permits
- TSMC/foundry IP: strict NDA and IP segregation between competing customers in shared fab
- Conflict minerals: gold, tantalum, tin, tungsten traceability mandatory

## Sustainability Signals to Watch For
- Water usage per wafer (litres/wafer) — fabs are extreme water consumers
- Energy per wafer start (kWh); renewable energy % of fab energy
- PFC (perfluorocarbon) emissions — major GHG in semiconductor process
- Packaging substrate recyclability
- OSAT partner environmental certifications

## Key Search Queries
```
<company> fabless IDM foundry model manufacturing supply chain
<company> TSMC GlobalFoundries Samsung foundry partner
<company> fab utilisation capacity wafer starts quarterly
<company> allocation shortage automotive industrial customer
<company> export control EAR entity list compliance
<company> cycle time yield new node ramp
<company> OSAT packaging assembly test ASE Amkor
<company> supply chain planning Kinaxis o9 capacity
```
