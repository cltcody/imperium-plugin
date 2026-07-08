---
description: Parse and analyse structured logs — error clusters, request_id tracing, timeline, correlation with recent changes
argument-hint: [log file path, request_id, or paste/pipe the log output]
---

# Debug: Logs

Turn a wall of log output into a diagnosis: cluster the errors, trace the failing request, build the timeline, correlate with recent changes, and hand off to the right verify command.

This command is **stack-agnostic**: how the app runs and where it writes logs come from the project's `STACK.md`, not from this file. Resolve the runtime per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` — read `STACK.md` at the project root and, for the component under investigation, use its `dev` command (and `working_dir`) to know what process emits the logs. No `STACK.md` → auto-detect once and recommend `/cc:setup:stack`.

The analysis logic below is **log-format-neutral**. Many backends emit **structured (JSON-per-line) logs** keyed by a correlation id; if this project does, lean on it. A common convention is the `{domain}.{component}.{action}_{state}` event pattern:

```json
{
  "event": "<domain>.<component>.<action>_started",
  "timestamp": "2026-05-26T14:23:45.123Z",
  "request_id": "<correlation-id>",
  "duration_ms": null
}
```

- **Event states** typically include `_started`, `_completed`, `_failed`, `_validated`, `_rejected`, `_retrying`.
- A **correlation id** (`request_id`, `trace_id`, etc.), usually injected per request, is the key that stitches one flow together.
- Adapt to whatever this project actually emits — check its logging conventions (e.g. a `logging-standard` doc, the logging config, or a sample line) before assuming field names. If logs are plain text rather than structured, fall back to line-oriented `grep`/`awk` and timestamps instead of `jq`.

The `jq`/`grep` snippets below assume JSON-per-line with `request_id`/`event`/`duration_ms` fields and a captured log file at `$LOG`. Substitute the project's actual fields, format, and tooling.

## Steps

1. **Acquire the logs.** From the argument path, a pasted block, or the running system. Capture to a file (referred to below as `$LOG`) so the queries can re-run:
   - **Running app:** start the app via the resolved `dev` command (from `STACK.md`) and tee its output to a file, e.g. `<dev command> 2>&1 | tee /tmp/dev.log`. Use whatever port/host the `dev` step defines.
   - **Container runtime:** the project's container log command (`docker compose logs <service> --tail 500`, `docker logs <container> --follow`, `kubectl logs <pod>`, etc. — whatever this stack uses).
   - **Existing log files:** the path the app writes to (often defined in the logging config or `STACK.md` notes).
   - **CI:** `gh run view <id> --log-failed`.
   - **Production:** the platform's log viewer (Datadog, CloudWatch, Railway, etc.).
   Note the format: JSON-per-line, plain text, or mixed.

2. **Identify error clusters.** Grep for failure signals (`_failed`, `ERROR`, `exception`, `traceback`, HTTP `5xx`/`4xx` — adapt to the stack's vocabulary). Group repeated occurrences into distinct error types and count each — 500 lines of noise is usually 2–4 distinct failures. Record first-seen and last-seen timestamps per cluster and rank by frequency × severity.

   ```bash
   # All error events
   grep "_failed\|ERROR" "$LOG" | jq -c '{event, error, error_type, request_id}'

   # Failed HTTP requests (adapt the event name / status field to this project)
   grep "request.http.completed" "$LOG" | jq 'select(.status >= 400)' | head -10
   ```

3. **Trace one failing flow via the correlation id.** Pick a representative correlation id (`request_id`, `trace_id`, …) from the dominant cluster and replay its full lifecycle:

   ```bash
   cid="<correlation-id>"
   grep "$cid" "$LOG" | jq -s 'sort_by(.timestamp) | .[] | {event, timestamp, duration_ms, error, status}'
   ```

   A healthy flow reads roughly: `request.http.started` → `<feature>.<action>.started` → `<feature>.<action>.validated` → `<dependency>.<op>.started/completed` → `<feature>.<action>.completed` → `request.http.completed` (2xx). Map this skeleton to the project's actual events. Find the exact step where the failing flow diverges. Watch for slow `duration_ms` entries preceding errors (timeout chains).

4. **Build the timeline.** Order events around the dominant cluster: what happened immediately before the first failure? Did failures start abruptly (deploy/change-triggered) or degrade gradually (resource/load)?

5. **Correlate with recent changes.** `git log --oneline --since="<first-error-time>"` (and `-- <suspect-paths>`) — did a commit, dependency bump, migration, or config change land just before the errors began? Match stack-trace files/lines against the recent diff (`git diff <suspect-commit>^ -- <file>`). State the correlation honestly: confirmed, plausible, or none found.

6. **Summarize findings.** Produce the findings block (see Output). If this analysis supports a larger debugging effort, save it to `${user_config.workspace_dir}/reports/log-analysis-<topic>.md` so `/cc:verify:debug` or `/cc:verify:rca` can build on it.

## Log query reference

Assumes JSON-per-line with a captured log at `$LOG`. Adapt field names, event names, and tooling to the project's actual format; for plain-text logs, swap `jq` filters for `grep`/`awk`.

```bash
# All events from one feature/domain
grep "<domain>\." "$LOG" | jq . | less

# Slow dependency calls (db query, http client, cache, …)
grep "<dependency>.<op>.completed" "$LOG" | jq 'select(.duration_ms > 100)' | head -10

# Slow requests
grep "request.http.completed" "$LOG" | jq 'select(.duration_ms > 1000) | {path, duration_ms, status}'

# Average duration by event
grep "_completed" "$LOG" | jq -s 'group_by(.event) | map({event: .[0].event, avg_ms: (map(.duration_ms) | add / length)}) | .[]'

# Auth failures
grep "401\|403" "$LOG" | jq -c '{path, status, error}' | head -10
```

## Output

```
LOG ANALYSIS
Source:      <file/container/CI run>   Window: <first ts> → <last ts>
Clusters:
  1. <error type> — <count>× , first seen <ts>  [likely root]
  2. <error type> — <count>×  [downstream of 1]
Trace:       correlation id <id> — diverges at <event> (<file:line> if known)
Timeline:    <trigger event> → <first failure> → <cascade>
Correlation: <commit/config/none> — <confidence>
Hypothesis:  <one-sentence most likely cause>
Next:        /cc:verify:debug | /cc:verify:rca
```

## Quality checklist

- [ ] Errors grouped into distinct clusters with counts, not listed raw
- [ ] Root failure separated from downstream cascade noise
- [ ] At least one failing flow traced end-to-end via the correlation id
- [ ] Timeline anchored to timestamps, including the first occurrence
- [ ] Recent-change correlation checked against git history and stated with confidence
- [ ] A single primary hypothesis stated, with the evidence for it

## Handoff

**Chain:** in a debugging chain, immediately invoke the suggested next command with the SlashCommand tool — `/cc:verify:debug` when there is a reproducible error to fix now, `/cc:verify:rca` when the cause needs deeper investigation or a documented analysis. Slow-dependency findings → `/cc:verify:performance`.
**Solo:** end with the findings block and recommend `/cc:verify:debug` (fix it) or `/cc:verify:rca` (understand it) based on confidence in the hypothesis.
**Abort rules:** logs unreadable, empty, or missing the failure window → report what's missing and ask for a better source (longer tail, debug level, the right service) instead of speculating. Evidence points at infrastructure outside the repo (platform outage, third-party API) → report that conclusion and stop; no code change will fix it.
