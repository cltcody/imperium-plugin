---
description: Convert a PRD into a technical specification with module breakdown, contracts, data model, and a slice-by-slice delivery order
argument-hint: [prd-name or path to docs/prd/<name>.md]
---

# Spec

Turn a PRD into a technical specification for work that spans **multiple features or slices**: module breakdown, contracts, data model, and an ordered delivery plan that each slice can be planned and shipped from independently. A single self-contained feature does not need this — take it straight to `/cc:plan:feature`.

## Steps

1. **Load the PRD.** Read `docs/prd/<name>.md` (or the path/pasted content given). If no PRD exists and the request is more than one slice of work, suggest `/cc:plan:prd` first. If it is genuinely a single feature, redirect to `/cc:plan:feature` and stop.
2. **Analyse the existing codebase.** Detect the stack from manifests and read the most similar existing feature/module to extract the patterns in use (layering, naming, error handling, test layout). The spec must extend existing conventions, not invent parallel ones. In this template that means the vertical-slice layout under `app/<feature>/` (models / schemas / routes / service / repository / exceptions / constants / types / tests) and the patterns in `reference/patterns/`.
3. **Design the module/component breakdown.** For each module: responsibility, public interface, dependencies on other modules, and which existing code it touches. Call out shared infrastructure that must exist before feature slices can build on it.
4. **Define contracts — where applicable to the stack:**
   - **API contracts:** per endpoint — method + path, request/response schemas (field, type, required/optional), error cases with status codes, auth requirements.
   - **Internal contracts:** function/service interfaces between modules, event/message shapes, CLI surfaces — whatever boundaries the architecture has.
5. **Define the data model and migration notes.** New entities/tables (fields, types, indexes, relations), changes to existing ones, and for each schema change: is a migration needed, is it backward compatible, what is the rollback story. Reference `/cc:implement:migrate` as the execution path for schema work.
6. **Order the slices.** Break the work into delivery slices, each independently shippable and verifiable. For each slice: scope, depends-on, and what it unblocks. Explicitly mark which slices can run in parallel (e.g. independent modules, frontend vs backend of the same feature) and where they merge.
7. **Collect open questions.** Anything unresolved goes in an Open Questions section, each marked **blocking** (must be answered before its slice starts) or **non-blocking** (note an assumption and proceed).
8. **Write and confirm.** Save the spec, present the slice order and open questions, and get the user's confirmation before any slice planning begins.

## Output

`docs/specs/<name>.md` containing:

```markdown
# Spec: <Name>
**PRD:** docs/prd/<name>.md | **Status:** Draft/Approved | **Created:** YYYY-MM-DD

## Module breakdown        ← responsibilities, interfaces, dependencies
## Contracts               ← API/internal contracts incl. error cases
## Data model & migrations ← schema changes, compatibility, rollback notes
## Delivery order          ← slices with depends-on / unblocks / parallel-with
## Open questions          ← blocking vs non-blocking, assumptions stated
```

## Quality checklist

- [ ] Every PRD requirement maps to at least one slice (no orphaned requirements)
- [ ] Contracts cover error cases, not just the happy path
- [ ] Every schema change has a migration note and a rollback story
- [ ] Slice order has no circular dependencies; parallel slices are genuinely independent
- [ ] Spec follows existing codebase patterns (cited from real files, not invented)
- [ ] Blocking open questions are flagged, not buried

## Handoff

**Chain:** once the spec is confirmed and the first slice has no blocking open questions, immediately invoke `/cc:plan:feature` for the **first slice** using the SlashCommand tool — pass it the spec path and slice name; do not ask. Subsequent slices return here for their turn in the delivery order.
**Solo:** suggest `/cc:plan:feature` for the first slice, naming it explicitly.
**Abort rules:** blocking open questions remain unanswered → surface them to the user and stop; never plan a slice on top of an unresolved blocking question. PRD contradicts existing architecture in a way the spec cannot reconcile → present the conflict and options instead of choosing silently.
