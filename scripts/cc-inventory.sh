#!/usr/bin/env bash
# cc-inventory.sh — Generate the command/skill tables in INVENTORY.md from frontmatter.
#
# Regenerates the content between <!-- BEGIN GENERATED: X --> / <!-- END GENERATED: X -->
# marker pairs in global/INVENTORY.md, using each command/skill file’s frontmatter
# `description:` (full value, block scalars joined). Everything outside the markers (headings, prose,
# `---` separators) is left untouched.
#
# Command grouping (dev vs sales table, and the `Group` column) is derived from the
# subdirectory under commands/. Skill category (dev/sales/design table) and the
# sales/design ⚙ config column are not derivable from frontmatter alone — the category
# split is a curated taxonomy (mirrors CLAUDE.md's "Command Groups" section and this
# file's own pre-existing grouping); ⚙ is derived by grepping each skill dir for
# [COMPANY]/[PRODUCT_*] placeholders.
#
# Bash 3.2-compatible (macOS default). All parsing/generation logic runs in python3
# (already a hard requirement elsewhere in this repo — see scripts/cc-apply.sh).
#
# Usage:
#   bash scripts/cc-inventory.sh           # rewrite INVENTORY.md in place
#   bash scripts/cc-inventory.sh --check   # regenerate to a temp file, diff, exit non-zero on drift (no writes)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INVENTORY="$ROOT/INVENTORY.md"

MODE="write"
if [[ "${1:-}" == "--check" ]]; then
  MODE="check"
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: python3 is required" >&2
  exit 1
fi

if [[ ! -f "$INVENTORY" ]]; then
  echo "Error: $INVENTORY not found" >&2
  exit 1
fi

GEN_TMP="$(mktemp "${TMPDIR:-/tmp}/cc-inventory.XXXXXX")"
trap 'rm -f "$GEN_TMP"' EXIT

python3 - "$ROOT" "$INVENTORY" "$GEN_TMP" <<'PYEOF'
import os, re, sys

root, inventory_path, out_path = sys.argv[1], sys.argv[2], sys.argv[3]

# ── Frontmatter: `description:` value (block scalars joined) ────────────────────────────────
def first_description_line(path):
    try:
        with open(path, "r", encoding="utf-8", errors="strict") as fh:
            lines = [l.rstrip("\r\n") for l in fh.readlines()]
    except (OSError, UnicodeDecodeError):
        return None
    if not lines or lines[0] != "---":
        return None
    end_idx = None
    for i in range(1, len(lines)):
        if lines[i] == "---":
            end_idx = i
            break
    if end_idx is None:
        return None
    block = lines[1:end_idx]
    for i, line in enumerate(block):
        if line.startswith("description:"):
            remainder = line[len("description:"):].strip()
            if remainder in ("", ">", ">-", ">+", "|", "|-", "|+"):
                # Block scalar — join the full indented block (a bare first line
                # truncates mid-sentence in the generated tables).
                parts = []
                for cont in block[i + 1:]:
                    if cont and not cont[0].isspace():
                        break  # next frontmatter key
                    stripped = cont.strip()
                    if stripped:
                        parts.append(stripped)
                return " ".join(parts) if parts else None
            # Inline value — strip a matching pair of surrounding quotes.
            if len(remainder) >= 2 and remainder[0] == remainder[-1] and remainder[0] in "\"'":
                remainder = remainder[1:-1]
            return remainder
    return None


def md_escape(text):
    return text.replace("|", "\\|") if text else text


# ── Commands ───────────────────────────────────────────────────────────────
DEV_GROUP_ORDER = ["piv", "plan", "implement", "verify", "release", "git", "github",
                    "radar", "debug", "monitor", "entry", "setup", "maintain", "life"]
SALES_GROUP_ORDER = ["discovery", "account", "demo", "value", "deal", "rfp", "handover"]

commands_dir = os.path.join(root, "commands")
commands = []  # (group, slash, desc)
if os.path.isdir(commands_dir):
    for dirpath, dirnames, filenames in os.walk(commands_dir):
        for fn in sorted(filenames):
            if not fn.endswith(".md"):
                continue
            fpath = os.path.join(dirpath, fn)
            rel = os.path.relpath(fpath, commands_dir)
            parts = rel.split(os.sep)
            stem = parts[-1][:-3]
            if len(parts) == 1:
                group = "entry"
                slash = f"/cc:{stem}"
            else:
                group = parts[0]
                slash = f"/cc:{group}:{stem}"
            desc = first_description_line(fpath) or "(missing description)"
            commands.append((group, slash, desc))

unknown_groups = sorted({g for g, _, _ in commands} - set(DEV_GROUP_ORDER) - set(SALES_GROUP_ORDER))
if unknown_groups:
    sys.stderr.write(
        "NOTICE cc-inventory.sh: unclassified command group(s) "
        f"{unknown_groups} — bucketed into Dev Commands; add to DEV_GROUP_ORDER/SALES_GROUP_ORDER.\n"
    )

def group_order(group, known):
    return known.index(group) if group in known else len(known)

def build_command_table(rows):
    lines = ["| Command | Group | Description |", "|---------|-------|-------------|"]
    for group, slash, desc in rows:
        lines.append(f"| `{slash}` | {group} | {md_escape(desc)} |")
    return "\n".join(lines)

dev_rows = sorted(
    (c for c in commands if c[0] in DEV_GROUP_ORDER or c[0] not in SALES_GROUP_ORDER),
    key=lambda c: (group_order(c[0], DEV_GROUP_ORDER), c[1]),
)
sales_rows = sorted(
    (c for c in commands if c[0] in SALES_GROUP_ORDER),
    key=lambda c: (group_order(c[0], SALES_GROUP_ORDER), c[1]),
)

dev_commands_table = build_command_table(dev_rows)
sales_commands_table = build_command_table(sales_rows)

# ── Skills ─────────────────────────────────────────────────────────────────
# Curated category membership (not derivable from frontmatter). Mirrors the
# categorization already in INVENTORY.md as of this script's introduction.
DEV_SKILLS = [
    "piv-orchestrator", "security-audit", "gdpr-check", "skill-creator", "sop-creator",
    "archon", "rulecheck", "save-task-list", "triage", "diagram", "ship-pr",
    "architecture-board", "humanize", "feature-interview", "premerge-checklist",
    "piv-autopilot", "device-qa",
]
LIFE_SKILLS = [
    "council", "finance-council", "big-purchase-council", "subscriptions-audit",
    "home-council", "insurance-review",
    "health-council", "family-council", "benefits-navigator",
]
SALES_SKILLS = [
    "account-intelligence", "business-case-stress-tester", "champion-health",
    "competitive-battlecard", "confidence-tagger", "critical-business-issue-finder",
    "demo-dryrun-coach", "demo-storyboard", "discovery", "exec-briefing-prep",
    "field-comms-writer", "grill-me", "handoff", "integration-complexity",
    "linkedin-post", "meeting-notes-structurer", "negotiation-prep", "osd-architect",
    "presales-coach", "pricing-positioning", "rfx-navigator", "supply-chain-map",
    "tactical-empathy-coach", "toc-bbit-expert", "video-demo-creator",
    "win-loss-analyzer", "workshop-agenda-builder", "write-a-skill",
]
DESIGN_SKILLS = ["brand", "design-system", "docx-generator", "pptx-generator"]

CONFIG_TOKEN_RE = re.compile(r"\[COMPANY(?:_PRODUCT)?\]|\[PRODUCT_[A-E]\]")

def skill_has_config_tokens(skill_dir):
    for dirpath, dirnames, filenames in os.walk(skill_dir):
        for fn in filenames:
            fpath = os.path.join(dirpath, fn)
            try:
                with open(fpath, "r", encoding="utf-8", errors="strict") as fh:
                    text = fh.read()
            except (OSError, UnicodeDecodeError):
                continue
            if CONFIG_TOKEN_RE.search(text):
                return True
    return False

skills_dir = os.path.join(root, "skills")
all_skill_names = sorted(os.listdir(skills_dir)) if os.path.isdir(skills_dir) else []
all_skill_names = [n for n in all_skill_names if os.path.isdir(os.path.join(skills_dir, n))]

categorized = set(DEV_SKILLS) | set(SALES_SKILLS) | set(DESIGN_SKILLS) | set(LIFE_SKILLS)
uncategorized = sorted(set(all_skill_names) - categorized)
if uncategorized:
    sys.stderr.write(
        f"NOTICE cc-inventory.sh: uncategorized skill(s) {uncategorized} — "
        "bucketed into Dev Skills; add to the category lists in this script.\n"
    )

def skill_desc(name):
    return first_description_line(os.path.join(skills_dir, name, "SKILL.md")) or "(missing description)"

def build_dev_skills_table(names):
    lines = ["| Skill | Description |", "|-------|-------------|"]
    if not names:
        lines.append("| _none in this variant_ | |")
    for name in names:
        lines.append(f"| `{name}` | {md_escape(skill_desc(name))} |")
    return "\n".join(lines)

def build_config_skills_table(names, notes_header="Description"):
    lines = [f"| Skill | Config | {notes_header} |", "|-------|:------:|" + "-" * (len(notes_header) + 2) + "|"]
    if not names:
        lines.append("| _none in this variant_ | | |")
    for name in names:
        cfg = "⚙" if skill_has_config_tokens(os.path.join(skills_dir, name)) else ""
        lines.append(f"| `{name}` | {cfg} | {md_escape(skill_desc(name))} |")
    return "\n".join(lines)

dev_skill_names = sorted(set(DEV_SKILLS) & set(all_skill_names)) + sorted(set(uncategorized))
sales_skill_names = sorted(set(SALES_SKILLS) & set(all_skill_names))
design_skill_names = sorted(set(DESIGN_SKILLS) & set(all_skill_names))
life_skill_names = sorted(set(LIFE_SKILLS) & set(all_skill_names))

dev_skills_table = build_dev_skills_table(dev_skill_names)
sales_skills_table = build_config_skills_table(sales_skill_names)
design_skills_table = build_config_skills_table(design_skill_names, notes_header="Notes")
life_skills_table = build_dev_skills_table(life_skill_names)

sections = {
    "dev-commands": dev_commands_table,
    "sales-commands": sales_commands_table,
    "dev-skills": dev_skills_table,
    "sales-skills": sales_skills_table,
    "design-skills": design_skills_table,
    "life-skills": life_skills_table,
}

# ── Marker substitution ───────────────────────────────────────────────────────
with open(inventory_path, "r", encoding="utf-8") as fh:
    original = fh.read()

updated = original
missing_markers = []
for marker_id, table in sections.items():
    begin = f"<!-- BEGIN GENERATED: {marker_id} -->"
    end = f"<!-- END GENERATED: {marker_id} -->"
    pattern = re.compile(re.escape(begin) + r"\n.*?\n" + re.escape(end), re.DOTALL)
    replacement = f"{begin}\n{table}\n{end}"
    new_updated, n = pattern.subn(replacement, updated)
    if n == 0:
        missing_markers.append(marker_id)
    else:
        updated = new_updated

if missing_markers:
    sys.stderr.write(
        f"Error: INVENTORY.md is missing marker pair(s) for: {', '.join(missing_markers)}\n"
        "Expected '<!-- BEGIN GENERATED: <id> -->' / '<!-- END GENERATED: <id> -->' "
        "around each table.\n"
    )
    sys.exit(2)

with open(out_path, "w", encoding="utf-8") as fh:
    fh.write(updated)
PYEOF
py_rc=$?

if [[ "$py_rc" -ne 0 ]]; then
  exit "$py_rc"
fi

if [[ "$MODE" == "check" ]]; then
  if diff -u "$INVENTORY" "$GEN_TMP" >/tmp/cc-inventory-diff.$$ 2>&1; then
    echo "INVENTORY.md is up to date with frontmatter."
    rm -f /tmp/cc-inventory-diff.$$
    exit 0
  else
    echo "INVENTORY.md is out of date. Diff (generated vs current):"
    sed "s|^--- $INVENTORY|--- INVENTORY.md (current)|; s|^+++ $GEN_TMP|+++ INVENTORY.md (generated)|" /tmp/cc-inventory-diff.$$
    rm -f /tmp/cc-inventory-diff.$$
    exit 1
  fi
else
  if diff -q "$INVENTORY" "$GEN_TMP" >/dev/null 2>&1; then
    echo "INVENTORY.md already up to date. No changes written."
  else
    cp "$GEN_TMP" "$INVENTORY"
    echo "INVENTORY.md regenerated from frontmatter."
  fi
  exit 0
fi
