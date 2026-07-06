# React adapter

Token-consuming React components. They read the same `--ds-*` CSS variables as every other
adapter, so branding and dark mode are inherited — no props needed.

## Setup
```jsx
// once, at your app root
import "../path/to/design-system/tokens/tokens.css";
import { Button, Badge, Card, Stat, Input, Alert, Spinner } from "./Components.jsx";
```

## Use
```jsx
<Button variant="primary">Save</Button>
<Badge tone="success">Matched</Badge>
<Card title="Summary"><Stat label="Revenue" value="$48.2k" /></Card>
<Alert tone="error">Could not connect.</Alert>
```

## Notes
- These are **reference** components (one file), not a published package — copy them into your
  app and extend. They prove the token layer drives React cleanly.
- Dark mode: set `data-theme="dark"` on a parent (e.g. `<html>`); components re-read the
  tokens automatically.
- The spinner uses a `ds-spin` keyframe — it ships with the vanilla kit; if you only use
  React, add the keyframe once globally.
