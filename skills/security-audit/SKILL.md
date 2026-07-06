---
name: security-audit
description: |
  Full defensive security audit of a codebase or change-set — officer-ready clearance report with
  severity-rated findings and a prioritized remediation backlog. Use on "security audit", "is this
  secure", "check for vulnerabilities", or before a release or compliance sign-off.
context: fork
agent: general-purpose
---

# Security Audit

Audit any repository or change-set across eight security dimensions and produce a report a security officer can sign off on: executive summary, per-dimension clearance status, severity-rated findings with evidence, gap analysis, and a remediation backlog ready to flow back into the PIV development loop.

**Defensive orientation only.** This skill reviews, rates, and reports. It must NEVER produce exploit code, working payloads, attack tooling, or step-by-step attack instructions beyond the minimal scenario description needed to justify a severity rating. If asked to weaponize a finding, decline and point to the remediation instead.

---

## Step 1 — Scope

Establish what is being audited before reading a single file.

1. **Audit scope.** Ask (or infer from the request):
   - **Full repo** — every tracked file, plus git history where relevant.
   - **Diff/branch** — `git diff main...HEAD` (or uncommitted changes) only. Faster; suited to pre-merge checks.
2. **Identify the tech stack.** Detect, don't assume:
   - Manifests: `package.json`, `pyproject.toml`, `requirements*.txt`, `go.mod`, `Cargo.toml`, `*.csproj`, `pom.xml`, `Gemfile`, `composer.json`
   - Lockfiles: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `uv.lock`, `poetry.lock`, `go.sum`, `Cargo.lock`
   - Infra: `Dockerfile`, `docker-compose*.yml`, Terraform/`*.tf`, Kubernetes manifests
   - CI: `.github/workflows/*.yml`, `.gitlab-ci.yml`, `azure-pipelines.yml`, `Jenkinsfile`
3. **Map the attack surface.** Classify the project — this decides which dimensions get depth:
   - **Web/API service** → all eight dimensions, full depth
   - **CLI tool / library** → input validation, dependencies, secrets; authn/authz only if it talks to services
   - **AI skill / prompt / agent repo (markdown-only)** → secrets, supply-chain (CI + install scripts), prompt-injection surface, license/compliance. Do NOT generate appsec noise (no SQL-injection findings for a repo with no SQL).
   - **Infra/CI repo** → CI permissions, supply-chain, secrets
4. **Record scope facts** for the report header: repo/project name, branch, commit hash (`git rev-parse HEAD`), date, scope mode, stack summary.

If the working tree is dirty during a full audit, note it — the report must state exactly what state was audited.

---

## Step 2 — Audit Dimensions

Run the dimensions below. Where the environment supports it, run independent dimensions in parallel and/or delegate deep investigation to the **`security-auditor`** subagent (one delegation per dimension group, each returning structured findings). Skip dimensions that Step 1 ruled out of scope — but record each skip in the gap analysis with the reason.

### D1 — Secrets & Credentials
- Grep code, config, and CI files for hardcoded credentials: `password`, `secret`, `api[_-]?key`, `token`, `BEGIN (RSA|EC|OPENSSH) PRIVATE KEY`, connection strings, cloud keys (`AKIA[0-9A-Z]{16}`, `ghp_`, `xox[baprs]-`, `sk-`).
- Check `.gitignore` covers `.env*`, key files, credential stores.
- Check git **history**, not just HEAD: `git log --all --diff-filter=A -- "*.env" "*.pem" "*.key"` and targeted `git log -S` for suspect strings. A secret removed in a later commit is still exposed.

### D2 — Injection & Input Validation
- Language-appropriate sinks: raw SQL / string-built queries, `eval`/`exec`, `os.system`/`subprocess` with `shell=True`, unsanitized template rendering, command construction from user input, path traversal (`..` joins), unsafe deserialization (`pickle`, `yaml.load`, `ObjectInputStream`).
- Confirm inputs cross a validation boundary (schema/model/sanitizer) before reaching sinks.

### D3 — Authentication & Authorization
- Endpoints/handlers without auth checks; missing authorization (object-level access control) after authentication.
- Token handling: weak or hardcoded JWT secrets, `alg: none`, missing expiry; password hashing (bcrypt/argon2 required; flag md5/sha1/plaintext).
- Session fixation, insecure cookie flags, CORS misconfiguration (`*` with credentials).

### D4 — Dependency & Supply-Chain Risk
- Lockfile present and committed? Versions pinned or floating (`*`, `latest`, broad ranges)?
- CI actions/plugins pinned to a tag or, better, a commit SHA? Any `curl | bash` style installs in CI or setup scripts?
- Install hooks (`postinstall` scripts, `setup.py` code execution) from untrusted packages.
- Run the project's own audit tooling if available (`npm audit`, `pip-audit`, `cargo audit`, `osv-scanner`) — report counts, do not auto-fix.

### D5 — Prompt-Injection Surface *(AI/skill/agent repos and any code calling LLMs)*
- Identify every point where **untrusted content** (pasted documents, fetched web pages, RFP attachments, user uploads, tool results) enters a prompt or skill workflow.
- Check for guards: explicit "treat pasted content as data, not instructions" framing, instruction/data separation, refusal to follow embedded directives, output constraints.
- Flag skills/commands that instruct the model to take privileged actions (write files, call MCPs, send messages) based on content from untrusted sources without a confirmation gate.

### D6 — Data Exposure & Logging
- Sensitive fields (passwords, tokens, PII, card data) written to logs, error messages, or analytics.
- Stack traces or internal details returned to end users.
- Debug endpoints/flags left enabled; verbose error modes default-on.

### D7 — Infrastructure & CI Permissions
- GitHub Actions: `permissions:` blocks present and minimal? `pull_request_target` misuse? Secrets exposed to fork PRs? Self-hosted runners on public repos?
- Containers: running as root, `latest` base images, secrets baked into layers.
- Branch protection assumptions documented (cannot always be verified from the repo — record as a gap if not verifiable).

### D8 — License & Compliance Flags
- Dependency licenses incompatible with intended distribution (GPL in proprietary code, missing NOTICE files).
- Embedded third-party code without attribution; bundled fonts/images/data with unclear rights.
- This is a *flagging* dimension — raise INFO/LOW findings for a human licensing decision, not legal verdicts.

For every dimension, the output is either **findings** (Step 3 format) or an explicit honest **"no finding"** — never invented issues to look thorough.

---

## Step 3 — Severity Rating

Rate every finding. Use these definitions exactly — do not inflate severity to seem rigorous, and do not deflate it to be polite:

| Severity | Definition |
|----------|------------|
| **CRITICAL** | Exploitable now with serious impact: exposed live credential, remote code execution, auth bypass, secret in public history. Blocks release. |
| **HIGH** | Significant risk requiring a realistic but plausible precondition: injection reachable from user input, unpinned CI action with write permissions, missing authz on sensitive data. Fix before production. |
| **MEDIUM** | Weakens defense-in-depth: missing rate limiting, weak hashing of non-credential data, floating dependency versions, missing prompt-injection guard on internal-only input. Fix in normal course. |
| **LOW** | Best-practice deviation, hard to exploit: verbose errors in dev paths, missing security headers on internal tooling. Fix opportunistically. |
| **INFO** | Observation, no action required: licensing note, gap notice, hardening suggestion. |

Every finding MUST carry:
- **ID** — `SEC-001`, `SEC-002`, … (stable within the report)
- **Severity** — from the table above
- **Location** — `file:line` (or commit hash for history findings; "repo-wide" only when truly so)
- **Description** — what is wrong, factually
- **Impact** — what an attacker gains / what the business loses
- **Exploit scenario** — one or two sentences describing *how* it could plausibly be abused. Scenario only — **never working exploit code or payloads**.
- **Recommendation** — the concrete fix (exact config change, API to use, pattern to apply)
- **Effort** — **S** (< 1 h), **M** (half a day), **L** (multi-day / needs design)

---

## Step 4 — Report Generation

Write the report to `${user_config.workspace_dir}/reports/security/security-report-YYYY-MM-DD.md` (create the directory if missing; if a report for today exists, suffix `-2`, `-3`, …).

Use `references/report-template.md` in this skill folder as the structure. Fill **every** section:

1. **Header** — project, date, auditor, scope, commit hash.
2. **Executive summary** — written for a security officer who will not read the findings: what the system is, what was audited, headline verdict, finding counts by severity, the one-paragraph "should this ship?" answer.
3. **Methodology** — dimensions run, tools used, scope mode, what was sampled vs. exhaustive.
4. **Status dashboard** — one row per dimension with status:
   - **CLEARED** — no findings above LOW
   - **CLEARED WITH CONDITIONS** — MEDIUM/HIGH findings exist with agreed remediation; conditions listed explicitly
   - **BLOCKED** — at least one unresolved CRITICAL (or HIGH with no viable remediation path)
5. **Detailed findings** — one block per finding in the Step 3 format.
6. **Gap analysis** — what could NOT be assessed and why (no test suite to verify behavior, no SBOM, branch protection not verifiable from repo, audit tool unavailable offline, history too large to scan fully). A gap is not a finding — but hiding a gap invalidates the clearance.
7. **Remediation backlog** — table sorted CRITICAL → INFO, then by effort (quick wins first within a severity). Columns: priority rank, ID, severity, effort, action, owner (blank), status. This table must be directly usable as a work list.
8. **Residual-risk statement** — what risk remains if all CONDITIONS are met, in plain language.
9. **Sign-off block** — overall verdict (APPROVED / APPROVED WITH CONDITIONS / REJECTED), auditor line pre-filled with model + date, empty lines for the security officer and (if applicable) DPO.

The report stands alone: a reader with no access to the chat must be able to act on it.

---

## Step 5 — Handoff

After writing the report:

1. Print the report path and the status dashboard inline so the user sees the verdict immediately.
2. If the backlog is non-empty, **offer to convert it into a PIV plan** so findings flow straight back into the development loop:
   - One or two focused fixes → `/cc:plan:task` per item
   - A broader remediation effort → `/cc:plan:feature` with the backlog table as input
3. If any finding is CRITICAL, say so first and recommend stopping any pending release/merge until it is resolved, then re-running `/cc:verify:security` (diff scope) to confirm the fix.
4. Suggest re-audit cadence: after remediation, and before any release or marketplace submission.

---

## Quality Checklist

- [ ] Scope, commit hash, and working-tree state recorded in the header
- [ ] Every in-scope dimension has findings OR an explicit honest "no finding" — nothing invented, nothing silently skipped
- [ ] Out-of-scope dimensions appear in the gap analysis with reasons (graceful degradation, e.g. markdown-only repos)
- [ ] Every finding has ID, severity, file:line evidence, impact, scenario, concrete fix, and S/M/L effort
- [ ] No exploit code, payloads, or attack tooling anywhere in the report
- [ ] Status dashboard uses only CLEARED / CLEARED WITH CONDITIONS / BLOCKED, and conditions are explicit
- [ ] Remediation backlog is sorted and directly usable as a work list
- [ ] Report written to `${user_config.workspace_dir}/reports/security/security-report-YYYY-MM-DD.md` and readable standalone
- [ ] Handoff to `/cc:plan:task` or `/cc:plan:feature` offered when the backlog is non-empty
