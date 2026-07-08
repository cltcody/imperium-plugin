---
description: Build-artifact budget audit — build what ships (route JS, chunks, assets, images, container), measure it against STACK.md budgets, and report trend deltas with a PASS/WARNINGS/FAIL verdict
argument-hint: "[--delta | --no-build]"
---

# Verify: Bundle — Build-Artifact Budget Audit

Weigh what actually ships. This command builds each shippable artifact the project produces — web bundle, static export, mobile bundle, container image — measures it, and compares against the size budgets declared in `STACK.md`. It audits the **build output**, not how the code reads (`/cc:verify:performance` is the static-source sibling): it catches the 2 MB hero image, the route whose first-load JS quietly doubled, the container that grew 300 MB. Run it before `/cc:release:deploy`, after dependency changes, or whenever the app feels heavier.

It is **stack-agnostic**: which components build, and with what command, comes from the project's `STACK.md` per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` — never from this file.

Flags: `--delta` — ledger delta mode (see Findings ledger). `--no-build` — reuse the last build output instead of rebuilding, always with an explicit staleness warning.

## Findings ledger

Budget violations are recorded in the shared findings ledger — `${user_config.workspace_dir}/audits/ledger.jsonl`, one JSON record per finding — per `${CLAUDE_PLUGIN_ROOT}/references/dev/findings-ledger.md`. Records carry `command`, `rule`, `file`, `severity` (CRITICAL / HIGH / MEDIUM / LOW), `status` (new / known / accepted / fixed / regressed), `first_seen` / `last_seen`, and `accepted_reason` / `accepted_by` / `accepted_until` on accepted findings, keyed by `fingerprint` (first 16 hex chars of sha256 over `command|rule|file|normalized_evidence`). Here the normalized evidence is the **budget key** (e.g. `route_first_load_kb`), never the measured byte count — so a persisting violation keeps its fingerprint while sizes fluctuate — and `file` is the offending artifact or route path (the component's output root for `bundle.total` / `bundle.container`).

- **Default runs** annotate every finding with its ledger status — NEW, KNOWN, or ACCEPTED (REGRESSED when a previously fixed violation returns) — tag format per the ledger reference.
- **`--delta`** reports only NEW and REGRESSED findings in full, plus a one-line summary of the rest (counts of known / accepted / fixed).
- **Acceptance is user-driven only.** Never mark a finding accepted yourself; record it (reason, by whom, until when) only on explicit user grant. **No ledger present?** Run ledger-less (findings unannotated) and offer to initialize `${user_config.workspace_dir}/audits/ledger.jsonl`.
- Rule ids for the `rule` field: `bundle.route-js`, `bundle.chunk`, `bundle.asset-size`, `bundle.image-size`, `bundle.total`, `bundle.container`.

## Steps

### 1. Resolve what ships

Read `STACK.md` and resolve components per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. Identify which components produce a shippable artifact, and of what kind: a `build` step on a web framework (Next.js, Vite, an SSG, …) → web bundle or static export; Expo / React Native → per-platform mobile JS bundle; a Dockerfile in the component's `working_dir` → container image.

A component with no `build` step and no Dockerfile ships nothing — skip it. **If no component produces a shippable artifact, report "not applicable — nothing ships from this repo" and stop.** No `STACK.md` → auto-detect components once and recommend `/cc:setup:stack`.

### 2. Build — or reuse with a staleness warning

Run each shipping component's `build` step from its `working_dir`. If a build fails, stop — see Abort rules.

With `--no-build`, reuse the existing build output and **always print a staleness warning** naming the output's timestamp. Also check whether sources are newer than the output — any hits mean the measurements may not reflect the current code:

```bash
find <source dirs> -type f -newer <build output dir> -print | head -5
```

### 3. Measure per ecosystem — each from its component's `working_dir`

**Next.js** — parse the `next build` output for per-route first-load JS (`bundle.route-js`), then weigh emitted static chunks (`bundle.chunk`). Use `@next/bundle-analyzer` or `source-map-explorer` **only if already a devDependency** — never install analysis tooling for this audit:

```bash
du -sh .next/static && find .next/static -type f -name "*.js" -size +100k -exec ls -lh {} +
```

**React Native / Expo** — export and weigh the per-platform bundles (`bundle.total` per platform; oversized individual chunks → `bundle.chunk`):

```bash
npx expo export --output-dir dist-export
du -sh dist-export
find dist-export -type f \( -name "*.hbc" -o -name "*.js" \) -exec ls -lh {} +
```

**Static sites / generic fallback** — total output size plus the largest files (adapt `dist/` to the component's build output directory):

```bash
du -sh dist/ && find dist -type f -size +250k -exec ls -lh {} +
```

**Assets pass (all ecosystems)** — images (`bundle.image-size`) and other media/fonts (`bundle.asset-size`) over threshold anywhere in the shipped output:

```bash
find dist -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.webp" -o -name "*.svg" \) -size +500k -exec ls -lh {} +
find dist -type f \( -name "*.mp3" -o -name "*.mp4" -o -name "*.webm" -o -name "*.woff" -o -name "*.woff2" \) -size +250k -exec ls -lh {} +
```

**Container image** (`bundle.container`) — if a Dockerfile is in scope, inspect the built image. If no image exists or it predates the current Dockerfile, record the gap explicitly — never imply "within budget":

```bash
docker image inspect <image:tag> --format '{{.Size}}'
```

The `-size` thresholds above are a first-pass net for spotting offenders; the budget comparison in step 5 always uses exact measured sizes against the step-4 budgets.

### 4. Budgets — the `budgets:` block in STACK.md

Read the `budgets:` block from the `STACK.md` frontmatter. Schema — every key optional, and **only declared budgets are enforced**; a flat block applies to every shipping component, or nest budgets under component names to differentiate (nested keys win):

```yaml
budgets:
  route_first_load_kb: 250   # per-route first-load JS          → bundle.route-js
  chunk_max_kb: 300          # largest single emitted JS chunk  → bundle.chunk
  asset_max_kb: 250          # largest non-image asset          → bundle.asset-size
  image_max_kb: 500          # largest single image             → bundle.image-size
  total_mb: 5                # total shipped output (per platform for mobile) → bundle.total
  container_mb: 400          # container image size             → bundle.container
```

**No `budgets:` block → first-run baseline mode.** Measurements without budgets produce a **baseline, not findings**: propose a budgets block derived from the current measurements plus ~10% headroom (rounded to friendly numbers), show it, and **offer** to write it into `STACK.md` — never write it unasked. The run then ends PASS with "baseline established — budgets proposed".

### 5. Record the baseline and the ledger findings

Append this run's raw measurements — violations or not — to `${user_config.workspace_dir}/audits/bundle-baseline.json` (create it if missing), one entry per component per run, so later runs show trend deltas even for artifacts that never breach a budget:

```json
{ "date": "2026-07-06", "component": "web", "total_kb": 4812,
  "routes": { "/": 128, "/dashboard": 292 }, "chunks": { "chunks/vendor-9f3.js": 294 },
  "largest_assets": { "public/hero.png": 740 }, "container_mb": null }
```

Then compare exact measurements against the resolved budgets. Every **violation** (measured > budget) becomes a ledger finding per the Findings ledger section, with measured-vs-budget stated in the report; within-budget measurements live in the baseline only, never in the ledger.

### 6. Report and verdict

Severity per `${CLAUDE_PLUGIN_ROOT}/references/dev/severity-and-rubrics.md`, mapped to this command's budget semantics (a budget is a project-declared limit, so the failure scenario is concrete by construction):

- a budget exceeded by **≥20%**, or the `total_mb` / `container_mb` budget exceeded **at all** (`container_mb` is the total for a containerized component) → **HIGH**
- any other budget exceeded by **<20%** → **MEDIUM**. CRITICAL is not used by this command — artifact size never demonstrates data loss on its own.

Verdict, with accepted findings reported but excluded from the math: any HIGH → **FAIL** · only MEDIUM → **WARNINGS** · nothing exceeded → **PASS**.

Write the report to `${user_config.workspace_dir}/reports/bundle/YYYY-MM-DD-bundle.md` (create the directory if needed): top-offenders table, per-budget status, deltas vs the previous baseline entry, ledger status annotations.

## Output

```
BUNDLE AUDIT — <date> · <stack from STACK.md> · build: fresh | reused (staleness warning)
Budgets: STACK.md budgets: block | none → baseline mode (proposal below)
Top offenders
  #  artifact                       size     budget   Δ vs last run
  1  /dashboard first-load JS       312 KB   250 KB   +38 KB
  2  public/hero.png                740 KB   500 KB   unchanged
Per-budget status (component: web)
  route_first_load_kb  250  worst 312 (/dashboard)  exceeded +25%  HIGH   NEW    bundle.route-js
  image_max_kb         500  worst 740 (hero.png)    exceeded +48%  HIGH   KNOWN  bundle.image-size
  chunk_max_kb         300  worst 294               within budget
Ledger: 1 new · 1 known · 0 accepted · 0 regressed
Verdict: PASS | WARNINGS | FAIL — <reason, e.g. 2 budgets exceeded ≥20%>
```

## Quality checklist

- [ ] Every shipping component measured from its own `working_dir` — none skipped silently, non-shipping components named as skipped
- [ ] Build freshness stated — fresh build, or `--no-build` with an explicit staleness warning
- [ ] Analyzer tooling used only when already a devDependency — nothing installed into the project
- [ ] Budgets read from `STACK.md`; if absent, a baseline was recorded and a ~10% headroom budgets block proposed (offered, never force-written)
- [ ] Raw measurements appended to `audits/bundle-baseline.json` even when nothing violates
- [ ] Every violation carries rule id, artifact path, measured-vs-budget evidence, severity, and ledger status
- [ ] Verdict derived from the declared thresholds (≥20% or total/container → FAIL; <20% → WARNINGS), accepted findings excluded from the math; report written to `${user_config.workspace_dir}/reports/bundle/YYYY-MM-DD-bundle.md`

## Handoff

**Chain:** not part of the default verify chain. When inserted explicitly (e.g. before a release), a FAIL verdict halts the chain — report and stop; WARNINGS continue with the findings restated at the commit gate.
**Solo:** oversized route JS → code-split / dynamic-import via `/cc:plan:task`; oversized images → offer to compress or convert them; source-side patterns behind the weight (heavy imports, missing lazy loads) → `/cc:verify:performance`; clean PASS before shipping → continue with `/cc:release:deploy`.
**Abort rules:** no shippable artifacts in any component → "not applicable", stop. A `build` step fails → stop and route to `/cc:verify:debug` — a broken build cannot be measured, and never silently fall back to stale output (only an explicit `--no-build` may reuse it). Docker unavailable or image missing for a container component → measure the remaining components and record the container gap explicitly.
