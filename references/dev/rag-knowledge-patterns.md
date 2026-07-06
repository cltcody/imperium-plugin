# RAG & Knowledge-Base Patterns

> Distilled from imported course/workshop notes, 2026-07. Original synthesis for this
> plugin — no third-party text reproduced.

Retrieval patterns for agents over document knowledge bases: when RAG is the right
tool, why flat RAG stops working at scale, and the hierarchical design that fixes it.
Complements `agent-design-patterns.md` (tool design for the retrieval tools
themselves).

---

## When RAG — and when not

- **Document knowledge bases** (support docs, meeting notes, contracts, research):
  RAG is the right tool, and the patterns below apply.
- **Codebases**: mostly *not*. Modern coding agents do agentic search — grep, glob,
  read — over a well-structured repo (see `ai-project-setup-patterns.md`) and this
  beats maintaining a code embedding index that goes stale on every commit. Reserve
  code-RAG for cross-repo discovery at very large scale.

---

## Why flat RAG breaks at scale

Flat RAG embeds every chunk into one undifferentiated pool and searches all of it
equally. With dozens of documents this works; with hundreds to thousands it degrades
predictably:

- Many chunks become **semantically near-identical** (every weekly meeting note
  mentions the same projects), so top-K selection turns effectively random among them.
- There is **no way to scope** a query the way the user means it ("the February 2nd
  meeting") because structure and metadata aren't part of retrieval.
- Precise chunks are too small to answer from; whole documents are too big to embed
  accurately. Flat RAG forces one bad compromise size.

---

## Hierarchical RAG: two levels

### Level 1 — category scoping (search narrower)

Attach metadata/categories to every chunk at ingestion (source, folder, date, topic —
whatever the corpus naturally organizes by). Retrieval becomes two steps: pick the
category (agent decision or metadata filter from the query), then run semantic search
**only within that subset**. The "many near-identical chunks" problem shrinks to the
slice that actually matters.

Categories must exist honestly: either the corpus is already organized (folders,
sources, dates) or an ingestion-time model assigns them. If neither holds, this level
isn't the right approach. Note this is *not* a knowledge graph — categories don't
encode relations between topics, only membership.

### Level 2 — parent-context expansion (answer wider)

Embed **small leaf chunks** (roughly 100–400 characters) for retrieval precision, but
store each with a pointer to its parent section and document. Retrieval "zooms in,
then zooms out":

1. Search finds the top-K leaf chunks (precise match).
2. Follow parent IDs from the chunk metadata; dedupe (5 chunks might map to 3
   documents).
3. Send the **parent sections/documents** — not the fragments — to the LLM as
   context, keeping chunk-level provenance for citations.

Optionally also embed **LLM-generated document summaries** alongside leaf chunks and
search both pools at once; whether the hit is a summary or a leaf, expansion resolves
to the same parent document. Summaries cost an LLM call per ingested document — the
one optional expense here, worth it for large corpora.

### Combined flow

```
query → [category filter] → search leaf chunks (+ summaries)
      → resolve parent documents (dedupe)
      → LLM answers from parents, cites chunk sources
```

Expose this to the agent as tools that *enforce* the path: a scoped search tool
(category parameter, returns chunks + parent IDs) and a get-context tool (expands a
chunk/ID to its section or full document). Let the agent decide how far to zoom —
"this chunk suffices" vs. "read the whole section" — via a second tool call rather
than always shipping maximal context.

---

## Ingestion pipeline notes

- **Use a structure-aware converter** for real-world files (PDF, DOCX, PPTX, HTML).
  Naive text extraction destroys tables, headings, and content split across pages —
  and with them your hierarchy. Purpose-built open-source document converters handle
  these and emit structured output worth chunking.
- **Hybrid chunking**: split along the document's own structure (sections, headings,
  tables kept intact) with size limits as the secondary constraint — not fixed-size
  windows that cut sentences and tables mid-way. Structure-derived chunks are exactly
  what Level 2 needs, since each chunk knows its section.
- Store rich metadata on every row: document ID, section ID, category, source path,
  date. All the hierarchy above is just disciplined metadata plus code that follows
  the pointers.
- Re-ingestion must be idempotent (replace by document ID), or the knowledge base
  accumulates stale duplicates that reintroduce the flat-RAG noise problem.

---

## Beyond hierarchy: knowledge graphs

Hierarchical RAG answers "find the right document and its context". It does **not**
answer multi-hop relational questions ("which projects depend on the system that
person X owns?") — nothing in categories encodes how topics relate. That's the
knowledge-graph regime (entity/relation extraction at ingestion, graph traversal at
query time). It is substantially more expensive to build and maintain; adopt it only
when real queries demonstrably need multi-hop reasoning, and keep hierarchical RAG
for everything else. The two compose: graph for relations, hierarchy for content.

---

## Debugging retrieval: symptom → fix

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Results feel random / plausible-but-wrong document | Near-duplicate chunks competing in one flat pool | Add Level 1 category scoping; filter before searching |
| Right document found, answer still vague or wrong | LLM only saw a fragment | Add Level 2 parent expansion; shrink leaf chunks, ship parents |
| "The Feb 2nd meeting" returns other meetings | Semantic search can't express structured constraints | Move dates/sources into metadata filters, not the embedding text |
| Tables/figures answered wrong | Naive extraction shredded structure at ingestion | Re-ingest with a structure-aware converter and hybrid chunking |
| Old/contradictory content resurfaces | Non-idempotent re-ingestion left stale rows | Replace by document ID on every ingest |
| Agent skips retrieval or reads too much | Tool design permits shortcuts | Enforce find → expand via tool shapes and docstrings (see `agent-design-patterns.md`) |
| Relational questions fail despite good retrieval | Wrong tool class — hierarchy can't do multi-hop | Evaluate a knowledge graph for that query class only |

Instrument before tuning: log each retrieval (query, filters, chunk IDs, parent IDs,
scores) so you can replay a bad answer and see *which* stage — scoping, search, or
expansion — chose wrong. Build a small labeled query set (question → expected
document) and re-run it after every pipeline change, exactly like a test suite.

---

## Defaults that work

| Decision | Default |
|----------|---------|
| Leaf chunk size | ~400 chars (100–400 range) when using parent expansion |
| What to embed | Leaf chunks; optionally document summaries too |
| What to send to the LLM | Parent sections/documents, deduped |
| Scoping | Metadata/category filter before semantic search |
| Citations | Chunk-level provenance carried through expansion |
| Storage | Relational DB + vector extension is plenty (e.g. Postgres/pgvector) |
| Retrieval control | Agent-driven via search + get-context tools, path enforced by tool design |
