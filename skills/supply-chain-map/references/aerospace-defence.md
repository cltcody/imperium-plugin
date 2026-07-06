# Aerospace & Defence — Sector Reference for Supply Chain Mapping

**Cluster:** Industrial
**Representative Companies:** Boeing, Airbus, Exostar, Lockheed Martin, BAE Systems, Raytheon, Rolls-Royce, Safran
**Taxonomy description:** Specialized/big/complicated lumps of metal, sold to regulated businesses (& governments)

---

## Typical Make/Buy Split
- Prime contractors (Boeing, Airbus): 20–40% in-house (final assembly, integration, test); 60–80% sourced from Tier 1/2/3
- Tier 1 (Safran, Collins Aerospace, Spirit AeroSystems): 40–60% in-house; balance from Tier 2
- Defence systems: typically higher in-house content due to classification and technology protection requirements
- Long-tail Tier 2/3: often small, sole-source specialists — massive fragility risk
- Key signal: "sole-source", "long lead time items (LLI)", "build-to-print", "Government-Furnished Equipment (GFE)" in programme filings

## Inbound Raw Materials — Typical Modal Split
| Material | Mode | Notes |
|----------|------|-------|
| Titanium (structural) | Air or Ocean FCL | High value; aerospace grade; limited smelters |
| Aluminium (machined parts) | Road FTL or Ocean FCL | High volume alloy billet |
| Composites (CFRP, prepreg) | Road (temperature-controlled) | Frozen storage requirement; cold chain |
| Forgings (landing gear, engine) | Road FTL | Heavy; long lead time (up to 2 years) |
| Specialty alloys (Inconel, titanium) | Air or Road | High value; tight traceability |
| Electronics / avionics | Air | High value; DO-254/DO-178 qualified |
| Fasteners (aerospace grade) | Road FTL or Air | AS9100 qualified; traceability per lot |

## Distribution Norms
- Programme-based: each aircraft or system is a project — logistics built around programme master schedule
- Long lead time items (LLI): some forgings and castings 18–24 months lead time — must be ordered 2 years before delivery
- Traceability is absolute: every component must have full birth-to-retirement records (Form 1, 8130-3, EASA Form 1)
- MRO (Maintenance, Repair and Overhaul): significant logistics around engine/component shop visits — AOG (aircraft-on-ground) drives extreme urgency
- Government Furnished Equipment (GFE): customer supplies some components — adds complexity
- Bonded stores / AS9120 distributors: certified distribution chain required; grey market parts are a criminal offence

## Outbound Modal Split
| Channel | Mode | Notes |
|---------|------|-------|
| Aircraft delivery (commercial) | Self-ferry (aircraft flies) | Customer takes delivery at OEM facility |
| Aircraft delivery (defence) | Military flight or heavy-lift (e.g., Beluga) | Classification and security requirements |
| MRO / spare parts (AOG) | Air express (next flight out) | AOG = $100k+/hr cost — price insensitive |
| MRO / spare parts (routine) | Air or Road | SLA-based; 24–72 hrs typical |
| Sub-assemblies to prime | Road FTL (heavy/OOD) or Air | Fuselage sections by road; engines by sea or Beluga |
| Export (government customer) | Air freight (military C-17/A400) or Ocean | Governed by export licence (ITAR/EAR) |

## Air Freight Use Cases (structurally very high — AOG economics dominate)
- AOG (aircraft on ground): airline losing $50k–$200k/hr — any part needed flies immediately
- Programme schedule recovery: late supplier delivery air-freighted to avoid schedule slip penalty
- First article / qualification parts: always air (time to qualification is programme-critical)
- ITAR-controlled items: often limited to specific approved routes — air simplifies route control

---

## Typical Strategic Ambitions
| Dimension | Typical targets |
|-----------|----------------|
| **Growth** | Win next-generation platform (NGAD, GCAP, A320neo successor); grow MRO and services revenue (annuity stream) |
| **Efficiency** | Reduce programme cost overruns; cut LLI inventory through better demand signal sharing with Tier 1; improve build rate |
| **New Business Models** | Power-by-the-hour (PBH) engine services; as-a-service sustainment contracts; digital MRO |
| **Market Share** | Compete for next-generation fighter/UAV programmes; grow commercial MRO market share vs OEM shops |
| **Innovation** | Sustainable aviation fuel (SAF) integration; hybrid-electric propulsion; advanced manufacturing (additive, automated fibre placement) |
| **Digitalisation** | Digital thread from design to MRO; real-time programme schedule visibility; AI-driven AOG prediction and prevention |

---

## Common Supply Chain Platforms
| SC Function | Typical Platforms |
|-------------|------------------|
| **Demand Planning** | SAP IBP, o9, Kinaxis (long-cycle programme demand; MRO spare parts forecasting) |
| **Supply Planning** | SAP IBP, OMP Plus, PTC Windchill (integrated with PLM; LLI management) |
| **Logistics Planning** | Oracle TMS, SAP TM, Kuehne+Nagel AEROfreight tools (AOG-capable TMS) |
| **Visibility** | Exostar (aerospace-specific supply chain collaboration platform), project44, FourKites |
| **Control Tower** | Exostar, o9, SAP IBP (programme schedule + supply integration) |
| **Global Trade & Compliance** | SAP GTS, E2open, Amber Road (ITAR/EAR compliance critical; TAA; DSP-5/DSP-73) |
| **Supplier Collaboration (VMI-type)** | Exostar (aerospace-specific), E2open, SAP Ariba Supply Chain (AS9100 supplier management) |
| **Customer Collaboration (CPFR-type)** | Exostar (airline customer portals), Salesforce, government programme portals |
| **Scenario Planning** | o9, Kinaxis, Anaplan (build rate scenarios; MRO demand modelling) |
| **Risk & Resilience** | Resilinc, riskmethods, Exostar Risk Management (Tier N sub-tier visibility) |
| **Procurement (Direct Materials)** | SAP Ariba, Coupa, Ivalua (long-term strategic agreements for LLI, metals, composites) |

---

## Top 10 Use Cases (Business-Driven)
1. **AOG Prevention** — Achieve >99.9% same-day parts availability for AOG events, preventing >$100k/hr airline downtime costs
2. **Programme Schedule Recovery** — Recover a 6-week schedule slip through supply chain re-sequencing without penalty clause exposure
3. **Gross Margin on Programme** — Keep programme gross margin within ±3% against budget despite LLI cost escalation and rework
4. **Long Lead Time Item Security** — Ensure 100% LLI coverage against 24-month production plan with zero schedule breaks
5. **Working Capital on MRO Inventory** — Reduce MRO spare parts inventory value by 20% while maintaining >98% parts fill rate
6. **Revenue at Risk from Supply Delay** — Keep revenue at risk from Tier 1 schedule slippage below 2% of annual programme revenue
7. **Export Compliance Speed** — Process all ITAR/EAR export authorisations with <5-business-day approval cycle, zero violations
8. **Model & React to Sole-Source Failure** — Identify and execute alternate source qualification within 6 months of sole-source supplier failure
9. **MRO Turn Time** — Reduce aircraft heavy maintenance turn time by 15% through better parts pre-positioning and digital work order management
10. **Supplier Financial Health Monitoring** — Detect and mitigate financial distress in Tier 2/3 suppliers before it causes programme impact

---

## Regulatory & Compliance Considerations
- ITAR (International Traffic in Arms Regulations): US defence articles and services — criminal penalties for violations; limits who can access data
- EAR (Export Administration Regulations): dual-use aerospace items; entity list screening
- AS9100 Rev D: aerospace quality management system standard — mandatory for all suppliers
- FAA / EASA: airworthiness certification for all components; Form 8130-3 / EASA Form 1 required
- DFARS / NDAA (US): Defence acquisition regulations — domestic sourcing requirements, country-of-origin restrictions
- Anti-counterfeiting: AS6174, AS5553 standards for suspect counterfeit avoidance — all parts must be traceable to original manufacturer

## Sustainability Signals to Watch For
- Sustainable Aviation Fuel (SAF) offtake commitments and supply chain development
- Product lifecycle emissions (aircraft operational emissions are Scope 3 Cat 11)
- Manufacturing energy and waste reduction at assembly facilities
- Titanium and composite material recycling programmes
- Supply chain diversity targets (small business, minority-owned suppliers — required in US government contracts)

## Key Search Queries
```
<company> supply chain programme 10-K LLI long lead time
<company> Tier 1 supplier network sole-source sub-tier visibility
<company> MRO spare parts AOG logistics distribution
<company> ITAR export control compliance violations DSP-5
<company> AS9100 quality supplier qualification audit
<company> build rate production ramp deliveries quarterly
<company> power by the hour PBH services revenue MRO
<company> sustainability SAF composite recycling manufacturing
```
