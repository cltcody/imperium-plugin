---
name: device-qa
description: |
  Maintain a project's Device-QA tracker — the running board of QA that automated gates
  (typecheck/test/lint, cloud CI) and even the e2e suite can't judge, so a human must verify it
  on a real build/device: audio to hear, visuals to eyeball, biometric/Face ID, store-sandbox
  purchases, small-screen truncation, e2e flows authored-but-not-yet-run. Two modes — recompile
  the whole board from open QA-labelled issues + the "NOT YET RUN ON DEVICE" notes in the repo
  docs, or append a single item as it's discovered — then open a docs-only PR. Project-agnostic:
  reads per-repo labels/paths from the tracker's own config block and the automatable-vs-on-device
  boundary from STACK.md. Complements /cc:verify:e2e (which RUNS the e2e suite); this TRACKS the
  manual on-device work that no suite covers. Use on "device qa", "update the device-qa board",
  "record device qa", "what needs on-device verification", or after finishing work that leaves
  something to verify on device.
disable-model-invocation: true
---

# Device-QA Tracker

Keeps a repo's **Device-QA tracker** current — a single markdown board (default `DEVICE-QA.md`
at the repo root) of QA that automated gates can't judge, so a human must run it on a real
build/device. `/cc:verify:e2e` *runs* the automated e2e suite; this skill *tracks* the manual
on-device work that even a green e2e run leaves unverified. The board must not drift.

**Scripts don't do the thinking — you do.** Data collection is inline `gh` + `grep` (no API
key); the ranking, categorising, and pruning is this session's judgment.

## First: read the config block and the stack manifest

**Config block** — every tracker ends with an HTML-comment config that tells this skill how to
refresh *that* repo. Read it before anything else:

```
<!--
device-qa config (read by the `device-qa` skill):
  tracker: DEVICE-QA.md
  auto-block: between the device-qa:auto:start / :end markers
  issue-labels: ["qa: pre-launch", "QA"]
  doc-scan: [".maestro/README.md", "LESSONS.md"]
  stack-manifest: STACK.md
  repo: <owner>/<name>
  pr: docs-only
-->
```

No tracker yet? Offer to scaffold one (header prose + empty `device-qa:auto` block + config)
and stop for a human to fill the prose. Tracker but no config block? Infer defaults (labels
`qa`/`QA`; scan `*/README.md` + a `LESSONS`/`lessons` file) and add a config block in the same PR.

**Stack manifest (`STACK.md`)** — this is what *frames the board*. Resolve it per
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` (handle multi-component projects; skip
gracefully if absent):

- Its `smoke` / `test` / `typecheck` / `lint` / `build` steps are the **automatable** gates —
  work those verify does **not** belong on this board.
- Its `e2e:*` steps (and anything its prose flags **local / macOS-only / opt-in / device /
  Release-build**) are exactly the surface that **does**. Cite the manifest's **real** command
  in each row (`e2e:setup` → its resolved script, then `e2e:smoke` / `e2e`) rather than inventing
  one, and honour any noted preconditions (dedicated simulator, Release-not-dev-client, a build
  baked **after** source is final). If `STACK.md` and a row disagree on the command/boundary,
  `STACK.md` wins — flag the drift.

## Modes

- **Add-one** ("record device qa for X", or at the end of a work session): append one row to the
  correct auto-block section for the item just found. Cheapest path — no full sweep; prefer it
  during normal development. Make sure a backing issue exists and is labelled so a later
  recompile can find it; if none exists, say so and offer to file it.
- **Recompile** ("update the device-qa board" / "refresh"): rebuild the whole auto-block from
  scratch (below). Prunes items whose issue closed; catches doc-note items nobody added by hand.

## Recompile steps

1. **Window** — default the trailing 14 days; a bare number in the args overrides (days). The
   board is *open* work, so include older still-open items too — the window only bounds the
   "recently surfaced" log, never what counts as open.
2. **Collect (deterministic):**
   - Issues: `gh issue list --repo <repo> --state open --label "<label>" --json number,title,labels,updatedAt,url --limit 200` per configured label; union them.
   - Doc notes: `grep -nEi "NOT YET RUN ON DEVICE|device[- ]QA|verify on device" <doc-scan paths>` — device-QA items that live in prose, not (yet) an issue.
   - Stack boundary: resolve `STACK.md` (above) so rows cite real commands and nothing automatable slips onto the board.
   - Current board: read the rows between the `device-qa:auto` markers, to diff against.
3. **Reconcile (judgment):**
   - **Prune** any row whose issue is closed/merged-and-verified (`gh issue view <n> --json state,stateReason`), and any doc-note whose marker is gone.
   - **Keep** open items; **add** newly-found issues/doc-notes not already on the board.
   - **Categorise** into the board's sections (functional/content QA · e2e flows authored-but-not-run · acoustic/hardware capture · standing limitations · code sweeps flagged for device). One row per item; one crisp "what to verify, on which build".
   - Dedup: an item that is both an issue and a doc-note is ONE row (cite the issue).
4. **Rewrite only the auto-block** — replace everything between `device-qa:auto:start` and `:end`;
   leave the header prose and config comment untouched. Refresh the "last refreshed" line and the
   trailing dated "recently surfaced" log (newest first).
5. **Open a docs-only PR** — branch, commit the single tracker file (root `*.md` → the docs-skip
   CI fast path where the project has one), push, open the PR. Summarise adds/prunes in the body.
   **Never merge without human review** — the board's judgment calls (what's really done, what's
   a dup) deserve eyes. If the project has `/cc:github:pr`, use it; else `gh pr create`.

## Rules

- **One tracker file per PR** — keep it docs-only so CI stays cheap; never fold source changes in.
- **The issue is the source of truth; the board is the mirror.** Never invent a row with no
  backing issue or doc-note — if something needs tracking and has neither, file the issue first.
- **Prune conservatively** — drop a row only when its issue is genuinely closed or its doc-note
  removed. "Probably done" stays until confirmed (same discipline as not ticking a QA box you
  didn't watch).
- **Skill-owned block only** — everything outside the `device-qa:auto` markers is human prose;
  never rewrite it.
- **On-demand, no cron** — the systematic upkeep is the host repo's add-as-you-go convention
  (its CLAUDE.md / PR template) plus this recompile when a sweep is wanted.
