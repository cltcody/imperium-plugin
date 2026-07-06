# 01_core_principles.md

# Core Principles

**VERBOSE NAMING IS NON-NEGOTIABLE**

Use intention-revealing names: `product_id`, `product_name` (not `id`, `name`)

Choose clarity over brevity always

**AI-FRIENDLY LOGGING IS MANDATORY**

Structured JSON to stdout/console with contextual fields

Descriptive event names (snake_case: `filtering_products`, `validation_failed`)

Include `fix_suggestion` in error logs

**TYPE SAFETY IS REQUIRED**

Backend: Full Pydantic validation

Frontend: TypeScript strict mode, no `any` without justification

**DOCUMENTATION EVERYWHERE**

Backend: Google-style docstrings with examples

Frontend: JSDoc for complex functions