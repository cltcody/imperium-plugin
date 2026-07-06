// ============================================================================
// Design System — React adapter
// Token-consuming components. Import the tokens once at your app root:
//   import "<design-system>/tokens/tokens.css";
// These components style themselves only via the --ds-* CSS variables, so a
// brand change (or [data-theme="dark"] on a parent) propagates automatically.
// No build tooling is assumed beyond a normal JSX pipeline.
// ============================================================================

import React from "react";

const v = (name) => `var(--ds-${name})`;

export function Button({ variant = "default", size = "md", children, ...props }) {
  const base = {
    display: "inline-flex", alignItems: "center", justifyContent: "center", gap: v("space-2"),
    fontSize: size === "sm" ? v("text-xs") : v("text-sm"),
    fontWeight: v("weight-semibold"), lineHeight: 1, cursor: "pointer",
    padding: size === "sm" ? `${v("space-1")} ${v("space-3")}` : `${v("space-2")} ${v("space-4")}`,
    borderRadius: v("radius-md"), border: `1px solid ${v("color-border")}`,
    background: v("color-surface-2"), color: v("color-fg"),
    transition: `background ${v("duration-fast")} ${v("ease")}`,
  };
  const variants = {
    default: {},
    primary: { background: v("color-primary"), borderColor: v("color-primary"), color: v("color-primary-fg") },
    accent:  { background: v("color-accent"), borderColor: v("color-accent"), color: v("color-on-semantic") },
    success: { background: v("color-success"), borderColor: v("color-success"), color: v("color-on-semantic") },
    error:   { background: v("color-error"), borderColor: v("color-error"), color: v("color-on-semantic") },
    outline: { background: "transparent", borderColor: v("color-primary"), color: v("color-primary") },
    ghost:   { background: "transparent", borderColor: "transparent" },
  };
  return <button style={{ ...base, ...variants[variant] }} {...props}>{children}</button>;
}

export function Badge({ tone = "neutral", children }) {
  const tones = {
    neutral: { background: v("color-surface-2"), color: v("color-fg") },
    primary: { background: v("color-primary"), color: v("color-primary-fg") },
    success: { background: v("color-success"), color: v("color-on-semantic") },
    warning: { background: v("color-warning"), color: v("color-on-semantic") },
    error:   { background: v("color-error"), color: v("color-on-semantic") },
  };
  return (
    <span style={{ display: "inline-flex", alignItems: "center", padding: `2px ${v("space-2")}`,
      borderRadius: v("radius-pill"), fontSize: v("text-xs"), fontWeight: v("weight-semibold"),
      ...tones[tone] }}>{children}</span>
  );
}

export function Card({ title, children }) {
  return (
    <div style={{ background: v("color-surface"), border: `1px solid ${v("color-border")}`,
      borderRadius: v("radius-lg"), boxShadow: v("shadow-1"), overflow: "hidden" }}>
      <div style={{ padding: v("space-5") }}>
        {title && <h3 style={{ margin: `0 0 ${v("space-2")}`, fontSize: v("text-lg"), fontWeight: v("weight-semibold") }}>{title}</h3>}
        {children}
      </div>
    </div>
  );
}

export function Stat({ label, value }) {
  return (
    <div style={{ background: v("color-surface"), border: `1px solid ${v("color-border")}`,
      borderRadius: v("radius-md"), boxShadow: v("shadow-1"), padding: `${v("space-3")} ${v("space-4")}`, minWidth: 120 }}>
      <div style={{ fontSize: v("text-xs"), color: v("color-fg-muted"), textTransform: "uppercase", letterSpacing: "0.04em" }}>{label}</div>
      <div style={{ fontSize: v("text-2xl"), fontWeight: v("weight-bold"), lineHeight: v("leading-tight"), marginTop: v("space-1") }}>{value}</div>
    </div>
  );
}

export function Input(props) {
  return <input style={{ width: "100%", fontSize: v("text-sm"), color: v("color-fg"),
    background: v("color-bg"), border: `1px solid ${v("color-border")}`, borderRadius: v("radius-md"),
    padding: `${v("space-2")} ${v("space-3")}` }} {...props} />;
}

export function Alert({ tone = "success", children }) {
  return <div style={{ padding: `${v("space-3")} ${v("space-4")}`, borderRadius: v("radius-md"),
    border: `1px solid ${v(`color-${tone}`)}`, fontSize: v("text-sm") }}>{children}</div>;
}

export function Spinner({ sm }) {
  const s = sm ? "0.875rem" : "1.25rem";
  return <span style={{ display: "inline-block", width: s, height: s, border: `2px solid ${v("color-border")}`,
    borderTopColor: v("color-primary"), borderRadius: "50%", animation: "ds-spin 0.7s linear infinite" }} />;
}
// Add `@keyframes ds-spin { to { transform: rotate(360deg); } }` once (it ships in tokens.css's kit, or add globally).
