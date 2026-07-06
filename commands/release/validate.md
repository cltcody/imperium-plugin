---
description: Full pre-release validation — tests, types, lint, local server, and Docker deployment
---

# Release: Validate

Run comprehensive pre-release validation to ensure tests, type checks, linting,
formatting, the production build, the local server, and (if configured) the
container/Docker deployment are all working correctly. This is fuller than
`/cc:verify:run` — it adds the production `build`, a running-server smoke test, and a
container deployment check on top of the verify gate.

It is **stack-agnostic**: the concrete commands come from the project's `STACK.md`, not
from this file.

## Steps

### 1. Resolve the stack

Read the project's `STACK.md` and resolve commands per
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. This validation runs these
steps **for every component** from that component's `working_dir`:

```
smoke → test → typecheck → lint → format:check → build
```

Skip any step a component does not map (not an error). If there is no `STACK.md`,
auto-detect once from project markers and recommend the user run `/cc:setup:stack` to
persist a manifest.

### 2. Test suite

Run each component's `test` step from its `working_dir`.

**Expected:** All tests pass.

### 3. Type checking

Run each component's `typecheck` step.

**Expected:** Zero type errors.

### 4. Linting and formatting

Run each component's `lint` and `format:check` steps.

**Expected:** Lint clean; formatter reports nothing to reformat.

### 5. Production build

Run each component's `build` step (where mapped).

**Expected:** Build succeeds with zero errors. A build that only works in dev mode is a
failure.

### 6. Local server validation

Start the app using the component's `dev` step (run it in the background), wait a few
seconds for startup, then smoke-test it. Use the project's actual entry point and port —
resolve them from the `dev` command and the project config rather than assuming.

```bash
# Start the resolved dev step in the background (example shape — use the resolved command):
<dev-step-command> &
```

Wait ~3 seconds for startup, then test the running app. For an HTTP service, probe its
documented root/health endpoint and confirm a healthy response and any expected headers
(e.g. a request-id header if the app sets one):

```bash
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:<port>/
```

**Expected:** A healthy response (HTTP 200 for an HTTP app) and the app's expected
startup output. For non-HTTP apps (CLI, worker, native), substitute the equivalent
"it starts and responds" check.

Stop the server afterward (kill the background process / free the port).

### 7. Container / Docker deployment validation

Only if the project ships a container setup (e.g. `docker-compose.yml` / `compose.yaml`
or a `Dockerfile`). Drive image and service names from the project's compose file — do
**not** hardcode them.

Build and start the service:

```bash
docker-compose up -d --build
```

**Expected:** The image builds successfully and the service starts.

Wait a few seconds, then verify status and reachability (use the same endpoint/port as
the local-server smoke):

```bash
docker-compose ps
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:<port>/
```

**Expected:** Service status shows "Up" and serves the same healthy response as the local
server.

Check the service logs for the project's expected startup/log format (e.g. structured
JSON with a request id, if the app logs that way):

```bash
docker-compose logs <service> | tail -20
```

Stop the service:

```bash
docker-compose down
```

If the project has no container setup, skip this section (not a failure) and note it in
the report.

### 8. Compile the summary report

See Output below — format the report clearly with per-component rows and status
indicators (✅/❌/⚠️).

## Output

A summary report covering:

- Per-component results for `test`, `typecheck`, `lint`, `format:check`, `build` (skipped
  steps marked unmapped)
- Local server status (started, endpoint/health response, expected headers/output)
- Container/Docker deployment status (build, up, same response, expected logs) — or
  "no container setup" if none
- Any errors or warnings encountered
- Overall health assessment (PASS/FAIL)

```
RELEASE VALIDATE — <stack> (from STACK.md)
──────────────────────────────────────────
backend  (uv)   smoke ✅  test ✅ (121)  typecheck ✅  lint ✅  format ✅  build ✅
frontend (npm)  test ✅   typecheck ✅   lint ✅       build ✅   (smoke, format: unmapped)
Local server    ✅ started, / → 200, x-request-id present
Container        ✅ build + up, / → 200, structured JSON logs
                 (or: no container setup — skipped)

Overall: ✅ PASS — ready for /cc:release:deploy
         ❌ FAIL — <failing check>
```

Adapt the rows to whatever components and steps the project's `STACK.md` actually defines.

## Quality checklist

- [ ] All tests pass for every component that maps `test`
- [ ] `typecheck` clean for every component that maps it
- [ ] `lint` and `format:check` clean where mapped
- [ ] Production `build` succeeds where mapped (not just dev mode)
- [ ] Local server starts and responds on its root/health endpoint with expected output/headers
- [ ] Container builds, starts, serves the same response, and logs in the expected format —
      or absence of a container setup is explicitly noted
- [ ] Skipped/unmapped steps are reported, not silently dropped

## Handoff

**Chain:** If the overall assessment is PASS, invoke `/cc:release:deploy` to continue the release. If FAIL, invoke `/cc:verify:debug` to diagnose the failing check.

**Solo:** Report the summary. On PASS, suggest `/cc:release:env` (if not yet run) and `/cc:release:deploy`; on FAIL, suggest `/cc:verify:debug`.

**Abort rules:** Never proceed to deployment with any failing section. If container validation fails but local validation passes, stop and diagnose the container/compose configuration before re-running — do not deploy on a partially green report.
