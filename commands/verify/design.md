---
description: Architecture review of the change — UX, AI design, and cross-system seams — via relevance-gated parallel heads, findings saved by severity
argument-hint: [diff-range | optional]
---

# Verify: Design — Architecture Review

Review the change-set for the dimensions the code reviewer doesn't own:
**user experience, AI/LLM design, and cross-system architecture.** Only the
heads relevant to the diff run; the rest report N/A. One synthesized review, not
three dumps.

## Steps

1. **Scope.** Establish the diff (`git diff main...HEAD` or the working tree, as `/cc:verify:code` does).
2. **Decide heads.** Apply the relevance rule per head; state which run and which are N/A and why:
   - `ux-reviewer` — user-facing surface in diff (`*.tsx/.jsx/.vue/.svelte/.html/.css`, `components/ views/ pages/ templates/ ui/`, view-rendering handlers, CLI copy, prose/markdown copy shipped to end users — internal engineering docs/changelogs don't count)
   - `ai-architect` — AI/LLM/prompt/embedding/agent/rag content in diff **source/config** files (matches inside docs/markdown don't count)
   - `systems-architect` — cross-service / migration / schema / contract change in diff
3. **Fan out.** Launch the in-scope agents **in parallel** — emit multiple Agent calls in a single turn — passing the diff scope and changed-file list.
4. **Synthesize.** Merge into one severity-ranked review; list skipped heads as `N/A — <reason>`.
5. **Save.** Write to `${user_config.workspace_dir}/code-reviews/<slug>-design.md`; append any LOW findings to `${user_config.workspace_dir}/code-reviews/backlog.md` (`OPEN | file:line | issue | <this-review>`).

## Output

The merged review in-conversation and saved file: a per-head status line (ran / N/A), then findings sorted by severity with `file:line`, then a verdict — APPROVE / APPROVE WITH FIXES / REQUEST CHANGES / BLOCK (CRITICAL).

## Quality checklist

- [ ] Relevance decision shown for all three heads (run or N/A + reason)
- [ ] In-scope heads launched in parallel, not sequentially
- [ ] Every finding has `file:line` evidence and a concrete scenario
- [ ] One merged, severity-ranked review; LOWs appended to the backlog
- [ ] No findings invented for an out-of-scope head

## Handoff

**Chain:** runs after `/cc:verify:security`. On completion, immediately invoke `/cc:verify:execution-report` with the SlashCommand tool — do not ask. Any CRITICAL finding → STOP and report; CRITICAL/HIGH → `/cc:verify:code-review-fix` first (within the chain's max-2 fix→re-validate budget), then proceed to `/cc:verify:execution-report`. On an infra-only repo with no user-facing prose in the diff all heads are N/A — a clean no-op; proceed straight to `/cc:verify:execution-report`.
**Solo:** suggest after `/cc:verify:code` / `/cc:verify:security` for product changes; suggest the `architecture-board` skill before a deploy.
**Abort rules:** BLOCK (CRITICAL) halts the chain until fixed; an empty diff → report "nothing to review" and stop.
