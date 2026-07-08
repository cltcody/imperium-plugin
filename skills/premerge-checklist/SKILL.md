---
name: premerge-checklist
description: |
  Pre-merge checklist for known burns a regex gate can't catch: client-side API key exposure,
  platform/deploy config drift, mobile (EAS) credentials, OAuth token storage, git & branch
  hygiene, validation honesty. Use on "pre-merge check", "known burns", "before I merge", "am I
  safe to merge".
---

# Pre-Merge Known-Burns Checklist

Run this in the last five minutes before a merge. Every item exists because it bit someone:
each carries the burn (why it is here), a concrete check, and a pass criterion. The commands
only surface candidates — judging each hit is the actual check, which is why this is a skill
and not a hook.

**What this is NOT:**

- **Not a code review** — correctness, design, and tests are `/cc:verify:code` and `/cc:verify:pr`.
- **Not the secrets hook** — `${CLAUDE_PLUGIN_ROOT}/hooks/block-secrets.py` already blocks reading env/credential files into the session, env-var dumps, and secret-shaped variable expansions in tool calls. Do not re-check what it enforces; this skill checks what a regex cannot judge — whether a value is safe *where it sits*.
- **Not the full security scan** — OWASP dimensions, injection, auth, and source-level secret-literal greps are `/cc:verify:security` (full audit: the **security-audit** skill).

## How to run

- From the repo root on the merge-candidate branch; base below is `origin/main` (substitute the real base) — fetch once first so the range is current.
- Judge names, paths, and shapes — never print secret values. To review env var names, open `.env.example` with the Read tool (hook-exempt); the real env file stays out of the session.
- Fences spell `.e[n]v` with a character class where needed so the commands stay clear of the secrets hook's read patterns while still matching real code.
- A category whose technology is absent (no mobile app, no OAuth) is n/a — record it as PASS with a note, never skip the summary line.

## 1. Client-side key exposure

**1.1 Public-prefixed env vars carrying secrets** — `NEXT_PUBLIC_*` / `EXPO_PUBLIC_*` / `VITE_*` values are inlined into shipped JS: a secret behind a public prefix is published, not configured.

```bash
grep -rhoE '(NEXT_PUBLIC|EXPO_PUBLIC|VITE)_[A-Z0-9_]+' src/ app/ 2>/dev/null | sort -u
```

Pass: every name is public-by-design (URLs, flags, publishable/anon keys). A name ending in KEY/SECRET/TOKEN must be verifiably safe to publish — an anon key behind row-level security is; a server API key never is.

**1.2 Keys reachable in built artifacts** — source greps miss what bundlers inline; the leak is only visible in the build output, so grep the artifact after a fresh production build.

```bash
grep -rnoE '(sk-[A-Za-z0-9_-]{16,}|AKIA[A-Z0-9]{16}|ghp_[A-Za-z0-9]{36}|xox[bap]-[A-Za-z0-9-]{10,}|AIza[A-Za-z0-9_-]{35})' dist/ build/ .next/ .output/ 2>/dev/null | head -20
```

Pass: zero hits, or every hit confirmed publishable (e.g. a browser key restricted by referrer). No build output present → build first, then judge.

**1.3 Server-only keys imported into client components** — a server key referenced in a `use client` file ships to the browser even without a public prefix; the bundler inlines whatever the client graph touches.

```bash
# .e[n]v is spelled with a character class to stay clear of the secrets hook
grep -rlE "['\"]use client['\"]" app/ src/ 2>/dev/null | xargs -I{} grep -HnE 'process\.e[n]v\.[A-Z_]+' {} 2>/dev/null | grep -v '_PUBLIC_'
```

Pass: zero non-public env references in client-marked files. Same judgment for Vite/RN equivalents: any secret-named var referenced from code that ships to the client.

## 2. Platform & deploy config

**2.1 Code ↔ platform config drift** — code referencing a var that exists only on your machine deploys fine and 500s at runtime; Cloudflare Pages/Workers vars are per-environment, so preview and production drift separately.

```bash
grep -rhoE '(process|import\.meta)\.e[n]v\.[A-Z][A-Z0-9_]*' src/ app/ functions/ 2>/dev/null | sed -E 's/.*\.e.v\.//' | sort -u
grep -hoE '^[A-Z][A-Z0-9_]* *=' wrangler.toml netlify.toml 2>/dev/null | tr -d ' =' | sort -u
```

Pass: every code-referenced name has a home in platform config or dashboard secrets — for every environment (preview AND production) — and every declared name is still consumed. Workers `env.X` bindings and dashboard-only vars need eyes, not grep.

**2.2 Secrets committed into platform config files** — `wrangler.toml` `[vars]` (also `netlify.toml`, `fly.toml`) are plaintext in git; a real secret there is in history forever. Dashboard-managed secrets are the correct home.

```bash
grep -nE '(KEY|SECRET|TOKEN|PASSWORD)[A-Z_]* *= *"[^"]{8,}"' wrangler.toml netlify.toml fly.toml vercel.json 2>/dev/null
```

Pass: committed platform config holds only non-secret values (URLs, flags, public IDs). Anything secret-shaped: move to managed secrets AND rotate — deleting the line does not delete the history.

**2.3 Hardcoded environment-specific URLs** — a localhost/staging/tunnel URL hardcoded during a demo ships to production pointing at the wrong (or dead) backend.

```bash
grep -rnE '(localhost:[0-9]+|127\.0\.0\.1|ngrok|staging\.|\.workers\.dev)' src/ app/ 2>/dev/null | grep -viE '(\.test|\.spec|__tests__|\.md)'
```

Pass: every hit is test/dev-only or read from configuration.

## 3. Mobile credentials

**3.1 Credential files tracked in git** — `eas credentials` writes `credentials.json` and keystores beside the app; one `git add .` later the Android signing key is in history. A leaked keystore means hijackable app updates, and unlike an API key it cannot be rotated.

```bash
git ls-files -- 'credentials.json' '*/credentials.json' '*.keystore' '*.jks' '*.p12' '*.p8' '*.mobileprovision' 'google-services.json' '*/google-services.json' 'GoogleService-Info.plist' '*/GoogleService-Info.plist'
```

Pass: zero tracked. `google-services.json` is tolerated by some teams — treat tracked as CHECK until its console keys are confirmed restricted and the team has accepted it.

**3.2 App config exposing internal endpoints** — everything in `app.json` / `app.config.*` `extra` (and `eas.json` env blocks) rides inside the shipped bundle; anyone who unzips the APK/IPA reads it.

```bash
grep -rniE '(apikey|secret|token|internal|admin)' app.json app.config.js app.config.ts eas.json 2>/dev/null
```

Pass: nothing in app config you would not print on the login screen — secrets and internal endpoints belong behind a backend or in EAS secrets, not in `extra`.

## 4. OAuth & token storage

**4.1 Tokens in localStorage / AsyncStorage** — both are plaintext: readable by any XSS on web, by anything on a rooted device in RN. Refresh tokens are long-lived credentials; secure storage exists precisely for them.

```bash
grep -rnE '(localStorage|sessionStorage|AsyncStorage)\.setItem\([^)]*[Tt]oken' src/ app/ 2>/dev/null
```

Pass: access tokens at worst in memory; refresh tokens ONLY in secure storage (expo-secure-store / Keychain / Keystore) or httpOnly cookies.

**4.2 Tokens logged** — a token logged once outlives its rotation: it lands in device logs, CI output, and error trackers. Log scraping is the classic OAuth leak path.

```bash
grep -rniE '(console\.(log|debug|info|error)|logger\.[a-z]+|print)\(.*(access_token|refresh_token|id_token|authorization|bearer)' src/ app/ 2>/dev/null | grep -viE '(\.test|\.spec|__tests__)'
```

Pass: zero token-adjacent logging outside tests; request/response loggers redact `Authorization` and `Set-Cookie`.

**4.3 Redirect URIs with wildcards** — a wildcard redirect URI turns the auth-code flow into an open redirect: any attacker page can receive your users' authorization codes.

```bash
grep -rniE 'redirect_?uris?.*\*' . --include='*.json' --include='*.ts' --include='*.py' --include='*.toml' --include='*.yaml' 2>/dev/null | grep -v node_modules
```

Pass: exact URIs (scheme + host + path) per environment, zero wildcards — and confirm the provider dashboard matches, which no grep can see.

**4.4 Client secrets in SPA / native code** — public clients cannot keep a secret: anything shipped is extractable, and PKCE exists so they need none. A secret in client code means re-registering the OAuth app, not just deleting the line.

```bash
grep -rniE 'client_?secret' src/ app/ ios/ android/ 2>/dev/null | grep -viE '(\.test|\.spec|__tests__|\.md)'
```

Pass: zero hits in client-delivered code; authorization-code flows from public clients use PKCE (a code_challenge is present).

## 5. Git & branch hygiene

**5.1 Merge-conflict leftovers** — conflict markers are syntactically legal in YAML strings, markdown, and SQL; a divider row left by a resolved-in-haste conflict ships silently.

```bash
git diff --check origin/main...HEAD && ! git grep -nE '^(<{7}|={7}|>{7})' -- ':!*.md'
```

Pass: both commands exit clean; any hit is visually confirmed as a legitimate divider.

**5.2 Large or binary files in the branch diff** — one stray binary or vendored directory bloats every future clone; rewriting history after push is team-wide pain.

```bash
git diff --numstat origin/main...HEAD | awk '$1 == "-" || $1+0 > 400' | head -15
```

Pass: every binary (`-`) or large-added file is intentional and belongs in git rather than object storage, LFS, or `.gitignore`.

**5.3 Env-family files newly tracked on this branch** — the secrets hook blocks *reading* env files; nothing blocks *tracking* one. A new `apps/x/.env.production` slips past a stale `.gitignore` via `git add .`, and a pushed env file means rotating everything in it (see `${CLAUDE_PLUGIN_ROOT}/references/dev/lessons-learned.md` §5, 2026-07-01).

```bash
# .e[n]v pathspecs keep this command clear of the secrets hook
git diff --name-only --diff-filter=A origin/main...HEAD -- '.e[n]v*' '*/.e[n]v*' '*.pem' '*.key'
```

Pass: zero paths (`*.example` / `*.sample` are fine). Any hit: untrack it, extend `.gitignore`, rotate every value the file held.

**5.4 Stale branch — the diff contains only this feature** — a branch behind main shows another merged feature's files as *deletions* in its diff; merge that and you silently clobber the newer feature (2026-06-20).

```bash
git log --oneline origin/main..HEAD | head -30
git diff --name-status origin/main...HEAD | awk '$1 == "D"'
```

Pass: every commit is this feature's; every deletion is deliberate. Deletions you never made = staleness → merge `origin/main` into the branch, resolve (purely-additive conflicts: keep both sides), re-run the verify gate, confirm those files leave the diff.

**5.5 Manifest and lockfile move together** — a manifest committed without its lockfile (or vice versa) fails clean CI installs within seconds, with a cryptic error (2026-05-13).

```bash
git diff --name-only origin/main...HEAD | grep -E '(package(-lock)?\.json|pnpm-lock\.yaml|yarn\.lock|pyproject\.toml|uv\.lock|poetry\.lock|Cargo\.(toml|lock)|go\.(mod|sum))'
```

Pass: manifests and their lockfiles appear as a pair (or neither).

## 6. Validation honesty

**6.1 The verify gate ran on the FINAL commit** — a gate that passed two commits ago validated a different tree; "it was green when I checked" is the classic false MERGE READY, and a post-validation fix-up commit is a new, unvalidated tree.

```bash
git rev-parse --short HEAD && git status --porcelain
```

Pass: working tree clean, and the SHA your last verify run recorded (`/cc:verify:run`, CI, or the execution report) equals HEAD. Anything newer → re-run the gate before merging.

**6.2 Skipped and focused tests are declared, not silent** — a committed `.only` makes CI run one test and report green; silent skips hide known failures from reviewers. Known-failing tests belong in a declared baseline or the PR body (2026-07-03).

```bash
git grep -nE '\.(only|skip|todo)\(|xit\(|xdescribe\(|@pytest\.mark\.skip|@unittest\.skip' -- ':!*.md'
```

Pass: zero `.only`; every skip/todo either predates this branch or is named in the PR body with a reason.

**6.3 Dev shortcuts swept** — shortened timers, stub data, and forced flags added for QA ship unless marked at creation and swept before merge (2026-04-03).

```bash
git grep -niE 'TODO:? *REMOVE|dev shortcut|DO NOT (SHIP|MERGE)' -- ':!*.md'
```

Pass: zero hits in this branch's files. Note (2026-06-25): if the branch bumps a dependency with a native/compiled layer, green interpreted-layer CI proves nothing — an actual build of that layer is part of validation honesty too.

## Summary

Close the pass by filling in one line per category, then apply the rule:

```
PRE-MERGE KNOWN-BURNS
1. Client-side key exposure   PASS | CHECK — <one-line finding, or n/a: reason>
2. Platform & deploy config   PASS | CHECK — <one-line finding, or n/a: reason>
3. Mobile credentials         PASS | CHECK — <one-line finding, or n/a: reason>
4. OAuth & token storage      PASS | CHECK — <one-line finding, or n/a: reason>
5. Git & branch hygiene       PASS | CHECK — <one-line finding>
6. Validation honesty         PASS | CHECK — <one-line finding>
```

**Any CHECK ⇒ resolve it, or have the user explicitly accept it (named in the PR body) before merge.** After the merge: watch CI on main — red main means a hotfix branch immediately, before anything else merges (2026-04-03).
