# Brand profiles

A **profile** decides voice, audience, topics, house rules, hashtags, footer, and where facts
come from. Every draft runs under exactly one. Two ship by default — `personal` and `company` —
and you can add your own (template at the bottom). Load the selected profile's block before
drafting; on any conflict, the profile block wins over the generic mode rules.

The `company` profile is **config-driven**: its identity fields come from `cc.config.json`
(`[COMPANY]`, `[COMPANY_PRODUCT]`, products, brand). Fill those once via `/cc:setup:configure`
and this profile speaks in your company's terms automatically.

| Profile | What it is | Stance | Grounding source |
|---------|-----------|--------|------------------|
| `personal` | You writing as yourself — no brand, no product | **Personal** — no pitch, no hashtags, no body links; reach-optimized own voice | your **real experience** + `references/voice-and-tone.md` |
| `company` | `[COMPANY]` / `[COMPANY_PRODUCT]` thought leadership & launch content | **Branded** — may name the product, features, and make an honest CTA | product facts you supply (docs, discovery, value/demo skills) |

The profiles deliberately differ in **stance**: `personal` carries no brand at all (own voice, no
hashtags/footer, no links in the post body); `company` is allowed to name the product and call to
action, but never with unfounded outcome promises. The quality gate adapts per profile.

---

## Profile: `personal`

- **Role:** you, a practitioner sharing earned insight.
- **Audience:** your peers and network — people who'd know if you were faking it.
- **Topics:** whatever you actually have a view on from real work.
- **Voice:** your own idiolect (sample it — see `references/voice-and-tone.md` and Step 2.5 of
  the skill). Direct, specific, one defensible opinion per piece.
- **Stance:** **no pitch.** Share because it's worth saying. No product placement.
- **Hashtags:** **none.**
- **Footer:** **none.**
- **Links:** **none in the post body** — any URL goes in a first comment after engagement builds.
- **Banned:** the universal AI-tell list (quality gate) + any engagement-bait CTA.

## Profile: `company`

- **Role:** a credible voice for `[COMPANY]` — expert, not a billboard.
- **Audience:** the buyers, users, and practitioners in `[COMPANY]`'s market.
- **Topics:** `[COMPANY_PRODUCT]` and the problems it solves; category insight; launches; customer
  outcomes (anonymised unless cleared).
- **Voice:** confident, specific, no hype. Follows the brand tone from `cc.config.json`
  (`[BRAND_FONT]` etc. inform written collateral, not post voice).
- **Stance:** **branded** — may name `[COMPANY]` / `[COMPANY_PRODUCT]`, describe real features, and
  make one honest CTA. **No unfounded outcome promises** ("guaranteed", "cure", "10x overnight").
- **Hashtags:** 4–6 from your company set (define below when you set the profile up).
- **Footer:** `[COMPANY] — <tagline / link>` (publish-ready articles only; see quality gate).
- **Grounding:** real product facts you supply. Never fabricate features, metrics, or customer
  quotes — if you don't have the fact, ask or flag it as unverified.
- **Banned:** the universal list + any competitor-disparagement + claims legal hasn't cleared.

---

## Add your own profile (template)

Copy this block, name it, and fill it in. Keep the same fields so the mode rules and quality
gate compose with it cleanly.

```
## Profile: `<name>`
- **Role:** <who is speaking>
- **Audience:** <who it's for>
- **Topics:** <what it covers>
- **Voice:** <tone, sentence habits, English variant, sample source>
- **Stance:** <promote vs educate vs personal — and what's allowed/banned>
- **Hashtags:** <the set, or none>
- **Footer:** <the footer, or none>
- **Grounding:** <where facts come from; how to handle missing facts>
- **Banned:** <words/patterns/claims to never use>
```
