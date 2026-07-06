---
description: Guided brand setup — add your logo, colors, and fonts through a conversation; no file editing required
argument-hint: "[optional: path to a logo file or folder]"
---

# Setup: Brand Assets

Set up the visual side of the plugin — logo, colors, fonts, and optional letterhead/slide
templates — entirely through conversation. **You do the talking; this command does the file
work.** Never ask the user to edit JSON, run scripts, or move files themselves — offer to do
each step for them, confirm, and verify it worked.

Tone: warm, concrete, one thing at a time. Assume the user just wants their company's look
applied and doesn't want to think about where files go.

## Steps

### 1 — Find the plugin source

The brand lives in the plugin **source** (the `global/` directory), not the installed copy.
Locate it: if the current directory is the plugin source, use it; otherwise run
`claude plugin marketplace list` and read the `imperium` marketplace's `Source:
Directory (...)` path. If you still can't find it, ask the user: "Where did you save the
Command Center plugin folder?" — accept a path. Set `<ROOT>` to that directory.

The brand registry is `<ROOT>/skills/brand/brands/<BRAND>/` (default `<BRAND>` = `template`).

### 2 — Greet and read what's already set

Read the active config (`<ROOT>/cc.config.local.json` if it exists, else the `cc.config.json`
template) `brand.*` and `<ROOT>/skills/brand/brands/<BRAND>/brand.json`.
Tell the user, in plain language, what's already configured and what's missing — e.g.:
"Your colors are set (navy + blue), font is Inter, but there's no logo yet. Want to add one?"

### 3 — Logo (the main manual step)

Ask: "Do you have a logo file? You can give me the file path, drop it in a folder and tell
me where, or say 'skip for now.'" Accept `$ARGUMENTS` if a path was already provided.

When the user points you at a file (or folder):
- Confirm the file exists and is a supported format (`.svg`, `.png` preferred; `.jpg` ok).
- **Copy it for them** into `<ROOT>/skills/brand/brands/<BRAND>/assets/` with a clear name
  (`logo-dark.<ext>` for logos that sit on light backgrounds; `logo-light.<ext>` for logos
  on dark backgrounds). Don't move the original — copy it.
- If they have both a light and dark version, place both. If only one, place it as
  `logo-dark` and note that a light-background variant can be added later.
- Update `brand.json` `logo_dark` / `logo_light` to the new relative paths.
- Confirm: "Added your logo at `assets/logo-dark.svg` and pointed the config at it. ✅"

If the user has no logo, leave the template placeholder and reassure them they can run
`/cc:setup:brand` again any time to add one.

### 4 — Colors, font, sign-off (confirm or adjust)

Read the current `brand.*` values and show them simply ("Heading color: navy `#1A2B5C`").
Ask if they want to change any. Accept plain answers ("make the accent a brighter blue" →
pick a sensible hex and confirm it). For each change, **write it to `cc.config.local.json`**
`brand.*` yourself (the gitignored override — create it from `cc.config.json` if absent; never
edit the tracked template). Keep it light — most users will keep the defaults.

### 5 — Optional: letterhead / slide templates

Ask once: "Do you have a Word letterhead or PowerPoint template you want documents to match?
(Optional.)" If yes, copy the file into the brand assets folder and set `brand.json`
`docx_template` / `pptx_template` to its path. If no, the generators build from scratch using
your colors and font — totally fine.

### 6 — Apply and publish (do it for them)

- Run `bash <ROOT>/scripts/cc-apply.sh --apply` to push config values into the skills/commands.
- Run `bash <ROOT>/scripts/cc-publish.sh --skip-config` to make the updated brand live in the
  installed plugin (then `/reload-plugins` or restart picks it up).
Report both in one friendly line — don't show raw script noise unless something failed.

### 7 — Verify and reassure

Confirm the brand profile is complete: `brand.json` has colors, font, and at least one logo
path that points to a file that actually exists. Report a short checklist:

```
Brand setup ✓
  Company:  Acme Corp
  Colors:   #1A2B5C heading · #2E6FE0 accent
  Font:     Inter
  Logo:     assets/logo-dark.svg ✅  (light variant: not set — optional)
  Templates: none (generated from scratch)
Live now — reload Claude Code to see it. Run /cc:setup:brand again anytime to change things.
```

If anything is still missing, say exactly what and offer to handle it now — never leave the
user with a manual to-do.

## Notes

- This is fully re-runnable. To **rebrand later** (new logo, new colors), just run it again;
  to change the company *name* or products, run `/cc:setup:configure`. Both re-apply safely.
- Logos and templates are binary files the config can't generate — placing them is the one
  thing that needs a real file, which is why this command exists: to do it for the user.
