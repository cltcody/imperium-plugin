---
description: Audit environment variables for security, completeness, and documentation
---

# Environment Audit

Audit environment variables for security, completeness, and documentation — run before
every deployment. This audit is **stack-agnostic**: the secret-scanning logic is neutral,
and config inspection is driven by the project's `STACK.md`, not hardcoded paths.

## Steps

### 0. Resolve the stack

Read the project's `STACK.md` and resolve per
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. For each `component`, note its
`working_dir` (where its `.env` / `.env.example` and config live) and `language` (which
source file extension and settings idiom to inspect). If there is no `STACK.md`,
auto-detect components once from project markers and recommend the user run
`/cc:setup:stack` to persist a manifest. The `.env` and secret-scanning steps below stay
stack-neutral; only the config-validation step (step 4) adapts to each component's
`language`.

### 1. Compare .env.example vs .env

Run per component, from its `working_dir` (a component may keep its env at the repo root —
use the location its `working_dir` resolves to; an `.env` at the project root applies when
a component has no local one).

```bash
# Keys in .env.example
grep -E "^[A-Z_]+" .env.example | cut -d= -f1 | sort > /tmp/env_example_keys.txt

# Keys in actual .env (if it exists)
[ -f .env ] && grep -E "^[A-Z_]+" .env | cut -d= -f1 | sort > /tmp/env_keys.txt

# Keys in .env not in .env.example (undocumented)
comm -23 /tmp/env_keys.txt /tmp/env_example_keys.txt

# Keys in .env.example not in .env (potentially missing)
comm -23 /tmp/env_example_keys.txt /tmp/env_keys.txt
```

### 2. Check for hardcoded secrets in source

Stack-neutral pattern scan across the whole repo — credential assignments that bake a
literal into source rather than reading from the environment.

```bash
# Common secret patterns in any source file
grep -rnI \
  -e "password\s*[:=]\s*['\"][^'\"]" \
  -e "secret\s*[:=]\s*['\"][^'\"]" \
  -e "api[_-]\?key\s*[:=]\s*['\"][^'\"]" \
  -e "token\s*[:=]\s*['\"][^'\"]" \
  --exclude-dir={.git,node_modules,.venv,venv,dist,build,.next} \
  . | grep -viE "test|example|#|//|settings\.|os\.environ|getenv|process\.env|import\.meta\.env"
```

```bash
# Check container / compose definitions for hardcoded secrets (if present)
for f in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
  [ -f "$f" ] && grep -nE "password|secret|key|token" "$f" | grep -viE "#|POSTGRES_PASSWORD: postgres"
done
```

### 3. Verify .env is not committed

```bash
git log --all --oneline -- "**/.env" ".env"
git status --short | grep "\.env$"
```

**Expected:** zero results. `.env` must never be in git history (for any component).

### 4. Verify settings validation in code

Inspect each component's config/settings file — the one that loads env vars. Locate it from
the component's `working_dir` and `language` (e.g. a Python pydantic-settings `config.py`/
`settings.py`, a Node config module or `zod`/`envalid` schema, a Django `settings.py`). Use
`Read` on whatever the project actually uses.

Check (idioms vary by language, the intent does not):
- Required vars raise a clear error if missing (not silently default to `null`/`None`)
- Sensitive settings (e.g. `SECRET_KEY`, `DATABASE_URL`) have no fallback default in
  production
- Validation runs on load / at startup, not lazily — and the env-file path is explicit
  (e.g. pydantic `model_config` with `validate_default=True` and an explicit `env_file`; a
  schema parsed eagerly at module load in Node)

### 5. Check sensitive vars are not logged

Run per component, from its `working_dir`, against its `language`'s source files. Match the
project's settings-access idiom (e.g. `settings.` in Python, `config.`/`process.env.` in
Node) against logging/print calls.

```bash
# Example for a Python component; adapt the accessor and glob to the component's language
grep -rnI -e "settings\." -e "config\." -e "process\.env\." . \
  --exclude-dir={.git,node_modules,.venv,venv,dist,build,.next} \
  | grep -iE "logger|\.log\(|console\.|print\("
```

**Expected:** No logging of `DATABASE_URL`, `SECRET_KEY`, or any credential field.

### 6. Verify all active services have vars

Use `Read` on `STACK.md` and the project's service/dependency notes. For every service
marked active, confirm its required env vars exist in the relevant `.env.example`.

## Output

An env audit report in this format:

```
ENV AUDIT
─────────
🔴 CRITICAL  — security risk (secret in code, .env committed)
🟠 HIGH      — missing required var, app will fail to start
🟡 MEDIUM    — undocumented var or weak default
🟢 LOW       — documentation improvement

.env.example coverage: X/Y vars documented (per component)
Secrets in source: <n> found / CLEAN
.env in git history: YES (🔴) / NO (✅)

Overall: CLEAN / ISSUES FOUND
```

Adapt the per-component rows to whatever components the project's `STACK.md` defines.

## Quality checklist

- [ ] Every key in each `.env` is documented in its `.env.example` and vice versa
- [ ] Zero hardcoded secrets in source or container/compose definitions
- [ ] `.env` absent from git history and working tree status
- [ ] Settings validation rejects missing required vars; no production fallback defaults
- [ ] No credential fields appear in logging or print statements

## Handoff

**Chain:** If the audit is CLEAN, invoke `/cc:release:deploy` to continue the release. If issues are found, fix them, run `/cc:verify:run` to confirm nothing broke, then re-run `/cc:release:env` until clean.

**Solo:** Report the audit results. On findings, suggest fixing them and re-running; on clean, suggest `/cc:release:deploy`.

**Abort rules:** Any 🔴 CRITICAL finding blocks deployment — stop the release chain immediately. Rotate any credentials that were ever committed to git before proceeding; if `.env` is in git history, treat all its secrets as compromised.
