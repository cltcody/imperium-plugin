---
description: Build the tariff/regulatory exposure brief for a target account — five-vector scoring against the exposure-analysis framework
argument-hint: [company name] [--vectors <filter>]
---

Build the trade & regulatory exposure brief for: **$ARGUMENTS**

`--vectors <filter>` (optional): restrict the run to a comma-separated subset of vectors
(e.g. `--vectors tariff,cbam`) — useful for a fast re-check after new evidence turns up.
Default: all five vectors.

This command executes the method in
`${CLAUDE_PLUGIN_ROOT}/references/domains/trade/exposure-analysis.md` — read it before
running; do not restate its content here, follow it.

**Where this writes:** the exposure brief resolves against the deals workspace per the
Command Integration Contract in
`${CLAUDE_PLUGIN_ROOT}/references/presales/deals-workspace.md` (config → env → default
`~/code/deals-workspace`; offers to create if absent; never falls back to cwd or this
repo). This is the worst-case leak artifact named in the safeguard matrix — a customer name
plus a quantified risk posture — so in a `corporate`-classed repo
(`${CLAUDE_PLUGIN_ROOT}/references/dev/repo-classification.md`) print the one-line
redirect notice before writing; the destination is the workspace either way.

If the company name is ambiguous (multiple plausible entities, a common word, a subsidiary
of an unclear parent), ask which one before researching — a wrong-company brief is worse
than a slow start.

## Steps

1. **Disambiguate the account.** Confirm the exact legal entity (parent vs. subsidiary,
   ticker if public). If it can't be resolved from $ARGUMENTS and context, ask — do not guess.

2. **Declare the data mode, up front.** Check whether a trade-data source (bill-of-lading /
   customs-records MCP or export) is connected this session, and apply the framework's
   data-source stance (`${CLAUDE_PLUGIN_ROOT}/references/domains/trade/exposure-analysis.md`
   — connected = primary quantitative source tagged 🟢 with dataset + date; not connected =
   its ranked public-source fallback, quantitative inferences 🟡 at best). State the mode in
   the output header exactly once. Do not silently mix modes.

3. **Research each in-scope vector using its ranked evidence sources.** In order, for each of
   the framework's five vectors (Tariff actions by lane/HS chapter; Sanctions & denied-party
   proximity; Carbon border measures; Forced-labor supply-chain risk; De-minimis/e-commerce
   changes) — or the subset named by `--vectors`:
   - Pull evidence from the vector's ranked sources (highest reliability first) via
     WebSearch/WebFetch and any connected trade-data tool.
   - Tag every claim 🟢 Confirmed / 🟡 Inferred / 🔴 Unknown with an inline source, per
     `${CLAUDE_PLUGIN_ROOT}/skills/confidence-tagger/references/confidence-tagging.md`.
     A number with no source and no tag does not go in the brief.
   - Note the vector's "hardening questions" that remain open after research.

4. **Score each vector against the framework's anchors — or record insufficient data.**
   Assign 1 / 3 / 5 only when the evidence matches an anchored description; 2 or 4 only when
   it genuinely sits between two anchors, justified against both. Cite which anchor clause
   the evidence matches, so the score is falsifiable. **No evidence reaching an anchor →
   "insufficient data"** — a valid, honorable result, never a guessed number. State what
   evidence would be needed to score it instead.

5. **Assemble the brief in the framework's required shape** (header, exposure summary
   table, per-vector analysis, "What we could NOT establish", so-what, gap list — see
   Output below).

6. **Write the file** to `<deals-workspace>/accounts/exposure-<company-slug>.md`
   (kebab-case the company name, e.g. `exposure-halcyon-devices.md`), resolved per the
   Command Integration Contract above. Create the `accounts/` directory if it doesn't exist.

## Output

Write `<deals-workspace>/accounts/exposure-<company-slug>.md` with this shape (per the
framework's "Required brief shape"):

1. **Header** — account (exact entity), date, data mode (trade-data connected / public
   fallback), sources consulted.
2. **Exposure summary table** — all five vectors (or the `--vectors` subset, noting the
   others as not run this pass), each with score-or-*insufficient data* and a one-line why.
3. **Per-vector analysis** — for each vector: evidence chain (tagged claims with inline
   sources), score justification against the anchors (or the insufficient-data explanation),
   open hardening questions.
4. **What we could NOT establish** — mandatory, ranked by how much each unknown would change
   the picture, each with how to fill it (call question, document request, trade-data
   connection).
5. **So-what** — which scored exposures create urgency for a trade-compliance conversation,
   at capability level (no named product or vendor) — each tied back to a scored vector.
6. **Gap list** — 🔴 items, per the confidence-tagger's gap-list format (gap / why it
   matters / how to fill), sorted by impact.

**Exemplar:** match the shape and bar of `${CLAUDE_PLUGIN_ROOT}/references/presales/exemplars/exposure-brief-exemplar.md` — not its content.

## Quality checklist

- [ ] Data mode declared once, in the header — no silent mixing of connected/fallback evidence
- [ ] All five vectors (or the requested subset) are either scored against a cited anchor or
      explicitly marked "insufficient data" — no vector left blank or skipped silently
- [ ] Every claim carries a 🟢/🟡/🔴 tag with an inline source
- [ ] Every score cites the anchor clause(s) it matches — falsifiable, not asserted
- [ ] No fabricated sources, volumes, or counterparty names
- [ ] "What we could NOT establish" section present and ranked
- [ ] So-what stays at capability level — no named product pitch
- [ ] Gap list present, sorted by impact

## Handoff

**Chain:** if this brief was triggered from a change digest or watchlist review, return to
`/cc:radar:brief` with the scored vectors so the affected-accounts shortlist can cite them;
otherwise, when discovery is next on the account, hand straight to
`/cc:discovery:prep` — the exposure findings seed its hypotheses and question plan.
**Solo:** when one or more scored exposures maps to a quantifiable value lever, suggest
`/cc:value:roi-case` — resolve the mapping via
`${CLAUDE_PLUGIN_ROOT}/references/domains/trade/valuation/_index.md` (e.g., a high tariff
score maps to `fta-utilization` and `duty-drawback`; a high de-minimis score maps to
`de-minimis-optimization`) and 🟡-tag every unvalidated benchmark it pulls in.
**Abort rules:** company can't be disambiguated (ambiguous name, unclear parent/subsidiary)
→ ask before researching. Zero public information findable for the company at all → report
that honestly as the finding (every vector "insufficient data", gap list explains why) —
do not pad the brief with generic industry assumptions dressed up as company-specific claims.
