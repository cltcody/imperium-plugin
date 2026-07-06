# Brand Setup Guide

> **Easiest path: run `/cc:setup:brand`.** It walks you through adding your logo and
> confirming colors and fonts, and does the file work for you — no need to copy files or
> edit JSON by hand. The steps below are the manual reference for anyone who'd rather do it
> directly or wants to understand what the command sets up.

## Overview

The brand registry lives in `skills/brand/brands/`. Each subdirectory represents one company brand. Skills that produce documents, slides, or styled output (docx-generator, pptx-generator, content-service, etc.) resolve a brand entry at runtime and apply its colors, fonts, logos, and tone rules automatically.

A `template/` directory ships with the toolkit as the canonical starting point and as the fallback when no company brand is configured.

---

## Step 1: Copy the Template

```bash
cp -r skills/brand/brands/template/ skills/brand/brands/<your-company>/
```

Replace `<your-company>` with a lowercase, hyphen-separated identifier that matches how you will reference the brand in skill configuration (e.g., `acme-corp`, `northstar`, `internal`).

---

## Step 2: Fill in brand.json

Open `skills/brand/brands/<your-company>/brand.json` and populate every field.

| Field | Type | Description |
|---|---|---|
| `company_name` | string | Full legal or display name of the company. Used in document headers, footers, and generated cover pages. |
| `primary_color` | string (hex) | Brand primary color, e.g. `"#1A73E8"`. Applied to headings, hyperlinks, and table headers in generated documents and slides. |
| `accent_color` | string (hex) | Secondary highlight color, e.g. `"#F4B400"`. Used for callout boxes, badges, and decorative rules. |
| `background_color` | string (hex) | Page or slide background color, e.g. `"#FFFFFF"`. Applied to slide backgrounds and document page color when generating from scratch. |
| `font_family` | string | Primary typeface name, e.g. `"Inter"`, `"Lato"`, `"Helvetica Neue"`. Defaults to `"Inter"` if omitted. Must be available in the runtime environment or embedded in the template file. |
| `font_weights` | array of numbers | Font weights to load or embed, e.g. `[400, 600, 700]`. Include every weight used across headings, body, and captions. |
| `logo_dark` | string (path) | Relative path to the logo file intended for dark backgrounds (white or light-colored mark), e.g. `"assets/logo-dark.svg"`. Accepts SVG or PNG. |
| `logo_light` | string (path) | Relative path to the logo file intended for light backgrounds (dark-colored mark), e.g. `"assets/logo-light.png"`. Accepts SVG or PNG. |
| `docx_template` | string (path) or null | Relative path to an existing `.docx` file that carries your letterhead, styles, and footer. When provided, docx-generator inserts content into this template. Set to `null` to have the skill generate a branded document from scratch using the color and font fields above. |
| `pptx_template` | string (path) or null | Relative path to an existing `.pptx` file that carries your slide master and layouts. When provided, pptx-generator uses these layouts. Set to `null` to generate a master from scratch. |
| `tone_rules` | array of strings | Writing style directives applied by content-generating skills, e.g. `["Use active voice.", "Avoid jargon.", "Keep sentences under 25 words."]`. |
| `sign_off` | string | Standard closing phrase appended to proposals and formal emails, e.g. `"Warm regards,"` or `"Best,"`. |

Example `brand.json`:

```json
{
  "company_name": "Acme Corp",
  "primary_color": "#003087",
  "accent_color": "#FF6B00",
  "background_color": "#FFFFFF",
  "font_family": "Inter",
  "font_weights": [400, 600, 700],
  "logo_dark": "assets/logo-dark.svg",
  "logo_light": "assets/logo-light.png",
  "docx_template": "assets/letterhead.docx",
  "pptx_template": null,
  "tone_rules": [
    "Use active voice.",
    "Lead with the customer benefit.",
    "Avoid acronyms unless previously defined."
  ],
  "sign_off": "Best regards,"
}
```

---

## Step 3: Add Logo Assets

Place logo files in the `assets/` subdirectory inside your brand folder:

```
skills/brand/brands/<your-company>/
  brand.json
  assets/
    logo-dark.svg      # white/light mark for dark backgrounds
    logo-light.png     # dark mark for light backgrounds
    letterhead.docx    # optional — existing Word template
```

Accepted formats: SVG (preferred for scalability) and PNG (minimum 300 dpi for print quality). Do not use JPEG for logos — transparency is lost.

The paths in `logo_dark` and `logo_light` inside `brand.json` must be relative to the brand directory root (not the repo root).

---

## Step 4: Configure docx-generator and pptx-generator

Point each skill at your brand entry by setting the `brand` key in the skill's configuration or by passing it at invocation time.

In your project or global skill config (`.claude/skills.json` or equivalent):

```json
{
  "docx-generator": {
    "brand": "acme-corp"
  },
  "pptx-generator": {
    "brand": "acme-corp"
  }
}
```

The value must match the directory name you created under `skills/brand/brands/`.

If you invoke the skill directly, you can override the brand at call time:

```
/docx-generator brand=acme-corp
/pptx-generator brand=acme-corp
```

---

## Default Behavior

When no brand is configured — either because the `brand` key is absent from skill config or because the named directory does not exist — skills fall back to `skills/brand/brands/template/`. The template brand uses neutral colors, Inter font, and placeholder logo paths.

In interactive sessions, skills that detect a missing brand will prompt the user to provide a company name and primary color before proceeding. The collected values are used for that run only and are not saved. To make values permanent, complete Steps 1-4 above.
