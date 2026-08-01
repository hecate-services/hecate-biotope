# Pre-registration: world 14

**Written before world 14 was built.** Corrects register entry **A.5**, and
targets **A.2** and **G.4**. World 13 is superseded, not edited.

## A rule I said was dead, and why it is not

The ground floor sweep was run to test this rule's premise and
[refuted it](RESULTS_GROUND_FLOOR.md). I wrote that it killed world 14's
candidate. **It killed one of two justifications and strengthened the other**,
and pretending otherwise would be worse than reversing.

What died: *the floor's magnitude is what creates the sightless sessile regime.*
It is not. Sweeping it 0 to 48 moved nothing except the size of the creature,
because the lineage re-sizes to whatever balances and the population grazes the
stock to wherever the marginal grazer breaks even.

What survives, untouched by that: **the floor is unconditional.** Every cell gets
the same subsidy regardless of what is around it, so a desert cell in the middle
of a grazed-out region is refilled exactly as fast as one beside untouched
ground. That is not a magnitude, it is a shape, and **it is what prevents spatial
structure from forming at all.** The sweep is the evidence: standing stock came
out near 200 at four different floors, and `ground_spread` has sat at 22 to 25
since world 12. A population that re-equilibrates to a uniform break-even
everywhere is exactly what an unconditional subsidy produces.

## World 3 diagnosed this and fixed half of it

`ground.erl` says so in its own words, about the world it replaced:

> sessility is viable exactly when income exceeds metabolism, equilibrium density
> is then income over metabolism, which is above one, so every cell is grazed
> more than once a tick, so a mover never finds more than a stayer already has.
> **A uniform resource that renews in place IS the resource that selects for
> sitting still, which is why plants do not move.**

World 3 made recovery depend on the cell's own stock, which is half of removing
the uniformity. The other half is the floor, and the same file already states
what it is supposed to be:

> **The floor is recolonisation: the baseline any bare patch gets from what is
> around it.**

The code does not do that. It adds a constant. **A mechanism claimed in a comment
and implemented as a global constant is the same defect as a law applied at one
site**, which this register has now caught five times (C.6, B.7, B.8, and world
13's flat fee).

## The single change

**A bare patch is recolonised by its neighbours, not by a constant.**

```
floor = mean(stock of the neighbouring cells) * recolonise_pct / 100
```

`ground_seed` is **deleted**. One constant replaces one constant, and the rest of
`recover/4` is untouched: a cell still gains `max(floor, stock * growth_pct)` and
is still left alone above the ceiling.

Neighbours are the cells that exist. The disc is the whole world and beyond its
rim is nothing rather than bare ground, so a rim cell averages over the
neighbours it has. Counting absent cells as zero would make the rim
systematically poor, which is an edge artefact and not physics.

Every cell grows from the same prior state, so the order they are visited in
cannot matter.

## The control is a point on the sweep

**`recolonise_pct = 3` reproduces worlds 2 to 13 exactly on a full board.** Every
neighbour at the ceiling of 400 gives `400 * 3 / 100 = 12`, which is the
`ground_seed` those worlds used. As with world 13's `neural_cost` of 330, the
comparison lives inside the experiment rather than across it.

Swept: **0, 1, 2, 3, 4, 6, 9, 12, 18.** 24 seeds, 4,000 ticks, 100% efficiency,
`neural_cost` pinned at 330 throughout. Every value published. **No value will be
chosen afterwards and the control does not move.**

The price of perception is held fixed for the same reason as last time: world 13
moved sensors by making them cheaper, so anything that moves here has to move for
another reason.

## What would count as a finding

Stated in advance, in the order they have to happen.

1. **The board becomes spatially structured.** `ground_spread` rises above the 22
   to 25 it has sat at since world 12. This is the mechanism check and everything
   below it depends on it. If the ground does not get patchier, nothing else can
   follow and the rest of these are void.
2. **Being common costs something, for the first time in this world.** A dense
   sessile population grazes its own neighbourhood flat, and a flat neighbourhood
   supplies no floor, so **the lawn destroys its own subsidy**. Concretely: the
   sessile share of surviving worlds falls below the 7-of-8 it has held at every
   floor tested. That is **G.4**, which has been open since the section was
   written and which no world has touched.
3. **Perception rises above the whole band the floor sweep measured**, which was
   0.12 to 0.65 sensors per creature across every value of a constant. With the
   price pinned, that could only come from how creatures are making a living.
4. **`still_pct` falls** from the 99 to 100 the sessile regime has held.

## What will NOT happen, stated in advance

**Extinctions will rise, and the world may sterilise at every value.** A
grazed-out board has no rich neighbours, so recovery can collapse globally rather
than locally: the same feedback that is supposed to punish the lawn can take
everything with it. A floor of 0 killed all 24 seeds in the last sweep and
`recolonise_pct = 0` is the same world. **If nothing survives at any value the
mechanism is unusable and that is the result**, not a tuning problem to be
escaped by widening the range.

**G.1 is untouched.** Every survivor will be at one founding line. Nothing here
recombines and nothing arrives from outside.

**There is still no variation in TIME.** **A.4**, **G.3** and **G.5** are
untouched: no day, no season, no weather, and every source of chance is still
genetic. This makes the board vary in space as a consequence of what creatures
do; it does not make any tick different from any other.

**And the most likely outcome is still nothing.** Twelve of thirteen worlds have
produced no lasting movement on perception, and the one that did moved it by
changing a price. A patchy board is something to perceive, and something to
perceive is not the same as a reason to pay for the organ.

**The strongest available negative:** if the board gets patchy and perception
does not move, then patchiness is not what is missing either, and the remaining
candidates on the register's own short list are variation in time and
recombination.

## The commitments

1. Rules frozen before the first run, not changed in response to it. This file is
   superseded, not edited.
2. Every value reported, including **nothing happened**, and including the dead.
3. `world:ruleset/0` says 14 in the same commit as the rules, and there is a test
   that fails if it does not.
4. `lineages`, `depth` and the uptake spread are reported beside the population,
   as since world 9.
5. **This rule was declared dead one message before it was pre-registered.** The
   sweep that killed it refuted the premise about magnitude and left the premise
   about shape standing. Recorded here so nobody has to reconstruct it.
