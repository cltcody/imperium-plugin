# Valuation Lever — Inventory Reduction from Forecast Accuracy (Planning)

> **Directional benchmarks.** Ranges below are public-knowledge-based and directional. Validate against your own deal history before customer use; tag unvalidated figures 🟡 in any customer-facing output.

Better forecast accuracy lowers the demand-uncertainty component of safety stock, releasing
working capital (one-time) and reducing annual carrying cost (recurring). The math is
standard inventory theory: safety stock scales with forecast error, so a relative error
reduction translates roughly one-for-one into a reduction of the error-driven stock — *if*
planners actually re-parameterize the system.

---

## 1. Formula

```
Safety stock (demand-driven)   SS = z × σ_D × √L
  ⇒ SS scales linearly with σ_D, and σ_D is proportional to forecast error (RMSE)

Cash release   ΔW = SS_value × w × (1 − σ_new/σ_old)
Annual value   V  = ΔW × cc

Where:
  SS_value        = current safety-stock value at cost
  w               = share of safety stock driven by demand variability
                    (vs supply variability, MOQs, batch sizes — not touched by forecasting)
  σ_new/σ_old     = ratio of forecast error after vs before (RMSE or WMAPE proxy)
  z, L            = service factor and lead time — unchanged, so they cancel in the ratio
  cc              = annual inventory carrying-cost rate
                    (capital + storage + insurance + shrink + obsolescence)
```

**Worked example (synthetic figures):**

| Term | Value |
|---|---|
| SS_value | $30,000,000 (within $100M total inventory) |
| w — demand-driven share | 70% |
| Forecast error improvement | WMAPE 35% → 28%, i.e. σ_new/σ_old = 0.8 |
| cc — carrying-cost rate | 20% |

```
Error-driven stock   = 30,000,000 × 0.70          = 21,000,000
Reduction            = 21,000,000 × (1 − 0.8)     =  4,200,000  (one-time cash release)
Annual value V       =  4,200,000 × 0.20          =    840,000  /yr
```

**Annual value: $840,000/yr, plus a $4,200,000 one-time cash release** — separate lines,
always.

---

## 2. Inputs table

| Input | Where discovery uncovers it | Typical range | Basis |
|---|---|---|---|
| SS_value | Demand/supply planning manager + controller: safety stock at cost from the planning system, or estimated as total inventory minus cycle/pipeline stock. Planning suite territory §01 (planning environment) and §05 (volumes & scale). | 15–40% of total inventory value for make-to-stock businesses | Mechanism: depends on service targets and variability; derive from their system, not the range. Directional. |
| w — demand-driven share | Planning manager: what drives current SS parameters — demand CV vs supplier lead-time variance vs lot sizes ("Current Process" territory §03) | 50–80% where demand volatility dominates; much lower for MOQ-constrained buys | Inventory-theory decomposition; genuinely uncertain until parameters are inspected — directional. |
| Current forecast error | Planning manager: WMAPE/bias by horizon and level (§03); if unmeasured, that fact is itself the pain | WMAPE 20–50% at SKU-location, monthly, one period ahead | Widely observed planning practice; varies hugely by industry and granularity — always restate at *their* measurement level. Directional. |
| Achievable error reduction | Anchored to method gap found in discovery (naive/statistical baseline vs ML with drivers; promo/NPI handling) | 10–30% relative reduction | Directional: gains shrink as the baseline improves; never promise past what a backtest on their history shows. |
| cc — carrying rate | CFO/controller — house number; components: capital (WACC), storage, insurance, shrink, obsolescence | 15–25%/yr | Standard textbook/practitioner band; composition matters (see CFO challenge 2). |

---

## 3. What a CFO challenges

1. **"Forecast accuracy doesn't move inventory by itself."** The attribution gap — the
   single most common failure of planning ROI cases. Stock falls only when planners reset
   safety-stock parameters and buyers follow them.
   *Response:* concede the mechanism and build it in: value ramps over 2–4 quarters as
   parameters are re-tuned, and the case includes the process change (who resets, how
   often), not just the algorithm.
2. **"Your 20% carrying cost is double what our finance uses."** Carrying-rate inflation.
   *Response:* decompose it. If finance recognizes only capital cost (~8%), run the case
   at their rate — 4,200,000 × 0.08 = $336,000/yr — and argue storage/obsolescence as
   separately evidenced lines only if their P&L shows them.
3. **"Cutting stock will crater service levels."** The tradeoff attack.
   *Response:* the reduction holds service constant by construction (z unchanged; only
   σ falls). Offer the alternative framing — keep the stock, raise service — and let them
   choose which to monetize (never both).
4. **"You've counted this cash twice with the clearance lever."** Overlap on
   variability-driven stock.
   *Response:* boundary rule — lead-time/transit variability stock belongs to the
   clearance/logistics levers; demand-variability stock (w) belongs here. Show the
   decomposition so the same pallet isn't released twice.
5. **"The error improvement is a vendor benchmark, not ours."**
   *Response:* correct — that's why the 10–30% range stays 🟡 until a backtest on the
   customer's own demand history produces a measured delta at their granularity.

---

## 4. Defensibility notes

**Strong when:** make-to-stock with measurable WMAPE and a real safety-stock line in the
planning system; demand-driven variability dominates (w high); finance already tracks
carrying cost; a backtest on customer history is feasible pre-commit (strongest possible
evidence in the whole library).

**Weak when:** inventory is MOQ/batch-driven (w low — better forecasts won't shrink it);
no baseline error measurement exists (fix measurement first, monetize later); make-to-order
businesses; or planners lack authority to change parameters (value stalls at the process
gap).

**Do NOT stack with:**
- **Clearance working capital** — transit/lead-time variability stock is theirs; demand variability is yours; decompose w explicitly.
- **Expedite/OTIF reduction** — the same forecast improvement drives both fewer expedites and less stock; both may be claimed but each dollar's root cause is allocated once (expedites avoided are a flow saving; stock released is a stock saving — legitimate together, but never fund both from the identical variability reduction without showing the split).
- Never claim service-level improvement *and* the full stock reduction — pick the frame.

---

## 5. Confidence guidance (🟡 → 🟢)

Upgrade to 🟢 when you have:
- Current WMAPE/bias measured from the customer's own planning data at a stated granularity and lag.
- A backtest on ≥12 months of their demand history showing the achieved error reduction — this converts the softest input into the hardest and is worth insisting on.
- SS_value and its parameter drivers (z, σ, L) pulled from their planning system, decomposing w.
- The carrying rate agreed with their finance team in writing (component by component).
