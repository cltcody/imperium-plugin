# Vue adapter

Token-consuming Vue components. They wrap the shared `.ds-*` classes from
`../vanilla/components.css`, so the look matches every other adapter and rebranding happens
through `--ds-*` tokens — not per-component styles.

## Setup
```js
// once, at your app root (e.g. main.js)
import "../path/to/design-system/tokens/tokens.css";
import "../path/to/design-system/ui-kits/vanilla/components.css";
```

## Use
```vue
<DsButton variant="primary">Save</DsButton>
<DsBadge tone="success">Matched</DsBadge>
<DsCard title="Summary"><DsStat label="Revenue" value="$48.2k" /></DsCard>
<DsAlert tone="error">Could not connect.</DsAlert>
```

## Notes
- `Components.vue` documents the set and gives a copy-paste SFC for each component (split them
  into `DsButton.vue`, `DsBadge.vue`, etc. in a real app).
- These are **reference** components, not a published package.
- Dark mode: set `data-theme="dark"` on a parent; tokens re-resolve automatically.
