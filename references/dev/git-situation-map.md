# Git Situation Map — Diagnosis & Recovery Recipes

Read by `/cc:git:guide`. Each recipe: how to confirm the diagnosis from real repo
state, the fix (with variants), why it works, and the escape hatch. Never prescribe
from the symptom alone — run the Diagnose commands first; users routinely misdescribe
their own git state.

## The 60-second mental model

Teach these five facts opportunistically — one per answer, matched to the situation:

1. **Commits are snapshots, not diffs.** Every commit is a complete picture of the
   tree plus a pointer to its parent(s). Nothing you committed is ever edited in
   place — "changing history" always means *making new commits and moving pointers*.
2. **Branches are just movable pointers** to a commit. Creating one is free;
   deleting one deletes nothing but the pointer.
3. **HEAD is "where you are".** Usually it points at a branch; detached HEAD just
   means it points at a commit directly. Nothing is broken.
4. **Three zones:** working tree (your files) → index/staging (`git add`) → history
   (`git commit`). Most "undo" questions are really "which zone do I want to reset?"
5. **The reflog is the safety net.** Every place HEAD has been for the last ~90 days
   is recoverable via `git reflog` — even after reset --hard, rebase, or branch
   deletion. **Committed work is almost never lost.** Only *uncommitted* changes can
   truly vanish.

## Safety tiers

Label every prescribed command with its tier:

- 🟢 **Safe** — creates new history or only reads; freely reversible.
- 🟡 **Rewrites history** — old commits stay reachable via reflog, but shared
  branches need `--force-with-lease` and teammate coordination. Never on a branch
  others build on.
- 🔴 **Destroys uncommitted work** — `reset --hard`, `checkout/restore` over dirty
  files, `clean -f`, `stash drop`. The only tier where data is genuinely
  unrecoverable. Always snapshot first (`git stash push -u -m backup` or
  `git branch backup/<date>`) and get explicit confirmation.

## Situation index

| # | Symptom phrases | Recipe |
|---|---|---|
| S1 | "undo my last commit", "committed too early" | Undo a commit |
| S2 | "committed on the wrong branch", "forgot to branch" | Move commits to another branch |
| S3 | "typo in commit message", "forgot a file" | Amend |
| S4 | "throw away my changes", "get back to clean" | Discard uncommitted work |
| S5 | "detached HEAD", "not on any branch" | Detached HEAD |
| S6 | "my work disappeared", "commits are gone" | Reflog recovery |
| S7 | "rebase/merge went wrong", "stuck mid-rebase" | Abort or finish an in-flight operation |
| S8 | "conflict markers", "both modified" | Conflicts |
| S9 | "push rejected", "diverged from remote" | Local vs remote divergence |
| S10 | "committed a secret / password / huge file" | Remove something from history |
| S11 | "where did my stash go", "stash pop conflicted" | Stash trouble |
| S12 | "one big blob of changes, want separate commits" | Split work into commits |
| S13 | "deleted a branch by accident" | Recover a deleted branch |
| S14 | "wrong author/email on my commits" | Fix author identity |
| S15 | "pulled and now everything is broken" | Upstream breakage |

---

## S1 — Undo a commit

**Diagnose:** `git log --oneline -3` · pushed yet? `git status -sb` (ahead/behind) or
`git branch -r --contains HEAD`.

**Fix by intent:**
- Keep the changes, redo the commit later: 🟢 `git reset --soft HEAD~1` (changes stay
  staged) or `git reset HEAD~1` (unstaged).
- Discard commit *and* its changes: 🔴 `git reset --hard HEAD~1` — snapshot first.
- **Already pushed to a shared branch:** 🟢 `git revert <sha>` — a new commit that
  undoes it. Never reset a shared branch.

**Why:** reset moves the branch pointer; --soft/--mixed/--hard choose how many of the
three zones follow it. revert adds forward history instead of rewriting.
**Escape hatch:** `git reflog` → `git reset --hard HEAD@{1}` returns to before the undo.

## S2 — Commits on the wrong branch

**Diagnose:** `git log --oneline main..HEAD` (or vs the intended base) to count the
stray commits; confirm whether the wrong branch was pushed.

**Fix (not pushed):** 🟢 from the wrong branch:
```bash
git branch correct-branch          # new pointer at current commit (or use existing)
git reset --hard <last-good-sha>   # 🟡 move wrong branch back (work is safe on correct-branch)
git switch correct-branch
```
If the target branch already exists: `git switch correct-branch && git cherry-pick <sha>...`
then reset the wrong branch back.
**Fix (pushed):** cherry-pick onto the right branch 🟢, then `git revert` the strays on
the shared branch 🟢.
**Why:** branches are pointers — "moving" commits is really re-pointing labels.

## S3 — Amend (message typo, forgot a file)

**Diagnose:** only valid for the **latest** commit and only if unpushed
(`git status -sb` ahead count ≥ 1). Older commit → S12's interactive rebase, or just
a follow-up commit.

**Fix:** message only: 🟡 `git commit --amend -m "better message"` · forgot a file:
`git add <file> && git commit --amend --no-edit`.
**Pushed already?** Prefer a follow-up commit; amend + `--force-with-lease` only on
your own unshared branch.
**Why:** amend replaces the tip commit with a new one — that's why it counts as a rewrite.

## S4 — Discard uncommitted work 🔴

**Diagnose:** `git status` — separate *modified tracked* files from *untracked* ones;
they need different commands and both are unrecoverable once discarded.

**Fix (after snapshot + explicit confirmation):**
- One file: `git restore <file>` · everything tracked: `git restore .`
- Unstage without losing edits: 🟢 `git restore --staged <file>`
- Untracked files/dirs: `git clean -nd` (dry-run **first**, always show the user),
  then `git clean -fd`.
- "Maybe I'll want it later": prefer 🟢 `git stash push -u -m "wip <context>"` over
  deletion — costless insurance.

## S5 — Detached HEAD

**Diagnose:** `git status` says "HEAD detached at <sha>". Ask: did they make commits
while detached? `git log --oneline -5`.

**Fix:** no commits made: 🟢 `git switch <branch>` — done. Commits made and wanted:
🟢 `git switch -c rescue-branch` (names the anchor where they stand), then merge/cherry-pick
onto the real branch. Commits made and unwanted: just `git switch <branch>` — they
become unreferenced (reflog keeps them ~90 days).
**Teach:** detached HEAD is not an error state — it's git letting you stand on any
commit. The only risk is walking away from unlabelled commits.

## S6 — "My work disappeared" (reflog recovery)

**Diagnose:** `git reflog -20` — read it *with* the user; each line is a place HEAD
has been. Find the entry just before things went wrong. Also check `git stash list`
and S13 if a branch vanished.

**Fix:** inspect first: 🟢 `git show HEAD@{n}` / `git log --oneline HEAD@{n}` ·
recover: `git branch rescue HEAD@{n}` (safest — new label, moves nothing) or
🔴 `git reset --hard HEAD@{n}` (only on a clean tree).
**Why:** commits are only *unreachable*, not deleted, until gc expires them (~90 days).
**Truly uncommitted work** is the one thing reflog can't bring back — check editor
local history / IDE undo as the last resort.

## S7 — Stuck mid-rebase / mid-merge / mid-cherry-pick

**Diagnose:** `git status` names the in-flight operation, or check for
`.git/rebase-merge`, `.git/MERGE_HEAD`, `.git/CHERRY_PICK_HEAD`.

**Fix — always offer both directions:**
- Bail out cleanly: 🟢 `git rebase --abort` / `git merge --abort` /
  `git cherry-pick --abort` — returns exactly to the pre-operation state.
- Push through: resolve conflicts (S8), `git add <files>`, then `--continue`.
**Escape hatch after a *finished* bad rebase/merge:** `git reset --hard ORIG_HEAD` 🟡
(ORIG_HEAD = where you were before the operation).

## S8 — Conflicts

**Diagnose:** `git diff --name-only --diff-filter=U` lists conflicted files.

**Fix:** per file, read both sides and combine *intents* — never mechanically pick
ours/theirs. Marker anatomy: `<<<<<<<` your side, `=======` divider, `>>>>>>>` their
side. Then `git add <file>` and continue the operation. Verify no stragglers:
`git grep -l "<<<<<<<"`. Deleted-by-them/us: decide deliberately — `git rm` accepts
the deletion, `git add` keeps the file.
**Hand off:** conflicts during a main-sync → `/cc:github:sync` owns the full flow.

## S9 — Push rejected / diverged from remote

**Diagnose:** `git fetch` then `git status -sb` — ahead N / behind M tells the story.
Behind only → plain fast-forward pull. Ahead+behind → true divergence. Ask: did
*you* rewrite history (rebase/amend), or did someone else push?

**Fix:**
- Someone else pushed: 🟢 `git pull --rebase` (linear) or `git pull` (merge commit) —
  match the team's convention.
- You rebased/amended a branch you own alone: 🟡 `git push --force-with-lease` —
  **never bare `--force`**; with-lease aborts if the remote moved since your last fetch.
- Remote rewritten under you (force-pushed by someone else): `git fetch` then
  `git reset --hard origin/<branch>` 🔴 after stashing local work.

## S10 — Secret or huge file in history

**Secret — order matters: 1) ROTATE THE CREDENTIAL FIRST.** History cleanup never
un-leaks a pushed secret; assume it's compromised the moment it left the machine.
2) Only in the latest unpushed commit → `git rm --cached <file> && git commit --amend` 🟡.
3) Deeper history → `git filter-repo` (or BFG) 🟡🟡 — full-history rewrite; coordinate
with every collaborator before force-pushing, and route to `/cc:verify:security` for
the exposure assessment. Add the path to `.gitignore` so it can't recur.

**Huge file:** same mechanics minus the rotation urgency; going forward use Git LFS
or keep artifacts out of the repo.

## S11 — Stash trouble

**Diagnose:** `git stash list` · inspect one: `git stash show -p stash@{n}`.

**Fix:** apply without deleting: 🟢 `git stash apply stash@{n}` (prefer over `pop` —
pop deletes on success). Pop conflicted: the stash is **kept**; resolve like S8, then
`git stash drop` manually. Dropped/popped-and-lost stash:
`git fsck --unreferenced | grep commit` then `git show <sha>` to find it —
stashes are commits too.

## S12 — Split a blob of changes into clean commits

**Uncommitted:** 🟢 `git add -p` — stage hunk-by-hunk (`y`/`n`/`s`plit), commit, repeat.
**Already committed (unpushed):** 🟢 `git reset HEAD~1` puts everything back as
working-tree changes, then `add -p` as above. Several commits to reshape:
🟡 `git rebase -i <base>` — but this environment can't drive interactive editors;
prefer the reset + re-commit path, or `GIT_SEQUENCE_EDITOR` scripting only if the
user asks.
**Teach:** small single-intent commits are what make S1/S2-style surgery easy later.

## S13 — Recover a deleted branch

**Fix:** find its last tip: `git reflog | grep <branch-name>` (or
`git reflog -30` and eyeball) → 🟢 `git branch <branch-name> <sha>`. Deleted on the
remote too: any local clone that still has it can re-push.
**Why:** deleting a branch deletes a pointer, not commits.

## S14 — Wrong author/email

**Diagnose:** `git log -3 --format='%an <%ae>'` · `git config user.email`.

**Fix:** config first so it stops recurring: `git config user.email <work-email>`
(add `--global` deliberately, per-repo is safer for mixed identities). Last commit:
🟡 `git commit --amend --reset-author --no-edit`. A run of unpushed commits:
🟡 `git rebase -r <base> --exec 'git commit --amend --reset-author --no-edit'`.
Pushed/shared history: usually not worth the rewrite — fix config and move on
(mention `.mailmap` for display-level cleanup).

## S15 — "I pulled and now it's broken"

**Diagnose:** is it *conflict* breakage (S8) or *semantic* breakage (builds/tests fail
with no conflicts)? `git log --oneline ORIG_HEAD..HEAD` shows exactly what the pull
brought in.

**Fix:** immediate unblock: 🟢 `git switch -c before-pull ORIG_HEAD` to keep working
pre-pull while investigating. Find the culprit:
`git bisect start; git bisect bad HEAD; git bisect good ORIG_HEAD` with the failing
command as the test. Never "fix" by force-pushing the old state over teammates' work —
the upstream commit's author fixes forward.
