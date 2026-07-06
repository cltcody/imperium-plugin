# Valuation Lever — Expedited-Freight & OTIF-Penalty Reduction

> **Directional benchmarks.** Ranges below are public-knowledge-based and directional. Validate against your own deal history before customer use; tag unvalidated figures 🟡 in any customer-facing output.

Two related flow savings from better planning and execution visibility: (a) cutting the
**premium** paid for expedited freight that exists only to rescue late or mis-planned
orders, and (b) reducing **OTIF (on-time-in-full) chargebacks** levied by large retail
customers on non-compliant purchase orders. Both are P&L-visible, which makes them
CFO-friendly — and baseline-sensitive, which makes them attack-prone.

---

## 1. Formula

```
Annual savings  S = (X × a × r_x)  +  (R × n × f × r_o)
                    └── expedite ──┘   └──── OTIF ────┘

Where:
  X   = annual expedited-freight PREMIUM — the cost delta over the standard mode,
        not the gross spend on expedited moves
  a   = addressable share — % of expedite events caused by planning/visibility
        failures (vs customer-demanded rush, disaster recovery)
  r_x = achievable reduction of addressable expedites
  R   = annual revenue through OTIF-enforcing retail customers
  n   = non-compliance rate — % of PO value currently failing OTIF terms
  f   = fine rate applied to non-compliant PO value
  r_o = achievable reduction in non-compliance
```

**Worked example (synthetic figures):**

| Term | Value |
|---|---|
| X — expedite premium | $2,400,000/yr |
| a — addressable share | 35% |
| r_x — reduction | 60% |
| R — OTIF-covered revenue | $250,000,000 |
| n — non-compliance | 12% of PO value |
| f — fine rate | 3% |
| r_o — reduction | 40% |

```
Expedite savings = 2,400,000 × 0.35 × 0.60             = 504,000
OTIF baseline    = 250,000,000 × 0.12 × 0.03           = 900,000
OTIF savings     = 900,000 × 0.40                      = 360,000
Annual value  S  = 504,000 + 360,000                   = 864,000
```

**Annual value: $864,000**

---

## 2. Inputs table

| Input | Where discovery uncovers it | Typical range | Basis |
|---|---|---|---|
| X — expedite premium | Freight-audit data (TMS suite §1.6) split by service level; T.1.13 asks directly what triggers air/expedited shipments; logistics director persona | Expedited moves commonly cost 2–5× the standard mode on the same lane; premium = delta only | Published mode economics (air vs ocean, team/expedited ground vs standard) support the multiple; the customer's own split is the real number. Directional. |
| a — addressable share | Root-cause sample of expedite events: planning miss / visibility gap / customer rush / force majeure ("Current Process" + risks territory) | 25–50% | Mechanism: only self-inflicted expedites are claimable; customer-demanded rushes may even be billable revenue. Directional — measure on a 3-month sample. |
| r_x | Anchored to what the solution actually changes (earlier visibility of shortfall, better forecast, alerting) | 40–70% of addressable events | Directional; bounded by lead-time physics — an expedite avoided needs the problem visible before the standard-mode cutoff. |
| R, n — OTIF exposure | Sales/customer-ops persona: which retail customers enforce OTIF, their scorecards; deduction lines in AR ("Project Objectives" territory — chargebacks are usually a named pain) | n: 5–20% of PO value fails for suppliers in trouble; scorecards give the real number | Retailer scorecards are contractual and specific — always obtainable in discovery. Range directional. |
| f — fine rate | The retailer's published compliance program terms | ~3% of the value of non-compliant cases/POs is the widely known anchor among major North American mass retailers; programs vary | Public knowledge of large-retailer OTIF programs; treat as directional and read the actual vendor agreement. |
| r_o | Root-cause split of failures: fill (inventory) vs on-time (transport/booking) vs data (ASN/labeling) | 30–60% | Only the failure modes the solution touches count; data/labeling failures need different fixes than fill failures. Directional. |

---

## 3. What a CFO challenges

1. **"Your expedite baseline is gross spend, not premium."** The classic inflation on this
   lever — counting the whole air-freight bill instead of the delta over ocean/ground.
   *Response:* compute X as (expedited cost − standard-mode cost) per rescued shipment
   from freight-audit data. Volunteering this correction before they find it buys
   credibility for the whole case.
2. **"Most expedites are the customer's rush orders — you can't save those."**
   Attribution on a.
   *Response:* agree; that's what a = 35% encodes. Show the root-cause sample (even 50
   classified events from 3 months of data) rather than asserting the share.
3. **"OTIF fines get negotiated away — we don't actually pay 3%."**
   *Response:* baseline from actual deductions taken in AR over 12 months, net of
   successful disputes — not from the fine schedule. If real net deductions are small,
   shrink the claim and keep the relationship/shelf-space risk as a soft note.
4. **"This is the same forecast improvement you already monetized in inventory."**
   Double-count with the inventory lever.
   *Response:* legitimate to claim both — one is a flow saving, one a stock release — but
   show the allocation: which failure modes drive expedites (execution/visibility) vs
   which drive safety stock (demand error), so no single root cause is priced twice.
5. **"Ramp?"** OTIF scorecards move slowly, and retailers measure in windows.
   *Response:* model 2–3 quarters to reach r_o run-rate, and note fill-driven failures
   can't improve faster than the inventory/planning changes behind them.

---

## 4. Defensibility notes

**Strong when:** freight-audit data can isolate expedite premiums by cause; the customer
sells through OTIF-enforcing mass retailers and the deductions ledger is real and visible
in AR; expedites cluster on identifiable lanes/SKUs (fixable pattern, not noise).

**Weak when:** expedites are rare or genuinely customer-billable; no freight-audit
granularity (premium unmeasurable); OTIF fines are routinely waived; DTC-dominant revenue
(no retailer compliance programs); or the root causes are structural capacity shortfalls
no software will fix.

**Do NOT stack with:**
- **Inventory reduction** — shared root cause (forecast error); claim both only with an explicit failure-mode allocation (see challenge 4).
- **Clearance working capital** — clearance-delay-caused expedites: those dollars go in exactly one lever.
- **Penalty avoidance** — OTIF chargebacks are commercial deductions, not regulatory penalties; keep them here, never in both.

---

## 5. Confidence guidance (🟡 → 🟢)

Upgrade to 🟢 when you have:
- X computed from 12 months of the customer's freight-audit data with a per-event premium calculation.
- A root-cause classification of a real expedite sample (≥50 events) establishing a.
- OTIF baseline from actual AR deductions and the retailer's own scorecard — both are contractual documents the customer possesses.
- r_x / r_o anchored to a pilot period (e.g. one quarter on priority lanes) with measured before/after, rather than the directional ranges above.
