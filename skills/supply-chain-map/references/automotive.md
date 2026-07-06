# Automotive — Sector Reference for Supply Chain Mapping

**Cluster:** Industrial
**Representative Companies:** JLR (Jaguar Land Rover), Ford, Honda, Continental, Toyota, BMW, Stellantis, Bosch
**Taxonomy description:** Complicated large lumps of metal, sold to consumers & businesses

---

## Typical Make/Buy Split
- OEM (Ford, Honda, JLR): 30–50% in-house (body stamping, engine, final assembly); 50–70% from Tier 1/2/3 suppliers
- Tier 1 suppliers (Continental, Bosch): 40–60% in-house; 40–60% from Tier 2 sub-suppliers
- Electronics content rapidly increasing: 40–50% of vehicle value is now electronic — majority outsourced
- EV transition shifting make/buy: battery cells (outsourced to CATL, LG, Panasonic); battery pack/module (moving in-house)
- Key signal: "preferred supplier programme", "sole-source", "Tier 1 partners", "insourcing battery" in investor materials

## Inbound Raw Materials — Typical Modal Split
| Material | Mode | Notes |
|----------|------|-------|
| Steel coil (body panels) | Rail or Road FTL | Very high volume; JIT delivery to stamping |
| Aluminium (castings, body) | Road FTL or Rail | Increasingly used for lightweighting |
| Battery cells (EV) | Ocean FCL or Road | From Asia (CATL, LG, Panasonic) or regional gigafactories |
| Semiconductors / ECUs | Air (shortage) / Road | Most critical shortage item in recent years |
| Plastic / polymer components | Road FTL | Regional compounders; local preferred |
| Glass (windscreen, windows) | Road FTL | Fragile; regional supplier preferred |
| Rubber (tyres, seals) | Road FTL or Ocean FCL | Tyres from regional; seals Asia |
| Powertrain sub-assemblies | Road FTL (JIT/JIS) | Tier 1 delivers direct to assembly line |

## Distribution Norms (JIT/JIS model — extremely time-sensitive)
- **JIT (Just-in-Time):** parts delivered to assembly line within hours of use; no stockroom buffer
- **JIS (Just-in-Sequence):** parts delivered in exact vehicle build sequence — seats, dashboards, doors
- Milk run: OEM-operated trucks collect from multiple Tier 1 suppliers on fixed daily routes
- Kanban replenishment: two-bin or electronic kanban for standard parts
- Finished vehicles: road transporter (multi-deck car carriers); rail for longer distances; RORO ocean for exports
- Dealer network: regional PDC (Parts Distribution Centre) → dealer → consumer
- New vehicle: OEM → PDC → dealer for customer order; transit to dealer as demo/stock

## Outbound Modal Split (Finished Vehicle)
| Channel | Mode | Notes |
|---------|------|-------|
| Domestic dealer | Road (multi-deck car carrier) | Final delivery from plant or regional DC |
| Export (same continent) | Road or Rail | RORO vessel for volume Europe→ME |
| Export (intercontinental) | RORO ocean | High volume; dedicated RORO terminals |
| Fleet / corporate | Road direct or dealer | High volume orders; direct factory order |
| Spare parts (dealer) | Road LTL | OEM parts distribution via regional PDC |
| Spare parts (urgent) | Air express | Uptime critical; production or customer SLA |

## Air Freight Use Cases (normally very low; spikes during shortage events)
- Semiconductor shortage: ECUs and semiconductors air-freighted to prevent line stoppage
- Launch support: initial parts supply for new model launch — ocean lead time too long
- Recall parts: urgent safety recall replacement parts
- Prototype / development: engineering samples always air-freighted

---

## Typical Strategic Ambitions
| Dimension | Typical targets |
|-----------|----------------|
| **Growth** | Accelerate EV portfolio; grow software-defined vehicle revenue (OTA, subscriptions); expand in China and India |
| **Efficiency** | Reduce manufacturing cost per vehicle (MCPV) by 5–10%; cut semiconductor single-source dependency; reduce warranty cost |
| **New Business Models** | Vehicle subscription; software OTA revenue (comfort features, performance upgrades); mobility services (car-sharing, fleet management) |
| **Market Share** | Win EV segment in target markets; defend ICE share in markets where EV adoption is slow |
| **Innovation** | Autonomous driving development; solid-state battery development; software-defined vehicle architecture |
| **Digitalisation** | Real-time production scheduling (connected to Tier 1 EDI); digital twin of assembly plant; AI-powered demand sensing for options |

---

## Common Supply Chain Platforms
| SC Function | Typical Platforms |
|-------------|------------------|
| **Demand Planning** | o9, Kinaxis, SAP IBP, IHS Markit (vehicle demand intelligence) |
| **Supply Planning** | Kinaxis, OMP Plus, o9, SAP IBP (complex BOM; JIT/JIS scheduling critical) |
| **Logistics Planning** | Blue Yonder TMS, Oracle TMS, SAP TM, Transplace (inbound milk run; outbound carrier management) |
| **Visibility** | FourKites, project44, Descartes, Covisint (automotive-specific), Volkswagen Group's own systems |
| **Control Tower** | Kinaxis, o9, E2open (critical for semiconductor shortage management) |
| **Global Trade & Compliance** | SAP GTS, E2open, Descartes (rules of origin for FTA compliance; USMCA, EU-UK TCA) |
| **Supplier Collaboration (VMI-type)** | E2open, Covisint, SupplyOn (automotive-specific supplier portal widely used in Europe) |
| **Customer Collaboration (CPFR-type)** | Dealer management systems (CDK Global, Reynolds & Reynolds); OEM order management portals |
| **Scenario Planning** | Kinaxis, o9, Anaplan (production mix; EV vs ICE capacity decisions) |
| **Risk & Resilience** | Resilinc, riskmethods, Everstream (Tier N visibility critical after 2011 Japan/Thailand disasters) |
| **Procurement (Direct Materials)** | SAP Ariba, Coupa, Ivalua (strategic sourcing for steel, battery, semiconductors) |

---

## Top 10 Use Cases (Business-Driven)
1. **Production Line Continuity** — Prevent production line stoppage from component shortage; maintain throughput within 2% of planned despite supply disruptions
2. **Semiconductor Shortage Management** — Allocate constrained semiconductor supply across vehicle lines with <3% revenue at risk from forced production mix changes
3. **Gross Margin on EV** — Keep EV gross margin trajectory positive quarter-on-quarter despite battery cost and logistics volatility
4. **New Model Launch on Time** — Achieve Job 1 (first vehicle off the line) within <2-week variance and reach volume ramp within 8 weeks
5. **Working Capital on Parts** — Reduce in-transit and buffer inventory across Tier 1 supply base by 20% through JIT optimisation
6. **Revenue at Risk from Dealer Stockouts** — Keep dealer allocation shortfall below 3% of configured customer orders in backlog
7. **Recall Execution Speed** — Identify and contact all affected vehicle owners within 24 hours of recall decision; parts available within 2 weeks
8. **Model & React to Disruption** — Re-sequence production plan within 4 hours of Tier 1 supply failure to minimise line impact
9. **EV Battery Supply Security** — Secure battery cell supply 24 months ahead with <5% volume miss against committed volumes
10. **Rules of Origin Compliance** — Achieve 100% FTA qualification accuracy for all export markets to avoid tariff leakage

---

## Regulatory & Compliance Considerations
- Emissions regulations: Euro 6/7 (EU), EPA Tier 3 (US), China 6 — major driver of R&D and supply chain investment
- Safety standards: FMVSS (US), ECE regulations (UN/EU); type approval required market-by-market
- Battery regulations: EU Battery Regulation (2023) — carbon footprint declaration, recycled content, passports
- Rules of origin: USMCA, EU-UK TCA, EU-Japan EPA — determines tariff treatment for exports; critical for EV battery sourcing
- REACH / RoHS: chemical and hazardous substances compliance throughout vehicle BOM
- Conflict minerals: extensive use of cobalt, tungsten, tantalum — mandatory 3TG reporting

## Sustainability Signals to Watch For
- Fleet average CO2 emissions (gCO2/km) vs regulatory target
- EV/BEV/PHEV mix as % of total sales
- Battery supply chain sustainability: cobalt sourcing, recycled battery content targets
- Manufacturing energy intensity (kWh per vehicle produced)
- Scope 3 Category 11 (use of sold vehicles) — by far the largest Scope 3 for automakers

## Key Search Queries
```
<company> manufacturing plants assembly supply chain 10-K
<company> Tier 1 supplier JIT JIS preferred supplier programme
<company> semiconductor ECU shortage production line impact
<company> EV battery supply CATL LG Panasonic gigafactory
<company> rules of origin USMCA FTA tariff compliance
<company> new model launch Job 1 production ramp
<company> supply chain planning Kinaxis o9 SAP IBP
<company> sustainability CO2 fleet emissions battery circular
```
