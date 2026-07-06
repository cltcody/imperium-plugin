---
description: Sync the current branch with main — fetch, choose rebase or merge, resolve conflicts, re-validate
---

# GitHub: Sync with Main

Bring the current feature branch up to date with main before it drifts into a merge nightmare. Fetch, decide rebase vs merge deliberately, resolve conflicts with care, and prove nothing broke afterwards. Sync early and often — small daily syncs beat one giant one.

## Steps

1. **Fetch and assess.**
   ```bash
   git fetch origin main
   git rev-list --left-right --count origin/main...HEAD   # behind/ahead
   git log --oneline HEAD..origin/main                    # what changed upstream
   git diff origin/main...HEAD --name-only                # overlap risk vs files main touched
   ```
   If the branch is not behind, report "already in sync" and stop.

2. **Choose the strategy — state the choice and why before running it.**
   - **Rebase** (default for short-lived, unshared feature branches): linear history, replays your commits on top — `git rebase origin/main`.
   - **Merge** (`git merge origin/main`) when the branch is shared with others, already has review history you must preserve, or contains merge commits — rebasing rewrites hashes and forces everyone else to recover.

   | Aspect | Merge | Rebase |
   |--------|-------|--------|
   | History | Shows when branches split/merged | Linear |
   | Conflicts | Handled once | Handled per commit |
   | Safety | Preserves all commits | Rewrites hashes — force-push needed |

   Uncommitted changes → `git stash` first (or route to `/cc:release:commit`), `git stash pop` after.

3. **Resolve conflicts** (if any). For each conflicted file: read both sides, understand the *intent* of each change, and combine — don't mechanically pick "ours"/"theirs".

   ```
   # Example conflict in a source file:
   # <<<<<<< HEAD (your changes)
   #   your_function()
   # =======
   #   their_function()        # main's changes
   # >>>>>>> origin/main
   # → keep what makes sense for BOTH intents, remove all markers
   ```

   Then `git add <file>` and `git rebase --continue` (or complete the merge commit). Repeat per commit during a rebase. If one side deleted a file the other modified: decide deliberately — `git rm <file>` to accept the deletion or `git add <file>` to keep it. Check `git grep -l "<<<<<<<"` for stragglers before continuing.

4. **Escape hatch.** If a rebase becomes a mess: `git rebase --abort` returns to the pre-sync state; fall back to `git merge origin/main` (one conflict resolution instead of per-commit).

5. **Re-validate.** Main's changes can break your branch even without textual conflicts. Invoke `/cc:verify:run` (which resolves the project's `STACK.md` per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` and runs the gate per component). If there is no `STACK.md`, it auto-detects from project markers for this run — recommend `/cc:setup:stack` to persist a manifest. All mapped steps must come back green. Failures introduced by the sync → fix now, not at PR time. To find which upstream commit broke it: `git bisect start; git bisect bad HEAD; git bisect good origin/main~1`.

6. **Push.** After a merge: `git push`. After a rebase, history changed:
   ```bash
   git push --force-with-lease origin <branch>
   ```
   **Force-with-lease only, never bare `--force`** — and never force-push a branch others are committing to.

## Output

The feature branch up to date with `origin/main`, conflicts resolved, validation green, remote updated. Summary of strategy used, conflicts resolved, and upstream changes worth knowing about.

## Quality checklist

- [ ] Strategy (rebase vs merge) chosen deliberately and stated
- [ ] No conflict markers remain (`git grep "<<<<<<<"` clean)
- [ ] Conflict resolutions preserve the intent of both sides
- [ ] `/cc:verify:run` green after the sync
- [ ] Force-push only with `--force-with-lease`, only on unshared branches

## Handoff

**Chain:** when invoked as part of a PR flow, return to `/cc:github:pr` once green.
**Solo:** suggest `/cc:github:pr` if the branch is ready for review, or continuing implementation. Sync daily on active branches.
**Abort rules:** conflict resolution is ambiguous (both sides changed the same logic for different reasons) → stop and ask the user rather than guessing. Validation fails after sync and the cause is upstream → route to `/cc:verify:debug` and flag the upstream commit. Rebase repeatedly painful → abort and merge instead.
