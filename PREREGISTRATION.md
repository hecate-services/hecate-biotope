# Pre-registration: world 2

**Written before world 2 was built.** World 1 is superseded, not edited:
[PREREGISTRATION_WORLD1.md](PREREGISTRATION_WORLD1.md) and its
[results](RESULTS_WORLD1.md) stand as the record of a different world, and
nothing measured there may be compared with anything measured here.

## Why there is a world 2

World 1 answered its own question honestly and the answer was thin. From its
frozen run: **predation was most of the economy and required no adaptation at
all**, perception was selected out almost everywhere, and movement was mostly a
literal coin toss because most creatures carried no sensors.

Four defects explain that. They interlock, which is why they are fixed together
rather than one per world.

### 1. A plant was a KIND OF THING rather than a WAY OF LIVING

World 1's own module header claimed *"consumption is one rule that does not know
what it is eating"*. That was false. There were two functions, `eat_plants` and
`eat_creatures`, with separate accounting, because plants and creatures were
separate types. The rule knew perfectly well, and the herbivore/carnivore split
that had supposedly been deleted survived as a structural fact about what exists.

A plant is not a kind of thing. **It is a strategy**: stay where you are and take
energy from the environment around you. World 1 removed `hunt` for naming a
behaviour and then hard-coded an entire entity type, two constants and the
permanent floor of the food chain around another one. The trophic structure was
celebrated for falling out of a single rule while its foundation had been
installed by hand.

### 2. The instrument could not resolve what it was measuring

`body:scale/1` divided every field by 20 and clamped at 15. In natural terms a
plant read **2**, a full-strength scent mark read **1**, and two well-fed
creatures in a cell read **15 and saturated**. One resolution for quantities
spanning 30 to 900. Scent was quantised to a single bit, which is very likely why
scent sensors went extinct in every seed: not because trails are useless, but
because the device could barely register them.

### 3. A creature could not perceive itself

There was no proprioception. The central rule is that the stronger consumes the
weaker, so whether you are currently the eater or the eaten is the most
decision-relevant fact available, and it was not available. Every strategy of the
form *behave differently when weak* was unreachable.

### 4. There was no nonlinearity, so fixing 3 alone would have done nothing

Own energy is **constant across all seven candidate cells**. In a single linear
layer it contributes equally to every option and cancels in the argmax. Adding
proprioception to a linear brain changes nothing whatsoever, and a nonlinearity
with no self-knowledge has little to combine. Either fix alone is provably
insufficient.

## What world 2 is

Still: **physics is ours to write, biology never is.** No named action, no named
organ, no named kind of organism.

### The ground holds energy, and there are no plants

Energy entering the world is physics. A plant is not. So:

- Every cell accumulates energy at `influx` per tick, up to `ground_ceiling`.
  Uniformly, everywhere, because that is what an ambient supply does.
- A creature absorbs whatever has gathered in the cell it occupies. All of it. No
  rate limit and therefore no further constant.
- Contest resolves first, then the survivor absorbs. One order, stated.

`plant_energy`, `regrowth_per_tick`, the plants map and the sowing machinery are
all deleted. **Patchiness stops being sprinkled by a random number generator and
becomes the depletion left by grazing**: the spatial structure of the world is
made by its inhabitants.

Two ways of making a living now exist, and neither is named anywhere:

| | income | costs | exposure |
|---|---|---|---|
| stay | one cell's influx | no movement | cannot flee, and banks energy that others can take |
| move | whatever accumulated where you have not been | movement, every tick | can leave, can take what the sessile have banked |

A creature that stays put and lives off ambient energy **is** a plant. Nothing in
the rules will call it one.

**A world begins with every cell full**, since no cell has been drained. The
opening phase of a run is colonisation of a virgin larder and is not equilibrium;
runs must be long enough to pass it and the transient must not be read as the
answer.

### Sensors, in natural units

A sensor is still `{Field, Range}` and still evolvable. One field is renamed, one
is added, and every reading is expressed in its own natural unit rather than
through one shared divisor:

| field | unit | a reading of 3 means |
|---|---|---|
| `ground` | `ground_ceiling` | three cells' worth of accumulated energy in reach |
| `creatures` | `ground_ceiling` | creature flesh worth three full cells |
| `scent` | `scent_per_tick` | as much trace as three fresh marks |
| `self` | `ground_ceiling` | I am worth three full cells |

One energy unit for every energy quantity, because energy is the only currency
here and the exchange rate already exists.

`self` is a sensor like any other: it can be absent, it costs rent, and a lineage
that never evolves it never learns whether it is large or small.

### A brain with structure

Inputs are the sensor readings plus `here`, a 1 for the cell the creature already
occupies and 0 for the other six. That replaces world 1's special staying-weight
with an ordinary input, so nothing in the brain is special-cased.

- **Hidden nodes**, evolvable in number, each with a weight per input.
- **Rectification**, `max(0, x)`. Integer, monotone but not linear, no libm, so a
  run stays bit-identical from its seed and the world remains probeable offline.
  That property has already saved this project a fortnight and is not being
  traded for a smoother activation that would change the numbers and not the
  decisions.
- **Outputs**, each with a weight per input and per hidden node.

Structural mutation adds and removes sensors, hidden nodes and outputs. **This is
the main engineering risk in world 2.** Every structural change must update every
dependent weight vector consistently, and a misaligned vector does not crash: it
silently makes a creature read the wrong column. World 1 had one such invariant;
world 2 has three that interact. Guarded by tests asserting shape after every
kind of change, and by long runs whose completion is itself an assertion.

### Actuators

- **`move`** — evaluated per candidate cell; the creature goes to the highest.
  Absent means it never moves, which is now a living rather than a death
  sentence.
- **`breed`** — evaluated once on its own cell; above a threshold it spends
  **half its current energy** on a child. Absent means no descendants.

**`breed_at` and its three companion constants are deleted.** Deciding
reproduction by a hand-written rule with a heritable threshold was exactly the
shape `hunt` had. Now a lineage can evolve *breed when the ground is rich* or
*breed when nothing large is near*, which the rule forbade. No floor replaces it:
a creature that breeds itself down to nothing leaves children too small to
survive, which needs no rule to prevent.

**Two actuators, and that is a fact about this world rather than an oversight.**
Little here is physically distinct to *do*: consumption is automatic on contact,
and scent is left by moving because moving disturbs ground, which is physics and
not a gland that could be switched off. If the finding is that the action space
is too thin, the honest next addition is **effort**, spending more to move
further, left out here to keep one world's change tractable.

### Scale, and a reversal

The economy is re-expressed at **ten times the grain**: metabolism, movement,
rent, starting energy, influx and ceiling all multiplied together. Nothing about
the world changes, because scaling every energy quantity by the same factor is a
change of units. It buys the resolution to set a ratio to within a tenth, which
the next section needs and integers at the old grain could not express.

**Radius stays at 20, reversing what an earlier draft proposed.** That draft
argued for radius 40 to raise the population and suppress drift, since drift is
what wrecked the `breed_at` experiment. But if sitting still pays, the board
fills: equilibrium population is roughly cells times influx over metabolism, so
viable sessility saturates the surface. That is not a runaway to be capped, **it
is a forest** — a field of grass is a population at the carrying capacity of the
ground. The population therefore rises by itself, drift falls by itself, and a
larger board would only make each tick several times more expensive for a benefit
already obtained.

`max_creatures` accordingly rises well above the cell count. It remains a safety
valve, not a model parameter, but a covered board is now the expected state
rather than evidence of a mistuning. **The cost is compute**: a world that can
hold a forest is far more expensive to simulate than one holding fifty wanderers,
and the frozen run is expected to take minutes rather than seconds.

## What may set a constant

Unchanged, and it is the rule this project exists to keep.

A number may be chosen for **viability**: nothing goes extinct or extinction is
the finding, the population is not pinned at `max_creatures`, the energy books
balance, an instrument can resolve what it measures, **both ways of making a
living are reachable**, and a run completes fast enough to repeat across at least
eight seeds.

A number may be chosen for **scale**: `max_sensors`, `max_sensor_range` and
`max_hidden` are safety valves against a runaway genome making one tick cost as
much as the whole disc. When one binds it is counted and reported.

**A number may never be chosen because of what evolves in it.**

### `influx` is the one number that decides whether plants can exist

It is therefore the one most at risk of being chosen for its outcome. Set it
generously and everything sits still; set it meanly and sessility is fatal and
world 1 returns. Either would be engineering the answer.

The criterion, stated before measuring, derives it from the economy alone and
makes no reference to what evolves:

> **The smallest `influx` at which a sensorless creature that never moves can
> accumulate enough to raise one child within `max_age`.**

That is the least generous value at which the sessile option exists at all. It
cannot be accused of installing plants, because anything smaller forbids them and
this is the smallest thing that does not. It will be derived by measurement and
the derivation recorded, exactly as `scent_mutation` was in world 1 after being
set the wrong way round the first time.

It will also be checked in the other direction: a mobile forager must remain
viable at that value, so that neither option is priced out before selection sees
it. The same argument that rejected area-scaled sensor rent in world 1.

Constants whose functional form no physics settles, named rather than defended:

- **sensor rent rises linearly with range.** Reach costs; whether with the radius
  or the area covered is undecided here. Carried forward unchanged.
- **hidden nodes cost flat rent.** A brain is a thing that must be run, and unlike
  reach there is no geometry to derive a shape from.
- **the rectified activation**, chosen for being integer and libm-free.

## What will be reported

Everything that varies, side by side, **with none of it privileged**. No headline
metric: a probe that reports one number at the top is a probe that will be run
until that number moves, and this project has already made that mistake.

Viability, deaths by cause, the share of energy taken from other creatures rather
than from the ground, the sensor census with **carriers, reach and attention**
separately, hidden node counts, structural gains and losses, signature count and
spread, **the fraction of creatures that did not move**, and the distribution of
all of it across seeds.

## What would count as a finding

Stated in advance so nothing can be promoted to one afterwards.

1. **Sessility as a living.** A persistent fraction of the population that does
   not move and takes its energy from the ground. That is autotrophy, and it
   would have emerged from rules that do not contain the word.
2. **Perception that pays.** Sensors that persist AND are acted on, meaning
   non-zero attention. World 1 had neither reliably, and carriers alone are not
   enough: an organ can be carried, charged for, and ignored.
3. **Topology that is used.** Hidden nodes persisting under rent, which they will
   only do if the nonlinearity buys something a linear map could not.
4. **Conditional behaviour.** `self` sensors persisting with attention. They are
   useless to a linear brain by construction, so if they persist and are weighted,
   something is combining self-knowledge with what is nearby.
5. **Predation as a strategy rather than as weather.** A high share of energy
   from creatures TOGETHER with creature sensors carried and attended. World 1 had
   the first without the second, and that distinction is the one worth keeping.
6. **Divergence between seeds**, with within-seed spread smaller than
   between-seed spread. Not establishable from one run per seed, and will not be
   claimed from one.

**None of these is expected.** The honest prior remains world 1's result: one kit
fixed near 100%, and nothing else happening.

## The attribution cost, stated plainly

**Several things change at once, so a positive result cannot be attributed to any
one of them.** The ground, the units, proprioception, the nonlinearity, topology,
reproduction and the grain all move together.

Accepted deliberately. Two of the four defects are provably useless to fix
without the fourth, and the first makes the others moot, since a world with its
food chain nailed to the floor cannot answer what a food chain does. Changing one
at a time would mean three worlds guaranteed in advance to show nothing.

The question world 2 asks is not *which change mattered* but **does this world
have room for evolution at all**, and that does not decompose. If the answer is
yes, isolating what did the work is world 3's job, and a much better problem to
have.

## The commitments

1. The rules are frozen before the first run and are not changed in response to
   what the first run shows.
2. Results are reported across many seeds as a distribution, including **nothing
   happened**, which remains a likely and acceptable outcome.
3. If the physics changes again, that is world 3. This file is superseded rather
   than edited and its results retired rather than carried forward.
4. World 1's results are retired now. They describe a different world and may not
   be quoted alongside anything from this one.
