---
description: Generate tailored SPIN/MEDDIC/BANT discovery questions by persona and product
argument-hint: [persona] [product] [framework]
disable-model-invocation: true
---

Generate a sequenced discovery question set.

- Persona: $0
- Product(s): $1
- Framework: $2 (default: SPIN if not specified)

Run the **discovery** skill with these parameters and produce the full question set.

Focus on problem and implication questions — minimise situation questions (≤3).
Tag hypotheses: 🟡 Inferred unless from prior discovery notes.
Output as a printable call-prep question card.
