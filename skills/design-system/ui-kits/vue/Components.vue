<!-- ===========================================================================
  Design System — Vue adapter (single-file reference components)
  Token-consuming components. Import the tokens once at your app root:
    import "<design-system>/tokens/tokens.css";
  Styling is entirely via the --ds-* CSS variables, so a brand change or
  [data-theme="dark"] on a parent propagates automatically. No build tooling
  beyond a normal Vue SFC pipeline is assumed.

  Usage:
    <DsButton variant="primary">Save</DsButton>
    <DsBadge tone="success">Matched</DsBadge>
    <DsCard title="Summary"><DsStat label="Revenue" value="$48.2k" /></DsCard>
============================================================================ -->
<script setup>
defineProps({
  // shared
  as: { type: String, default: "button" },
});
</script>

<template>
  <!-- This file documents the component set; each block below is a standalone SFC
       you can split into its own file. They share the .ds-* classes from
       ../vanilla/components.css, so the Vue layer is a thin wrapper over tokens. -->
  <div class="ds-vue-reference">
    <!-- Button -->
    <!-- <DsButton variant>: default|primary|accent|success|error|outline|ghost  -->
    <button :class="['ds-btn', variant && `ds-btn--${variant}`, size && `ds-btn--${size}`]">
      <slot />
    </button>
  </div>
</template>

<!--
  RECOMMENDED SPLIT (one SFC each), all importing ../vanilla/components.css:

  DsButton.vue
    <script setup>defineProps({ variant: String, size: String });</script>
    <template><button :class="['ds-btn', variant && `ds-btn--${variant}`, size && `ds-btn--${size}`]"><slot/></button></template>

  DsBadge.vue
    <script setup>defineProps({ tone: String });</script>
    <template><span :class="['ds-badge', tone && `ds-badge--${tone}`]"><slot/></span></template>

  DsCard.vue
    <script setup>defineProps({ title: String });</script>
    <template><div class="ds-card"><div class="ds-card__body"><h3 v-if="title" class="ds-card__title">{{ title }}</h3><slot/></div></div></template>

  DsStat.vue
    <script setup>defineProps({ label: String, value: [String, Number] });</script>
    <template><div class="ds-stat"><div class="ds-stat__label">{{ label }}</div><div class="ds-stat__value">{{ value }}</div></div></template>

  DsAlert.vue
    <script setup>defineProps({ tone: { type: String, default: 'success' } });</script>
    <template><div :class="['ds-alert', `ds-alert--${tone}`]"><slot/></div></template>

  Import the stylesheet once at the app root:
    import "../path/to/design-system/ui-kits/vanilla/components.css";
    import "../path/to/design-system/tokens/tokens.css";
-->

<style scoped>
/* Components import ../vanilla/components.css globally; no per-SFC styles needed —
   that keeps a single source of truth for the look across all adapters. */
</style>
