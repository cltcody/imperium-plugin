# 03_architecture.md

# Architecture

## Backend: `app/api/` → `app/services/` → `app/models/`

Service Layer: API routes delegate to service functions

Tests mirror `app/` structure (`test_<module>.py`)

StructuredLogger for all logging

## Frontend: `src/components/` + `src/lib/` + `src/types/`

Component composition with explicit Props interfaces

TypeScript types match backend Pydantic models exactly

StructuredLogger matching backend pattern