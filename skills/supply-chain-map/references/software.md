# Software — Sector Reference for Supply Chain Mapping

**Cluster:** High Tech
**Representative Companies:** Red Hat, HPE (software division), SAP, Salesforce, ServiceNow, Microsoft, Oracle
**Taxonomy description:** Complicated digital services, sold to businesses & consumers

---

## Typical Make/Buy Split
- Core product development: 70–90% in-house engineering; 10–30% outsourced development (nearshore/offshore)
- Infrastructure (cloud hosting): rapidly shifting to hyperscaler (AWS, Azure, GCP) — minimal own data centres
- Professional services delivery: mix of own consultants + partner ecosystem (SIs like Accenture, Deloitte)
- Physical SC is minimal: primarily limited to hardware bundles, USB keys (legacy), data centre equipment procurement
- Key signal: "cloud-first", "SaaS transition", "partner network" in investor materials

## Inbound "Raw Materials" — Minimal Physical SC
| Component | Mode | Notes |
|-----------|------|-------|
| Server / compute hardware (data centres) | Road FTL or Air | Capital equipment for own infrastructure |
| Networking equipment | Road FTL | Switches, routers for own/colo DCs |
| USB/physical media (legacy) | Parcel | Mostly eliminated; some regulated markets |
| Laptops / developer equipment | Parcel or Road | Employee hardware procurement |

> **Note:** For SaaS/cloud software, the "supply chain" is primarily digital — code repositories, CI/CD pipelines, CDN distribution, cloud provisioning. Physical SC is largely irrelevant to the product itself.

## Distribution Norms (Digital)
- SaaS: instantaneous digital delivery; licensing keys / tenant provisioning via cloud portal
- On-premise software: licence file + installer download or physical media (rare)
- Professional services: consultant deployment via resource scheduling systems
- Partner/reseller channel: digital licence transfer; fulfilment via distributor portals (e.g., AWS Marketplace, Azure Marketplace)
- The meaningful "supply chain" questions are: data centre geography (latency, data sovereignty), CDN footprint, disaster recovery architecture

## Outbound Distribution (Physical where applicable)
| Channel | Mode | Notes |
|---------|------|-------|
| Direct enterprise (SaaS) | Digital | API provisioning; zero physical logistics |
| Reseller / partner channel | Digital (marketplace) | AWS/Azure/GCP marketplaces dominant |
| Government / air-gapped | Physical media or secure courier | Classified environments; compliance-driven |
| Hardware-bundled software | Parcel with device | OEM bundled; increasingly licence-only |

## Air Freight Use Cases (near-zero)
- Emergency hardware replacement for own data centres
- Physical delivery to air-gapped/government customers requiring certified media
- Employee equipment for critical project mobilisation

---

## Typical Strategic Ambitions
| Dimension | Typical targets |
|-----------|----------------|
| **Growth** | Accelerate SaaS/cloud transition; expand platform ecosystem and marketplace revenue; grow international markets |
| **Efficiency** | Reduce cloud infrastructure cost per customer; improve professional services utilisation and margin; automate deployment |
| **New Business Models** | AI-as-a-Service; outcome-based pricing (not per-seat); embedded finance and vertical SaaS expansion |
| **Market Share** | Displace legacy on-premise incumbents; win cloud-native enterprise accounts; expand mid-market via self-serve |
| **Innovation** | Generative AI product integration; autonomous agents embedded in workflow; platform extensibility (low-code/no-code) |
| **Digitalisation** | Own SC: full digital procurement for hardware/services; partner ecosystem digital onboarding; automated licence management |

---

## Common Supply Chain Platforms
> Note: Software companies use SC platforms primarily for their own internal operations (hardware procurement, professional services deployment) and increasingly offer SC platforms as products to other industries.

| SC Function | Typical Platforms (own operations) |
|-------------|-----------------------------------|
| **Demand Planning** | Anaplan, Adaptive Insights (workforce and capacity planning — not goods) |
| **Supply Planning** | Coupa, SAP Ariba (for hardware procurement planning) |
| **Logistics Planning** | Oracle TMS, SAP TM (minimal — for hardware/data centre equipment) |
| **Visibility** | ServiceNow (internal IT asset visibility), proprietary cloud monitoring |
| **Control Tower** | ServiceNow, Jira (engineering deployment control), proprietary SRE tooling |
| **Global Trade & Compliance** | SAP GTS, E2open (for hardware exports; software export controls — EAR for encryption) |
| **Supplier Collaboration (VMI-type)** | Coupa, SAP Ariba (hardware supplier portals) |
| **Customer Collaboration (CPFR-type)** | Salesforce, Gainsight (customer success / renewal management — digital analogue to CPFR) |
| **Scenario Planning** | Anaplan, Adaptive (financial scenario modelling; headcount and capacity) |
| **Risk & Resilience** | Resilinc, D&B (for hardware supply and data centre vendor risk) |
| **Procurement (Direct Materials)** | Coupa, SAP Ariba, Ivalua (servers, networking, SaaS licences for engineering tooling) |

---

## Top 10 Use Cases (Business-Driven)
> Note: Use cases for software companies are primarily digital/service supply chain — not physical goods.

1. **Service Availability** — Maintain platform uptime above 99.99% SLA across all regions, with recovery time <15 minutes for critical failures
2. **Time to Deploy** — Reduce new enterprise customer time-to-value (contract to go-live) by 30% through automated provisioning
3. **Partner Revenue at Risk** — Keep revenue at risk from partner/reseller pipeline gaps below 5% of quarterly ARR
4. **Gross Margin on Cloud** — Keep gross margin on cloud-delivered services above 70% as infrastructure costs fluctuate
5. **Working Capital on Hardware** — Reduce data centre hardware inventory days by 20% through better capacity planning and JIT procurement
6. **Launch on Time** — Release new product version within <1-sprint variance of committed customer roadmap date
7. **Professional Services Margin** — Keep professional services gross margin within ±3% through utilisation optimisation and project scope management
8. **Renewal Revenue at Risk** — Keep churn-driven ARR at risk below 5% by identifying at-risk accounts 90 days before renewal
9. **Model & React to Outage** — Detect, model, and resolve a multi-region cloud outage within 30 minutes using automated runbooks
10. **Compliance Readiness** — Achieve 100% export compliance screening for software with encryption capabilities in all shipped builds

---

## Regulatory & Compliance Considerations
- Export controls on encryption: EAR controls (BIS); ENC exception or licence required for strong encryption software exports to restricted countries
- Data sovereignty: GDPR (EU), CCPA (California), LGPD (Brazil) — drives data centre geography decisions
- FedRAMP / IL4/IL5 (US Government): cloud hosting compliance for government customers — shapes DC footprint
- SOC 2 Type II / ISO 27001: customer-required certifications for enterprise SaaS
- Open source licence compliance: GPL, LGPL, MIT — must be tracked in software BOM (SBOM)

## Sustainability Signals to Watch For
- Data centre PUE (Power Usage Effectiveness) — benchmark is <1.3 for hyperscalers
- Renewable energy % of data centre power consumption
- Hardware lifecycle management and e-waste commitments
- Scope 3: employee travel and commuting (often largest Scope 3 for software companies)

## Key Search Queries
```
<company> SaaS cloud transition revenue model ARR
<company> data center infrastructure cloud hosting AWS Azure GCP
<company> partner ecosystem reseller channel marketplace
<company> professional services utilisation margin delivery
<company> export control encryption EAR compliance software
<company> supply chain hardware procurement data center
<company> sustainability data center renewable energy PUE
<company> product roadmap launch NPI customer commitment
```
