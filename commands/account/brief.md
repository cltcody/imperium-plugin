---
description: One-page company brief for a target account — firmographics, trade footprint, signals
argument-hint: [account name or domain]
---

Build a one-page company brief for **$ARGUMENTS** to prepare for first engagement.

## What to produce

1. **Company overview** — industry, headquarters, revenue, employee count, key geographies. Source from ZoomInfo, public filings, press.
2. **Trade and supply chain footprint** — import/export countries, product categories, regulatory exposure (customs classifications, trade agreements, restricted party risk). Source from public filings, news, sustainability reports.
3. **Technology signals** — known ERP, TMS, customs/trade systems (job posts, press releases, LinkedIn).
4. **Business signals** — recent news, M&A, regulatory events, leadership changes. Anything that could be a compelling event.
5. **Hypotheses** — based on the above, what are the 2-3 most likely pains this company has in global trade compliance?

## Optional — Regulatory exposure summary

If the account is a plausible trade/customs/supply-chain fit, add a short paragraph teasing
its regulatory exposure — 1-2 sentences on the most likely exposure vector (tariff/lane
concentration, sanctions/denied-party proximity, CBAM/carbon, forced-labor supply-chain risk,
or de-minimis/e-comm changes) based on what's already surfaced in the footprint and business
signals above, confidence-tagged like everything else in this brief. This is a teaser, not the
analysis — for the full five-vector exposure brief, run `/cc:account:exposure` on this account
rather than duplicating its scoring method here.

## Confidence tagging

Apply the confidence-tagging standard to every claim:
- 🟢 Confirmed — cited from annual report, filing, press release, or CRM
- 🟡 Inferred — reasoned from company profile, industry norms, indirect signals
- 🔴 Unknown — data gap; list explicitly

## Format

Output as a clean one-page brief, printable. End with:
- **Gap list**: 3-5 things we don't know that would materially change the hypotheses
- **Recommended first question**: the single best opening question for this account based on the brief
