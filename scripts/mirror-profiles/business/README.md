# Command Center — Business Edition (cc-business)

A curated toolkit for client-facing teams — professional services, product marketing,
and customer support — built for **claude.ai chat and Cowork**. It ships the document,
presentation, communication, and decision-support skills from the full Command Center
plugin, without the developer and presales tooling that needs a code repository or an
SC role.

## Install

```
/plugin marketplace add <owner>/<business-mirror-repo>
/plugin install cc-business@imperium-business
```

On install you'll be prompted for a few identity values (company name, etc.) — these
personalize the skills' output. No other setup is required.

## What's included

See [`INVENTORY.md`](INVENTORY.md) for the full catalog. The short version:

| You want to… | Reach for |
|---|---|
| Build a branded deck or Word doc | `pptx-generator` · `docx-generator` |
| Draw a diagram or map a customer's supply chain | `diagram` · `supply-chain-map` |
| Write or polish customer-facing text | `field-comms-writer` · `humanize` |
| Turn meeting notes into actions + follow-up | `meeting-notes-structurer` |
| Prep for a hard conversation | `negotiation-prep` (before) · `tactical-empathy-coach` (live) · `exec-briefing-prep` |
| Write an SOP / runbook / escalation procedure | `sop-creator` |
| Plan a workshop or multi-day EBC | `workshop-agenda-builder` |
| Pressure-test a plan or claim | `grill-me` · `confidence-tagger` · `toc-bbit-expert` |
| Compare against a competitor | `competitive-battlecard` |
| Create LinkedIn content | `linkedin-post` |

Skills trigger by **description** — just say what you want ("turn these notes into a
follow-up email"). If one doesn't trigger, ask for it by name ("use the sop-creator
skill"). The `find` and `guide` entries in the plugin menu route you when unsure.

## Scope notes

- This is a **variant** of the full Command Center plugin: same versions, same release
  train, smaller catalog. If you also work in a code repository with Claude Code and
  want the developer workflow, ask the plugin owner about the full `cc` plugin.
- Some entries visible in Claude Code (grouped `/cc:*` commands) don't apply on chat
  surfaces; everything in `INVENTORY.md` here is chat-ready.
