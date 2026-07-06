# Telecomm & Network — Sector Reference for Supply Chain Mapping

**Cluster:** High Tech
**Representative Companies:** Nokia, Vodafone, Verizon, Ericsson, Cisco, Huawei, Deutsche Telekom, AT&T
**Taxonomy description:** Complicated digital services, and the complicated digital things to run them

---

## Typical Make/Buy Split
**Infrastructure vendors (Nokia, Ericsson, Cisco):**
- Hardware (base stations, routers, switches): 60–80% EMS / ODM; own final integration and testing
- Software / firmware: 100% in-house
- Antennas: mixed — own design, outsourced manufacture

**Telco operators (Vodafone, Verizon, Deutsche Telekom):**
- Network equipment: 100% purchased from vendors (capital expenditure, not manufacturing)
- CPE (customer premises equipment): 80–90% outsourced; own only procurement and logistics
- Key signal: "network rollout partners", "equipment vendors", "managed services" in annual reports

## Inbound Raw Materials — Typical Modal Split (for vendors/manufacturers)
| Material | Mode | Notes |
|----------|------|-------|
| Semiconductors / ASICs | Air | Custom chips; long lead times; shortage-critical |
| PCBs and sub-assemblies | Air or Ocean FCL | EMS-sourced; depends on build cycle |
| Sheet metal / enclosures | Road FTL (regional) | Heavy, low value density — local preferred |
| Optical fibre components | Ocean FCL or Air | High precision; Asia-dominant supply |
| Power components | Road FTL or Ocean | Transformers, batteries, UPS — heavy |
| Cables and connectors | Ocean FCL | High volume, commodity |

## Distribution Norms (Vendors and Operators differ significantly)
**Vendors (Nokia, Ericsson, Cisco):**
- Project logistics model: equipment shipped to specific site, not to DC — complex multi-drop project logistics
- Regional integration centres: pre-integration of base stations before site delivery
- Spare parts / MRO: forward-stocking locations near operator network footprint

**Operators (Vodafone, Verizon):**
- Central logistics hub → field operations teams → installation sites
- CPE (routers, modems): centralised DC → last-mile courier to consumer premise
- Network rollout: project logistics with specialist telecom installers
- Returns (CPE): high volume — subscriber churn and upgrade programmes drive reverse logistics

## Outbound Modal Split
| Channel | Mode | Notes |
|---------|------|-------|
| Network rollout (site delivery) | Road FTL + specialist lift | Heavy equipment; site-specific delivery |
| Enterprise customer | Road LTL or courier | Routers, switches, CPE |
| Consumer CPE | Parcel (B2C) | Last-mile; high return rate |
| Spare parts (field service) | Road express or Air | SLA-driven; next-business-day parts |
| Export (EM operators) | Ocean FCL | Infrastructure build in Africa, APAC |

## Air Freight Use Cases
- Network rollout acceleration: operator committed to 5G coverage date — equipment air-freighted to meet milestone
- Spare parts (NOC SLA): network uptime SLA forces express parts delivery
- Emergency replacement: natural disaster / outage recovery requires rapid infrastructure deployment
- Custom ASICs: high-value custom silicon always air-freighted from foundry

---

## Typical Strategic Ambitions
| Dimension | Typical targets |
|-----------|----------------|
| **Growth** | Win 5G/6G infrastructure share; grow managed services and network-as-a-service (NaaS); expand into private networks (enterprise 5G) |
| **Efficiency** | Reduce network rollout cost per site; cut CPE logistics cost per subscriber; improve parts fill rate for field service |
| **New Business Models** | Network-as-a-Service; open RAN ecosystems; edge computing services bundled with connectivity |
| **Market Share** | Win national 5G contracts; expand in EM (Africa, SE Asia); protect installed base from Chinese vendor displacement |
| **Innovation** | Accelerate open RAN (O-RAN) development; AI-driven network optimisation; quantum-safe encryption rollout |
| **Digitalisation** | Real-time network rollout tracking; automated CPE provisioning and delivery; predictive spare parts inventory |

---

## Common Supply Chain Platforms
| SC Function | Typical Platforms |
|-------------|------------------|
| **Demand Planning** | SAP IBP, o9, Kinaxis, Anaplan (long-cycle capital planning typical) |
| **Supply Planning** | SAP IBP, OMP Plus, o9 (complex BOM; project-based builds) |
| **Logistics Planning** | Oracle TMS, SAP TM, Blue Yonder, specialist project logistics tools (Trimble, Transporeon) |
| **Visibility** | FourKites, project44, Descartes, Coupa (network rollout tracking) |
| **Control Tower** | o9, SAP IBP, ServiceNow (for field operations) |
| **Global Trade & Compliance** | SAP GTS, E2open, Descartes (telecom equipment subject to export controls) |
| **Supplier Collaboration (VMI-type)** | E2open, SAP Ariba Supply Chain, Coupa |
| **Customer Collaboration (CPFR-type)** | Salesforce (operator account management), proprietary vendor portals |
| **Scenario Planning** | o9, Anaplan, Kinaxis (capacity and rollout scenario modelling) |
| **Risk & Resilience** | Resilinc, Everstream, Dun & Bradstreet (geopolitical / vendor concentration risk) |
| **Procurement (Direct Materials)** | SAP Ariba, Coupa, Ivalua (large capital equipment and component contracts) |

---

## Top 10 Use Cases (Business-Driven)
1. **Network Rollout on Time** — Deliver 5G site equipment and complete installation within <2-week variance of committed operator schedule
2. **Spare Parts Availability** — Achieve >98% same-day or next-day spare parts fill rate to maintain network uptime SLAs
3. **CPE Cost per Subscriber** — Reduce cost-to-serve per subscriber (CPE logistics + returns) by 20% through better routing and returns management
4. **Component Shortage Continuity** — Maintain network equipment production during semiconductor shortage with <5% shipment delay
5. **Revenue at Risk from Rollout Delay** — Keep revenue at risk from equipment delivery delays below 2% of contracted network rollout revenue
6. **Gross Margin on Projects** — Keep project gross margin stable within ±3% despite component cost and logistics cost volatility
7. **Working Capital on Long-Cycle Projects** — Reduce inventory holding for network build programmes by 20% through phased delivery planning
8. **Geopolitical Vendor Diversification** — Reduce dependency on single-country equipment vendors to <40% of network BOM within 24 months
9. **Field Service Model & React** — Model and dispatch field engineers and parts to network outage within 2 hours of fault detection
10. **Returns Efficiency** — Recover >80% of CPE value through refurbishment or resale programmes; reduce landfill to near zero

---

## Regulatory & Compliance Considerations
- Security certification: GSMA SAS, 3GPP standards compliance for network equipment
- Export controls: US EAR and EU dual-use apply to encryption and advanced network equipment
- National security: government scrutiny of vendor selection (Huawei exclusions in US, UK, EU)
- Spectrum licensing: drives rollout timeline rigidity — missed milestones = regulatory penalties
- Consumer protection: CPE device certification (CE, FCC) before distribution

## Sustainability Signals to Watch For
- Energy consumption per network site (kWh); renewable energy targets for network infrastructure
- CPE circular economy: refurbishment %, landfill avoidance
- Packaging reduction for consumer CPE
- Scope 3 logistics emissions from rollout and distribution

## Key Search Queries
```
<company> 5G network rollout equipment supply chain logistics
<company> EMS ODM contract manufacturer base station
<company> CPE customer premises equipment logistics distribution
<company> spare parts field service availability SLA
<company> supply chain disruption semiconductor shortage network
<company> export control telecom equipment compliance
<company> sustainability energy network circular CPE
<company> supply chain planning SAP IBP o9 Kinaxis
```
