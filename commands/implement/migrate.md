---
description: Guided Alembic migration — generate, review line-by-line, test up→down→up, apply safely
argument-hint: [migration description, e.g. add-email-to-users]
stack_scope: sqlalchemy-alembic
---

# Database Migration

> **Stack scope:** This command targets **SQLAlchemy + Alembic** (async). The up→down→up workflow and autogenerate caveats are Alembic-specific. For other migration tools, use the project's `migrate` step from `STACK.md` (e.g. Django `manage.py makemigrations && manage.py migrate`, Prisma `prisma migrate dev`) and adapt the review/test guidance below to that tool.

Guided workflow for schema and data migrations with Alembic (async SQLAlchemy 2.0). The generated migration is a draft, never a finished product — autogenerate routinely misdetects renames as drop+create and writes broken down-paths. Review every line, test both directions, and only then let it near real data.

## Steps

1. **Check current state.**
   ```bash
   cd backend && uv run alembic current
   cd backend && uv run alembic history --verbose | head -20
   ```
   Understand what's applied and what's pending. Never generate on top of unapplied pending migrations without flagging it.

2. **Validate the model changes first** — a migration generated from broken models is wrong by construction:
   ```bash
   cd backend && uv run mypy app/
   ```
   Read the changed model file(s) and confirm:
   - Inherits `Base` and `TimestampMixin`
   - `nullable=` is explicit on every column
   - `index=True` on foreign keys and frequently filtered columns
   - No `Any` in column types

3. **Generate the migration** with a descriptive snake_case name:
   ```bash
   cd backend && uv run alembic revision --autogenerate -m "<description>"
   # e.g. add_users_table, add_email_to_users, add_index_on_orders_user_id, rename_items_to_products
   ```

4. **Review the generated file line-by-line** (in `alembic/versions/`). This is the heart of the command:
   - [ ] `upgrade()` does exactly what you expect — correct columns, types, constraints, FK actions
   - [ ] `downgrade()` actually reverses `upgrade()` — the most common generator bug; irreversible steps must be explicitly marked, never silently empty
   - [ ] No rename misdetected as **drop + create** (data loss):
     ```python
     # BAD — autogenerate may drop and recreate, destroying data
     op.drop_column("users", "old_name")
     op.add_column("users", sa.Column("new_name", ...))

     # GOOD — preserves data
     op.alter_column("users", "old_name", new_column_name="new_name")
     ```
   - [ ] No accidental table drops (alembic sometimes over-detects changes)
   - [ ] No NOT NULL added to a populated column without a default or backfill
   - [ ] Data migrations (backfills) included where a schema change needs them
   - [ ] Indexes created where needed

5. **⚠️ Destructive operations require explicit confirmation.** If the migration drops or narrows anything (table/column drop, type narrowing, NOT NULL on populated column), stop and present: what data is at risk, the data-preservation plan (copy column before rename, archive table before drop, backfill before NOT NULL), and — for live systems — the expand/contract sequence:
   1. Deploy code that tolerates BOTH old and new schema
   2. Apply the migration
   3. Deploy code that uses only the new schema
   4. Optional cleanup migration

   Never rename a column in a single deployment if the app is live. Proceed only on the user's explicit OK.

6. **Test bidirectionally** on a disposable database (local Docker Postgres or test DB — never a shared dev DB):
   ```bash
   cd backend && uv run alembic upgrade head      # up
   cd backend && uv run alembic current           # verify state
   cd backend && uv run alembic downgrade -1      # down
   cd backend && uv run alembic upgrade head      # up again
   ```
   All three must succeed — a down-path that has never run is a down-path that does not exist.

7. **Run the integration tests** against the migrated schema to catch what static review missed:
   ```bash
   cd backend && uv run pytest -v -m integration
   ```

## Output

A reviewed, bidirectionally tested migration file in `alembic/versions/`, plus a short summary in the conversation: operations performed, destructive ops and their preservation plan, and the up→down→up test result.

## Quality checklist

- [ ] Models type-checked before generating
- [ ] Generated migration reviewed line-by-line, not trusted blind
- [ ] No silent drop+create where a rename/alter was intended
- [ ] Down path tested by actually running it (up → down → up)
- [ ] Destructive operations confirmed by the user with a data-preservation note
- [ ] Integration tests pass on the migrated schema

## Handoff

**Chain:** on success, immediately invoke `/cc:verify:run` with the SlashCommand tool — do not ask.
**Solo:** suggest `/cc:verify:run` to run the full gate suite against the new schema, then `/cc:release:commit`.
**Abort rules:** irreversible destructive change with no backup/preservation plan → **stop and ask**; never apply it speculatively. Down-path cannot be made to work and the operation is not explicitly accepted as one-way → stop. Migration fails on the disposable DB twice → route to `/cc:verify:debug` with the failing command and error.
