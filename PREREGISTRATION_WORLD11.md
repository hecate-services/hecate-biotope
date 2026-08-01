# Pre-registration: world 11

> **SUPERSEDED** by [PREREGISTRATION.md](PREREGISTRATION.md). The criteria as
> frozen before world 11 ran, kept whole and unedited. Scored in
> [RESULTS_WORLD11.md](RESULTS_WORLD11.md).

**Written before world 11 was built.** Corrects register entry **B.8**. World 10
is superseded, not edited:
[PREREGISTRATION_WORLD10.md](PREREGISTRATION_WORLD10.md) and its
[results](RESULTS_WORLD10.md) stand as the record of a different world.

Thermodynamics at the classical scale still governs. See world 7's file for the
four laws applied one at a time; nothing here changes any of them.

## Why there is a world 11

`resolve/2` was wrong in two ways, both invisible inside it and visible only
across it. That is now the third time: **C.6** was the movement fare, **B.7** was
capacity applied at one feeding site and not the other, and this is **B.8**,
found by the audit in [AUDIT_ENERGY_PATHS.md](AUDIT_ENERGY_PATHS.md).

**Only the winner ate.** `absorb` was called for the strongest creature in a
cell and for nobody else. Anything that tied with it survived the contest and
then did not feed at all, so sharing a cell with an equal cost a creature its
entire meal. No rule anywhere says that.

**And the winner ate twice.** World 8 bounds grazing by `min(uptake, frame)` and
world 10 bounds meat by the same expression, applied **independently in the same
tick**. A creature that made a kill therefore took its body's worth of meat and
then its body's worth of ground. The stated law is that a creature cannot take
in more than its body allows; what was implemented is that it cannot take more
than its body allows **from any one source**.

World 10 handed that a second mouthful without noticing. The carrion a predator
cannot finish is buried on its own cell inside `devour`, and the grazing ran
immediately afterwards on that same cell.

## The single change

**Feeding is a property of a creature, not of a contest, and it is bounded
once.**

Every creature the contest leaves alive feeds, from what is left where it
stands, up to `min(uptake, frame)` counting meat and ground **together**.
Strongest first, which is the order the contest has already established.

**No new constant.** The bound is the expression that was already at both sites.

### What this does not do

Who dies is unchanged. The contest still goes to the largest structure and every
weaker creature in the cell still loses.

It does not touch **C.2**, where everything moves exactly one cell per tick, and
that is deliberate: the next world is about speed and it is a much larger change
than this one.

## What would count as a finding

Stated in advance.

1. **Density rises.** More creatures feed each tick than before, since a tie no
   longer costs a whole meal, so the same ground supports more.
2. **`from_creatures_pct` falls further**, from world 10's 21%. A kill no longer
   buys a second helping from the ground, so the return on predation drops
   again.
3. **Being large stops paying twice.** Largest frame and largest store fall
   again, as they did in world 10 and for the same reason one step further on.

## What will NOT happen, stated in advance

**This will not touch the monoculture.** Every seed still collapses to one
founding line, because nothing here adds a way for two strategies to coexist.
**G.1** is untouched and the register says why: what is missing is
recombination, spatial structure, frequency dependence or variation in time, and
this is none of them.

**Perception will not move.** Nothing here changes what a sensor costs or gives
a creature anything new to decide.

**And extinctions may rise.** Feeding is strictly more bounded than it was, so
the world is poorer per creature. World 10 already lost a seed at 2,000 ticks
relative to world 9 for the same reason, and if that continues it is the price
of the books being right rather than a fault.

## The commitments

1. Rules frozen before the first run, not changed in response to it.
2. Reported across every seed and every efficiency, including **nothing
   happened**.
3. A further change is world 12. This file is superseded, not edited.
4. Worlds 1 to 10 are retired and may not be quoted alongside this.
5. **The engine is reported beside the population**, `lineages`, `depth` and the
   uptake spread.
6. **The register audit continues.** This world came out of it rather than out
   of an experiment, which is now four in a row, and the question that found it
   is the same one every time: does this law hold at every site, or only where
   it was introduced?
