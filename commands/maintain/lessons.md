---
description: Re-harvest project LESSONS.md files into the shared lessons-learned reference — additive, generalized, dated
argument-hint: [project path, or blank to scan sibling repos]
---

# Maintain: Re-harvest Lessons

Pull new lessons out of project `LESSONS.md` files and fold the transferable ones into the
shared cross-project reference at `${CLAUDE_PLUGIN_ROOT}/references/dev/lessons-learned.md`.
That file's header defines the contract this command executes: only project-agnostic lessons
cross over, rewritten in generalized wording, keeping the date each lesson was earned —
project-specific rules stay in the project's own file. Run this after a project's LESSONS.md
has grown (a fresh burn, a finished milestone), or periodically across all projects. When
working inside the plugin repo, edit the working copy at
`global/references/dev/lessons-learned.md` so the change ships.

**Binding rules (from the reference's header — preserve them):**

- **Additive only.** Append new entries into existing thematic sections. Never delete,
  rewrite, or reorder existing entries; never renumber sections.
- **Generalize, don't flatten.** Strip project names, paths, and app-specific APIs into
  generic equivalents — but keep the incident: the mechanism and the burn are the pedagogy.
- **Dates mark when the lesson was earned,** never when it was harvested. Preserve them.
- **Two layers, on purpose.** The reference is the cross-project layer; each project keeps
  its own LESSONS.md (read every session by `/cc:prime`). This command copies the
  generalized form upward — it never empties or edits the source file.

## Steps

### 1 — Locate source LESSONS.md file(s)

If the argument names a project path, the source is `<that path>/LESSONS.md` — if the file
does not exist there, say so and stop. With no argument, scan likely project roots — the
parent folder of the current repo:

```bash
# Sibling project roots: LESSONS.md files at depth 2 under the parent of this repo
find "$(dirname "$PWD")" -maxdepth 2 -name "LESSONS.md" \
  -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/.claude/*" 2>/dev/null
```

(If the current checkout is nested — e.g. a git worktree — start the scan from the real
projects folder instead.) List what was found — project, path, rough entry count — and
confirm the scope with the user before reading further: some sources may be out of bounds
for a shared reference (client work, archived repos). Nothing found → report that, point at
the reference's "Keeping a LESSONS.md" section for the starter format, and stop.

### 2 — Build the already-harvested set

Read `${CLAUDE_PLUGIN_ROOT}/references/dev/lessons-learned.md` in full. For each candidate
lesson from step 1, decide whether its substance is already present — match on the rule's
mechanism, not its wording, because lessons get rephrased when generalized (a project entry
about jest workers OOM-ing in CI may already live on as "bound test-worker memory; reproduce
CI's constraints locally"). When in doubt, treat it as already present: a near-duplicate
entry costs more than a missed nuance.

### 3 — Classify, then generalize

For each lesson not yet in the reference, classify it:

- **Project-specific — stays put.** The rule only means something inside that project's
  stack, files, or product decisions (one library's API quirk with no cross-stack analogue,
  a product-decision record, a workaround pinned to one version). Say why, in one line each;
  do not port these.
- **Transferable — rewrite to the reference's register.** Generalize the way the existing
  entries read: project names and paths become generic equivalents ("a heavy module graph",
  "the runner's bootstrap"), the earned `(YYYY-MM-DD)` date stays, and the incident-driven
  flavor stays — symptom, root cause, generalized rule. If the general form collapses into a
  truism ("test your code"), the transferable part wasn't real; leave it project-specific.

### 4 — Propose, then append on approval

Show the user the proposed additions grouped under the reference's existing thematic
sections (read the current section list from the file — git hygiene, CI discipline, module
graph, and so on). If a lesson fits no existing section, propose a new numbered section
appended after the last one. On approval, APPEND the new entries into those sections —
never delete or rewrite existing entries, never renumber. The project's residue (exact
files, exact APIs) stays in the project's own LESSONS.md, per the reference's "promote
upward" rule.

### 5 — Report

```
Lessons re-harvest — <date>
───────────────────────────
Sources scanned:        2 (appA/LESSONS.md, toolB/LESSONS.md)
Lessons found:          14
Already harvested:       6 (matched on substance)
Added to reference:      5 (→ sections 2, 5, 7)
Left project-specific:   3 (reasons above)
```

Close by restating the division of labor, so nobody "cleans up" the wrong layer later: the
plugin reference is the cross-project layer; each project keeps its own LESSONS.md, and
`/cc:prime` reads the project file every session. If the reference changed, run
`bash global/scripts/cc-audit.sh` from the plugin repo root before committing.
