# Pre-registration: does structure make computation worth paying for?

**Written before the run.** Tests the association reported in
[RESULTS_LUMPS.md](RESULTS_LUMPS.md). Not a world: the physics is world 14's and
`world:ruleset/0` does not move.

## The claim, stated so it can fail

**A brain is worth its rent when the right answer depends on more than one thing
at once, and a patchy board is the first thing in this project that makes that
true.**

A linear brain scores a candidate cell as a weighted sum of what it reads there.
That is enough to climb a gradient, and it is what these creatures do: 101 of 118
on the live island carry a ground sensor with real attention on it. But on a
patchy board the value of a cell is **not monotone in any single reading**. A
rich cell shared with six others is worth less than a poorer empty one, and value
is something like stock **over** competitors. **A linear brain can add and cannot
divide.** A hidden node is the organ that lets one input modulate another, and on
a flat board there is nothing to modulate: stock and crowding are uniform
everywhere.

The observation that prompted this is three islands, same binary, same tick:

| island | `ground_spread` | hidden nodes per creature |
|---|---|---|
| beam00 | 24 | **0.00** |
| beam01 | 83 | **0.16** |
| beam03 | 89 | **0.25** |

Against 0.01 for twelve worlds at the same price. Three points is three points.

## The design

`neural_cost` swept over **world 13's exact steps** — 330, 220, 165, 110, 66, 33,
11, 3, 1 — under world 14, **48 seeds**, **20,000 ticks**, 100% efficiency, every
other constant at its default.

**PATCHINESS IS NOT A KNOB AND THIS IS THE WHOLE REASON FOR THE DESIGN.** There is
no constant that sets how patchy a board becomes: `ground_spread` came out 24, 83
and 89 on three islands running identical rules at the same price, so it is an
outcome of the seed. Sweeping `recolonise_pct` would not vary it cleanly — the
world 14 sweep gave 43 to 58 at every rate it survived. So the comparison is
**across seeds within one world**, which is also what avoids comparing against
world 13's five-seed medians, a summary this project has already shown was
hiding a bimodal distribution.

**20,000 ticks because 4,000 would risk a false null.** The fleet reached 0.16
and 0.25 at about 35,000, and board structure is visible by 4,000, so the effect
forms somewhere between. A null at 20,000 does not rule out something slower and
this file says so in advance.

**48 seeds because survival is the binding constraint.** About two seeds in
twenty-four reach 4,000 at the control price and fewer will reach 20,000, so the
control arm may be too thin to speak to on its own. Survival rises as the price
falls, so the cheap end will be well populated. **The pooled analysis is
primary** for exactly this reason.

## What counts as "appears", fixed now

**Hidden nodes per creature above 0.10**, which is ten times the 0.01 floor of
worlds 2 to 13 and below every value the two lumpy islands show. Chosen before
any number is seen and not adjusted afterwards.

## What would count as a finding

1. **Hidden nodes at the CONTROL price rise above the twelve-world floor.** At
   330, worlds 2 to 13 recorded 0.01. Anything above 0.10 there is a result on
   its own, because that price is the one world 13 showed prices computation out
   on a flat board.
2. **Pooled over every surviving world, hidden nodes rise with `ground_spread`.**
   Reported as hidden-per-creature within tertiles of `ground_spread`, not as a
   correlation coefficient, because the distribution is skewed and a single
   number would hide the shape.
3. **THE DIRECTION TEST, and it is free.** If brains cause patchiness rather than
   the reverse, then making brains cheap should make boards patchier: as
   `neural_cost` falls, `ground_spread` would rise. **The prediction is that it
   does not** — that `ground_spread` is roughly flat across the price sweep while
   hidden nodes climb. If instead patchiness tracks the price, finding 2 is
   confounded and the arrow points the other way.
4. **SENSORS DO NOT SHOW THE SAME PATTERN.** A sensor pays on a flat board too:
   climbing a gradient needs no hidden layer. So if sensors track `ground_spread`
   as strongly as hidden nodes do, then what is being measured is not
   computation but something that makes creatures able to afford every organ —
   size, or income. Hidden nodes moving **more** than sensors is what would make
   this about brains.

## What will NOT happen, stated in advance

**This will not settle the causal arrow.** It is an observational correlation
across seeds, and finding 3 is the only thing here that speaks to direction. A
real intervention would need a knob on patchiness and there is not one; that is
a limitation of the design and not something to be argued away afterwards.

**G.1 is untouched.** Every survivor will be at one founding line.

**Extinctions will be high at the expensive end**, roughly twenty-two seeds in
twenty-four at the control, and will fall as the price falls, exactly as world 13
found.

**The world is still perfectly constant.** A.4, G.3 and G.5 stand: no day, no
season, no weather, and every source of chance is still genetic.

**And the most likely outcome is still nothing.** Twelve worlds produced no
movement on hidden nodes and the one that did moved it by changing the price.
Asking for a structure effect **on top of** a known price effect is a harder
thing than anything that has landed here, and the fleet reading is three islands.

**The strongest available negative**, and it is a real possibility: hidden nodes
flat across every tertile of `ground_spread`. That would say the 0.00 / 0.16 /
0.25 was noise, that world 14 moved perception and not computation, and that a
brain still has nothing to decide.

## The commitments

1. Steps, seeds, horizon and the 0.10 threshold frozen before the first run, not
   changed in response to it. This file is superseded, not edited.
2. Every price reported, including **nothing happened**, and including the dead.
3. Not a world. No ruleset bump, no WORLDS.md row, and nothing here licenses a
   claim about world 15.
4. `lineages`, `depth` and the uptake spread reported beside the population, as
   since world 9.
5. **This run is the most expensive in the project** — nine prices by forty-eight
   seeds by twenty thousand ticks — and the cost is stated here so that a null is
   not quietly discounted for having been dear.
