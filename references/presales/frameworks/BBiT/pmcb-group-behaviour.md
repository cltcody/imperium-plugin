# PMCB: Understanding and Changing Group Behaviour

## What It Is

PMCB explains why whole groups of people behave the way they do. It stands for **Policies, Measures, Consequences, Behaviours**, and they form a chain:

- **Policy** drives the **Measure**.
- The **Measure** drives the **Consequences**.
- The **Consequences** drive the **Behaviour**.

For individuals, consequences drive behaviour (that's the ABC tool). A group is just individuals, so the same applies. But for a group to act the same way, the same consequences must be applied consistently. That consistency comes from a policy. A policy sets how things should be; a measure tracks whether it's happening; consequences get applied based on the measure; and that drives the group's behaviour.

"Tell me how I'll be measured, and I'll tell you how I'll act." That's the whole chain in one line.

### PMCB vs. ABC

ABC zooms in on one individual and manipulates specific consequences and behaviours. PMCB is wider and less detailed. Policies apply to many people, and consequences are more generic (warnings, termination, bonuses, promotions). They're complementary: PMCB handles maybe 90% of group cases, and ABC can sharpen your PMCB by making the consequences more effective, or handle behaviours not tied to any policy.

## Why It Matters

You use PMCB in two situations:

- **To cause change.** Changing a policy, measure, or consequence is an efficient, leveraged way to shift a whole group, without the problems of poorly thought-out changes.
- **To clear obstacles.** A PMCB can block the behaviour you want or drive a counterproductive one. You need to spot it before you can fix it.

If a whole group does the same thing, there's almost certainly a chain causing it. Just asking them to do something else means fighting that chain over and over. Better to understand it and change the chain itself.

## The Four Parts

### Policies

A policy is a rule or guideline that sets how people should act or what to aim for. Three types:
- **Formal:** written and communicated. Laws, employment terms, quality standards.
- **Informal:** known and accepted but never officially endorsed. "That's just the way we do things here."
- **Internal:** rules you set for yourself based on your values (going vegan, recycling).

The category usually doesn't matter in practice, but it helps you spot them. A **bad policy** is one that encourages behaviour you don't want, blocks behaviour you do want, or is simply irrelevant and lingering. Often the intent was good but the implementation had unintended effects (an open-communication policy that causes constant interruptions; a "whole team must agree" rule where one holdout stalls a project).

### Measures

A measure is what you track, record, or just pay attention to, to see whether the policy is being followed. Without a measure, a policy gets forgotten: no feedback, no way to apply consequences, no way to get caught.

Measures can be formal and objective (sales, defect rate) or informal and subjective (a manager noticing who tends to arrive late). Internal policies have measures too (mentally tracking how often you get takeout).

A **good measure**:
- Relates well to the policy and drives the right behaviour.
- Is free of loopholes, so you can't score well without actually delivering.
- Is visible, so people know it exists and what it tracks.
- Doesn't conflict with another measure. Conflicting measures (cut costs *and* raise quality) set people up to fail, and they give up.

### Consequences

Consequences are what happen to people when they do the behaviour, and they're the actual driver. (See the ABC module for depth.) In PMCB they're harder to look at in isolation, because one policy and measure can have many small consequences applied by many people. So for analysis, policies and measures are usually the more useful levers, but the consequences must exist or no behaviour occurs.

**Effective consequences:**
- People **care** about them. Irrelevant consequences do nothing.
- They **scale** to the measure and policy. Big stakes need strong consequences. People work harder to avoid being fired than a slap on the wrist.
- They're **aligned** with the measure: better score, better outcome.
- They're **consistent**. Haphazard application makes people relaxed.
- They're **clear and visible**, so people understand what they are.

Watch for **natural or internal consequences** too (wanting to impress others, enjoying a type of work). These exist outside your setup and can help or fight your policy. If the policy and measure make sense but the behaviour still isn't happening, the consequences are missing or ineffective.

## What You Should Do: Changing an Existing Behaviour

We usually jump to adding new consequences (reward or punishment) without asking why the behaviour exists. Often existing policies, measures, and consequences are causing it, and will keep fighting your change unless you address them.

**Work backwards from the behaviour:**
1. Identify the behaviour you don't want.
2. Find the consequences driving it.
3. Find the measure those consequences are based on.
4. Find the policy behind that measure.

It's not strict. Sometimes the policy or measure is the easiest to spot first; fill in the gaps. A simple table (Policy, Measure, Consequence, Behaviour) works fine; you don't need a full causal branch.

Often the fix isn't removing the policy but **fixing the broken link**, usually the measure.

### Worked example

A remote IT worker writes a script to keep his chat status "online," because he gets in trouble for looking away.
- **Policy:** people should be available during the workday. (Reasonable.)
- **Measure:** last active status in the company chat. (The weak link.)
- **Consequence:** trouble if not active.
- **Behaviour:** faking online status.

The policy is fine. Swap the measure to **responsiveness to messages**. Same consequences, but now the behaviour is people actually responding when needed. Shift one measure and the vast majority of a large group moves to a more productive behaviour.

You don't need a perfect measure. Getting 99% of people to a better behaviour is a huge win.

Another example: a salesperson gives out discounts too freely because the policy is "close as many leads as fast as possible," measured by conversion rate and lead time, rewarded by commission. Don't just punish it; align the PMCB. Change the measure to "leads converted with less than a 10% discount," possibly adding margin as a factor.

## PMCB and Druids

You can add PMCBs to a druid to give detail to the **loopback** (the long arrow from goal violation back to the opposing behaviour), which often feels like a big jump in logic.

A goal violation at the top of a druid is usually a **policy not being met**. The chain reads:
- If we hit a goal violation, then we give **more focus to the policy**.
- More focus on the policy means **more attention to the measure**.
- More attention to the measure means **consequences applied more rigorously**.
- More rigorous consequences mean **people do the behaviour more**.

This explains why opposite sides of a druid have opposing measures: they're usually enforced by **different departments** with different focuses (finance vs. customer service). That's how behaviour gets pushed back and forth.

Adding PMCBs also helps when resolving druids. Sometimes a simple **policy change** removes a cause, instead of needing a full injection. Sometimes a policy is itself an obstacle to an injection and must change first.

---

## Quick Reference

| Part | What it is |
|---|---|
| Policy | The rule or guideline (formal, informal, or internal) |
| Measure | How you track whether the policy is followed |
| Consequence | What happens to people based on the measure |
| Behaviour | What the group actually does |

| To change a group behaviour | |
|---|---|
| 1 | Identify the unwanted behaviour |
| 2 | Find the consequences driving it |
| 3 | Find the measure behind them |
| 4 | Find the policy behind the measure |
| Fix | Align or fix the broken link (often the measure), don't just add punishment |

| Tool choice | |
|---|---|
| ABC | One individual, detailed, specific consequences |
| PMCB | Whole group, wider, policy-level levers |
