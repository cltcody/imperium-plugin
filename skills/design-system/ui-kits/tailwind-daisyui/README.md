# Tailwind / DaisyUI adapter

Themes a Tailwind + DaisyUI project with the neutral `--ds-*` tokens. The mapping
(`--ds-*` → DaisyUI roles) follows Plan 0 §B.

## Two ways to wire it

### A — Build-time (has a `tailwind.config.js`)
```js
// tailwind.config.js
const { dsTheme, dsThemeDark } = require("./theme.js");
module.exports = {
  content: ["./**/*.{html,js,jsx,ts,tsx,vue}"],
  plugins: [require("daisyui")],
  daisyui: { themes: [{ ds: dsTheme }, { "ds-dark": dsThemeDark }] },
};
```
Then set `data-theme="ds"` (or `ds-dark`) on `<html>`.

### B — No-build / CDN (Tailwind + DaisyUI loaded from a CDN)
Add a `[data-theme="ds"]` CSS block that points DaisyUI's color vars at your token
values (see `demo.html`). This is the path a server-rendered app (e.g. Django templates)
uses. To rebrand, change only the four brand values (`--p`, `--s`/`--a`, `--b1`).

## Token → DaisyUI mapping

| `--ds-*` | DaisyUI | Role |
|----------|---------|------|
| `--ds-color-primary` / `-primary-fg` | `--p` / `--pc` | brand action |
| `--ds-color-accent` | `--s` / `--a` | secondary / accent |
| `--ds-color-bg` | `--b2` (page) | canvas |
| `--ds-color-surface` / `-surface-2` | `--b1` / `--b3` | panels |
| `--ds-color-fg` | `--bc` | text |
| `--ds-color-success/warning/error/info` | `--su/--wa/--er/--in` | semantic |
| `--ds-radius-lg/md/pill` | `--rounded-box/-btn/-badge` | shape |

## Coverage
The DaisyUI classes used in `demo.html` cover the Tier-1/2 checklist: `btn` (+ variants/
sizes), `badge`, `card`, `stat`/`stats`, `table`, `tabs`, `input`/`select`/`toggle`,
`loading`, `alert`. This is the adapter validated on a real app in Plan 0 Gate 3.
