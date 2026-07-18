---
description: One-shot init for a NEW or EXISTING repo — git init, classify (personal/corporate/shared-oss), scaffold [WORKSPACE_DIR]/, generate STACK.md, offer CI, and (personal only, confirmed) plant per-repo plugin settings. Use when the ask is "set this repo up for cc", "init this project", or you've just cloned/created a repo and want the full one-shot setup instead of running setup:stack, setup:ci, and classification by hand.
argument-hint: "[path — defaults to cwd]"
model: sonnet
size-budget: exempt — one-shot init spanning classify/scaffold/stack/CI/settings branches
---

# Setup: Project — One-Shot Init

Everything a repo needs before the dev commands trust it: a git repo, a declared
**class** (`personal` / `corporate` / `shared-oss` — see
`${CLAUDE_PLUGIN_ROOT}/references/dev/repo-classification.md`), a `STACK.md`, a
`[WORKSPACE_DIR]/` scaffold, and — carefully gated — a plugin auto-install. This command
composes `/cc:setup:stack` and `/cc:setup:ci` rather than duplicating their logic; it adds
the classification step neither of them owns and the scaffold/settings steps that belong
once, at init, not on every stack regen.

Target directory: `$ARGUMENTS` if given, else the current working directory. All steps
below operate against that directory.

**Idempotent by design.** Re-running this command re-detects every artifact it manages —
git repo, `class:`, `STACK.md`, `[WORKSPACE_DIR]/`, gitignore entries, CI file, settings
file — and reports each as "present, skipped" without asking or changing anything, unless a
step's own contract (e.g. `setup:stack`'s diff-and-confirm) calls for a confirmation on a
real change.

## Steps

### 1 — Resolve target dir, git init if needed

Resolve the target directory. If it is not inside a git repository (`git rev-parse
--is-inside-work-tree` fails), **ask the user to confirm** before running `git init` there —
this command must never silently turn an arbitrary directory into a repo. If the user
declines, stop here (see Abort rules) — nothing downstream has a repo root to key off.

If already a git repo, report that and move on (idempotent no-op).

### 2 — Classify the repo

Apply `${CLAUDE_PLUGIN_ROOT}/references/dev/repo-classification.md` in full — this command
is one of the two places (with `setup:stack`) that *runs* detection.

1. **If `STACK.md` already exists and its frontmatter has a `class:` field, that value
   always wins.** Report it ("already classified: `corporate`") and skip straight to Step 3
   — never re-detect or second-guess an existing `class:` (override semantics are absolute,
   per the reference doc). If the live remote-host guess would differ, mention the mismatch
   as an FYI only — do not offer to change the field; the user edits STACK.md directly if
   they want to correct it.
2. **Otherwise, detect.** Read `git remote get-url origin` (first remote if `origin` is
   absent). Read the active config (`cc.config.local.json` if present, else
   `cc.config.json`) for its `classification` block:
   ```json
   "classification": {
     "personal_owners": [...], "work_owners": [...], "work_owner_suffixes": [...]
   }
   ```
   **This block may not exist yet** (it lands with the config-wiring task) — treat a
   missing/empty block as "no lists configured," which means the owner/suffix rows of the
   detection table can never match. That is not an error; it simply means every repo falls
   through to the host-pattern rows (`dev.azure.com`, `*.visualstudio.com`, known corporate
   forge hosts) and, failing those, to the **ask-when-ambiguous** row. Apply the table
   in order:
   - owner ∈ `personal_owners` → `personal`
   - owner ∈ `work_owners`, or owner ends with a `work_owner_suffixes` entry → `corporate`
   - Azure DevOps hosts → `corporate`
   - known corporate-forge hosts → `corporate`
   - public forge, owner matches no list → `shared-oss`
   - no remote, or unknown/unlisted host → **ambiguous**
3. **Ambiguous → ask, if interactive.** In an interactive session, ask exactly: **"Is this a
   work repo? (y/n)"** and set `class:` from the answer (`y` → `corporate`, `n` → treat the
   repo like the shared/personal question needs one more beat — if `n`, follow up once:
   "Is it your own repo, or someone else's you're contributing to?" to land on `personal` vs
   `shared-oss`). In a **non-interactive** session (headless/chain), asking is impossible:
   default to `corporate` for this invocation and flag the classification as unresolved in
   the output — the same fail-safe asymmetry the reference doc specifies (a wrongly cautious
   `personal` guess costs a one-line override later; a wrongly open `corporate` guess can
   leak).
4. **Always confirm the result with the user** before writing it — even a confident,
   unambiguous detection. One line: "Classifying this repo as **`<class>`** (`<reason>`) —
   sound right?" A "no" lets the user state the correct class directly rather than re-running
   detection.

### 3 — Generate STACK.md, then add `class:`

Run `/cc:setup:stack` semantics (invoke via the SlashCommand tool if available, else apply
its steps inline) **only if `STACK.md` does not already exist** — this command does not
force a stack regen on every init. Order matters: stack detection runs first and produces
the full manifest, *then* this command inserts the `class:` field from Step 2 into that
manifest's frontmatter (right after `stack:`, before `components:`), matching the schema in
`references/dev/stack-resolution.md`:

```markdown
---
stack: <detected>
class: <personal|corporate|shared-oss>
components:
  ...
---
```

If `STACK.md` already existed (Step 2 case 1: had `class:` already, or existed without one),
don't regenerate it — just confirm it has the `class:` line (adding it if it was the "existed
without one" case) and leave everything else untouched.

### 4 — Scaffold `[WORKSPACE_DIR]/`

Create, if absent: `[WORKSPACE_DIR]/plans/`, `[WORKSPACE_DIR]/reports/`,
`[WORKSPACE_DIR]/code-reviews/`. Report "present, skipped" for any that already exist.

Append `.gitignore` entries appropriate to the class just written — this is dev-workflow
scaffolding, distinct from the deals workspace (a separate repo entirely; see
`references/presales/deals-workspace.md` — sales/deal/radar artifacts never land here
regardless of class, they redirect there):

- **`shared-oss`** — ignore `[WORKSPACE_DIR]/` entirely (one line: `[WORKSPACE_DIR]/`). Per
  the safeguard matrix's warning rationale: plans/reviews/reports are legitimate for your
  own work but must not ride into an upstream PR you don't own the tree of.
- **`personal` / `corporate`** — track it; add no ignore entry. Plans, code reviews, and
  execution reports are legitimate work product of the codebase they're about (the matrix's
  `.specify/` row is "allowed" in both).

Skip the append if the exact entry is already present (idempotent).

### 5 — Offer CI (don't force)

Ask whether to run `/cc:setup:ci` now (invoke via the SlashCommand tool on a yes). This is
an offer, not a default action — decline leaves nothing written and isn't an abort condition
for the rest of this command.

### 5b — Offer reference components (when a library is configured)

Resolve the portfolio's component reference library per
`${CLAUDE_PLUGIN_ROOT}/references/dev/component-reference-library.md`. **No library
resolves → skip this step silently** (no mention in output beyond the status row).

If a library resolves **and** it carries a stack directory matching this project's
detected stack, offer per-family copies — one multi-select question, default none:
"Copy reference component families? (e.g. forms / auth / data / shell / none)" — listing
the families the library actually has for that stack. On a selection, copy per the
reference doc's copy-semantics table (component source + NOTES.md to the stack's
destination; never `_demo/`, examples, or `CONVENTIONS.md`), then record the traceability
line (families + library commit) in the CLAUDE.md stub or `[WORKSPACE_DIR]/reports/`.
Declining copies nothing and isn't an abort condition. Idempotent: if a destination
component dir already exists, report "present, skipped" for it rather than overwriting.

### 6 — Plant per-repo plugin settings (personal only, gated)

Per the safeguard matrix, this is the one command-family cell with real per-class variance:

| Class | Behavior |
|---|---|
| `corporate` | **Never planted.** Print: "Settings not planted — this repo is classified `corporate`. Personal marketplace/plugin config does not belong in an employer's tracked tree, even gitignored-adjacent. Install at user scope on this machine instead." Do not ask. |
| `shared-oss` | **Never planted.** Print: "Settings not planted — this repo is classified `shared-oss`. You don't own this tree; planted config would ride into your next PR. Use user-scope install or `claude --plugin-dir`." Do not ask. |
| `personal` | Proceed to the gate below. |

**For `personal` repos**, planting `.claude/settings.json` (the `imperium` marketplace +
`cc@imperium`, same shape as this repo's own root `.claude/settings.json`) needs the user's
confirmation **and** is gated on **Probe P1** (plan Task 0.2: does a github-source
marketplace pointing at a private repo resolve and prompt on a fresh Claude Code **web**
session?). P1 had not run as of this command's authoring — both outcomes are designed so no
future probe result forces a redesign, only a branch choice:

1. **Look for a recorded result** — `.specify/reports/portfolio-review.md`, a line
   containing "Probe P1". If found:
   - **recorded pass** → plant normally (see file content below), no caveat needed.
   - **recorded fail** → **skip branch**: don't plant. Print: "Probe P1 (web marketplace
     fetch) failed on this portfolio — planting a per-repo settings file wouldn't help web
     sessions here. Use `claude --plugin-dir <path-to-imperium>/global` on web, or install
     at user scope for local machines." Same effect as the corporate/shared-oss refusal, but
     phrased as a probe result, not a class refusal.
2. **No recorded result (the common case today)** → **plant-with-caveat branch**: this is a
   `personal` repo (open posture, no leak risk — worst case is an unused file), so bias
   toward planting rather than withholding. Ask the user to confirm, then write
   `.claude/settings.json`:
   ```json
   {
     "extraKnownMarketplaces": {
       "imperium": { "source": "github", "repo": "<owner>/imperium" }
     },
     "enabledPlugins": { "cc@imperium": true }
   }
   ```
   Resolve `<owner>/imperium` from the installed plugin's own origin if it's a reachable git
   checkout (`git -C "$(dirname "$CLAUDE_PLUGIN_ROOT")" remote get-url origin`, parsed for a
   `github.com/<owner>/<repo>` shape); if that fails, ask once: "What's your imperium fork's
   GitHub `owner/repo` (e.g. `yourname/imperium`)?" Then print the caveat: "Planted
   `.claude/settings.json` — Probe P1 (does this actually prompt on Claude Code **web**) is
   unresolved. On a Mac this plants fine either way. If you're on web and it doesn't prompt,
   fall back to `claude --plugin-dir <path>/global`. Once P1 resolves, re-run this step: a
   recorded pass needs no change, a recorded fail means switch to not planting here."
3. If `.claude/settings.json` already exists with equivalent content, report "present,
   skipped." If it exists with different content, show the diff and confirm before
   overwriting — same convention as `setup:stack`'s STACK.md handling.

### 7 — Print the Operating Cadence card + next steps

Print a condensed cadence card (full table: `CLAUDE.md` → Operating Cadence):

```
ONE-TIME     accept plugin install prompt · /cc:setup:configure (identity)
             per project: /cc:setup:stack → /cc:setup:ci
RECURRING    Mon  /cc:radar:scan            Fri  /cc:verify:dependencies
             Monthly  /cc:maintain:audit    Before committing plugin edits: cc-audit.sh
             Ending a session mid-task: /cc:pause  (resume: /cc:prime --resume)
```

Then the next step, based on what this run found:

- **No project charter exists** (`[WORKSPACE_DIR]/plans/project-charter-*.md` absent) *and*
  the repo looks greenfield (was just `git init`'d this run, or has no source files beyond
  what this command just created) → suggest `/cc:plan:project` to run the inception
  interview before writing any code.
- **Otherwise** (existing codebase, or a charter already present from a prior
  `/cc:plan:project` run) → suggest `/cc:prime` to load full project context before the next
  piece of work.

## Output

```
SETUP: PROJECT — <path>
────────────────────────────────────────────────────────
git repo         <initialized | already present>
class            <personal|corporate|shared-oss>  (<how determined>)
STACK.md         <written | already present, class: added | already present, unchanged>
[WORKSPACE_DIR]/  plans/ reports/ code-reviews/  <created | present, skipped>
.gitignore       <[WORKSPACE_DIR]/ ignored (shared-oss) | tracked, no entry added>
CI               <written | offered, declined | already present | not offered — declined upstream>
components       <copied: <families> @ <library-commit> | offered, declined | no library | no stack match>
settings.json    <planted | planted with P1 caveat | skipped (probe fail) | refused (class) | present, skipped>

Next: /cc:plan:project   — or —   /cc:prime
```

## Quality checklist

- [ ] Git init only happened after explicit confirmation (never silent)
- [ ] Classification followed the reference doc's table in order; ambiguity asked (or,
      non-interactive, defaulted `corporate` and flagged it) rather than guessing
      shared-oss/personal
- [ ] An existing `class:` in STACK.md was never overwritten or re-derived
- [ ] STACK.md regenerated only when absent; `class:` inserted without disturbing an
      existing manifest's components
- [ ] `[WORKSPACE_DIR]/` gitignore treatment matches the class (ignore only for shared-oss)
- [ ] CI was offered, never forced
- [ ] Reference components were offered only when a library resolved with a matching
      stack, copied only on explicit selection, and the copy was recorded with the
      library commit; existing destinations were never overwritten
- [ ] Settings planting happened in `personal` repos only, only after user confirmation, and
      respected whichever P1 branch applied (recorded pass/fail, or the plant-with-caveat
      default when unresolved)
- [ ] Corporate/shared-oss repos got the refusal notice, never a settings file, and were
      never asked
- [ ] A re-run reports "present, skipped" per artifact and changes nothing unprompted

## Handoff

**Chain:** greenfield repo with no charter yet → hand off to `/cc:plan:project` to run the
inception interview; its output (`[WORKSPACE_DIR]/plans/project-charter-<name>.md`) names
slice 1 as the first `/cc:plan:feature` candidate, continuing the PIV chain into
`/cc:piv:ship`.

**Solo:** existing project → suggest `/cc:prime` to load context before the next task.

**Abort rules:** user declines `git init` on a non-repo target → stop; nothing else in this
command has a root to key off. Classification is contested (user disagrees with the
detected/asked result) → don't argue it — tell the user to set `class:` in STACK.md
manually and re-run this command, which will then read and respect that value per the
override semantics.
