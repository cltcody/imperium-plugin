---
description: Static performance review of the diff or a target area — N+1s, missing indexes, unbounded queries, sync-in-async, cache candidates
argument-hint: [path or area — defaults to the current diff]
allowed-tools: Read, Grep, Glob, Bash, SlashCommand
---

# Performance Review

Static review of the current diff (default) or a named area for the performance problems that actually kill applications under load. No profiler needed — these patterns are visible in the code. Optional gate: run before first real traffic, before scaling, or when something feels slow.

This review is **mostly static analysis** and **stack-agnostic**: the heuristics below apply across ORMs and frameworks. Where it needs to know *where* a component lives or *what language* it is, it reads the project's `STACK.md` rather than assuming one stack.

## Steps

1. **Resolve the stack (for scoping).** Read the project's `STACK.md` and resolve components per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. Use each component's `working_dir` and `language` to know which directories and file types to scan, and its `migrate` step as the route for any index/schema fix. No `STACK.md` → auto-detect components once and recommend `/cc:setup:stack`. Skip components that map nothing relevant.

2. **Scope the review.** Default to the current diff (`git diff HEAD`, or against main). If an argument names a path/area, review that instead. State the scope — and the resolved stack — in the report header.

3. **N+1 query patterns** (the most common killer). A loop that issues a DB call per iteration, lazy relationship access inside iteration, or a missing eager-load. Look for iteration over a result set where each element triggers another query (a `get`/`fetch`/relationship access inside the loop body), and for relationship/association declarations that default to lazy loading.

   **Fix pattern** (eager-load in one query instead of N). Example in async SQLAlchemy — adapt to the project's ORM:
   ```python
   # BAD — N+1
   items = (await db.execute(select(Order))).scalars().all()
   for item in items:
       user = await db.get(User, item.user_id)  # 1 query per item

   # GOOD — single query
   result = await db.execute(select(Order).options(selectinload(Order.user)))
   items = result.scalars().all()
   ```
   Expected impact: N queries → 1. The equivalent in other ORMs: `prefetch_related`/`select_related` (Django), `JOIN FETCH` / `include` / `with` (others).

4. **Missing database indexes.** Columns used in WHERE / JOIN / ORDER BY — especially foreign keys — without an index. Find foreign-key declarations and the columns filtered or sorted on, and check each has a backing index in the model or a migration.

   **Fix:** name the exact index to add and route it via `/cc:implement:migrate` (which runs the project's `migrate` step). Example — adapt to the project's ORM:
   ```python
   user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
   ```

5. **Unbounded queries and missing pagination.** Any endpoint returning a list MUST paginate, with an enforced maximum page size. Look for list/collection queries with no `limit`/`take`/`top` and for handlers whose response type is a bare list. Use whatever paginated-response convention the project already has (a shared `PaginationParams` / `PaginatedResponse[T]` helper, a framework paginator, cursor pagination) rather than inventing one.

6. **Sync-blocking calls in async context.** In an event-loop runtime, one blocking call stalls every concurrent request. Look for synchronous I/O on the hot path: blocking file reads, blocking HTTP clients where an async client exists, and blocking sleeps. Replace each with its async equivalent, or offload CPU-heavy work to a thread/process pool. (Skip this check for components whose `language`/runtime is not event-loop based.)

7. **Repeated expensive computations — cache candidates.** Queries for rarely-changing data (settings, feature flags, roles, reference tables) executed on every request. Look for the same lookup repeated per request that could be memoized.

   **Fix:** if a cache service (e.g. Redis) is active in `STACK.md` → use it; otherwise an in-process memoization for truly static data. Always note the invalidation story.

8. **Oversized payloads and hot-loop allocations.** Endpoints serializing full objects where the client needs three fields; per-iteration allocations, string concatenation in a loop, or repeated regex/serializer construction inside hot paths.

9. **Rate and write each finding** with severity, `file:line`, concrete fix, and expected impact, then pick the **Top 3 wins** — highest impact for lowest effort.

## Output

A report in the conversation (no file written):

```
PERFORMANCE REVIEW — <scope> (<stack from STACK.md>)
────────────────────────────────────────────────────
🔴 CRITICAL — will cause production issues under load
🟠 HIGH     — significant performance risk
🟡 MEDIUM   — optimise before scaling
🟢 LOW      — minor improvement

[severity] <type> — file:line — what's wrong — concrete fix — expected impact

Top 3 wins (highest impact, lowest effort):
1. ...
2. ...
3. ...
```

Fix 🔴 immediately. Address 🟠 before your first real traffic.

## Quality checklist

- [ ] Scope explicit — diff or named area, plus the resolved stack, stated in the report header
- [ ] Findings use this project's actual idioms and conventions (its ORM's eager-load, its pagination helper), not generic advice
- [ ] Every finding has `file:line` + concrete fix + expected impact (e.g. "N queries → 1")
- [ ] No speculative micro-optimisations — only patterns with real load impact
- [ ] Top 3 wins section present and genuinely low-effort

## Handoff

**Chain:** not part of the default verify chain. When explicitly inserted into a chain: a 🔴 CRITICAL finding **halts the chain** — report and stop; otherwise continue to `/cc:verify:execution-report`.
**Solo:** route mechanical fixes (add index, add eager-load, swap to async client) to `/cc:verify:code-review-fix`; index/schema additions through `/cc:implement:migrate`; structural changes (caching layer, pagination redesign) to `/cc:plan:task`.
**Abort rules:** empty diff and no area argument → offer a full scan of the resolved components' source roots instead of reporting nothing.
