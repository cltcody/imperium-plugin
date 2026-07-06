# Context Engineering for Coding Agents

> Distilled from imported course/workshop notes, 2026-07. Original synthesis for this
> plugin — no third-party text reproduced.

How to decide what an agent sees, when it sees it, and what it never sees. Companion
to `piv-methodology.md` (the loop that consumes this context) and
`ai-project-setup-patterns.md` (structuring the codebase itself to be cheap to load).

---

## The budget model

Treat every context window as a **budget**. The failure mode of unmanaged context is
not a hard error — it's gradual: a long window degrades recall ("needle in a
haystack"), the agent stops honoring early instructions, and it wanders. Almost every
runaway coding-agent session traces back to context mismanagement, not model quality.

Two consequences:

- **Spend deliberately.** Load what the current task needs; actively exclude the rest.
  Telling an agent what *not* to read is as valuable as telling it what to read.
- **Prefer artifacts over conversation.** Long-lived state belongs in files (plans,
  reports, rules), not in chat history. A fresh window plus a good file beats a stale
  window every time.

---

## The three-layer context model

| Layer | What | Loaded | Size discipline |
|-------|------|--------|-----------------|
| 1. Global rules | CLAUDE.md / AGENTS.md — non-negotiable conventions | Always, every session | 100–500 lines hard cap |
| 2. On-demand references | Task-type guides (`reference/api_guide.md`, `frontend_component_guide.md`, …) | Deterministically, when working on that area | 50–200 lines each |
| 3. Task plans | One implementation plan per feature | For exactly one loop, then archived | Everything the task needs, nothing else |

The layers have different lifetimes: Layer 1 changes rarely (via the meta-loop, see
`piv-methodology.md`), Layer 2 grows as the project grows areas, Layer 3 is disposable.

---

## Layer 1: global rules that actually work

A useful CLAUDE.md covers, in roughly this order:

1. **Core principles** — the 3–6 non-negotiables (naming, type safety, logging,
   documentation). Each phrased as an enforceable rule, not a value statement.
2. **Tech stack** — frameworks, language versions, package manager, lint/format
   tooling, with version numbers.
3. **Architecture** — folder organization, layer/slice pattern, where tests live.
4. **Code style** — naming conventions per language, docstring format, with short
   real examples from the codebase.
5. **Logging** — structure, what to log, one backend and one frontend example.
6. **Testing** — framework, file naming/mirroring convention, how to run.
7. **API contracts** — how backend models and frontend types stay in sync (full-stack
   projects).
8. **Common patterns** — 2–3 template-grade code examples used throughout.
9. **Development commands** — install / dev / test / lint, per component.
10. **AI assistant instructions** — ~10 bullets: read existing code first, match
    conventions, run linters before finishing, never sacrifice clarity for brevity.

Writing rules:

- **Under 500 lines.** Past that, rules stop being read reliably and start costing
  budget on every session. Push detail into Layer 2 guides.
- **Specific beats generic.** "Use intention-revealing names: `product_id`, not `id`"
  is a rule; "write clean code" is noise.
- **Show, don't tell** — small real examples outperform prose.
- **Generate, then curate.** For an existing project: have the agent read the config
  manifests, folder tree, and 3–5 representative files, then extract the conventions
  *actually in use*. For a new project: answer its clarifying questions (project type,
  domain, scale, stack preferences), let it research current best practices, then trim.

An `AGENTS.md` is only worth keeping if it contains agent-operational notes that don't
belong in the README; if the two would be identical, keep one source of truth.

---

## Layer 2: on-demand reference guides

A reference guide is a 50–200 line, code-heavy recipe for **one recurring task type**:
building an API endpoint, adding an agent tool, creating a migration, writing a React
component. Structure:

1. Title + one-line "use this when".
2. Overall pattern (folder sketch or diagram, 2–3 sentences).
3. 3–6 numbered steps, each with a real code example and its 3–5 rules.
4. A closing checklist (`- [ ]` items) including validation steps.

Rules of the genre:

- One task type per guide. General principles belong in Layer 1 — never duplicated.
- Real code from this codebase, not placeholders.
- **Deterministic loading**: the guide is named in the command or prime that needs it
  ("read `reference/api_guide.md` before implementing endpoints"), or loaded manually
  before the work starts. This differs from progressive disclosure — you are choosing
  the context, not hoping the agent discovers it.

---

## Prime commands, general and specialized

The **general prime** (structure + docs + key files + git state) works for small and
mid-size codebases. It stops scaling when the codebase does: priming an enterprise
repo "in general" either blows the budget or produces a uselessly shallow summary.

**Specialized primes** fix this. Each is a prime command scoped to a slice of the
system — `prime-frontend`, `prime-tools`, `prime-billing` — and each specifies:

- which directories and guides to read,
- which files matter most in that area,
- and explicitly **what to skip** (don't read the schema docs when priming frontend
  auth work).

You, the developer, know which area the next feature touches; encode that knowledge
as the prime selection. On very large codebases this is the single highest-leverage
context technique.

---

## Memory between sessions

Options, in order of preference:

1. **Git log as memory.** Disciplined commit messages (one per verified PIV loop) form
   a free, always-current history. Primes should read the recent log; planning can
   query it ("what did we change around X recently?").
2. **Changelog / progress file.** A maintained `CHANGELOG.md` or PRD with checked-off
   phases tells the agent what exists and what's next. Useful when commit history is
   noisy.
3. **Native session memory** — see "Native memory & caching" below. This plugin's own
   `session.md` cursor (`/cc:pause` / `/cc:prime --resume`) and cross-machine store
   (`memory-sync.sh` / `handoff`) are the in-house implementation of this option.
4. **External memory stores** (memory MCPs, task managers). Powerful but heavier;
   worth it once multiple agents or people share the state, or the state needs to span
   *projects* rather than one repo (see Phase E note below). Not built into this plugin
   today — evaluate case by case.

All are viable; the anti-pattern is relying on the agent to "remember" a previous
conversation. It can't — persist or lose it.

**A future cross-project option (not built):** a third-party memory MCP (e.g.
basic-memory) could give GTM/sales skills (`account-intelligence`, `champion-health`,
`win-loss-analyzer`) a real knowledge graph spanning multiple accounts/deals across
repos — something flat per-project markdown can't do well. This is deliberately
deferred: it's a new dependency (a local MCP server + SQLite index) that would overlap
with `memory-sync.sh`'s job unless scoped tightly to cross-project sales memory only.
Revisit when a concrete cross-account need arises; don't add it speculatively.

---

## Native memory & caching (2026)

Claude Code ships native mechanisms that cover part of the "memory between sessions"
problem out of the box. This plugin should lean on them rather than re-invent them:

- **Auto memory.** Claude writes its own notes to
  `~/.claude/projects/<project>/memory/MEMORY.md` (+ topic files) as a session
  progresses. Only the first ~200 lines / 25KB of `MEMORY.md` load at session start;
  topic files load on demand — so keep it curated, same discipline as Layer 1's
  500-line cap. Toggle with the `/memory` command or the `autoMemoryEnabled` setting.
  Subagents can carry their own auto memory too (distinct from the `memory: project`
  frontmatter lever below — see `model-routing.md`).
- **`memory-sync.sh` is the transport, auto-memory is the writer.** `global/scripts/memory-sync.sh`
  already symlinks each machine's `~/.claude/projects/<encoded-path>/memory/` directory
  into a shared private git store — which is the *exact same directory* native
  auto-memory writes to. Nothing new needs building here: link a project once
  (`memory-sync.sh link`) and native auto-memory notes ride the existing
  `SessionStart`-pull / `SessionEnd`-push hooks across machines for free. `handoff`
  (`global/skills/handoff/SKILL.md`) is the complementary "manual, narrative" memory —
  use it when you want a curated summary instead of whatever auto-memory happened to
  jot down.
- **`/compact` + microcompaction.** `/compact` summarizes older turns when the context
  window fills; microcompaction offloads bulky tool outputs to disk earlier,
  retrievable by path, before a full compaction is needed. Both are automatic/manual
  native behavior — nothing to configure.
- **`PreCompact` hook.** Fires just before compaction runs (manual or auto). This
  plugin uses it for a safety-net session cursor — see `pre-compact-snapshot.py` in
  `global/hooks/` — so a compaction event never silently erases "where am I" state.
- **Prompt caching.** Claude Code caches its own sessions' stable prefix (system
  prompt, tool definitions, CLAUDE.md) automatically — nothing a plugin author
  configures directly. The one lever command/skill authors *do* control: keep static
  instructions first in a command body and put volatile/dynamic content (large file
  dumps, `!`-executed shell output) last, so the stable prefix stays maximally reusable
  across turns instead of being interrupted by content that changes every run.

---

## Subagents as context firewalls

Research is context-expensive: exploring a codebase or reading docs pollutes the main
window with hundreds of file dumps. Delegate it:

- Spawn subagents for codebase analysis and external research (they can run in
  parallel — the tasks are independent).
- Each subagent burns its *own* window and returns a **concise summary** to the
  parent. The parent keeps only conclusions.
- Same principle inside multi-agent systems: sub-workers write summaries to shared
  state, never full transcripts (see `agent-design-patterns.md`).

The plan document is the ultimate application: an entire research phase distilled
into one file, consumed by a fresh implementation window.

---

## The strategy checklist

For any nontrivial session, you should be able to point at each of these:

- [ ] Plan-as-artifact: the task's full context distilled into a single document
- [ ] Concise global rules (≤500 lines), detail pushed to on-demand guides
- [ ] On-demand guides loaded deterministically for the task type at hand
- [ ] A prime command ran at session start (specialized on large codebases)
- [ ] Long-term memory via git log / changelog, not chat history
- [ ] Research delegated to subagents; only summaries in the main window
- [ ] Fresh conversation per task; no marathon windows
- [ ] `autoMemoryEnabled` is on and `memory-sync.sh` is linked, if cross-machine
      persistence matters for this project
- [ ] PreCompact safety-net has fired at least once this project (check for an
      auto-generated `session.auto.md` or `session.md` after a `/compact`)

If a session went off the rails, the postmortem is almost always one of these boxes
unchecked.
