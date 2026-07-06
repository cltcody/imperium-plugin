# Valuation Lever — Broker-Fee Consolidation

> **Directional benchmarks.** Ranges below are public-knowledge-based and directional. Validate against your own deal history before customer use; tag unvalidated figures 🟡 in any customer-facing output.

Reduce customs brokerage spend by consolidating a fragmented broker base onto fewer
providers with negotiated, transparent fee schedules — and by eliminating ancillary charges
(disbursement fees, per-line charges, amendment fees) that fragmentation hides.

---

## 1. Formula

```
Annual savings  S = N × (p_current − p_target) + A

Where:
  N         = annual customs entries (declarations) across all brokers
  p_current = current blended all-in cost per entry
              (base fee + line charges + amendments + admin surcharges)
  p_target  = negotiated consolidated all-in cost per entry
  A         = ancillary savings, chiefly disbursement fees avoided by paying duties
              direct to the authority instead of through the broker:
              A = D_via_broker × r_disb
```

**Worked example (synthetic figures):**

| Term | Value |
|---|---|
| N — annual entries | 30,000 |
| p_current — blended all-in per entry (12 brokers) | $85 |
| p_target — consolidated per entry | $62 |
| Duties disbursed via brokers | 40% of $6,000,000 |
| r_disb — disbursement fee | 2.5% |

```
Per-entry savings   = (85 − 62) × 30,000          = 23 × 30,000  = 690,000
Disbursement saved  = 6,000,000 × 0.40 × 0.025    =                 60,000
Annual savings  S   = 690,000 + 60,000            =                750,000
```

**Annual value: $750,000**

---

## 2. Inputs table

| Input | Where discovery uncovers it | Typical range | Basis |
|---|---|---|---|
| Broker/3PL count | Directly asked in the TMS suite carrier-base section (T.1.15 "How many brokers or 3PLs do you use?"); logistics director persona | 3–15+ for mid-size importers; fragmentation grows with acquisitions and lanes | Mechanism: each port/mode/legacy entity tends to accrete its own broker. Directional. |
| N — annual entries | Trade compliance manager; entry summaries or broker invoices ("Volumes & Scale" territory) | Deal-specific | Direct discovery datum. |
| p_current — blended all-in per entry | Accounts payable / controller persona: a 3-month broker invoice sample, *including* ancillary lines (cf. freight-audit territory, TMS suite §1.6) | $35–$150 per entry all-in; fragmented bases sit toward the top | Brokerage base fees are widely quoted in the tens of dollars; ancillary lines commonly add 30–60% on top. Directional. |
| p_target | Benchmark from a consolidated RFP; procurement persona | 15–35% below blended current | Volume leverage plus ancillary-fee elimination; savings above ~40% should trigger a scope check (service level being cut?). Directional. |
| D_via_broker, r_disb | Broker invoices: disbursement/advancement fee lines; treasury persona for direct-pay feasibility | Disbursement fees ~2–3% of duty outlay where charged | Brokers publicly price duty advancement in this band; direct-pay programs remove it. Directional. |

---

## 3. What a CFO challenges

1. **"This is a procurement negotiation, not a software benefit."** Attribution — the
   sharpest attack on this lever.
   *Response:* concede the split honestly. The negotiation captures the rate; the software
   claim is (a) the entry-level visibility that makes p_current measurable at all across
   12 invoice formats, and (b) *keeping* the savings — fee-schedule compliance auditing so
   ancillary charges don't creep back. Claim the sustain, share the capture.
2. **"Your blended current cost is inflated."** Baseline built from the worst invoices.
   *Response:* build p_current from a full 3-month invoice sample across all brokers, show
   the distribution, and use the median-weighted blend — not the scariest example.
3. **"Fewer brokers = concentration risk and worse service on specialty lanes."**
   *Response:* model consolidation to 2–3 brokers, not 1, and exclude genuinely specialist
   entries (e.g. complex admissibility regimes) from N. Shrinking N by 10–15% for carve-outs
   keeps the number honest: (85 − 62) × 25,500 = $586,500 still clears most hurdles.
4. **"Switching costs and disruption?"** One-time costs omitted.
   *Response:* include a one-time transition line (SOPs, power-of-attorney re-papering,
   parallel running — typically a low-six-figure one-off) and show payback including it.
5. **"Aren't you also claiming broker-error penalty savings elsewhere?"** Double-count
   with penalty avoidance.
   *Response:* this lever claims *fees only*. Error-driven costs (post-entry corrections,
   penalties) belong exclusively to the penalty-avoidance lever.

---

## 4. Defensibility notes

**Strong when:** broker count is high relative to volume; invoices show heavy ancillary
lines; no one currently owns brokerage spend as a category (classic post-M&A shape);
invoice data is retrievable for a real baseline.

**Weak when:** already consolidated (1–2 brokers on negotiated schedules); volumes too low
for leverage; brokerage bundled into a 3PL/forwarder contract where fees can't be isolated
(baseline unmeasurable → keep the lever out or fully 🟡); heavy specialty cargo needing
niche brokers.

**Do NOT stack with:**
- **Penalty avoidance** via "better brokers make fewer errors" — error costs live there, fees live here.
- **Clearance working capital** via "consolidated brokers clear faster" — dwell-time value lives there; don't monetize the same broker improvement twice.

---

## 5. Confidence guidance (🟡 → 🟢)

Upgrade to 🟢 when you have:
- p_current computed from an actual multi-month, all-brokers invoice sample (not one broker's rate card).
- N from entry summaries or customs-authority data, not an estimate.
- p_target from a real consolidated quote or completed RFP round — until a broker has priced it, the target rate stays 🟡.
- Disbursement savings confirmed by treasury that direct-pay (e.g. ACH to the customs authority) is operationally acceptable.
