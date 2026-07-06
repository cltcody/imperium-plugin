---
description: Full branch review before merge — diff vs main, commit hygiene, breaking changes, validation, MERGE READY / NEEDS CHANGES verdict
argument-hint: [PR number/URL or base branch — defaults to main]
---

# PR Review

Review everything on the current branch before it merges: the complete diff against the base branch, commit hygiene, breaking changes, and a full validation run — ending in a clear MERGE READY / NEEDS CHANGES verdict. Broader than `/cc:verify:code` (which reviews only uncommitted work).

## Steps

1. **Get the full picture.** `$ARGUMENTS` is either a base branch (defaults to `main`) or a PR reference (number, URL, or branch). If it's a PR reference, resolve and check out the PR branch first, then review against its base:
   ```bash
   gh pr view <ref> --json number,title,body,author,headRefName,baseRefName,state,additions,deletions,changedFiles
   gh pr checkout <ref>
   ```
   Then capture the full diff (BASE = the PR's base, or `main`):
   ```bash
   git log BASE...HEAD --oneline --no-merges
   git diff --stat BASE...HEAD
   git diff BASE...HEAD
   ```
   Note commit count, file count, and total size. For each changed file note its type (handler, util, test, config) and whether it's new, modified, or deleted.

2. **Understand intent.** Read the linked spec in `docs/specs/`, plan in `${user_config.workspace_dir}/plans/`, the GitHub issue, or the PR description; otherwise infer from commits. State in one sentence what problem this branch solves before reviewing anything.

3. **Check commit hygiene.** Messages explain *why* and follow conventional commits; no fixup/WIP noise that should be squashed; no unrelated changes smuggled in; no secrets anywhere in `git log -p main...HEAD`.

4. **Review the diff** — read the full file for each non-trivial change, not just the hunks, and read a similar existing file to learn the expected pattern. For large branches (>15 files or >800 lines), delegate to the `code-reviewer` subagent with the conventions from `CLAUDE.md`. Rate findings per the canonical ladder in `${CLAUDE_PLUGIN_ROOT}/references/dev/severity-and-rubrics.md`; this command's markers map onto it as 🔴 BLOCKING = CRITICAL/HIGH, 🟡 WARNING = MEDIUM, 🟢 NOTE = LOW:

   **Completeness**
   - [ ] Code does what the commit messages claim; no obvious missing cases
   - [ ] Migration included if the schema changed
   - [ ] New routes/modules wired into the app entrypoint, per the project's conventions
   - [ ] `STACK.md` updated if components or services changed

   **Correctness**
   - [ ] Logic correct for all stated requirements
   - [ ] Edge cases handled: null, empty, zero, boundary values
   - [ ] No blocking sync calls in async context
   - [ ] Error paths return correct HTTP status codes

   **Type Safety**
   - [ ] All new functions/signatures annotated where the language supports it
   - [ ] No new type suppressions (`# type: ignore`, `# pyright: ignore`, `eslint-disable`,
         `# noqa`) without justification

   **Security** (severity by reachability per the ladder; reachable issues are CRITICAL/HIGH → 🔴 BLOCKING)
   - [ ] No secrets committed
   - [ ] Auth on protected routes
   - [ ] User input validated before use
   - [ ] No SQL string formatting

   **Tests**
   - [ ] New behaviour covered: happy path + at least one failure path
   - [ ] No existing tests deleted or weakened to pass

   **Breaking Changes** — each one named explicitly:
   - [ ] API/response shape changed? → all consumers must be updated
   - [ ] DB schema changed? → migration included
   - [ ] Env vars added? → `.env.example` (or equivalent) updated
   - [ ] Public interface changed? → callers notified

   **Code Quality**
   - [ ] Structured logging present
   - [ ] No dead code or debug statements
   - [ ] No cross-feature imports

5. **Check CI first** (if a PR exists) — `gh pr checks <ref>`. A red check is a hard block: NEEDS CHANGES regardless of local results. If checks are still pending, wait for them before issuing a verdict. Then run validation locally — never assume from CI badges. This step is **stack-agnostic**: resolve the concrete commands from the project's `STACK.md` per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`, or simply invoke `/cc:verify:run`. For each component, run these steps from its `working_dir`, skipping any the component does not map:

   ```
   smoke → test → typecheck → lint → format:check
   ```

   Run smoke first (fail-fast), then run all components and aggregate per-component results — do not stop at the first component's failure. If there is no `STACK.md`, auto-detect once from project markers and recommend the user run `/cc:setup:stack` to persist a manifest.

6. **Issue the verdict** using the report format below; if a PR exists, post it as a review (`gh pr review <ref> --approve|--request-changes --body ...`) or otherwise as a comment.

## Output

```
PR REVIEW
─────────
Branch: <name> vs <base> | Commits: N | Files: N | +A −D

SUMMARY: <one paragraph — what this branch does and why>
BREAKING CHANGES: <list or "none">
COMMIT HYGIENE: ✅ / ⚠️ <notes>

🔴 BLOCKING — file:line — description
🟡 WARNING  — file:line — description
🟢 NOTE     — file:line — description

Checks: CI ✅/❌/⏳ | per-component verify (from STACK.md):
  <component> (<pkg mgr>)  smoke ✅  test ✅  typecheck ✅  lint ✅  format ✅
  <component> (<pkg mgr>)  test ✅   typecheck ✅           (smoke, lint, format: unmapped)
Verdict: MERGE READY / NEEDS CHANGES
```

## Special cases

- **Draft PR** — review for direction, not polish; comment only, no verdict.
- **Large PR (>500 lines)** — note that thorough review may miss things and suggest splitting; favour architecture over line-level detail.
- **Missing tests** — name the specific cases that should exist; don't auto-block, but flag the risk.
- **Sensitive areas** — migrations (check reversibility), security code (extra scrutiny), config (check all environments).

## Quality checklist

- [ ] Whole branch diff reviewed, not just the latest commit
- [ ] Intent stated in one sentence before reviewing
- [ ] Breaking changes explicitly listed or ruled out
- [ ] Validation actually run, not assumed from CI badges
- [ ] Verdict is unambiguous, with every 🔴 item actionable

## Handoff

**Chain:** none — this command is standalone.
**Solo:** on MERGE READY with uncommitted fixes pending, suggest `/cc:release:commit`; otherwise suggest merging via `/cc:github:pr`. On NEEDS CHANGES, suggest `/cc:verify:code-review-fix` for the blocking findings.
**Abort rules:** branch has no commits beyond base → report "nothing to review" and stop. A 🔴 security finding, or a red GitHub CI check, means NEEDS CHANGES regardless of how green local validation is.
