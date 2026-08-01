# Pre-registration: world 4

> **SUPERSEDED** by [PREREGISTRATION.md](PREREGISTRATION.md). Kept whole and
> unedited. Its results are in [RESULTS_WORLD4.md](RESULTS_WORLD4.md): the first
> positive of the project, and a negative whose cause is what world 5 acts on.

**Written before world 4 was built.** World 3 is superseded, not edited:
[PREREGISTRATION_WORLD3.md](PREREGISTRATION_WORLD3.md) and its
[results](RESULTS_WORLD3.md) stand as the record of a different world.

## Why there is a world 4

World 3 made the ground's recovery depend on its standing stock, and **changed
nothing**: `still%` was 100 in seven seeds of eight, exactly as world 2.

Its own negative said why, and said it precisely. **A stayer absorbs everything
every tick, so its cell holds zero stock forever**, so there is never anything for
a stock-dependent rule to act on. Its income is exactly the bare floor. That one
quantity then sets both halves of the original proof: sessility is viable when the
floor beats metabolism, so equilibrium density exceeds one creature per cell, so
every cell is stripped every tick, **so nothing anywhere ever holds stock and the
mechanism never fires in a populated world at all**.

**Total absorption is the culprit, not the growth curve.** Any stock-dependent
rule degenerates to its floor when every cell is emptied every tick.

## The single change

**A creature absorbs at most `uptake` per tick, and `uptake` is heritable.**

    taken = min(uptake, stock in the cell)

That is the whole of world 4. Nothing else changes: not the growth curve, not the
brain, not the sensors, not reproduction, not the death deposit, not the disc.

### Why heritable rather than a constant

A fixed rate would decide the answer globally. Whether it sits above or below
what a cell can sustainably yield decides, for everybody at once and by my hand,
whether staying put works. That is the steering this project exists to avoid.

Made heritable, both livings are reachable and neither is given:

- a lineage that feeds **slowly enough** holds its cell at a standing stock and
  can draw on it indefinitely, so staying pays
- a lineage that feeds **faster than the ground can recover** strips its cell to
  nothing, its income collapses to the bare floor, and it must move or starve

**Overgrazing becomes possible, and fatal to the creature that does it.** That is
what makes staying dangerous for the first time in four worlds.

### Why this is a capacity and not a rule

`breed_at` was deleted in world 2 for being a hand-written behaviour with a
parameter bolted on: *breed when energy exceeds X*. `uptake` is not that shape. It
is a bodily capacity, like a sensor's range, and it says nothing about when or
whether to do anything. Nothing reads it but the arithmetic of absorption.

### What it should break

The step world 3 could not touch. A stayer's income is no longer pinned to the
bare-ground floor: it becomes whatever its own feeding rate lets the cell sustain.
So the quantity that decides sessile viability and the quantity that sets
equilibrium density come apart for the first time, and the Marginal Value Theorem
finally has a depletion curve within a patch to act on.

**It may still not be enough**, and the honest prior is that it might not: I have
now predicted twice that a mechanism would break this trap and been wrong twice.

## What may set a constant

Unchanged. A number may be chosen for **viability** or for **scale**, and **never
because of what evolves in it**.

`uptake` itself is a trait and has no value to derive. Two things are set:

- **the founding range** is `0` to `ground_ceiling`, which is derived rather than
  chosen: more than a full cell holds cannot be taken from it, so the range is
  the physically meaningful one and nothing narrower was picked.
- **`uptake_mutation`** is a scale constant of the same kind as `brain_mutation`,
  small and symmetric so a lineage drifts rather than resamples.

One quantity **will be measured and reported** before the run, because it is the
line that separates the two livings and neither is to be arranged:

> the maximum sustainable yield of a cell: the largest amount that can be taken
> every tick without driving the standing stock to nothing.

A lineage feeding below it can stay; one feeding above it cannot. Reporting it is
how we know both sides of that line are reachable, and it is derived from the
growth curve rather than picked.

Carried forward and already named: sensor rent rising linearly with range, flat
rent per hidden node, the rectified activation, and the two ground constants
derived in world 3.

## What will be reported

Everything that varies, side by side, **with none of it privileged**, plus the
population's mean feeding rate, which is the new axis.

## What would count as a finding

Stated in advance.

1. **Movement that persists.** `still%` durably below 100. Worlds 2 and 3 were at
   100 in every seed but one. This is the question.
2. **A feeding rate that settles somewhere.** Mean `uptake` converging away from
   the founding average, in either direction. Toward prudence means the sessile
   life won on its own terms; toward greed means stripping and moving did.
3. **Both, in one world.** Two groups at different feeding rates coexisting is
   the herbivore-and-grazer split arriving without either being named.
4. **Perception that pays**, meaning sensors carried AND acted on.
5. **Topology that is used**, and **conditional behaviour** via `self`.
6. **A landscape that differentiates**, `ground_spread` durably above ten. World
   3 reached 35-53 in three seeds of eight without anything moving.

**None is expected.**

## The commitments

1. Rules frozen before the first run, not changed in response to it.
2. Reported across many seeds as a distribution, including **nothing happened**.
3. A further change is world 5. This file is superseded, not edited.
4. Worlds 1, 2 and 3 are retired and may not be quoted alongside this.
