---
description: Write a product requirements document through structured questioning
argument-hint: [feature-or-product-name]
---

# Plan: PRD — Product Requirements Document

Define WHAT to build and WHY before any technical planning. The PRD captures problem, users, scope, and success criteria; `/cc:plan:feature` turns it into HOW. Use for features large enough to have users, scope decisions, and risks — skip to `/cc:plan:task` for small changes. Be problem-first and hypothesis-driven: start with the problem, demand evidence before committing to a solution, and prioritize ruthlessly. **Never invent plausible-sounding requirements to fill a section** — if you lack the information, write `TBD — needs user research` and flag it as an open question rather than guessing.

## Steps

1. **Load context.** If not primed, read `CLAUDE.md` and skim the project structure. Check `docs/prd/` for related PRDs and `${user_config.workspace_dir}/plans/` for related plans. In this template, also read `STACK.md` (active services) and `${user_config.workspace_dir}/context/decisions.md` (architectural constraints).
2. **Harvest the conversation.** Extract requirements already discussed so you only ask what is still unknown.
3. **Ask structured questions** — in batches, waiting for answers:
   - **Problem:** What problem does this solve, and for whom? What is the current workaround? Why now?
   - **Users:** Who are the primary users? What is the user journey, trigger to outcome?
   - **Scope:** The 3 things this MUST do (in scope). What is explicitly NOT being built (out of scope)? What does success look like, measurably?
   - **Constraints & risks:** Technical constraints or dependencies? Deadlines or phasing? Top 2–3 risks?
4. **Write the PRD** to `docs/prd/<kebab-name>.md` (create the directory if needed) using this template:

```markdown
# PRD: <Feature Name>

**Status:** Draft | Review | Approved
**Created:** YYYY-MM-DD
**Owner:** <name>

---

## Executive Summary
<2-3 sentences: what this is, who it's for, why it matters now.>

## Problem Statement
<What problem this solves and for whom. 2-3 sentences. Include current workaround if any, and the cost of not solving it.>

## Evidence
- <User quote, data point, or observation that proves this problem is real.>
- <If none exists: "Assumption — needs validation" and add to Open Questions.>

## Key Hypothesis
We believe <this capability> will <solve this problem> for <these users>.
We'll know we're right when <measurable outcome>.

## Target Users
| User Type | Description | Primary Need |
|-----------|-------------|--------------|
| <type>    | <who they are> | <what they need> |

## MVP Scope
### In Scope
- <feature/behavior that WILL be built>
### Out of Scope (v1)
- <what we are explicitly NOT building now / deferred>

## User Stories
**As a** <user type> **I want to** <action> **So that** <outcome>
(repeat for each major user story — aim for 3-5)

## Acceptance Criteria
- [ ] <specific, testable criterion>
- [ ] <specific, testable criterion>

## Core Architecture & Patterns
<Which existing patterns this follows — vertical slice, repository pattern, etc.
Reference `reference/patterns/` and `${user_config.workspace_dir}/context/decisions.md`.>

## Technology Stack
<Only what is relevant to this feature — don't repeat the full stack.>

## Security & Configuration
- Authentication required: yes / no
- New env vars needed: <list or "none">
- Sensitive data handled: <describe or "none">
- Rate limiting needed: yes / no

## API Specification (high-level)
| Method | Path | Description |
|--------|------|-------------|
| POST   | /... | ...         |
<Full contract goes in the spec (`/cc:plan:spec`). This is overview only.>

## Success Metrics
- <how we measure success — quantitative target if possible>

## Implementation Phases
| Phase | Scope | Deliverable |
|-------|-------|-------------|
| 1     | <what's built first> | <what can be tested/demoed> |

## Future Considerations
<What comes after v1 — not committed, just recorded. 3-5 bullets.>

## Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| <risk> | Low/Med/High | Low/Med/High | <how we address it> |

## Dependencies
- <other features or services this depends on>

## Open Questions
- <unresolved decisions — answer before technical planning>
```

5. **State assumptions.** List every assumption made where answers were missing, and confirm with the user.

## Output

`docs/prd/<kebab-name>.md` — a reviewed PRD with no unanswered Open Questions blocking the next phase. Then summarize Problem → Solution → primary metric, list any open questions still needing answers, and point to the next step.

## Optional: HTML companion (`--html` flag)

If `$ARGUMENTS` contains the literal token `--html`, **also** write a self-contained HTML companion at the same path with a `.html` extension (same base name); otherwise generate markdown only.

- Single file, zero external dependencies — works offline. No external markdown parser.
- Dark default with `html[data-theme="light"]` override; header theme toggle (float right); preference in `localStorage['theme']`, applied before first paint.
- Save-bar with a File System Access API connect button, status, and save-now; auto-save on an 800ms debounce, a final save on `pagehide`, and a Firefox `alert()` fallback.
- `SAVED_STATE` sentinel — exactly one line: `const SAVED_STATE = null; // @@SAVED_STATE@@` (auto-save does a regex replacement of this line).
- `<header>` — PRD title, status/date badges, theme toggle. Body typography: `font-size: 15px`, `line-height: 1.7`, `max-width: 760px`.
- **Interactive — Key Hypothesis**: single "Mark as Validated ✓" checkbox; when checked the section gets a green border + tinted background. State key `hypothesis_validated`.
- **Interactive — In-scope MVP items**: each a checkbox row; checking marks it "implemented" (green tint + check). State key `scope_{n}`. Out-of-scope items are static (constraints, not tasks).
- **Interactive — Open Questions**: each a checkbox row; checking applies `text-decoration: line-through` and a "resolved" badge. State key `q_{n}`.
- All other content is read-only. Render fenced code as `<pre><code>` on `var(--surface)`; tables as `<table>` with `border-collapse: collapse` and `var(--border)` cell borders.

## Quality checklist

- [ ] Problem and target users are concrete, not generic
- [ ] Problem is evidenced, not assumed (or the gap is flagged as an open question)
- [ ] Out-of-scope list is explicit — scope cannot silently grow
- [ ] Every acceptance criterion is testable
- [ ] Success metrics are measurable
- [ ] Assumptions flagged and confirmed; open questions resolved or owned
- [ ] A skeptic could read this and understand why it's worth building

## Handoff

**Chain:** when in a PIV chain, immediately invoke `/cc:plan:feature` referencing this PRD via the SlashCommand tool — do not ask.
**Solo:** end by suggesting `/cc:plan:feature docs/prd/<name>.md` to produce the implementation plan, or `/cc:plan:spec` first if the work spans multiple features/slices.
**Abort rules:** if the user cannot articulate the problem or users, stop — a PRD built on guesses produces a plan built on guesses. Capture what is known as a draft and list the blocking questions.
