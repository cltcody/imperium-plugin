---
description: Pre-deployment readiness gate — validation, security, env audit, migrations, container build, smoke test, changelog — ends in GO / NO-GO
allowed-tools: Read, Grep, Glob, Bash, SlashCommand
---

# Deploy Readiness

Run every check that separates a safe deployment from a hopeful one, and end with a single GO / NO-GO verdict. **This command never deploys anything.** It verifies readiness and hands the user the exact deploy steps — pushing the button stays human.

This gate is **stack-agnostic**: the concrete validation, migration, build, and server commands come from the project's `STACK.md`, not from this file. The container/Docker steps below use generic placeholders — adapt them to the project's actual container setup.

## Steps

### 1. Resolve the stack

Read the project's `STACK.md` and resolve commands per
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. Active components and steps
change what must be verified. Each readiness item below runs its step **per component** from
that component's `working_dir`, skipping any step a component does not map (not an error). If
there is no `STACK.md`, auto-detect once from project markers and recommend the user run
`/cc:setup:stack` to persist a manifest.

### 2. Fresh validation

If `/cc:verify:run` has not run GREEN in this session (or the tree changed since), invoke it
now — a stale green does not count. It runs the resolved `smoke → test → typecheck → lint →
format:check` steps per component. RED → the gate is already failed; record it and continue
gathering the remaining items so the user sees the full picture.

### 3. Security gate

Invoke `/cc:verify:security` (diff scope for a reviewed increment, full scope for a first
deploy) and `/cc:release:env`. Any CRITICAL/HIGH (🔴/🟠) finding is a ❌.

### 4. Environment audit

Verify the project's env template (e.g. `.env.example`) documents every variable the code
reads, and that the production environment has values for ALL of them. Production-critical
values to confirm where they apply:
- Database connection points at the production database, not dev
- App secret / signing key is a strong random value, not a default
- Allowed origins / hosts are production domains, not `localhost`
- Environment flag set to production
- Log level set to `INFO` or `WARNING` (not `DEBUG`)

No secrets hardcoded in source, container/compose config, or CI config; the local env file is
gitignored and absent from git history.

### 5. Pending migrations

If a component maps the `migrate` step, list the migrations not yet applied to the target
environment (run the component's migration-status command, or invoke `/cc:implement:migrate`
for a guided review). For each pending migration: confirm it has a tested rollback path (or a
stated one-way plan). Ordering rule: **apply migrations before deploying code that depends on
them** — never the reverse. If no component maps `migrate`, mark this item N/A.

### 6. Container build

Build the production container image and confirm it succeeds with zero errors — if it fails
locally, it will fail in production. A build that only works in dev mode is a ❌. Use the
project's container build (generic placeholder):

```bash
# e.g. docker-compose build  /  docker build -t <image> .  /  the project's build command
docker-compose build
```

If the project's production artifact is a non-container `build` step from `STACK.md`, run that
instead and confirm it produces a clean production bundle.

### 7. Health / smoke check of the built artifact

Start the built artifact and confirm it serves traffic, then tear it down. Use the project's
container run + health endpoint (generic placeholders — substitute the real port and health
path):

```bash
# e.g. start the built artifact
docker-compose up -d --build
# health endpoint must return 200 — this is what deploy platforms use to confirm startup
curl -f http://localhost:<port>/<health-path> || echo "HEALTH CHECK FAILED"
docker-compose down
```

If the project has no container, smoke-test the artifact via the resolved `dev` step (start the
server, hit its health/root endpoint, stop it) — but prefer the deployable artifact over the
dev server when one exists.

### 8. CORS / hosts and production logging

- Confirm cross-origin / allowed-host config is an explicit list of production domains, **not
  a wildcard** — and never a wildcard combined with credentials enabled. Check the project's
  config and middleware where this is defined.
- Verify production-mode logging is structured (e.g. valid JSON, no plaintext debug logs) by
  starting the artifact in production mode and inspecting its first log lines:

```bash
# start in production mode and inspect logs (generic placeholders)
docker-compose up -d   # with the environment flag set to production
docker-compose logs | head -10   # must be structured, no plaintext debug logs
docker-compose down
```

### 9. Version and changelog

Confirm the version is bumped and the changelog covers everything since the last release — if
stale, invoke `/cc:release:changelog`. Confirm the working tree is clean and the release commit
exists.

### 10. Render the verdict

Every item ✅ → **GO**, plus the concrete deploy steps for the user's setup (push tag, merge to
main for auto-deploy, image push + restart). Any ❌ → **NO-GO** with each failing item routed
(see Abort rules).

## Output

A checklist in the conversation (no file written). Adapt the rows to whatever components and
steps the project's `STACK.md` actually defines:

```
DEPLOY CHECKLIST — <project> <version> (from STACK.md)
──────────────────────────────────────────────────────
[✅/❌] Validation suite GREEN (fresh) — per component (smoke, test, typecheck, lint, format)
[✅/❌] Security scan — no 🔴/🟠 findings
[✅/❌] Env audit — DB, secret/signing key, allowed origins, environment flag, log level
[✅/❌/N/A] Migrations — pending listed, rollback path confirmed, migrate-before-deploy noted
[✅/❌] Container/production build succeeds
[✅/❌] Health endpoint returns 200 from the built artifact
[✅/❌] CORS/hosts locked to production domains (not wildcard)
[✅/❌] Logging structured in production mode
[✅/❌] Version bumped + changelog current

Verdict: 🟢 GO — deploy steps below   /   🔴 NO-GO — failing items routed below
```

## Quality checklist

- [ ] Steps resolved from `STACK.md` (or auto-detected once, with `/cc:setup:stack` recommended)
- [ ] No item marked ✅ on stale or assumed results — everything re-verified this session
- [ ] Env audit covered code-read vars, the env template, logs, and git history
- [ ] Migration ordering (migrate before code) stated whenever migrations are pending
- [ ] Build and smoke test ran against the deployable artifact, not the dev server (where one exists)
- [ ] Verdict is unambiguous — exactly one of GO / NO-GO
- [ ] Nothing was actually deployed by this command

## Handoff

**Chain:** none — this is a terminal gate; the human deploys.
**Solo:** on GO, hand over the deploy steps, remind the user that `/cc:release:rollback` is the incident path if the deploy goes wrong, and suggest running `/cc:verify:system-health --post-deploy` to watch the health endpoint and error rates for the first minutes post-deploy (see `${CLAUDE_PLUGIN_ROOT}/references/dev/scheduling.md` for polling on an interval instead of a one-off check).
**Abort rules:** any ❌ → NO-GO. Route each failing item: validation/build failures → `/cc:verify:code-review-fix` (mechanical) or `/cc:verify:debug` (unclear cause); security findings → fix before re-running this gate; migration issues → `/cc:implement:migrate`; stale changelog → `/cc:release:changelog`. Re-run this command after fixes — partial green is not GO.
