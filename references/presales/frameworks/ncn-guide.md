# Necessary Condition Networks (NCN)

An NCN is a planning tool. It maps the **order** things must happen in, using **outcomes** instead of actions.

This guide covers the theory, how to build one, and the two most common mistakes.

---

## What it is

An NCN is a network of necessary conditions. It shows the dependencies between steps.

It answers two questions:

- What must be done before I can start the next thing?
- What does "done" look like for each step?

You read and build it differently:

- **Plan it right to left.** Start with the goal, then ask what comes before.
- **Execute it left to right.** Work through it in order.

You can use it for a quick day plan or a full project plan. For advanced use, look into Critical Chain Project Management.

---

## Why it matters

Most people default to task lists. Lists have three flaws an NCN fixes.

- **No clear start point.** A long list feels overwhelming, and you do not know where to begin. An NCN shows you the few places you can actually start.
- **Wrong order.** Lists ignore sequence. You start things you cannot finish because a prerequisite is missing. An NCN makes the order obvious.
- **Action focus.** Lists tell you to *do* a step. You can finish the action and still not deliver the result. An NCN focuses on the effect, so you always check: *did the needed state actually happen?*

There is one more benefit. Because every step must lead to the goal, an NCN exposes work you do not need. If a step is not a prerequisite for anything else, you do not need it.

---

## What you should do

### Build a simple NCN

A simple NCN brings order to any goal. You only need the advanced steps if you plan to run it as a structured project.

**Step 1: Start with the goal.**
Put your final outcome on the far right. Every other step must help reach it. If a step does not tie in, ask why you feel you must do it. It may not be needed, or you may need to reframe the goal.

**Step 2: Work right to left.**
For each effect, ask: *What effects are needed before this one?* Add them to the left with an arrow pointing right.

You will end up with several chains:

- **Independent chains** can be worked on in parallel.
- **Dependent chains** need an effect from another chain first.

There is no fixed shape. Some NCNs are a few clean chains. Others look like a spiderweb.

**Step 3: Place any effects you already know.**
If you already have a list of effects, take them one at a time. For each, ask: is it a prerequisite for something, a post-requisite of something, or its own separate stream?

**Step 4: Check it left to right.**
Read each link one at a time, using one of these:

1. "I must first have A before I can have B."
2. "In order to have B, I must first have A."

If you can reach B without A, the link is wrong. This check often reveals steps you can drop.

> **Tip:** Have one or two people draft the rough plan. Then let others review and move things. If everyone tries to plan it at once, it becomes a fight.

---

### Add resources and level it

These two steps add detail and make the plan easier to follow.

**Resourcing: who is responsible**

Decide who owns each effect. Use color coding for a quick visual.

- Keep it high level. You want the person, team, or group responsible for the effect, not every individual doing the work.
- Pick resource categories that match the detail you need. Example: development team, product team, quality team.
- This is useful even if you never run the NCN as a timed project. At a glance you see who owns what.

**Levelling: the order you will work in**

The arrows only show true prerequisites. But in real life, a resource cannot work on everything at once. Levelling sorts out the practical order.

- Shift entities left or right into the sequence you plan to do them.
- Look for overlaps where one resource has too many effects at the same time, then spread them out.
- One step may not require another, but doing it first might give useful context or make the next step easier. That is a levelling choice, not a prerequisite.

**About overlaps**

Aim for no overlaps as a start. One resource, one effect at a time. It is lower risk and makes priorities clear.

But overlaps are fine when they make sense:

- A resource category has several people, so they handle several effects at once.
- An effect has long elapsed time but short touch time. You can wait on a third party and work on something else meanwhile.

So "no overlaps" is a guideline, not a hard rule.

---

### Scale it (add time)

Use scaling when the time frame matters, or when you just want a rough idea of how long the plan takes.

**Always use elapsed time, not touch time.**

- **Touch time** is how long the work takes to physically do.
- **Elapsed time** is how long from starting to finishing, including waiting.

Example: eating one apple takes a couple of minutes. Eating 100 apples takes far more than 200 minutes because of everything in between. An eight-hour task can take two weeks if you only get an hour a day on it.

**Estimate with a range.**

People underestimate, from optimism or pressure. So do not ask for one number.

- Ask: how long if things go well? How long if they go badly (normal bad, not the once-ever disaster)?
- Take the midpoint. A three-to-five day estimate becomes four days.
- Do not chase false accuracy. Close is good enough.

**How to scale.**

1. Pick a unit of time: hours, days, weeks, whatever fits.
2. Set a grid where one space equals one unit.
3. Resize each entity box to match its elapsed time. A three-day effect spans three grid spaces.
4. Close the gaps. In a scaled NCN, a gap is wasted time. Push each entity hard against the end of the one before it.

This gives you the fastest possible timeline. Then add reality:

- Recheck your levelling now that time is visible.
- Add gaps where a resource is overloaded.
- Add gaps for outside commitments. If a team is pulled into another project for a week, several chains slip a week.

You now have a resourced, levelled, and scaled NCN you can run a project from.

---

## Core requirements

These two rules keep an NCN accurate.

**1. Prerequisite arrows only**

Only add an arrow where one entity is truly needed before another.

- Do not turn preferences or efficiency choices into arrows. That creates false prerequisites, confusion, and lost flexibility. People think they cannot start a step when they actually can.
- Put timing preferences into entity *positioning* on the levelled or scaled NCN, not into the arrows. This keeps it clear which links are real and which are just practical sequencing.

**2. Done statements**

Word every entity as a done statement: what it looks like when complete, not what you plan to do.

- This keeps the focus on the effect. People will not call something finished just because they did an action.
- Each entity only exists because the next one needs it. So a real state must be reached before you move on.

Even action-heavy steps get worded as outcomes:

- Action: "Submit the mortgage application."
- Better: "I have submitted my application to the bank."
- Best: "The bank has confirmed receipt of my mortgage application."

Until that confirmation, you have not really handed over to the next step, so it is not done.

---

## Common errors

**Time-sequence dependency arrows**

You think "A, then B, then C" out of habit, then draw arrows for it. But if A and B could be done in either order, there should be no arrow between them. Only link true prerequisites.

**Touch-time scaling error**

Scaling by active work time gives an unrealistic plan. Most steps have wait time. A colleague's review may take 20 minutes of work but a few days to actually happen. Scale by elapsed time, or your timeline only works if everything goes perfectly.

**Optimistic scaling error**

People underestimate. They picture the best case and ignore normal disruptions. That is why projects get delayed. Use the range method: best case, worst case, take the midpoint.

---

## Quick recap

- **NCN** = a network of outcomes ordered by what must happen first.
- **Build** right to left from the goal. **Check** left to right.
- **Resource** it (who owns each effect), then **level** it (the order you will work).
- **Scale** it with elapsed time and range estimates.
- **Two rules:** prerequisite arrows only, and word everything as a done statement.
