# MCP Tool Setup

## Overview

Some skills in Command Center use MCP (Model Context Protocol) tools for external integrations.
When an MCP is connected, skills pull data automatically and push updates back to the source system.
When an MCP is not connected, skills prompt you to paste the relevant context manually instead.

This document lists which skills need which MCP servers.

---

## Skills by MCP Requirement

### No MCP Required

These skills are pure-prompt and work without any external integrations:

- `account-intelligence`
- `brand`
- `competitive-battlecard` *(Salesforce optional — see below)*
- `confidence-tagger`
- `demo-dryrun-coach`
- `demo-storyboard`
- `design-system`
- `diagram`
- `docx-generator`
- `gdpr-check`
- `grill-me`
- `handoff`
- `linkedin-post`
- `osd-architect`
- `pptx-generator`
- `rulecheck`
- `save-task-list`
- `security-audit`
- `skill-creator`
- `sop-creator`
- `supply-chain-map`
- `tactical-empathy-coach`
- `toc-bbit-expert`
- `workshop-agenda-builder`
- `write-a-skill`

**Commands:** `/cc:radar:scan`, `/cc:radar:impact`, `/cc:radar:brief` — these read the
regulatory-sources reference and the codebase directly (WebFetch/WebSearch, grep), no MCP
needed. (`/cc:account:exposure` has an optional MCP slot — see below.)

---

### Salesforce MCP

Skills that use Salesforce to pull deal data, opportunity records, contact history, and activity logs:

| Skill | What Salesforce provides |
|---|---|
| `business-case-stress-tester` | Deal size, account tier, prior ROI discussions |
| `champion-health` | Champion contact record, activity log, opportunity history |
| `competitive-battlecard` | Prior wins/losses against competitor in similar accounts |
| `critical-business-issue-finder` | Prior call notes and activity history |
| `discovery` | Existing account data before the call |
| `exec-briefing-prep` | Account tier, opportunity stage, exec contact record, activity history |
| `field-comms-writer` | Account name, key contacts, deal stage |
| `integration-complexity` | Discovery notes and systems mentioned in opportunity/account records |
| `meeting-notes-structurer` | Updates opportunity record with key findings and MEDDPICC changes |
| `negotiation-prep` | Deal value, prior discount history, current opportunity stage |
| `presales-coach` | Deal context for coaching output and Salesforce update tasks |
| `pricing-positioning` | Confirmed value drivers from discovery and the opportunity record |
| `rfx-navigator` | Prior responses for this account |
| `video-demo-creator` | Confirmed pains, persona names, deal context |
| `win-loss-analyzer` | Full deal history, stage progression, activity log, close data |

**Setup:**

Add the Salesforce MCP server to Claude Code. The recommended server is the official Salesforce MCP or a community wrapper around the Salesforce REST/Bulk API. Add it with `claude mcp add` (or interactively via `/mcp`), or put it in a project `.mcp.json` under `"mcpServers"`:

```json
{
  "mcpServers": {
    "salesforce": {
      "command": "npx",
      "args": ["-y", "@your-org/salesforce-mcp"],
      "env": {
        "SF_INSTANCE_URL": "https://yourorg.salesforce.com",
        "SF_ACCESS_TOKEN": "your-token"
      }
    }
  }
}
```

---

### Confluence MCP

Skills that use Confluence to read prior research or save outputs to team libraries:

| Skill | What Confluence provides |
|---|---|
| `business-case-stress-tester` | Prior approved ROI benchmarks and reference metrics |
| `champion-health` | Saves assessment to the deal folder for the full account team |
| `critical-business-issue-finder` | Prior account research brief or discovery documentation |
| `exec-briefing-prep` | Account research and prior engagement notes |
| `field-comms-writer` | Saves a copy of the email/message to the deal folder |
| `integration-complexity` | Prior integration patterns for this ERP or WMS version |
| `meeting-notes-structurer` | Saves structured summary to the deal folder |
| `rfx-navigator` | Prior RFx responses for this account |
| `video-demo-creator` | Prior deal documentation for personalising the script |
| `win-loss-analyzer` | Saves debrief to the team win/loss library |

**Setup:**

Add the Confluence MCP server via `claude mcp add` / `/mcp`, or in `.mcp.json`:

```json
{
  "mcpServers": {
    "confluence": {
      "command": "npx",
      "args": ["-y", "@your-org/confluence-mcp"],
      "env": {
        "CONFLUENCE_BASE_URL": "https://yourorg.atlassian.net/wiki",
        "CONFLUENCE_TOKEN": "your-api-token"
      }
    }
  }
}
```

---

### Microsoft 365 / SharePoint MCP

Skills that use SharePoint or Microsoft 365 to pull account documents:

| Skill | What SharePoint provides |
|---|---|
| `discovery` | Account-related documents and prior engagement materials |

**Setup:**

Add the Microsoft 365 MCP server via `claude mcp add` / `/mcp`, or in `.mcp.json`. Use the Microsoft Graph API-backed server:

```json
{
  "mcpServers": {
    "microsoft365": {
      "command": "npx",
      "args": ["-y", "@your-org/m365-mcp"],
      "env": {
        "AZURE_TENANT_ID": "your-tenant-id",
        "AZURE_CLIENT_ID": "your-client-id",
        "AZURE_CLIENT_SECRET": "your-client-secret"
      }
    }
  }
}
```

---

### GitHub MCP / `gh` CLI

Skills that interact with GitHub repositories, issues, or pull requests:

| Skill | What GitHub provides |
|---|---|
| `triage` | Read and label issues by type, effort, priority, and area |
| `piv-orchestrator` | Lists open PRs; dispatches the `triage` skill against GitHub issues |
| `archon` | Implements solutions for GitHub issues; supports webhook-driven automation |
| `ship-pr` | PR autopilot — creates the PR, watches CI, drives it to merge |
| `security-audit` | Checks GitHub Actions permissions, `pull_request_target` misuse, secrets exposure |

These skills use the `gh` CLI (GitHub CLI) rather than an MCP server. Install it with:

```bash
brew install gh
gh auth login
```

If your org uses the GitHub MCP server for richer programmatic access, add it via `/mcp` as well.

---

### Optional: Trade-data source

`/cc:account:exposure` (the tariff/regulatory exposure brief) can use a connected
**commercial trade-data source** — the class of provider that sells shipment-level
import/export records aggregated from customs manifests (bill-of-lading data) — to sharpen
its evidence beyond what's publicly filed.

**No standard MCP server exists for this class of provider today.** The entry below is a
*convention* for wiring one in if you already have a subscription and either the vendor
ships an MCP server or you build a thin wrapper around their API. It names the class of
provider, not any specific one — this plugin endorses none.

| Command | What a trade-data source would add |
|---|---|
| `/cc:account:exposure` | Shipment-level import/export records for the account's lanes — sharper, 🟢-tier evidence where records exist, in place of inferring exposure from public filings alone |

**Setup (if you have one):** add it like any other server — `claude mcp add` / `/mcp`, or in
`.mcp.json`:

```json
{
  "mcpServers": {
    "trade-data": {
      "command": "npx",
      "args": ["-y", "@your-org/trade-data-mcp"],
      "env": {
        "TRADE_DATA_API_KEY": "your-api-key"
      }
    }
  }
}
```

`trade-data` is a placeholder server name — use whatever your provider's server (or your own
wrapper) is actually called.

**Degrades gracefully:** `/cc:account:exposure` and `/cc:radar:brief` work **fully** on
public sources without this — filings, annual reports, news, and regulator lists, with every
claim 🟢🟡🔴 confidence-tagged per the exposure-analysis framework. A connected trade-data
source improves evidence quality; it never gates either command.

---

## Installing MCPs

Use Claude Code's built-in `/mcp` command to add, remove, or inspect MCP servers interactively, or the `claude mcp add` CLI (`--scope user` to make a server available in every project).

For manual configuration, add entries under `"mcpServers"` in a project-root `.mcp.json` (checked in — the way to share a server config with your team) or in your user-level config via `claude mcp add`. Claude Code picks up changes on the next session start.

**None of these servers are required.** Every skill degrades gracefully — without the MCP it prompts you to paste the relevant context instead. Set up only what you actually use.

See the [Claude Code MCP documentation](https://docs.anthropic.com/en/docs/claude-code/mcp) for the full reference.
