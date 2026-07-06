# AI Project Setup Patterns

> Distilled from imported course/workshop notes, 2026-07. Original synthesis for this
> plugin — no third-party text reproduced.

How to structure a codebase so coding agents (and humans) work fast in it: architecture
selection, vertical-slice rules, the seven pillars of AI-readiness, and validation-gate
design. Used by `/cc:plan:setup`, `/cc:plan:feature`, and `/cc:setup:stack` thinking.

---

## Why structure beats prompts

An agent's context window is a budget (see `context-engineering.md`), and architecture
determines how much of it goes to *navigation* instead of work. In a classic layered
codebase, understanding one feature means loading a controller, service, repository,
model, DTO, and route registration across six directories; in a feature-sliced
codebase it means loading one directory. Same model, roughly half the tokens per
change — compounding over hundreds of interactions. Teams that restructure routinely
report multi-x agent-productivity gains without touching a single prompt.

---

## Choosing an architecture

| Pattern | Agent-friendliness | Use when |
|---------|-------------------|----------|
| **Vertical Slice (VSA)** | Best — one directory per feature, full context isolation | Default for new apps and agent-heavy work |
| Feature folders | Good — like VSA, less strict | Transitioning from layers; heavy shared infra |
| Modular monolith | Moderate — clear module borders, but layers inside modules | >50K lines with strong discipline |
| Layered / clean | Poor — one feature scattered over 5–6 directories | Small apps, legacy you won't rewrite, compliance-mandated separation |
| Microservices | Poor — context fragmented across repos and network hops | Only when scaling genuinely requires it; then use VSA *inside* each service |
| Single file | Fine for <500-line throwaways, catastrophic after | True prototypes only |

Guidance: pick the simplest structure that solves the problem, but when a large share
of the agent's effort goes to hopping between layers, restructure — new features
first, old code as touched (strangler-fig, below).

---

## Vertical slice architecture: the rules

### Rule 1 — `core/` holds universal infrastructure

Config, logging, database connection, base exceptions, shared framework dependencies
(e.g. auth dependency providers). Test: *if every feature were deleted, would this
code still be required?* Build it first (config → logging → database → exceptions →
dependencies), then leave it alone.

### Rule 2 — `shared/` obeys the three-feature rule

Code moves to `shared/` only when a **third** feature needs it:

1. First feature: write it inline.
2. Second feature: duplicate it (comment the duplication).
3. Third feature: extract and refactor all three.

One use is feature-specific; two may be coincidence; three is a proven pattern.
Duplication in two places is cheaper than the wrong abstraction — and with agents,
duplication is cheaper than coupling generally. Superficially similar logic serving
different domains (price validation vs. quantity validation) stays separate.

### Rule 3 — features are self-contained slices

Each feature directory owns its `routes` → `service` → `repository` → `models` /
`schemas` / `exceptions`, its unit tests, and a short README (purpose, key flows,
business rules, integration points). Start with routes/service/schemas; add files as
needed. Build **outside-in**: define the API schemas first, then work inward.

### The messy 20% (cross-feature reality)

- **Cross-feature transactions**: an explicit orchestrating service (e.g. order
  creation coordinating products + inventory + orders) owns the transaction boundary —
  the whole flow traceable in one file.
- **Cross-feature reads**: feature A may *read* feature B's repository; it must
  **never write** B's tables. Document the dependency in both READMEs; use events for
  cross-feature writes (also the cure for circular imports).
- **Infra/logic splits**: cache client, feature-flag client, task-queue config live
  in `core/`; cache keys, flag checks, and task definitions live in the features.
- **Auth is dual-natured**: an `auth/` slice owns login/registration/user data;
  `core/dependencies.py` exposes the reusable `get_current_user` everyone consumes.
- **Tests**: unit tests co-located in the slice; integration tests (multi-feature) in
  a root `tests/`; e2e under `tests/e2e/`. Feature fixtures in the slice's conftest,
  shared fixtures at root.

A from-zero scaffold (init, tree, core infra, main, tooling, first slice, wire-up,
smoke test) is about an hour of work — the payoff is every subsequent feature knowing
exactly where it goes.

### Migration: strangler fig

Don't rewrite. All new features in slices; migrate old code only when a change touches
more than ~half of it; document the boundary in a `MIGRATION.md`; stop around 80% —
stable untouched code can stay in the old shape forever. Agents are good at the
mechanical part (moving files, fixing imports/tests) once you hand them the plan.

---

## The seven pillars of an AI-ready codebase

1. **Grep-ability.** Agents navigate by search; what can't be found gets
   hallucinated. Named exports only; explicit typed DTOs; dedicated error classes
   (`UserNotFoundError`, not bare `Error`); constants/enums instead of magic strings.
2. **Glob-ability.** Predictable placement: co-locate by feature; standardized file
   names (`service.py`, `schemas.py`, `types.ts`); tests next to code; absolute
   imports. The agent should *know* where auth logic lives without exploring.
3. **Boundaries as lint rules.** Agents don't respect implicit layering — encode it:
   import allow/deny lists (database layer can't import HTTP layer), explicit
   dependency injection, no hidden globals.
4. **Security as lint rules.** Hardcoded-secret detection, banned functions
   (`eval`/`exec`), enforced parameterized queries, input validation at the edge.
   Constraints the agent cannot forget because the gate enforces them.
5. **Testability — and the assertion problem.** Agents generate tests that pass,
   look plausible, and assert nonsense (they guess business logic from names:
   `SAVE20` "must be" 20% off). Two working defenses: *specify assertions in the
   prompt* ("SAVE20 gives 15%, discount never exceeds price"), and *review every
   assertion as guilty until proven correct* — the one review step you cannot
   delegate. Also: no network in unit tests; assert behavior, not implementation.
6. **Observability.** Structured JSON logs with a consistent event taxonomy —
   `{domain}.{component}.{action}_{state}` (`product.create_completed`,
   `agent.tool.execution_failed`) with standard states (`_started`, `_completed`,
   `_failed`, `_rejected`, `_retrying`); always carry `request_id`/`correlation_id`
   (issued by middleware) so one request is traceable across slices; log exceptions
   with full parseable tracebacks; include a `fix_suggestion` field in error logs.
   Grep-friendly by construction: `grep '_failed'`.
7. **Documentation as context.** Three tiers — root README (single source of truth:
   quick start, architecture, common commands), per-feature READMEs (flows, rules,
   integration points), and ADRs recording *why* decisions were made (without the
   why, an agent will "helpfully" reverse them). Distinguish **code docstrings**
   (for the developer/agent writing the app) from **tool docstrings** (read by the
   embedded agent at runtime — see `agent-design-patterns.md`). Explain every
   suppressed lint rule inline.

File-size discipline underpins all seven: target <300 lines per file (agents degrade
past ~400–500), one responsibility per file, minimal metaprogramming/"magic".

---

## Validation gates: green checks = done

The definition of done for agent work is *all gates pass*, not *the diff looks right*.
Gates turn linters and type checkers from passive review aids into an active feedback
loop: the agent writes, runs the gates, reads the errors, fixes, repeats — no human in
the loop until the grunt work is finished. Human review then spends itself on what
machines can't check: test assertions, security implications, architectural fit.

Gate design:

- **Ordered and cheap-first**: format/lint → typecheck → unit tests → integration →
  smoke (boot the app, hit health endpoints, verify request-ID headers) → summary
  report with per-gate pass/fail. In this plugin, the concrete commands per project
  resolve via `references/dev/stack-resolution.md`.
- **Errors must be actionable.** Agents fix what they can parse. (They are also bad
  at line numbers — when building custom tooling, present errors with their enclosing
  function/class rather than as bare line references.)
- **Dual type checking (Python)**: a pragmatic checker for fast iteration plus a
  strict one before merge catches variance/protocol issues the first one lets slide.
  Don't silence the strict checker with blanket "report nothing" settings — fix the
  types.
- **Adopt incrementally**: start with error/import lint rules and pre-commit hooks;
  add security and bug-detection rules next; annotations/docstring enforcement last.
  A gate set imposed all at once gets disabled; one grown weekly compounds.
- **Suppression audits**: periodically inventory every `# type: ignore`/`noqa`,
  explain why each exists, and recommend remove/keep/refactor with effort and risk —
  suppressions are debt with interest.

Without this infrastructure, agent-generated code *reduces* net velocity — the debt
arrives faster than the features. With it, quality is enforced systematically at
exactly the speed the agent works.

---

## Companion: the numbered convention files

`references/piv/01_core_principles.md` … `10_ai_instructions.md` are a compact
worked example of a Layer-1 rule set for a FastAPI + React project (verbose naming,
structured logging with fix suggestions, strict typing, mirrored tests, AI assistant
instructions). Use them as a seed when generating a project's CLAUDE.md — the
generation process itself is described in `context-engineering.md`.
