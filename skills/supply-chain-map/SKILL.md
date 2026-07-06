---
name: supply-chain-map
description: |
  Builds a structured visual supply chain map for any named company from public research —
  manufacturing networks, distribution, logistics flows, CMO vs owned plants, freight modes,
  sourcing. Use on "map / diagram / analyse the supply chain of X". Not for code diagrams — use
  `diagram`.
---

# Supply Chain Map Skill

Produces a **structured, interactive supply chain map** for any company, covering:
- Tier structure (T2 raw materials → T1 suppliers → Manufacturing → DC → Channel → Consumer)
- Make/buy split (owned plants vs CMOs, % in-house)
- Distribution model (centralised hub, regional, hub-and-spoke, 3PL vs owned)
- Logistics overlay (ocean FCL/LCL, road FTL/LTL, air, parcel, rail — per lane)
- Volume & split indicators (where public data exists)
- Explicit confidence tagging: **Confirmed / Inferred / Unknown**

---

## Step 1 — Research phase

Before drawing anything, run targeted searches to populate the data model.
Search in this order, stopping each thread when you have enough signal:

### 1a. Company fundamentals
```
<company> supply chain manufacturing distribution model
<company> annual report 10-K properties manufacturing sites
<company> owned plants vs contract manufacturers CMO split
<company> distribution centers logistics network
```

### 1b. Logistics & transport
```
<company> logistics transport modes air freight ocean road
<company> freight emissions sustainability report transport
<company> 3PL partners logistics providers
<company> supply chain transformation distribution strategy
```

### 1c. Planning & technology
```
<company> supply chain planning S&OP ERP technology
<company> demand planning inventory management digital
<company> o9 Kinaxis Blue Yonder OMP ${user_config.company} SAP IBP
```

### 1d. Fill gaps with industry benchmarks
If company-specific data is thin, pull sector norms from the relevant reference file:
```
<industry> supply chain logistics modal split benchmarks
<industry> CMO outsourcing manufacturing typical percentage
```

**Capture confidence level for every data point as you go:**
- 🟢 **Confirmed** = quoted directly from annual report, sustainability report, or exec interview
- 🟡 **Inferred** = consistent with industry norm + company's known product/geography mix
- 🔴 **Unknown** = not findable; must be flagged as a gap

**Internal-source tier:** when the user supplies confirmed internal data
mid-conversation (e.g., named platforms, CMO partners, DC locations), treat it
as 🟢 Confirmed with an internal-source attribution ("Source: internal
(<user>, <month>)"). Move the corresponding line from the 🔴 Unknown column
to the 🟢 Confirmed column on the Gaps tab.

---

## Step 2 — Populate the data model

Before building the visual, fill this internal model (in your reasoning):

```
COMPANY: ___
INDUSTRY: ___   CLUSTER: ___
REVENUE: ___   FISCAL YEAR: ___

TIER STRUCTURE
  T2 raw material origins: [list with confidence]
  T1 supplier count / geography: [with confidence]

MANUFACTURING
  In-house %: ___  [confidence]
  Own plant locations + primary product: [list]
  CMO/CDMO/EMS role (flex / core / regional): [with confidence]
  Planning hub(s): [location + scope]

DISTRIBUTION
  Model type: centralised / regional / hub-and-spoke
  Primary DC locations: [list with confidence]
  3PL vs owned: [split + confidence]

LOGISTICS (per lane)
  Inbound T2→T1: [mode | confidence]
  Inbound T1→Plant: [mode | confidence]
  Plant→DC same-region: [mode | confidence]
  Plant→DC intercontinental: [mode | confidence]
  DC→Mass retail: [mode | confidence]
  DC→Prestige/specialty: [mode | confidence]
  DC→Travel retail: [mode | confidence]
  DC→Ecom/DTC: [mode | confidence]

PLANNING TECH STACK (always probe for this)
  Demand forecasting: ___   (e.g., o9, Kinaxis, SAP IBP, RELEX)
  Production scheduling: ___ (e.g., OMP, Aspen, proprietary)
  Distribution & inventory planning: ___ (e.g., Blue Yonder, Manhattan)
  Supplier collaboration: ___ (e.g., E2open, Exostar, SupplyOn)
  Customer collaboration: ___ (e.g., E2open, SPS Commerce, Retail Link)
  Visibility / Control Tower: ___ (e.g., FourKites, project44, o9)
  Global Trade & Compliance: ___ (e.g., SAP GTS, E2open, Descartes)
  Risk & Resilience: ___ (e.g., Resilinc, Everstream, riskmethods)
  ERP backbone: ___ (e.g., SAP S/4HANA, Oracle)

STRATEGIC AMBITIONS (from reference file and company sources)
  Growth: ___
  Efficiency: ___
  New business models: ___

TOP USE CASES (from reference file — frame the gap summary around these)
  [List top 3–5 most relevant use cases for this company's situation]

VOLUMES / SPLITS (public data only — do not fabricate)
  Air freight trend: ___
  Scope 3 transport emissions: ___
  SKU count: ___
  Countries served: ___

GAPS (what is NOT publicly known):
  [list each gap explicitly]
```

---

## Step 3 — Build the interactive visual

Use `visualize:show_widget` (HTML) or a standalone HTML file in the outputs
folder. Structure as **4 tabs minimum** (5 if planning tech or sustainability
data is rich):

### Tab 1 — Overview (end-to-end tier map)
SVG flowchart, top-to-bottom, 6 rows:
```
T2 Raw materials  →  T1 Suppliers  →  Manufacturing  →  Distribution  →  Channels  →  Consumer
```
- Color-code by node type (see color system below)
- Arrow thickness = relative volume (thick = dominant, thin = minor, dashed = minor/emergency)
- Every node clickable → opens **in-page detail drawer** (see Step 3b below)

### Step 3b — Interactive node detail drawer (MANDATORY)

When delivering as a standalone HTML file, the "click any node for deeper
dive" promise MUST be fulfilled with a real, self-contained interaction —
**not** a clipboard copy, alert, or stub.

**Right — build a sliding detail drawer:**
1. Add a right-side `<div class="drawer">` with close button, kind, title, body.
2. Add a `<div class="drawer-backdrop">` for dimmed overlay (click to close).
3. Pre-populate a `DETAILS` array in JS: one object per node with
   `{match, kind, title, body}`. `match` = unique substring of the onclick
   string; `body` = rich HTML (h4 sections, bullet lists, confidence tags, sources).
4. On node click, look up matching entry and render it into the drawer;
   add `.open` class to slide in. Close on ✕, backdrop click, or Escape key.
5. Provide curated content for **every major node** — plants, DCs, channels,
   raw-material categories, T1 suppliers, CMO network, consumer segment.
   Include confidence tags and sources inside each body.
6. Fallback for unmatched nodes: show "No curated detail yet" state.

The drawer CSS must include:
- Fixed position, full-height, width `min(460px, 92vw)`, transform-based slide
- Backdrop with `rgba(0,0,0,0.55)` and opacity transition
- `z-index: 50+` so it overlays tabs/SVG
- Body scrollable (`overflow-y: auto`) since detail can be long

### Tab 2 — Manufacturing (make/buy map)
- Large metric cards: % in-house vs CMO/EMS/CDMO
- Grid of owned plant boxes (location + primary product category)
- CMO/EMS box (role, scale, geography)
- Planning hub callout

### Tab 3 — Distribution (logistics overlay)
- Tier rows: Plants → DCs → Channels
- **Colored arrows by transport mode** (see mode color system below)
- Arrow labels: mode + volume indicator where known
- Confidence badges on key figures

### Tab 4 — Planning & Tech
Always include a dedicated row of cards for the planning technology stack if
even one platform is known. One card per SC function:
- Demand Planning platform
- Supply Planning platform
- Logistics / TMS platform
- Visibility / Control Tower platform
- Supplier Collaboration platform
- Customer Collaboration platform
- Global Trade & Compliance platform
- Risk & Resilience platform
- ERP backbone

Use a coloured left-border on each card matching the relevant node-colour class.

### Tab 5 — Data gaps (confidence matrix)
Three columns, always present:
| 🟢 Confirmed | 🟡 Inferred | 🔴 Unknown |
Show as side-by-side cards, one bullet per data point.
Bottom section: "Key confirmed signals" — the 2–3 most important public facts.
Bottom section: "Key use cases to explore" — top 3 use cases from the reference file most relevant to this company's gaps.

---

## Color system (use consistently across all maps)

### Node colors
| Node type | SVG class |
|-----------|-----------|
| Raw material suppliers | `c-gray` |
| Direct / T1 suppliers | `c-teal` |
| Owned manufacturing | `c-purple` |
| CMO / EMS / CDMO / outsourced mfg | `c-coral` |
| Distribution / DC | `c-blue` |
| Sales channels | `c-amber` |
| Consumer / end market | `c-green` |
| Planning / tech overlay | `c-teal` (dashed box) |

### Transport mode colors (logistics overlay)
| Mode | Hex | Use |
|------|-----|-----|
| Ocean FCL | `#185FA5` (blue 600) | Bulk intercontinental |
| Road FTL | `#0F6E56` (teal 600) | Plant→DC, DC→mass retail |
| Road LTL | `#3B6D11` (green 600) | DC→prestige/specialty |
| Air (emergency) | `#854F0B` (amber 700) | Always dashed — declining |
| Parcel (express) | `#993556` (pink 600) | DTC, ecom last-mile |
| Ocean LCL | `#888780` (gray 500) | Dashed — small consolidated |
| Rail / intermodal | `#534AB7` (purple 600) | Where applicable |

Arrow stroke weight:
- 3px = dominant / high volume
- 2px = significant
- 1.5px = minor / specialist
- Dashed = emergency / declining / low-frequency

---

## Step 4 — Confidence tagging rules

**Every** numeric claim and structural assertion must carry a confidence badge.

```
🟢 Confirmed — cite source (annual report, sustainability report, exec quote,
               OR internal source provided by user)
🟡 Inferred  — state the reasoning ("Road FTL inferred: EU-EU lane, industry norm")
🔴 Unknown   — state exactly what is missing ("Named 3PL partners not disclosed")
```

Never present inferred data as confirmed. Never fabricate volumes, percentages,
or cost figures. If a volume figure does not exist publicly, mark it 🔴 and note
it in the Data Gaps tab.

**When the user supplies internal data mid-conversation:** update the widget
immediately — move items from 🔴 to 🟢, add the platform/name card, attribute
the source inline ("Source: internal (<user>, <month>)").

---

## Step 5 — Volume & split indicators

Use these sources in priority order:
1. **Annual report / 10-K** — Properties section, Segment reporting, MD&A
2. **Sustainability report** — Transport emissions, modal split trends, air freight %
3. **Earnings calls** — CSCO/COO commentary on logistics strategy
4. **Trade press / McKinsey / Gartner** — Exec interviews on SC transformation
5. **Industry benchmarks** — Only when company-specific data is absent; must be tagged 🟡
6. **User-supplied internal data** — Always treat as 🟢 with internal attribution

---

## Step 6 — Output structure

Deliver in this sequence:

1. **Brief research summary** (2–3 sentences in prose) — what you found and confidence level
2. **Interactive widget** (4–5 tabs as above, with working drawer per Step 3b)
3. **Saved HTML file** — always write the full widget HTML to `mnt/outputs/<CompanyName>_supply_chain_map.html` (see Saving outputs below)
4. **Gap summary** (short prose after the widget) — the 3–5 most important unknown facts
5. **Top use cases** (2–3 sentences) — highlight which of the industry's Top 10 Use Cases are most relevant given the gaps identified
6. **Follow-up offer** — ask if user has internal data to enrich the map
7. **G2M Handoff Package** — always emit this block at the end (see Step 7)

---

## Saving outputs

After delivering the interactive widget, **always** save a standalone copy of the full HTML to the user's outputs folder:

```
/sessions/eloquent-sharp-rubin/mnt/outputs/<CompanyName>_supply_chain_map.html
```

- Use the company name (spaces replaced with underscores, no special characters) in the filename, e.g. `Unilever_supply_chain_map.html`, `Colgate_Palmolive_supply_chain_map.html`.
- The file must be fully self-contained — all CSS, JavaScript, and data embedded inline — so it opens correctly without an internet connection.
- This is the same HTML as the widget; just write it to disk using the Write tool or Bash after rendering the widget.
- If the user has not mounted an outputs folder, note that the file has been saved to the session's working folder and will be accessible via the file link.

After saving, provide a `computer://` link so the user can open the file directly:
```
[View saved map](computer:///sessions/eloquent-sharp-rubin/mnt/outputs/CompanyName_supply_chain_map.html)
```

---

## Step 7 — G2M Handoff Package

Always emit this structured block at the very end of every supply chain map output. It packages the key signals that feed directly into the ${user_config.company} G2M qualification workflow — so the transition from account research to solution fit assessment is instant rather than requiring the user to re-enter context.

```
---
## 🔗 G2M Handoff Package
*Ready for ${user_config.company}-g2m — continue directly or copy into a new session*

**Account:** [company name]
**Industry:** [taxonomy label, e.g. "Consumer Packaged Goods"]
**Cluster:** [High Tech / Industrial / Consumer]
**Revenue / Size:** [confirmed figure or "Est. >$Xbn" with confidence tag]
**Primary Geographies:** [e.g. "North America, Western Europe, Asia-Pacific"]

**Current Tech Stack:**
| Function | Platform | Confidence |
|---|---|---|
| Demand Planning | [platform or Unknown] | 🟢/🟡/🔴 |
| Supply Planning | [platform or Unknown] | 🟢/🟡/🔴 |
| TMS / Logistics | [platform or Unknown] | 🟢/🟡/🔴 |
| Supplier Collaboration | [platform or Unknown] | 🟢/🟡/🔴 |
| Global Trade / Compliance | [platform or Unknown] | 🟢/🟡/🔴 |
| Visibility / Control Tower | [platform or Unknown] | 🟢/🟡/🔴 |

**Key Pain / Gap Signals:**
- [Gap 1 — e.g. "No supplier collaboration platform identified 🔴"]
- [Gap 2 — e.g. "Air freight over-reliance flagged in sustainability report"]
- [Gap 3 — e.g. "Multi-region distribution with no confirmed visibility tool"]

**Strategic Ambitions:**
- [e.g. "Reducing logistics cost", "DTC expansion", "Supply chain digitalisation"]

**Top ${user_config.company} Use Cases to Explore:**
- [Use case 1 — map from the industry reference file, prioritised by gap fit]
- [Use case 2]
- [Use case 3]

**Displacement / Expansion Signals:**
- [e.g. "SAP IBP in use for demand — potential to expand into supply collaboration"]
- [e.g. "No GTM platform found — global trade compliance gap"]

**ISC Flag:** [Yes — if Planning, GTM Suite, or Supply Collaboration in scope / No]
---
```

**Guidance on the tech stack table:** only include rows where there is something meaningful to say — a confirmed platform, a confirmed gap, or a strong inferred signal. Omit rows that are purely unknown with no directional signal; they add noise. The purpose of this block is to give the G2M agent a running start, not to replicate the full map.

---

## Industry-specific variations — FULL TAXONOMY

Read the relevant reference file **before** building. Files are organised by cluster:

### 🔵 HIGH TECH cluster
| Industry | Reference file | Representative companies |
|----------|---------------|--------------------------|
| Technology Devices | `references/technology-devices.md` | Dell, Logitech, Google, Apple, HP |
| Semiconductors | `references/semiconductors.md` | Infineon, Intel, TSMC, Qualcomm |
| Telecomm & Network | `references/telecomm-network.md` | Nokia, Vodafone, Verizon, Ericsson |
| Medical Tech Devices | `references/medical-tech-devices.md` | Intuitive Surgical, Philips, Medtronic |
| Software | `references/software.md` | Red Hat, HPE, SAP, Salesforce |

### 🟤 INDUSTRIAL cluster
| Industry | Reference file | Representative companies |
|----------|---------------|--------------------------|
| Industrial Manufacturing | `references/industrial-manufacturing.md` | CAT, Assa Abloy, Emerson, Honeywell |
| Automotive | `references/automotive.md` | JLR, Ford, Honda, Continental, Toyota |
| Aerospace & Defence | `references/aerospace-defence.md` | Exostar, Boeing, Rolls-Royce, BAE Systems |

### 🟢 CONSUMER cluster
| Industry | Reference file | Representative companies |
|----------|---------------|--------------------------|
| Consumer Packaged Goods | `references/consumer-packaged-goods.md` | P&G, PMI, Unilever, Colgate |
| Food & Beverage | `references/food-beverage.md` | Campbell's, Mars, Kellanova, Nestlé |
| Retail | `references/retail.md` | Aldi, Lidl, Ulta, Sobeys, Walmart |
| Apparel & Footwear | `references/apparel-footwear.md` | Nike, Inditex, ASOS, Hugo Boss |
| Lifesciences (Pharma & Biotech) | `references/lifesciences.md` | Biogen, Eli Lilly, Abbott, Pfizer |

**If the company's sector is ambiguous**, match on these signals:
- Sells physical product to end consumers → Consumer cluster
- Sells to other businesses for integration → High Tech or Industrial
- Product goes into the body → Lifesciences
- Product has a chip → High Tech (Technology Devices or Semiconductors)
- Product is a large capital item → Industrial

**If no exact match**, use the closest industry by product type and note the approximation.

---

## Quality checklist (run before delivering)

- [ ] Correct industry reference file read before building
- [ ] All 4 tabs present (Overview, Manufacturing, Distribution, Gaps)
- [ ] Planning & Tech tab included with all 9 SC function cards
- [ ] Every node is clickable **and opens a working in-page detail drawer**
      (NOT a clipboard copy or alert)
- [ ] DETAILS array covers every major node with confidence tags + sources
- [ ] Drawer closes via ✕, backdrop click, and Escape key
- [ ] Every arrow has a transport mode color
- [ ] At least one confirmed data point per tier row
- [ ] Data Gaps tab has at least 5 entries in the 🔴 Unknown column
- [ ] Top use cases surfaced in gap summary
- [ ] User-supplied internal data reflected as 🟢 with internal attribution
- [ ] No fabricated volumes or percentages
- [ ] Confidence badges visible on key figures
- [ ] Legend present (node colors + transport mode colors)
- [ ] Note at bottom: "Click any node to explore further"
- [ ] G2M Handoff Package emitted at the end with tech stack table, gap signals, use cases, and ISC flag
- [ ] Standalone HTML file saved to `mnt/outputs/<CompanyName>_supply_chain_map.html` with `computer://` link provided
