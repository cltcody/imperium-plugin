---
name: video-demo-creator
description: |
  Guides the full presales demo-video lifecycle — brief, Tell-Show-Tell script, recording
  checklist, editing, and 13-point validation across all 5 video levels; integrates Descript,
  Synthesia, goConsensus. Use on "create a demo video", "video brief", or "Synthesia script".
---

# Video Demo Creator

Guides the full lifecycle of a presales demo video — brief, script, recording prep, editing, and validation.
Every video follows the PCV Loop: **P**lanning (70% of effort) → **C**reation → **V**alidation.

Full reference: `references/Video_Recording_Best_Practice_Guide_V3.md`

---

## Connected Tools

| Tool | What it does for you |
|------|---------------------|
| **Salesforce** | Pulls confirmed pains, persona names, and deal context to personalise the script |
| **Confluence** | Saves the video brief and script to the account or product knowledge space |

No connections? Provide the persona, pain, and product context below.

---

## Step 1 — Select the video level

Choose the right level before anything else. The wrong format for the funnel stage is the most common wasted effort in demo video production.

| Level | Type | Length | Funnel stage | Use it when… |
|-------|------|--------|-------------|--------------|
| **L1** | Teaser / Overview | 60–90 sec | Top of funnel | Sparking interest — one wow moment, no full workflow |
| **L2** | Product Demo On-Demand | 3–5 min | Mid funnel | One persona, one use case for outreach or goConsensus |
| **L3** | Deep Dive Demo | 5–10 min | Mid funnel | Qualified leads who want end-to-end workflow detail |
| **L4** | Industry Use Case | 5–10 min | Evaluation | Full E2E supply chain story for one industry |
| **L5** | Live Demo / PoC Recording | 20–45 min | Bottom of funnel | Record every live session for coaching and reuse |

**The rule:** If your video runs longer than its level maximum, split it into separate videos. Longer does not mean better.

Timing formulas by level:

| Level | TELL 1 | SHOW | TELL 2 | Total |
|-------|--------|------|--------|-------|
| L1 Teaser | 15 sec | 55 sec | 20 sec | 90 sec |
| L2 Product Demo | 60 sec | 3 min | 30–60 sec | 3–5 min |
| L3 Deep Dive | 90 sec | 7–8 min | 90 sec | 5–10 min |
| L4 Industry Use Case | 60 sec | 7–8 min | 60 sec | 5–10 min |
| L5 Live Demo | 3–5 min | 30–35 min | 5 min | 20–45 min |

---

## Step 2 — Fill in the Video Brief

**Spend 70% of your time here. Most videos fail because teams skip this step.**

Fill in every field. If you cannot answer a field, the video is not ready to script yet.

```
VIDEO BRIEF

Video level:        L1 / L2 / L3 / L4 / L5
Video type:         Teaser / Product Demo / Deep Dive / Industry Use Case / Live Demo
Target persona:     [Role, seniority, industry, company size]
Top pain point:     [What keeps them up at night — 1 sentence, not a feature list]
Industry focus:     [Automotive / Pharma / Retail / Chemicals / Other: ___]
Product focus:      [Max 1–2 modules or use cases — if more, make two videos]
Hook (first 10 sec):[One question or statement that hits their pain right away]
Max length:         [60–90 sec / 3–5 min / 5–10 min]
Format:             [Avatar (Synthesia) / Human cam / Screen+Voice / Mix]
Demo share:         [Target: min 60% of runtime for demo types]
Key messages:       [Max 3 — if you need more, make two videos]
Call-to-action:     [One only: request demo / book meeting / explore more / watch next video]
Slides needed:      [Max 2–3 for videos under 5 min. No agenda slides. No company overview]
goConsensus story:  [Which story does this clip belong to? What comes before and after it?]
```

**AI prompt — generate a video brief from scratch:**

```
You are a Senior PreSales Consultant specializing in Supply Chain & Global Trade SaaS.
I want to create a video. Help me generate a structured Video Brief.

My inputs:
- Video Type: [90-Second Overview / Product Demo / Deep Dive / Industry Use Case]
- Target Persona: [e.g. VP Supply Chain, Trade Compliance Manager]
- Industry: [e.g. Automotive, Pharma, Retail]
- Primary Business Problem: [e.g. export controls, customs processing]
- Desired Length: [max 90 sec / 3-5 min / 5-10 min]
- Call-to-Action: [request demo / book meeting / explore more]

Generate a complete brief with: Hook, Tell-Show-Tell structure, Key Messages (max 3),
one objection to address mid-demo, and a value statement.
Keep language simple. Use active voice. Address the viewer as "you".
```

---

## Step 3 — Generate the hook

The first 8 seconds decide if someone watches or scrolls. Generate five options and pick the one that hits hardest.

**AI prompt — 8-second hook generator:**

```
Write 5 different opening lines (under 20 words each) for a video targeting [PERSONA] about [TOPIC].

Use these formats:
1. A contrarian statement
2. A surprising statistic
3. A direct pain call-out
4. A bold prediction
5. A "what if" question

Rate each hook from 1-10 for scroll-stop power and explain why.
```

**AI prompt — ICP pain excavator (if you need deeper hook material):**

```
You are a B2B buyer psychology expert.
My product: [describe your product in 1-2 sentences]
My Ideal Customer Profile: [role, industry, company size]

Identify the top 5 daily emotional pain points this person experiences.
Write each as an internal monologue (what they think but do not say out loud).
For each pain point, suggest a 1-sentence video hook that hits it directly.
Keep it real and specific. No corporate language.
```

---

## Step 4 — Write the script

Scripts are written in a 4-column table: Time / Visual or Action / Narration / Direction Notes.
Narration should sound like you are talking to a colleague — short sentences, active voice, "you" language.

**AI prompt — full script assembler:**

```
Use the following Video Brief and generate a complete video script.

[PASTE YOUR VIDEO BRIEF HERE]

Format the script as a table with 4 columns:
- Column 1: TIME (e.g. 0:00–0:30)
- Column 2: VISUAL / ACTION (what is visible on screen)
- Column 3: NARRATION (spoken text, natural and conversational)
- Column 4: DIRECTION NOTE (tone, pace, emphasis)

Rules:
- Follow Tell-Show-Tell strictly: TELL 1 → SHOW → TELL 2
- Demo share minimum 60% of total runtime for demo types
- No feature listing — frame every capability from the persona's view
- Keep sentences short. Use active voice. Use "you" language
- Do not start sentences with "We" — start with "You" or the outcome
- One clear CTA at the end only
```

**Script writing rules (apply to every script):**

```
TELL 1 — Set the stage
  [ ] Persona introduced within first 15 seconds
  [ ] Their challenge stated — not your product
  [ ] Max 1–2 slides (no agenda, no company intro)
  [ ] Emotional hook lands in the first 10 seconds

SHOW — Demo in action
  [ ] Fullscreen only — no split screen, no distractions
  [ ] Real user flow from persona's perspective (not admin functions)
  [ ] Narrate what the persona achieves — not what buttons they click
  [ ] Mouse moves slowly. Cursor highlight enabled
  [ ] Min 60% of total runtime for demo-type videos
  [ ] Handles 1–2 objections mid-demo (L3 and above)

TELL 2 — Value and close
  [ ] Concrete outcomes: time saved, errors reduced, risk removed
  [ ] One final slide maximum
  [ ] One CTA only — spoken and on screen must match
```

---

## Step 5 — Pre-recording checklist

Run this before hitting record. Problems found here take 5 minutes to fix. Problems found after recording take 3 hours.

```
ENVIRONMENT
  [ ] Demo sandbox or tenant prepared — never use live production data
  [ ] Full workflow rehearsed at least twice — not once
  [ ] All unnecessary applications closed
  [ ] Notifications disabled (OS-level, not just muted)
  [ ] Screen resolution set to 1920×1080
  [ ] Cursor highlight enabled

AUDIO
  [ ] External microphone connected and selected as default input
  [ ] Room is quiet — door closed, background noise tested
  [ ] Audio level tested in recording tool (no peaks, no background hum)

CAMERA (for human-cam segments)
  [ ] Camera at eye level — not looking up or down
  [ ] Lit from the front (key light 3–5 ft, 45°) — not backlit
  [ ] Real background — professional, minimal, no virtual background
  [ ] Dressed professionally — no stripes, neon, or shiny accessories

TOOL SELECTION
  [ ] TELL 1 + TELL 2: Synthesia (avatar) or human cam
  [ ] SHOW: Descript screen recording + voice
  [ ] Assembly: Import all clips into one Descript project
  [ ] Publish destination: goConsensus story confirmed
```

**Tool decision by video level:**

| Level | TELL 1 | SHOW | TELL 2 | Assembly |
|-------|--------|------|--------|----------|
| L1 Teaser | Synthesia | Descript screen | Synthesia | goConsensus |
| L2 Product Demo | Synthesia or cam | Descript screen | Synthesia or cam | goConsensus |
| L3 Deep Dive | Cam or slides | Descript screen | Cam or slides | goConsensus |
| L4 Industry Use Case | Synthesia + slides | Descript screen | Synthesia + slides | goConsensus |
| L5 Live Demo | Live (Teams/Zoom) | Live screen | Live | Internal library |

---

## Step 6 — Editing in Descript

Descript uses script-based editing: delete text from the transcript = delete that section of video.

```
EDITING WORKFLOW

1. Import all clips (avatar, screen, camera) into one Descript project
2. Script-based editing: cut from the transcript, not the timeline
3. AI actions to run:
   → "Edit for clarity" — AI removes tangents and dead air
   → "Remove filler words" — removes um, uh, basically, you know, like
   → Gap remover: set to max 0.3-second pauses
4. Add B-roll: overlay screen clips on top of presenter audio
5. Add captions/subtitles — essential for LinkedIn autoplay-on-mute
6. Simple cuts for transitions — no fancy effects

EXPORT SETTINGS
  Format:      MP4 (H.264), minimum 1080p, 16:9
  LinkedIn:    Consider 1:1 aspect ratio for feed posts
  Thumbnail:   Custom — persona image + headline text
  Captions:    Export SRT from Descript and upload separately to each channel
```

**Descript AI shortcut prompts:**
- `"Create clips"` or `"Create a highlight reel"` — scans transcript for engaging moments and cuts short clips for social
- `"Can you add some music that fits the vibe?"` — adds background music
- `"Decrease the volume"` — adjusts if music is too loud

---

## Step 7 — Script quality audit (before or after recording)

Run this AI audit before recording to catch problems early. Also useful after a first edit to tighten the final cut.

**AI prompt — conversion optimizer:**

```
You are a senior direct-response copywriter who has optimized hundreds of video scripts.

Audit the following script:
[PASTE SCRIPT HERE]

Rewrite any sentences that:
- Start with "We" (flip to viewer perspective)
- List a feature without a business benefit
- Exceed 30 spoken words in a 10-second window

Give an overall conversion score out of 10 and explain your rating.
```

**AI prompt — traffic-light quality review:**

```
Review the following video script against these criteria:
[PASTE SCRIPT HERE]

Check structure:
1. Is the persona addressed within the first 15 seconds?
2. Is Tell-Show-Tell clearly visible? Mark where SHOW begins and TELL 2 starts
3. Are there more than 3 feature mentions without a benefit statement? Flag them
4. Is the CTA clear and singular?
5. What is the demo share in %? (Target: min 60% for demo videos)

Check language:
6. Are there technical terms the target persona would not understand?
7. Is the voice active, not passive?
8. Does the narration sound conversational or like a white paper?
9. Are there vague phrases like "many features" or "various capabilities"?

Output: Traffic-light rating (GREEN / AMBER / RED) per criterion + concrete improvement suggestions.
```

---

## Step 8 — 13-point validation checklist

Run every video through this before publishing. Do not skip it.

| # | Checkpoint | Status |
|---|------------|--------|
| 1 | Video level matches the funnel stage and content plan | OK / Fix |
| 2 | Video opens within 5 seconds with a persona hook — no long intro | OK / Fix |
| 3 | Length stays under the defined maximum for this level | OK / Fix |
| 4 | TELL 1 is max 20% of total runtime | OK / Fix |
| 5 | Demo share is min 60% of total runtime (for demo types) | OK / Fix |
| 6 | Demo is fullscreen — no split screen, no distracting toolbars | OK / Fix |
| 7 | No customer data, PII, or live production data visible on screen | OK / Fix |
| 8 | Filler words and pauses longer than 0.3 seconds removed | OK / Fix |
| 9 | Captions / subtitles present | OK / Fix |
| 10 | Audio level consistent — no peaks, no background noise | OK / Fix |
| 11 | Spoken CTA and on-screen CTA match exactly | OK / Fix |
| 12 | Branding: logo, colors, font match ${user_config.company} guidelines | OK / Fix |
| 13 | Sign-off obtained from product expert and sales lead | OK / Fix |

Any Fix → resolve before publishing. A video with open Fix items is not ready.

---

## Step 9 — goConsensus publishing

Individual videos become powerful when combined into guided buyer experiences in goConsensus.

```
PUBLISHING IN GOCONSENSUS

Story structure:
  Position by: E2E Process (Plan / Source / Make / Deliver / Return)
  Then by:     Persona / Role (VP Supply Chain / Compliance Manager / Logistics Coordinator)
  Then by:     Use Case (what specific problem this video solves)

A VP Supply Chain watches the strategic overview.
A Compliance Manager dives into the details.
Same product. Different stories. One goConsensus project.

After publishing:
  [ ] Video assigned to the correct goConsensus story
  [ ] Tracking enabled — goConsensus records which videos each prospect watches
  [ ] Insights shared with AE before next call — use watch data to prepare

Tracking gives you:
  - Which videos each prospect watched
  - Watch time and engagement rate per video
  - Which topics sparked the most interest
  → Use these signals in the next discovery or follow-up call
```

---

## Quick reference

### 5 Golden Rules
1. Persona FIRST — never start with the product
2. Hook within the first 10 seconds
3. Tell-Show-Tell ALWAYS, at every level
4. Demo fullscreen, minimum 60% of runtime (for demo types)
5. ONE CTA — not two, not three

### 5 Most Common Mistakes
1. Long intro jingle or logo animation before the hook
2. Slide wall instead of live demo
3. Feature tour without business benefit ("and over here you can also see...")
4. Multiple CTAs at the end
5. Wrong video level for the funnel stage

### End-to-end timeline
| Phase | Activity | Tool |
|-------|----------|------|
| 1 | Select level. Confirm funnel stage | Content plan |
| 2 | Fill in video brief | This skill |
| 3 | Generate hook + script | AI prompts above |
| 4 | Build max 2–3 slides for TELL 1 | PowerPoint / goConsensus |
| 5 | Set up demo sandbox. Dry run ×2 | Demo environment |
| 6 | Record screen + voice (+ camera if needed) | Descript / Synthesia |
| 7 | Script-based cut. Remove fillers. Add B-roll | Descript |
| 8 | 13-point validation + AI quality review | Step 8 checklist above |
| 9 | Export MP4 1080p + SRT captions + thumbnail | Descript export |
| 10 | Publish to goConsensus / LinkedIn / website | goConsensus + channels |
| 11 | Track views, watch time, CTA clicks | goConsensus analytics |

**A simple L2 video (3–5 min) can be completed in 2–3 days. A deep dive in one week maximum.**

---

## Tools

| Tool | Purpose | Access |
|------|---------|--------|
| **Descript** | Screen recording, script-based editing, AI filler removal, export | https://descript.cello.so/ukNKAhow9fy |
| **goConsensus** | Publish videos, build guided buyer stories, track engagement | https://app.goconsensus.com/ |
| **Synthesia** | AI avatar videos for TELL 1 and TELL 2 segments | https://app.synthesia.io/ |

---

## Quality checklist

- [ ] Video brief is complete before any script is written
- [ ] Persona is named and their pain is stated in one sentence
- [ ] Script follows Tell-Show-Tell — structure is visible in the timing table
- [ ] Demo share is confirmed at ≥ 60% of runtime (for demo types)
- [ ] Hook lands in the first 10 seconds
- [ ] One CTA only — spoken and on-screen versions match
- [ ] All 13 validation checkpoints are OK before publishing
- [ ] goConsensus story placement confirmed — this video has a position in the buyer journey
