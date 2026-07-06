# {Project Name} — Security Audit Report

**Classification:** Internal — Security Review
**Prepared for:** {Security officer / team, e.g. Information Security}
**Author:** {Auditor name} (audit executed by Claude Code, {model id})
**Date:** {YYYY-MM-DD}
**Scope:** {Full repository | Diff: {base}...{head} | Uncommitted changes}
**Commit:** `{full commit hash}` {— note if working tree was dirty}
**Branch:** `{branch}`

**Verdict: {APPROVED | APPROVED WITH CONDITIONS | REJECTED}{ — one-line qualifier, e.g. "cleared for release once SEC-001 and SEC-003 are resolved"}**

---

## Executive Summary

{2–4 paragraphs, written for a security officer who will not read the detailed findings:}

{Paragraph 1 — What this system is: purpose, tech stack, attack surface class (web service / CLI / AI-skill repo / infra). What data it touches and who uses it.}

{Paragraph 2 — What was audited: scope mode, dimensions covered, dimensions excluded and why (see Gap Analysis).}

{Paragraph 3 — Headline result: overall verdict, what blocks or conditions it, what is already sound.}

**Finding counts:**

| CRITICAL | HIGH | MEDIUM | LOW | INFO |
|:--------:|:----:|:------:|:---:|:----:|
| {n} | {n} | {n} | {n} | {n} |

**Bottom line:** {One paragraph: should this ship / merge / be distributed, under what conditions, and by when the conditions must be met.}

---

## Methodology

- **Scope mode:** {full repo | diff} — {file count / diff size}
- **Dimensions assessed:** {list of D1–D8 actually run}
- **Dimensions excluded:** {list, with one-line reason each — also captured in Gap Analysis}
- **Tools & techniques:** {e.g. pattern search (grep) across source and config; git history inspection; dependency audit via {npm audit / pip-audit / none available}; manual review of CI workflows and auth paths; delegation to `security-auditor` subagent for {dimensions}}
- **Coverage notes:** {what was exhaustive vs. sampled, e.g. "all CI workflows reviewed in full; source grep patterns are heuristic and complement, not replace, manual review of auth code"}
- **Standards referenced:** {e.g. OWASP Top 10 (2021), OWASP LLM Top 10, CIS GitHub benchmark — as applicable}

---

## Status Dashboard

| # | Dimension | Status | Findings | Conditions / Notes |
|---|-----------|--------|----------|--------------------|
| D1 | Secrets & credentials | {CLEARED / CLEARED WITH CONDITIONS / BLOCKED} | {IDs or "none"} | {conditions, or "—"} |
| D2 | Injection & input validation | {…} | {…} | {…} |
| D3 | Authentication & authorization | {…} | {…} | {…} |
| D4 | Dependency & supply chain | {…} | {…} | {…} |
| D5 | Prompt-injection surface | {…} | {…} | {…} |
| D6 | Data exposure & logging | {…} | {…} | {…} |
| D7 | Infrastructure & CI permissions | {…} | {…} | {…} |
| D8 | License & compliance | {…} | {…} | {…} |

**Status definitions:**
- **CLEARED** — no findings above LOW in this dimension.
- **CLEARED WITH CONDITIONS** — MEDIUM/HIGH findings exist; clearance holds only if the listed conditions are met by the stated deadline.
- **BLOCKED** — at least one unresolved CRITICAL finding (or HIGH with no viable remediation). Release/distribution must not proceed.
- **NOT ASSESSED** — out of scope or not assessable; reason recorded in Gap Analysis. Not a clearance.

---

## Detailed Findings

{One block per finding. Order: CRITICAL → HIGH → MEDIUM → LOW → INFO. If a dimension produced no findings, do not pad — the dashboard already says CLEARED. Delete this placeholder block in the final report.}

### SEC-{NNN} — {Short title}

| Field | Value |
|-------|-------|
| **Severity** | {CRITICAL / HIGH / MEDIUM / LOW / INFO} |
| **Dimension** | {D1–D8 name} |
| **Location** | `{file}:{line}` {or commit `{hash}` for history findings} |
| **Status** | {OPEN / RESOLVED — {date, commit} / ACCEPTED RISK — {approver}} |

**Description:** {What is wrong, factually, with the evidence quoted or referenced.}

**Impact:** {What an attacker gains or what the business loses if exploited.}

**Exploit scenario:** {1–2 sentences describing how this could plausibly be abused. Scenario only — no exploit code, no payloads.}

**Recommendation:** {The concrete fix — exact config change, API/pattern to use, guard to add.}

**Effort:** {S (< 1 h) / M (half a day) / L (multi-day or needs design)}

---

## Gap Analysis

{What could NOT be assessed and why. A gap is not a finding — but an unstated gap invalidates the clearance. Examples: no test suite to verify auth behavior dynamically; no SBOM, so transitive dependency licensing unverified; branch protection and org settings not verifiable from repository contents; dependency audit tool unavailable in offline environment; git history truncated by shallow clone.}

| # | Area not assessed | Reason | Risk if unaddressed | Suggested follow-up |
|---|-------------------|--------|---------------------|---------------------|
| G1 | {…} | {…} | {…} | {…} |
| G2 | {…} | {…} | {…} | {…} |

---

## Remediation Backlog

{Sorted by severity (CRITICAL first), then by effort within each severity (quick wins first). This table is the work list — each row should be directly convertible into a /cc:plan:task item.}

| Priority | ID | Severity | Effort | Action | Owner | Status |
|----------|-----|----------|--------|--------|-------|--------|
| 1 | SEC-{NNN} | {CRITICAL} | {S} | {Imperative one-liner, e.g. "Rotate the exposed credential at `config/settings.py:14` and purge it from git history"} | | OPEN |
| 2 | SEC-{NNN} | {HIGH} | {M} | {…} | | OPEN |
| … | … | … | … | … | | … |

**Conversion:** run `/cc:plan:task` per item, or `/cc:plan:feature` with this table as input for a consolidated remediation effort.

---

## Residual-Risk Statement

{Plain-language statement of what risk remains assuming all conditions in the dashboard are met and the backlog above is executed. Include: risks accepted by design (with who accepts them), risks deferred (with revisit date), and the recommended re-audit trigger (e.g. "re-run /cc:verify:security on every release branch; full re-audit after the auth refactor or in 6 months, whichever is sooner").}

---

## Sign-Off

> {Summary sentence pattern: "All assessed dimensions are {CLEARED / CLEARED WITH CONDITIONS as listed above}. {N} findings were identified, of which {n} are resolved and {n} remain open in the remediation backlog with agreed effort estimates. Gaps in assessment are documented above. The system is {approved / approved with conditions / not approved} for {release / merge / distribution}."}

| Role | Name | Decision | Date |
|------|------|----------|------|
| Auditor (author) | {Auditor name} | {APPROVED / APPROVED WITH CONDITIONS / REJECTED} | {YYYY-MM-DD} |
| Security Officer | | | |
| DPO (if personal data in scope) | | | |

**Conditions of approval (if any):**
1. {Condition, owner, deadline}
2. {…}

---

*Audited with Claude Code ({model id}) against repository state at commit `{hash}` on {date}. This report is a technical security assessment; it does not constitute legal advice. No exploit code was produced during this audit.*
