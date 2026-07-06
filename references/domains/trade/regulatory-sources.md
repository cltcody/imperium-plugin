# Trade Regulatory Sources — Curated Watch List

The source map `/cc:radar:scan` executes against. Each entry says **where to look, what a
change there actually means, how often to expect one, and how to recover the source when
its URL drifts**. The change-significance rubric at the bottom decides what scan surfaces
loudly (MAJOR), lists (ROUTINE), or merely logs (NOISE).

**Maintenance.** Regulator URLs rot without notice — sites migrate, slugs change, archives
move. Every source therefore carries a **Re-find** field (search phrase + publishing
organization) that recovers it via WebSearch. If a fetch fails, use the Re-find field
before declaring the source dead; if the recovered URL differs, update this file.
Some environments also block direct fetches to government hosts at the network-policy
level — WebSearch against the Re-find phrase is the standard fallback there too.

**Provenance:** authored 2026-07-02. Every URL verified live on that date (via web search
result confirmation; direct fetch was policy-blocked in the authoring environment — see
note above). Re-verify opportunistically on each scan.

---

## Exposure-vector legend

Each source feeds one or more exposure vectors (defined in `exposure-analysis.md`):

| Code | Vector |
|------|--------|
| **T** | Tariff actions by trade lane / HS chapter |
| **S** | Sanctions & denied-party proximity |
| **C** | CBAM / carbon border measures |
| **F** | Forced-labor supply-chain risk |
| **D** | De-minimis / e-commerce entry changes |

## Source index

| # | Source | Jurisdiction | Cadence | Vectors |
|---|--------|--------------|---------|---------|
| 1 | Federal Register — trade agency dockets | US | business-daily | T S D |
| 2 | USTR — Section 301 actions & exclusions | US | episodic (weeks–months) | T |
| 3 | CBP — CSMS bulletins | US | multiple per day | T F D |
| 4 | OFAC — Recent Actions (SDN updates) | US | several per week | S |
| 5 | BIS — Entity List | US | batched, roughly monthly–quarterly | S |
| 6 | DHS/CBP — UFLPA Entity List & enforcement stats | US | list: several batches/yr; stats: monthly | F |
| 7 | EU Official Journal — L series | EU | business-daily | T S C F |
| 8 | TARIC — integrated tariff database | EU | daily data updates | T C |
| 9 | CBAM — implementation hub | EU | milestone-driven | C |
| 10 | UK Trade Remedies Authority — public case file | UK | per-case events (weeks) | T |
| 11 | WCO — HS nomenclature revision cycle | Global | 5-year cycle + milestone docs | T |
| 12 | EU Forced Labour Regulation (2024/3015) | EU | milestone-driven | F |

---

## US sources

### 1. Federal Register — trade agency dockets

| Field | Value |
|-------|-------|
| URL | https://www.federalregister.gov/agencies/trade-representative-office-of-united-states |
| What changes | The legal record of US trade action: notices of investigation, proposed and final tariff modifications, exclusion grants/extensions, comment-period openings, hearing schedules. A tariff action is not law until it appears here — this is the authoritative confirmation layer for anything rumored elsewhere. Also carries BIS Entity List final rules and OFAC sanctions notices (see sources 4–5 for their faster native feeds). |
| Cadence | Publishes every business day; trade-docket items typically several per week, spiking around active investigations. |
| Re-find | Search `Federal Register agency page United States Trade Representative documents` — publisher: Office of the Federal Register (federalregister.gov). The site also exposes per-agency RSS (`documents.rss?conditions[agencies][]=trade-representative-office-of-united-states`). For BIS/Treasury items, swap the agency name in the search. |
| Feeds vectors | T, S, D (de-minimis rule changes publish here as proposed/final rules) |

### 2. USTR — Section 301 investigations, tariff actions & exclusions

| Field | Value |
|-------|-------|
| URL | https://ustr.gov/issue-areas/enforcement/section-301-investigations (tariff lists & exclusion process under `/tariff-actions`) |
| What changes | The policy layer ahead of the legal layer: new 301 investigations announced, tariff action lists modified (product/HS-subheading coverage, rates), exclusion processes opened/closed, exclusion extensions, statutory review outcomes. Changes here foreshadow Federal Register notices by days-to-weeks — earliest reliable signal on lane-level tariff exposure. |
| Cadence | Episodic — quiet for weeks, then clusters of activity around an investigation or review. Check weekly. |
| Re-find | Search `USTR Section 301 investigations tariff actions exclusion process` — publisher: Office of the United States Trade Representative (ustr.gov). Press releases at `ustr.gov/about/policy-offices/press-office` if the enforcement subtree reshuffles. |
| Feeds vectors | T |

### 3. CBP — Cargo Systems Messaging Service (CSMS)

| Field | Value |
|-------|-------|
| URL | https://www.cbp.gov/trade/automated/cargo-systems-messaging-service (message platform: https://csms.cbp.gov/) |
| What changes | The operational layer: how announced policy actually hits the border. Filing guidance for new duties (which HTS flags, which entry types, effective timestamps), ACE system programming changes, effective-date corrections, enforcement-mechanics updates (incl. forced-labor detention procedures and de-minimis entry handling). When policy and CSMS guidance disagree on an effective date, CSMS is what the border enforces. |
| Cadence | Multiple messages per day; only a fraction are duty/enforcement-relevant (many are pure system-maintenance notices). |
| Re-find | Search `CBP Cargo Systems Messaging Service CSMS` — publisher: U.S. Customs and Border Protection (cbp.gov). Individual bulletins are mirrored on the agency's email-bulletin service; searching `CSMS <topic>` usually surfaces the exact message. |
| Feeds vectors | T, F, D |

### 4. OFAC — Recent Actions (SDN & sanctions list updates)

| Field | Value |
|-------|-------|
| URL | https://ofac.treasury.gov/recent-actions |
| What changes | Every sanctions-list event in human-readable form: SDN additions/removals/modifications, new sanctions programs, general licenses issued/amended, guidance and FAQs. Changes appear here **before** Federal Register publication — this is the fastest authoritative denied-party signal. Machine-readable list files and a change archive hang off the same site. |
| Cadence | Several actions per week; large batch designations arrive without warning. |
| Re-find | Search `OFAC recent actions sanctions list updates` — publisher: U.S. Department of the Treasury, Office of Foreign Assets Control (ofac.treasury.gov). The SDN change archive lives under `specially-designated-nationals-list-sdn-list`. |
| Feeds vectors | S |

### 5. BIS — Entity List (Export Administration Regulations)

| Field | Value |
|-------|-------|
| URL | https://www.bis.gov/entity-list (legacy mirror: bis.doc.gov, `Supplement No. 4 to Part 744`) |
| What changes | Additions, removals, and modifications to the Entity List — parties subject to export license requirements. Changes land as batched Federal Register final rules (often effective on publication) and the list page updates in step. An addition can instantly make a counterparty unservable for controlled goods/technology. Note: the agency migrated from `bis.doc.gov` to `bis.gov`; both currently resolve — prefer the new host. |
| Cadence | Batched rules roughly monthly-to-quarterly, sometimes 30+ entities per rule. |
| Re-find | Search `BIS Entity List Supplement No. 4 Part 744` — publisher: U.S. Department of Commerce, Bureau of Industry and Security. Amendments always cross-publish in the Federal Register (search `Federal Register additions to the Entity List`). |
| Feeds vectors | S |

### 6. DHS/CBP — UFLPA Entity List & enforcement statistics

| Field | Value |
|-------|-------|
| URL | https://www.dhs.gov/uflpa (Entity List under the same subtree; enforcement dashboard: https://www.cbp.gov/newsroom/stats/trade/uyghur-forced-labor-prevention-act-statistics) |
| What changes | Two distinct signals. (a) **Entity List additions** — suppliers whose goods carry a rebuttable presumption of forced-labor origin and are barred from entry; additions arrive in batches and immediately taint any supply chain touching a listed party. (b) **Enforcement statistics** — shipment detentions/denials by industry and origin; sustained shifts reveal where enforcement attention is moving before any list change. The annual enforcement-strategy update flags next-target industries. |
| Cadence | List: several batch additions per year. Stats dashboard: refreshed roughly monthly (revamped 2026). Strategy update: annual. |
| Re-find | Search `UFLPA Entity List DHS Uyghur Forced Labor Prevention Act` — publisher: U.S. Department of Homeland Security (Forced Labor Enforcement Task Force); dashboard publisher: U.S. Customs and Border Protection. |
| Feeds vectors | F |

## EU sources

### 7. EU Official Journal — L series (Legislation)

| Field | Value |
|-------|-------|
| URL | https://eur-lex.europa.eu/oj/daily-view/L-series/default.html (browse hub: `/oj/direct-access.html`) |
| What changes | The EU's legal layer: anti-dumping and countervailing duty regulations (definitive and provisional), safeguard measures, sanctions regulations (restrictive-measures amendments), Combined Nomenclature amendments, CBAM implementing acts, and the annual CN update each autumn. Only the electronic OJ on this site is legally authentic — a measure exists when it appears here. |
| Cadence | Business-daily publication; trade-relevant acts several per week. |
| Re-find | Search `EUR-Lex Official Journal L series daily view` — publisher: Publications Office of the European Union (eur-lex.europa.eu). Since Oct 2023 each act publishes individually (no collated issue), so per-act search `EUR-Lex regulation <topic>` also works. |
| Feeds vectors | T, S, C, F |

### 8. TARIC — EU integrated tariff database

| Field | Value |
|-------|-------|
| URL | https://ec.europa.eu/taxation_customs/dds2/taric/taric_consultation.jsp?Lang=en (explainer: https://taxation-customs.ec.europa.eu/customs/common-customs-tariff-cct/tariff-classification-goods/eu-customs-tariff-taric_en) |
| What changes | The applied layer: measure-level data per goods code × origin — third-country duty rates, AD/CVD measures with company-specific rates, tariff quotas, suspensions, prohibitions, certificate requirements. OJ acts become enforceable customs reality here; national systems sync from this daily. A rate you'd quote a customer comes from TARIC, not from the act. |
| Cadence | Updated daily (data transmission to member-state administrations is daily). |
| Re-find | Search `TARIC consultation European Commission customs tariff database` — publisher: European Commission, Directorate-General for Taxation and Customs Union. The consultation tool URL shape (`dds2/taric/taric_consultation.jsp`) has been stable for years but the host path may migrate — the explainer page always links the live tool. |
| Feeds vectors | T, C |

### 9. CBAM — Carbon Border Adjustment Mechanism implementation hub

| Field | Value |
|-------|-------|
| URL | https://taxation-customs.ec.europa.eu/carbon-border-adjustment-mechanism_en |
| What changes | Implementation milestones and mechanics of the EU carbon border levy. Definitive regime live since 2026-01-01: importers of covered goods (iron/steel, aluminium, cement, fertilisers, electricity, hydrogen) must be authorized CBAM declarants; financial obligations accrue on 2026 imports with first certificate settlement in 2027. Watch for: new implementing acts (default values, verification, certificate pricing, registry rules), scope-expansion proposals (downstream products), and default-value revisions — each shifts landed cost on covered lanes. |
| Cadence | Milestone-driven — implementing acts arrive in clusters; between clusters, monthly checks suffice. |
| Re-find | Search `carbon border adjustment mechanism European Commission taxation customs` — publisher: European Commission, DG TAXUD. Implementing acts also publish in the OJ (source 7). |
| Feeds vectors | C |

## UK sources

### 10. UK Trade Remedies Authority — public case file

| Field | Value |
|-------|-------|
| URL | https://www.trade-remedies.service.gov.uk/public/cases/ (org page: https://www.gov.uk/government/organisations/trade-remedies-authority) |
| What changes | UK trade-remedy case lifecycle: new anti-dumping/countervailing/safeguard investigation initiations, registration deadlines, provisional and final determinations, transition reviews of inherited measures, suspension/revocation decisions. Each case page carries the non-confidential public file. An initiation signals possible future duties on a product/origin pair; a final determination changes UK landed cost. |
| Cadence | Per-case events every few weeks; new initiations a handful per year. Check weekly. |
| Re-find | Search `Trade Remedies Authority public cases trade remedies service` — publisher: UK Trade Remedies Authority (gov.uk / trade-remedies.service.gov.uk). Determinations also announce via the org's gov.uk news page. |
| Feeds vectors | T |

## Global sources

### 11. WCO — Harmonized System nomenclature revision cycle

| Field | Value |
|-------|-------|
| URL | https://www.wcoomd.org/en/topics/nomenclature/instrument-and-tools/hs-nomenclature-2028-edition.aspx (cycle process: `/nomenclature/activities-and-programmes/amending_hs.aspx`) |
| What changes | The classification foundation under every tariff schedule. HS revises on a ~5-year cycle; **HS 2028** (adopted Dec 2025, published Jan 2026, in force 2028-01-01) amends ~8% of subheadings: 6 new headings, 428 new subheadings created, 172 deleted. Watch for: correlation tables (HS 2022 → HS 2028), national/EU adoption acts, and Committee classification decisions between editions. Every reclassified code silently changes duty rates, FTA eligibility, and any system keyed on HS literals. |
| Cadence | 5-year cycle; milestone documents (amendment sets, correlation tables, explanatory-note updates) land irregularly through the 2026–2027 implementation window. Monthly check is enough. |
| Re-find | Search `WCO HS nomenclature 2028 edition amendments` — publisher: World Customs Organization (wcoomd.org). After 2028, search the next edition year. |
| Feeds vectors | T (indirectly all vectors — HS codes key sanctions, CBAM and forced-labor scoping too) |

### 12. EU Forced Labour Regulation (Regulation (EU) 2024/3015)

| Field | Value |
|-------|-------|
| URL | https://eur-lex.europa.eu/eli/reg/2024/3015/oj/eng (Commission implementation page: https://single-market-economy.ec.europa.eu/single-market/goods/forced-labour-regulation_en) |
| What changes | The EU's UFLPA-class regime: a ban on placing forced-labor-made products on the EU market (any sector, any origin, component-level taint). In force since 2024-12-13; fully applicable **2027-12-14**. Pre-application milestones to watch: Commission implementation guidelines and the public **risk database** (geographic areas × product categories) due by 2026-06-14 — once live, database entries function like an enforcement watch list; member-state competent-authority designations and penalty regimes. Unlike UFLPA there is no entity list yet — the risk database is the nearest analogue. |
| Cadence | Milestone-driven through 2027; once the risk database is live, check it monthly for entry changes. |
| Re-find | Search `EU forced labour regulation 2024/3015 ban products` — publisher: European Commission (EUR-Lex for the act; DG GROW for implementation). |
| Feeds vectors | F |

---

## Change-significance rubric

Applied by `/cc:radar:scan` to every detected change. When in doubt between two tiers,
classify **up** and say why. Tier assignment is about **decision impact for someone with
exposure on the affected lane/list/code** — not about how loud the announcement was.

| Tier | Definition | Scan behavior |
|------|------------|---------------|
| **MAJOR** | Creates, removes, or materially re-prices a legal obligation on identifiable goods, lanes, or parties — someone must *act* (re-source, re-price, file, screen, stop shipping). Includes new enforcement powers going live and classification changes that cascade into rates/eligibility. | Surface at top of digest with affected scope (HS chapters / origins / party names), effective date, and action window. |
| **ROUTINE** | Scheduled, procedural, or narrow-scope movement inside an existing framework — worth a line so trend-watchers see the machine turning, but no immediate action for most holders of exposure. | List in digest body, one line each. |
| **NOISE** | No new obligation, scope, rate, or date — restatements, ceremony, system trivia. | Log to state only; never in the digest. |

### MAJOR — worked examples

1. A new Section 301 investigation is initiated against a major trading partner's
   practices (e.g., the 2026 initiation against an origin country's IP regime). No duty
   exists yet, but the statutory path to tariffs on that lane has opened — anyone sourcing
   from that origin needs a contingency line in their next planning cycle. *Initiations
   are MAJOR even though the rate change is months away: the action window opens now
   (comments, exclusion positioning, sourcing hedges).*
2. A batch Entity List rule adds 30+ parties with license-review presumption of denial
   effective on publication. Every exporter and re-exporter must re-screen counterparties
   the same day — retroactive screening gaps are violations.
3. An OFAC batch designation adds parties in a jurisdiction where watched accounts have
   suppliers — denied-party proximity changed overnight, payment and shipment flows may
   already be non-compliant.
4. CBAM definitive-regime implementing act sets certificate pricing/settlement mechanics,
   converting a reporting exercise into a per-tonne landed-cost line on covered imports —
   quoting and margin models on those lanes must be re-run.
5. HS 2028 correlation tables publish: every system, schedule, and FTA-eligibility rule
   keyed on the ~600 changed subheadings now has a hard migration deadline (2028-01-01).

### ROUTINE — worked examples

1. The annual EU Combined Nomenclature update publishes in the OJ each autumn —
   scheduled, mostly technical code housekeeping; only holders of the specific renumbered
   codes need to touch anything.
2. A scheduled TARIC nomenclature correction or daily measure-data refresh with no rate
   or scope change — the database turning over as designed.
3. USTR extends existing Section 301 exclusions unchanged for another period —
   status-quo-preserving; beneficiaries note the new expiry date, nobody re-prices.
4. A UK TRA transition review of an inherited measure opens (initiation of a *review*,
   not a new investigation) — parties on that product register interest; everyone else
   just watches.
5. Monthly UFLPA enforcement-statistics refresh showing detention volumes consistent with
   the running trend — confirms the picture, changes no decision. *(Escalate to MAJOR
   only if the mix shifts sharply into a watched industry or origin.)*

### NOISE — worked examples

1. A press release restating an existing tariff policy or celebrating an anniversary of a
   measure — no new scope, rate, party, or date.
2. A CSMS message announcing scheduled ACE system maintenance or a certification-webinar
   reminder — pure operations, no trade-measure content.
3. Advisory-committee membership solicitations and hearing-logistics notices in the
   Federal Register trade docket — the docket's ambient hum.
4. A regulator's site navigation/branding refresh (e.g., a host migration with content
   unchanged) — update this file's URL, log it, tell no one.

### Escalation modifiers

- **Watchlist proximity:** a ROUTINE change that directly touches an HS chapter, origin,
  or party on the invoking workspace's account watchlist is reported as MAJOR **for those
  accounts** (scan flags the promotion).
- **Effective-date compression:** any change effective in <14 days moves up one tier —
  short action windows are themselves the risk.
- **Stacking:** several ROUTINE changes converging on one lane in a single scan period
  are surfaced together with a note — trend onset looks like routine noise item-by-item.
