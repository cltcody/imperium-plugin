---
name: gdpr-check
description: |
  GDPR compliance assessment of a project or feature — officer-ready report with status dashboard,
  gap analysis, and prioritised remediation backlog. Use on "GDPR check", "privacy review",
  "DPIA", or whether a feature processes personal data lawfully.
context: fork
agent: general-purpose
---

# GDPR Check — Privacy Compliance Review

Assess a project or feature against the GDPR from an engineering standpoint: discover what personal data it actually processes (in code, schemas, configs, and logs), evaluate it across the core compliance dimensions, rate each dimension, and write a report a DPO or GDPR officer can act on — including what could *not* be assessed from code alone.

**Caveat that MUST appear in every output:** this is an engineering-level assessment designed to PREPARE the conversation with the DPO/GDPR officer. It is not legal advice and does not replace a formal legal review or a DPO sign-off.

---

## Step 1 — Scope & data inventory

Establish what is being assessed and what personal data is in play. Do not rely on documentation claims — verify against the actual codebase.

1. **Define scope.** Whole project, a feature, or a change-set? Record the scope and the current commit hash (`git rev-parse --short HEAD`) — the report is a snapshot of that state.
2. **Discover personal data.** Scan code, database schemas, migrations, API contracts, config files, and log statements for personal-data fields. For a large codebase, delegate this sweep to the `gdpr-auditor` subagent. Look for at least:
   - Direct identifiers: names, email addresses, phone numbers, postal addresses, usernames, national/customer/employee IDs
   - Online identifiers: IP addresses, device IDs, cookies, session tokens tied to a person, tracking pixels
   - Indirect/derived data: geolocation, behavioural analytics, telemetry, free-text fields that may contain personal data
   - Authentication artefacts: password hashes, OAuth tokens, biometric data
3. **Identify data subjects.** Who do these fields describe — customers, end users, employees, prospects, children?
4. **Map data flows.** Where does personal data go beyond the application boundary: third-party services and SDKs, LLM APIs (Anthropic, OpenAI, Azure OpenAI, etc.), analytics and error-tracking platforms (e.g. Google Analytics, Sentry, Datadog), email/SMS providers, cloud storage, data warehouses. Note the hosting region of each recipient.
5. **Build the data inventory table** (data element / category / source / storage location / retention / recipients) using the structure in `references/report-template.md`. Mark every cell you could not verify as `UNKNOWN` — unknowns feed the gap analysis, never guesses.

If the project processes **no personal data at all** (verified, not assumed), say so explicitly, produce a short report stating the evidence, and stop after Step 5.

## Step 2 — Assessment dimensions

Assess each dimension below against the evidence gathered in Step 1. For deep code-level scans (log hygiene, retention logic, third-party calls), delegate to the `gdpr-auditor` subagent and consolidate its structured findings. Ground every claim in a file/line, config value, or an explicit "not assessable from code".

| # | Dimension | Key questions | Primary articles |
|---|-----------|---------------|------------------|
| 1 | Lawful basis & purpose limitation | Is there an identifiable lawful basis per processing purpose? Is data reused beyond its original purpose (e.g. production data in test/analytics/LLM prompts)? | Art. 5(1)(b), 6 |
| 2 | Data minimisation | Are fields collected that no feature uses? Are full records passed where a subset would do (APIs, LLM prompts, exports)? | Art. 5(1)(c) |
| 3 | Storage limitation & retention | Are there retention periods and deletion/anonymisation jobs in code or config — or does data live forever? Backups included? | Art. 5(1)(e), 17 |
| 4 | International transfers | Does personal data leave the EU/EEA (US-hosted SaaS, LLM APIs, CDNs)? Is each transfer covered by an adequacy decision, the EU–US Data Privacy Framework, or SCCs? | Art. 44–49 |
| 5 | Processor relationships & DPAs | Is every third party receiving personal data a known processor with a DPA — including AI providers (Anthropic, OpenAI)? Are model inputs contractually excluded from training? | Art. 28 |
| 6 | Data subject rights support | Can the data model actually deliver access, rectification, erasure, portability, and objection? Is erasure feasible (foreign keys, event logs, caches, backups, third-party copies)? | Art. 12–22 |
| 7 | Special category data | Any health, biometric, political, religious, sexual-orientation, or trade-union data — including free-text fields that could carry it? If so, which Art. 9(2) condition applies? | Art. 9 |
| 8 | Privacy by design & default | Are privacy-protective defaults in place (opt-in not opt-out, minimal scopes, pseudonymisation, field-level encryption for sensitive data)? | Art. 25 |
| 9 | Records of processing (ROPA) impact | Does this project introduce a new processing activity, a new data category, or a new recipient that the organisation's ROPA must reflect? | Art. 30 |
| 10 | Breach-notification readiness | Would the team detect a personal-data breach (alerting, audit logs)? Is there a path to assess and report within 72 hours? | Art. 33–34 |
| 11 | Logging & telemetry hygiene | Do log statements, error reports, or traces emit PII (emails, tokens, request bodies)? This is the classic engineering finding — check log calls, middleware, and APM config explicitly. | Art. 5(1)(c)(f), 32 |

## Step 3 — DPIA screening

Determine whether a Data Protection Impact Assessment is **indicated** (Art. 35). Flag it — do not write a full DPIA unless the user explicitly asks.

Screening criteria (two or more usually means a DPIA is required; one may suffice):

- Systematic and extensive profiling or automated decision-making with significant effects
- Large-scale processing of special category data or criminal-offence data
- Systematic monitoring of publicly accessible areas or of users at scale
- New technologies applied to personal data (including novel AI/LLM processing of personal data)
- Matching/combining datasets, processing data of vulnerable subjects (e.g. children), or processing that prevents subjects from exercising rights

Record the screening result as: **DPIA indicated** / **DPIA not indicated** / **Cannot determine from code** — with the criteria that fired.

## Step 4 — Status rating

Rate every dimension from Step 2:

- **COMPLIANT** — evidence shows the requirement is met
- **PARTIAL** — mechanisms exist but with verified gaps
- **GAP** — requirement is not met, or a violation is in the code
- **NOT APPLICABLE** — dimension does not apply (state why)

For each PARTIAL or GAP, create a finding with an ID (`GDPR-001`, `GDPR-002`, …) containing: status, the relevant GDPR article(s), concrete evidence (file:line, config key, schema field), risk level (CRITICAL / HIGH / MEDIUM / LOW), a concrete remediation action, and an effort estimate (**S** < 1 day, **M** 1–3 days, **L** > 3 days). Anything not assessable from code (contracts, DPAs, organisational measures, the org's ROPA) goes in the gap analysis as an open question for the DPO — never rated COMPLIANT on assumption.

## Step 5 — Report generation

Write the report to `${user_config.workspace_dir}/reports/gdpr/gdpr-report-YYYY-MM-DD.md` (create the directory if needed) using `references/report-template.md`. It must contain:

1. Header — project, date, assessor, scope, commit hash
2. Executive summary written for a DPO/GDPR officer: what the system does, what personal data it processes, overall posture, the 3–5 things that need attention first
3. Data inventory table and processing-activity summary
4. Status dashboard — one row per dimension with status and finding IDs
5. Detailed findings (`GDPR-001` format)
6. DPIA screening result
7. Gap analysis — what could not be assessed from code and which questions to put to the DPO/legal
8. Remediation backlog ordered by priority (risk first, then effort)
9. Sign-off block with the cleared / cleared with conditions / blocked decision left for the DPO
10. The engineering-assessment / not-legal-advice caveat

## Step 6 — Handoff

Present the executive summary and the dashboard in the conversation, link the report file, and then offer next steps:

- **Remediate:** offer to convert the remediation backlog (or its top items) into a PIV plan via `/cc:plan:task`, so the fixes flow back into the development loop (plan → `/cc:implement:execute` → `/cc:verify:run`).
- **Escalate:** remind the user to take the report to the DPO/GDPR officer for the formal decision — the sign-off block is theirs to fill.
- **Re-check:** after remediation, suggest re-running the check (or `/cc:verify:gdpr` in diff mode for the fix itself) to update statuses.

---

## Quality checklist

- [ ] Data inventory is built from verified code/schema/config evidence — unknown cells say `UNKNOWN`, not a guess
- [ ] Every PARTIAL/GAP finding has an ID, article reference, file-level evidence, risk level, remediation, and S/M/L effort
- [ ] All 11 dimensions rated; NOT APPLICABLE always carries a reason
- [ ] Items not assessable from code appear in the gap analysis as DPO questions — never assumed COMPLIANT
- [ ] DPIA screening result recorded with the criteria that fired
- [ ] Report written to `${user_config.workspace_dir}/reports/gdpr/gdpr-report-YYYY-MM-DD.md` with commit hash and sign-off block
- [ ] The not-legal-advice caveat appears in the report and in the conversation summary
- [ ] Handoff to `/cc:plan:task` offered for the remediation backlog
