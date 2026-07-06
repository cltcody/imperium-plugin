---
description: Greenfield project inception — interview a fuzzy idea into an implementation-ready project charter. Use when starting a new project, "I have an idea for an app," or planning something new from scratch.
argument-hint: [project name or one-line idea — optional]
---

# Plan: Project — Greenfield Inception Interview

There is no codebase to analyze yet — the founder's head is the codebase. This command
runs a structured interview that turns a fuzzy idea into a **project charter**:
implementation-ready scope, users, success criteria, constraints, stack, and a first
slice that pastes directly into `/cc:plan:feature`. It precedes and seeds everything
else in greenfield PIV — `/cc:setup:project` scaffolds what this charter decides, and
slice 1 becomes the first feature-sized inner loop.

## Idea

$ARGUMENTS

## Steps

1. **Frame it.** If `$ARGUMENTS` gave a name or one-liner, restate it back in one
   sentence and confirm. If empty, ask for it directly. Then tell the user the shape
   of what's coming: roughly 10-15 questions, one at a time, ending in a written
   charter — not a form to fill out, a conversation.
2. **Run the ladder.** Follow
   `${CLAUDE_PLUGIN_ROOT}/references/dev/project-inception.md` stage by stage — problem,
   users & moment of use, success criteria, constraints, stack recommendation, MVP cut,
   non-goals. Honor its interview discipline throughout: one question at a time, reflect
   the answer back before advancing, apply each stage's sufficiency test (not a question
   quota), capture 2-3 verbatim quotes, offer the `grill-me` skill for any contested or
   wavering branch (stack choice, MVP cut, mobile-vs-web...), and if the budget runs past
   ~15 questions, stop climbing and tag every thin stage 🟡 in Open Questions rather than
   interrogating further.
3. **Stack recommendation.** At Stage 5, consult
   `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-profiles/` (nextjs, fastapi, django,
   expo-rn, generic-node, generic-python) and the reference's decision tree
   (shape → hosting reality → existing-stack gravity). This stage is a recommendation
   you make, not an interrogation — present the chosen stack with a one-line why and one
   rejected alternative, and ask only for confirmation.
4. **Write the charter** to `${user_config.workspace_dir}/plans/project-charter-<kebab-name>.md`
   using the reference's charter template exactly — every section required, a failed
   stage's section replaced by an honest 🟡 line (never omitted, never invented). Slice 1
   is marked as the first `plan:feature` candidate and must be paste-able as that
   command's argument alone. Charter confidence is `<n>/10` with justification: what's
   solid, what the residual risk is, which section carries it.
5. **Apply the stranger test** from the reference: could a developer with zero context
   read the charter alone and start slice 1's `plan:feature` without asking the founder
   anything? Any question the stranger would still have to ask names a failing ladder
   stage — revisit it before the charter is final, or (past budget) tag it 🟡 and say so
   in the confidence justification.

## Output

`${user_config.workspace_dir}/plans/project-charter-<kebab-name>.md` — then report the charter path
and a 5-line summary: the problem in one sentence, the primary user + moment of use,
the chosen stack, slice 1's name, and the charter confidence score.

## Quality checklist

- [ ] All seven ladder stages complete, or each incomplete stage explicitly tagged 🟡
- [ ] 2-3 verbatim user quotes captured in the Problem section
- [ ] Slice 1's name + scope paragraph + acceptance bullets are paste-able into
      `/cc:plan:feature` as its argument, alone, and would yield a coherent plan
- [ ] Stranger test run and named as passing (or its failing stage identified)
- [ ] Charter confidence given with justification, not just a number

## Handoff

**Chain:** when in a PIV chain, immediately invoke `/cc:setup:project` via the
SlashCommand tool to scaffold the repo, then `/cc:plan:feature <slice 1>` (or
`/cc:piv:ship "<slice 1>"` to run the full chain) — do not ask.
**Solo:** end by suggesting the same: `/cc:setup:project` to scaffold, then
`/cc:plan:feature <slice 1>` (or `/cc:piv:ship`).
**Abort rules:** the user can't answer Stage 1 or Stage 2 questions at all (no
concrete problem, no nameable user) → this isn't inception yet, it's idea exploration;
route to the `grill-me` skill and stop — do not force a charter out of a conversation
that hasn't found its problem. Charter confidence comes in below 7/10 → do not hand
off; surface the open questions and the failing stage instead.
