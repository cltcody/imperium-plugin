---
name: skill-creator
description: |
  Guide for creating or updating skills in this project — structure, frontmatter, triggering, and
  packaging. Use on "create a skill", "add a skill", "new skill for", or "improve the skill".
disable-model-invocation: true
license: Complete terms in LICENSE.txt
---

# Skill Creator

This skill provides guidance for creating effective skills — and for landing them correctly in this repository, which ships its Claude Code assets at the plugin root (`global/`), not under `.claude/` (that path is reserved for local settings/hooks).

## Where things live in this project

| Artifact | Location | Invoked as |
|----------|----------|------------|
| Skills | `skills/<skill-name>/SKILL.md` | Triggered by description match or `/<skill-name>` |
| Skill resources | `skills/<skill-name>/{references,scripts,assets}/` | Loaded on demand |
| Commands | `commands/<group>/<name>.md` | `/cc:<group>:<name>` |
| Subagents | `agents/<name>.md` | Delegated to by commands via the Agent tool |

After adding or changing a skill:
1. Update the Skills section in `CLAUDE.md` so the skill is documented.
2. Run `/cc:maintain:audit` — it checks frontmatter, naming, and references for every command, skill, and agent.
3. Commit via `/cc:release:commit`.

## About Skills

Skills are modular, self-contained packages that extend Claude's capabilities by providing
specialized knowledge, workflows, and tools. Think of them as "onboarding guides" for specific
domains or tasks—they transform Claude from a general-purpose agent into a specialized agent
equipped with procedural knowledge that no model can fully possess.

### What Skills Provide

1. Specialized workflows - Multi-step procedures for specific domains
2. Tool integrations - Instructions for working with specific file formats or APIs
3. Domain expertise - Company-specific knowledge, schemas, business logic
4. Bundled resources - Scripts, references, and assets for complex and repetitive tasks

## Core Principles

### Concise is Key

The context window is a public good. Skills share the context window with everything else Claude needs: system prompt, conversation history, other Skills' metadata, and the actual user request.

**Default assumption: Claude is already very smart.** Only add context Claude doesn't already have. Challenge each piece of information: "Does Claude really need this explanation?" and "Does this paragraph justify its token cost?"

Prefer concise examples over verbose explanations.

### Set Appropriate Degrees of Freedom

Match the level of specificity to the task's fragility and variability:

**High freedom (text-based instructions)**: Use when multiple approaches are valid, decisions depend on context, or heuristics guide the approach.

**Medium freedom (pseudocode or scripts with parameters)**: Use when a preferred pattern exists, some variation is acceptable, or configuration affects behavior.

**Low freedom (specific scripts, few parameters)**: Use when operations are fragile and error-prone, consistency is critical, or a specific sequence must be followed.

Think of Claude as exploring a path: a narrow bridge with cliffs needs specific guardrails (low freedom), while an open field allows many routes (high freedom).

### Anatomy of a Skill

Every skill consists of a required SKILL.md file and optional bundled resources:

```
skills/skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter metadata (required)
│   │   ├── name: (required)
│   │   └── description: (required)
│   └── Markdown instructions (required)
└── Bundled Resources (optional)
    ├── scripts/          - Executable code (Python/Bash/etc.)
    ├── references/       - Documentation intended to be loaded into context as needed
    └── assets/           - Files used in output (templates, icons, fonts, etc.)
```

The folder name must be kebab-case and match the `name` field. The file must be named exactly `SKILL.md`.

#### SKILL.md (required)

Every SKILL.md consists of:

- **Frontmatter** (YAML): Contains `name` and `description` fields. These are the only fields that Claude reads to determine when the skill gets used, thus it is very important to be clear and comprehensive in describing what the skill is, and when it should be used.
- **Body** (Markdown): Instructions and guidance for using the skill. Only loaded AFTER the skill triggers (if at all).

#### Bundled Resources (optional)

##### Scripts (`scripts/`)

Executable code (Python/Bash/etc.) for tasks that require deterministic reliability or are repeatedly rewritten.

- **When to include**: When the same code is being rewritten repeatedly or deterministic reliability is needed
- **Example**: `scripts/rotate_pdf.py` for PDF rotation tasks
- **Benefits**: Token efficient, deterministic, may be executed without loading into context
- **Note**: Scripts may still need to be read by Claude for patching or environment-specific adjustments

##### References (`references/`)

Documentation and reference material intended to be loaded as needed into context to inform Claude's process and thinking.

- **When to include**: For documentation that Claude should reference while working
- **Examples**: `references/finance.md` for financial schemas, `references/api_docs.md` for API specifications, `references/report-template.md` for a report skeleton
- **Use cases**: Database schemas, API documentation, domain knowledge, company policies, detailed workflow guides
- **Benefits**: Keeps SKILL.md lean, loaded only when Claude determines it's needed
- **Best practice**: If files are large (>10k words), include grep search patterns in SKILL.md
- **Avoid duplication**: Information should live in either SKILL.md or references files, not both. Prefer references files for detailed information unless it's truly core to the skill—this keeps SKILL.md lean while making information discoverable without hogging the context window. Keep only essential procedural instructions and workflow guidance in SKILL.md; move detailed reference material, schemas, and examples to references files.

##### Assets (`assets/`)

Files not intended to be loaded into context, but rather used within the output Claude produces.

- **When to include**: When the skill needs files that will be used in the final output
- **Examples**: `assets/logo.png` for brand assets, `assets/slides.pptx` for PowerPoint templates, `assets/frontend-template/` for HTML/React boilerplate
- **Benefits**: Separates output resources from documentation, enables Claude to use files without loading them into context

#### What to Not Include in a Skill

A skill should only contain essential files that directly support its functionality. Do NOT create extraneous documentation or auxiliary files, including:

- README.md
- INSTALLATION_GUIDE.md
- QUICK_REFERENCE.md
- CHANGELOG.md
- etc.

The skill should only contain the information needed for an AI agent to do the job at hand. It should not contain auxiliary context about the process that went into creating it, setup and testing procedures, user-facing documentation, etc. Creating additional documentation files just adds clutter and confusion. (`python scripts/validate_claude_assets.py` flags README files inside skill folders.)

### Progressive Disclosure Design Principle

Skills use a three-level loading system to manage context efficiently:

1. **Metadata (name + description)** - Always in context (~100 words)
2. **SKILL.md body** - When skill triggers (<5k words)
3. **Bundled resources** - As needed by Claude (Unlimited because scripts can be executed without reading into context window)

#### Progressive Disclosure Patterns

Keep SKILL.md body to the essentials and under 500 lines to minimize context bloat. Split content into separate files when approaching this limit. When splitting out content into other files, it is very important to reference them from SKILL.md and describe clearly when to read them, to ensure the reader of the skill knows they exist and when to use them.

**Key principle:** When a skill supports multiple variations, frameworks, or options, keep only the core workflow and selection guidance in SKILL.md. Move variant-specific details (patterns, examples, configuration) into separate reference files.

**Pattern 1: High-level guide with references**

```markdown
# PDF Processing

## Quick start

Extract text with pdfplumber:
[code example]

## Advanced features

- **Form filling**: See [FORMS.md](references/FORMS.md) for complete guide
- **API reference**: See [REFERENCE.md](references/REFERENCE.md) for all methods
```

Claude loads the referenced files only when needed.

**Pattern 2: Domain-specific organization**

For Skills with multiple domains or variants, organize content by domain so only the relevant file is loaded:

```
skills/cloud-deploy/
├── SKILL.md (workflow + provider selection)
└── references/
    ├── aws.md (AWS deployment patterns)
    ├── gcp.md (GCP deployment patterns)
    └── azure.md (Azure deployment patterns)
```

When the user chooses AWS, Claude only reads aws.md.

**Pattern 3: Conditional details**

Show basic content, link to advanced content ("For tracked changes: see references/redlining.md").

**Important guidelines:**

- **Avoid deeply nested references** - Keep references one level deep from SKILL.md. All reference files should link directly from SKILL.md.
- **Structure longer reference files** - For files longer than 100 lines, include a table of contents at the top so Claude can see the full scope when previewing.

## Skill Creation Process

1. Understand the skill with concrete examples
2. Plan reusable skill contents (scripts, references, assets)
3. Create the skill folder and resources
4. Write SKILL.md
5. Register and validate (CLAUDE.md + `python scripts/validate_claude_assets.py`)
6. Iterate based on real usage

### Step 1: Understanding the Skill with Concrete Examples

Skip this step only when the skill's usage patterns are already clearly understood. It remains valuable even when working with an existing skill.

To create an effective skill, clearly understand concrete examples of how the skill will be used. For example, when building an image-editor skill, relevant questions include:

- "What functionality should the skill support?"
- "Can you give some examples of how this skill would be used?"
- "What would a user say that should trigger this skill?"

To avoid overwhelming users, avoid asking too many questions in a single message. Conclude this step when there is a clear sense of the functionality the skill should support.

### Step 2: Planning the Reusable Skill Contents

Analyze each concrete example by:

1. Considering how to execute on the example from scratch
2. Identifying what scripts, references, and assets would be helpful when executing these workflows repeatedly

Examples: a `pdf-editor` skill benefits from a `scripts/rotate_pdf.py` (same code rewritten each time); a `big-query` skill benefits from `references/schema.md` (schemas rediscovered each time); a report-producing skill benefits from `references/report-template.md`.

### Step 3: Create the Skill Folder

Create `skills/<skill-name>/` (kebab-case) with `SKILL.md` and only the resource folders the skill actually needs. There is no init script in this repo — create the files directly. Implement and test any `scripts/` by actually running them; populate `references/` and `assets/` with real content (this may need user input, e.g. templates or documentation).

Consult these design-pattern guides as needed:

- **Multi-step processes**: See [references/workflows.md](references/workflows.md) for sequential workflows and conditional logic
- **Specific output formats or quality standards**: See [references/output-patterns.md](references/output-patterns.md) for template and example patterns

### Step 4: Write SKILL.md

Remember the skill is being created for another instance of Claude to use. Include information that is beneficial and non-obvious. **Always use imperative/infinitive form.**

##### Frontmatter

Write the YAML frontmatter with `name` and `description`:

- `name`: The skill name, matching the folder (kebab-case)
- `description`: The primary triggering mechanism for the skill.
  - Include both what the Skill does and specific triggers/contexts for when to use it.
  - Include all "when to use" information here — not in the body. The body is only loaded after triggering, so "When to Use This Skill" sections in the body are not helpful to Claude.
  - Example for a `docx` skill: "Comprehensive document creation, editing, and analysis with support for tracked changes, comments, formatting preservation, and text extraction. Use when Claude needs to work with professional documents (.docx files) for: (1) Creating new documents, (2) Modifying or editing content, (3) Working with tracked changes, (4) Adding comments, or any other document tasks"

Do not include any other fields in the YAML frontmatter.

##### Body

Write instructions for using the skill and its bundled resources. If the skill references project commands, always use the `/` prefix (e.g. `/cc:verify:run`, `/cc:release:commit`).

### Step 5: Register and Validate

The skill ships with the repository — no packaging step, no install script. To land the skill:

1. Document the skill in the Skills section of `CLAUDE.md`.
2. Run `python scripts/validate_claude_assets.py` and fix anything it reports (frontmatter fields, kebab-case naming, broken relative links, stray files).
3. Commit via `/cc:release:commit`.

### Step 6: Iterate

After testing the skill, users may request improvements. Often this happens right after using the skill, with fresh context of how the skill performed.

**Iteration workflow:**

1. Use the skill on real tasks
2. Notice struggles or inefficiencies
3. Identify how SKILL.md or bundled resources should be updated
4. Implement changes, re-run `python scripts/validate_claude_assets.py`, and test again
