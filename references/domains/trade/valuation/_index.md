# Trade Valuation Library — Pain → Lever Index

> **Directional benchmarks.** Ranges below are public-knowledge-based and directional. Validate against your own deal history before customer use; tag unvalidated figures 🟡 in any customer-facing output.

Eight quantified value levers for trade/customs/supply-chain deals. Used by
`/cc:value:roi-case` (resolve discovered pains → levers → formulas) and by
`business-case-stress-tester` (each lever file's "What a CFO challenges" section is the
attack list for cases built on that lever).

**How to use:** match what the customer actually said (left column) to lever file(s), open
the lever, build the driver from its formula and inputs table, then check the
**double-count matrix** below before summing drivers.

---

## Pain → lever map

| # | Discovered pain (customer language) | Lever(s) | Headline formula |
|---|---|---|---|
| 1 | "We pay duty on goods we end up re-exporting or that come back as returns." | [duty-drawback](duty-drawback.md) | R = duties paid × export-matched share × 99% × completeness × (1 − filing cost) |
| 2 | "We're pretty sure we're leaving trade-agreement savings on the table." | [fta-utilization](fta-utilization.md) | S = covered imports × eligible share × utilization gap × duty rate saved |
| 3 | "Our suppliers won't send origin certificates, so we just pay full duty." | [fta-utilization](fta-utilization.md) | S = covered imports × eligible share × utilization gap × duty rate saved |
| 4 | "Every broker bills us differently and nobody can compare the invoices." | [broker-consolidation](broker-consolidation.md) | S = entries × (blended cost/entry − consolidated cost/entry) + disbursement fees avoided |
| 5 | "We inherited a dozen brokers from acquisitions and no one owns the spend." | [broker-consolidation](broker-consolidation.md) | S = entries × (blended cost/entry − consolidated cost/entry) + disbursement fees avoided |
| 6 | "We took a customs penalty last year and legal is still cleaning it up." | [penalty-avoidance](penalty-avoidance.md) | A = 3-yr failure baseline × reduction + (event probability × severity × tail reduction, soft) |
| 7 | "My team files post-entry corrections all day long." | [penalty-avoidance](penalty-avoidance.md) | A = 3-yr failure baseline × reduction (correction admin is the hard part) |
| 8 | "Shipments sit at the port for days waiting on paperwork." | [clearance-working-capital](clearance-working-capital.md) (+ [expedite-otif-reduction](expedite-otif-reduction.md) if delays trigger expedites) | W = dwell days removed × daily imported COGS (one-time); annual = W × WACC + D&D avoided |
| 9 | "Demurrage and detention charges keep ambushing us on the freight bill." | [clearance-working-capital](clearance-working-capital.md) | Charges avoided = shipments × incident rate × avg charge × reduction |
| 10 | "Our cross-border parcels get taxed and brokered inconsistently by destination." | [de-minimis-optimization](de-minimis-optimization.md) | S = parcels × shiftable share × (value × duty rate + fee delta) × durability haircut |
| 11 | "The new tariff round just blew up our landed cost." | [fta-utilization](fta-utilization.md) + [duty-drawback](duty-drawback.md) + [de-minimis-optimization](de-minimis-optimization.md) — mitigation trio; apply the waterfall rule below | Each dollar of import value gets exactly one duty treatment |
| 12 | "Expedites are eating our margin." | [expedite-otif-reduction](expedite-otif-reduction.md) (+ [inventory-reduction](inventory-reduction.md) if forecast-driven) | S = expedite premium × addressable share × reduction |
| 13 | "Our biggest retail customer keeps fining us for late or short orders." | [expedite-otif-reduction](expedite-otif-reduction.md) | S = covered revenue × non-compliance % × fine rate × reduction |
| 14 | "We carry mountains of safety stock because nobody trusts the forecast." | [inventory-reduction](inventory-reduction.md) | ΔW = safety stock × demand-driven share × (1 − error ratio); annual = ΔW × carrying rate |
| 15 | "Finance says too much cash is tied up in inventory." | [inventory-reduction](inventory-reduction.md) (+ [clearance-working-capital](clearance-working-capital.md) for in-transit stock) | ΔW = safety stock × demand-driven share × (1 − error ratio) |
| 16 | "We can't even tell what we truly pay per shipment in fees and duties." | [broker-consolidation](broker-consolidation.md) first (visibility baseline), then re-run discovery for levers 1–2 | S = entries × cost-per-entry delta — the invoice sample built here feeds every other lever |

Pains that match **no lever**: don't force one. Log them for the qualitative half of the
case; an ROI case with two hard levers and honest gaps beats one with eight stretched levers.

---

## Stacking & double-count matrix

Before summing drivers, check every pair you used. ⛔ = never stack on the same underlying
value; ⚠️ = stackable only with the explicit split described; ✓ = independent.

| | Drawback | FTA | Broker | Penalty | Clearance-WC | De-minimis | Inventory | Expedite/OTIF |
|---|---|---|---|---|---|---|---|---|
| **Drawback** | — | ⛔ same import dollars: duty-free preferential entries yield no drawback | ✓ | ⚠️ documentation benefit priced once | ✓ | ⛔ no duty paid → nothing to recover | ✓ | ✓ |
| **FTA** | ⛔ | — | ✓ | ⚠️ origin-doc improvement: money in FTA, risk note in penalty | ✓ | ⛔ shifted parcels leave the FTA base | ✓ | ✓ |
| **Broker** | ✓ | ✓ | — | ⛔ fees here, error costs there | ⚠️ "better broker clears faster" — dwell value priced once | ⚠️ shifted parcels leave the broker entry count | ✓ | ✓ |
| **Penalty** | ⚠️ | ⚠️ | ⛔ | — | ✓ | ✓ | ✓ | ⛔ OTIF chargebacks are commercial, not regulatory — they live in Expedite/OTIF |
| **Clearance-WC** | ✓ | ✓ | ⚠️ | ✓ | — | ✓ | ⚠️ transit-variability stock there, demand-variability stock here — decompose | ⚠️ delay-caused expedites priced in exactly one lever |
| **De-minimis** | ⛔ | ⛔ | ⚠️ | ✓ | ✓ | — | ✓ | ✓ |
| **Inventory** | ✓ | ✓ | ✓ | ✓ | ⚠️ | ✓ | — | ⚠️ shared forecast root cause — allocate failure modes, stock vs flow |
| **Expedite/OTIF** | ✓ | ✓ | ✓ | ⛔ | ⚠️ | ✓ | ⚠️ | — |

**Universal rules:**

1. **Import-value waterfall.** Assign each dollar of import value to exactly one duty
   treatment — preferential (FTA), drawback-matched, low-value clearance, or full duty —
   before computing any duty lever. The three duty levers compete for the same dollars.
2. **One-time ≠ annual.** Working-capital releases (clearance-WC, inventory) are
   balance-sheet events reported on their own line; only carrying benefits recur. Never
   fold a release into the annual run-rate or the payback denominator silently.
3. **One improvement, one price.** A single operational improvement (better docs, better
   broker, better forecast) may touch several levers — monetize it in one, reference it
   qualitatively in the others.
4. **Soft stays soft.** Expected-value tail-risk components (penalty lever) never enter
   the hard-savings total.
5. **Banner discipline.** Every number sourced from this library is 🟡 in customer-facing
   output until validated per the lever's confidence-guidance section — per the banner at
   the top of every file.
