<!--
  EXEMPLAR for /cc:verify:rca — a root cause analysis at the quality bar.
  Entirely SYNTHETIC: the incident, codebase ("Dispatch", Meridian Freight
  Systems), logs, commits, and people are fictional. A real RCA is saved to the
  workspace reports/ directory. Match the SHAPE and BAR — sourced timeline,
  verbatim evidence, the hypothesis tree with ELIMINATED branches and their
  elimination evidence, the root-cause vs contributing-factors distinction, and
  prevention items routed to specific process changes — NOT its content.
-->

# RCA: Nightly ETA Sync Silently Drops Updates

**Date:** 2026-06-19 | **Severity:** P1 | **Status:** root cause confirmed | **Confidence:** High

## What happened

Between 2026-06-12 and 2026-06-18, the nightly carrier ETA sync silently failed to apply ~2–4% of shipment updates each run (measured: 143 of 4,912 updates dropped on 06-17). Coordinators saw stale ETAs on the dispatch board and re-confirmed times with carriers by phone; no errors were logged and the job reported success every night. Reproduction verified: yes — deterministic failing test, see Evidence E4.

## Timeline (sourced)

| When (UTC) | Event | Source |
|---|---|---|
| 2026-06-12 09:41 | `a3f81c2` merged: "perf: ETA sync incremental — cursor on updated_at instead of full-table scan" | `git log --oneline apps/tracking/sync.py`; PR #412 |
| 2026-06-12 18:00 | Deployed in release 2026.24 | deploy log, `releases/2026.24.md` |
| 2026-06-13 02:00 | First incremental run; job exits 0, `eta_sync_completed rows=4788` | worker log `worker-1.log:2026-06-13T02:03:11Z` |
| 2026-06-16 08:30 | First user report: "ETA on MER-88213 is three days old" | ops channel, ticket OPS-2291 |
| 2026-06-17 14:00 | Second report, different carrier — rules out carrier-specific data issue | ticket OPS-2304 |
| 2026-06-18 10:12 | Investigation start; drop rate quantified via reconciliation query (E2) | this RCA |

The onset matches `a3f81c2` exactly: reconciliation of pre-06-12 runs (full-table era) shows zero drops. `git blame apps/tracking/sync.py` attributes the cursor logic (lines 31–39) entirely to that commit.

## Hypotheses (tree with eliminated branches)

| # | Hypothesis | Prior | Outcome |
|---|---|---|---|
| H1 | Carrier feed omits the rows (upstream data gap) | Likely — usual suspect | **Eliminated.** Raw feed payloads are archived (`apps/tracking/feed_archive/`); for all 143 dropped refs on 06-17, the payload contains the update (checked with `python scripts/grep_archive.py --date 2026-06-17 --refs dropped_refs.txt` → 143/143 present). The data reached us. |
| H2 | Worker crash / OOM mid-run truncates the batch | Possible | **Eliminated.** Exit code 0 every night (`systemctl status` history), memory flat at ~180 MB (metrics dashboard, 06-12→06-18), and dropped refs are interleaved throughout the run, not clustered at the tail — inconsistent with truncation. |
| H3 | The new dedupe filter (`a3f81c2` also added one) discards them | Possible — same commit | **Eliminated.** The dedupe path logs `eta_sync_row_deduped` per skip (`sync.py:58`); 06-17 log contains 12 dedupe events, none matching the 143 dropped refs (`grep eta_sync_row_deduped worker-1.log | grep -f dropped_refs.txt` → 0 hits). |
| H4 | Incremental cursor misses rows committed concurrently with the cursor read | Initially unlikely — "it's just a timestamp comparison" | **Confirmed.** Survives all evidence, explains the onset date, the silence, the ~3% rate, and reproduces deterministically (E4). |

H4 is the only hypothesis that explains *why the bug appeared when it did*: the race existed only once the sync became cursor-based.

## Evidence

**E1 — the cursor logic** (`apps/tracking/sync.py:31-39`, introduced by `a3f81c2`):

```python
cursor = SyncState.objects.get(name="eta_sync").last_run_at
rows = CarrierUpdate.objects.filter(updated_at__gt=cursor)
...
state.last_run_at = timezone.now()   # line 39, saved after the batch
```

**E2 — the drop, quantified** (reconciliation SQL run 06-18):

```
SELECT count(*) FROM carrier_updates cu
LEFT JOIN shipment_etas se ON se.source_update_id = cu.id
WHERE cu.received_date = '2026-06-17' AND se.id IS NULL;
 count
-------
   143
```

**E3 — the smoking gun:** dropped rows carry `updated_at` values *earlier* than the cursor that skipped them. `updated_at` is set by `auto_now` at Python statement time, but the row becomes visible only at transaction commit. The ingest API (`apps/tracking/ingest.py:74`) holds transactions open 1–8s under load (pgbouncer log, p95 8.2s). Any row whose transaction was open while the sync read its cursor window commits *after* the read with a timestamp *before* the new cursor — permanently invisible to every subsequent incremental run.

**E4 — deterministic reproduction** (`apps/tracking/tests/test_sync_race.py`, written during this RCA):

```
$ uv run pytest apps/tracking/tests/test_sync_race.py -q
F                                                       [100%]
AssertionError: update committed during sync window was never applied
1 failed in 2.31s
```

The test opens an ingest transaction, runs the sync, commits the ingest, runs the sync again — the row is never picked up. Green after the fix below.

## 5 Whys

1. **Why are ETAs stale on the board?** → The nightly sync never applied 143 of 06-17's updates. *(E2)*
2. **Why didn't the sync apply them?** → Its incremental filter `updated_at__gt=cursor` excluded them on every run. *(E1, E3: their timestamps predate the cursor)*
3. **Why do committed rows have timestamps before the cursor?** → `updated_at` is assigned at statement time inside long-lived ingest transactions; visibility begins at commit, 1–8s later. The cursor was advanced to `timezone.now()` in that gap. *(E3; pgbouncer p95)*
4. **Why did the sync design assume timestamp order == visibility order?** → PR #412 was reviewed as a pure performance change; the repo has no documented pattern for incremental cursors, so transaction-visibility semantics were never raised in review. *(PR #412 review thread: zero comments on the cursor; no `references/` or CLAUDE.md entry on cursor patterns)*
5. **Why did it run for 6 days undetected?** → The job's only success signal is its own row count; nothing compares "updates received" to "updates applied". *(worker logs: `eta_sync_completed` every night; no reconciliation metric exists — checked `apps/tracking/metrics.py`)*

Stopped at level 5: both terminal causes (missing pattern documentation, missing reconciliation gate) are actionable process changes.

## Root Cause

The incremental sync in `apps/tracking/sync.py:31-39` treats `updated_at` order as commit-visibility order. Rows written in transactions that were open during a sync run commit after the cursor has advanced past their timestamps, so `updated_at__gt=cursor` excludes them forever. Root-cause test: making the cursor window overlap-safe makes the symptom impossible (E4 test goes green) — causation, necessity, and sufficiency all hold; no co-factor is required to produce the drop.

## Contributing Factors

- **No reconciliation check** — received-vs-applied counts are not compared, so a silent 3% loss looked like success for six days (why #5).
- **Long-lived ingest transactions** (p95 8.2s) — widened the race window from theoretical to 3%-per-night. Not the root cause: even 10ms transactions lose rows eventually.
- **Review framing** — "perf refactor" framing meant no one asked correctness questions; no team reference on cursor-based incremental patterns existed to ask them from.

## Fix

`apps/tracking/sync.py`: overlap the cursor window and make application idempotent — filter with `updated_at__gt=cursor - timedelta(seconds=60)` (covering the max observed transaction hold with margin) and upsert by `source_update_id` so re-reading the overlap is harmless. Cursor advance unchanged. Shipped in `d91e447`; E4's regression test green; backfill re-ran 06-12→06-18 (612 recovered updates, count matches E2 summed).

## Prevention Actions

- [x] **Regression test:** `apps/tracking/tests/test_sync_race.py` — concurrent-commit case, red before fix, green after. *(done, in `d91e447`)*
- [ ] **Reconciliation gate:** nightly count comparison received-vs-applied in `apps/tracking/metrics.py`; alert at >0.5% divergence — turns this whole failure class into a same-day page. *(owner: platform; ticket OPS-2311)*
- [ ] **Pattern doc:** add "incremental cursors: never trust timestamp order across transactions — overlap + idempotent apply" with this RCA linked, to the project CLAUDE.md patterns section, so the next PR #412 gets caught in planning. *(owner: tech lead; ticket OPS-2312)*
- [ ] **Review checklist item:** PRs touching any `SyncState` cursor require an explicit "concurrent-write visibility" answer in the description. *(owner: tech lead; same ticket)*
