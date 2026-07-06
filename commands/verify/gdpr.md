---
description: GDPR/privacy gate — scan the change-set for new personal-data processing, or run a full compliance assessment
argument-hint: [scope: diff|full]
disable-model-invocation: true
---

# Verify — GDPR / Privacy Check

Privacy gate for the PIV loop. In **diff** mode (default) it answers one question fast: does the current change-set introduce new personal-data processing, new third-party data flows, or PII in logs? In **full** mode it runs the complete `gdpr-check` skill and produces an officer-ready report. This is an **optional** gate — it is not part of the default `/cc:piv:loop` chain; run it when a change touches user data, adds a third-party integration or LLM call, or before a privacy-relevant release.

All output carries the caveat: engineering-level assessment to prepare the DPO conversation — not legal advice.

## Steps

1. **Resolve scope.** `$ARGUMENTS` = `full` → go to step 5. Otherwise default to `diff`.
2. **Collect the change-set.** `git diff HEAD` plus untracked files (`git status --short`); if the working tree is clean, diff against the merge base of the current branch and the default branch. If there is no diff at all, report that and stop.
3. **Quick scan** (delegate to the `gdpr-auditor` agent for large diffs, scoped to changed files only). Check the change-set for:
   - **New personal-data processing** — added schema fields, models, API params, or form inputs that are personal data (names, emails, phone, addresses, IDs, IP addresses, geolocation, device IDs); any new collection of special category data is automatically a GAP
   - **New third-party data flows** — added SDKs, outbound HTTP calls, analytics/error-tracking config, or LLM API calls that send personal data outside the application boundary; note recipient and hosting region, and whether an EU→US (or other third-country) transfer is implied
   - **PII in logs** — new or modified log/trace/error statements that emit emails, names, tokens, request bodies, or whole user objects (in this template: check the context fields passed to structlog calls)
   - **Removed safeguards** — deleted anonymisation, retention/deletion jobs, masking, or consent checks
4. **Rate findings** using the skill's scale: COMPLIANT / PARTIAL / GAP / NOT APPLICABLE per touched area; each PARTIAL or GAP gets evidence (file:line), the GDPR article, risk level, remediation, and S/M/L effort. Present a short summary in the conversation (no report file in diff mode). Done — go to Handoff.
5. **Full mode.** Invoke the `gdpr-check` skill on the whole project: data inventory → 11 assessment dimensions → DPIA screening → report to `${user_config.workspace_dir}/reports/gdpr/gdpr-report-YYYY-MM-DD.md` using the skill's `references/report-template.md`.

## Output

- **diff:** conversation summary — clean bill ("no new personal-data processing detected in this change-set") or rated findings with evidence and remediation.
- **full:** report at `${user_config.workspace_dir}/reports/gdpr/gdpr-report-YYYY-MM-DD.md` plus an executive summary and status dashboard in the conversation.

## Quality checklist

- [ ] Scope honoured: diff mode touched only the change-set; full mode covered the whole project
- [ ] Every finding has file:line evidence, a GDPR article reference, risk level, and S/M/L effort
- [ ] Unverifiable items (DPAs, ROPA coverage, lawful-basis decisions) flagged as DPO questions — never assumed compliant
- [ ] PII-in-log check explicitly performed on new/modified log statements
- [ ] Not-legal-advice caveat included in the output

## Handoff

**Chain:** this command is an OPTIONAL gate — not part of the default `/cc:piv:loop` chain. When it is invoked within a chain: a finding rated **GAP on lawful basis or on international transfers halts the chain** — stop, report the finding with evidence, and route the remediation to `/cc:plan:task`; do not proceed to `/cc:verify:execution-report` or the commit gate until the user decides. Any other result (COMPLIANT, PARTIAL, or GAPs on other dimensions): report findings and continue the chain to the next step — do not ask.
**Solo:** end by suggesting the user convert findings into `/cc:plan:task` (and, for broad exposure found in diff mode, a follow-up `/cc:verify:gdpr full`).
**Abort rules:** no git repository or empty diff in diff mode → report and stop, do not fabricate findings. New special-category data collection detected → treat as GAP, CRITICAL risk, and halt as above. If the codebase is too large to sweep confidently in full mode, narrow scope with the user instead of producing a shallow report.
