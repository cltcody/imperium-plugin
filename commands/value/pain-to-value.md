---
description: Map customer pains to ${user_config.company} capabilities and value outcomes — with optional root-cause clustering, a capability heat map, and ranked recommendations with buyer personas
argument-hint: "[discovery notes or pain statements]"
---

Map the following pains to ${user_config.company} capabilities and value outcomes.

Paste pains or discovery notes: $ARGUMENTS

Run the base table always. The deeper analysis (Steps 2–5) is optional — use it after discovery
when you need a prioritised, heat-mapped solution recommendation (say "full capability map" or
"heat map" to force it); for a quick pass, the table + "After the table" section is enough.

## Step 1 — Pain-to-Value table

For each pain, produce:

| Pain (customer's words) | ${user_config.company} Capability | Product | Value outcome | Value type | Impact | Urgency | Confidence |
|------------------------|------------------|---------|--------------|-----------|--------|---------|------------|
| | | ${user_config.product_a} / ${user_config.product_b} / ${user_config.product_c} / ${user_config.product_d} | [time/cost/risk reduction] | Hard / Soft | H/M/L | H/M/L | 🟢/🟡 |

**Rules**
- Use the customer's exact words for the pain — do not reframe.
- Value outcomes must reference ${user_config.company}-specific capabilities (not generic software benefits).
- Hard value = directly measurable (FTE, $, days). Soft value = qualitative (risk reduction, compliance posture).
- **Impact** = business damage if unsolved (H/M/L). **Urgency** = how soon it must be solved (H/M/L). Confirm each with the user rather than assuming; mark assumptions 🟡.
- Tag every value claim: 🟡 Inferred (based on ${user_config.company} reference customers) unless this customer has confirmed a metric.

## Step 2 — Root-cause clustering (optional)

Group the pains by their **underlying root cause**, not their symptom — two pains often share one
cause and one fix. Derive the clusters from *this customer's* domain and ${user_config.company}'s capability
areas (do not impose a fixed taxonomy). For each cluster: name it, list the pains it covers, and
note whether it's a real root cause or a surface symptom of a deeper one.

## Step 3 — Capability heat map (optional)

Map the pains onto ${user_config.company}'s **own capability domains** (from your product/capability framework
in `cc.config.json` or the customer's discovery — *not* a hardcoded suite). Score each domain:

- **Critical** — 2+ pains map here, OR 1 pain with High impact + High urgency
- **High** — 1 pain with High impact OR High urgency
- **Medium** — 1 pain with Medium impact OR Medium urgency
- **Low** — mapped but lower priority · **—** — no current pain maps here

Produce a table: `Domain | Heat | Pains mapped | Evidence`. Never mark a domain Critical without a
specific pain (with evidence) driving it.

## Step 4 — Prioritised recommendations (optional)

From the heat map, produce ranked recommendations — Critical + High heat only:
1. The **top 3 capability domains**.
2. The ${user_config.company} product(s) that address each (${user_config.product_a}…${user_config.product_e}).
3. The **primary buyer persona** for each (who owns this problem and this budget).
4. A one-sentence value statement per domain, grounded in the customer's own numbers where known.

## Step 5 — Open data gaps

The discovery questions still needed to validate the case — the metrics you're currently
inferring (🟡) that must become confirmed (🟢) before the value case is defensible. Be explicit;
never paper a gap over with an assumption.

## ${user_config.company} value anchors (tag 🟡 Inferred until confirmed)
- ${user_config.product_a}: up to 90% reduction in manual classification effort; minutes per product vs days
- ${user_config.product_b}: near-zero manual document re-keying for covered document types; high accuracy on unstructured formats
- ${user_config.product_c}: 80%+ reduction in false positives; screening coverage across all counterparty types
- ${user_config.product_d}: systematic ${user_config.product_d} utilisation; rules-of-origin documentation automated; audit-ready

## After the table
- **Top 3 value drivers** (ranked by magnitude for this customer)
- **Biggest 🔴 gaps** in the value case (metrics we need to validate with the customer)
- **Recommended demo modules** (which pains to show in the demo, in priority order)
