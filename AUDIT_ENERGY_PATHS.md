# Audit: every path energy takes, and whether one law holds on all of them

**Not an experiment.** No world was run for this. It is a read of
`advance_world/world.erl` against a single question, and the question is the one
that has now produced two corrections in a row:

> **Does this law hold at every site, or only at the site where it was
> introduced?**

That question found `C.6`, the movement fare that was the one cost unpayable
from your own body, which held perception at zero for five worlds. It then found
`B.7`, world 8's capacity bound applied to grazing and not to predation, which
became world 10. Neither was visible in any single function. Both lived in the
**difference between two functions**, which is why reading either one carefully
would never have found them.

So this is a deliberate pass over every place energy moves, listing the sites
side by side rather than reading each in turn.

## The sites

One tick, in order, and where matter or energy crosses a boundary at each phase:

| phase | site | what crosses |
|---|---|---|
| charge | `burn` → `settle` → `eat_own_frame` | store out; frame → store when the store is short |
| move | `step` | store out as the fare |
| consume | `devour` → `take_them` | victim → store, and since world 10 the remainder → ground |
| consume | `absorb` | ground → store |
| breed | `room` | store → child's store and child's frame |
| build | `invest` | store → frame |
| reap | `bury` | whole creature → ground |
| grow | `ground:grow` | the sun → ground |

## Finding 1: capacity is per SOURCE, not per creature

**The strongest thing here, and world 10 made it worse rather than better.**

    resolve(Ids, W) -> absorb(Winner, devour(Winner, Rest, W)).

`devour` takes meat, bounded by `min(uptake, frame)`. `absorb` then takes
ground, bounded by `min(uptake, frame)` **again**. The two bounds are applied
independently in the same tick, so a creature that makes a kill can take in
**twice** what the rule says its body allows.

The stated law is *a creature cannot take in more than its frame*. What is
implemented is *a creature cannot take in more than its frame from any one
source*, which is a different and much weaker claim, and nobody wrote it.

**And world 10 handed this a second mouthful.** The carrion a predator cannot
finish is buried on its own cell during `devour`, and `absorb` runs immediately
afterwards **on that same cell**. So a predator eats what it can hold, spills the
rest onto the ground under its feet, and then grazes its own spillage up to the
cap a second time, in the same tick. I introduced that interaction in world 10
and did not see it.

This is the same shape as `B.7` one level up: the bound is right at each site and
wrong across them.

## Finding 2: the body is infinitely plastic

Matter enters a creature at a bounded rate and moves between its two
compartments at an unbounded one.

    affordable(Wanted, Store) -> min(max(0, Wanted), max(0, Store)).

`invest` converts **the entire store into frame in a single tick** if the brain
asks for it. `eat_own_frame` runs the same conversion backwards, taking
`min(S, needed_frame(Short, Eff))`, bounded by the debt being covered rather than
by any rate. So a creature can build its whole reserve into a body and break its
whole body back down, both instantly.

Nothing in the world grows or shrinks at a rate. Real growth is rate-limited
because assembly takes time and surfaces; von Bertalanffy's whole model is
anabolism against catabolism with a rate on each.

**It matters because contests are decided on structure.** Size is currently a
switch rather than an investment: a creature can become the largest thing in its
cell in the tick it decides to, with no lag between deciding and being. Any
tradeoff between carrying energy where it is mobile and edible, and building it
where it is safe and expensive, is neutralised by the conversion being free of
time.

## Finding 3: thinking is free once the organ exists

`choose` evaluates the brain **once per candidate cell**, which is seven, plus
once in `breed_one` and once in `build_one`. About nine evaluations a tick.
`hidden_rent` is charged once, in `charge`.

This is not obviously wrong. A standing cost is a defensible model, and the
register already argues that for sensors: rent is paid whether the reading is
used or not. But it should be stated rather than implicit, because the current
shape means a brain that deliberates over seven options costs exactly what one
that deliberates over none costs, and the register's own explanation for why
brains keep being deleted is that there is nothing to decide.

## What the audit did NOT find

Worth recording, because a clean result narrows the search:

- **Conservation holds at every site.** Each path either transfers, dissipates
  into the account, or both, and the tests assert it across the efficiency sweep.
- **No unthreaded randomness and no clock reads** anywhere in `advance_world`.
  Every draw goes through the world's own rng, and every fold that could depend
  on map iteration order sorts its keys first. Measured, not assumed:
  `scripts/same_seed_same_world.escript` shows a world is a pure function of its
  seed and gives the same answer whether it is advanced in one call or one tick
  at a time.
- **Negative stores cannot leak.** `settle` never drives a store below zero and
  `whole/1` clamps anyway, so a creature dying in debt cannot mint energy.

## What follows

Finding 1 is the candidate for world 11: bound intake **per creature per tick**
rather than per source, which is a deletion, costs no constant, and corrects an
interaction world 10 introduced.

Finding 2 is larger and is a genuine new rule rather than a deletion, so it is
not next. It is also the one most likely to matter for entry `G.1`: a rate on
building is the first thing that would make being large an investment with a lag,
and lags are what make timing worth deciding.

Neither is a free good in the register's original sense. Both are the newer
category this method keeps turning up: **a law that is true everywhere it was
written and false in the gaps between.**
