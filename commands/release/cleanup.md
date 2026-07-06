---
description: Find and remove dead code, debug artifacts, and stale content — with confidence classification and confirmation before deleting
argument-hint: [optional directory to scope the sweep]
---

# Cleanup

Find dead content in the repository and remove it safely. Nothing is deleted without showing the full candidate list and getting explicit confirmation. Establish a green baseline first so you can prove the cleanup changed nothing behavioral.

This command is **stack-agnostic**: the concrete validation, lint, and analysis commands come from the project's `STACK.md`, resolved per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`, not from this file. Detection patterns span whatever languages the codebase actually uses.

## Steps

1. **Establish a baseline.** Run `/cc:verify:run` (resolves `STACK.md` and runs `smoke → test → typecheck → lint → format:check` per component from each `working_dir`). If it fails before cleanup, report and stop — never clean on a red baseline. If there is no `STACK.md`, auto-detect once from project markers and recommend the user run `/cc:setup:stack` to persist a manifest.

2. **Auto-fix safe lint issues first** (these need no approval — most linters apply only provably safe fixes, which typically includes unused-import removal). Resolve each component's `lint` (and formatter) step from `STACK.md` per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`, run it in its auto-fix / write mode from the component's `working_dir`, then review the diff. For example, depending on the resolved toolchain:
   ```bash
   # Run the component's resolved linter in fix mode + formatter in write mode, e.g.:
   #   Python (ruff):   uv run ruff check . --fix   &&  uv run ruff format .
   #   JS/TS (eslint):  npm run lint -- --fix       &&  npx prettier --write .
   #   Go:              go vet ./... ; gofmt -w .   ;   goimports -w .
   git diff --stat                  # review what changed
   ```
   Skip this for any component whose `STACK.md` maps no linter/formatter. Only apply the linter's *safe* autofix tier — never bulk-apply unsafe/aggressive rewrites here.

3. **Hunt dead content** (scope to the argument directory if given; cover the file types each component actually uses). Tailor every pattern below to the languages present — the examples list the common-language equivalents:
   - **Debug artifacts** — stray debug output left from development:
     ```bash
     # Debug print/log statements, per language:
     #   Python:  print(   |  pprint(
     #   JS/TS:   console.log(  |  console.debug(  |  console.dir(
     #   Go:      fmt.Println(  |  fmt.Printf(  |  log.Println(
     #   Rust:    println!(  |  dbg!(  |  eprintln!(
     #   Java:    System.out.println(
     grep -rn "<debug_pattern_for_lang>" <scope_dir> --include="<lang_glob>" | grep -v "test\|//\|#"
     # Leftover breakpoints / debuggers, per language:
     #   Python: breakpoint() | import pdb | import ipdb
     #   JS/TS:  debugger;
     #   Ruby:   binding.pry
     #   Go:     runtime.Breakpoint()
     grep -rn "<breakpoint_pattern_for_lang>" <scope_dir> --include="<lang_glob>"
     ```
   - **Dead code:** symbols (functions, methods, classes, exports) with zero callers. Prefer the language's own analyzer where one exists, then verify by reference search:
     ```bash
     # Resolve the component's `lint`/static-analysis step from STACK.md and use its
     # unused-code reporting where available, e.g.:
     #   Python:  ruff check --select F401,F811  |  vulture .
     #   JS/TS:   eslint (no-unused-vars)  |  ts-prune  |  knip
     #   Go:      go vet ./...  |  staticcheck ./... (U1000 unused)
     #   Rust:    cargo check (dead_code warnings)
     # Then confirm each suspect has zero callers by reference search:
     grep -rn "<symbol_name>" <scope_dir> --include="<lang_glob>"   # verify zero callers per suspect
     ```
     Beware dynamic dispatch, reflection, framework-registered handlers (routes, controllers, listeners), test fixtures, plugin/entry-point hooks, and public/exported API — when in doubt, keep.
   - **Stale TODO/FIXME/HACK:**
     ```bash
     grep -rn "TODO\|FIXME\|HACK\|XXX" <scope_dir>
     ```
     Propose deleting obsolete ones; file issues for real ones.
   - **Type / lint suppressions** (syntax varies by language): Python `# type: ignore` / `# pyright: ignore` / `# noqa`; TS/JS `// @ts-ignore` / `// @ts-expect-error` / `eslint-disable`; Go `//nolint`; Java `@SuppressWarnings`; etc.
     ```bash
     grep -rn "type: ignore\|pyright: ignore\|noqa\|@ts-ignore\|@ts-expect-error\|eslint-disable\|nolint\|SuppressWarnings" <scope_dir>
     ```
     Try removing each and re-running the component's `typecheck`/`lint` step (resolved from `STACK.md`); route a thorough audit to `/cc:verify:type-ignores`.
   - **Build / cache artifacts and leftovers:** generated or temporary files that should not be tracked, per stack — e.g. Python `__pycache__/` / `*.pyc` / `.mypy_cache/` / `.ruff_cache/`; JS/TS `node_modules` strays / `dist/` / `.next/` / `*.tsbuildinfo` if committed; Go `*.test` binaries; plus universal junk: empty source files (besides package markers like `__init__.py` / `index.ts` / `mod.rs`), `*.bak`, `*.old`, and editor temp files. Confirm against `.gitignore` before flagging tracked build output.
   - **Unused files, stale references, orphaned docs:** files referenced from nowhere (Grep each suspect filename/module across the tree), doc links pointing at deleted files, docs for removed features. Commented-out code blocks — git history preserves old code; it does not need to live in comments.

4. **Classify candidates by confidence:**
   - **SAFE** — provably unreferenced (debug prints, breakpoints, empty files, build/cache artifacts, zero-caller private symbols)
   - **LIKELY** — unreferenced but could be loaded dynamically or externally (public/exported API surface, framework-registered handlers, fixtures, entry points)
   - **KEEP** — looks dead but isn't — say why
   Never auto-delete LIKELY items.

5. **⛔ Present the list and confirm.** Show every deletion candidate with path, reason, and confidence. Wait for the user to approve, trim, or reject the list. Delete only what was approved (recoverable via git either way, but confirmation is still mandatory).

6. **Fix the fallout.** After deleting, sweep for now-broken references (imports, links, doc mentions) and fix them.

7. **Re-run the baseline.** Re-validate via the verify steps — invoke `/cc:verify:run`, or resolve `STACK.md` per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` and run `test → typecheck → lint` for each affected component from its `working_dir` (skip unmapped steps). All must be as green as in step 1. Show the before/after summary (`git diff --stat`).

## Output

A leaner working tree: approved dead content removed, references fixed, checks green. Summary lists what was deleted, what was kept and why, and any TODOs converted to issues.

## Quality checklist

- [ ] Baseline `/cc:verify:run` green before and after
- [ ] Every deleted item had zero verified inbound references
- [ ] Candidates classified SAFE / LIKELY / KEEP; LIKELY never auto-deleted
- [ ] Full candidate list shown and explicitly approved before any deletion
- [ ] No broken links/imports left behind (post-delete sweep done)
- [ ] No debug output or breakpoints (`print`/`console.log`/`fmt.Println`/`println!`, `breakpoint()`/`debugger;`/`pdb`) remaining in the cleaned scope

## Handoff

**Chain:** when part of a release flow, invoke `/cc:release:commit` next with the SlashCommand tool (`chore: remove dead code and debug artifacts`) — the commit gate still requires user approval.
**Solo:** suggest `/cc:release:commit`, and `/cc:release:docs` if the deletions affected documented structure.
**Abort rules:** baseline red before cleanup → stop and route to `/cc:verify:debug`. Checks break after deletion and the fix isn't obvious → restore the deleted files (`git checkout -- <paths>`) and report. User declines the candidate list → make no changes. No `STACK.md` and the stack can't be detected → say so and ask the user rather than guessing.
