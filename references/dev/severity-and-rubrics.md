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

## Borderline calls — worked examples

The ladder and the calibration rules settle most findings. The cases below are the
contested remainder — calls where two competent reviewers pattern-match to different
levels. They span the review families this ladder serves: security, performance,
correctness, dependencies, accessibility, test quality. Each shows the finding, the
tempting rating and its pull, the correct rating, and the one factor that decides it.
All codebases are fictional; nothing here overrides the rules above — these are the
rules under pressure.

1. **SQL interpolation in an ops-only maintenance script**
   - *Finding:* `tools/purge_tenant.py` f-strings its `--tenant` argument into
     `DELETE FROM tenants WHERE slug = '…'`.
   - *Tempting:* CRITICAL — string-built SQL fed by an external argument is the textbook
     injection pattern.
   - *Correct:* MEDIUM.
   - *Decider:* Exploit preconditions — everyone who can run the script already holds
     credentials with full DB access, so the injection grants nothing they lack.
     Parameterize it anyway; re-rate HIGH the day the argument is fed from tickets,
     exports, or anything a user once typed. Trace who supplies the input, not what the
     code looks like.

2. **Live-looking API key in a test fixture**
   - *Finding:* `tests/fixtures/billing.json` carries `"api_key": "sk_live_…"` —
     high-entropy, provider-prefixed, indistinguishable from a real key.
   - *Tempting:* LOW — "fixtures hold fake data" is usually true.
   - *Correct:* HIGH until provenance is proven — then CRITICAL (real: rotate, purge
     history) or LOW (synthetic: rename it so it screams fake).
   - *Decider:* Burden of proof — the ladder makes a real secret CRITICAL on presence
     alone, so "probably fake" is not a downgrade argument; provenance is: a
     secret-scanner verdict, the provider dashboard, the commit history.

3. **Missing index on a 200-row table**
   - *Finding:* `plans.code` is filtered in three queries and has no index; the table
     holds ~200 staff-edited rows.
   - *Tempting:* HIGH — "unindexed column on a queried path" pattern-matches to full
     scans at scale.
   - *Correct:* LOW.
   - *Decider:* Blast radius is measured, not inferred — a 200-row scan costs
     microseconds and the table grows by data entry, not by traffic. Name the number
     that would change the call (row count in the tens of thousands, or the query inside
     a per-request loop) and move on.

4. **N+1 query behind a cache**
   - *Finding:* `renderInvoice()` fetches each line item's product row in a loop — every
     fetch through `productCache.get()`.
   - *Tempting:* HIGH — the loop is the classic N+1 shape.
   - *Correct:* MEDIUM.
   - *Decider:* Reachability of the slow path — the failure scenario must survive the
     mitigation actually in place. Warm cache, the loop is free; the N+1 is real only on
     cold start or flush, a bounded event. Hit-rate evidence moves it: a per-request
     cache or an unbounded key space makes it HIGH.

5. **Heavy library in a lazy-loaded admin chunk**
   - *Finding:* the diff adds a 400 KB charting library to `admin/UsageDashboard`,
     behind the route-level code split.
   - *Tempting:* HIGH — "+400 KB dependency" reads like a shipping regression.
   - *Correct:* LOW.
   - *Decider:* Blast radius is where the bytes land, not how many there are — the
     customer entry chunk is byte-identical and the cost falls on a handful of staff
     sessions. The same import in the customer-facing entry chunk is a different
     finding: same bytes, every first paint, MEDIUM to HIGH.

6. **Catch-and-continue in a background retry loop**
   - *Finding:* `sync_worker.py` wraps each push in `except Exception: continue`; after
     `MAX_RETRIES` the item falls out of the loop — no log, no dead-letter.
   - *Tempting:* MEDIUM — "improve error handling" is usually advisory.
   - *Correct:* HIGH.
   - *Decider:* Data-loss potential with zero operator signal — on the Nth retry the
     record is silently discarded, and the first detection path is a customer noticing
     missing data. Silent loss on a background path outranks a loud failure on a
     foreground one.

7. **Webhook handler that isn't idempotent**
   - *Finding:* `POST /webhooks/payment` credits the account on every delivery; nothing
     checks the event id.
   - *Tempting:* MEDIUM — duplicate delivery feels like a rare edge case.
   - *Correct:* HIGH.
   - *Decider:* Recurrence rate — at-least-once redelivery is the provider's documented
     normal behavior (timeouts, retries, manual redelivers), so double-crediting is a
     normal-operations outcome. Check "edge case" claims against the integration's
     contract, not against intuition.

8. **Critical-scored CVE in a dev-only tool**
   - *Finding:* the lockfile pins a scaffolding CLI whose transitive parser carries a
     CVSS 9.8 RCE advisory.
   - *Tempting:* CRITICAL — the scanner prints 9.8 in red.
   - *Correct:* LOW.
   - *Decider:* Reachability — the tool is absent from the shipped artifact and parses
     only files developers already control; fold it into the next routine bump. It jumps
     to HIGH the moment the tool runs in CI with access to secrets or publish
     credentials — that is a real supply-chain path.

9. **Moderate-scored CVE in the upload path**
   - *Finding:* the image library that processes every user upload carries a CVSS 5.3
     out-of-bounds-read advisory.
   - *Tempting:* MEDIUM — the score says moderate.
   - *Correct:* HIGH.
   - *Decider:* Reachability, in the other direction — attacker-controlled bytes reach
     the vulnerable function on every upload, pre-auth. The advisory scores the
     reporter's assumed deployment; you rate *your* exposure. A CVSS score is an input
     to severity, never the severity.

10. **The same unlabeled input, two pages**
    - *Finding:* two form inputs with no programmatic label — one on an unlaunched
      internal ops page, one in the checkout address form.
    - *Tempting:* MEDIUM for both — same WCAG failure, and rating them identically
      feels principled.
    - *Correct:* LOW on the internal page, HIGH on checkout.
    - *Decider:* User harm attaches to the point of failure, not to the rule — a
      screen-reader user blocked at checkout is a customer who cannot pay, on the core
      path; the internal page has no users yet (fix it before launch does).

11. **Contrast failure on disabled buttons**
    - *Finding:* the accessibility scanner flags 2.4:1 text contrast on every disabled
      `Save` button.
    - *Tempting:* MEDIUM — the tool reports it as a WCAG 1.4.3 failure.
    - *Correct:* Not a finding — drop it (INFO at most, in an audit report).
    - *Decider:* Burden of proof includes reading the standard — WCAG 1.4.3 explicitly
      exempts inactive components. A scanner hit is a candidate, not a violation, until
      checked against the spec text. (The real question nearby: is the disabled state
      conveyed by more than color?)

12. **Assertion-free test on the refund path**
    - *Finding:* `test_refund_totals` builds a cart, calls `computeRefund()`, and
      asserts nothing; it passes because nothing threw.
    - *Tempting:* LOW — test hygiene, and the code under test may well be correct today.
    - *Correct:* HIGH.
    - *Decider:* False assurance — the suite reports the refund path covered while
      being able to detect nothing; a sign flip in `computeRefund()` ships green. An
      absent test is a visible gap; an assertion-free one is camouflage. Severity
      follows the certified path: the same empty test on a tooltip helper is LOW.

13. **Skipped regression test over a shipped bug**
    - *Finding:* `it.skip('carries the billing period across DST', …)` — skipped
      "temporarily" three months ago, guarding a bug that reached customers once
      already.
    - *Tempting:* LOW — a skip is one line of hygiene debt.
    - *Correct:* HIGH.
    - *Decider:* Recurrence rate — the test exists because the failure already
      happened; the skip removes the only detector for a proven failure mode. A
      disabled guard inherits the severity of whatever it guards.

Two patterns account for most miscalls: inflation from rating the *pattern* instead of
the traced path (1, 3, 4, 5, 8, 11), and deflation when a score, a label, or an
artifact's quietness hides the outcome (2, 6, 7, 9, 12, 13).

## False-positive discipline

Reviewer calibration names the dominant failure mode: over-flagging. These are the
operating rules that prevent it. The burden of proof is on the finding, never on the code.

- **Name the trigger before the level.** A severity attaches to a failure, and a failure
  has a trigger — the concrete input or state that fires it. Write the trigger first; if
  it cannot be written, there is no HIGH or CRITICAL to assign.
- **Cannot trace an actual path? Downgrade one level and say so — or drop the finding.**
  "MEDIUM — no reachable path from user input found" is a complete, honest disposition.
  A HIGH kept "to be safe" is how the ladder rots: the safety lives in the stated
  reason, not in the inflated level.
- **Every severity claim carries quotable evidence** — the file plus the offending
  snippet. If you cannot paste the line that fails, you have predicted a bug, not found
  one; predictions are hardening notes, and hardening notes are LOW.
- **"Could theoretically" is a LOW, not a HIGH.** Calibration rule 1, restated because
  it is the most-violated rule in practice. Theoretical becomes real the moment you
  write the input that does it; until then it blocks nobody.
- **Genuinely torn — the higher level's failure scenario won't quite write? Give the
  lower and state what would raise it.** "MEDIUM; becomes HIGH with evidence the cache
  is per-request" turns a judgment call into a checkable claim. This mirrors the
  stinginess principle the eval judges apply to scored artifacts — when torn between
  two scores, give the lower — and for the same reason: inflation destroys the scale's
  power to flag the real thing.

A review is trusted exactly to the degree its HIGHs turn out to be real. Every inflated
finding spends that trust; a clean "no findings — here is what was checked" earns it.

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
