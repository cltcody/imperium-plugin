# Agent Design Patterns

> Distilled from imported course/workshop notes, 2026-07. Original synthesis for this
> plugin — no third-party text reproduced.

Patterns for building LLM agents: tool design, tool documentation, multi-agent
topologies, guardrails, and security. Used by `/cc:plan:agent` and relevant to any
feature that embeds an LLM. Retrieval-specific patterns live in
`rag-knowledge-patterns.md`.

---

## Tool design: fewer, smarter tools

The single most repeated finding: **consolidated, workflow-shaped tools outperform
many small CRUD tools.** Agents pick wrong among ten similar tools; they rarely pick
wrong among three distinct ones.

### The query / read / modify triad

For any resource domain (a document vault, a CRM, a file store), three tools usually
suffice, mapping to the agent's mental model:

| Tool | Job | Returns |
|------|-----|---------|
| `X_query` | Find things (search, list, explore relationships) | Summaries/excerpts + IDs — never full content |
| `X_get_context` | Read things, with surrounding context (related items, backlinks, metadata) | Full content |
| `X_manage` | Change things (create/update/move/delete, single or bulk) | Structured success/failure per item |

Why split query from read: searching must stay cheap. Returning full documents from
search wastes tokens on results the agent will discard; the two-step *find → read*
flow lets the agent read only what matters.

### Consolidation rules

- **Bulk is a parameter, not a tool.** `manage(targets=[...])` — don't create a
  parallel `bulk_manage` the agent must choose between.
- **Adjacent operations fold in.** Folder ops belong in the vault manager (moving
  notes *is* organizing folders); "find availability" and "book slot" become one
  `schedule_event`.
- **Workflow-shaped composites** beat orchestration: `gather_related` (read note +
  find related + read those) saves three round trips and their token cost.

### Parameter and response design

- **Namespacing**: prefix domain tools (`obsidian_*`, `crm_*`) so selection is
  unambiguous when many servers are loaded.
- **Natural-language identifiers**: human-readable paths/names over opaque IDs — the
  agent hallucinates UUIDs but not `Projects/2026/roadmap.md`.
- **Response-format control**: a `response_format: concise | detailed` parameter
  (~50 vs ~200 tokens per result) lets the agent right-size output; document the
  costs so it can choose.
- **Self-describing names**: `target` not `file`, `confirm_destructive` not `force`,
  `max_related` not `limit`.
- **Safety defaults**: destructive ops require an explicit confirmation flag; bulk
  ops report partial success item-by-item; convenience flags (`create_folders=True`)
  remove multi-step failure chains.
- **Actionable errors**: an error message should tell the agent what to do next
  ("path outside vault root — use a path relative to the vault"), not just what broke.

---

## Tool docstrings: the agent's contract

A tool docstring is read by the LLM during tool selection — it's an interface
contract, not code documentation. Small docstring improvements produce outsized
behavior improvements. Required elements, in order:

1. **One-line summary** of the tool's purpose.
2. **"Use this when"** — 3–5 concrete scenarios (not "when you need to work with
   notes" — *which* work?).
3. **"Do NOT use this for"** — the critical, most-omitted section. Point to the
   correct alternative tool by name; this is what prevents tool confusion.
4. **Args with *why*** — beyond type and meaning, explain when to choose each enum
   value or include each optional parameter.
5. **Returns** — shape and structure, not just type.
6. **Performance notes** — token cost per configuration, typical latency, limits,
   external-call cost. Agents optimize when they can see the numbers.
7. **Examples** — 2–4 with realistic data (real-looking paths, not `foo.md`):
   a simple case, a complex case, an edge case.

Test docstrings like code: give the agent a task plus the full tool list — does it
pick correctly, choose economical parameters, and redirect off the "do NOT use"
guidance? **If the agent keeps misusing a tool, fix the docstring, not the agent.**

---

## Multi-agent topologies

Escalate only as needed; each step adds coordination cost.

### 1. Agent-as-tool (nesting)

A primary agent invokes a specialist agent as one of its tools (research agent
calling an email-drafting agent). Simplest composition; the sub-agent's context is
naturally isolated. Fine for one or two specialists with clear boundaries.

### 2. LLM router

A **lightweight, cheap model** classifies each request and routes to one specialist
(web search / mail search / document RAG / …), plus a **fallback route** for unclear
input. Properties to engineer for:

- Router accuracy is testable — hold a labeled query set and assert ≥95% routing.
- The router only routes; specialists own their domains and stream their own output.
- Cost win: the expensive model runs only on the routed work.
- Never hardcode route selection in code paths the router should own — and never let
  "no route matched" crash; that's what fallback is for.

### 3. Supervisor with shared state

A supervisor agent receives the request, delegates to sub-agents, and decides after
*each* result whether to delegate again, to a different agent, or to answer. The load-
bearing design points:

- **Shared state carries summaries, not transcripts.** Each sub-agent appends a
  concise summary of what it did/found to a shared (often append-only) state. Full
  outputs never enter another agent's window — this is what prevents context overflow
  and makes the pattern scale.
- **Dynamic interleaving is the goal.** A good supervisor produces different call
  sequences per request (research → tasks → research → email…), skipping irrelevant
  agents entirely. If every request follows the same A→B→C order, you built a
  pipeline, not a supervisor — and a deterministic pipeline would be cheaper and more
  reliable. The supervisor's system prompt is where this intelligence lives; budget
  real effort there.
- **Structured output for delegation decisions** — typed decisions (which agent,
  what instruction, or final-answer) rather than parsed prose.
- **Hard iteration cap** (e.g. 20) so delegation can't loop forever.

### 4. Human-in-the-loop gates

For consequential actions (sending email, spending money, deleting data):

- The agent may **prepare** autonomously (read, analyze, draft) but **execution
  requires approval**. Encode draft-first bias in the system prompt *and* enforce it
  in the workflow graph — prompt-only restrictions are not guarantees.
- Implement the pause as a workflow **interrupt with checkpointed state** (persistent
  store, e.g. Postgres) so approval can arrive minutes or days later, across restarts.
  Resume with an explicit approve/decline command that re-enters the graph.
- Surface the pending action as structured fields (recipient, subject, body) so a UI
  can render an approval card; keep an audit trail of decisions; rate-limit the
  execute path independently.

---

## Guardrails checklist

- [ ] Iteration/recursion caps on every agent loop
- [ ] Structured output validated against a schema at each decision point
- [ ] Streaming has a non-streaming fallback (structured-output streaming is the
      flakiest part of most stacks — validate it in isolation *before* integrating)
- [ ] Least-privilege credentials: request read-only scopes unless the tool writes
      (a read-only mail scope cannot be tricked into sending)
- [ ] Filesystem tools jailed to a configured root; path validation on every call
- [ ] Destructive operations behind explicit confirmation parameters
- [ ] External API failures handled per-tool (rate limits, auth expiry) with errors
      the agent can act on
- [ ] Every agent action emits a structured log event
      (`agent.tool.execution_started/_completed/_failed` — see
      `ai-project-setup-patterns.md` for the naming scheme)

---

## Prompt injection: assume it's unsolved

Any text an agent reads — web pages, emails, retrieved documents, file contents — is
a potential instruction channel. There is **no complete defense**; LLMs are
prediction machines and remain trickable, the way organizations remain phishable.
Layer mitigations instead:

1. **Least privilege** — the strongest defense is a tool that *can't* do the harmful
   thing (read-only scopes, jailed paths, no shell).
2. **Human gates** on irreversible/external actions (see above).
3. **Demarcate untrusted content** — wrap retrieved/external text and tell the model
   it is data, not instructions. Helps; never sufficient alone.
4. **Separate privilege domains** — the agent that browses untrusted content should
   not be the agent holding write credentials.
5. **Egress control** — an injected agent exfiltrates through its outputs; restrict
   where results can be sent.
6. **Log and review** — injection that succeeds silently is the worst case; audit
   trails make it detectable.

Threat-model any new tool by asking: *if every document this agent reads were written
by an attacker, what could this tool be made to do?*

---

## Evaluation and observability

- Trace every agent run (inputs, tool calls, outputs, token/latency costs) with an
  observability layer; you cannot improve prompts you cannot replay.
- Maintain small labeled eval sets for each decision point — router accuracy,
  tool-selection accuracy, end-to-end task success — and run them on every prompt or
  tool-docstring change, exactly like a test suite.
- Treat system prompts and docstrings as versioned code: change → eval → ship.

---

## Case study: knowledge-vault agent

A recurring reference design that exercises most patterns above — an agent over a
personal Markdown knowledge vault:

- **Three tools** (query / get-context / manage) per the triad, with bulk parameters
  and `confirm_destructive` on deletes.
- **Vault jail**: root directory from environment config; every path validated
  against it.
- **Integrity side-effects owned by tools**: moving/renaming notes auto-updates
  wiki-links so the agent can't silently break the graph.
- **Harness split**: a general coding agent (with native file editing) serves as the
  primary agent, while custom retrieval/search runs behind an MCP server it calls —
  reuse the harness's strengths, add only the domain tools you actually need.
