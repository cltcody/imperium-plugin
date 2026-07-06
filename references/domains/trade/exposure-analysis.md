# Exposure-Analysis Framework — Trade & Regulatory Exposure Briefs

The analysis method behind `/cc:account:exposure`. An exposure brief answers one question
for one account: **where does trade regulation touch this company's money, and how do we
know?** It is a research artifact, not a pitch — its credibility comes entirely from the
evidence chain behind each score. A brief that guesses confidently is worse than no brief.

Exemplar at the quality bar:
`${CLAUDE_PLUGIN_ROOT}/references/presales/exemplars/exposure-brief-exemplar.md`

---

## Method in one paragraph

Score the account against the **five exposure vectors** below, in order. For each vector:
gather evidence from the ranked sources, assign a 1–5 exposure score **only if the evidence
supports one of the anchored descriptions**, tag every claim 🟢🟡🔴, and record the questions
that would harden the score. A vector without evidence gets **"insufficient data"** — never
a guessed number. The brief closes with the mandatory "What we could NOT establish" section
and a so-what translation (which exposures create urgency, at capability level).

### Data-source stance (applies to every vector)

- **If a trade-data source is connected** (bill-of-lading / customs-records MCP or export),
  use it as the primary quantitative source: lanes, HS chapters, shipment counts, declared
  values, counterparty names. Claims from it are 🟢 with the dataset + date cited.
- **If not connected — the normal case — degrade to public sources** and say so in the
  brief's header: annual report / 10-K risk factors and supply-chain disclosures, earnings
  calls, sustainability reports, regulator lists and dockets, reputable trade press,
  job postings, and the company's own commerce footprint (shipping policies, marketplace
  presence). Quantitative inferences from these are 🟡 at best.
- The brief must state which mode it ran in. Silently mixing the two is a defect.

### Scoring scale

| Score | Meaning |
|-------|---------|
| **1** | Minimal — the vector barely touches this business; evidence affirmatively shows low exposure |
| **3** | Material — the vector demonstrably touches revenue, cost, or operations; unmitigated or partially mitigated |
| **5** | Severe — the vector is a structural threat: quantified financial impact, active enforcement/measures, or a business model built on the exposed channel |
| **insufficient data** | No evidence either way. A valid and honorable result — record what would be needed instead of a number |

Scores of 2 or 4 are permitted only when evidence genuinely sits between two anchors —
justify against **both** neighboring anchors when you use one. Note that a **1 requires
evidence too**: absence of information is "insufficient data", not a 1.

---

## Vector 1 — Tariff actions by trade lane / HS chapter

**Definition.** Exposure to duty increases and trade-remedy measures — additional tariffs,
safeguards, anti-dumping/countervailing duties, retaliation rounds — on the specific
origin→destination lanes and HS chapters the company actually imports in. Exposure is a
function of *lane concentration × chapter coverage × action status*, not of "imports a lot."

**Evidence sources, ranked by reliability:**

1. **Annual report / 10-K** — risk factors, MD&A, and supply-chain/sourcing sections:
   country-of-origin concentration, named manufacturing geographies, any quantified tariff
   cost or margin callout. 🟢 when quoted.
2. **Import records** — *if a trade-data source is connected*: import value by lane and HS
   chapter, matched against active/proposed actions. **Public fallback if not:** earnings-call
   transcripts (tariff questions from analysts), product documentation and teardown coverage
   implying country of origin, disclosed supplier or factory lists. 🟢 (connected) / 🟡 (fallback).
3. **Regulator dockets and action lists** — active and proposed tariff actions, remedy
   cases, exclusion processes covering the relevant chapters. 🟢 for the action's existence
   and scope; matching it to the company is your inference (🟡) unless the company is named.
4. **News and trade press** — escalation signals, sector coverage, company statements. 🟡.

**Anchored scores:**

- **1** — Import footprint is documented and concentrated in lanes/chapters with **no
  active or formally proposed actions**; tariff language in the risk factors is generic
  boilerplate with no quantification; no analyst has asked about tariffs on recent calls.
- **3** — **At least one major lane or dominant HS chapter sits under an active action or a
  formal investigation**, or the company has quantified tariff cost in a filing or call
  (a stated dollar/margin impact). Mitigation (re-sourcing, price pass-through) is mentioned
  but incomplete or unproven.
- **5** — **The majority of import value sits in lanes/chapters under active actions**, with
  escalation enacted or formally proposed on top; filings quantify a tariff hit to gross
  margin; the company has already been forced into visible responses (announced price
  increases, disclosed supplier-base shifts, inventory pull-forwards).

**Questions that move the score from guessed to evidenced:**

- What share of import value comes from each origin country, and from which HS chapters?
- Has the company quantified tariff cost anywhere public (filing, call, investor day)?
- Are any of its chapters covered by exclusions — and when do those expire?
- Is there evidence of re-sourcing (new factory geographies in filings or job postings), and
  what fraction of volume has actually moved?

---

## Vector 2 — Sanctions & denied-party proximity

**Definition.** Proximity of the company's suppliers, customers, logistics partners,
subsidiaries, or owners to sanctioned jurisdictions and denied-party/restricted-entity
lists — i.e., screening-obligation exposure and the blast radius of a bad match. This
vector scores *proximity and program maturity*, not moral judgment.

**Evidence sources, ranked by reliability:**

1. **Regulator lists themselves** — consolidated screening and restricted-entity lists,
   matched against the company's disclosed subsidiary, supplier, and partner names. A match
   or near-match is 🟢 for the list entry; the relationship's current status is usually 🟡.
2. **Annual report / 10-K** — the subsidiaries exhibit, geographic segment disclosure
   (operations in or adjacent to sanctioned/high-risk jurisdictions), legal-proceedings and
   risk-factor sections (enforcement matters, voluntary self-disclosures, market exits). 🟢.
3. **Import/export records** — *if a trade-data source is connected*: counterparty names on
   shipments, screened against the lists. **Public fallback:** enforcement-action databases
   and press releases, investigative journalism, the company's own compliance statements. 🟢/🟡.
4. **News** — enforcement coverage, sector advisories, divestment announcements. 🟡.

**Anchored scores:**

- **1** — No operations, segments, or disclosed counterparties in or adjacent to sanctioned
  or high-risk jurisdictions; no enforcement history findable; screening exposure limited to
  routine denied-party checks any importer runs.
- **3** — Operations or supply base in **jurisdictions adjacent to active sanctions
  programs**, or disclosed counterparties that plainly require enhanced screening;
  risk-factor language on sanctions goes beyond boilerplate (names programs or geographies);
  no disclosed screening-program details.
- **5** — A **named counterparty, affiliate, or owner on or credibly linked to a restricted
  list**; a disclosed enforcement matter, subpoena, or voluntary self-disclosure; or a
  disclosed exit from a sanctioned market with ongoing wind-down obligations.

**Questions that move the score from guessed to evidenced:**

- Has the full subsidiary and disclosed-counterparty list actually been screened, or only
  the famous names?
- What revenue share comes from high-risk jurisdictions (segment data, not vibes)?
- Does the company disclose a screening program, and at what depth (customers only, or
  suppliers and logistics partners too)?
- Any enforcement history — including settled or self-disclosed matters — in the last
  five years?

---

## Vector 3 — Carbon border measures (CBAM-class)

**Definition.** Exposure to carbon border adjustment mechanisms: importing covered goods
(the emissions-intensive categories these regimes enumerate — think primary metals, cement,
fertilizer classes) into jurisdictions operating such measures, plus the embedded-emissions
**reporting burden** and eventual **certificate cost**. Includes forward exposure where the
regime's scope-extension reviews would pull the company's products in.

**Evidence sources, ranked by reliability:**

1. **Annual report + sustainability report** — product mix versus covered categories,
   destination-market revenue split, whether supplier-level embedded-emissions data exists
   (a Scope-3 program that names suppliers is a strong signal it does). 🟢 when quoted.
2. **Import records** — *if a trade-data source is connected*: covered-code volumes into the
   relevant market. **Public fallback:** geographic revenue segments × product composition
   inference (what the products are physically made of). 🟢 (connected) / 🟡 (fallback).
3. **Regulator scope lists and guidance** — the covered-goods list, phase-in timeline, and
   any published scope-extension review. 🟢 for scope; applying it to the company is 🟡
   unless the product mapping is unambiguous.
4. **News / industry-association positions** — sector lobbying reveals who expects to pay. 🟡.

**Anchored scores:**

- **1** — Product mix contains **no covered categories** and no meaningful sales into
  jurisdictions operating such measures; or covered-market revenue is documented as
  negligible.
- **3** — Covered inputs are **embedded in the company's products or direct imports into a
  covered jurisdiction at material volume**; the reporting obligation applies (or a
  published scope extension would apply it); supplier emissions data has **not** been
  collected, so default values — the punitive path — would govern; cost not yet quantified.
- **5** — Covered goods are a **core import line into a covered jurisdiction**; the company
  acknowledges the measure as a material cost in filings or sustainability disclosures;
  supplier data is unavailable or unverifiable, and certificate-phase cost is quantified or
  plainly unavoidable at current sourcing.

**Questions that move the score from guessed to evidenced:**

- Which product lines contain covered inputs, and what import value do they carry into the
  covered market?
- Can suppliers provide verifiable embedded-emissions data — has anyone asked them yet?
- Who files the declarations today (the company, or a broker who will hand the liability back)?
- Where is the regime in its phase-in, and does a scope-extension review touch this sector?

---

## Vector 4 — Forced-labor supply-chain risk (UFLPA-class)

**Definition.** Exposure to import bans and detentions under forced-labor presumption
regimes: supply-chain links — at any tier — to flagged regions or listed entities, and the
traceability burden of **rebutting a presumption** (documentary proof of provenance down to
raw material). The operational risk is detention: goods held at the border while the company
assembles evidence it may not have.

**Evidence sources, ranked by reliability:**

1. **Regulator entity lists and detention statistics** — the listed-entity roster and
   published detention/seizure statistics by sector. 🟢 for the list and stats; mapping to
   the company is 🟡 unless a supplier is named.
2. **Annual report + sustainability report** — supplier code-of-conduct and audit
   disclosures, published supplier lists, raw-material provenance statements for
   high-scrutiny inputs (the fiber, polysilicon, and primary-metal classes these regimes
   concentrate on). 🟢 when quoted — but note what the disclosure *doesn't* cover (tier depth).
3. **Import records** — *if a trade-data source is connected*: shipper names screened
   against entity lists, origin sub-regions. **Public fallback:** NGO and investigative
   reporting on the sector's supply chains, supplier lists published for sustainability
   compliance. 🟢 (connected) / 🟡 (fallback).
4. **News** — detentions in the company's sector, peer enforcement, congressional or
   parliamentary attention to the product category. 🟡.

**Anchored scores:**

- **1** — Bill of materials contains **no high-scrutiny inputs**; tier-1 suppliers are
  documented and outside flagged regions; a traceability program with published evidence
  (supplier list + audit cadence) exists.
- **3** — **High-scrutiny inputs are present** in the product and provenance is unverified
  beyond tier 1; sector peers have had detentions; the company publishes a code of conduct
  but no traceability evidence (no supplier list, no chain-of-custody claims).
- **5** — A **supplier on or credibly linked to an entity list**; disclosed detentions or
  withhold-release exposure; or a majority of a key input sourced from a flagged region with
  no demonstrated isolation of the supply chain.

**Questions that move the score from guessed to evidenced:**

- Does the bill of materials include high-scrutiny inputs at all — which products, which inputs?
- How deep does traceability actually go: tier 1 attestations, or tier 2/3 chain-of-custody?
- Has the company experienced detentions (usually surfaces only in calls, news, or the
  customer's own admission — ask)?
- What is the detention rate in this sector, and what happened to the peers who got hit?

---

## Vector 5 — De-minimis / e-commerce regime changes

**Definition.** Dependence on low-value / de-minimis import channels — direct-to-consumer
cross-border parcel flows entering under simplified, duty-free thresholds — in markets that
are tightening or abolishing those thresholds. The exposure is a step-change in landed cost
and data obligations on a channel the business model may quietly depend on.

**Evidence sources, ranked by reliability:**

1. **Annual report / investor materials** — channel mix (DTC vs wholesale/retail), described
   fulfillment model (export-hub direct parcels vs in-country inventory), any stated
   dependence on cross-border e-commerce. 🟢 when quoted.
2. **Import records** — *if a trade-data source is connected*: formal-entry volumes versus
   the parcel volume the revenue implies — a gap suggests de-minimis reliance. **Public
   fallback:** the company's own shipping policies ("ships from" disclosures, delivery
   times implying origin), marketplace storefront presence, customs-operations job postings. 🟡.
3. **Regulator proposals and enacted rule changes** on de-minimis thresholds, parcel data
   requirements, and platform liability in each relevant market. 🟢 for the rule; the
   company mapping is 🟡.
4. **News / industry coverage** — enforcement pilots, carrier surcharges, sector reaction. 🟡.

**Anchored scores:**

- **1** — Negligible cross-border DTC parcel volume; goods enter destination markets via
  formal entries with duty paid (in-country inventory model); threshold changes would not
  alter the landed-cost model.
- **3** — A **meaningful DTC share is fulfilled cross-border under de-minimis in at least
  one major market where a change is proposed or enacted**; the landed-cost model would
  change materially; no disclosed mitigation (no in-country fulfillment buildout announced).
- **5** — The **business model is built on de-minimis**: majority of a major market's
  revenue arrives as direct parcels under the threshold; a change is enacted or imminent;
  margin or pricing impact is quantified, or unavoidable at current unit economics.

**Questions that move the score from guessed to evidenced:**

- DTC versus wholesale revenue split, per major market — stated where?
- What is the fulfillment topology (where does a customer's parcel actually ship from)?
- Average order value versus the relevant thresholds — above, below, or straddling?
- Any disclosed mitigation: in-country distribution centers, marketplace-of-record shifts,
  duty-paid pricing tests?

---

## Mandatory rules (non-negotiable, checked by the eval rubric)

1. **Every claim carries a confidence tag** — 🟢 Confirmed / 🟡 Inferred / 🔴 Unknown, with
   inline source attribution, per the house standard:
   `${CLAUDE_PLUGIN_ROOT}/skills/confidence-tagger/references/confidence-tagging.md`.
   A number without a source and a tag does not go in the brief.
2. **No evidence → "insufficient data", never a guessed score.** An invented 3 is the worst
   outcome this framework can produce: it looks like analysis and poisons the account plan.
   Record the score as *insufficient data*, list exactly what evidence would be needed, and
   move on. "Insufficient data" on a vector is a finding, not a failure.
3. **The "What we could NOT establish" section is required, not optional.** Every brief ends
   with it: the material unknowns, ranked by how much they would change the picture, each
   with how to fill it (call question, document request, trade-data connection). A brief
   without this section is incomplete regardless of how strong the rest is.
4. **Scores cite their anchors.** Each score is justified against the vector's anchored
   descriptions above — "scored 3 because [evidence] matches [anchor clause]" — falsifiably,
   so a reader holding the same evidence could dispute it.
5. **Brand-neutral and clean-room.** No company, product, or vendor names in this framework
   or in reusable examples derived from it; account briefs name the *account* (that is their
   job) but never pitch a named product — the so-what section speaks at capability level.
6. **State the data mode.** Trade-data source connected, or public-source fallback —
   declared once in the brief header (see the data-source stance above).

## Required brief shape

1. **Header** — account, date, author mode (trade-data connected / public fallback), sources consulted.
2. **Exposure summary table** — five vectors, score or *insufficient data*, one-line why.
3. **Per-vector analysis** — evidence chain, tagged claims, anchored score justification,
   hardening questions still open.
4. **What we could NOT establish** — mandatory (rule 3).
5. **So-what** — which exposures create urgency for a trade-compliance conversation, at
   capability level, each tied back to a scored vector.
6. **Gap list** — 🔴 items with why-it-matters and how-to-fill, per the tagging standard.
