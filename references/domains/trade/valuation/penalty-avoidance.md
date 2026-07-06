# Valuation Lever — Penalty & Compliance-Risk Avoidance

> **Directional benchmarks.** Ranges below are public-knowledge-based and directional. Validate against your own deal history before customer use; tag unvalidated figures 🟡 in any customer-facing output.

Reduce the recurring cost of compliance failures — penalties, liquidated damages,
post-entry corrections, interest, and the internal firefighting they generate — plus the
expected value of low-probability/high-severity enforcement events. This lever is part
hard (historical run-rate reduction), part soft (tail-risk insurance); present the two
components separately and never let the soft part inflate the hard total.

---

## 1. Formula

```
Annual value  A = (B × r) + (p × L × r_tail)
                  └─hard─┘   └────soft────┘

Where:
  B      = compliance-failure baseline: trailing 3-year average of penalties, fines,
           liquidated damages, plus the admin cost of post-entry corrections and
           interest on underpaid duties
  r      = achievable reduction of the recurring baseline through automated
           classification/screening/filing controls
  p      = annual probability of a major enforcement event (audit finding, seizure,
           denied-party violation) under current controls
  L      = loss severity of that event (penalty + remediation + disruption)
  r_tail = reduction in that probability from systematic controls
```

**Worked example (synthetic figures):**

| Term | Value |
|---|---|
| B — recurring baseline | $180,000/yr penalties + $120,000/yr correction admin & interest = $300,000 |
| r — recurring reduction | 60% |
| p — major-event probability | 2%/yr |
| L — severity | $2,500,000 |
| r_tail | 50% |

```
Hard component  = 300,000 × 0.60              = 180,000
Soft component  = 0.02 × 2,500,000 × 0.50     =  25,000
Annual value A  = 180,000 + 25,000            = 205,000
```

**Annual value: $180,000 hard + $25,000 soft (expected value).** Lead with the hard number;
present the soft component as risk posture, not savings.

---

## 2. Inputs table

| Input | Where discovery uncovers it | Typical range | Basis |
|---|---|---|---|
| Penalty/fine history | Trade compliance manager and controller: 3 years of penalty notices, liquidated-damage claims, settlement payments. Surfaces under the suites' "Risks" and "Project Objectives" territory — a recent penalty is often the compelling event itself. | Deal-specific; lumpy | Direct discovery datum; use a 3-year average because single years mislead. |
| Post-entry correction volume & cost | Compliance team: corrections filed per year × handling effort; broker amendment fees on invoices | 0.5–3% of entries need correction; 1–4 hrs handling each | Mechanism: manual classification/valuation is error-prone at scale. Directional — genuinely uncertain, measure it. |
| r — achievable reduction | Anchored to root causes found in "Current Process" discovery: which failure modes are automatable (classification, screening, document completeness) vs not (supplier misdeclaration) | 40–80% of automatable failure modes | Bounded by the automatable share; never claim reduction of failure modes the product doesn't touch. Directional. |
| p — major-event probability | Compliance persona: audit history, prior disclosures, denied-party screening coverage gaps | 1–5%/yr for importers with manual screening; 🟡 always | Genuinely uncertain — no defensible point estimate exists; present as a stated assumption with sensitivity. |
| L — severity | Public enforcement mechanics: statutory penalty frameworks scale with duty loss and culpability (negligence vs gross negligence multiples); sanctions violations carry per-transaction penalties | Mid-six to mid-seven figures for a serious matter | Statutory multiplier structures are public law; the specific number for this customer is 🟡 until sized against their own duty exposure. |
| Loaded labor cost (correction admin) | Controller/HR standard figure | $60–$120/hr loaded | Standard loaded-cost range for compliance/ops roles in developed markets. Directional. |

---

## 3. What a CFO challenges

1. **"We've never been fined — you're monetizing a ghost."** No baseline.
   *Response:* if B ≈ 0, don't force it. Shift the hard component to measured correction
   admin cost (real hours, real invoices) and present the tail purely as risk posture with
   the CFO's own p estimate plugged in. An honest small number beats a contested big one.
2. **"Your baseline is one bad year."** A single penalty spike annualized.
   *Response:* always use the trailing 3-year average and show the year-by-year series.
   If the spike was a one-off with a fixed root cause, exclude it and say why.
3. **"Expected-value math is insurance salesmanship."** The p × L component.
   *Response:* agree — that's why it's segregated as soft and excluded from payback math.
   Offer the sensitivity framing: "at what p and L would you self-insure?" and let finance
   pick the inputs.
4. **"You're claiming this and the broker savings from the same cleanup."** Double-count.
   *Response:* fee reductions live in broker-consolidation; error-cost reductions live
   here. Show the split explicitly.
5. **"How much of the reduction is really attributable to the product?"** Some failures
   (supplier misdeclaration, forced-labor exposure in tier-2) aren't fixed by software.
   *Response:* the failure-mode table from discovery tags each mode automatable or not;
   r applies only to the automatable share.

---

## 4. Defensibility notes

**Strong when:** there is a documented penalty/correction history (compelling event);
entry volumes are high and classification is manual; screening coverage has known gaps;
a recent audit or prior disclosure has finance already sensitized.

**Weak when:** clean history and low volumes (tail-only case — soft); failures are
predominantly upstream (supplier data) where software attribution is thin; or the customer
treats occasional penalties as an acceptable cost of doing business (no compelling event).

**Do NOT stack with:**
- **Broker consolidation** — fees there, error costs here (one broker improvement, two levers, pick lanes).
- **FTA utilization** — "better origin documentation" can't be monetized as both duty savings and penalty reduction; put the money in FTA and reference the risk benefit qualitatively here.
- Never add the soft (p × L) component into the hard-savings total or payback calculation.

---

## 5. Confidence guidance (🟡 → 🟢)

Upgrade to 🟢 when you have:
- The customer's actual 3-year penalty/correction ledger (from the controller, not memory).
- Measured correction volume and handling time from their own case data or ticket system.
- A failure-mode root-cause breakdown agreed with the compliance team, so r applies to a defined automatable share.
- The tail component (p, L) never reaches 🟢 on probability — it can reach 🟢 only on severity, sized against the customer's own duty exposure and statutory multipliers. Keep the EV line 🟡 permanently and label it soft.
