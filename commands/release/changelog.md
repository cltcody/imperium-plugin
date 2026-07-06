---
description: Generate or refresh CHANGELOG.md from commits since the last tag, in Keep a Changelog format
argument-hint: [version e.g. 2.1.0, or "unreleased"]
model: haiku
effort: low
---

# Generate Changelog

Generate or update `CHANGELOG.md` from the git history since the last release. Run before tagging a version or whenever the changelog has drifted behind the commits.

## Steps

1. **Find the baseline.** Run `git describe --tags --abbrev=0` to get the last tag. If it succeeds, list commits with `git log <tag>..HEAD --oneline --no-merges`. If there are no tags, use `git log main...HEAD --oneline --no-merges` (or the full history for an initial release).

2. **Categorize each commit** into Keep a Changelog sections, using conventional-commit prefixes first and message content as fallback:

   | Section | Signals |
   |---------|---------|
   | Added | `feat:`, "add", "new", "implement" |
   | Changed | `refactor:`, behavior/API contract changes |
   | Performance | `perf:`, "optimize", "improve" |
   | Deprecated | "deprecate" |
   | Removed | "remove", "delete", "drop" |
   | Fixed | `fix:`, "bug", "resolve", "correct" |
   | Security | `security:`, CVE references, dependency patches |

   Flag anything containing `BREAKING` or `!:` prominently at the top of the version section — for API changes, note the contract: `METHOD /path/` changed: before → after. Fold `chore:`/`docs:` noise into one line or drop it.

3. **Verify against the diff.** Run `git diff --stat <tag>..HEAD` and spot-check that entries reflect real user-visible changes — read changed route files to identify API changes. Rewrite commit messages into user-facing language: describe the effect, not the implementation. For Security entries, do not disclose exploit details before the patch is deployed.

4. **Determine the version.** Use the argument if given; otherwise propose one by semver relative to the previous tag:
   - Breaking change → **MAJOR**
   - New feature, backward compatible → **MINOR**
   - Fixes only → **PATCH**
   Use `[Unreleased]` when no release is being cut.

5. **Update CHANGELOG.md.** If it exists at the project root, prepend the new section under the header (read it first to match existing style — never rewrite history sections). If not, create it with the standard header:

   ```markdown
   # Changelog

   All notable changes to this project will be documented here.
   Format: [Keep a Changelog](https://keepachangelog.com)

   ## [<version>] - YYYY-MM-DD

   ### Breaking Changes
   - <description> — `METHOD /path/` changed: before → after

   ### Added
   - <user-facing description> (#issue)

   ### Fixed
   - <what was broken and what was fixed>
   ```

6. **Optionally tag.** Only if the user asked for a release: suggest `git tag -a v<version> -m "Release v<version>"`. Never push tags unless explicitly asked.

## Output

An updated `CHANGELOG.md` at the project root with a new dated version section in Keep a Changelog format, plus a summary of how many commits were folded into each category.

## Quality checklist

- [ ] Every commit since the last tag is represented or deliberately dropped as noise
- [ ] Entries describe user-visible effects, not implementation detail
- [ ] Breaking changes called out explicitly, with API before/after where relevant
- [ ] Version number follows semver relative to the previous tag
- [ ] Existing CHANGELOG.md content and style preserved (prepend, never rewrite)
- [ ] No invented entries — every line traces to a real commit

## Handoff

**Chain:** when part of a release flow, invoke `/cc:release:docs` next with the SlashCommand tool to bring the rest of the documentation in line.
**Solo:** suggest `/cc:release:commit` to commit the changelog update (`docs: update changelog for v<version>`).
**Abort rules:** no commits since the last tag → report "nothing to release" and stop. Git history unreadable or tags inconsistent → report the discrepancy and ask the user which baseline to use instead of guessing.
