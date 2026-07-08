---
description: Add a new service to this project (database, cache, auth, AI/RAG, storage, email, etc.)
argument-hint: [service name, e.g. redis, supabase, pgvector]
stack_scope: python-fastapi
disable-model-invocation: true
---

# Add a Service

Add a new service (database, cache, auth, AI/RAG, storage, email, etc.) and wire it into config, health checks, and Docker.

> **Stack scope:** Targets a **Python / FastAPI** vertical-slice backend — the config, dependency-injection, health-check, and Docker wiring steps are framework-specific. For other stacks, adapt to your framework's config/DI conventions (or use `/cc:plan:feature`). Any validation it runs still resolves from the project's `STACK.md`.

## Steps

### 1. Identify the service

Ask: **What service do you want to add?** Common options:
- `supabase` — managed PostgreSQL + auth + storage + realtime
- `pgvector` — vector search inside existing PostgreSQL (for RAG)
- `qdrant` — standalone vector database (for RAG at scale)
- `redis` — caching, sessions, rate limiting, queues
- `clerk` / `auth0` — managed auth with UI; `jwt` — custom auth with JSON Web Tokens (DIY)
- `s3` / `r2` — file storage; `resend` / `sendgrid` — transactional email
- `openai` / `anthropic` — AI completions
- `arq` — async background job queue (Redis-backed)

### 2. Read the reference pattern

- `reference/patterns/database-options.md` — for databases and vector stores
- `reference/patterns/auth-patterns.md` — for auth services

### 3. Make the changes — for each service, do ALL of the following

#### 3.1 Update STACK.md
Mark the service as `STATUS=active` and add notes.

#### 3.2 Update docker-compose.yml (if self-hosted)

Examples (add any new volume to the `volumes:` section at the bottom):

```yaml
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    restart: unless-stopped
  qdrant:
    image: qdrant/qdrant:latest
    ports:
      - "6333:6333"
    volumes:
      - qdrant_data:/qdrant/storage
    restart: unless-stopped
```

#### 3.3 Update backend/.env.example

Add the required env vars for the service:

```bash
# Redis
REDIS_URL=redis://localhost:6379
# Qdrant
QDRANT_URL=http://localhost:6333
QDRANT_COLLECTION=my_collection
# Supabase (replaces DATABASE_URL)
DATABASE_URL=postgresql+asyncpg://postgres:[password]@db.[project].supabase.co:5432/postgres
SUPABASE_URL=https://[project].supabase.co
SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_KEY=...
```

#### 3.4 Create the integration module

Create `backend/app/core/<service>.py` with: connection setup (client init, connection pool); a dependency function (like the `get_db()` pattern); a health check function (wired into `/health/ready`); structured logging on connect/disconnect.

#### 3.5 Update backend/app/core/health.py

Add a health check for the new service so `/health/ready` covers it.

### 4. Service-specific notes

#### Supabase specifics

Supabase IS PostgreSQL — your existing SQLAlchemy models work unchanged.

1. Create project at supabase.com
2. Get connection string from: Settings → Database → Connection string → URI
3. Replace `DATABASE_URL` in `backend/.env`
4. Run `uv run alembic upgrade head` to apply your migrations
5. Update `STACK.md`: Primary Database TYPE → Supabase (PostgreSQL)

Optional extras: Auth → `gotrue` client or Supabase JS SDK (frontend); Storage → `supabase-py` client; Realtime → Supabase JS SDK (frontend).

#### pgvector specifics (RAG inside PostgreSQL)

pgvector adds vector similarity search to your existing database — best choice for most RAG use cases. Install: `cd backend && uv add pgvector sqlalchemy`

```python
# In alembic migration — enable the extension
op.execute("CREATE EXTENSION IF NOT EXISTS vector")
```

Model + query example:
```python
from pgvector.sqlalchemy import Vector

class Document(Base, TimestampMixin):
    __tablename__ = "documents"
    id: Mapped[int] = mapped_column(primary_key=True)
    content: Mapped[str] = mapped_column(Text)
    embedding: Mapped[list[float]] = mapped_column(Vector(1536))  # dim depends on model

# Cosine similarity search
result = await db.execute(
    select(Document)
    .order_by(Document.embedding.cosine_distance(query_embedding))
    .limit(5)
)
```

### 5. Verify nothing broke — confirm the integration is green

```bash
cd backend && uv run pytest -v
cd backend && uv run mypy app/
cd backend && uv run pyright app/
```

## Output

The service is fully wired: `STACK.md` updated to `STATUS=active`, `docker-compose.yml` extended (if self-hosted), env vars documented in `backend/.env.example`, an integration module at `backend/app/core/<service>.py`, and a health check registered in `/health/ready`.

## Quality checklist

- [ ] STACK.md marks the service `STATUS=active` with notes
- [ ] All required env vars documented in `backend/.env.example`
- [ ] Integration module follows the `get_db()` dependency pattern with structured logging
- [ ] `/health/ready` covers the new service
- [ ] Tests, mypy, and pyright all green after wiring

## Handoff

**Chain:** Invoke `/cc:verify:run` after wiring to confirm tests, types, and lint are all green.
**Solo:** Suggest `/cc:verify:run`, then `/cc:release:env` if new secrets were introduced, and `/cc:plan:feature` to build the first feature that uses the service.
**Abort rules:** If `STACK.md` shows `STATUS=not initialized` for the project itself, stop and route to `/cc:plan:setup` first. If `/cc:verify:run` is red after wiring and the failure cannot be fixed immediately, route to `/cc:verify:debug` — do not leave the service half-integrated.
