# Component Reference Library — discovery, consultation, and copy semantics

A **component reference library** is a portfolio-level directory of exemplar UI
components — annotated source + runnable example + a `NOTES.md` of
usability/accessibility/security rationale per component — that projects copy
from instead of re-deriving form, auth, data, and shell patterns. It is
**copy-not-import**: the library is upstream exemplar material, never a runtime
dependency; copies are owned (and may drift) downstream.

This doc tells dev commands how to find such a library, when to consult it, and
how to copy from it. Two commands integrate it: `/cc:plan:feature` (consult
during codebase intelligence) and `/cc:setup:project` (offer copies at init).

## Resolution order (where the library is)

1. `${user_config.component_reference_dir}` — if set and non-empty, use it.
2. `~/code/_templates/reference` — if that directory exists (portfolio default
   layout).
3. Neither → **no library; every integration below is a silent no-op.** Never
   ask the user to create one; never error.

A valid library root contains a `CONVENTIONS.md` and one or more stack
directories. If the resolved path exists but has no `CONVENTIONS.md`, treat it
as no library (avoids misfiring on an unrelated folder).

## Layout contract (what a library looks like)

```
<library-root>/
├── CONVENTIONS.md              ← read this first; it is authoritative
├── <stack>/                    ← e.g. react/, html/, django/
│   ├── _demo/                  ← runnable harness; NEVER copied
│   └── <family>/<component>/   ← e.g. forms/text-field/
│       ├── <source files>
│       ├── *.example.*         ← demo usage; usually not copied
│       └── NOTES.md            ← the rationale; the reason to copy at all
```

Stack detection for matching: `react/` fits Next.js/React projects, `html/`
fits static sites (paste-friendly for Astro and friends), `django/` fits Django
projects. A library may carry any stack set; match against the project's
`STACK.md` stack.

## Consultation rule (planning — `/cc:plan:feature` Phase 2)

When the feature touches a user-facing surface that a library family covers —
forms/validation, auth screens, tables/pagination/async states, layout/modal/
toast/destructive-confirm — **check the library for a canonical component
before researching or inventing one**:

- Read the matching component's source **and its NOTES.md**; the NOTES carry
  decisions (aria wiring, focus behavior, enumeration-safe copy, escaping
  rules) that must survive adaptation.
- Plan the task as **COPY + ADAPT**, citing the library file as the PATTERN
  reference, and carry the NOTES' "breaks guarantees" list into the task's
  GOTCHA field.
- If the library lacks the component or the stack, proceed normally — and note
  the gap in the plan so the user can decide whether the built result should be
  generalized back into the library later (upstreaming is manual, by design).

## Copy semantics (setup — `/cc:setup:project` step 5b, or any manual copy)

Per-stack destinations (the library's own `CONVENTIONS.md` wins on conflict):

| Stack | Copy | To | Notes |
|---|---|---|---|
| react | component dir's `.tsx` + `NOTES.md` | `components/<family>/<component>/` | Requires a `cn()` util at `@/lib/utils` and shadcn-style CSS variables — standard in shadcn-ready projects. Skip `*.example.tsx` unless demos are wanted. |
| django | `templates/components/*.html` partials | project app's `templates/` | `forms.py`/`views.py` content is **surfaced for manual merge**, never auto-merged. Layout bases (e.g. `layout/app_base.html`) replace a project's base template — offer separately and explicitly. |
| html | files as-is | wherever the site keeps partials | Paste-level granularity; point rather than automate. |

**Never copy:** `_demo/` harnesses, `CONVENTIONS.md` (link it instead),
`NOTES-TEMPLATE.md`, lockfiles.

**Traceability:** after copying, record what was taken and from where —
family/component list + the library's current commit (`git -C <library-root>
rev-parse --short HEAD` when it is a git repo) — in the project's setup notes
or the plan that drove the copy. Copies drift by design; the record is what
makes a later refresh reviewable.

## What this is not

- Not a package registry: no auto-sync, no version constraints, no upgrade
  command. A library refresh reaching a project is always a human-reviewed
  re-copy.
- Not a scaffold: scaffolding whole projects stays with the templates that
  surround the library; this doc governs component-level copies only.
