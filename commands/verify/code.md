---
description: Technical code review of uncommitted or branch changes, with severity-rated findings saved to ${user_config.workspace_dir}/code-reviews/
argument-hint: [scope, e.g. "uncommitted" (default) or "branch"]
---

# Review Changed Code

Review changed code for real bugs — logic errors, security issues, performance problems, quality and architecture violations — and save a findings report with severity ratings. This reviews the code, not the process; it runs after `/cc:verify:run` passes and before anything is committed. It is **stack-agnostic**: the language- and framework-specific checks below adapt to whatever the project's `STACK.md` declares.

## Review Philosophy

- Simplicity is the ultimate sophistication — every line should justify its existence.
- Code is read far more often than it's written — optimize for readability.
- The best code is often the code you don't write; elegance comes from clarity of intent and economy of expression.

## Steps

1. **Establish scope.** Default is uncommitted work: `git status`, `git diff HEAD`, `git diff --stat HEAD`, plus new files via `git ls-files --others --exclude-standard`. If `$ARGUMENTS` says "branch", diff against main instead (`git diff main...HEAD`).

2. **Gather conventions and resolve the stack.** Skim `CLAUDE.md`, `README.md`, any standards under `docs/`, and `${user_config.workspace_dir}/agents/reviewer.md` so the review judges against *this* project's patterns (e.g. vertical slices, strict typing, structured logging), not generic taste. Read the project's `STACK.md` and resolve its components per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` so the checklist below is interpreted in the project's actual language(s), frameworks, and idioms (the right type-suppression syntax, the validation/ORM/logging conventions, the migration tool). If there is no `STACK.md`, auto-detect once from project markers and recommend the user run `/cc:setup:stack` to persist a manifest.

3. **Delegate the heavy review to the `code-reviewer` agent.** Launch it with the Agent tool, passing: the diff scope, the list of changed/new files, the conventions from step 2, and the resolved stack (so it applies the checklist in the project's idioms). Instruct it to read each changed file in its entirety — not just the diff — and analyze against this checklist, mapping each language-specific item to the component's actual language/framework:

   **Correctness**
   - Logic matches the stated requirement
   - Edge cases handled: null, empty, zero, boundary values; no off-by-one errors
   - No incorrect conditionals or race conditions
   - No blocking synchronous calls inside async/concurrent code
   - Error paths handled; appropriate status codes / error results returned

   **Type Safety**
   - All new functions/exports have type annotations (where the language supports them)
   - No new type-suppression directives (e.g. `# type: ignore`, `# pyright: ignore`, `eslint-disable`, `@ts-ignore`) added without justification — match the syntax to the component's language
   - No untyped escape hatches introduced (e.g. `Any`, `any`, unchecked casts)

   **Security** (severity per the canonical ladder — reachability decides, see below)
   - No secrets, credentials, or API keys in code
   - User input validated before use (via the project's validation layer)
   - Protected endpoints/handlers have auth checks
   - No string-built / interpolated SQL queries (injection); no XSS or insecure data handling

   **Performance**
   - No N+1 queries
   - No inefficient algorithms or unnecessary computations
   - No obvious memory leaks

   **Code Quality**
   - Structured logging present per the project's convention (e.g. `_started` / `_completed` / `_failed` lifecycle events)
   - No swallowed exceptions (bare catch / catch-and-ignore)
   - No dead code, unused imports, or debug prints/console statements
   - No DRY violations; functions not overly complex; names are clear
   - Tests cover at least happy path + one failure case

   **Architecture**
   - Respects the project's module boundaries (e.g. no cross-feature imports under a vertical-slice rule)
   - New shared code justified (3+ features will use it)
   - New route/module/handler wired into the app entrypoint where the framework requires it
   - Migration created (via the project's migration tool) if the schema changed

   Severity levels, evidence bars, and verdict semantics come from the canonical ladder in `${CLAUDE_PLUGIN_ROOT}/references/dev/severity-and-rubrics.md` — hold the agent's findings to that bar (no HIGH+ without a concrete failure scenario; security severity by reachability, not category).

4. **Verify findings are real.** Spot-check the subagent's findings: where cheap to do so, reproduce the concern by running the relevant `test` step for the affected component, resolved from `STACK.md` per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` (run from that component's `working_dir`; skip if the component does not map `test`). Drop anything speculative. Focus on real bugs, not style nits.

5. **Write the report** to `${user_config.workspace_dir}/code-reviews/<kebab-name>.md` (named after the feature/branch). Each finding:

   ```
   severity: CRITICAL | HIGH | MEDIUM | LOW
   file: path/to/file
   line: 42
   issue: one-line description
   detail: why this is a problem
   suggestion: how to fix it
   ```

   Include a stats header (files modified/added/deleted, lines +/-). If nothing is found, write "Code review passed. No technical issues detected."

## Output

`${user_config.workspace_dir}/code-reviews/<name>.md` — stats, then findings sorted by severity with `file:line` references, plus a one-line verdict echoed in the conversation:

```
Verdict: CLEAN / FINDINGS (X critical, Y high, Z medium/low)
```

**Exemplar:** match the shape and bar of `${CLAUDE_PLUGIN_ROOT}/references/dev/exemplars/code-review-exemplar.md` — not its content.

## Quality checklist

- [ ] Every changed and new file was reviewed in full, not just the diff
- [ ] Every finding has severity, `file:line`, and a concrete fix suggestion (the finding anatomy in `${CLAUDE_PLUGIN_ROOT}/references/dev/severity-and-rubrics.md`)
- [ ] Severities match the canonical ladder — reachable security issues rated CRITICAL/HIGH; downgrades carry stated reasoning
- [ ] Findings verified against actual code, no speculation
- [ ] Report saved to `${user_config.workspace_dir}/code-reviews/` even when clean

## Handoff

**Chain:** if the report contains any findings, immediately invoke `/cc:verify:code-review-fix` with the report path — the fix → re-validate cycle runs at most 2 times per chain; findings persisting after that stop the chain. If clean, immediately invoke `/cc:verify:security`. Do not ask.
**Solo:** suggest `/cc:verify:code-review-fix` (findings exist) or `/cc:verify:security` (clean), then `/cc:release:commit` once clean.
**Abort rules:** a CRITICAL finding that cannot be auto-fixed safely (e.g. leaked credential already pushed, fundamental design flaw) stops the chain — report it to the user and wait. If the diff is empty, report "nothing to review" and stop.
