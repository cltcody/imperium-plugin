# Valuation Lever — De-Minimis / Low-Value Clearance Optimization

> **Directional benchmarks.** Ranges below are public-knowledge-based and directional. Validate against your own deal history before customer use; tag unvalidated figures 🟡 in any customer-facing output.

Route eligible low-value cross-border shipments through the destination country's
low-value/de-minimis clearance regime — lawfully, via fulfillment-network structure (where
the parcel ships from, and as whose importation) — saving duty, tax where applicable, and
formal-entry brokerage costs. **Regulatory volatility warning:** de-minimis thresholds are
actively contracting in several major markets (the US sharply restricted its regime for
many origins in 2025; the EU has moved to close low-value exemptions). This lever must be
sized on the *current* rulebook per destination at proposal time, and the durability risk
disclosed — never sell a multi-year run-rate on a threshold under legislative attack.

---

## 1. Formula

```
Annual savings  S = P × e × (v × d + Δf) × h

Where:
  P  = annual cross-border direct-to-consumer parcels
  e  = shiftable share — % of parcels under the destination threshold AND
        restructurable to qualify (origin, channel, consignee rules)
  v  = average declared value per parcel
  d  = average duty (+ import tax where the regime waives it) rate avoided
  Δf = per-parcel clearance-cost delta (formal/informal entry fee vs
        low-value manifest clearance)
  h  = durability & eligibility haircut for regulatory change risk and
        qualification failures over the modeled year
```

**Worked example (synthetic figures):**

| Term | Value |
|---|---|
| P — annual parcels | 500,000 |
| e — shiftable share | 60% |
| v — avg declared value | $40 |
| d — duty/tax rate avoided | 12% |
| Δf — clearance-cost delta | $1.50/parcel |
| h — durability haircut | 70% |

```
Shiftable parcels    = 500,000 × 0.60                  = 300,000
Per-parcel saving    = (40 × 0.12) + 1.50              = 4.80 + 1.50 = 6.30
Gross savings        = 300,000 × 6.30                  = 1,890,000
Net annual savings S = 1,890,000 × 0.70                = 1,323,000
```

**Annual value: $1,323,000** — with the h = 70% haircut and the regime-risk caveat stated
in the same breath.

---

## 2. Inputs table

| Input | Where discovery uncovers it | Typical range | Basis |
|---|---|---|---|
| P, v — parcel volume & value profile | E-commerce/DTC operations persona; parcel-mode volumes surface in TMS suite modes territory (T.1.8 Parcel) and the logistics suite's last-mile sections | Deal-specific; v must come as a distribution, not a mean — threshold eligibility is per-parcel | Direct discovery datum; the value *distribution* decides e. |
| e — shiftable share | Fulfillment-network map: where parcels ship from today vs where they could; trade compliance persona for qualification rules (origin restrictions, consignee-per-day rules) | 20–70%; heavily regime- and network-dependent | Bounded by the value distribution below threshold × network feasibility. Directional — genuinely uncertain until the parcel file is analyzed. |
| d — duty/tax avoided | Destination-country rulebooks: which regimes waive duty only vs duty + import tax below threshold; product HS mix | 5–20% combined where both waived; low single digits where only duty | Published thresholds and tax rates per destination; verify at proposal time — this input rots fastest. |
| Δf — clearance-cost delta | Broker/carrier invoices: formal vs low-value clearance fees per parcel (freight-audit territory) | $0.50–$5 per parcel | Carrier brokerage surcharge schedules are published; low-value manifest clearance is materially cheaper than formal entry. Directional. |
| h — durability haircut | Regulatory radar: is the destination threshold politically stable this cycle? | 50–85%; lower wherever legislation is pending | Judgment input by design — it exists to keep the lever honest. Always disclosed, always 🟡. |

---

## 3. What a CFO challenges

1. **"This rule is being abolished — you're selling savings on borrowed time."** The
   defining attack on this lever, and often correct.
   *Response:* agree, and show it's priced in: h discounts the run-rate, the model is
   per-destination on current rules, and the multi-year case carries a stepped-down h.
   Where a destination's change is already enacted, that lane is excluded entirely. Selling
   this lever *without* the haircut is how credibility dies.
2. **"Isn't splitting shipments to duck the threshold illegal?"**
   *Response:* yes — artificial splitting to evade duties is unlawful, and the lever
   explicitly excludes it. The savings come from *structural* routing (fulfillment location,
   importer-of-record model) on parcels that genuinely qualify. Say this unprompted.
3. **"You've already counted these parcels in the FTA or drawback math."**
   *Response:* one duty treatment per dollar. Parcels routed through low-value clearance
   leave the FTA-eligible base (V) and can never generate drawback (no duty paid). Show
   the import-value waterfall from `_index.md`.
4. **"The compliance and returns costs of the new routing eat the savings."**
   *Response:* include the offsets — data-quality work for low-value manifests, possibly
   longer consumer delivery routes, returns-flow changes — as a cost line, not a footnote.
5. **"Average value × average rate is lazy math."** Distribution attack.
   *Response:* correct; the real model runs the parcel file against the threshold
   per-parcel. The average form is for sizing only — flag it 🟡 until the file is run.

---

## 4. Defensibility notes

**Strong when:** high-volume DTC cross-border flows with value distribution genuinely below
destination thresholds; fulfillment network flexible (multiple ship-from options); duty-bearing
categories (apparel, accessories); destination regimes currently stable.

**Weak when:** threshold under active legislative attack for the customer's origins (US
2025-class changes); values cluster above thresholds; single fixed fulfillment location;
B2B flows (regimes are consumer-oriented); or the customer's brand risk appetite excludes
aggressive routing. This is the most volatile lever in the library — when in doubt, present
it as an option study, not a run-rate.

**Do NOT stack with:**
- **Duty drawback** — no duty paid, nothing to recover, on the same parcels.
- **FTA utilization** — remove shifted parcels from the FTA base before computing V × g.
- **Broker consolidation** — Δf here already reprices clearance for these parcels; don't also count them in the broker lever's N.

---

## 5. Confidence guidance (🟡 → 🟢)

Upgrade to 🟢 when you have:
- The actual parcel file (12 months: value, origin, destination, HS) run against current per-destination thresholds — replacing the average-based sizing.
- Per-destination rules verified at proposal date (thresholds, duty vs duty+tax scope, origin exclusions) — dated in the case, because this input expires.
- Carrier/broker quotes for low-value clearance fees on the customer's actual lanes.
- The durability haircut h can never reach 🟢 — it is a disclosed judgment; keep the total driver 🟡 in any multi-year projection regardless of other evidence.
