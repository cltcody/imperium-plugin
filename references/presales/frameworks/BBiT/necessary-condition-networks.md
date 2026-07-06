# Necessary Condition Networks (NCN): Turning a Plan Into a Network

## What It Is

A Necessary Condition Network (NCN) is a planning tool. It maps the steps of a plan as a network of prerequisites, not a flat list.

The name says it all: it's a **network** of **necessary conditions**. It shows which steps depend on which, so you know exactly where you can start and what order things must follow.

It uses prerequisite logic (also called necessity logic): "In order to do this, I must first have that."

Example: getting ready for work. Some order matters (shower before getting dressed, get up before showering). Some doesn't (feeding the dog can happen anywhere). An NCN makes those real dependencies clear and stops you treating habits as fixed rules.

Two core rules:
- **Prerequisite arrows only.** An arrow means one step is genuinely required before another. Not "I prefer to do it first."
- **Done statements, not actions.** Word each step as the finished effect ("the dog is fed"), not the action ("feed the dog"). An action can be done without the effect landing.

## Why It Matters

A task list has flaws an NCN fixes:
- **Lists hide the start point.** You often can only begin in a few places, but the list doesn't show that, so you try to start somewhere and get stuck.
- **Lists focus on actions.** You can do work that wasn't needed, or tick off an action and think you're done when the real effect never landed. An NCN asks "what does done look like?" for each step. If a step isn't a prerequisite for anything else, you don't need it.

NCNs work at any level of detail, from a quick weekly plan to a full change project. For advanced use, look into Critical Chain Project Management.

## What You Should Do

### Step 1: Build the simple NCN (work right to left)

1. **Put the goal on the far right.** This is the final effect everything feeds into. If a step doesn't tie into the goal, ask why you feel you must do it. It may not be needed, or the goal needs reframing.
2. **Work backwards.** For each step, ask: what effects are needed to achieve the effect to its right?
3. **Place each entity.** For every step, decide: is it a prerequisite of something (goes left of it), a post-requisite (goes right), or a separate stream entirely?
4. **Word everything as done statements.** Even action-heavy steps. "I have submitted my mortgage application," or better, "the bank has confirmed receipt of my application."

You'll end up with several chains. Some run in parallel; some cross over where one chain's effect is needed by another. There's no fixed shape. It might be a few clean chains or a spiderweb.

**Check it left to right**, one link at a time:
- "In order to have B, I must first have A."
- If you can actually get B without A, the dependency is wrong. Remove it.

This check often reveals steps you didn't need, so you reach the goal with less effort.

Tip: have one or two people draft the rough NCN, then let others adjust. A whole group squabbling over placement is a nightmare.

### Step 2: Resourcing

Add who is responsible for each effect. Colour coding works well (one colour per person, team, or skill set).

Decide your resource categories first. A simple plan might use three teams; a detailed one might split skill sets within each. This lets you see at a glance who delivers what, even on a plan with no fixed timeline.

### Step 3: Levelling

Levelling organises the order you intend to actually work in. The arrows stay reserved for true prerequisites, so practical sequencing lives in how you position the entities.

A resource might be free to start five things but can't do all five at once. So shift entities left or right into the order you'll do them, and spread out overlaps where one resource has too much at once.

Aim for **no overlaps** as a starting point (one effect per resource at a time). It's lower risk and makes priorities clear. But it's a guideline, not a hard rule. Overlaps make sense when a category has several people, or when a step has long elapsed time but little touch time (you wait on a third party and work on something else meanwhile).

### Step 4: Scaling

Scaling adds a time scale when the timeframe matters.

- **Use elapsed time, not touch time.** Elapsed time is from when a step becomes available to when it's complete. An 8-hour task takes two weeks if you only get an hour a day. A 20-minute review still takes days if the reviewer is slow to get to it. (Eating one apple takes minutes; eating 100 takes far more than 100 times as long.)
- **Estimate with a range.** People underestimate. Ask "how long if it goes well?" and "how long if it goes badly?" under normal conditions, then take the midpoint. Three to five days becomes four. Don't chase false precision.
- **Set a scale and size the boxes.** One grid space = one unit of time. A three-day step fills three spaces.
- **Close the gaps.** In a scaled NCN, a gap is wasted time. Push entities so each one starts right as its prerequisite finishes. That gives you the fastest possible timeline.
- **Then add reality back.** Revisit levelling. Add gaps for resource contention or outside commitments (a team pulled onto another project for a week pushes its chains back a week).

Levelling and scaling are iterative. Resource first, then scale, then come back and re-level. Changes to one affect the other.

## Common Errors

**Time-sequence arrows.** Adding an arrow because you'll do A then B, when really either could go first. That's a preference, not a prerequisite. It creates false blockers and kills flexibility. Sequencing preferences belong in levelling, not in the arrows.

**Touch-time scaling.** Sizing a step by active work time, ignoring wait time. This makes the timeline unrealistically short, only achievable if everything goes perfectly and is top priority. Always use elapsed time.

**Optimistic scaling.** Underestimating by picturing the best case. This is why projects get delayed. Use the range method (best case, worst case, midpoint) instead.

---

## Quick Reference

| Step | What you do |
|---|---|
| 1. Build | Goal on the right, work left adding prerequisite effects |
| 2. Resource | Colour-code who is responsible for each effect |
| 3. Level | Shift entities into the order you'll actually work, spread overlaps |
| 4. Scale | Size boxes by elapsed time, close gaps, then add real-world gaps back |
| Plan vs. execute | Plan right to left; execute left to right |
| Two core rules | Prerequisite arrows only; everything worded as done statements |
| Estimating | Best case + worst case, take the midpoint |
