---
name: account-intelligence
description: |
  Full account intelligence pipeline — runs supply-chain mapping and ${user_config.company}
  solution-fit qualification in sequence for any named company, producing the visual map AND the
  fit assessment in one workflow. Use on "full account analysis for [company]", "map and qualify
  [company]", or "prep me for a call with [company]".
---

# Account Intelligence Pipeline

This skill sequences supply-chain research with solution-fit qualification to take a
prospect from zero to a fully qualified ${user_config.company} opportunity in a single workflow:

**Phase 1 → supply-chain-map:** Build a visual, tabbed supply chain map for the
target company, covering tiers, manufacturing, distribution, logistics, and tech
stack — with confidence tagging throughout.

**Phase 2 → solution-fit qualification (inline, below):** Feed the Handoff Package from
Phase 1 into the qualification workflow in this skill to assess ${user_config.company} solution fit,
surface buyer personas, and identify the right ${user_config.company} products to pursue.

---

## How to run this workflow

### Step 1 — Capture the target account

Ask the user for:
- **Company name** (required)
- **Any known context** — internal data, recent conversations, known platforms,
  stated pain points (optional but valuable — it will flow into Phase 2)

If the user provided the company name in their original message, proceed directly
without asking again.

### Step 2 — Run Phase 1: Supply Chain Map

Follow the full `supply-chain-map` skill (read its SKILL.md at
`${CLAUDE_PLUGIN_ROOT}/skills/supply-chain-map/SKILL.md`). Complete all steps including:
- Research (Steps 1–2)
- Interactive visual widget (Step 3)
- Output: research summary, widget, gap summary, top use cases, follow-up offer
- **Handoff Package** (Step 7) — this is the bridge to Phase 2

If the user supplied internal context earlier in the conversation, treat it as
🟢 Confirmed and attribute it as "Source: internal" in the map.

### Step 3 — Transition

After emitting the supply chain map and Handoff Package, add a brief transition line
before moving into Phase 2:

> "Supply chain map complete. Running solution-fit qualification now using the signals above..."

### Step 4 — Run Phase 2: solution-fit qualification

Using the Handoff Package as pre-populated input (do not re-ask for company name,
industry, size, or geography — all of it flows from Phase 1), qualify the account against
${user_config.company}'s portfolio. Apply the ${user_config.qualification_framework} lens where deal context exists.

Work through the four fit dimensions, scoring each 🟢 Strong / 🟡 Partial / 🔴 Weak with a
one-line rationale tied to evidence from Phase 1:

1. **Product fit** — which ${user_config.company} products (${user_config.product_a}, ${user_config.product_b}, ${user_config.product_c},
   ${user_config.product_d}, or the full ${user_config.suite_1}) map to the prospect's surfaced pains and
   tech-stack gaps? Note displacement signals (incumbent tools) and expansion signals.
2. **Industry fit** — does the prospect's sector match ${user_config.company}'s strongest reference base?
3. **Geo fit** — are the prospect's regions ones ${user_config.company} serves well?
4. **Company-size fit** — is the prospect in ${user_config.company}'s target band for deal size and
   complexity?

Then produce:
- **Recommended products table** — each product with a fit rating (Strong Fit / Some
  Potential / Avoid) and the evidence behind it.
- **Key personas to target** — the buyer/champion roles implied by the supply-chain shape.
- **Trigger events** — compelling events present in the research (M&A, regulation, growth,
  disruption) that create urgency.
- **Ideal Solution Candidate (ISC) flag** — yes/no with a one-line rationale.
- **Customer reference suggestions** — if comparable ${user_config.company} references are known.

Where Phase 1 left tech stack 🔴 Unknown, surface those as discovery questions rather than
guessing — that tells the seller exactly what to ask next.

### Step 5 — Combined summary

Close with a brief (3–5 bullet) synthesis — the single most important thing to know about
the supply chain situation AND the single most important ${user_config.company} opportunity it implies.
This is the "executive takeaway" a seller can use in 30 seconds before a call.

### Step 6 — Save outputs

The supply-chain-map skill saves the map HTML automatically. After the full pipeline
completes, also save a qualification summary to the outputs folder:

```
<outputs-dir>/<CompanyName>_solution_fit.md
```

The file should contain: the account header block (name, industry, size, geo), the
recommended products table with fit ratings, key personas, trigger events, ISC flag, and
the executive summary bullets from Step 5. Provide links to both saved files at the end of
the response so the user can open them directly.

---

## Skipping to Phase 2

If the user already has a supply chain map (from this session or a previous one) and just
wants the qualification, skip Phase 1 entirely. Ask them to paste or confirm the Handoff
Package, then run Phase 2 (Step 4) directly.

---

## Notes on data quality

The quality of the Phase 2 qualification is directly proportional to the richness of
Phase 1. If the supply chain map surfaces a confirmed tech stack, the fit assessment will
be much sharper. If most of the tech stack is 🔴 Unknown, the output flags those as data
gaps to resolve in discovery — which is still useful.

Never fabricate data to fill gaps in either phase. Flag unknowns explicitly and surface
them as discovery questions.
