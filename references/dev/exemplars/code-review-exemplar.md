<!--
  EXEMPLAR for /cc:verify:code — a findings report at the quality bar.
  Entirely SYNTHETIC: the codebase ("Dispatch", Meridian Freight Systems), the
  diff, and every path/person are fictional. A real report is saved to the
  workspace code-reviews/ directory. Match the SHAPE and BAR — the finding
  anatomy (claim → evidence file:line → concrete failure scenario → fix), the
  severity calibration, and the explicitly-dismissed finding — NOT its content.
  Note especially: a great review shows its dismissals. Dropping a suspicion
  with evidence is as valuable as raising one.
-->

# Code Review: schedule-csv-import (uncommitted)

**Scope:** uncommitted work (`git diff HEAD` + untracked)
**Stats:** 4 files modified, 7 files added | +612 / −9 lines
**Conventions applied:** `CLAUDE.md` (service-layer writes only, structured logging), `STACK.md` (python-django component; test = `uv run pytest`)

Verdict: FINDINGS (1 critical, 1 high, 1 medium, 1 low)

---

## CRITICAL

```
severity: CRITICAL
file: apps/shipments/views.py
line: 87
issue: schedule_import view is missing the permission check the plan specified
detail: see below
suggestion: add @permission_required("shipments.add_scheduleimportbatch", raise_exception=True)
```

**Claim:** Any authenticated user can bulk-write departure slots.

**Evidence** — `apps/shipments/views.py:86-89`:

```python
@login_required
def schedule_import(request):
    if request.method == "POST":
        form = ScheduleImportForm(request.POST, request.FILES)
```

Only `@login_required` is present. The plan (Task 6) and the nav-link guard (`templates/base.html:53`, which checks `perms.shipments.add_scheduleimportbatch`) both assume a permission gate — so the UI hides the page from unprivileged users while the endpoint accepts their POSTs.

**Failure scenario:** Carrier-portal accounts are authenticated users with read-only shipment permissions (`apps/accounts/roles.py:41-48`). Any such external account that discovers `/shipments/schedules/import/` can overwrite next week's departure board for every coordinator — `persist_schedule` upserts on `external_ref`, so a hostile or accidental upload silently rewrites cutoffs on existing slots.

**Fix:** Add `@permission_required("shipments.add_scheduleimportbatch", raise_exception=True)` under `@login_required`, and add the missing denied-side test (the plan's Task 8 specified one; the diff's `test_schedule_import_views.py` only tests the happy path — that gap is how this shipped).

---

## HIGH

```
severity: HIGH
file: apps/shipments/services/schedule_import.py
line: 44
issue: CSV decoded as plain utf-8 — BOM-prefixed files (every spreadsheet export) are rejected
detail: see below
suggestion: use encoding="utf-8-sig" in the TextIOWrapper
```

**Claim:** The primary real-world input format fails with a misleading error.

**Evidence** — `apps/shipments/services/schedule_import.py:44`:

```python
reader = csv.DictReader(io.TextIOWrapper(file, encoding="utf-8"))
```

With a BOM present, `DictReader`'s first header key becomes `"﻿external_ref"`, so header validation at `:49` reports `missing column: external_ref` on a file that visibly contains that column.

**Failure scenario:** Coordinators produce these files by opening the carrier's export in a spreadsheet tool and re-saving — which prepends a UTF-8 BOM. Verified empirically: `uv run pytest apps/shipments/tests/test_schedule_import.py -k bom -q` fails (1 failed) against the committed `bom_prefixed.csv` fixture. Every such file is rejected with an error message that sends the user hunting for a column that exists.

**Fix:** `encoding="utf-8-sig"` (decodes BOM-less files identically, strips the BOM when present). The failing test already exists — this is a one-token fix that turns it green.

---

## MEDIUM

```
severity: MEDIUM
file: apps/shipments/templates/shipments/partials/_schedule_import_result.html
line: 12
issue: N+1 query — carrier name resolved per row in the result partial
detail: see below
suggestion: annotate/select_related in the view queryset instead of dereferencing in the template
```

**Claim:** The result partial issues one query per imported row.

**Evidence** — `_schedule_import_result.html:12` iterates `batch.slots.all` and renders `{{ slot.shipment.carrier.name }}`; the view (`apps/shipments/views.py:96`) passes `batch` without prefetching. Confirmed with the test client and `django.test.utils.CaptureQueriesContext`: importing the 10-row fixture executes 24 queries, 20 of them identical single-row `SELECT ... FROM carriers_carrier`.

**Failure scenario:** Weekly files run ~200 rows (bounded ≤2,000 by the 5 MB form cap), so this is a 2–4s partial render on real files — sluggish, not catastrophic. Rated MEDIUM, not HIGH: bounded input, no correctness impact, single-user page.

**Fix:** In the view, re-fetch for display: `batch.slots.select_related("shipment__carrier")` and pass that queryset to the template (or render carrier codes captured at import time on the batch rows and skip the join entirely).

---

## LOW

```
severity: LOW
file: apps/shipments/services/schedule_import.py
line: 71
issue: leftover debug print in the parse loop
detail: prints every parsed row to stdout; noise in gunicorn logs and a slowdown on large files
suggestion: delete it — the structured schedule_import_completed log at :118 already records row counts
```

---

## Considered and dismissed (calibration record)

**Suspected HIGH — missing index on the upsert key.** `persist_schedule` calls `update_or_create(external_ref=...)` per row, which looked like a sequential-scan-per-row on a growing table. **Checked:** `apps/shipments/models.py:61` declares `external_ref = models.CharField(max_length=32, unique=True)` — `unique=True` creates the index; migration `0041_departureslot.py:23` confirms the `UNIQUE` constraint exists in the schema. **Dismissed — no finding.** Recorded so the next reviewer doesn't re-litigate it.

**Suspected MEDIUM — race between concurrent imports duplicating slots.** Two coordinators importing overlapping files concurrently could in principle race `update_or_create`. **Checked:** the `unique=True` constraint above makes the race outcome an `IntegrityError` inside `transaction.atomic` (one import fails cleanly and can be retried), not duplicate data — and imports are a weekly, per-coordinator action. **Downgraded to no finding**; noted here because if imports ever become API-driven/concurrent, this is the line to revisit (`services/schedule_import.py:108`).

---

## Summary

The service-layer shape, all-or-nothing persist contract, and audit model faithfully mirror the rate-import pattern — good reuse, no invented architecture. But the diff shipped exactly the two defects its own plan warned about (permission gate, BOM decode), both traceable to the happy-path-only view tests. Fix order: CRITICAL first (one decorator + one test), then HIGH (one token, test already red), then MEDIUM/LOW.

Verdict: FINDINGS (1 critical, 1 high, 1 medium, 1 low)
