---
description: Holistic system health check before release, on schedule, or post-deployment
disable-model-invocation: true
---

# Verify: System Health

One command to verify the entire system is ready for production — catches issues that
individual checks miss with full-stack validation. It is **stack-agnostic**: the concrete
commands come from the project's `STACK.md`, not from this file.

**When to use:** Before `/cc:release:deploy`; weekly as scheduled maintenance (see
`${CLAUDE_PLUGIN_ROOT}/references/dev/scheduling.md`); right after a deploy, in **post-deployment
mode** (below); or whenever something feels "off". (For the process-review command, see
`/cc:verify:system` — a different command.)

**Two modes:**
- **Pre-release audit (default)** — Steps 1-9 below: the full-stack readiness sweep.
- **Post-deployment mode (`--post-deploy`)** — a lighter, faster pass for right after a release:
  hit the health endpoints, spot-check critical endpoints, and diff the error-log rate against
  the pre-deploy baseline. See [Post-deployment mode](#post-deployment-mode) below.

## Steps

### 0. Resolve the stack

Read the project's `STACK.md` and resolve commands per
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. The stack-coupled checks below
run **per component** from that component's `working_dir`, using the component's mapped
commands and `package_manager`. Skip any step a component does not map (not an error), and
**aggregate** results per component — do not stop at the first component's failure. If there
is no `STACK.md`, auto-detect once from project markers and recommend the user run
`/cc:setup:stack` to persist a manifest.

Mapping for this command:

| Health area | Step |
|-------------|------|
| Database / migration state | `migrate` |
| Test suite | `test` |
| Coverage | `coverage` |
| Type safety | `typecheck` |
| Lint | `lint` |
| Format | `format:check` |
| Server startup | `dev` |

### 1. Health endpoints

If the project exposes HTTP health endpoints, hit them (server must be running). Use the
project's real host/port and endpoint paths:

```bash
# From project root (server must be running)
curl -s http://localhost:<port>/health | jq .
curl -s http://localhost:<port>/health/db | jq .
curl -s http://localhost:<port>/health/ready | jq .
```

Expected responses:
```json
{
  "status": "healthy",
  "uptime": "12h 34m",
  "timestamp": "2026-05-26T14:23:45Z"
}
```

**Red flags:**
- ❌ Any endpoint returns status != "healthy"
- ❌ Database connection failing
- ❌ Service not ready for traffic

### 2. Database / migration state

For each component that maps `migrate`, check that applied migrations match the latest
defined migration, using the component's own migration tooling (the `migrate` command shows
which tool the project uses — e.g. its current/history subcommands). Run from the component's
`working_dir`.

```
# Per component (working_dir), via the project's migration tool:
#   - current applied revision
#   - latest defined revision
# Expected: current revision == latest revision
```

**Red flags:**
- ❌ Pending migrations
- ❌ Inconsistent migration state
- ❌ Cannot connect to database

### 3. Test suite status

For each component, run the `test` step, then the `coverage` step, from its `working_dir`.

```
# Per component (working_dir):
#   test      → full suite
#   coverage  → test run with coverage report
```

**Red flags:**
- ❌ Failing tests
- ❌ Coverage below 70% on new code
- ❌ Test database connection issues

### 4. Type safety

For each component that maps `typecheck`, run it from its `working_dir`. Also count type
suppressions in the component's source (`# type: ignore`, `# pyright: ignore`,
`eslint-disable`, `# noqa`, etc., as appropriate for the language).

```
# Per component (working_dir):
#   typecheck → static type checking
#   count suppression comments in source
```

**Red flags:**
- ❌ Type errors in any component
- ❌ More than 5 type suppressions (should be rare)
- ❌ Loosely-typed escapes (e.g. `Any`) without justification

### 5. Code quality

For each component, run `lint` and `format:check` from its `working_dir`. Run a security
scanner too if one is mapped or available for the stack.

```
# Per component (working_dir):
#   lint         → linter
#   format:check → formatter in check mode
#   (optional) language-appropriate security scanner
```

**Red flags:**
- ❌ Lint errors
- ❌ Formatting issues
- ❌ Security warnings (HIGH or CRITICAL)

### 6. Dependency health

For each component, check for outdated and vulnerable dependencies using its
`package_manager`'s own tooling (e.g. the manager's "outdated" listing and an audit command,
if available).

```
# Per component, via its package_manager:
#   list outdated packages
#   audit for known vulnerabilities (if an audit tool is available)
```

**Red flags:**
- ❌ Multiple outdated packages
- ❌ Known vulnerabilities in dependencies
- ❌ Language/runtime version incompatibility

### 7. Docker build status

If the project ships a Docker build, build the image, check its size, and smoke-test the
container. Use the project's real Dockerfile path, image name, and exposed port:

```bash
# Build the image (use the project's Dockerfile path and image name)
docker build -f <dockerfile> -t <image>:test .

# Check image size
docker images <image>:test --format "table {{.Repository}} {{.Size}}"

# Run container and test (use the project's host/container ports and health path)
docker run -d --name test-app -p <host-port>:<container-port> <image>:test
sleep 2
curl http://localhost:<host-port>/health
docker stop test-app && docker rm test-app
```

**Red flags:**
- ❌ Build fails
- ❌ Image size unexpectedly large for the stack
- ❌ Container fails to start
- ❌ Health endpoint unreachable

### 8. Environment variables

```bash
# Check required env vars are set (use the project's actual required vars)
required_vars=("DATABASE_URL" "SECRET_KEY" "DEBUG")
for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo "❌ Missing: $var"
  else
    echo "✅ Set: $var"
  fi
done

# Check no secrets in .git
git log -p --all | grep -i "password\|secret\|token\|key=" | wc -l
```

**Red flags:**
- ❌ Missing required environment variables
- ❌ Secrets committed to git
- ❌ `.env` file checked in version control

### 9. Generate the report

Create `${user_config.workspace_dir}/reports/system-health-<date>.md` (see Output for the template).

### 10. Automated scheduling (optional)

A slash command is not a shell command — it cannot go directly into a crontab line. To run
this weekly, use one of the real scheduling mechanisms and recipes in
`${CLAUDE_PLUGIN_ROOT}/references/dev/scheduling.md` (Desktop Tasks, Routines, or a headless
`claude -p` one-shot from cron/CI). Minimal headless example for a cron/launchd user:

```bash
claude -p "/cc:verify:system-health" --model haiku
```

This catches drift before it becomes a problem.

## Post-deployment mode

Invoked as `/cc:verify:system-health --post-deploy` right after a `/cc:release:deploy`, or
polled on an interval per the scheduling reference below. It is a **subset** of the steps
above, tuned for speed: confirm the just-shipped deploy is actually healthy rather than
re-running the full pre-release sweep.

**Resolve first:** same as Step 0 — read `STACK.md` and resolve the `health`/`smoke` step and
any logging location per
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. Nothing below hardcodes a port,
framework, or process manager; substitute the project's real endpoint paths, host/port, and
log source.

1. **Health endpoints.** Hit the project's real health endpoint(s) — same URLs as Step 1
   above, using the actual deployed host:

   ```bash
   curl -s https://<deployed-host>/<health-path> | jq .
   ```

   Expect the same "healthy" shape used in Step 1. If the project maps a `smoke` step in
   `STACK.md`, running it against the deployed target is an acceptable substitute where no
   HTTP endpoint exists.

2. **Critical endpoint spot-check.** Exercise 2-3 endpoints that represent real user paths
   (login, list a core resource, create/read a core object) — not just `/health`. A green
   health check with a broken critical path is the classic false-negative this step exists to
   catch.

3. **Error-log delta.** Compare the error rate/count in the post-deploy window against the
   same window pre-deploy, using whatever the project's actual log source is (structured log
   aggregator query, `journalctl`, container logs, platform log tail — resolve from the
   project, don't assume one):

   ```bash
   # Generic shape — substitute the project's real log source and error pattern:
   # errors in the last N minutes now  vs.  errors in the equivalent window before deploy
   ```

   A spike relative to the pre-deploy baseline is a red flag even if every health check is
   green.

4. **Alerting-threshold guidance.** If the project has an observability/APM tool, these are
   reasonable starting thresholds to alert on (tune per project, and wire them into whatever
   tool the project actually uses — Datadog, Grafana, CloudWatch, Uptime Robot, etc. — this
   file stays tool-agnostic):

   | Metric | Healthy | Warning | Critical |
   |--------|---------|---------|----------|
   | Response time (p95) | < 200ms | 200-500ms | > 500ms |
   | Error rate | < 0.1% | 0.1-1% | > 1% |
   | CPU usage | < 50% | 50-80% | > 80% |
   | Memory usage | < 70% | 70-85% | > 85% |
   | Disk usage | < 70% | 70-85% | > 85% |

5. **If unhealthy.** Check the project's real logs and process status (resolve from
   `STACK.md`/deployment target — don't assume Docker), then escalate: if a straightforward fix
   is apparent, route to `/cc:verify:debug`; if the issue is critical and user-facing, route to
   `/cc:release:rollback` immediately rather than continuing to investigate live.

**Continuous / scheduled polling** (rather than a one-off check right after deploy): do **not**
hand-roll a `while true; sleep N` shell loop. Use
`${CLAUDE_PLUGIN_ROOT}/references/dev/scheduling.md` — the "post-deploy polling" recipe covers
both a short-lived just-after-deploy watch and an ongoing scheduled health check.

## Output

A health report at `${user_config.workspace_dir}/reports/system-health-<date>.md`. Adapt the component rows and
sections to whatever the project's `STACK.md` actually defines:

```markdown
# System Health Report

**Date:** 2026-05-26
**Environment:** local / staging / production
**Generated:** 14:23 UTC

## Status Summary

| Component | Status | Details |
|-----------|--------|---------|
| HTTP Server | ✅ | Responding to requests |
| Database | ✅ | Connected, migrations current |
| Tests | ✅ | 112/112 passing |
| Type Safety | ✅ | 0 typecheck errors |
| Code Quality | ✅ | All lint/format checks passing |
| Dependencies | ⚠️ | 3 packages outdated (non-critical) |
| Docker | ✅ | Builds successfully, ~450MB |
| Env Vars | ✅ | All required vars present |

## Details

### Health Endpoints
```json
{
  "status": "healthy",
  "uptime": "4h 12m",
  "timestamp": "2026-05-26T14:23:45Z"
}
```

### Database
- Current migration: `a1b2c3d4e5f6` (2026-05-20)
- Latest migration: `a1b2c3d4e5f6` ✅ synced

### Tests
```
112 tests passing
Coverage: 82%
Avg test time: 0.3s
```

### Type Safety
```
typecheck: 0 errors, 0 warnings
Type suppression count: 2 (justifications documented)
```

### Dependencies
```
3 outdated packages (non-breaking / patch / minor)
```

## Recommendations

✅ System is **healthy** and ready for production
🟡 Schedule dependency updates within 2 weeks
✅ No critical issues found

---

**Report generated by:** `/cc:verify:system-health`
```

## Quality checklist

- [ ] All health endpoints responding; service ready for traffic
- [ ] Migrations current; database connected (every component that maps `migrate`)
- [ ] All tests passing; `typecheck`, `lint`, and `format:check` at 0 errors where mapped
- [ ] No high-severity dependency vulnerabilities; no secrets in git; required env vars set
- [ ] Docker image builds, starts, and passes its health check (if the project ships one)
- [ ] Post-deployment mode only: critical endpoints spot-checked; error rate diffed against the pre-deploy baseline, not just "endpoint returned 200"

## Handoff

**Chain:** When run as the pre-release gate: all components green → continue to `/cc:release:deploy`. Any component red → route per area before re-running:
- Failing tests, type errors, or lint → `/cc:verify:debug`
- Migration drift or pending migrations → `/cc:implement:migrate`
- Env var or secret issues → `/cc:release:env`

When run in **post-deployment mode**: all green → done, this is the terminal step after
`/cc:release:deploy`. Unhealthy and fixable → `/cc:verify:debug`. Unhealthy and user-facing →
`/cc:release:rollback` immediately.

**Solo:** Report the status summary table and recommendations; suggest merging approved PRs, deploying to staging, and scheduling dependency updates as applicable. In post-deployment mode, report the health status summary and, for a deeper full-stack check, suggest re-running this command in its default mode.

**Abort rules:** Do not proceed to deployment with any ❌ component. Secrets found in git history are an immediate stop — route to `/cc:release:env` and rotate the credentials before anything else. In post-deployment mode: if a health check stays unhealthy after investigation and the issue is critical/user-facing, stop investigating live and route to `/cc:release:rollback`.
