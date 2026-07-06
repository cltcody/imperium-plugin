# The Deals Workspace

One private git repo is the canonical, cwd-independent home for **every** sales, deal, and
radar artifact the cc commands produce. Commands resolve their output paths against this
workspace — never against the repo you happen to be standing in. Throughout this file,
`<deals-workspace>/` means the root resolved by the rule in "Resolving the workspace path"
below; it is a runtime resolution, not a `cc-apply` placeholder.

---

## What this kills, and why

Two failure modes existed before this convention, and this workspace ends both:

1. **Artifacts scattered into whatever repo you're standing in.** Sales commands used to
   write under the current project's `[WORKSPACE_DIR]` (`.specify/`), so an exposure brief
   or PoC readout landed in whichever repo the session happened to be in — including
   corporate repos, where a customer-named deal document in the tracked tree is a
   confidentiality leak, not just clutter. The workspace makes output location a function
   of the artifact, not of the cwd.

2. **Radar state fragmentation.** `/cc:radar:scan` kept `radar/state.json` per repo, so N
   repos × 2 machines meant N×2 diverging baselines: the same regulatory change reported
   as "new" in every location it hadn't been seen from, and no location holding the true
   last-checked picture. The workspace holds **one** `radar/state.json` — see "Radar state
   is singular" below.

---

## Layout

```
<deals-workspace>/
├── accounts/     # account-level intelligence
│   ├── brief-<company-slug>.md         # /cc:account:brief
│   ├── exposure-<company-slug>.md      # /cc:account:exposure
│   └── watchlist.md                    # hand-maintained; read by radar:scan + radar:brief
├── deals/        # opportunity-level work product
│   ├── poc-plan-<name>.md              # /cc:deal:poc-plan
│   ├── poc-readout-<name>.md           # /cc:deal:poc-readout
│   ├── proposal-<name>.md              # /cc:deal:proposal (when saved)
│   ├── exec-summary-<name>.md          # /cc:deal:exec-summary (when saved)
│   └── champion-pack-<name>.md         # /cc:deal:champion-enable (when saved)
├── radar/        # regulatory-radar state and output
│   ├── state.json                      # THE one scan baseline — singular, see below
│   └── digests/
│       └── radar-scan-<date>.md        # /cc:radar:scan digest copies (MAJOR-bearing runs)
└── rfp/          # responses library feed
    └── response-<account>-<year>.md    # /cc:rfp:respond drafts + approved responses
```

Rules of the layout:

- **Exactly one home per artifact type.** The table above is exhaustive for file-writing
  behavior: if a sales/deal/radar/rfp command writes or offers to save an artifact, it goes
  to the path named here. Commands whose output is conversation-only (e.g. `/cc:radar:brief`
  shortlists, `/cc:value:roi-case` cases, discovery summaries) stay inline by default; when
  the user asks to save one, it goes under the nearest of these four directories
  (`accounts/` if account-scoped, `deals/` if opportunity-scoped) — never into the current
  repo and never into a fifth ad-hoc directory.
- **Radar state is singular.** `radar/state.json` in this workspace is the only radar
  baseline that exists. A `/cc:radar:scan` run from any cwd, on any machine, reads and
  writes this one file. Per-repo radar state is a migration artifact, not a valid location
  (see Migration below). The same goes for digest copies: MAJOR-bearing digests save to
  `radar/digests/`, not to the current repo's `reports/`.
- **`rfp/` is the feed, not the library.** Working responses accumulate here; once a
  response is approved, promote a copy into the plugin's
  `${CLAUDE_PLUGIN_ROOT}/references/presales/rfp-library/` per that library's README so the
  RFP commands can reuse its language. The workspace copy remains the account-specific
  record.
- Dev-workflow output (plans, code reviews, execution reports, session cursors) is **not**
  sales material and stays in the per-project `[WORKSPACE_DIR]` — this workspace holds
  customer- and deal-facing artifacts only.

---

## Resolving the workspace path

Commands resolve the workspace root in this order — first hit wins:

1. `paths.deals_workspace` in `cc.config.json`
2. the `CC_DEALS_WORKSPACE` environment variable
3. the default: `~/code/deals-workspace`

**When the resolved path does not exist:** the command tells the user what it resolved and
why, then **offers to create the directory and `git init` it** (as a private repo — see
Sync below). It never silently writes anywhere else, and it **never falls back to the
current repo** — not to `[WORKSPACE_DIR]`, not to cwd, not to a temp dir. If the user
declines creation, the command prints its artifact inline in the conversation and writes no
file. If the path exists but is not a git repo, offer `git init` the same way; if it exists
but is a file, stop and report the misconfiguration.

### Corporate machines: two workspaces, zero cross-contamination

A corporate machine runs its **own, separate** workspace: point `paths.deals_workspace` (or
`CC_DEALS_WORKSPACE`) on that machine at a work-side path whose remote — if it has one at
all — is work-hosted. Work-produced deal artifacts never sync to personal GitHub, and the
personal workspace repo is never cloned onto or pushed from the corporate machine. Because
the workspace is selected per-machine by config, the two sides never see each other: no
shared remote, no shared path, no file ever eligible for both. The one thing that is shared
is this convention — same layout, same resolution rule, different root. Repo-class
safeguards on top of this (what a `corporate`-classed repo may ever receive) are defined in
`${CLAUDE_PLUGIN_ROOT}/references/dev/repo-classification.md`; this file only fixes where
sales artifacts go, that one fixes what each repo class refuses.

---

## Sync stance: it's a git repo — commit/push IS the sync

The workspace syncs across personal machines the way any repo does: commit, push, pull.
Recommended setup is a **private GitHub repo** (`gh repo create deals-workspace --private`)
cloned to the resolved path on each personal machine. No hooks, no store, no gate — after a
session that wrote artifacts, commit and push; before relying on radar state from another
machine, pull. Commands may offer a commit after writing; pushing stays a user action.

Deal artifacts deliberately do **not** ride the memory store (see
`docs/memory-sync-runbook.md` for that mechanism), because every property that makes the
store right for memory makes it wrong for work product:

- **Size and shape** — the store moves small per-project memory files on session hooks;
  briefs, readouts, and RFP responses are large, numerous, and grow without bound.
- **Reviewability** — deal artifacts need real history: `git log` for what changed before a
  readout went out, `git diff` for review, branches if two machines edit the same brief.
  The store's hook-driven push is deliberately invisible; that is the opposite of what a
  customer-facing document needs.
- **Denylist semantics** — the store's block-and-hold denylist gate exists to keep flagged
  terms from leaving via an automatic background channel. Applied to primary work product
  it would hold your own deliverable hostage on a false positive. The gate does **not**
  apply to the deals workspace — nothing here leaves by any channel other than your own
  deliberate `git push` to the workspace's own private remote.

Two hard lines replace the gate: the workspace repo must **never be public**, and it must
never appear on the corporate machine under a personal remote (nor the work-side workspace
under one) — the rationale and enforcement live in `repo-classification.md`, per the
corporate-machines paragraph above.

---

## Migration: the one-time sweep

Existing artifacts are scattered across project `.specify/` dirs from the pre-workspace
era. Run this sweep once per machine (a sonnet agent can execute it verbatim):

1. **Find candidates.** Across your project roots (e.g. `~/code`, `~/Developer`):
   `find ~/code ~/Developer -maxdepth 5 -path '*/.specify/*' \( -path '*/accounts/*' -o
   -path '*/deals/*' -o -path '*/radar/*' -o -name 'radar-scan-*.md' \) -type f`.
   Also catch strays by name: `exposure-*.md`, `brief-*.md` (account briefs only — not
   `radar:brief` output), `poc-plan-*.md`, `poc-readout-*.md`, `watchlist.md`.
2. **Merge radar state — don't just pick a file.** If more than one `state.json` turns up,
   union their `sources` maps into one: for each source name, keep the entry with the
   newest `last_checked` (its `last_known_items` ride along). Write the merged result to
   `<deals-workspace>/radar/state.json`. Discard the originals only after the merge is
   written and valid JSON.
3. **Merge watchlists.** Concatenate all found `watchlist.md` files, dedupe by account
   name, keep the union of annotations (when two lines annotate the same account
   differently, keep both annotations on one line). Result:
   `<deals-workspace>/accounts/watchlist.md`.
4. **Move everything else** into its layout home above (`mv`, or `git mv` where the source
   was tracked). On a filename collision between repos, suffix the older file with its
   source repo name and keep both.
5. **Leave a pointer.** In each vacated `.specify/accounts|deals|radar/` directory, leave a
   one-line `README.md`: "Moved to the deals workspace — see
   references/presales/deals-workspace.md in the cc plugin." Then commit the removals in
   each source repo.
6. **Corporate caveat.** If any artifact was tracked in a corporate repo, moving it is
   remediation, not just tidying — note that the repo's **history** still contains it and
   flag that to the user; whether history gets rewritten is their call, not the sweep's.
7. **Commit the workspace** as the final step, so the sweep lands atomically.

---

## Command integration contract

This paragraph is the normative behavior for every sales/deal/radar/rfp command that reads
or writes a workspace artifact — command files reference this section instead of restating
it:

> **Resolve** the workspace root via `cc.config.json paths.deals_workspace`, else
> `CC_DEALS_WORKSPACE`, else `~/code/deals-workspace`, and resolve all artifact paths from
> this file's Layout against that root — regardless of cwd. **If the root is missing** (or
> not a git repo), say so, name the resolved path, and offer to create + `git init` it as a
> private repo; on decline, deliver the artifact inline and write nothing. **Refuse every
> fallback**: never write a sales artifact into the current repo, `[WORKSPACE_DIR]`, or any
> path outside the workspace, silently or otherwise. **In a `corporate`-classed repo**, add
> the one-line redirect notice required by `repo-classification.md` — the destination is
> the workspace either way. **Radar state** is always `<deals-workspace>/radar/state.json`
> — one file, every cwd, every machine.

Reads follow the same resolution: a command that consumes `accounts/watchlist.md` or globs
`deals/poc-plan-*.md` looks in the workspace, and treats an absent workspace as "no
artifacts yet" (the graceful empty path), not as a license to search the current repo.
