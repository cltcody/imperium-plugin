---
description: Assess whether a trade-regulatory change touches this codebase's reference data, fixtures, or rate tables, and scope the fix. Use when the ask is "does this tariff/sanctions change break anything here" or you're handed a /cc:radar:scan digest entry
argument-hint: [digest entry or pasted regulatory-change text]
disable-model-invocation: true
---

# Radar: Impact

Dev-facing follow-through on a regulatory-radar change: given one change (a `/cc:radar:scan`
digest entry, or text pasted directly — e.g. from a Federal Register notice or an internal
alert), determine whether *this specific codebase* has anything keyed to what changed, scope
the blast radius, and route to planning. This command is for product codebases — reference
data, fixtures, rate tables, HS-code or country-code literals, sanctioned-party lists baked
into config or seed data. It is not an account/customer research tool — that's
`/cc:radar:brief`.

## Change

$ARGUMENTS

If empty, ask for the change (digest entry or pasted text) before proceeding.

## Steps

1. **Parse what the change touches.** From the input, extract as many of the following as
   are stated: HS chapters/subheadings affected, specific rates (old → new, or new rate
   created), country/party lists touched (additions/removals), regime/program name (e.g.
   Section 301 list, OFAC SDN, BIS Entity List, CBAM, UFLPA, de-minimis threshold, HS
   revision), effective date, and jurisdiction. If the input is too vague to extract any of
   these, say so and ask for the specific notice/rule rather than guessing at scope.

2. **Confirm this is a code repository.** Check for the markers `/cc:setup:stack` would use
   (`package.json`, `pyproject.toml`, `STACK.md`, source directories). No such markers →
   this is not a product codebase; abort per the Abort rule below rather than inventing an
   impact scan.

3. **Impact-scan the codebase** for anything keyed to what changed:
   - Grep for the literal codes/rates/parties involved: HS codes or subheadings (with and
     without punctuation, e.g. `8471.30` and `84713000`), country codes (ISO alpha-2/3),
     named parties or entity-list strings, rate constants (percentages, duty amounts),
     regime/program identifiers used as flags (`section301`, `ofac`, `uflpa`, `cbam`,
     `de_minimis`, HS revision year literals like `hs2022`/`hs2017`).
   - Check the obvious homes for this kind of data first: fixtures/seed data, config files,
     reference-data modules, rate tables, migration files (a rate or list is often seeded
     via migration, not just live code) — then widen to a full-repo grep if the narrow
     search comes back empty, to avoid a false "no impact" from checking too little.
   - Check migration history (`git log` on any matched files, or the migrations directory)
     for when the current values were last touched — tells you how stale the baseline is
     and who/what last owned this data.
   - Record every hit as `file:line` with the matched literal and surrounding context.

4. **Run a STACK.md-resolved targeted test check** on the affected areas. Resolve the
   project's tooling per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`: for each
   component whose `working_dir` contains a hit from step 3, run its `test` step scoped to
   the affected files/modules if the runner supports narrowing, else the full `test` step for
   that component. No `STACK.md` → auto-detect once and recommend `/cc:setup:stack`. No
   resolvable test step for a component with hits → say so explicitly, don't imply "tests
   pass" when none ran.

5. **Assess risk and effort.** For each affected file/area: what breaks if nothing changes
   (wrong duty calculated, a barred party not screened, an expired rate still applied, a
   soon-to-be-invalid HS code rejected at filing) — rate severity high/medium/low by
   real-world consequence, not by line count. Effort: rough size (single constant update /
   data-table refresh / logic change / migration needed) and any test-coverage gap the scan
   exposed.

6. **Verdict.** One of:
   - **Impact found** — proceed to Output with the affected-files list, risk, and effort.
   - **No impact found** — a first-class, equally valid verdict. State it plainly along with
     the evidence of where you looked (which literals/patterns were searched, which
     directories/components were checked, what the targeted tests showed) so "no impact"
     reads as a checked fact, not a shrug.

## Output

```
RADAR IMPACT ASSESSMENT — <one-line change summary>
Change: <regime/program, what moved, effective date>
Parsed scope: <HS chapters | rates | party lists | regime — whatever was extractable>

Repo check: <component(s) checked, per STACK.md>

VERDICT: IMPACT FOUND / NO IMPACT FOUND

Affected files (if impact found):
  <file>:<line> — <matched literal> — <what it currently encodes>
  ...

Evidence searched (always shown, both verdicts):
  Patterns: <literals/regexes searched>
  Locations: <dirs/components checked, incl. fixtures/migrations>
  Tests run: <component: test step + result, or "none resolvable">

Risk assessment: HIGH / MEDIUM / LOW — <real-world consequence if unaddressed>
Effort estimate: <rough size + what kind of change>

Drafted task for /cc:plan:task:
"<one-paragraph task description: what to update, where, why, by when (effective date)>"
```

## Quality checklist

- [ ] Change was parsed into concrete, searchable terms before any grep ran — not a vague
      keyword search on the notice's headline
- [ ] Repo-code check happened before any codebase claim — no impact assessment offered for
      a non-code input
- [ ] Search widened beyond the first empty result before declaring "no impact" — fixtures,
      migrations, and config checked, not just obvious source files
- [ ] Every affected-file claim carries a `file:line` reference
- [ ] Targeted tests were actually run (or their absence stated) — not assumed
- [ ] "No impact found" states the evidence with the same rigor as "impact found"
- [ ] Drafted task description is concrete enough to hand to `/cc:plan:task` without
      further clarification

## Handoff

**Chain:** impact found → invoke `/cc:plan:task` with the drafted task description as input.
**Solo:** no impact found → say so and stop; no further command needed unless the user wants the assessment saved to `${user_config.workspace_dir}/reports/`. Broader data-contract testing beyond this change → note that full data-contract verification is out of scope here (see the plan's backlog) and this command only covers the single-change case.
**Abort rules:** not a code repository (no stack markers found) → stop and say this command is for product codebases; if the underlying need is customer/account-facing, suggest `/cc:radar:brief` instead.
