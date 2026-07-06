---
description: Health check for the cc plugin — placeholders, broken refs, frontmatter, inventory drift
---

# Maintain: Audit Command Center

Run an ongoing maintenance audit across all skills, commands, and agents. This is the command to run after adding/editing any asset, or periodically to catch drift. To automate the periodic run instead of remembering it — including the scriptable half via `bash global/scripts/cc-audit.sh` — see `${CLAUDE_PLUGIN_ROOT}/references/dev/scheduling.md`.

## Steps

### 1 — Unresolved placeholders

Grep the tree for any remaining placeholders the user should have filled:

```bash
grep -rn "\[COMPANY\]\|\[COMPANY_PRODUCT\]\|\[PRODUCT_[A-E]\]\|\[SOLUTION_SUITE_[0-9]\]\|\[QUALIFICATION_FRAMEWORK\]\|\[ACCENT_COLOR_HEX\]\|\[PRIMARY_COLOR_HEX\]\|\[BACKGROUND_COLOR_HEX\]\|\[BRAND_FONT\]\|\[WORKSPACE_DIR\]\|\[[^]]*fill in\]" \
  skills/ commands/ agents/ .claude/ 2>/dev/null | grep -v ".git"
```

This catches both config tokens and unfilled scaffold stubs like `[Agent description — fill in]`. Report each as `file:line` grouped by placeholder. If zero, say so. Cross-reference against `cc.config.json` — if a config placeholder appears in files but is filled in config, the user should run `bash scripts/cc-apply.sh --apply`. (Stub placeholders like `…fill in]` aren't config-driven — they need a real value written into the file.)

**Where tokens are allowed to live:** loaded content (`skills/*/SKILL.md`, `commands/*.md`)
references config as `${user_config.<key>}` — the plugin `userConfig` mechanism, substituted
automatically on marketplace installs. A `[BRACKET_TOKEN]` from the config map appearing in
one of those files is a **regression** (it will never substitute for marketplace users) —
convert it to the matching `${user_config.<key>}` (key = last segment of the config path in
`cc.config.json`'s `placeholders` map). Support files read at runtime (`references/`,
`skills/*/references/`, css/json assets) keep `[BRACKET_TOKEN]`s — that's expected; cc-apply
bakes them for clone installs and Claude resolves them in-context otherwise.

### 2 — Residual brand leakage

Catch any company name or company-specific design IP that slipped in without being mapped to
a placeholder. Read the original source company names from git history or ask the user once.
Default check (also covers design-system IP terms `graphik`, `wtg`):

```bash
grep -rin "wisetech\|e2open\|cargowise\|easyclass\|docai\|scpm\|graphik\|\bwtg\b" \
  skills/ commands/ agents/ .claude/ 2>/dev/null \
  | grep -v "BRAND_SETUP\|WHAT_TO_UPDATE\|cc.config\|commands/maintain/audit" \
  | grep -v "skills/supply-chain-map/" | grep -v ".git"
```

Any hit is a leak — report `file:line` and recommend a fix. **Expected/exempt:** the
`supply-chain-map` skill lists `E2open` among o9/Kinaxis/SAP/Descartes in vendor reference
tables — that is factual market data, not toolkit branding, so it is excluded above.

### 3 — Frontmatter validation

For every command `.md` under `commands/`: verify it has frontmatter with a `description:` field. List any missing.

For every skill `SKILL.md` under `skills/`: verify it has `name:` and `description:` in frontmatter. List any missing.

For every agent `.md` under `agents/`: verify `name:` and `description:`. List any missing.

### 4 — Broken internal references

Skills and commands often reference sibling files (e.g. `references/foo.md`, `${CLAUDE_PLUGIN_ROOT}/skills/...`). For each such reference found in a SKILL.md or command file, check the target exists. Report broken paths as `source_file → missing_target`.

Pay special attention to:
- Cross-skill references (a skill that points at another skill which doesn't exist in the plugin)
- `references/` paths inside skill directories
- Brand asset paths in docx/pptx/diagram skills

Also confirm the `design-system` skill ships **no proprietary binary assets** (it must stay
clean-room): flag any embedded/licensed font or non-placeholder logo.

```bash
find skills/design-system -type f \( -name "*.otf" -o -name "*.ttf" -o -name "*.woff*" -o -name "*.eot" \) 2>/dev/null
# logos/images other than the empty assets/ placeholder are suspect:
find skills/design-system -type f \( -name "*.svg" -o -name "*.png" -o -name "*.jpg" \) 2>/dev/null
```

Any bundled typeface or real logo is a leak — the design system references fonts/icons by
category only (default `Inter` via the system stack). Report and recommend removal.

### 5 — Inventory drift (INVENTORY.md)

Compare the actual files on disk against what `INVENTORY.md` lists:
- Count skills in `skills/` vs skills listed in INVENTORY.md
- Count command files in `commands/` vs commands listed in INVENTORY.md

Report any skill/command present on disk but missing from INVENTORY.md (and vice versa). Offer to regenerate the INVENTORY.md tables.

### 6 — MCP coverage

Grep skills for MCP/connected-tool references and confirm each is documented in `MCP_SETUP.md`:

```bash
grep -rln -i "mcp\|connected tool" skills/ 2>/dev/null
```

Report any skill that uses an MCP tool but isn't listed in MCP_SETUP.md.

### 7 — Hardcoded stack literals (dev commands)

Dev commands must resolve their toolchain from the project's `STACK.md` (per
`references/dev/stack-resolution.md`), never hardcode one. Catch any reintroduced literal:

```bash
# Files intentionally framework-specific are exempt (they carry a stack_scope: marker)
EXEMPT=$(grep -rl "^stack_scope:" commands/ 2>/dev/null)
grep -rnE "uv run|cd backend|app\.main|uvicorn|alembic|npm run|pnpm |yarn " commands/ 2>/dev/null \
  | { [ -n "$EXEMPT" ] && grep -vFf <(echo "$EXEMPT") || cat; } \
  | grep -vE "verify/dependencies\.md|verify/security\.md|setup/stack\.md"
```

The remaining hits are **candidates**. A hit is **acceptable** (not a regression) when it is:
- in a file with a `stack_scope:` frontmatter key (intentionally framework-specific), or
- a commented example (`# …`) or a fenced block labelled `EXAMPLE`, or a per-language menu
  (e.g. `# Python (ruff): …`), or
- inside `verify/dependencies.md` / `verify/security.md` (package-manager lookup tables) or
  `setup/stack.md` (detection heuristics).

A hit is a **regression** when a command silently runs a single stack's commands as the only
path (e.g. an executable `cd backend && uv run pytest` step outside an example). Report
`file:line` and recommend converting it to STACK.md resolution, or adding a `stack_scope:`
marker if the command is genuinely framework-specific.

### 8 — Invocation policy (context budget)

Skill/command descriptions share a listing budget of ~1% of the context window; on overflow
Claude Code silently drops descriptions and conversational triggering breaks. Two checks keep
the listing lean (policy rationale: the commit that introduced this step):

**a) Chain targets must stay model-invocable.** A command that another command or skill
invokes mid-flow must NOT carry `disable-model-invocation: true`. Scan for flipped commands
that are hard-invoked elsewhere (imperative context or a dispatch/handoff table — the
`piv-orchestrator` dispatch table and `plan/project`'s handoff are known invokers):

```bash
# flipped commands
FLIPPED=$(grep -rl "^disable-model-invocation: true" commands/ | sed 's|commands/||; s|\.md$||; s|/|:|')
# any imperative or table-dispatch reference to them from another file is a conflict
for c in $FLIPPED; do
  grep -rnE "(run|invoke|execute|chain|hands? off to|\|)\s*\`?/cc:$c\b" commands/ skills/ references/ 2>/dev/null \
    | grep -v "commands/$(echo $c | tr ':' '/').md" | grep -vE "suggest|recommend|see |or \`/cc:" \
    && echo "⚠️  /cc:$c is flipped but invoked above"
done
```

Judgment applies: "suggest `/cc:x`" is fine (recommendation); "immediately invoke `/cc:x` —
do not ask" is a conflict → remove the flag from the target.

**b) Description length.** Flag any skill/command description over ~350 characters — the
listing truncates entries at 1,536 chars, but the shared budget is the real constraint. Put
the key use case and trigger phrases first. Report total listing size (all names +
descriptions of model-invocable entries) so drift is visible run-over-run.

New commands default to model-invocable — when adding one, decide deliberately: deliberate
typed workflow → add `disable-model-invocation: true`; conversational trigger (or a chain
target) → leave it invocable and keep the description tight.

### 9 — Report

Produce a single clean report with a status line per category:

```
Command Center Audit — <date>
─────────────────────────────
✅ Placeholders:    all resolved (or: N unresolved — run cc-apply.sh)
✅ Brand leakage:   none
⚠️  Frontmatter:    2 commands missing description
✅ Broken refs:     none
⚠️  INVENTORY.md:       1 skill on disk not listed
✅ MCP coverage:    complete
✅ Stack literals:  none (3 files stack_scope-exempt)
✅ Invocation:      N user-only, no flipped chain targets, listing size reported
```

For each ⚠️ or ❌, list the specifics and a recommended action. If the user wants, offer to auto-fix frontmatter and regenerate INVENTORY.md.
