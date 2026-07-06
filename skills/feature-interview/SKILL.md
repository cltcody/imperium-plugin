---
name: feature-interview
description: |
  Lightweight feature-planning interview — one question at a time, no repo access needed —
  producing a structured Feature Brief that /cc:plan:feature turns into a full implementation
  plan in Claude Code. Built for chat surfaces where dev commands don't exist.
  Use on "I have a feature idea", "help me plan/spec a feature", or "feature brief".
---

# Feature Interview — Chat-Portable Planning Onramp

Interview the user about a single feature and distill the answers into a **Feature Brief** —
a structured, self-contained artifact that `/cc:plan:feature` can consume as its input in
Claude Code. This skill deliberately needs **no repository access**: everything that requires
reading code is captured as an explicit *verify-in-repo* item instead of guessed at.

**Scope boundaries** (route away early if these fit better):
- Whole new project or product idea → `/cc:plan:project` (greenfield charter interview)
- Stress-testing an existing plan or design → the `grill-me` skill
- Small, well-understood change → skip the interview; `/cc:plan:task` in Claude Code

**If you are running inside Claude Code with the repo available**, say so and offer to skip
straight to `/cc:plan:feature <feature description>` — the interview is the fallback for
surfaces without the command, not a required stage.

## Interview

Ask **one question at a time**, offer your recommended answer with each question, and skip
anything the user has already answered. Keep it to the minimum set that makes the brief
implementable — this is a lightweight interview, not an interrogation.

### Phase 1 — Frame
1. What problem does this solve, and for whom? (capture the user story:
   *As a `<user>` I want `<action>` so that `<benefit>`*)
2. What type of change is it — new capability, enhancement, refactor, bug fix — and roughly
   how big does it feel (small / medium / large)?
3. What does success look like? One observable outcome.

### Phase 2 — Scope
4. What is explicitly **in** the first version, and what is **out**? Push for the MVP cut.
5. Any hard constraints the code can't reveal — deadlines, compliance, platform,
   compatibility promises, performance targets?
6. What existing behavior, feature, or system does this touch or depend on (as far as the
   user knows)?

### Phase 3 — Behavior
7. Walk the happy path step by step: what does the user do, what does the system do?
8. What are the 2–3 edge cases or failure modes that matter most? What should happen in each?
9. Acceptance criteria: 3–7 verifiable statements ("given X, when Y, then Z" or checklist
   form) the implementation must satisfy.

### Phase 4 — Risks and unknowns
10. What is the user unsure about? Anything that depends on how the code currently works goes
    into **Verify in repo** — never guessed. Typical items: existing patterns to mirror,
    affected modules, migration needs, test conventions.

## Output — the Feature Brief

Produce a single markdown artifact:

```markdown
# Feature Brief: <name>
**Type:** <new capability | enhancement | refactor | bug fix> · **Size feel:** <S/M/L> · **Date:** <date>

## Problem & user story
## Success criteria
## Scope
### In  /  ### Out
## Constraints & dependencies
## Behavior
### Happy path  /  ### Edge cases
## Acceptance criteria
## Verify in repo (open questions for planning)
## Next step
Open Claude Code in the target repo and run:
/cc:plan:feature <paste this brief, or its saved path>
```

Every section is filled from interview answers only — mark anything unknown as unknown rather
than inventing it. Close by telling the user the brief is designed to be handed to
`/cc:plan:feature`, which will do the codebase research (patterns, file references, ordered
tasks, validation gates) that chat cannot.
