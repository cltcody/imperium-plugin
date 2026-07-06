---
description: Review the API design for consistency, correctness, and developer experience
---

# API Review

Review the API design for consistency, correctness, and developer experience — run before
releasing a new API surface. This review is **stack-agnostic**: it inspects whatever API
layer the project actually has, and any concrete command (starting the server, smoke check)
comes from the project's `STACK.md`, not from this file.

## Resolve the stack

Before probing anything that runs, read the project's `STACK.md` and resolve commands per
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. The component that exposes the
API (typically a backend/API component) declares its `working_dir`, `package_manager`, and
mapped steps — use those instead of assuming a framework. To bring the API up so you can
probe live endpoints, run that component's `dev` step from its `working_dir`. To confirm the
app loads before probing, run its `smoke` step. Skip any step the component does not map. If
there is no `STACK.md`, auto-detect once from project markers and recommend the user run
`/cc:setup:stack` to persist a manifest.

The grep snippets below are illustrative; adapt the route-declaration pattern, file
extensions, and framework idioms (response-model declaration, error type, pagination
helpers, auth dependency) to the API component's actual language and framework as found in
its source tree.

## Steps

### 1. Map all routes

Locate the API component's source tree (its `working_dir`) and enumerate every route
declaration. Use `Grep` + `Read` to find the framework's route/handler registration
idiom (e.g. a decorator, a router registration, or a route table) across that tree's source
files, excluding tests and comments. For example, for a decorator-based framework:

```bash
# Run from the API component's working_dir; adapt the pattern + file glob to its language
grep -rn "<route-declaration-pattern>" <source-dir> --include="<source-glob>" | grep -v "test\|#"
```

List every endpoint: method, path, response model/schema, auth.

### 2. Naming consistency

Use `Grep` + `Read` to check:

- [ ] URL paths are `kebab-case` (not `snake_case` or `camelCase`)
- [ ] URL paths are plural for collections: `/items/` not `/item/`
- [ ] Resource IDs in path: `/items/{item_id}` not `/items/{id}` or `/get-item`
- [ ] No verb in URL path (no `/create-item`, `/delete-user`) — use HTTP method

```bash
# Check for verbs in route paths (adapt the path-declaration idiom + glob to the framework)
grep -rn "<path-declaration-idiom>" <source-dir> --include="<source-glob>" | grep -iE "create|delete|update|get|list|fetch"
```

### 3. HTTP methods and status codes

For every route, verify:

| Action | Method | Success Status |
|--------|--------|---------------|
| List | GET | 200 |
| Get one | GET | 200 (404 if not found) |
| Create | POST | 201 |
| Full update | PUT | 200 |
| Partial update | PATCH | 200 |
| Delete | DELETE | 204 (no body) |

```bash
# Find explicit success-status declarations (adapt the idiom + glob to the framework)
grep -rn "<status-code-idiom>" <source-dir> --include="<source-glob>" | grep -v "test\|#"
```

### 4. Response models

```bash
# Routes missing a declared response model/schema — they should all have one
grep -rn "<route-declaration-pattern>" <source-dir> --include="<source-glob>" | grep -v "<response-model-idiom>\|test"
```

Every route must declare a response model/output schema. This validates output and strips
unexpected fields.

### 5. Error consistency

```bash
# Error responses raised across routes (adapt the error-raising idiom + glob)
grep -rn "<error-raising-idiom>" <source-dir> --include="<source-glob>" | grep -v "test\|#"
```

Check: are 404, 422, 409 errors consistent? Do they all use a single shared error-response
shape?

### 6. Pagination

```bash
# List (collection GET) endpoints — do they use the project's pagination helper?
grep -rn "<collection-get-idiom>" <source-dir> --include="<source-glob>" -A 5 | grep -v "<pagination-idiom>\|{id}\|health"
```

Any GET endpoint returning multiple items must use the project's pagination params + a
paginated response wrapper.

### 7. Auth coverage

```bash
# Routes — which declare an auth dependency / guard? (adapt the idiom + glob)
grep -rn "<route-declaration-pattern>" <source-dir> --include="<source-glob>" -A 3
```

Mark each route: public, authenticated, or admin. Flag any route that should be protected
but isn't.

### 8. OpenAPI documentation quality

Use `Read` on route files. Check each route has:
- `summary` or descriptive route name
- `tags` set on the router/route group
- Response descriptions for non-200 status codes

If the framework serves a live schema (OpenAPI/Swagger) and you need to inspect it, bring
the API up with the component's `dev` step (resolved above) and read the served schema
endpoint; otherwise inspect the source declarations directly.

## Output

An API review report in this format:

```
API REVIEW
──────────
Total endpoints: <n>
  GET:    <n>
  POST:   <n>
  PUT:    <n>
  PATCH:  <n>
  DELETE: <n>

🔴 BLOCKING  — file:line — description
🟡 WARNING   — file:line — description
🟢 NOTE      — file:line — description

Consistency score: HIGH / MEDIUM / LOW
Production Ready: YES / NEEDS WORK
```

## Quality checklist

- [ ] Every route mapped with method, path, response model, and auth status
- [ ] Naming, methods, and status codes follow REST conventions
- [ ] All routes declare a response model/output schema; errors use one shared error shape
- [ ] Collection GETs use the project's pagination params + paginated response wrapper
- [ ] Auth coverage explicit for every route; no unintentionally public endpoints

## Handoff

**Chain:** If findings exist, invoke `/cc:verify:code-review-fix` to auto-fix the correctable issues (or apply fixes manually), then re-run `/cc:verify:api`. If clean, continue to the next step in the chain.

**Solo:** Report the review. On findings, suggest fixes followed by `/cc:verify:run`; on clean, suggest continuing with `/cc:verify:run` or `/cc:release:commit`.

**Abort rules:** Any 🔴 BLOCKING finding means the API surface is not production-ready — do not proceed to release steps until it is resolved and the review is re-run. If the contract itself is ambiguous (not just the implementation), route back to `/cc:plan:api`.
