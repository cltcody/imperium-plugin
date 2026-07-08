---
description: Author tests for the changed code — detect the project's framework, cover the diff with happy-path, edge, and failure cases, and run them green
argument-hint: [optional path or area to focus on — defaults to the working diff]
disable-model-invocation: true
---

# Verify: Test — Author Tests for the Change

Write the tests the change is missing. This is the authoring counterpart to `/cc:verify:run` (which *runs* the suite) and to `/cc:verify:coverage` (which *analyzes* gaps but writes nothing): it produces new tests for the code you just wrote, then proves they pass. Use it right after `/cc:implement:execute`, or any time you say "add tests for this". It is **stack-agnostic** — the framework and test command come from the project's `STACK.md`, not from this file.

> **Scope:** for a project with a real test stack. This plugin repo ships markdown + manifests only — there is no unit-test framework here, so in *this* repo `/cc:verify:run` (the structure/audit gate) is the suite. Use this command in the downstream projects the dev commands drive.

## Steps

1. **Resolve the test stack.** Read the project's `STACK.md` and resolve each component's `test` step per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` (run from that component's `working_dir`). No `STACK.md` → detect the framework once from the project's markers and existing tests (e.g. `package.json` → jest/vitest, `pyproject.toml`/`pytest.ini` → pytest, `go test`, `cargo test`, `*_test.rb` → rspec) and recommend `/cc:setup:stack`. Match the **existing tests' style, directory, and naming** exactly; never introduce a second framework.
2. **Find what the diff left untested.** Diff against `main` (or the working tree) and list the changed functions/branches/modules. Cross-reference existing tests to find the gaps — prioritise new public behaviour and changed logic over untouched code.
3. **Write focused tests** for each gap: the happy path, the meaningful edge cases (empty/null, boundary, error input), and at least one failure mode per unit. Keep tests deterministic and isolated — no live network, no shared mutable state, no order dependence. Reuse the project's existing fixtures/factories/helpers.
4. **Run only the new/affected tests** with the resolved `test` command and iterate until green. If a new test reveals a real bug in the change, stop and report it — do **not** weaken the test to make it pass.
5. **Report change coverage** — which changed units are now covered, which are deliberately left (with a one-line reason), and the run result.

## Output

New/extended test files in the project's test location, plus a summary in the conversation:

```
TESTS ADDED
───────────
Framework:  <detected/resolved from STACK.md>
New tests:  <n> across <files>
Covered:    <changed units now under test>
Left:       <units intentionally uncovered + why>
Run:        ✅ PASS (<n> passed) / ❌ FAIL (<details>)
```

## Quality checklist

- [ ] Used the project's existing framework, style, and test directory — no new stack introduced
- [ ] Every changed public behaviour has at least a happy-path test
- [ ] Edge cases and one failure mode covered per non-trivial unit
- [ ] Tests are deterministic and isolated (no network, no order dependence)
- [ ] New tests run green — and any genuine bug they surfaced is reported, not silenced

## Handoff

**Chain:** when the new tests are green, immediately invoke `/cc:verify:run` with the SlashCommand tool to run the **full** suite (the new tests plus everything else) — do not ask.
**Solo:** after writing tests, suggest `/cc:verify:run` for the full gate, then `/cc:verify:code` to review the change including its tests. To find *where* tests are missing before authoring, run `/cc:verify:coverage` first.
**Abort rules:** if a new test exposes a real defect in the change, stop the chain and report it for a fix (route to `/cc:verify:debug` if the cause is unclear) — never edit the test to pass over a real bug. If no test framework is detected, stop and tell the user instead of scaffolding one unasked.
