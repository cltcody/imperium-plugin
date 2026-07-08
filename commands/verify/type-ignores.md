---
description: Audit all type/lint suppressions — find every suppression, investigate why it exists, recommend resolution
---

# Type Suppression Audit

Find every type/lint suppression comment in the codebase, investigate why it exists, and
provide recommendations for resolution or justification. This audit is **stack-agnostic**:
the suppression syntaxes span languages, and the type checker used to confirm fixes comes
from the project's `STACK.md`, not from this file.

## Steps

### 1. Find all suppressions

Grep across all source files so none are missed — including inline (`# noqa: E501`,
`// @ts-expect-error`), bare/blanket, and block forms. Cover the suppression syntaxes for
whatever languages the codebase actually uses, for example:

- **Python**: `# type: ignore`, `# pyright: ignore`, `# noqa`
- **TypeScript / JavaScript**: `// @ts-ignore`, `// @ts-expect-error`, `// @ts-nocheck`,
  `// eslint-disable-next-line`, `// eslint-disable-line`, `/* eslint-disable */`,
  `// biome-ignore`, `// prettier-ignore`
- **Other languages present**: their equivalents (e.g. Go `//nolint`, Java
  `@SuppressWarnings`, C# `#pragma warning disable`, Rust `#[allow(...)]`)

Match both the inline form (with a specific rule code) and the blanket/file-level form.

### 2. Investigate each one

For each suppression, read the surrounding code and determine why it was added — the actual
root cause, not just the symptom.

### 3. Write the report

Create a markdown report file (create the reports directory if not created yet):
`${user_config.workspace_dir}/reports/ignore-comments-report-{YYYY-MM-DD}.md`

For each comment, use this format:

```
**Why it exists:**
{explanation of why the suppression was added}

**Options to resolve:**

1. {Option 1: description}
   - Effort: {Low/Medium/High}
   - Breaking: {Yes/No}
   - Impact: {description}

2. {Option 2: description}
   - Effort: {Low/Medium/High}
   - Breaking: {Yes/No}
   - Impact: {description}

**Tradeoffs:**

- {Tradeoff 1}
- {Tradeoff 2}

**Recommendation:** {Remove | Keep | Refactor}
{Justification for recommendation}

---

{Repeat for each comment}
```

## Output

A dated audit report at `${user_config.workspace_dir}/reports/ignore-comments-report-{YYYY-MM-DD}.md` with one
entry per suppression: why it exists, resolution options with effort/breaking/impact
assessment, tradeoffs, and a Remove/Keep/Refactor recommendation.

## Quality checklist

- [ ] Every suppression in the codebase is captured, across all languages present (Python
      `# type: ignore` / `# pyright: ignore` / `# noqa`; TS/JS `// @ts-ignore` /
      `// @ts-expect-error` / `eslint-disable`; and any other language's equivalents)
- [ ] Both inline (rule-coded) and blanket/file-level forms are covered
- [ ] Each entry explains the actual root cause, not just the symptom
- [ ] Each entry has at least one concrete resolution option with effort and breaking-change assessment
- [ ] Every recommendation is one of Remove / Keep / Refactor with justification

## Handoff

**Chain:** For findings recommended Remove or Refactor, fix the root causes rather than
just deleting the comment; once suppressions are removed, run the affected component's
`typecheck` step (resolved per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`
from its `working_dir`) to confirm the checker stays clean, then invoke `/cc:verify:run`
to confirm the full gate (tests, types, lint) stays green.

**Solo:** Report the audit summary and point to the report file; suggest tackling Remove
recommendations first, then `/cc:verify:run`.

**Abort rules:** If removing a suppression turns the component's `typecheck` (or lint) red
and the root cause is non-trivial, document it as Keep (with justification) rather than
leaving the build red — and route the underlying issue to `/cc:verify:debug` or
`/cc:plan:task`. If a component has no `typecheck` mapped in `STACK.md`, skip its checker
confirmation; no `STACK.md` at all → auto-detect the type checker once and recommend
`/cc:setup:stack`.
Remember the project rule: zero new suppressions without explicit approval.
