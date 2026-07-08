---
description: Audit whether the tests actually catch bugs — nine test-smell checks (assertion-free, mock-the-subject, snapshot-only, flaky waits, …) plus an optional guarded mutation-lite probe, with a PASS/WARNINGS/FAIL verdict
argument-hint: "[scope: diff|full] [--mutation]"
---

# Verify: Test Quality — Do the Tests Catch Bugs?

Audits the **quality** of existing tests — would they fail if the code broke? — complementing `/cc:verify:coverage` (quantity) and `/cc:verify:test` (authoring missing tests). Run it when coverage looks fine but bugs escape, before trusting a suite as a refactoring safety net, or when inheriting a codebase. **Stack-agnostic**: test framework and commands come from the project's `STACK.md` per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` (jest, vitest, pytest, go test, rspec, …) — never from this file.

Scope: **diff** (default) — test files changed in the working diff plus the test files covering changed modules (find them by grepping the changed modules' names/imports across the test tree). **full** — every test file in every component. `--mutation` additionally offers the guarded mutation-lite probe (step 3); it never runs on the flag alone.

## Findings ledger

Findings go to the shared findings ledger — `${user_config.workspace_dir}/audits/ledger.jsonl`, one JSON record per finding — per `${CLAUDE_PLUGIN_ROOT}/references/dev/findings-ledger.md`. Records carry `command`, `rule`, `file`, `severity` (CRITICAL / HIGH / MEDIUM / LOW), `status` (new / known / accepted / fixed / regressed), `first_seen` / `last_seen`, and `accepted_reason` / `accepted_by` / `accepted_until` on accepted findings, keyed by `fingerprint` — the first 16 hex chars of sha256 over `command|rule|file|normalized_evidence`. Here `file` is the test file (the mutated source file for `tq.mutation-survived`) and normalized evidence is the **test/suite or function name**, never a line number — findings survive line drift.

- **Default runs** annotate every finding with its ledger status — NEW, KNOWN, or ACCEPTED (REGRESSED when a previously fixed finding returns), tag format per the ledger reference. **`--delta`** reports only NEW and REGRESSED in full, plus one-line counts of known / accepted / fixed.
- **Acceptance is user-driven only** — never mark a finding accepted yourself; record acceptance (reason, by whom, until when) only when the user explicitly grants it. No ledger present? Run ledger-less (findings unannotated) and offer to initialize `${user_config.workspace_dir}/audits/ledger.jsonl`.
- Rule ids: `tq.assertion-free`, `tq.mock-subject`, `tq.snapshot-only`, `tq.sleep-wait`, `tq.shared-state`, `tq.disabled`, `tq.tautology`, `tq.broad-exception`, `tq.no-negative`, `tq.mutation-survived`.

### 1. Resolve the test stack and the scope

Read `STACK.md` and resolve each component's `test` step, `language`, and `working_dir` per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` — the language decides which detection idioms apply. No `STACK.md` → detect the framework once and recommend `/cc:setup:stack`. Locate each component's test tree and collect the in-scope test files (diff vs full). **No test files anywhere → a quantity problem, not quality: report "not applicable — no tests found", point to `/cc:verify:coverage` and `/cc:verify:test`, and stop.**

### 2. Static smell catalog

Sweep every in-scope test file for each smell. Greps are illustrative starting points (jest/vitest + pytest flavored — adapt to the component's language and framework). **A pattern match alone is never a finding**: verify every hit at its `file:line` against the smell's true-positive criteria first — the dominant failure mode is over-flagging, per `${CLAUDE_PLUGIN_ROOT}/references/dev/severity-and-rubrics.md`.

**`tq.assertion-free` — test blocks with no assertions.** Proves only "does not throw"; stays green while the code returns garbage. Detect candidate files, then read each hit:
```bash
grep -rln "def test_" <test dirs> | xargs grep -L "assert"
grep -rln "it(\|test(" <test dirs> | xargs grep -L "expect(\|assert"
```
True positive: an individual it/test/`def test_` body with zero assertion calls, directly or via an assertion helper. Not a finding: explicit smoke tests named as such, or blocks whose assertions live in a shared helper they call.

**`tq.mock-subject` — mocking the module under test.** The test exercises the mock: the real implementation could be deleted and it would stay green. Detect:
```bash
grep -rn "jest.mock(\|vi.mock(\|mocker.patch(\|@patch(" <test dirs>
```
True positive: the mocked target resolves to the same module/function the test imports as its subject. Mocking the subject's *dependencies* is normal, not a finding.

**`tq.snapshot-only` — suites that only snapshot.** Snapshots assert "output changed", never "output correct" — and changed snapshots get reflexively regenerated. Detect files whose only assertions are snapshot matchers:
```bash
grep -rln "toMatchSnapshot\|toMatchInlineSnapshot" <test dirs> | xargs grep -L "toBe(\|toEqual(\|toContain(\|toHaveBeen"
```
True positive: a whole file or suite asserting exclusively via snapshots. A snapshot alongside behavioral assertions is fine.

**`tq.sleep-wait` — fixed sleeps instead of condition waits.** Passes on the fast machine, flakes in CI, and hides real races behind "wait longer". Detect:
```bash
grep -rn "time.sleep(\|asyncio.sleep(\|setTimeout(\|sleep [0-9]" <test dirs>
```
True positive: a fixed-duration wait between action and assertion. Not a finding: condition polls with a timeout (`waitFor`, `eventually`, `until`), fake-timer advancement (`jest.useFakeTimers`), or sleeps inside the system under test itself.

**`tq.shared-state` — module-level mutable state without reset.** Order-dependent tests: one test's leftovers become the next test's fixture. Detect module-scope mutable declarations in test files, then check for a reset:
```bash
grep -rn "^let \|^var \|^[a-z_]* = \[\]\|^[a-z_]* = {}" <test dirs>
```
True positive: state mutated by tests and never reset in a beforeEach/afterEach (or function-scoped fixture). Not a finding: immutable/const fixtures, or state reset in setup/teardown hooks.

**`tq.disabled` — skipped tests inventory, with age.** Every skip is coverage that silently left the suite; older skips are likelier dead protection nobody re-enabled. Detect, then age each hit via blame:
```bash
grep -rn "\.skip\|\.todo\|xit(\|xdescribe(\|@pytest.mark.skip\|@unittest.skip" <test dirs>
git blame -L <line>,<line> --date=short -- <test file>
```
True positive: a skipped/todo test with no linked issue or reason comment. Documented skips are listed as inventory context, not findings. Skips older than ~90 days rate one step higher within their severity band.

**`tq.tautology` — assertions that cannot fail.** `expect(true).toBe(true)`, `assert True`, `assert x == x` — usually the residue of a stubbed test never finished. Detect the literal forms, and read assertion lines for self-comparisons (same expression on both sides — no reliable grep exists):
```bash
grep -rn "expect(true).toBe(true)\|expect(1).toBe(1)\|assert True\|assertTrue(True)" <test dirs>
```
True positive: an assertion whose operands are constants or the identical expression — it cannot fail for any behavior of the code under test.

**`tq.broad-exception` — catching any error as success.** `pytest.raises(Exception)` or a matcher-less `rejects`/`toThrow` passes when the *wrong* error fires — even a typo'd call raising TypeError before the code under test runs. Detect:
```bash
grep -rn "pytest.raises(Exception)\|pytest.raises(BaseException)\|assertRaises(Exception)\|rejects.toThrow()\|.toThrow()$" <test dirs>
```
True positive: no error type/class/message narrows the expectation and the code under test raises something more specific it should assert. Rare exception: the code genuinely raises a bare generic error — verify before dismissing.

**`tq.no-negative` — happy-path-only public APIs (judgment call, MEDIUM max).** A public entry point whose tests never feed it bad input has its most failure-prone paths unverified. No mechanical grep — list the in-scope public API surface (exported functions, route handlers, CLI entry points) and check each has at least one test driving a realistic failure mode (invalid input, not-found, unauthorized, conflict). True positive: at least one realistic failure mode exists and zero tests exercise any of them. Cap at **MEDIUM** — this flags missing tests, not a defect in an existing one; authoring them is `/cc:verify:test`'s job.

### 3. Mutation-lite probe — only with `--mutation` AND explicit confirmation

Static smells say a test *looks* weak; a surviving mutant *proves* the suite cannot catch a real bug. Deliberately tiny — a handful of hand-picked single-condition flips, not a mutation-testing campaign (for that, adopt a real tool like Stryker or mutmut as a project decision).

**Safety rails — all mandatory, in this order:**

1. **Confirm with the user first.** Name the exact functions you intend to mutate and get an explicit yes. The `--mutation` flag alone never starts the probe.
2. **Require a clean working tree** — if this prints anything at all, abort the probe before touching a single file:
   ```bash
   git status --porcelain
   ```
3. **Pick 3–5 critical-path functions** — money paths, data-integrity writes, auth/entry points. Skip any candidate with no targeted tests at all: that is a coverage gap for `/cc:verify:coverage`; mutating it proves nothing.
4. **One mutant at a time, strictly serial.** Per target, flip **exactly one** condition (`>` ↔ `>=`, `==` ↔ `!=`, negate one guard, off-by-one a boundary). Never two live mutations at once; never batch across files.
5. **Run only the targeted tests** for that file — the component's `test` step narrowed to the covering test file(s) (a single path or `-k` filter). Confirm those tests pass on the *unmutated* code first (a red baseline voids the probe for that target). Never run the full suite with a live mutant.
6. **Record the outcome** — killed (at least one targeted test fails) or survived (all stay green).
7. **Restore immediately and verify restoration** before the next target:
   ```bash
   git checkout -- <mutated file>
   git diff --exit-code -- <mutated file>
   ```
8. **Abort the whole protocol on any restore failure.** If the diff check is non-empty or the checkout errors, stop the entire probe, report the exact file and working-tree state to the user, and do not proceed to any further target.

Survived mutants are **HIGH** findings (`tq.mutation-survived`) — the failure is demonstrated, not asserted: this exact behavioral break passed the suite. Killed mutants are reported as positive evidence for the suite.

### 4. Rate the findings

Per `${CLAUDE_PLUGIN_ROOT}/references/dev/severity-and-rubrics.md`, every finding carries `file:line`, the lie it tells (why the suite stays green while the code breaks), and a minimal fix:

- `tq.assertion-free` or `tq.mutation-survived` on a **critical path** (money, data integrity, auth, main entry points) → **HIGH**.
- The same smells on leaf utilities, and the other smells generally → **MEDIUM** when they mask a plausible regression, **LOW** for hygiene-grade instances.
- `tq.no-negative` → **MEDIUM max**, always. CRITICAL is not used by this command.

### 5. Update the ledger, report, and verdict

Record findings per the Findings ledger section (statuses annotated on default runs, `--delta` for NEW + REGRESSED only, acceptance only from the user, accepted findings reported but excluded from verdict math). Write the report to `${user_config.workspace_dir}/reports/test-quality/YYYY-MM-DD-test-quality.md` (create the directory if needed). Verdict, accepted findings excluded: any HIGH → **FAIL** · only MEDIUM/LOW → **WARNINGS** · no findings → **PASS**.

## Output

```
TEST QUALITY — <scope> · <stack from STACK.md>
──────────────────────────────────────────────
Files audited: <n> test files across <components> · mutation probe: run | skipped (<why>)

  severity  status  rule                  file:line               evidence → minimal fix
  HIGH      NEW     tq.mutation-survived  src/billing/refund.ts   flipped >= to > in applyRefund; 4 targeted tests stayed green → assert the boundary amount
  MEDIUM    KNOWN   tq.sleep-wait         tests/sync.test.ts:88   fixed 2000 ms setTimeout before assert → poll with waitFor

Smells: assertion-free 2 · mock-subject 0 · snapshot-only 1 · sleep-wait 3 · shared-state 0 ·
        disabled 5 (oldest 214d) · tautology 1 · broad-exception 2 · no-negative 3
Mutation: 5 targets → 4 killed · 1 survived (tree clean, restorations verified)
Ledger: 4 new · 8 known · 1 accepted · 0 regressed
Verdict: PASS | WARNINGS | FAIL — <reason>
```

## Quality checklist

- [ ] Scope stated (diff or full); every in-scope test file swept for all nine static smells
- [ ] Every finding verified at its `file:line` against the smell's true-positive criteria — no raw grep dumps; each names the lie (how the test passes while the code breaks) and a minimal fix
- [ ] Mutation probe only with `--mutation` plus an explicit user yes; clean tree verified first; one mutant at a time; targeted tests only; restoration verified per target, whole probe aborted on any restore failure
- [ ] Ledger updated and statuses annotated per the findings-ledger reference; acceptance only from the user
- [ ] Verdict derived from findings (HIGH → FAIL; MEDIUM/LOW → WARNINGS), accepted findings excluded from the math

## Handoff

**Chain:** not part of the default verify chain. When inserted explicitly, a FAIL verdict halts the chain — report and stop; WARNINGS continue with the findings restated at the commit gate.
**Solo:** weak or missing tests → `/cc:verify:test` to author real ones, then `/cc:verify:run` for the full gate; a quantity problem (untested code) → `/cc:verify:coverage`; a flaky wait worth root-causing → `/cc:verify:debug`; a structural test-suite refactor → `/cc:plan:task`.
**Abort rules:** no test files in any component → "not applicable", recommend `/cc:verify:coverage` + `/cc:verify:test`, stop. Suite currently red → static catalog only, skip the mutation probe (kill/survive means nothing on a failing baseline) — say so. Dirty tree with `--mutation` → static catalog only, report why the probe was skipped. Restore failure mid-probe → abort the probe entirely, report the exact file and state, touch nothing further.
