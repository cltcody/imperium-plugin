---
name: write-a-skill
description: |
  Creates a new Claude skill for the Industry Solutions Skills library -- guides
  requirements gathering, authoring a correctly-structured SKILL.md, placing reference
  files, updating INVENTORY.md, and installing via `bash install.sh` from the imperium root.
  Use when you say "write a skill", "create a skill", "add a skill", or "how do I add a
  skill".
---

# Write a Skill

Guides the creation of a new skill for the Industry Solutions Skills library — from
requirements to installed, committed, and listed in INVENTORY.md.

---

## Step 1 — Gather requirements

Ask the user for:

| Field | Question |
|-------|----------|
| **Name** | What should the skill be called? (kebab-case, e.g. `exec-briefing-prep`) |
| **Purpose** | What task does it perform in one sentence? |
| **Triggers** | What phrases will users say to activate it? (aim for 8–15 natural variations) |
| **Workflow** | What steps does it follow? How many intake questions are needed? |
| **Output** | What does it produce — a document, a structured table, a coaching brief? |
| **References** | Is there supporting material to bundle (cheat sheets, frameworks, templates)? |
| **Connected tools** | Should it use Salesforce, Confluence, or SharePoint if available? |

If the user has already provided some of this in their request, do not ask again.

---

## Step 2 — Create the skill file

Create the file at:

```
skills/<skill-name>/SKILL.md
```

Use the template below — do not deviate from its structure. Every skill in this library
follows the same pattern so users can predict where to find things.

### SKILL.md template

```markdown
---
name: skill-name
description: |
  One-sentence summary of what the skill does and its core capability.
  Use when the user says "trigger phrase one", "trigger phrase two", or "trigger phrase
  three", or describes the situation this skill applies to.
  Max 1024 characters. Write in third person. No separate `triggers:` key — Claude Code
  only surfaces `description:` for auto-invocation, so fold every trigger phrase into it.
---

# Skill Name

One-sentence summary of what the skill does and when to use it.

---

## Connected Tools

| Tool | What it does for you |
|------|---------------------|
| **Salesforce** | What Salesforce provides — or "Not used by this skill" |
| **Confluence** | What Confluence provides — or "Not used by this skill" |

No connections? The skill works the same — just paste the context manually.

---

## Step 1 — Intake

What to ask before starting. Keep questions to a minimum — only what's needed.

| Field | Required / Optional |
|-------|---------------------|
| [Field] | Required |
| [Field] | Optional — default: [X] |

---

## Step 2 — [Main workflow step]

What Claude does here. Be specific — this is instruction, not description.

---

## Step 3 — Output

What gets produced. Include exact format, sections, and any output file path.

---

## Quality checklist

- [ ] [Check 1]
- [ ] [Check 2]
- [ ] [Check 3]
```

---

## Step 3 — Add reference files (if needed)

Place supporting material in:

```
skills/<skill-name>/references/
```

Reference files are appropriate when:
- The SKILL.md would exceed 500 lines without them
- Content belongs to a distinct domain (e.g. separate question banks per product suite)
- The material is loaded selectively, not always (e.g. advanced questions vs standard questions)

Name files descriptively: `opening-framework.md`, `gtm-questions.md`, `pricing-tiers.md`.
Instruct Claude to `Read` them explicitly inside the relevant Step.

---

## Step 4 — Update INVENTORY.md

Add a row to the skills table in `INVENTORY.md`:

```markdown
| `skill-name` | One-line description of what the skill does | "primary trigger phrase", "alternative phrase" |
```

INVENTORY.md is read by every agent at session start. If the skill isn't listed there, it won't
be discovered. This step is mandatory.

---

## Step 5 — Install and test

This library ships as the `presales` plugin. To test your skill locally, install the plugin from your working copy:

```
/plugin marketplace add <path-to-this-repo>
/plugin install cc@imperium
```

Then verify the skill loads by triggering it with one of its trigger phrases in a new session.
After merging to `main`, team members receive the update through the plugin (GitHub sync or the next release ZIP).

---

## Description and triggers — authoring guide

Both fields live in the SKILL.md frontmatter and serve different purposes.

### `description` — for the agent

The description is read by Claude alongside all other installed skills when deciding
which skill to load. It must give enough signal to distinguish this skill from others.

**Format:**
- Max 1024 characters
- Third person
- First sentence: what it does
- Second sentence: "Use when [specific triggers, contexts, or user phrases]"

**Good:**
```
Extract text and tables from PDF files, fill forms, and merge documents.
Use when the user is working with PDF files or mentions PDFs, forms, or document extraction.
```

**Bad:**
```
Helps with documents.
```

### `triggers` — for search and discovery

The `triggers` list is the canonical set of phrases users say to activate the skill.
It appears in INVENTORY.md and is used by the `/guide` command and session tooling.

- Aim for 8–15 trigger phrases
- Cover exact phrases, natural variations, and common misspellings
- Include both action phrases ("write a follow-up email") and situation phrases ("I just finished a call")
- Do not duplicate the description — triggers are user-facing, description is agent-facing

---

## Quality checklist

- [ ] `name` is kebab-case and matches the directory name
- [ ] `description` is under 1024 chars, third person, ends with "Use when..."
- [ ] `triggers` has 8–15 natural variations covering the main use cases
- [ ] Connected Tools section is present (even if "Not used by this skill")
- [ ] Workflow follows Step 1 (Intake) → Step N → Output structure
- [ ] Quality checklist is included at the end of the skill
- [ ] Reference files placed in `references/` subdirectory (not flat alongside SKILL.md)
- [ ] INVENTORY.md updated with a row for this skill
- [ ] `bash install.sh` re-run from the imperium root to install the skill globally
- [ ] Skill activated with a trigger phrase to confirm it loads correctly
