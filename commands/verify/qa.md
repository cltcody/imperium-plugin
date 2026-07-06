---
description: Generate a manual QA testing checklist for the current change-set — feature, cross-cutting, and regression tests, as a self-contained interactive HTML companion (with an optional Markdown version)
argument-hint: "[optional: feature/area name]"
---

# Verify: QA Checklist

Generate a **specific, actionable** manual QA checklist for the current feature branch, based
on the uncommitted/branch changes and the conversation context. The **default deliverable is a
self-contained interactive HTML checklist** with visual Pass/Fail/Skip tracking, saved to
`${user_config.workspace_dir}/qa/<branch>-checklist.html`. A plain-Markdown version
(`${user_config.workspace_dir}/qa/<branch>-checklist.md`) is **optional** — produce it only if the user asks
for it (or asks for "markdown"/"a plain checklist").

This is **stack-agnostic**: automated-check rows resolve from the project's `STACK.md` per
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` — never hardcode a test runner.

## Steps

### 1 — Gather context
```bash
git branch --show-current
git diff --name-only ; git diff --staged --name-only ; git diff --stat
```
From the conversation, capture: what was built and why, key design decisions, bugs found/fixed
during development (high-risk regression areas), edge cases discussed, and user concerns.

### 2 — Analyze changes
For each changed file: which user-facing capability it affects; what interactions need testing
(controls, navigation, async, etc.); what states/modes exist (on/off, locale, theme, role);
what integration points exist (does A affect B?).

### 3 — Generate the checklist
- **Feature-specific** — one section per logical feature: happy path, each option/variation,
  boundary conditions. Reference actual screen/component names and exact repro steps.
- **Cross-cutting** — include only those that apply to this project: offline/network-loss
  (if offline-capable), each supported locale (if i18n), navigate-away/back (no orphaned
  state), background/foreground, theme switch, auth/role variations.
- **Regression** — features sharing modified components or modules; call out anything that was
  buggy during development.
- **Automated results** — one row per **mapped** `STACK.md` step (`smoke`, `typecheck`,
  `lint`, `test`, `format:check`), with the resolved command and pass/fail. Skip unmapped steps.

### 4 — Build the HTML checklist (default deliverable)
Render the checklist into the interactive HTML companion and save it to
`${user_config.workspace_dir}/qa/<branch>-checklist.html` (create the dir if needed).

**Use the canonical template — do not hand-roll the HTML/CSS/JS.** Copy
`${CLAUDE_PLUGIN_ROOT}/references/qa/qa-checklist-template.html` and replace ONLY its `{{TOKEN}}`
placeholders (documented in the comment at the top of that file). Never edit the template's
`<style>` or `<script>` — the Pass/Fail/Skip selectors, live progress bar, per-row notes,
dark/light toggle, `localStorage` persistence, and File System Access auto-save (which bakes the
last run's results back into the file via the `@@SAVED_STATE@@` marker) all depend on it being
intact. Generated checklists also let testers attach screenshots to any row (drag-and-drop, paste, or
click-to-pick), with thumbnails, a click-to-zoom lightbox, and persistence baked into the saved file.
Map the tokens like so:
- `{{TITLE}}` / `{{META_BADGES}}` — feature title + branch/issue badges.
- `{{AUTO_ROWS}}` + `{{AUTO_KEYS}}` + `{{AUTO_DEFAULTS}}` — one row per **mapped** `STACK.md`
  step (`smoke`/`typecheck`/`lint`/`test`/`format:check`) with its resolved command; pre-check
  the steps that passed this run.
- `{{MATRIX_GROUPS}}` + `{{TESTS}}` + `{{TOTAL}}` — the Feature / Cross-cutting / Regression
  groups and their numbered rows (`num` contiguous 1..N; `TOTAL` = number of rows).
- `{{STORAGE_KEY}}` — unique, e.g. `qa-<branch-slug>`.
- `{{EDGE_CASES}}` — things already covered by unit tests (delete the section if none).
- `{{SIGNOFF_ITEMS}}` + `{{SIGNOFF_KEYS}}` — final sign-off rows.

After writing, verify there are no stray `{{` tokens left and that `{{TESTS}}` is valid JS
(each row `[groupId, num, 'title', 'tag', 'stepsHTML']`, every `groupId` matching a rendered
`id="grp-…"`). Tell the user the file path and that opening it in Chrome/Edge enables auto-save.

### 5 — Quality bar
Specific, not generic — real names, exact steps ("Open X → Y → tap Start"). Scannable
(short titles, exact repro). Flag development-time bugs as high-risk regressions.

### 6 — Optional: Markdown version
Only if the user asks for a Markdown/plain-text checklist, also write
`${user_config.workspace_dir}/qa/<branch>-checklist.md` mirroring the same sections (automated rows, manual
matrix with checkboxes, edge cases, sign-off) and display it in the conversation. Otherwise the
HTML file is the sole deliverable — give the user its path rather than dumping the matrix inline.
