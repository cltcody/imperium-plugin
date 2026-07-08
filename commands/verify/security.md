---
description: Security scan of the current change-set or the full repo — OWASP checks, severity-rated findings, PASS/WARNINGS/FAIL verdict
argument-hint: [scope: diff|full]
---

# Security Review

Scan for security issues introduced by the current work. Default scope is **diff** — the uncommitted changes and branch delta, checked against the dimensions most relevant to the change. Pass `full` for the complete audit. This command is **stack-agnostic**: dependency/CVE scanners and the components they run in come from the project's `STACK.md`, not from this file. The OWASP and code-pattern checks below are framework-neutral and apply broadly — framework-specific items (FastAPI, SQLAlchemy, Django, Express, …) are shown as **examples**, not the only stack.

## Steps

1. **Resolve scope (and the stack).** Read `STACK.md` first and resolve commands per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` — active components change the attack surface, and each component's `package_manager` and `working_dir` drive the dependency scan in step 2. No `STACK.md` → auto-detect components once and recommend `/cc:setup:stack`.
   - `diff` (default, and always the mode inside a verify chain): collect `git diff` (unstaged + staged) plus `git diff main...HEAD`. If the combined diff is empty, report "nothing to scan" and hand off.
   - `full`: invoke the **security-audit** skill and follow its workflow end-to-end (full-repo scope, all dimensions, officer-ready report to `${user_config.workspace_dir}/reports/security/`). Skip steps 2–3 below.

2. **Detect what the diff touches** — scan only relevant dimensions (a markdown-only diff gets secrets and supply-chain checks, not appsec noise). Map the grep patterns below to the languages and frameworks the diff actually touches (per the resolved component's `language`); the examples are illustrative, not exhaustive. **Scan the change-relevant dimensions**, delegating deep checks to the `security-auditor` subagent where useful:

   **Secrets & credentials** — hardcoded passwords, API keys, tokens, or secrets assigned to string literals in source (skip tests, comments, hashing/settings reads). Example greps:
   ```bash
   grep -rn "password\s*=\|secret\s*=\|api_key\s*=\|token\s*=\s*['\"]" <source dirs> | grep -v "test\|#\|hash\|check\|settings"
   git log --all --full-history -- "**/.env" "**/*.env"   # .env never committed
   ```
   No secrets in compose/CI/config files; new files that should be gitignored.

   **Injection (SQL / command / template)** — string-built queries or shell calls with user input instead of parameterized queries / safe APIs. All DB access via an ORM or parameterized queries — zero raw queries with user input. Example greps:
   ```bash
   grep -rn "execute.*f\"\|execute.*%\|text(\|os.system\|subprocess.*shell=True" <source dirs>
   ```

   **Authentication & authorization** — new endpoints/routes have auth checks; session/JWT secret from env, a safe algorithm (never `none`), expiry set; password hashing via `bcrypt`/`argon2`/`scrypt`, never `md5`/`sha1`/plain. Example grep (adapt the route decorator/registration idiom to the framework):
   ```bash
   grep -rn "<route decorator or registration>" <source dirs> -A 3 | grep -v "<auth dependency>\|health\|__"
   ```

   **Input validation** — all inputs go through a schema/validation layer; no raw request body/params parsed directly in handlers. Example grep:
   ```bash
   grep -rn "request.body\|request.json\|request.form\|req.body" <source dirs>
   ```

   **CORS** — read the app's CORS/middleware config: `allow_origins` not `*` in production; never `*` together with credentials enabled; configured per-environment.

   **Sensitive data in logs & error leakage** — secrets/PII never logged; stack traces only in logs, never in HTTP responses. Example greps:
   ```bash
   grep -rn "log" <source dirs> | grep -i "password\|token\|secret\|card\|ssn"
   grep -rn "traceback\|exc_info\|stack" <source dirs> | grep -v "log"
   ```

   **Rate limiting** — login/auth, password reset, and user-content endpoints throttled. Grep for the project's rate-limit middleware/decorator; none on sensitive endpoints → flag as missing.

   **Dependency & supply chain** — new/changed dependencies (pinned? lockfile updated? install scripts?), CI workflow changes (action pinning, `permissions:` scope). **Run the dependency/CVE scanner chosen per component's `package_manager`** from that component's `working_dir`: `uv`/`pip`/`poetry` → `pip-audit`; `npm` → `npm audit`; `pnpm` → `pnpm audit`; `yarn` → `yarn audit` (prefer a scanner already installed). Skip components whose package manager has no mapped scanner. If no scanner can run, record the gap explicitly — never imply "clean". Deep audit via `/cc:verify:dependencies`.

   **File upload** (if in scope) — max size enforced; type validated by magic bytes, not extension; stored outside web root; never executed.

   **Prompt-injection surface** (if AI features in scope) — new prompts, skills, or agent instructions consuming untrusted content without instruction/data separation or guards.

3. **Rate every finding** per the canonical ladder in `${CLAUDE_PLUGIN_ROOT}/references/dev/severity-and-rubrics.md` — reachability decides severity (a pattern-match hit that untrusted input cannot reach is MEDIUM at most), and INFO is this command's audit-only observation level. Each finding carries `file:line`, impact, concrete fix, and S/M/L effort. Report honest "no finding" per dimension scanned — never invent issues. **Defensive only: never produce exploit code.**

## Output

- **Diff scope:** an inline findings summary — per-dimension status (CLEARED / findings listed), severity-sorted finding list, and a verdict line. No file is written unless findings exist at HIGH+ — then also append them to `${user_config.workspace_dir}/reports/security/security-report-YYYY-MM-DD.md`.
- **Full scope:** the complete report at `${user_config.workspace_dir}/reports/security/security-report-YYYY-MM-DD.md` per the security-audit skill.

```
SECURITY REVIEW
───────────────
Severity per ${CLAUDE_PLUGIN_ROOT}/references/dev/severity-and-rubrics.md
(🔴 CRITICAL · 🟠 HIGH · 🟡 MEDIUM · 🟢 LOW · ℹ️ INFO — audit-only observation level)

[severity] Category — file:line — description — recommended fix — effort S/M/L

Dimensions: secrets ✅ | injection ✅ | authz ✅ | input ✅ | CORS ✅ | logs ✅ | rate-limit ⚠️ | deps ✅
Verdict: PASS | PASS WITH WARNINGS | FAIL (CRITICAL)
```

Fix all 🔴 and 🟠 before any deployment. Never ship a 🔴.

## Quality checklist

- [ ] Scope explicitly stated (diff vs full) and the diff actually collected, not assumed
- [ ] Only change-relevant dimensions scanned; skipped dimensions named with reason
- [ ] Dependency scan run per component's `package_manager` from its `working_dir`; unmapped/unavailable scanners recorded, never implied clean
- [ ] Every finding has severity, `file:line`, impact, concrete fix, and effort
- [ ] Honest "no finding" per clean dimension — nothing invented
- [ ] No exploit code or payloads produced
- [ ] Verdict line printed (PASS / PASS WITH WARNINGS / FAIL)

## Handoff

**Chain:** if any finding is **CRITICAL**, halt the chain — print the finding(s) and the verdict `FAIL (CRITICAL)`, recommend immediate remediation (offer `/cc:plan:task` per finding), and do NOT invoke the next command. Otherwise (PASS or PASS WITH WARNINGS), immediately invoke `/cc:verify:design` with the SlashCommand tool — do not ask. HIGH findings do not halt the chain but MUST be restated at the commit gate.
**Solo:** suggest `/cc:verify:design` for a product change (UX/AI/systems review), or `/cc:verify:execution-report` to summarize the work, or the full **security-audit** skill (`scope: full`) when the user needs an officer-ready clearance report with gap analysis and remediation backlog. Privacy/personal-data concerns → the **gdpr-check** skill.
**Abort rules:** CRITICAL finding → stop and report (never proceed to commit). Scan tooling unavailable (e.g. the component's CVE scanner offline) → continue with remaining dimensions and record the gap explicitly. Empty diff in chain mode → state "nothing to scan" and continue to `/cc:verify:design`.
