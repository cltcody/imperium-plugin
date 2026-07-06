# Confidence Tagging Standard — Industry Solutions

Every claim in any customer-facing or internal presales output must carry a confidence tag.
This standard applies to: account briefs, discovery summaries, demo scripts, OSDs, battlecards, ROI cases, handover docs, and stakeholder maps.

---

## The Three Tags

| Tag | Meaning | When to use |
|-----|---------|-------------|
| 🟢 **Confirmed** | Sourced directly from a reliable source | Annual report, sustainability report, exec quote, signed contract, CRM field confirmed by the customer, internal data supplied by the user |
| 🟡 **Inferred** | Reasoned from context, industry norms, or indirect signals | Pattern matches industry norm + company profile; logical implication of confirmed data; consistent with multiple indirect signals |
| 🔴 **Unknown** | Not findable or not yet confirmed | Data gap; must be stated explicitly so it can be filled |

---

## Source Attribution Format

After each tagged claim, cite the source inline:

```
🟢 Confirmed — Annual Report FY2024, p. 12
🟢 Confirmed — CRM (Salesforce, updated 2026-05-14)
🟢 Confirmed — Internal (Johannes Hangl, June 2026)
🟡 Inferred — logistics-sector norm; consistent with company's EU-heavy footprint
🔴 Unknown — named 3PL partners not disclosed publicly
```

Never present inferred data as confirmed.
Never fabricate volumes, metrics, or percentages.
The gap list (🔴 items) is as valuable as the confirmed data — it drives the next conversation.

---

## Applying Tags in Practice

### Account brief
Tag every firmographic claim, every trade-footprint assertion, every signal.

```
Revenue: ~$4.2B (FY2025 est.) 🟡 Inferred — analyst consensus; not confirmed in public filing
Customs volume: 180k+ import entries/year 🔴 Unknown — not disclosed; estimate based on SKU count × country footprint
ERP: SAP S/4HANA 🟢 Confirmed — LinkedIn job posts, 2025
```

### Discovery summary
Tag each customer statement by how it was captured.

```
Pain: "Our classification team spends 3 days on each new product launch" 🟢 Confirmed — stated by trade compliance director on 2026-05-21 call
Impact: ~$2M annual exposure in misclassification duties 🟡 Inferred — based on stated volume × average tariff rate; not customer-confirmed
```

### OSD / solution claims
Tag every capability assertion and every assumption.

```
[PRODUCT_A] will reduce classification cycle time by 80–90% 🟡 Inferred — based on [COMPANY] reference customer results; not yet validated against this customer's current state
Integration with SAP S/4HANA via standard API connector 🟢 Confirmed — [COMPANY] product documentation, March 2025
Go-live in Q3 2026 🔴 Unknown — depends on customer IT resource availability; not agreed
```

### ROI / business case
Label each value driver as hard (directly measurable) or soft (qualitative), and tag confidence.

```
Duty savings: $1.2M/year 🟡 Inferred — hard value; based on stated import volume × 0.8% avg tariff rate × 15% error rate reduction; customer has not confirmed error rate
Manual effort reduction: 4 FTE equivalent 🟡 Inferred — soft value; based on stated team size of 6 × 65% time on manual classification; customer has not confirmed
```

---

## What NOT to do

- ❌ Present a 🟡 inferred figure as a definite fact in a customer slide
- ❌ Leave claims untagged in any draft sent for review
- ❌ Use round numbers without flagging they are estimates (e.g., "$1M in savings" → tag it)
- ❌ Omit the 🔴 gap list to make the output look more complete

---

## When the user supplies internal data mid-conversation

If the user provides confirmed internal data (e.g., "actually their classification team is 8 people, not 6"), treat it as 🟢 Confirmed with internal attribution and update the output immediately:
```
Classification team: 8 FTE 🟢 Confirmed — Internal (call with trade compliance director, 2026-06-02)
```
Move the corresponding item from 🔴 Unknown to 🟢 Confirmed in the gap list.
