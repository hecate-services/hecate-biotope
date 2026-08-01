# Pre-registration: the floor under bare ground

**Written before the run.** Tests register entry **A.5**, and its result decides
what world 14's rule change is. Nothing here changes the physics: this is world
13, swept.

## Why this is not world 14

Every world so far changed a rule. This changes none. `ground_seed` is already a
configurable constant and the sweep sets it the way `HECATE_BIOTOPE_ECON` sets
anything else, so an island running any value here is running world 13.

It goes first because it is cheap and because **it decides whether the rule
change worth making is worth making.** The candidate for world 14 is to delete
the floor and let bare ground be recolonised from its neighbours, which is what
`ground.erl`'s own comment claims happens and what the code does not do. That
would be the acceptable route to **A.2** named in the register — emergent
enrichment rather than a terrain generator with free parameters. But it rests on
a premise: that the floor is what creates the regime with no perception in it. If
that premise is false, the rule change attacks the wrong thing. Four minutes of
compute is cheaper than finding out afterwards.

## What was measured, and why A.5 reads differently now

The register has looked at A.5 twice and both times asked **12 or 24**: the
criterion that set the seed in world 4 has gone stale, and applied today it would
demand 24. Both times it declined, correctly, because raising the floor would
undo world 3.

Nobody asked whether the floor should be there at all. Measured on 24 seeds at
4,000 ticks, and on three live islands:

- **Eight of 24 seeds survive. Seven are the same world**: about a thousand
  creatures, mean body 59 to 75, thirteen energy held each, **100% of them
  standing still, zero sensors.** One is the other world: 98 creatures of mean
  body 403, 952 energy each, 2% standing still, 0.96 sensors and 1.31 hidden
  nodes.
- In **all seven** sessile worlds, 6% of the standing stock comes to 9 to 13
  against a floor of 12, so **their income is the floor**. Upkeep is
  `metabolism + body/33` = 11 or 12. The regime runs on a surplus of **one unit a
  tick**.
- A body can live on one cell forever if `10 + S/33 <= 12`, so up to **S = 98**.
  The sessile worlds sit at 59 to 75, under it with room to fund a child. The
  mobile world sits at 403, where one cell cannot cover upkeep at any stock.

So the constant that A.5 describes as *"a floor a stripped cell gets for
nothing"* is what makes a blind, sessile living possible, and it was chosen in
world 4 by asking precisely whether a blind, sessile creature could raise a
child. **The criterion presupposed the answer to the question this project keeps
asking.** That is a fair thing to have done for viability and it has never been
tested.

## The sweep

`ground_seed` from 0 to 48, control **12** (worlds 2 to 13). 24 seeds, 4,000
ticks, 100% efficiency, `neural_cost` at its control of 330 throughout.

**The price of perception is held fixed on purpose.** World 13 moved sensors by
making them cheaper. If they move here it must be for a different reason, and
holding the price constant is what makes that claim mean anything.

Values: **0, 3, 6, 9, 12, 18, 24, 36, 48.** Every one published, as world 7
published every efficiency and world 13 every price. **No value will be chosen
afterwards**, and the control does not move.

24 seeds and no medians, because world 13 swept five and reported the middle one,
and the middle one of a bimodal distribution is not a summary of it. That is the
error this whole line of work came out of.

## The classification rule, fixed before the data

A surviving world is **sessile** if `still_pct >= 90`, **mobile** otherwise.
Observed values are 99 to 100 and 2 to 50, so the threshold sits in a band where
nothing has ever been measured. It is not chosen to split anything.

## What would count as a finding

1. **The sessile regime disappears when the floor stops funding it.** Concretely:
   no surviving world with `still_pct >= 90` at `ground_seed` of 9 or below,
   where the floor no longer covers a minimum upkeep of 11.
2. **Perception rises as the floor falls, and rises because the regime mix
   changed.** Sensors per creature within the mobile half should be roughly
   constant across the sweep while the mobile half's *share* grows. If sensors
   rise inside a regime rather than through the mix, the mechanism claimed here
   is wrong even though the headline moved.
3. **The symmetric half lands too.** Above 12 the sessile regime takes a larger
   share and perception falls further. A sweep that only moves in the direction
   hoped for is a nudge.
4. **Standing stock per cell tracks the crossover** at `ground_seed * 100 / 6`,
   below which a cell lives on the floor and above which it compounds.

## What will NOT happen, stated in advance

**Extinctions will rise at both ends,** and at `ground_seed = 0` a stripped cell
is dead forever, so the board goes sterile one cell at a time and every seed
should die. That is the anchor rather than a surprise; world 3's comment already
predicts it.

**G.1 is untouched.** Every survivor will be at one founding line. Nothing here
recombines, nothing arrives from outside, and the register's own amendment says
the collapse is the null expectation.

**The world is still perfectly constant.** **G.3**, **A.4** and **G.5** are
untouched: no day, no season, no weather, and every source of chance is still
genetic.

**And the most likely outcome is still nothing.** Removing the floor may simply
kill everything, in which case the mobile regime was living on the same subsidy
and the two are not alternatives at all. That result would be worth more than the
one hoped for, because it would say this world has exactly one way to make a
living and every regime we have named is a variation on it.

**The strongest available negative:** if perception stays at zero at every value
where anything survives, then the regime story is dead, world 13's pricing is the
whole of it, and world 14 should be about something else entirely.

## The commitments

1. Values and criteria frozen before the first run, not changed in response to
   it. This file is superseded, not edited.
2. Every value reported, including **nothing happened**, and including the dead.
3. The control at 12 does not move, whatever the sweep says. A value chosen
   because of what it produced would be tuning for an outcome.
4. World 14's rule change is decided by this result and pre-registered
   separately. It is not written yet and will not be back-dated.
5. `lineages`, `depth` and the uptake spread are reported beside the population,
   as since world 9.
