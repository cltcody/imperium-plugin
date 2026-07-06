---
description: Audit dependencies and supply chain — known CVEs, version hygiene, lockfile drift, CI action pinning, install-script risk
---

# Verify: Dependencies

Audit the project's dependency tree and supply chain: known vulnerabilities, version hygiene, lockfile drift, and CI supply-chain exposure. Run before `/cc:release:deploy`, after large dependency changes, or as routine (weekly/monthly) maintenance — to actually automate the weekly run, see `${CLAUDE_PLUGIN_ROOT}/references/dev/scheduling.md`. Standalone command — not part of the default verify chain.

This audit is **package-manager-driven**: the concrete audit tool, lockfile, and manifest for each component come from that component's `package_manager` in the project's `STACK.md`, not from this file.

## Resolve the stack

Before auditing anything, read the project's `STACK.md` and resolve commands per
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. Each component declares its
`working_dir`, `package_manager`, and `language` — iterate over **every** component and run
the audit from its `working_dir`. Map the `package_manager` to its concrete audit tooling,
manifest, and lockfile:

| `package_manager` | Vulnerability scan | Outdated list | Lock check | Manifest / Lockfile |
|-------------------|--------------------|---------------|------------|---------------------|
| `uv` | `uv run pip-audit` (install: `uv add --dev pip-audit`) | `uv pip list --outdated` | `uv lock --check` | `pyproject.toml` / `uv.lock` |
| `poetry` | `poetry run pip-audit` (or `poetry audit` plugin) | `poetry show --outdated` | `poetry check --lock` | `pyproject.toml` / `poetry.lock` |
| `pip` | `pip-audit` | `pip list --outdated` | — (use `pip-compile`/`requirements.txt` hash check if used) | `requirements*.txt` / `requirements*.txt` |
| `npm` | `npm audit` | `npm outdated` | `npm ci --dry-run` | `package.json` / `package-lock.json` |
| `pnpm` | `pnpm audit` | `pnpm outdated` | `pnpm install --frozen-lockfile --dry-run` | `package.json` / `pnpm-lock.yaml` |
| `yarn` | `yarn npm audit` (berry) / `yarn audit` (classic) | `yarn outdated` | `yarn install --immutable --dry-run` | `package.json` / `yarn.lock` |
| `bun` | `bun audit` | `bun outdated` | `bun install --frozen-lockfile --dry-run` | `package.json` / `bun.lockb` |

Prefer whatever scanner is already installed. If there is no `STACK.md`, auto-detect each
component once from project markers (manifest + lockfile → package_manager) and recommend the
user run `/cc:setup:stack` to persist a manifest. Never assume a single ecosystem — a repo
can have several components, each with its own package_manager; audit each.

## Steps

1. **Enumerate the components and their package managers.** From `STACK.md` (or auto-detection),
   list each component's `working_dir`, `package_manager`, and resolved manifest + lockfile.
   A repo can have several — audit each.

2. **Run each component's vulnerability scanner** from its `working_dir`, choosing the tool
   from the table above by `package_manager`:
   ```bash
   # Example for a uv component:
   #   cd <working_dir> && uv run pip-audit
   # Example for an npm component:
   #   cd <working_dir> && npm audit
   ```
   If no scanner can run for a component, say so explicitly rather than reporting "clean".
   Record each CVE with package, installed version, fixed version, and severity.

3. **List outdated packages** for each component (the `package_manager`'s outdated command
   from the table) and classify each as patch / minor / major. Majors need changelog review
   before upgrading (`gh release view --repo <org>/<repo> v<X>`); do not bundle them with
   security fixes.

4. **Check version hygiene and lockfile drift** per component. Flag: floating/unpinned
   versions in the manifest (`*`, bare `>=` with no upper bound) for production dependencies;
   a missing lockfile; lockfile out of sync with the manifest (run the `package_manager`'s
   lock-check command from the table); lockfile not committed.

5. **Audit CI supply chain.** In `.github/workflows/*.yml` (stack-neutral — same regardless of
   package manager): third-party actions pinned only to a mutable tag (`@v4`, `@main`) instead
   of a commit SHA; `curl | bash` style installs of unpinned scripts; secrets exposed to
   workflows triggered by forks (`pull_request_target` misuse).

6. **Check install-script and provenance risk.** New or recently-changed dependencies with
   install hooks (`postinstall`/`preinstall` in JS; build hooks in Python); names suspiciously
   close to popular packages (typosquatting); dependencies pulled from non-registry sources
   (git URLs, tarballs) without a pinned ref.

7. **Scan licenses for red flags.** Copyleft (GPL/AGPL) in a proprietary codebase,
   missing/unknown licenses, license changes on upgrade. Flag for review — do not make legal
   judgements.

8. **Compile the severity-rated report** (see Output). If any findings exist, also save the
   full report to `${user_config.workspace_dir}/reports/dependencies-<YYYY-MM-DD>.md`.

## Applying updates

Strategy by severity (the concrete upgrade and revert commands come from each component's
`package_manager`):

| Class | Action | Timing |
|-------|--------|--------|
| **Security fix** | Pin the fixed version via the component's package manager (e.g. `uv add <pkg>==<fixed>`, `poetry add <pkg>@<fixed>`, `npm install <pkg>@<fixed>`) — or the minimal bump that closes the CVE | Immediately; deploy within hours |
| **Patch** | Upgrade freely | Regularly, batched |
| **Minor** | Upgrade after a skim of release notes | This week |
| **Major** | Read the changelog, upgrade in its own PR with full testing | Planned, never bundled |

**Test after every update** by running that component's verify steps from `STACK.md`
(`smoke`, `test`, `typecheck`, `lint`) per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`
— or just run `/cc:verify:run`, which resolves them for every component. If any check fails:
revert the manifest + lockfile (`git checkout <manifest> <lockfile>` then the package
manager's sync/install — e.g. `uv sync`, `poetry install`, `npm ci`) and investigate. Commit
successful updates with a `chore(deps):` message listing each bump and its type.

## Output

```
DEPENDENCY AUDIT — <date>
─────────────────────────
Components scanned: <component (package_manager), …>   Scanners run: <list / NONE AVAILABLE>

🔴 CRITICAL  — exploitable CVE, malicious-package indicator
🟠 HIGH      — high-severity CVE, unpinned CI action, risky install script
🟡 MEDIUM    — floating versions, lockfile drift, stale majors
🟢 LOW       — outdated patches/minors, license review items

[severity] <component> <package/file> — finding — recommended action

Overall: CLEAN / N findings (X critical, Y high)
```

Findings exist → full report saved to `${user_config.workspace_dir}/reports/dependencies-<date>.md`. Clean scan → conversation summary only, no file.

## Quality checklist

- [ ] Every component (from `STACK.md` / auto-detection) scanned, not just the first one found
- [ ] The audit tool was chosen from each component's `package_manager` — not hardcoded
- [ ] A real scanner ran per component — or its absence is stated, never implied clean
- [ ] Each CVE lists installed version, fixed version, and severity
- [ ] Security upgrades separated from convenience upgrades
- [ ] CI actions and install scripts checked, not just package versions
- [ ] Updates tested (per-component verify steps + smoke) before committing
- [ ] Report file written only when findings exist

## Handoff

**Chain:** none — this is a solo command outside the default chain.
**Solo:** vulnerabilities or risky upgrades found → invoke `/cc:plan:task` to plan the upgrade (pin fixes, test, then majors separately). Broader supply-chain or codebase security concerns → suggest the `security-audit` skill for a full officer-ready report. Clean result before a release → continue with `/cc:release:deploy`.
**Abort rules:** no dependency manifest found in any component → report "not applicable — no dependency manifests detected" and stop.
