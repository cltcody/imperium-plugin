<!--
  EXEMPLAR for /cc:plan:feature — a complete feature plan at the quality bar.
  Entirely SYNTHETIC: "Meridian Freight Systems", the "Dispatch" app, every path,
  person, and code excerpt are fictional. A real plan is saved to the workspace
  plans/ directory. Match the SHAPE and BAR of this document — the file:line
  pattern pinning, per-task VALIDATE commands, gotcha specificity, and the way
  the confidence score is justified — NOT its content.
-->

# Feature Plan: CSV Import for Shipment Schedules

| | |
|---|---|
| **Type** | New capability (enhancement to shipments app) |
| **Complexity** | Medium |
| **Systems affected** | `apps/shipments` (model, service, view, templates, urls), test suite |
| **Stack** | Django 5.1 + htmx 2.0, PostgreSQL 16, uv-managed (per `STACK.md`) |
| **Estimated tasks** | 8, dependency-ordered |

## Feature Description

**User story:** As a dispatch coordinator I want to upload a carrier's weekly schedule CSV so that next week's shipment departure slots appear in Dispatch without re-keying 200+ rows by hand.

**Problem:** Coordinators receive weekly departure schedules from regional carriers as CSV exports. Today they re-type each row into the shipment form (~200 rows/week/coordinator, ~15 typos/week reach the ops board per the June incident log). There is no bulk path.

**Solution:** A `Schedule import` page in the shipments app: upload CSV → server-side parse and validate → show a per-row result partial (htmx) → persist valid rows atomically as `DepartureSlot` records, recording every import as a `ScheduleImportBatch` for audit. Mirrors the existing carrier rate-card import (`apps/carriers/services/rate_import.py`) — same parse/validate/persist shape, same result-partial UX.

**Feasibility check:** Confirmed. The rate-card import proves every pattern this feature needs (file upload form, service-layer CSV parsing, htmx result partial, batch audit model). No new dependencies — stdlib `csv` + existing Django/htmx only. Nothing to extend instead: rate import is carrier-pricing-specific and shares no schema with departure slots; a shared "generic CSV importer" abstraction is explicitly NOT being built (see NOT BUILDING).

## CONTEXT REFERENCES

### Read before implementing

| File | Lines | Why |
|---|---|---|
| `apps/carriers/services/rate_import.py` | 1–140 | The pattern to mirror end-to-end: `ImportResult` dataclass, `parse_*` pure function, `persist_*` transactional function |
| `apps/carriers/views.py` | 61–98 | htmx upload view shape: GET renders page, POST returns partial for `HX-Request`, redirect otherwise |
| `apps/carriers/forms.py` | 22–47 | `RateCardUploadForm` — file-size and content-type validation in `clean_csv_file` |
| `apps/carriers/templates/carriers/partials/_rate_import_result.html` | all | Result-partial markup conventions (row-error table, `.import-summary` classes) |
| `apps/shipments/models.py` | 18–74 | `Shipment` and `DepartureSlot` models; `DepartureSlot.external_ref` is the natural key for upsert |
| `apps/shipments/tests/test_views.py` | 1–55 | View-test conventions: `pytest.mark.django_db`, `client` fixture, permission fixtures from `conftest.py` |
| `core/timezones.py` | 9–31 | `depot_tz(depot_code)` — the ONLY sanctioned way to localize depot-local times |
| `CLAUDE.md` | all | Service-layer rule (no ORM writes in views), structured-logging naming (`*_started/_completed/_failed`) |

### Patterns to follow (actual excerpts)

**Result-object pattern** — `apps/carriers/services/rate_import.py:18-31`:

```python
@dataclass(frozen=True)
class ImportResult:
    ok_rows: int
    errors: list[RowError]          # RowError(line_no, field, message)

    @property
    def has_errors(self) -> bool:
        return bool(self.errors)
```

**Transactional persist with upsert** — `apps/carriers/services/rate_import.py:96-112`:

```python
@transaction.atomic
def persist_rates(carrier: Carrier, rows: list[ParsedRate], *, user) -> ImportResult:
    batch = RateImportBatch.objects.create(carrier=carrier, created_by=user)
    for row in rows:
        RateCard.objects.update_or_create(
            carrier=carrier, lane_code=row.lane_code,
            defaults={"amount": row.amount, "batch": batch},
        )
    logger.info("rate_import_completed", extra={"batch": batch.pk, "rows": len(rows)})
```

**htmx dual-response view** — `apps/carriers/views.py:80-93`:

```python
if form.is_valid():
    result = persist_rates(carrier, parsed.rows, user=request.user)
    if request.headers.get("HX-Request"):
        return render(request, "carriers/partials/_rate_import_result.html", {"result": result})
    return redirect("carriers:rate-list")
```

### New files to create

| File | Purpose |
|---|---|
| `apps/shipments/services/schedule_import.py` | `parse_schedule_csv()` + `persist_schedule()` |
| `apps/shipments/migrations/00XX_scheduleimportbatch.py` | Generated — `ScheduleImportBatch` model |
| `apps/shipments/templates/shipments/schedule_import.html` | Upload page |
| `apps/shipments/templates/shipments/partials/_schedule_import_result.html` | htmx result partial |
| `apps/shipments/tests/test_schedule_import.py` | Service unit tests |
| `apps/shipments/tests/test_schedule_import_views.py` | View/permission/integration tests |
| `apps/shipments/tests/fixtures/schedule_import/*.csv` | Valid, malformed, and BOM-prefixed fixtures |

### Documentation (verified 2026-07-01)

- Django file uploads — https://docs.djangoproject.com/en/5.1/topics/http/file-uploads/#basic-file-uploads — `UploadedFile.read()` returns bytes; decode explicitly.
- Django `update_or_create` — https://docs.djangoproject.com/en/5.1/ref/models/querysets/#update-or-create — race-safety caveat; acceptable here because imports are per-coordinator and wrapped in `transaction.atomic` (see Task 4 GOTCHA).
- Python `csv.DictReader` — https://docs.python.org/3/library/csv.html#csv.DictReader — missing keys yield `None`, restkey behavior for ragged rows.
- htmx `HX-Request` header — https://htmx.org/docs/#request-headers — server-side partial detection (matches existing pattern).

No new packages — nothing to API-verify beyond stdlib `csv` (verified above).

## NOT BUILDING

- **No generic/shared CSV importer abstraction.** Two importers (rates, schedules) do not justify shared code under the 3+ rule in `CLAUDE.md`. Copy the shape, not a base class.
- **No async/background processing.** Weekly files are ≤2,000 rows; parse+persist measured pattern (rate import) handles 5k rows in <2s. Revisit only if files grow 10×.
- **No column-mapping UI.** The CSV header contract is fixed (5 named columns below); carriers already produce it. A mapping wizard is a product decision → PRD, not this plan.
- **No CSV export.** Out of scope; note for later that export would need formula-injection escaping — irrelevant on import.
- **No partial-success commits.** Any row error rejects the whole file (all-or-nothing keeps the audit model simple and matches coordinator expectations from rate import).

## STEP-BY-STEP TASKS

**CSV header contract (decided, not deferred):** `external_ref,carrier_code,depot_code,departure_date,cutoff_time` — dates ISO `YYYY-MM-DD`, times `HH:MM` in the depot's local timezone.

### Task 1 — CREATE `apps/shipments/tests/fixtures/schedule_import/` fixtures

- **IMPLEMENT:** Three files: `valid_10_rows.csv` (clean), `bad_rows.csv` (missing column, bad date, unknown depot code — one defect per row), `bom_prefixed.csv` (same as valid but written with `utf-8-sig`).
- **PATTERN:** `apps/carriers/tests/fixtures/rate_import/` — same directory convention.
- **GOTCHA:** Write `bom_prefixed.csv` with an explicit BOM (`open(..., "w", encoding="utf-8-sig")` in a scratch snippet) — spreadsheet tools prepend it, and it is this feature's most likely real-world input.
- **VALIDATE:** `head -1 apps/shipments/tests/fixtures/schedule_import/valid_10_rows.csv` → prints exactly the 5-column header above.

### Task 2 — UPDATE `apps/shipments/models.py` — ADD `ScheduleImportBatch`

- **IMPLEMENT:** Fields: `created_by` (FK user, PROTECT), `created_at`, `source_filename`, `ok_rows` (int), mirroring `RateImportBatch` (`apps/carriers/models.py:88-101`). Add `batch = models.ForeignKey(ScheduleImportBatch, null=True, on_delete=models.SET_NULL)` to `DepartureSlot`.
- **PATTERN:** `apps/carriers/models.py:88-101`.
- **IMPORTS:** `from django.conf import settings` (AUTH_USER_MODEL FK) — matches existing usage at `apps/shipments/models.py:6`.
- **GOTCHA:** `DepartureSlot.external_ref` already has `unique=True` (`apps/shipments/models.py:61`) — do NOT add another index.
- **VALIDATE:** `uv run python manage.py makemigrations shipments && uv run python manage.py migrate && uv run python manage.py makemigrations --check --dry-run`

### Task 3 — CREATE `apps/shipments/services/schedule_import.py` — parser/validator

- **IMPLEMENT:** `parse_schedule_csv(file) -> ParsedSchedule` — decode `utf-8-sig`, `csv.DictReader`, validate header set exactly, per-row: `external_ref` non-empty, `carrier_code` exists (`Carrier.objects.filter(code__in=...)` — one query for the whole file, not per row), `depot_code` resolvable via `core.timezones.depot_tz`, date/time parseable. Collect `RowError(line_no, field, message)`; never raise on bad data. Localize `datetime.combine(departure_date, cutoff_time)` with `depot_tz(depot_code)`.
- **PATTERN:** `apps/carriers/services/rate_import.py:34-77` (parse function), `:18-31` (result dataclass).
- **IMPORTS:** `import csv, io`; `from dataclasses import dataclass`; `from core.timezones import depot_tz`.
- **GOTCHA (1):** `UploadedFile.read()` is bytes; wrap with `io.TextIOWrapper(file, encoding="utf-8-sig")` — plain `utf-8` leaves the BOM glued to the first header key and every file from a spreadsheet export fails with a misleading "missing column external_ref".
- **GOTCHA (2):** Project has `USE_TZ=True` — a naive combined datetime raises `RuntimeWarning` and stores as UTC, silently shifting cutoffs by the depot's UTC offset. Always `.replace(tzinfo=depot_tz(...))` via the helper; never `django.utils.timezone.make_aware` with the default (server) zone.
- **VALIDATE:** `uv run python -c "from apps.shipments.services.schedule_import import parse_schedule_csv; r = parse_schedule_csv(open('apps/shipments/tests/fixtures/schedule_import/bom_prefixed.csv','rb')); assert not r.errors, r.errors; print('BOM fixture parses clean:', len(r.rows), 'rows')"`

### Task 4 — UPDATE `apps/shipments/services/schedule_import.py` — ADD `persist_schedule`

- **IMPLEMENT:** `@transaction.atomic persist_schedule(parsed, *, user, filename) -> ScheduleImportBatch` — create batch, then per row `DepartureSlot.objects.update_or_create(external_ref=..., defaults={...})` (re-import of a corrected file must update, not duplicate). Structured logs `schedule_import_started` / `schedule_import_completed` with `extra={"batch": ..., "rows": ...}`.
- **PATTERN:** `apps/carriers/services/rate_import.py:96-112` (excerpt above).
- **GOTCHA:** Callers must check `parsed.has_errors` BEFORE calling persist (all-or-nothing contract). Guard anyway: `if parsed.has_errors: raise ValueError("refusing to persist rows with errors")` — defense against a future caller skipping the check.
- **VALIDATE:** `uv run pytest apps/shipments/tests/test_schedule_import.py -q` (written in Task 5 — run after; for immediate feedback: `uv run python -c "from apps.shipments.services.schedule_import import persist_schedule"`)

### Task 5 — CREATE `apps/shipments/tests/test_schedule_import.py` — service unit tests

- **IMPLEMENT:** Cases: valid file parses 10 rows / bad_rows yields exactly 3 `RowError`s with correct `line_no`s / BOM file parses clean / persist creates batch + slots / **re-importing the same file updates in place (slot count unchanged, `cutoff_at` updated)** / persist refuses a parsed result with errors / cutoff stored tz-aware in the depot zone (assert `slot.cutoff_at.utcoffset()` matches `depot_tz("ROT")`, not the server zone).
- **PATTERN:** `apps/carriers/tests/test_rate_import.py:1-90` — fixture-loading helper at `:12-18`.
- **VALIDATE:** `uv run pytest apps/shipments/tests/test_schedule_import.py -q`

### Task 6 — UPDATE `apps/shipments/forms.py` + `views.py` + templates — upload UI

- **IMPLEMENT:** `ScheduleImportForm` (single `FileField`; `clean_csv_file` rejects >5 MB and non-`.csv` extension — mirror `apps/carriers/forms.py:22-47`). View `schedule_import` decorated `@login_required` **and** `@permission_required("shipments.add_scheduleimportbatch", raise_exception=True)`: GET renders `schedule_import.html`; POST parses → if errors render partial with errors (nothing persisted) → else persist and render partial with summary; non-htmx POST falls back to redirect + message. Templates mirror the rate-import pair.
- **PATTERN:** `apps/carriers/views.py:61-98` (excerpt above); `_rate_import_result.html` for partial markup.
- **GOTCHA:** Return the errors partial with HTTP 200, not 422 — htmx 2.0 does not swap non-2xx responses without `response-targets` config this project doesn't use (checked `templates/base.html:14-19`: no ext loaded).
- **VALIDATE:** `uv run python manage.py shell -c "from django.template.loader import get_template; get_template('shipments/schedule_import.html'); get_template('shipments/partials/_schedule_import_result.html'); print('templates OK')"`

### Task 7 — UPDATE `apps/shipments/urls.py` + `templates/base.html` — wiring

- **IMPLEMENT:** `path("schedules/import/", views.schedule_import, name="schedule-import")` in the existing `shipments` namespace (`apps/shipments/urls.py:9-15`); nav link in the Shipments dropdown guarded by `{% if perms.shipments.add_scheduleimportbatch %}` — mirror the rate-import nav entry at `templates/base.html:52-54`.
- **VALIDATE:** `uv run python manage.py shell -c "from django.urls import reverse; print(reverse('shipments:schedule-import'))"`

### Task 8 — CREATE `apps/shipments/tests/test_schedule_import_views.py` — view/integration tests

- **IMPLEMENT:** Happy path (login + perm, POST valid fixture with `HX-Request: true`, assert partial contains summary AND `DepartureSlot` count increased); permission denied (authenticated user without perm → 403 — this exercises the new guard, not just its presence); bad file → 200 + row errors rendered + **zero** rows persisted; oversize file rejected by form; non-htmx POST redirects.
- **PATTERN:** `apps/shipments/tests/test_views.py:1-55`; permission fixtures `conftest.py:31-44`.
- **GOTCHA:** Set the htmx header via `client.post(..., headers={"HX-Request": "true"})` — the `HTTP_HX_REQUEST=` kwarg form is the pre-Django-4.2 spelling; this codebase uses `headers=` everywhere.
- **VALIDATE:** `uv run pytest apps/shipments/tests/test_schedule_import_views.py -q`

## TESTING STRATEGY

- **Unit (Task 5):** parser and persist logic in isolation — every validation rule has one bad-fixture row proving it fires, with the right line number.
- **Integration (Task 8):** full request cycle through form → service → DB, both htmx and fallback paths, permission boundary tested from the denied side.
- **Edge cases covered:** BOM-prefixed input, re-import idempotency, all-or-nothing on partial failure, timezone correctness (offset asserted, not assumed), empty file (header only → "0 rows" summary, no batch created), duplicate `external_ref` within one file (last-row-wins is the `update_or_create` behavior — assert it explicitly so it's a decision, not an accident).
- **Mirror:** `apps/carriers/tests/test_rate_import.py` for structure and fixture handling.

## VALIDATION COMMANDS (resolved from `STACK.md`, single component, `working_dir: .`)

1. **smoke:** `uv run python -c "import apps.shipments.services.schedule_import"` then `uv run python manage.py check`
2. **lint / format:check:** `uv run ruff check . && uv run ruff format --check .`
3. **typecheck:** `uv run mypy apps/shipments`
4. **test (unit):** `uv run pytest apps/shipments/tests/test_schedule_import.py -q`
5. **test (integration):** `uv run pytest apps/shipments -q`
6. **migrate:** `uv run python manage.py migrate && uv run python manage.py makemigrations --check --dry-run`
7. **manual:** dev server → `/shipments/schedules/import/` → upload `bad_rows.csv` (expect 3 row errors, nothing saved) → upload `valid_10_rows.csv` (expect 10-row summary) → re-upload it (expect update, not duplicates).

## ACCEPTANCE CRITERIA

- [ ] Coordinator with the import permission can upload a valid CSV and see a per-row summary; slots appear on the schedule board
- [ ] A file with any bad row persists nothing and shows every error with its line number
- [ ] Re-importing a corrected file updates existing slots (no duplicates)
- [ ] BOM-prefixed files import cleanly
- [ ] Users without `shipments.add_scheduleimportbatch` get 403 and see no nav link
- [ ] Cutoff times stored tz-aware in the depot's zone (asserted by test, not eyeballed)
- [ ] Every `ScheduleImportBatch` records who, when, filename, row count
- [ ] All validation commands 1–6 pass; manual pass 7 done

## Confidence score: 9/10

**Why 9 — what is pinned, not hoped:**
- Every task mirrors a shipped, working feature with exact `file:line` references and excerpts pasted above — no invented patterns anywhere in the plan.
- Zero new dependencies; the only non-Django API used (`csv.DictReader`, `io.TextIOWrapper`) is stdlib and its two relevant gotchas (BOM, bytes-vs-text) are already encoded as task GOTCHAs with the exact fix.
- Seed content is decided, not deferred: the 5-column header contract, fixture contents, permission codename, URL name, and log event names are all specified — the implementer makes no naming decisions.
- Every task has an executable VALIDATE, and the two behavior-introducing tasks (3, 6) validate the new behavior positively (BOM fixture parses; 403 asserted from the denied side) rather than by presence-grep.

**Why not 10 — the honest residual:** `core/timezones.py:depot_tz` coverage of carrier depot codes was verified only for the codes in the fixtures (ROT, HAM, GDN); a real weekly file could contain a depot code the mapping lacks. Mitigated, not eliminated: unknown depot codes are a defined row-level validation error (Task 3) with a test, so the failure mode is a clean rejection, not corruption. That residual is operational, not architectural — it cannot force a replan mid-implementation, which is why this rounds to 9 and ships.
