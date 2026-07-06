---
name: diagram
description: Generate software architecture and flow diagrams in Excalidraw format. For a company's supply-chain / logistics map use the `supply-chain-map` skill instead; for Theory-of-Constraints thinking-process trees and clouds use `toc-bbit-expert`.
---

# 🎨 Skill: Create Diagram

Generate beautiful, editable diagrams (Excalidraw format) for:
- System architecture
- Database schema
- Request flow
- Sequence diagrams
- Data relationships

---

## Usage

```
/create:diagram [type] [title]
```

### Types

- `architecture` — System components and relationships
- `dataflow` — How data moves through the system
- `database` — Tables, relationships, constraints
- `sequence` — Message sequence between actors
- `state` — State machine transitions
- `entity-relationship` — Database entities and relationships

### Examples

```
/create:diagram architecture "Items Service Architecture"
/create:diagram dataflow "Create Item Request Flow"
/create:diagram database "Items Database Schema"
/create:diagram sequence "User Authentication Flow"
```

---

## What You Get

✅ **Excalidraw JSON** — editable in excalidraw.com
✅ **PNG export** — ready for docs
✅ **SVG export** — for presentations
✅ **ASCII diagram** — for README

---

## Workflow

1. **Describe** what you want to visualize
2. **Generate** the diagram
3. **Export** (PNG, SVG, ASCII, or keep editing in Excalidraw)
4. **Commit** to docs/diagrams/ or embed in README

---

## Examples

### Architecture Diagram

```
FastAPI Backend
├── Routes (HTTP)
├── Service (Business Logic)
├── Repository (Database)
└── Models (SQLAlchemy)

↓ Database ↓

PostgreSQL
└── Items Table
```

Generates: Clean, color-coded diagram in Excalidraw format.

### Database Schema Diagram

```
Items Table
├── id (PK)
├── name (UNIQUE)
├── description
├── price
├── created_at
└── updated_at

Orders Table
├── id (PK)
├── user_id (FK)
├── item_id (FK → Items)
├── quantity
└── created_at
```

Generates: Entity-relationship diagram with connections.

### Request Flow Diagram

```
1. User submits form
   ↓
2. FastAPI validates input
   ↓
3. Service processes logic
   ↓
4. Repository queries DB
   ↓
5. Response returns (201 Created)
```

Generates: Sequence diagram with timing.

---

## Integration Points

### In Feature README

```markdown
# Items CRUD Feature

## Architecture

[Diagram: Items Service Architecture]

## Data Flow

[Diagram: Create Item Request Flow]
```

### In Spec Documents

```markdown
## System Design

See: docs/diagrams/items-architecture.json (editable in Excalidraw)
See: docs/diagrams/items-architecture.png (for this README)
```

### In PR Description

```markdown
## What this PR does

[Diagram: How this feature connects to existing system]

## Before/After

[Before] Simple list
[After] Paginated, sortable list with filters
```

---

## Exporting Diagrams

**Option 1: Keep in Excalidraw**
- Save as `.json`
- Commit to `docs/diagrams/`
- Link: excalidraw.com/@[username]/[diagram-id]

**Option 2: Export as PNG**
```bash
# From Excalidraw: File → Export → PNG
# Commit to docs/diagrams/
git add docs/diagrams/items-architecture.png
```

**Option 3: Export as SVG**
```text
# From Excalidraw: File → Export → SVG
# Embed in markdown
![Items Architecture](docs/diagrams/items-architecture.svg)
```

**Option 4: ASCII for README**
```text
/create:diagram architecture "Items" --format ascii

# Outputs:
# ┌──────────────┐
# │  FastAPI     │
# └──────────────┘
#       ↓
# ┌──────────────┐
# │ PostgreSQL   │
# └──────────────┘
```

---

## Tips

- **Keep it simple:** Too many boxes = unreadable
- **Color code:** Use colors to group related components
- **Label connections:** Explain what flows where
- **Version diagrams:** Save old versions (`v1`, `v2`) to track evolution
- **Keep in sync:** Update diagram when architecture changes

---

## When to Create Diagrams

✅ New feature architecture
✅ Database schema changes
✅ Complex request flows
✅ System integration points
✅ Deployment topology
✅ Onboarding documentation

❌ Simple concepts (text is fine)
❌ Obvious flows (avoid over-documentation)

---

## See Also

- `docs/diagrams/` — where diagrams live
- `${user_config.workspace_dir}/context/architecture.md` — system overview
- Feature README.md files — where diagrams should be embedded
