---
description: Score a completed/ending PoC against its own plan's success criteria and produce the champion-ready readout
argument-hint: [poc-plan path]
disable-model-invocation: true
---

# Deal: PoC Readout

Score a PoC/POV that is complete or ending against the success criteria its own `/cc:deal:poc-plan`
committed to — not against a fresh judgment call. The scorecard is only as honest as the evidence
behind it: every row needs a demonstration, a date, and a witness, or it doesn't get called "met."

## PoC plan: $ARGUMENTS

**Where this reads and writes:** `deals/` resolves against the deals workspace per the
Command Integration Contract in
`${CLAUDE_PLUGIN_ROOT}/references/presales/deals-workspace.md` (config → env → default
`~/code/deals-workspace`; offers to create if absent; never falls back to cwd or this
repo). In a `corporate`-classed repo
(`${CLAUDE_PLUGIN_ROOT}/references/dev/repo-classification.md`), print the one-line
redirect notice before writing — the destination is the workspace either way.

## Steps

1. **Resolve the poc-plan doc.** If `$ARGUMENTS` is a path, read it. Otherwise glob
   `<deals-workspace>/deals/poc-plan-*.md`, take the most recently modified match, and **state which
   file you resolved to before proceeding** — this is a confirmation step, not a silent guess. Zero
   matches → Abort (see below).
   > **Known gap:** `/cc:deal:poc-plan` currently prints its plan inline and does not save a
   > file, so the glob only finds plans you saved yourself (recommended:
   > `<deals-workspace>/deals/poc-plan-<name>.md`). Otherwise pass the path or paste the plan.
   > Tracked follow-up: add a write-to-file step to poc-plan.

2. **Extract the success criteria in poc-plan's own structure — don't re-derive a new one.**
   `/cc:deal:poc-plan` defines criteria under its `### Success criteria` heading as a table:
   `| Criterion | Measurement method | Target | Use case | Status |`, cross-referenced against the
   `### Use Cases in scope` table (`# | Use case | Description | Owner (customer) | Owner (${user_config.company})`)
   and framed by the `### POC Objective` one-liner and the gate question ("If we complete all use
   cases and satisfy all these criteria, will you select ${user_config.company} as your vendor of choice?").
   Pull every row from that exact table verbatim — criterion wording, measurement method, and target
   as written. Do not paraphrase or tighten a vague target; if it's vague, that's a finding (Step 6),
   not something to fix silently here.

3. **Score each criterion.** For every row from Step 2, assign exactly one of:
   - **MET** — target reached, evidence attached
   - **PARTIALLY MET** — directionally there, short of target, or met for some but not all use cases
   - **NOT MET** — tested, target not reached
   - **NOT TESTED** — the customer environment, data, or timeline never allowed a real test

   For each, capture evidence in this shape: *what was demonstrated, when it happened, who witnessed
   it (customer name/role — not "the team")*. Evidence-or-honest-gap: never infer a MET from
   proximity, vendor confidence, or a use case going well in general. If no evidence exists, the
   criterion is NOT TESTED — full stop, regardless of how the PoC "felt."

4. **Build the delta story.** Compare what actually happened against the POC Objective and the
   original use-case hypotheses from poc-plan: what was proven, what wasn't, and name surprises in
   both directions — things that worked better than expected AND things that underperformed or
   surfaced new risk. A readout with no surprises in either direction is a signal to re-check the
   evidence, not a compliment to the product.

5. **Form the overall verdict.** Roll the criteria scorecard up into one line: would the gate
   question ("will you select ${user_config.company}") get a clean yes today, a conditional yes, or a no — and
   why, in one sentence tied to the criteria that drove it.

6. **Write the readout doc** to `<deals-workspace>/deals/poc-readout-<name>.md` (see Output). This is
   a champion-ready document — it needs to survive being forwarded to the Economic Buyer without an
   SC in the room to explain it.

7. **Confidence-tag every evidence claim** 🟢 Confirmed (witnessed, dated, reproducible) / 🟡
   Inferred (reported secondhand, not directly observed) / 🔴 Unknown (no evidence either way) —
   applied to the evidence behind each scorecard row, not just to the overall verdict.

## Output

`<deals-workspace>/deals/poc-readout-<name>.md`:

```
## PoC Readout — [Account] | [Date]

Source plan: [path to the poc-plan doc resolved in Step 1]
POC Objective (from plan): [quoted one-liner]

### Executive summary
[3-4 sentences, exec-readable: overall verdict, the gate-question answer, the single
most important number or fact, and the recommended next step. No jargon.]

### Criteria scorecard
| Criterion | Target | Verdict | Evidence | Confidence |
|-----------|--------|---------|----------|------------|
| [from poc-plan Success criteria table] | [Target] | MET / PARTIALLY MET / NOT MET / NOT TESTED | [what/when/witnessed by] | 🟢/🟡/🔴 |

### The delta story
**What the PoC proved that the hypotheses assumed:** [...]
**What the PoC proved that we did NOT expect (positive surprise):** [...]
**What underperformed or surfaced new risk (negative surprise):** [...]

### Evidence appendix
[Full detail behind each scorecard row — session dates, attendees, data volumes, screenshots
or output references, direct quotes from the customer team where available. This is the
backup material if the EB or procurement pushes back on a verdict.]

### Open risks
[What's still unresolved going into a decision — data quality, integration scope, timeline,
a criterion that came back NOT TESTED and needs to be closed before signature.]

### Recommended next step
[One specific action — who does what by when. Tie it explicitly to the gate-question answer.]
```

If any criterion in the source poc-plan was never made measurable (no number, no agreed target,
status still "Not started" with no method defined), do not force a quantitative score onto it.
Say so explicitly, score it qualitatively (directional MET/PARTIAL/NOT MET based on customer
sentiment and observed behavior only), and put that caveat at the top of the executive summary —
not buried in the appendix. A qualitative call presented as if it were measured is worse than no
call at all.

## Quality checklist

- [ ] Source poc-plan file identified and named in the output doc
- [ ] Every criterion from poc-plan's Success criteria table appears in the scorecard — none
      dropped, none added
- [ ] Every MET or PARTIALLY MET has dated, witnessed evidence — not vendor-side inference
- [ ] NOT TESTED used honestly wherever evidence is genuinely absent — not softened to PARTIALLY MET
- [ ] Delta story names at least one surprise in each direction, or explicitly states there were none
- [ ] Every evidence claim carries a 🟢/🟡/🔴 tag
- [ ] Any criterion that was never made measurable is flagged prominently, not scored as if it were
- [ ] Recommended next step is specific — named action, named owner, named date

## Handoff

**Chain:** when in a PIV chain, immediately invoke `/cc:deal:champion-enable` with the readout doc
(arm the champion to carry the scorecard to the Economic Buyer), then `/cc:deal:exec-summary` for
leadership visibility — do not ask.
**Solo:** end by suggesting `/cc:deal:champion-enable <deals-workspace>/deals/poc-readout-<name>.md`
as the next step, with `/cc:deal:exec-summary` after.
**Abort rules:** no poc-plan doc found (neither `$ARGUMENTS` nor a match in
`<deals-workspace>/deals/`) → stop and route to `/cc:deal:poc-plan` first — there is nothing to score
against. Success criteria were never defined measurably across the board → don't fabricate rigor;
say so, score qualitatively per the caveat above, and keep that caveat prominent in the readout, not
just in this checklist.
