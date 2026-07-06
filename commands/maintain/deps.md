---
description: Dependency UPDATE loop — apply verify:dependencies findings in risk tiers (security, then patch/minor, majors only with --major), each tier gated by STACK.md's verify steps and rolled back independently on red
argument-hint: [--major]
disable-model-invocation: true
---

# Maintain: Dependency Update Loop

Apply the findings from `/cc:verify:dependencies` — that command audits and stops; nothing else
in the plugin owns turning its findings into actual upgrades (see its "Applying updates"
section, which hands the job off to exactly this command). Renovate-style: batch what's safe,
isolate what's risky, verify after every batch against the project's own verify gate, and never
leave a broken bump sitting on disk.

Like the audit it builds on, this command is **package-manager-driven**: the concrete update,
resync, and rollback commands for each component come from that component's `package_manager` in
the project's `STACK.md`, resolved per
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` — never hardcoded to one ecosystem.

## Steps

### 1. Resolve the stack and run the audit

Read `STACK.md` and resolve every component's `working_dir`, `package_manager`, and
manifest/lockfile per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. Then invoke
`/cc:verify:dependencies` with the SlashCommand tool to get the current findings — do not
re-implement its scanning logic here; this command consumes its output.

If no component resolves a dependency manifest at all (no `package.json`, `pyproject.toml`,
`Cargo.toml`, `go.mod`, etc. anywhere) → **stop**, report "not applicable — no dependency
manifests detected," the same abort rule the audit itself uses.

### 2. Categorize into risk tiers

From the audit's findings, sort every outdated/vulnerable package, per component, into exactly
one tier:

| Tier | Contents | Runs when |
|------|----------|-----------|
| **Security** | Any package with a known CVE (the audit's 🔴/🟠 findings) | Always |
| **Patch + minor** | Everything else outdated by a patch or minor version | Default |
| **Major** | Outdated by a major version bump | Only with `--major` |

A package that has both a CVE and a major-version fix available goes in **Security**, pinned to
the minimal version that closes the CVE (per the audit's own guidance) — never bundle a security
fix with an unrelated major bump.

If every tier is empty, report `Clean — nothing to update` and stop; there is no point running
gates against a no-op change set.

### 3. Confirm the commit strategy once

Before touching anything, ask once: **"Commit each green tier as we go? (y/n)"** Capture the
answer for the whole run — every tier below follows it without asking again. `n` means apply and
verify normally but leave the results staged/unstaged for the user to review and commit
themselves at the end; it does not skip verification or rollback.

### Rollback mechanics (used by every tier below)

Before applying a tier (or, inside Tier 3, before each individual package), snapshot that
component's manifest + lockfile — copy them aside, or `git stash push -- <manifest> <lockfile>`
if nothing else touches those paths yet. On a red gate, restore the snapshot and re-run that
component's resync command (mechanics table, third column) so the installed packages match the
restored lockfile again.

Snapshotting per tier — rather than trusting a blanket `git checkout` against the last commit —
matters specifically when the user declined per-tier commits in Step 3: a plain `git checkout --
<manifest> <lockfile>` after Tier 2 would also erase Tier 1's still-uncommitted security fix.
When commit-per-tier is enabled, each tier is committed before the next begins, so `git checkout`
against the last commit and the snapshot approach agree — use the snapshot approach uniformly so
the mechanics don't change based on the user's answer in Step 3.

### 4. Tier 1 — Security (always)

Batch-pin every CVE-flagged package to its fixed version, per component, using that component's
`package_manager` (mechanics table below). Then run the resolved verify gate — invoke
`/cc:verify:run` with the SlashCommand tool, which resolves `smoke → test → typecheck → lint →
format:check` per component from `STACK.md` — for **every** component, not just the one that
changed; a lockfile resolution can shift shared transitive versions across components in a
monorepo.

- **GREEN** → if the user opted into per-tier commits, commit now:
  `chore(deps): security patches — <pkg>@<old>→<new> (CVE-id), …`. Continue to Tier 2.
- **RED** → restore the Tier 1 snapshot, resync, report the failure and the packages involved,
  and **stop hard** — do not proceed to Tier 2 or Tier 3. Route to `/cc:verify:debug` with the
  failing step and its output. A security fix that breaks the build needs a human decision, not
  a silent downgrade to "ship the rest and skip this one."

### 5. Tier 2 — Patch + minor (default)

Batch-apply every patch and minor bump per component in one pass (the package manager's
"upgrade within declared range" command — mechanics table). Skim release notes for anything
minor with a notable changelog entry, but don't gate the batch on reading every one of them —
that's what the verify gate below is for.

Run the verify gate the same way as Tier 1 (`/cc:verify:run`, every component).

- **GREEN** → commit if opted in: `chore(deps): patch/minor updates — <pkg>@<old>→<new>, …`
  (every package in the batch). Continue to Tier 3 if `--major` was passed; otherwise go to
  Step 6.
- **RED** → restore **only the Tier 2 snapshot**, resync, report which packages were in the
  batch and what failed. **Continue** to Tier 3 if requested — a red patch/minor batch doesn't
  disqualify majors; they're an independent risk pool with their own gate.

### 6. Tier 3 — Major (only with `--major`)

Majors are never batched — apply and verify **one package at a time**:

1. Read that package's changelog / release notes / migration guide before touching anything —
   `gh release view --repo <org>/<repo> v<version>` if it's hosted on GitHub, or a web search for
   the project's changelog/upgrade guide otherwise. Note breaking changes relevant to how this
   project actually uses the package (grep for the symbols the changelog calls out).
2. Snapshot, then apply just that package's major bump (mechanics table — same shape as the
   security-pin column, target version is the new major instead of the CVE fix).
3. Run the verify gate for every component (`/cc:verify:run`).
4. **GREEN** → keep it, add it to the tier's passed list, move to the next major.
5. **RED** → restore that package's snapshot, resync, report which package and what failed, and
   move to the next major anyway — one bad major doesn't block trying the rest.

After every major has been attempted, if the user opted into per-tier commits and at least one
passed: one commit for the whole tier, `chore(deps): major upgrades — <pkg>@<old>→<new>, …`
(only the packages that passed — failed ones were already rolled back and are absent from the
diff).

### 7. Report

Compile the summary table (Output below) and close by pointing at
`${CLAUDE_PLUGIN_ROOT}/references/dev/scheduling.md`'s Recipe 1 — this command is naturally the
second half of that recipe: audit weekly, then run this loop against whatever it finds.

## Ecosystem mechanics

The concrete commands per `package_manager`, extending `/cc:verify:dependencies`'s audit table
with the update and resync side. "Resync" is what Rollback mechanics above runs after restoring
a snapshot.

| `package_manager` | Security pin / single-package bump | Patch+minor batch | Resync after restoring a snapshot |
|---|---|---|---|
| `uv` | `uv add <pkg>==<fixed>` | `uv lock --upgrade && uv sync` | `uv sync` |
| `poetry` | `poetry add <pkg>@<fixed>` | `poetry update` | `poetry install` |
| `pip` | edit the pin in `requirements*.txt`, `pip install -r requirements*.txt` | `pip-compile --upgrade` (if pip-tools) or edit pins directly | `pip install -r requirements*.txt` |
| `npm` | `npm install <pkg>@<fixed>` | `npm update` | `npm ci` |
| `pnpm` | `pnpm add <pkg>@<fixed>` | `pnpm update` | `pnpm install --frozen-lockfile` |
| `yarn` | `yarn add <pkg>@<fixed>` | `yarn upgrade` (berry) / `yarn upgrade` (classic) | `yarn install --immutable` |
| `bun` | `bun add <pkg>@<fixed>` | `bun update` | `bun install --frozen-lockfile` |
| `cargo` | `cargo update -p <pkg> --precise <fixed>` | `cargo update` (respects `Cargo.toml`'s declared ranges) | `cargo fetch` |
| `go mod` | `go get <pkg>@<fixed> && go mod tidy` | `go get -u ./... && go mod tidy` | `go mod download` |

**Go modules note:** a major bump to v2+ usually changes the import path (`module/v2`) — update
imports across the codebase, not just `go.mod`, before running the gate; the gate itself is what
catches any import path left unmigrated.

Skip any component whose `package_manager` maps to none of the above (no dependency manifest for
that component) — the same rule the audit uses.

## Output

```
DEPENDENCY UPDATE — <date>
───────────────────────────
Audit source: /cc:verify:dependencies (<date/time run>)
Commit-per-tier: yes/no (confirmed once at start)

Tier         Package    From → To      Gate   Commit
Security     <pkg>      1.2.3 → 1.2.4  ✅     chore(deps): security patches
Patch/minor  <pkg>      2.0.0 → 2.1.3  ✅     chore(deps): patch/minor updates
Patch/minor  <pkg>      0.9.0 → 0.9.4  ✅     (same commit)
Major        <pkg>      3.x → 4.0.0    ✅     chore(deps): major upgrades
Major        <pkg>      1.x → 2.0.0    ❌     ROLLED BACK — see failure detail above

Overall: 4 applied, 1 rolled back, 0 skipped
```

Scheduled maintenance: pair this command with the weekly recipe in
`${CLAUDE_PLUGIN_ROOT}/references/dev/scheduling.md` (Recipe 1) — schedule
`/cc:verify:dependencies` to run weekly, then run this command against whatever it finds.

## Quality checklist

- [ ] Findings sourced from `/cc:verify:dependencies`, not re-scanned from scratch
- [ ] Security tier always runs first, regardless of `--major`
- [ ] Patch/minor batched together; majors applied and gated one at a time
- [ ] The full verify gate (every component) ran after each tier/package, not just the changed
      component
- [ ] A red gate restored exactly the tier/package snapshot that failed — nothing else undone
- [ ] Commit strategy confirmed once up front, never re-asked per tier
- [ ] Each commit message lists every package bump it contains, with from→to versions
- [ ] Summary table shows every attempted package and its outcome, including rollbacks

## Handoff

**Chain:** none — this is a solo maintenance command, run manually or via the scheduling recipe
above. On a clean run with everything green, no further action is needed.
**Solo:** anything rolled back → route to `/cc:verify:debug` with the failing package and gate
output before retrying that bump by hand. For recurring runs, wire this command and
`/cc:verify:dependencies` through `${CLAUDE_PLUGIN_ROOT}/references/dev/scheduling.md`'s Recipe 1
rather than running either by hand every week.
**Abort rules:** no dependency manifest in any component → report "not applicable" and stop
(Step 1). Security tier gate red → restore its snapshot, report, and **stop hard** — do not
attempt the patch/minor or major tiers. Patch/minor batch or an individual major gate red →
restore just that scope's snapshot, report, and continue with the remaining tiers/packages.
