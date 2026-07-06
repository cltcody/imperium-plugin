---
description: Design REST API contract before implementing endpoints
argument-hint: [feature or resource name]
---

# Plan: API Design

Design the API surface *before* writing handlers — this prevents scope creep and keeps the
team aligned on request/response format. This planning step is **stack-agnostic**: it
designs a REST contract for any backend; any concrete command (auditing existing routes,
starting the server) comes from the project's `STACK.md`, not from this file.

**When to use:** Before writing any endpoint code for a new feature.

## Resolve the stack

Before running anything, read the project's `STACK.md` and resolve commands per
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. The component that exposes the
API (typically a backend/API component) declares its `working_dir`, `package_manager`, and
mapped steps — use those instead of assuming a framework. To bring the API up later (step 4),
run that component's `dev` step from its `working_dir`. Skip any step the component does not
map. If there is no `STACK.md`, auto-detect once from project markers and recommend the user
run `/cc:setup:stack` to persist a manifest.

The grep snippets below are illustrative. Adapt the route-declaration pattern, file
extensions, and framework idioms (request/response schema, error type, pagination helper,
auth guard) to the API component's actual language and framework as found in its source tree.

## Steps

### 1. API audit

Check existing patterns. From the API component's `working_dir`, find the framework's
route/handler registration idiom (a decorator, a router registration, or a route table)
across the source tree, so new endpoints match what's already there:

```bash
# Run from the API component's working_dir; adapt the pattern + file glob to its language.
# Example (FastAPI): grep -rn "@router.post\|@router.get" app/ | head -20
grep -rn "<route-declaration-pattern>" <source-dir> --include="<source-glob>" | head -20
```

Also read any project API-conventions reference (naming, status codes, pagination) if one
exists.

### 2. Define endpoints

For each endpoint, answer:

#### Endpoint 1: [METHOD] /path

| Field | Answer |
|-------|--------|
| **Purpose** | One sentence: what does this do? |
| **Path** | `/api/items` or `/api/v1/items/{id}` |
| **Method** | GET, POST, PUT, PATCH, DELETE |
| **Auth required?** | yes / no |
| **Request body** | Request schema, fields + types (e.g. Pydantic model, Zod schema, dataclass, JSON shape) |
| **Response (2xx)** | Response schema, fields + types (same form as request) |
| **Errors (4xx/5xx)** | 400 Bad Request, 404 Not Found, 409 Conflict, 500 Server Error |
| **Pagination?** | yes / no (if yes: cursor or offset?) |
| **Rate limit?** | yes / no (requests per minute) |

#### Example (schemas shown in a Pydantic-style notation — use your stack's schema language):
```
Endpoint: POST /api/items

Purpose: Create a new item in the inventory

Path: /api/items

Method: POST

Auth required: yes (user must be authenticated)

Request body:
  ItemCreate {
    name: string
    description: string (optional)
    price: number
    quantity: integer
  }

Response (201):
  ItemResponse {
    id: integer
    name: string
    description: string
    price: number
    quantity: integer
    created_at: datetime
    updated_at: datetime
  }

Errors:
  400: name or price invalid
  401: unauthorized
  409: item name already exists

Pagination: no

Rate limit: no
```

### 3. Consistency check

- [ ] All endpoints follow `/api/<feature>/<resource>` naming
- [ ] GET = fetch, POST = create, PUT/PATCH = update, DELETE = remove
- [ ] All list endpoints support pagination (if data could grow)
- [ ] All responses include timestamps (created_at, updated_at)
- [ ] Error responses follow a single shared error-response shape
- [ ] Status codes match HTTP standards (201 for creation, 204 for delete, 409 for conflict)
- [ ] Auth requirements are explicit (all endpoints or just some?)
- [ ] Rate limits documented if applicable

### 4. Schema validation (after implementation)

If the framework serves a live API schema (OpenAPI/Swagger, GraphQL introspection, etc.),
bring the API up and inspect it:

```bash
# Start the dev server via the API component's resolved `dev` step (from STACK.md),
# run from its working_dir. Examples:
#   FastAPI: uv run uvicorn app.main:app --reload
#   Django:  uv run python manage.py runserver
#   Node:    npm run dev
<dev-step-from-STACK.md>

# Then open the served schema/docs endpoint the framework exposes
# (e.g. /docs, /openapi.json, /graphql).
```

If the framework does not serve a live schema, inspect the route declarations and schemas in
the source directly. Check:

- [ ] All endpoints visible / registered
- [ ] Request/response schemas correct
- [ ] Status codes documented
- [ ] Required fields marked as required

## Output

An agreed API contract in this format:

```
API CONTRACT
──────────────────────────────────────

Feature: <feature name>
Author: <your name>
Date: <YYYY-MM-DD>

ENDPOINTS:
  POST /api/items              Create item
  GET  /api/items              List items
  GET  /api/items/{id}         Get single item
  PUT  /api/items/{id}         Update item
  DELETE /api/items/{id}       Delete item

SCHEMAS:
  ItemCreate → ItemResponse
  ItemUpdate → ItemResponse
  ErrorResponse (all errors)

ERRORS:
  400: Validation error
  401: Unauthorized
  404: Not found
  409: Conflict (duplicate)
  500: Server error

PAGINATION:
  GET /api/items?limit=10&offset=0
  Response includes: items[], total, limit, offset

RATE LIMITS:
  None (or specify if enforced)

SIGNED OFF: ✅ Team agrees
```

After merge, document the contract in the feature's `README.md` with examples.

## Quality checklist

- [ ] Every endpoint has purpose, method, path, auth, request/response schemas, and error codes defined
- [ ] Naming and status codes follow REST conventions (and any project API-conventions reference)
- [ ] Pagination decided for every list endpoint
- [ ] All errors map to a single shared error-response shape
- [ ] Contract signed off — no remaining ambiguity about request/response format

## Handoff

**Chain:** Invoke `/cc:plan:feature` next to scaffold the vertical slice that implements this contract.

**Solo:** Suggest `/cc:plan:feature` (new slice) or `/cc:implement:execute` (spec already exists) to build the endpoints, then `/cc:verify:api` after the build to validate the implementation matches this contract.

**Abort rules:** If the contract cannot be agreed (ambiguous resource model, conflicting existing patterns), stop and route to `/cc:plan:task` to resolve the design question first — do not start endpoint code with an unsigned contract.
