# Severity & Review Rubrics

The **single canonical severity ladder** and review rubrics for every reviewing command and
agent in this plugin — `/cc:verify:code`, `/cc:verify:pr`, `/cc:verify:security`,
`/cc:verify:codebase`, `/cc:verify:code-review-fix`, and the `code-reviewer`,
`security-auditor`, and `gdpr-auditor` agents. Those files do **not** define their own
ladders; they reference this one and declare only their command-specific deltas (extra
levels, label mappings, domain-specific evidence bars). If a file's local text ever
contradicts this reference, this reference wins.

The ladder encodes **decision semantics**, not labels: every level answers *what must be
demonstrated before assigning it*, *who acts on it*, and *what it blocks*.

---

## The canonical ladder

| Level | Definition | Evidence bar (before you may assign it) | Who acts | Chain behavior |
|-------|-----------|------------------------------------------|----------|----------------|
| **CRITICAL** | Exploitable security flaw, data loss/corruption, an irreversible action, or guaranteed breakage of a core path. | The failure is **demonstrated end-to-end**, not asserted: untrusted input traced to the sink, or the data-loss trigger shown to fire under a normal operation. Exception: a secret/credential in code is CRITICAL on presence alone — exposure *is* the demonstration. | **Human decision first.** `/cc:verify:code-review-fix` may apply the fix only when it is mechanical, local, and safe (e.g. parameterize one query, remove one hardcoded secret not yet pushed). A CRITICAL that cannot be fixed safely is escalated, never worked around. | **Stops everything.** Blocks merge, halts any verify/PIV chain, never passes a commit gate. A deferred (unfixed) CRITICAL means the chain ends with an escalation to the user. |
| **HIGH** | Real correctness bug or security weakness likely to be hit in normal use — wrong results, unhandled common failure mode, reachable injection with a realistic precondition. | A **concrete failure scenario**: specific input or state → specific wrong outcome, anchored at `file:line`. If you cannot write that sentence, the finding is not HIGH. | `/cc:verify:code-review-fix` fixes **all** HIGH findings automatically; a HIGH it cannot fix without inventing requirements is deferred with a reason and surfaced. | **Blocks merge** (NEEDS CHANGES / fix before commit). Does not by itself halt a chain — it routes into the fix loop; if still open after the loop cap it must be restated at the commit gate. |
| **MEDIUM** | Real but bounded: edge-case bug, meaningful performance issue at plausible scale, defense-in-depth gap (missing rate limit, floating dependency), maintainability problem that will breed defects. | A plausible path described and the **blast radius stated** — why it is bounded. | **Fix-or-ticket.** `code-review-fix` fixes only the mechanical-and-local ones (missing null check, unused import, off-by-one); everything else is deferred to the user with a one-line reason. | **Advisory.** Never blocks merge or chain, but must be *acknowledged* — fixed, ticketed, or explicitly accepted. Silent drops are a review defect. |
| **LOW** | Style, naming, hygiene, minor inefficiency, nice-to-have hardening. | Pointing at the line is enough. | Batched into a cleanup pass (`/cc:release:cleanup`) or consciously ignored. Deferred by default in `code-review-fix`. | **Advisory only.** Never blocks anything; excluded from verdict math. |
| **INFO** *(audit reports only)* | Observation, not a finding — licensing note, hardening idea, context for the reader. | n/a | Nobody; recorded for the report. | None. Only security/GDPR audit outputs use this level; code review does not. |

**Chain loop cap (canonical):** the fix → re-validate cycle runs **at most 2 times** per
chain; findings surviving the second loop stop the chain and escalate.

## Calibration rules (binding)

1. **No concrete failure scenario → not HIGH or CRITICAL.** "Could theoretically" is LOW
   until demonstrated. This rule has no exceptions, including security findings.
2. **Reachability decides security severity — never the category alone.** Trace whether
   untrusted input actually reaches the sink: a raw SQL string in a test fixture is not a
   raw SQL string in a request handler. Reachable injection / auth bypass / live secret →
   CRITICAL or HIGH. Unreachable pattern or defense-in-depth gap → MEDIUM. "All security
   findings are automatically CRITICAL" is over-flagging and is wrong.
3. **Downgrading with reasoning is a first-class outcome**, not a failure of nerve. State
   what evidence was missing for the higher level ("no reachable path from user input →
   MEDIUM, not HIGH"). Upgrades need the same discipline: name the new evidence.
4. **When torn between two levels**, pick the higher one only if you can write the concrete
   failure scenario; otherwise pick the lower.
5. **Count-capping must be declared, never silent.** "Reporting top 5 of 12 LOW findings"
   is honest; a silently truncated list corrupts the verdict.
6. **One finding per root cause.** List all occurrences inside that one finding instead of
   repeating it per file.
7. **Don't relitigate pre-existing code** unless the change under review makes it worse or
   newly dangerous.

## Anatomy of a finding

Claim → evidence → failure scenario → minimal fix. Every finding carries all four:

1. **Claim** — one line, specific ("retry loop drops the last error"), never vague
   ("consider improving error handling").
2. **Evidence** — `file:line` (or range) plus a short quote/description of the offending
   code. **No `file:line`, no finding.**
3. **Failure scenario** — how it goes wrong in practice: input/state → outcome. Mandatory
   and concrete for HIGH+; a plausibility sketch suffices for MEDIUM/LOW.
4. **Minimal fix** — the smallest correct change, described (reviewers are read-only and
   never apply it). "Rewrite the module" is not a fix suggestion.

## Anatomy of a verdict

Three canonical tiers. Every command keeps its own surface labels, but each label maps to
exactly one tier — a verdict is *derived* from the findings, never vibes:

| Tier | Condition | Evidence requirement |
|------|-----------|----------------------|
| **MERGE READY** | Zero CRITICAL, zero HIGH; no unacknowledged MEDIUM. | Must state **what was checked and found clean** (1–3 lines). A bare "looks good" is not a verdict. |
| **MERGE READY WITH WARNINGS** | Zero CRITICAL/HIGH; open MEDIUM/LOW remain. | Every open finding listed with a disposition: fix now, ticket, or ignore-with-reason. |
| **NEEDS CHANGES** | ≥1 CRITICAL or HIGH. | Every blocking finding meets the full finding anatomy, and the verdict names them — no blocking without a `file:line`. |

Label mapping per surface: `verify:code` CLEAN / FINDINGS(counts) · `verify:pr`
MERGE READY / NEEDS CHANGES · `verify:security` PASS / PASS WITH WARNINGS / FAIL(CRITICAL)
· `verify:codebase` CLEAN / NEEDS ATTENTION / ACTION REQUIRED · `code-reviewer` agent
APPROVE / APPROVE WITH FIXES / REQUEST CHANGES / BLOCK(CRITICAL) — where BLOCK(CRITICAL)
is NEEDS CHANGES with ≥1 CRITICAL, and APPROVE WITH FIXES = MERGE READY WITH WARNINGS.

## Reviewer calibration

- **Base rates.** Most diffs contain **zero** CRITICALs and zero-to-one HIGHs. Finding
  none is a valid, common outcome — report it with the checked-and-clean list and stop. A
  review with no findings is not a failed review; an empty findings list with documented
  checks is a valuable result.
- **The dominant failure mode is over-flagging, not under-flagging.** Inventing findings
  to look thorough, or inflating MEDIUMs into HIGHs, trains humans to ignore the ladder —
  and the one real HIGH drowns. A false CRITICAL costs more than a missed LOW: it burns
  remediation effort and erodes trust in every future verdict. Three verified findings
  with exact locations beat fifteen pattern-match guesses.
- **When to stop looking.** You are done when: every changed file (plus its direct callers
  and tests) has been read; each rubric dimension has been checked once against the change;
  and every candidate finding has been verified at its `file:line` or dropped. Then stop —
  additional passes hunting for something to say produce noise, not safety.

## Gate integrity: validated-state and declared exceptions

These rules bind every agent, command, or model that gates a change — human-invoked or
autonomous, present or future. A gate that doesn't follow them isn't a gate.

**1. A verdict binds to the exact state it evaluated.** Reviews, CI results, and gate
checks attach to a specific commit SHA (or file state), never to "the branch" or "the
work." Any change after the verdict — however small, including your own — voids it for the
new state. Merging or shipping state B on a verdict issued for state A is the
validate-one-merge-another defect, regardless of intent.

**2. Re-verification is proportionate to the delta, by class:**

| Delta since the verdict | Minimum re-verification |
|---|---|
| Nothing (same SHA) | None — the verdict stands |
| Docs/comments only, no executable or prompt-logic content | Mechanical gate re-run (cc-audit/CI) at the new state + a declared exception (rule 3) |
| Any code, command/skill logic, config, or schema | Full re-review at the new state — no exceptions |

When unsure which class a delta is, treat it as the higher one.

**3. Exceptions must be declared, never slipped.** Taking the proportionate shortcut (row 2)
is legitimate **only when stated in the final report**: what rule was relaxed, the exact
delta it covers (SHA→SHA), and what verification still covers it. An undeclared exception
is itself a defect — file it at MEDIUM minimum when found. The test: if the reader would
be surprised to learn what the verdict does *not* cover, it wasn't declared.

**4. You never get to be the sole judge of your own exception twice.** One declared
proportionate shortcut per ship is acceptable; stacking a second change on top of an
already-stale verdict requires a fresh full review — shortcuts don't compound.
