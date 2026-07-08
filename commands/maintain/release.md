---
description: Publish the next plugin version — bump manifests, write the CHANGELOG entry, tag, and snapshot-publish the mirror, with one approval gate before anything irreversible
argument-hint: [major|minor|patch] [mirror-remote-url]
disable-model-invocation: true
---

# Maintain: Release — Publish the Next Plugin Version

Run the full four-step release flow for this plugin in one deliberate pass:
**bump version → CHANGELOG entry → tag → mirror publish.** Marketplace installs only update
when `plugin.json`'s `version` changes, so a mirror publish without a bump is silently
ignored by every installed copy — this command exists so that can't happen by accident.

**Scope note:** this releases *the plugin itself* (run it from the plugin repo). For releasing
a user project, use `/cc:release:*`.

## Inputs

- `$1` (optional): bump size — `major`, `minor`, or `patch`. If omitted, propose one in Step 2.
- `$2` (optional): mirror remote URL (e.g. `https://github.com/<owner>/<mirror-repo>.git`).
  If omitted, ask the user once — never guess a publish target, and never hardcode one here.

## Steps

### 1 — Preflight (abort on any failure)

```bash
git rev-parse --abbrev-ref HEAD        # must be main
git status --porcelain                 # must be empty
git fetch --tags origin && git status -sb   # must not be behind origin/main
LAST_TAG=$(git describe --tags --abbrev=0)  # must exist; if no tags, stop and set them up first
git log --oneline "$LAST_TAG"..HEAD    # must be non-empty — otherwise there is nothing to release
bash scripts/cc-audit.sh               # the CI gate, run locally — 0 errors required
```

### 2 — Decide the bump

Classify the commits since `$LAST_TAG` by conventional-commit prefix: any breaking change →
`major`; any `feat` → `minor`; only `fix`/`docs`/`chore` → `patch`. Propose the resulting
version; the user's `$1` overrides. Compute `NEW_VERSION`.

### 3 — Bump both manifests

Update `"version"` in `.claude-plugin/plugin.json` **and** `.claude-plugin/marketplace.json`
(they must always match — verify with grep afterward).

### 4 — CHANGELOG entry

Add a `## [NEW_VERSION] — <date>` section at the top of `CHANGELOG.md` (repo root),
Keep a Changelog headings (`Added` / `Changed` / `Fixed` / `Removed`), one bullet per
user-facing change since `$LAST_TAG`, PR numbers cited. Follow the file's existing voice.
No `CHANGELOG.md`? Create it per `/cc:release:changelog`'s format.

### 5 — Release PR ⇢ **the approval gate**

Branch `chore/release-v<NEW_VERSION>`, commit the bump + changelog
(`chore(release): v<NEW_VERSION> — <one-line summary>`), push, open the PR, and wait for
checks to go green.

**Show the user the version, the changelog entry, and the publish target, and get explicit
approval now.** Everything before this point is reversible; everything after is not
(public tag, public mirror). Do not proceed on silence.

### 6 — Merge, tag, publish

```bash
gh pr merge --squash --delete-branch
git checkout main && git pull
git tag -a "v$NEW_VERSION" -m "cc $NEW_VERSION — <one-line summary>" && git push origin "v$NEW_VERSION"
bash scripts/cc-mirror.sh "$MIRROR_REMOTE"
```

### 7 — Verify and report

Confirm the mirror really serves the new version before declaring success:

```bash
gh api repos/<owner>/<mirror-repo>/contents/.claude-plugin/plugin.json --jq '.content' | base64 -d | grep '"version"'
```

Report: released version, tag, mirror commit, and the consumer paths — marketplace installs
pick it up on next startup (or `/plugin update`); repo-based machines get the
`repo-autoupdate` reinstall notice next session.

## Failure handling

- Audit or CI red → stop; fix on a normal branch first, then rerun from Step 1.
- Mirror push rejected or version mismatch in Step 7 → the tag already exists; do NOT re-bump.
  Fix the publish issue and rerun `cc-mirror.sh` only.
- Wrong version tagged → `git tag -d` + `git push origin :refs/tags/v<X>` is acceptable ONLY
  if the mirror was never published at that version; otherwise roll forward with a new patch.
