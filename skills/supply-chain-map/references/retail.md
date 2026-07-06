# Retail — Sector Reference for Supply Chain Mapping

**Cluster:** Consumer
**Representative Companies:** Aldi, Lidl, Ulta Beauty, Sobeys, Walmart, Target, Zara (as retailer), Amazon (retail), Costco
**Taxonomy description:** Delivering items from other industries to consumers

---

## Typical Make/Buy Split
> Note: Retailers do not manufacture — their "supply chain" is an orchestration and distribution function. The make/buy question becomes: own DC infrastructure vs 3PL, own fleet vs carrier, own brand vs national brand.

- **Own brand / private label**: 20–50% of assortment for grocery discounters (Aldi, Lidl — up to 90%); 10–30% for full-line grocery (Sobeys)
- **Owned DC**: large retailers operate own DCs; smaller chains use 3PL
- **Own last-mile fleet**: grocery and foodservice retailers often own; GM retailers typically outsource
- **Own dark stores / fulfilment centres**: ecom growth driving investment in dedicated fulfilment infrastructure
- Key signal: "private label penetration", "owned distribution", "fulfilment centres" in annual reports

## Inbound Flow — From Supplier to DC (typical modal split)
| Product category | Mode | Notes |
|-----------------|------|-------|
| Dry grocery (ambient) | Road FTL | Supplier to retailer DC; pallet-in |
| Fresh / chilled produce | Road FTL (refrigerated) | Daily or near-daily runs; short shelf life |
| Frozen | Road FTL (frozen) | Less frequent; batch deliveries |
| Non-food / general merchandise | Road FTL or Ocean FCL (imports) | Seasonal; far-origin private label |
| Apparel / textiles (private label) | Ocean FCL (Asia) | Seasonal buying; long lead time |
| Ecom goods (supplier drop-ship) | Parcel / LTL to fulfilment centre | Drop-ship or retailer-fulfilment mix |
| Beer / wine / beverages | Road FTL | High frequency, heavy |

## Distribution Norms
- Cross-dock: many grocery retailers cross-dock ambient products — no storage; truck-to-truck transfer
- Pick-and-pack DC: own-brand and multi-category consolidation for store orders
- Dark store / micro-fulfilment: dedicated ecom fulfilment; pick density optimised for online orders
- Ambient: typically 2-day replenishment cycle to store; fresh: daily
- Temperature zones: multi-temp DCs combine ambient, chilled, and frozen
- Click-and-collect: store acts as last-mile fulfilment point; back-room picking growing

## Outbound Modal Split (DC to Store / Consumer)
| Channel | Mode | Notes |
|---------|------|-------|
| Own stores (ambient) | Road FTL (own fleet or 3PL) | Regular cadence; 2-3x/week per store |
| Own stores (fresh) | Road FTL (refrigerated) | Daily; time-window constrained |
| Ecom home delivery | Parcel express or own van | Last-mile; 1- or 2-hour slots growing |
| Click-and-collect | Store pick | Consolidation from DC or in-store |
| Wholesale / foodservice | Road FTL | Costco-style volume drops |

## Air Freight Use Cases (effectively zero in standard retail)
- Emergency private label product (e.g., loss leader out-of-stock for promotional event)
- Luxury / premium fresh (Harrods food hall model)
- Seasonal private label from far-origin — very rare; most retailers accept ocean lead times

---

## Typical Strategic Ambitions
| Dimension | Typical targets |
|-----------|----------------|
| **Growth** | Expand ecom share; grow private label penetration; enter new geographies through M&A or franchise |
| **Efficiency** | Reduce cost-per-case through DC; improve on-shelf availability; cut shrink and waste; optimise last-mile delivery cost |
| **New Business Models** | Retail media networks (advertising revenue from supplier data); subscription/loyalty programmes; marketplace (allow third-party sellers) |
| **Market Share** | Win share in convenience and online; defend against discounter pressure (Aldi/Lidl); grow beauty/health speciality |
| **Innovation** | AI-driven personalised promotions; autonomous picking in DC; real-time pricing optimisation |
| **Digitalisation** | POS-linked replenishment; real-time inventory accuracy; supplier collaboration (EDI/API); store operations digitalisation |

---

## Common Supply Chain Platforms
| SC Function | Typical Platforms |
|-------------|------------------|
| **Demand Planning** | RELEX Solutions, Blue Yonder, o9, SAP IBP, Logility, Manhattan (retail-specific demand planning) |
| **Supply Planning** | RELEX, Blue Yonder, SAP IBP (replenishment planning; store-level inventory optimisation) |
| **Logistics Planning** | Blue Yonder TMS, Oracle TMS, Manhattan TMS, Descartes (store delivery routing critical) |
| **Visibility** | FourKites, project44, Descartes (inbound supplier shipment tracking) |
| **Control Tower** | RELEX, Blue Yonder, o9 (end-to-end from supplier to shelf) |
| **Global Trade & Compliance** | E2open, Descartes (private label imports; country-of-origin; CSDDD/CSRD product compliance) |
| **Supplier Collaboration (VMI-type)** | Retail Link (Walmart), GS1 EDI standards, SPS Commerce, CommerceHub (supplier order management) |
| **Customer Collaboration (CPFR-type)** | Not applicable in traditional form — retailer is the customer; loyalty data sharing with suppliers is the analogue |
| **Scenario Planning** | RELEX, Blue Yonder, Anaplan (seasonal range planning; promotional scenario modelling) |
| **Risk & Resilience** | Everstream, riskmethods (private label supplier risk); loss prevention analytics |
| **Procurement (Direct Materials)** | SAP Ariba, Coupa (for own-brand / private label sourcing) |

---

## Top 10 Use Cases (Business-Driven)
1. **On-Shelf Availability** — Achieve >98.5% on-shelf availability across all stores for top-500 SKUs, eliminating phantom inventory and reducing lost sales
2. **Demand Spike Absorption** — Absorb a 30% promotional or seasonal demand spike without stockouts or excess waste/markdown
3. **Gross Margin on Private Label** — Keep private label gross margin within ±1% despite input cost and ocean freight fluctuation
4. **Working Capital** — Maximise inventory turns by reducing days-on-hand across categories while maintaining fill rates
5. **Ecom Profitability** — Reduce last-mile delivery cost per order by 25% to achieve ecom contribution positivity
6. **Supplier On-Time In-Full (OTIF)** — Drive supplier OTIF to >98% through shared replenishment signals and automated purchase orders
7. **Revenue at Risk from Stockout** — Keep revenue at risk from out-of-stock events below 1% of weekly sales
8. **Shrink & Waste Reduction** — Reduce fresh and perishable waste by 20% through better demand sensing and markdown optimisation
9. **Model & React to Supply Disruption** — Identify supply disruption from a key supplier and execute range substitution within 24 hours
10. **Promotional ROI** — Measure and optimise promotional ROI within 48 hours of promotion end using integrated sell-through and margin data

---

## Regulatory & Compliance Considerations
- Food safety: FDA FSMA / EU Food Law for any grocery/food retail — HACCP-aligned receiving and storage
- Product labelling compliance: country-specific requirements for own-brand product across all markets
- Consumer protection: distance selling regulations (ecom returns policies); price transparency
- CSDDD / CSRD (EU): supply chain due diligence for own-brand product supply chain — human rights and environment
- Alcohol: licensing requirements per jurisdiction; age verification requirements (ecom)
- Weighted average cost compliance: some markets (e.g., Australia) regulate below-cost selling

## Sustainability Signals to Watch For
- Food waste reduction targets (% of unsold food donated vs landfill vs energy recovery)
- Plastic packaging reduction commitments (own-brand)
- Own fleet electrification timeline (last-mile delivery vans)
- Scope 3 (purchased goods — Cat 1) traceability and supplier ESG audit coverage
- Renewable energy in DC operations

## Key Search Queries
```
<company> distribution center DC network supply chain logistics
<company> private label own brand sourcing suppliers
<company> on-shelf availability inventory replenishment OTIF
<company> ecom fulfilment dark store last mile delivery
<company> shrink waste reduction fresh perishable markdown
<company> supplier collaboration EDI CPFR retail link
<company> supply chain planning RELEX Blue Yonder Manhattan
<company> sustainability food waste packaging fleet electrification
```
