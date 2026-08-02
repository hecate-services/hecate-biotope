# Pre-registration: world 15

**Written before world 15 was built.** Corrects register entries **D.2** and
**H.1**, and targets **G.4**. World 14 is superseded, not edited.

## Why there is a world 15

**Every creature currently occupies both trophic levels at once, for free.**

It absorbs energy that has gathered in the ground, and it also consumes anything
smaller that it meets, with no organ, no cost and no decision. `D.2` has been
open since world 4 and calls this a free good; `H.1`, added this week, says the
same thing from the other side and adds the half `D.2` misses.

Raf's correction is what made the size of this clear. There are no plants: world
2 deleted them. So a mouthless creature is not a herbivore, it is an **absorber**,
and **this world has exactly two trophic levels available and no more**, because
there is nothing to graze that is not alive. That is why `from_creatures_pct` sits
between 4 and 21 and never climbs. Splitting the two levels is the first genuine
niche this world could have.

## The single change

**A mouth is tissue, and eating is a decision.**

- **`mouth` is a heritable integer**, drawn at founding from zero upward and
  drifting like `uptake`. **Zero is a legitimate creature** and is the null this
  is measured against, exactly as a sensorless body is.
- **It is charged as plain tissue**: `carrying(structure + mouth + apparatus)`.
  Muscle and gut, not neural tissue, so it does not pay `neural_cost`.
- **`eat` becomes the fourth purpose**, alongside `move`, `breed` and `grow`,
  read once per tick as a threshold like `breed` rather than per candidate cell
  like `move`.
- **A creature consumes another only if `mouth > 0` and its brain said so.** In a
  cell, rank by structure as now; the strongest that both **can** and **chooses
  to** is the consumer. If none can or will, **nothing is eaten and everyone
  lives.**
- **What it takes is bounded by `min(mouth, remaining capacity, what is there)`**,
  the way `uptake` bounds what it takes from the ground. So mouth size is what it
  buys.

**NO NEW ECONOMY CONSTANT.** The upkeep uses the expression that already prices a
frame, the mutation reuses `uptake_mutation`, which the register already calls a
drift scale for heritable integers rather than a property of feeding, and the
founding distribution is a starting condition of the same kind as
`FOUNDER_MAX_SENSORS`. **Nothing caps the mouth**, because upkeep grows linearly
with it while income is bounded by the cell, so it is self-limiting in the same
way structure is.

### Why the tradeoff needs nothing designed into it

This is the part worth being explicit about, because a designed tradeoff would be
bias and this one is arithmetic.

**A mouth pays only where there is enough prey to cover its upkeep.** On a board
carrying 23 creatures over 1,261 cells it cannot possibly pay. On one carrying
221 it might. So **being common is what makes mouths pay**, which makes being
common costly, and that is negative frequency dependence falling out of the same
expression that prices a body. **`G.4`** has asked for a stabilising mechanism
since the section was written and has never had one that was not spatial.

### And scavenging stays free

Everything that dies returns its energy to the cell it died on, so carrion is
ground energy and is absorbed through `uptake`. **A mouth is therefore the price
of killing, not the price of eating**, and detritivory remains available to
anything. That is not a design choice, it is what `E.1` already does, and it is
worth naming so nobody reads a null on mouths as a null on carnivory.

## What would count as a finding

1. **A trophic split appears and both sides persist.** The share of creatures
   carrying `mouth > 0` settles somewhere strictly between none and all. **This
   is the target**, it is the first niche differentiation in fifteen worlds, and
   either extreme is the null.
2. **Mouths track density.** Across seeds, the prevalence of mouths rises with
   population. That is the frequency-dependence claim and the one that speaks to
   **G.4**.
3. **Perception moves, and specifically the `creatures` field.** If consumption
   is a decision, knowing what is beside you is worth more than it was. Reported
   per field, because a rise spread evenly over all four would mean something
   else.
4. **Hidden nodes rise.** "Am I bigger than that" is `self` multiplied by
   `creatures`, and `self` reads identically for every candidate cell so it
   cancels exactly in a linear comparison. This is the first decision in this
   world whose answer depends on your state relative to another's, which is
   precisely what a hidden node is for. **Reported at the control price of 330**,
   against the 0.27 world 14 gives at 2,000 ticks.

## What will NOT happen, stated in advance

**Extinctions will probably rise.** Removing a free good cost survival in worlds
10, 11 and 14, and this removes the largest one left. That is the price of honest
books rather than a fault.

**`lineages` will be 1**, and it is no longer the interesting number. **F_ST is
reported instead**, and the prediction is that it does **not** fall: a mouth
should not dissolve the spatial structure world 14 built.

**No `flee` output and no `fight` output.** Naming the behaviour is world 1's
`hunt` again. `move` exists, and flight is available the moment declining to be
eaten is possible.

**The world is still perfectly constant.** **A.4**, **G.3** and **G.5** stand: no
day, no season, no weather, every source of chance still genetic.

**And the most likely outcome is still nothing.** Fifteen worlds have produced no
lasting niche differentiation. The two ways this fails are symmetric and both are
plausible: **everyone grows a mouth**, because the rent is small against what a
kill is worth, or **nobody does**, because prey is never dense enough. Either
would say this world supports one way of living and only one.

**The strongest available negative** is the first of those. A mouth that everyone
carries is a free good with extra steps, and it would mean the tradeoff I claim
is arithmetic is not there at all.

## The commitments

1. Rules frozen before the first run, not changed in response to it. This file is
   superseded, not edited.
2. Every seed reported, including **nothing happened**, and including the dead.
3. `world:ruleset/0` says 15 in the same commit as the rules, and there is a test
   that fails if it does not.
4. **F_ST reported beside `lineages`**, since phase 0 showed the two answer
   different questions and only one of them can rise.
5. The four new tests go red against world 14's physics before they are believed.
6. **This is the first world where a group-level effect could exist**, because a
   lump that collectively over-consumes destroys the patch it lives on. Nothing
   here tests that and nothing here should be read as testing it. It is named so
   that it is not later claimed to have been predicted.
