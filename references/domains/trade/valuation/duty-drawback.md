# Valuation Lever — Duty Drawback Recovery

> **Directional benchmarks.** Ranges below are public-knowledge-based and directional. Validate against your own deal history before customer use; tag unvalidated figures 🟡 in any customer-facing output.

Recover duties already paid on imported goods that are subsequently exported, destroyed
under supervision, or used in exported manufactured goods. In the US the statutory recovery
is 99% of eligible duties, with a multi-year retroactive lookback; several other regimes
(EU inward processing, similar schemes elsewhere) achieve the same effect prospectively.

---

## 1. Formula

```
Annual recovery  R = D × e × s × f × (1 − c)

Where:
  D = total duties paid per year on imports (customs entry data)
  e = export-matched share — % of duty-paid import value that is later exported,
      destroyed, or embedded in exports (returns, re-exports, manufacturing drawback)
  s = statutory recovery rate (0.99 in the US; regime-specific elsewhere)
  f = claim-completeness factor — % of theoretically eligible duty you can actually
      document and match (import-export traceability quality)
  c = filing cost — specialist/broker contingency fee or internal program cost,
      expressed as a share of recovery

One-time catch-up  R₀ ≈ R × y   (y = clean back-years within the lookback window)
```

**Worked example (synthetic figures):**

| Term | Value |
|---|---|
| D — annual duties paid | $8,000,000 |
| e — export-matched share | 15% |
| s — statutory rate | 99% |
| f — claim completeness | 70% |
| c — filing contingency | 25% |

```
Eligible duty        = 8,000,000 × 0.15            = 1,200,000
Statutory recovery   = 1,200,000 × 0.99            = 1,188,000
Documentable         = 1,188,000 × 0.70            =   831,600
Net annual recovery  =   831,600 × (1 − 0.25)      =   623,700
One-time catch-up    =   623,700 × 3 back-years    = 1,871,100  (report separately — never in run-rate)
```

**Annual value: $623,700** plus a **$1,871,100 one-time** retroactive claim.

---

## 2. Inputs table

| Input | Where discovery uncovers it | Typical range | Basis |
|---|---|---|---|
| D — annual duties paid | Trade compliance manager / customs manager persona; entry summaries or the customs authority's account statements (in the US, ACE reports). Surfaces under the suites' "Volumes & Scale" and "Project Objectives" territory. | 0.5–5% of import value; far higher on goods hit by special/retaliatory tariffs | Published MFN tariff schedules cluster in low single digits; special tariff actions add 7.5–25%+ on affected lines. Directional. |
| e — export-matched share | Logistics director + e-commerce/returns owner: returns volume, re-export lanes, export of manufactured goods containing imported inputs. Logistics suite territory (reverse logistics, network sections). | 5–25% for importers with returns/re-export flows; near 0% for pure domestic distribution | Mechanism-driven: bounded by the customer's actual export and returns flows — discover, don't assume. Directional. |
| f — claim completeness | IT/integration persona: can import entries be matched to export documents at line level? (Suites' "IT & Integration" and "Sample Data Availability" territory.) | 50–85% | Traceability quality governs this; specialist filers routinely lose eligible value to documentation gaps. Directional — genuinely uncertain, varies with data hygiene. |
| c — filing cost | Whoever owns the broker/specialist relationship; ask if a drawback filer is already engaged and on what fee | 10–30% contingency | Drawback specialists publicly advertise contingency pricing in this band. Directional. |
| y — clean back-years | Trade compliance manager: record retention and prior-claim history | 0–5 years (US lookback is 5 years from import) | Statutory lookback is public law; usable years depend on record quality. |

---

## 3. What a CFO challenges

1. **"We already file drawback."** Baseline inflation — if a program exists, the lever is
   only the *incremental* completeness (Δf) and fee improvement, not the full R.
   *Response:* ask for last year's actual recovery; model the lever as
   `R_new − R_current`, and show f moving (e.g. 55% → 80%) rather than claiming from zero.
2. **"You've double-counted this with the trade-agreement savings."** Import value entered
   duty-free under a preference program paid no duty, so it can never yield drawback — and
   some agreements restrict drawback on preferential goods outright.
   *Response:* show that D excludes preferential entries; state explicitly that the FTA
   lever and this lever run on disjoint slices of import value.
3. **"The cash shows up when, exactly?"** Drawback claims can take 1–2 years to liquidate
   unless accelerated-payment privileges are secured.
   *Response:* present the ramp honestly — year-1 cash may be near zero without
   accelerated payment; the one-time catch-up offsets the wait. Never present R₀ as recurring.
4. **"Your completeness factor is a guess."** f = 70% is the softest term.
   *Response:* concede it; run the case at f = 50% (conservative) and show it still clears
   the hurdle: 8,000,000 × 0.15 × 0.99 × 0.50 × 0.75 = $445,500/yr.
5. **"Isn't this a consultant project, not a software outcome?"** Attribution.
   *Response:* the recovery itself needs a filer; the software claim is the *traceability*
   that raises f and sustains it — anchor the value claim to Δf only if that's the honest scope.

---

## 4. Defensibility notes

**Strong when:** the customer both imports duty-bearing goods and exports (manufacturing
with imported inputs, cross-border e-commerce returns, regional distribution hubs); entry
data and export docs are electronically matchable; duties are elevated by special tariff
actions (raises D without changing effort).

**Weak when:** pure domestic sell-through (e ≈ 0); goods enter duty-free (FTA, zero-rated
chapters, low-value clearance); poor record retention kills both f and the catch-up; or an
existing mature drawback program leaves only a thin increment.

**Do NOT stack with:**
- **FTA utilization** on the same import value — duty-free preferential entries yield no drawback (and some agreements bar it).
- **De-minimis optimization** on the same parcels — duty never paid means nothing to recover.
- Count the one-time catch-up **once**, outside the annual run-rate and outside payback-period math unless explicitly modeled as year-1 cash.

---

## 5. Confidence guidance (🟡 → 🟢)

Upgrade a claim to 🟢 when you have:
- Actual duties paid from the customer's own entry data or customs account statements (not an estimate from import value × assumed rate).
- A measured export-matched share from real returns/re-export volumes, not an industry analogy.
- Evidence of match rate: a sample import-to-export trace on real transactions establishing f.
- If a program exists: last 12 months of actual recoveries, making the claim a measured delta.

Until then every term stays 🟡, and the whole driver is tagged 🟡 in `roi-case` output.
