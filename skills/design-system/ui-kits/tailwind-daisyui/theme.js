// ============================================================================
// Design System — Tailwind/DaisyUI theme adapter
// Maps the neutral --ds-* tokens to a DaisyUI theme. Two ways to use it:
//
//  A) BUILD-TIME (tailwind.config.js): spread `dsTheme` into daisyui.themes.
//     module.exports = { plugins: [require('daisyui')],
//       daisyui: { themes: [{ ds: require('./theme.js').dsTheme }] } }
//
//  B) NO-BUILD / CDN: use the [data-theme="ds"] CSS block in demo.html instead
//     (DaisyUI reads its color vars from CSS; see that file).
//
// To rebrand: change the four brand values (primary/accent + base) — everything
// else is neutral. These mirror the light defaults in ../../tokens/tokens.css.
// ============================================================================

const dsTheme = {
  // Brand
  "primary": "#2563eb",
  "primary-content": "#ffffff",
  "secondary": "#0ea5e9",
  "secondary-content": "#ffffff",
  "accent": "#0ea5e9",
  "accent-content": "#ffffff",

  // Neutral surfaces / text
  "neutral": "#1f2733",
  "neutral-content": "#ffffff",
  "base-100": "#ffffff",
  "base-200": "#f8fafc",
  "base-300": "#f1f5f9",
  "base-content": "#0f172a",

  // Semantic
  "info": "#2563eb",
  "success": "#16a34a",
  "warning": "#d97706",
  "error": "#dc2626",

  // Shape (DaisyUI sizing vars)
  "--rounded-box": "12px",   // cards     → --ds-radius-lg
  "--rounded-btn": "8px",    // controls  → --ds-radius-md
  "--rounded-badge": "9999px", // chips   → --ds-radius-pill
  "--animation-btn": "0.2s",
  "--border-btn": "1px",
};

// Optional dark variant — mirrors [data-theme="dark"] in tokens.css.
const dsThemeDark = {
  "primary": "#3b82f6",
  "primary-content": "#0b1220",
  "secondary": "#38bdf8",
  "accent": "#38bdf8",
  "neutral": "#1f2733",
  "neutral-content": "#e6edf3",
  "base-100": "#0d1117",
  "base-200": "#161b22",
  "base-300": "#1f2733",
  "base-content": "#e6edf3",
  "info": "#60a5fa",
  "success": "#22c55e",
  "warning": "#f59e0b",
  "error": "#f87171",
  "--rounded-box": "12px",
  "--rounded-btn": "8px",
  "--rounded-badge": "9999px",
};

if (typeof module !== "undefined") { module.exports = { dsTheme, dsThemeDark }; }
