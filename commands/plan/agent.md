---
description: Scaffold a Pydantic AI agent as a vertical slice in the FastAPI backend
argument-hint: [agent name, e.g. research_agent]
stack_scope: python-fastapi
disable-model-invocation: true
---

# Scaffold New AI Agent Feature

Scaffold a Pydantic AI agent as a vertical slice in the FastAPI backend.

> **Stack scope:** This command targets a **Python / FastAPI** vertical-slice backend (Pydantic AI). Its scaffolding is framework-specific and intentionally *not* generalized — for other stacks, use `/cc:plan:feature` for a generic plan and adapt to your framework's conventions. Any validation it runs still resolves from the project's `STACK.md`.

## Steps

### 1. Gather requirements

Ask me:
1. **What is the agent name?** (e.g. "research_agent", "email_agent", "rag_agent")
2. **What is the agent's single responsibility?** (one sentence)
3. **Which LLM provider?** (default: Anthropic/Claude — check STACK.md)
4. **What tools does the agent need?** (list them — e.g. web_search, query_db, send_email)
5. **Does it need RAG?** (yes → also scaffold pipeline; no → skip)
6. **Streaming or single response?**

### 2. Create the full agent slice

```
backend/app/<agent_name>/
├── __init__.py
├── agent.py         ← Pydantic AI agent definition
├── clients.py       ← LLM client + provider configuration
├── prompt.py        ← System prompt template
├── tools.py         ← Tool implementations
├── schemas.py       ← Request/response Pydantic schemas
├── routes.py        ← FastAPI endpoint (POST /run or /stream)
├── exceptions.py    ← Agent-specific exceptions
├── constants.py     ← Model names, limits, timeouts
├── tests/
│   ├── __init__.py
│   └── test_agent.py
└── README.md
```

Use these file templates:

#### `constants.py`
```python
"""Constants for the <agent_name> agent. All model names and limits live here."""


class <AgentName>Constants:
    # Model configuration
    DEFAULT_MODEL: str = "claude-sonnet-5"          # update per STACK.md
    MAX_RETRIES: int = 3
    TIMEOUT_SECONDS: int = 60
    MAX_TOKENS: int = 4096

    # Router
    ROUTER_PREFIX: str = "/<agent_name>"
    ROUTER_TAG: str = "<agent_name>"

    # Tool limits
    MAX_SEARCH_RESULTS: int = 5
    MAX_CONTEXT_CHUNKS: int = 10
```

#### `clients.py`
```python
"""LLM client and provider configuration for <agent_name>."""
from pydantic_ai.models.anthropic import AnthropicModel
from app.<agent_name>.constants import <AgentName>Constants
from app.core.config import get_settings


def get_llm_model() -> AnthropicModel:
    """Return configured LLM model.

    Returns:
        Configured Anthropic model instance.
    """
    settings = get_settings()
    return AnthropicModel(
        <AgentName>Constants.DEFAULT_MODEL,
        api_key=settings.anthropic_api_key,
    )
```

#### `prompt.py`
```python
"""System prompt for <agent_name>. Keep prompts versioned and documented."""

SYSTEM_PROMPT = """You are <agent description>.

## Your capabilities
- <capability 1>
- <capability 2>

## Guidelines
- <behavioral guideline 1>
- <behavioral guideline 2>

## Response format
<describe expected output format>
"""
```

#### `tools.py`
```python
"""Tool implementations for <agent_name>.

Each tool has:
- A clear docstring (the agent reads this to decide when to use it)
- Typed inputs and outputs
- Structured logging with agent.tool.* events
- Its own exception handling
"""
from pydantic_ai import RunContext
from app.<agent_name>.constants import <AgentName>Constants
from app.core.logging import get_logger

logger = get_logger(__name__)


async def example_tool(ctx: RunContext[None], query: str) -> str:
    """Search for information about the given query.

    Use this tool when the user asks about topics that require
    up-to-date or external information.

    Args:
        ctx: Agent run context.
        query: The search query string.

    Returns:
        Search results as a formatted string.
    """
    logger.info("agent.tool.execution_started", tool="example_tool", query=query)
    try:
        # implement tool logic here
        result = f"Results for: {query}"
        logger.info("agent.tool.execution_completed", tool="example_tool")
        return result
    except Exception as e:
        logger.error(
            "agent.tool.execution_failed",
            tool="example_tool",
            error=str(e),
            error_type=type(e).__name__,
            exc_info=True,
        )
        raise
```

#### `agent.py`
```python
"""Pydantic AI agent definition for <agent_name>."""
import time
from pydantic_ai import Agent
from app.<agent_name>.clients import get_llm_model
from app.<agent_name>.prompt import SYSTEM_PROMPT
from app.<agent_name>.tools import example_tool
from app.<agent_name>.schemas import AgentRequest, AgentResponse
from app.core.logging import get_logger

logger = get_logger(__name__)

# Agent is stateless — instantiate once at module level
_agent = Agent(
    model=get_llm_model(),
    system_prompt=SYSTEM_PROMPT,
    tools=[example_tool],
)


async def run_agent(request: AgentRequest) -> AgentResponse:
    """Run the <agent_name> agent.

    Args:
        request: Validated agent request with user message and optional context.

    Returns:
        Agent response with result text and usage metadata.
    """
    start = time.time()
    logger.info("agent.lifecycle.started", agent="<agent_name>", message_len=len(request.message))

    result = await _agent.run(request.message)
    duration_ms = round((time.time() - start) * 1000, 2)

    logger.info(
        "agent.lifecycle.completed",
        agent="<agent_name>",
        duration_ms=duration_ms,
        tokens=result.usage().total_tokens if result.usage() else None,
    )

    return AgentResponse(
        result=str(result.data),
        usage=result.usage().total_tokens if result.usage() else 0,
    )
```

#### `schemas.py`
```python
"""Request/response schemas for <agent_name>."""
from pydantic import BaseModel, Field


class AgentRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=10000)
    context: dict[str, str] | None = Field(None)


class AgentResponse(BaseModel):
    result: str
    usage: int = Field(0, description="Total tokens used")
```

#### `exceptions.py`
```python
"""Agent-specific exceptions for <agent_name>."""


class AgentError(Exception):
    """Base exception for agent errors."""
    pass


class AgentTimeoutError(AgentError):
    def __init__(self, timeout_seconds: int) -> None:
        super().__init__(f"Agent timed out after {timeout_seconds}s")


class AgentToolError(AgentError):
    def __init__(self, tool: str, reason: str) -> None:
        super().__init__(f"Tool '{tool}' failed: {reason}")
```

#### `routes.py`
```python
"""HTTP routes for <agent_name>."""
from fastapi import APIRouter
from app.<agent_name>.agent import run_agent
from app.<agent_name>.constants import <AgentName>Constants
from app.<agent_name>.schemas import AgentRequest, AgentResponse

router = APIRouter(
    prefix=<AgentName>Constants.ROUTER_PREFIX,
    tags=[<AgentName>Constants.ROUTER_TAG],
)


@router.post("/run", response_model=AgentResponse)
async def run(request: AgentRequest) -> AgentResponse:
    """Run the <agent_name> agent with the given message."""
    return await run_agent(request)
```

#### `README.md`
```markdown
# <AgentName>

One sentence: what this agent does and when to use it.

## Capabilities

- <tool or capability 1>
- <tool or capability 2>

## API

**POST `/<agent_name>/run`**
```json
{
  "message": "user message here",
  "context": {}
}
```

## Tools

| Tool | When used | Input | Output |
|------|-----------|-------|--------|
| example_tool | <when agent uses it> | query: str | results: str |

## Configuration

| Env Var | Description | Required |
|---------|-------------|----------|
| `ANTHROPIC_API_KEY` | LLM provider key | Yes |

## Observability

All events logged under `agent.*` namespace. See `backend/docs/logging-standard.md`.
Key events: `agent.lifecycle.started`, `agent.tool.execution_*`, `agent.lifecycle.completed`.

## Reliability

- Max retries: see `constants.py`
- Timeout: see `constants.py`
- Error handling: all tool errors caught, logged, re-raised as `AgentToolError`
```

#### `tests/test_agent.py`
```python
"""Tests for <agent_name>."""
import pytest
from unittest.mock import AsyncMock, patch
from app.<agent_name>.agent import run_agent
from app.<agent_name>.schemas import AgentRequest


@pytest.mark.asyncio
async def test_run_agent_returns_response() -> None:
    """Agent returns a response for a valid request."""
    # Stub: mock the Pydantic AI agent run to avoid real LLM calls in unit tests
    request = AgentRequest(message="test message")
    # Replace with real mock when implementing
    pass


@pytest.mark.asyncio
async def test_run_agent_handles_tool_error() -> None:
    """Agent handles tool failures gracefully."""
    pass
```

### 3. Wire up after scaffolding

1. Add required env var to `backend/.env.example`:
```bash
ANTHROPIC_API_KEY=your-key-here
```

2. Add the API key to `backend/app/core/config.py` Settings:
```python
anthropic_api_key: str = Field(..., description="Anthropic API key")
```

3. Wire the router in `backend/app/main.py`:
```python
from app.<agent_name>.routes import router as <agent_name>_router
app.include_router(<agent_name>_router)
```

4. Add `pydantic-ai` to dependencies if not already present:
```bash
cd backend && uv add pydantic-ai
```

5. See `reference/patterns/agent-patterns.md` for advanced patterns:
   - Multi-tool agents
   - RAG integration
   - Streaming responses
   - Human-in-the-loop
   - Multi-agent orchestration

## Output

A complete agent vertical slice at `backend/app/<agent_name>/` — agent definition, clients, prompt, tools, schemas, routes, exceptions, constants, test stubs, and README — wired into `app/main.py` with env vars documented in `.env.example`.

## Quality checklist

- [ ] All slice files created from the templates (agent, clients, prompt, tools, schemas, routes, exceptions, constants, tests, README)
- [ ] Router wired in `backend/app/main.py` and prefix/tag set via constants
- [ ] `ANTHROPIC_API_KEY` (or chosen provider key) in `.env.example` and `config.py` Settings
- [ ] Structured logging in place (`agent.lifecycle.*`, `agent.tool.*` events)
- [ ] STACK.md checked for the active LLM provider and model name

## Handoff

**Chain:** If the agent's business logic still needs planning, invoke `/cc:plan:task` next; if a spec already exists, invoke `/cc:implement:execute` to build out the tools and logic.

**Solo:** Suggest `/cc:plan:task` to plan the real tool implementations, then `/cc:verify:run` once the slice compiles and tests exist.

**Abort rules:** If `STACK.md` shows `STATUS=not initialized` for the AI/LLM service, stop and route to `/cc:plan:setup` (or `/cc:plan:service` to add the provider) before scaffolding. If the agent's single responsibility cannot be stated in one sentence, stop and clarify scope with the user first.
