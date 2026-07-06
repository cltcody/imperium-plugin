# Valuation Lever — FTA / Preference-Program Utilization

> **Directional benchmarks.** Ranges below are public-knowledge-based and directional. Validate against your own deal history before customer use; tag unvalidated figures 🟡 in any customer-facing output.

Capture duty savings the customer is already legally entitled to but not claiming: goods
that qualify for a free-trade agreement or preference program but are entered at full MFN
duty because origin qualification, supplier certificates, or claim discipline are missing.

---

## 1. Formula

```
Annual savings  S = V × g × (u_target − u_current) × d − C_program

Where:
  V         = annual import value on lanes covered by at least one agreement/program
  g         = eligible share — % of V that could qualify under origin rules
  u_current = current utilization — % of eligible value actually claimed today
  u_target  = achievable utilization after fixing certification/claim gaps
  d         = weighted average duty rate saved on newly claimed value
              (MFN rate minus preferential rate, usually 0)
  C_program = annual cost of solicitation/qualification effort (internal + tooling)
```

**Worked example (synthetic figures):**

| Term | Value |
|---|---|
| V — covered-lane import value | $200,000,000 |
| g — eligible share | 40% |
| u_current → u_target | 55% → 85% |
| d — avg duty rate saved | 4.5% |
| C_program | $150,000/yr |

```
Eligible value        = 200,000,000 × 0.40                = 80,000,000
Utilization gap       = 0.85 − 0.55                       = 0.30
Newly claimed value   = 80,000,000 × 0.30                 = 24,000,000
Gross duty savings    = 24,000,000 × 0.045                =  1,080,000
Net annual savings    =  1,080,000 − 150,000              =    930,000
```

**Annual value: $930,000**

---

## 2. Inputs table

| Input | Where discovery uncovers it | Typical range | Basis |
|---|---|---|---|
| V — covered-lane import value | Trade compliance manager / customs manager; sourcing map by origin country. Surfaces in the suites' "Volumes & Scale" and network/lanes territory (cf. TMS suite trade-lane question T.1.12). | Deal-specific | Direct discovery datum — no benchmark needed. |
| g — eligible share | Trade compliance + sourcing personas: which origins have agreements, and do products plausibly meet origin rules (tariff-shift / value-content)? | 20–60% of covered-lane value | Bounded by sourcing footprint vs the agreement map; origin rules disqualify pass-through goods. Directional. |
| u_current | Entry data: preference-claim indicator by entry line; broker utilization reports | 40–80% where a program nominally exists; near 0% where none does | Customs authorities and trade bodies have repeatedly reported material under-utilization of preference programs; exact rates vary by agreement and country. Directional. |
| u_target | Judgment anchored to what blocks claims today (supplier certificates? broker instructions?) | 80–95%; never model 100% | Some value always fails qualification or documentation; claiming 100% is a credibility flag. Directional. |
| d — duty rate saved | Weighted from the customer's actual HS mix vs published tariff schedules | 2–8% typical for manufactured goods; 0% on already-duty-free chapters | Published MFN schedules; verify against the customer's top HS chapters rather than assuming an average. |
| C_program | Whoever chases supplier certificates today (often a spreadsheet-and-email process) — "Current Process" territory in the suites | $50k–$300k/yr fully loaded | Mechanism: solicitation effort scales with supplier count. Directional. |

---

## 3. What a CFO challenges

1. **"Our broker already claims everything claimable."** Baseline inflation.
   *Response:* pull u_current from entry data, not assertion — the claim indicator per
   entry line is auditable. If utilization is genuinely ~95%, this lever is small; say so
   and move on. Credibility here protects the rest of the case.
2. **"Eligible isn't qualified."** g conflates "an agreement exists on that lane" with
   "these SKUs meet origin rules with certificates in hand."
   *Response:* show g as a two-step estimate (lane coverage × plausible qualification) and
   run the conservative case at the low end: 200M × 0.20 × 0.30 × 0.045 = $540,000 gross.
3. **"You've counted this import value twice."** Overlap with drawback or de-minimis.
   *Response:* show the import-value waterfall — each dollar of V is assigned to exactly
   one duty-treatment lever (see the double-count matrix in `_index.md`).
4. **"Over-claiming gets us audited."** Risk-shaped pushback: aggressive utilization
   without solid origin records creates penalty exposure.
   *Response:* the lever includes C_program precisely because qualification rigor is the
   product of the work; pair with the penalty-avoidance lever's controls story rather than
   promising savings without substantiation.
5. **"How fast does this ramp?"** Supplier certificate solicitation takes quarters.
   *Response:* model a ramp — e.g. 40% of the gap closed in year 1, full run-rate in
   year 2 — and keep payback math on the ramped curve, not the steady state.

---

## 4. Defensibility notes

**Strong when:** multi-origin sourcing across several agreement-covered lanes; duty-bearing
HS chapters (apparel, footwear, food, some machinery); entry data available to measure
u_current; supplier base concentrated enough that certification effort is tractable.

**Weak when:** single-origin sourcing from a non-agreement country; product mix already
duty-free; no access to entry-line claim data (u_current unmeasurable → whole lever 🟡);
or origin rules the products clearly fail (pure trans-shipment).

**Do NOT stack with:**
- **Duty drawback** on the same value — preferential entries paid no duty to recover.
- **De-minimis optimization** on the same parcels — one duty treatment per dollar.
- Careful with **penalty avoidance**: claiming FTA savings *and* penalty reduction from
  the same "better origin documentation" is one improvement counted twice — attribute the
  documentation benefit to one lever and reference it qualitatively in the other.

---

## 5. Confidence guidance (🟡 → 🟢)

Upgrade to 🟢 when you have:
- u_current measured from the customer's own entry-line data (or broker utilization report), not estimated.
- d computed from the customer's actual top HS codes against published tariff schedules.
- g grounded in a sourcing-by-origin breakdown plus at least a spot check of origin-rule fit on top SKUs.
- Ideally: one quantified pilot lane — measured utilization lift on a single agreement — before extrapolating to all lanes.
