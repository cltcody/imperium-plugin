# Valuation Lever — Clearance Time → Working Capital

> **Directional benchmarks.** Ranges below are public-knowledge-based and directional. Validate against your own deal history before customer use; tag unvalidated figures 🟡 in any customer-facing output.

Faster, more predictable customs clearance shortens the cash-conversion cycle (goods stop
sitting in bonded limbo) and cuts the demurrage/detention/storage charges that dwell time
generates. Two distinct value streams: a **one-time cash release** (working capital freed)
with a small **annual carrying benefit**, plus a genuinely **annual** avoided-charges stream.

---

## 1. Formula

```
One-time cash release   W = ΔT × (C / 365)
Annual carrying benefit = W × k
Annual charges avoided  = N × q × c × r

Where:
  ΔT = average clearance dwell days removed (pre-filing, fewer holds, faster docs)
  C  = annual imported COGS flowing through affected entries
  k  = cost of capital (WACC) — NOT the full inventory carrying rate; storage and
       obsolescence for in-transit goods are captured in the charges term, and the
       full carrying rate belongs to the inventory-reduction lever
  N  = annual import shipments
  q  = share of shipments incurring demurrage/detention/storage today
  c  = average charge per incident
  r  = achievable reduction in incidents
```

**Worked example (synthetic figures):**

| Term | Value |
|---|---|
| ΔT — dwell days removed | 1.5 |
| C — imported COGS | $150,000,000 |
| k — WACC | 8% |
| N — import shipments | 20,000 |
| q — incident rate | 5% |
| c — avg charge | $450 |
| r — reduction | 40% |

```
Daily imported COGS      = 150,000,000 / 365      = 410,959 (rounded)
Cash release W           = 410,959 × 1.5          = 616,438  (one-time)
Carrying benefit         = 616,438 × 0.08         =  49,315  /yr
Charges baseline         = 20,000 × 0.05 × 450    = 450,000  /yr
Charges avoided          = 450,000 × 0.40         = 180,000  /yr
Annual value             = 49,315 + 180,000       = 229,315  /yr
```

**Annual value: $229,315/yr, plus a $616,438 one-time cash release** (report the one-time
line separately; a CFO values freed cash, but it is not recurring savings).

---

## 2. Inputs table

| Input | Where discovery uncovers it | Typical range | Basis |
|---|---|---|---|
| ΔT — dwell days removable | Logistics director + customs manager: current clearance cycle by port/mode, hold/exam frequency, share of entries pre-filed before arrival. Suites' "Current Process" territory; TMS suite dwell/detention question T.1.34 is the direct opener. | 0.5–3 days where filing is post-arrival and document chase is manual | Mechanism: pre-arrival filing and complete documentation remove queue-and-chase days; ceiling is the customer's measured dwell minus best-lane dwell. Directional. |
| C — imported COGS | Controller/finance persona; also derivable from import value in entry data ("Volumes & Scale" territory) | Deal-specific | Direct discovery datum. |
| k — WACC | CFO/finance | 7–12% for most mid/large enterprises | Standard corporate finance range; ask — finance always has a house number. |
| N, q, c — D&D/storage incidents | Freight-audit territory (TMS suite §1.6 invoice data); T.1.34 asks for dwell/detention frequency and cost directly | q: 3–10% of shipments; c: $150–$1,000+ per incident depending on mode (ocean container demurrage runs high) | Carrier and terminal D&D tariffs are published; incident rates vary widely by port discipline — hence directional. |
| r — reduction achievable | Root-cause split of incidents: documentation-driven (addressable) vs port-congestion-driven (not) | 30–60% of documentation-driven incidents | Only the self-inflicted share is claimable; congestion is not a software outcome. Directional. |

---

## 3. What a CFO challenges

1. **"You've double-counted the carrying cost with the inventory lever."** The classic
   stack error: in-transit stock valued at full carrying rate here *and* safety-stock
   reduction claimed there.
   *Response:* this lever uses WACC only, on in-transit value only; the inventory lever
   owns safety stock at the full carrying rate. Show the boundary line explicitly.
   (Bonus honesty: faster *and more predictable* clearance can also reduce safety stock —
   if you claim that, it goes in the inventory lever with lead-time variance as the input,
   not here.)
2. **"The one-time release is masquerading as annual savings."**
   *Response:* it never enters the run-rate. W is a balance-sheet event; only W × k
   recurs. Present the two lines separately, always.
3. **"Dwell is the port's fault, not our paperwork."** Attribution.
   *Response:* segment current incidents/dwell by root cause from freight-audit data —
   claim only the documentation/filing-driven share (that's why r ≤ 60%).
4. **"Demurrage baseline is cherry-picked from peak season."**
   *Response:* baseline from 12 months of freight-audit invoices, shown by month, not from
   the worst quarter.
5. **"1.5 days — says who?"**
   *Response:* measure current dwell distribution from the customer's own entry/arrival
   timestamps during discovery or PoC; the claim becomes their best lanes' performance
   applied to their worst lanes, which is hard to argue with.

---

## 4. Defensibility notes

**Strong when:** ocean-heavy import flows with high per-day container charges; post-arrival
filing today; measurable dwell from timestamps; freight-audit data exposes D&D lines
cleanly; finance is cash-focused (the one-time release resonates in tight-capital years).

**Weak when:** dwell already minimal (mature pre-filing); charges dominated by congestion
or carrier disputes; air-dominant flows (dwell short, D&D small); imported COGS modest so
W is trivial.

**Do NOT stack with:**
- **Inventory reduction** — carrying-rate boundary above; lead-time-variability safety stock belongs there, valued once.
- **Expedite/OTIF reduction** — clearance-delay-caused expedites: if faster clearance
  removes them, claim those dollars in the expedite lever OR here, never both.
- **Broker consolidation** — "better broker clears faster" must not monetize the same dwell reduction twice.

---

## 5. Confidence guidance (🟡 → 🟢)

Upgrade to 🟢 when you have:
- Dwell measured from the customer's own timestamps (arrival → release) by lane, not an assumed average.
- D&D/storage baseline from 12 months of actual freight-audit or carrier invoices.
- The customer's own WACC from finance.
- Root-cause tagging on a sample of incidents (documentation vs congestion) to substantiate r — a PoC that pre-files a subset of entries and measures the dwell delta is the gold standard.
