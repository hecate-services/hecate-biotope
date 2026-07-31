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

Three separate defects explain that, and they interlock, which is why they are
being fixed together rather than one per world.

### 1. The instrument could not resolve what it was measuring

`body:scale/1` divided every field by 20 and clamped at 15. In natural terms:

| quantity | typical raw | reading |
|---|---|---|
| one plant | 40 | **2** |
| one full-strength foreign scent mark | 30 | **1** |
| two well-fed creatures in a cell | 600 | **15, saturated** |

One resolution applied to three quantities spanning 30 to 900. Scent was
quantised to a single bit and creature energy pegged at the ceiling. **This is
very likely why scent sensors went extinct in every seed**: not because trails
are useless but because the instrument could barely register them.

This is a defect in a measuring device, statable without reference to what
evolves.

### 2. A creature could not perceive itself

There was no proprioception. The central rule of this world is that the stronger
consumes the weaker, so whether you are currently the eater or the eaten is the
most decision-relevant fact available, and it was not available. Every strategy
of the form *behave differently when weak* was unreachable, which includes
fleeing, hiding, and hunting selectively.

### 3. There was no nonlinearity, so proprioception would not have helped

Own-energy is **constant across all seven candidate cells**. In a single linear
layer it contributes the same amount to every option and cancels in the argmax.
So adding proprioception to a linear brain would have changed nothing at all, and
adding a nonlinearity to a brain with no self-knowledge would have had little to
combine. Fixing either alone is provably insufficient.

## What world 2 is

Still: **physics is ours to write, biology never is.** No named action, no named
organ, no role anywhere in the rules. Everything below is either a physical
quantity, a cost, or a structure that mutation acts on.

### Sensors, in natural units

A sensor is still `{Field, Range}` and still evolvable. Fields gain one member
and every reading is expressed in **its own natural unit** rather than through
one shared divisor:

| field | unit | a reading of 3 means |
|---|---|---|
| `plants` | `plant_energy` | three plants in reach |
| `creatures` | `plant_energy` | creature flesh worth three plants |
| `scent` | `scent_per_tick` | as much trace as three fresh marks |
| `self` | `plant_energy` | I am worth three plants |

Expressing creature flesh in plant-equivalents is not a convenience: it is the
exchange rate the world already runs on, since both are energy and energy is the
only currency here.

`self` is a sensor like any other. It can be absent, it costs rent, and a lineage
that never evolves it never learns whether it is large or small.

### A brain with structure

Inputs are the sensor readings, plus `here`, a 1 for the cell the creature is
already standing on and 0 for the other six. That replaces world 1's special
staying-weight with an ordinary input, so nothing in the brain is special-cased.

- **Hidden nodes**, evolvable in number, each with a weight per input.
- **Rectification**, `max(0, x)`, as the nonlinearity. Integer, monotone but not
  linear, and it requires no libm, so a run stays bit-identical from its seed and
  the whole world remains probeable offline in seconds. That property has already
  saved this project a fortnight of misdirected work and is not being traded away
  for a smoother activation that would change the numbers and not the decisions.
- **Outputs**, each with a weight per input and per hidden node.

Structural mutation adds and removes sensors, hidden nodes and outputs. **This is
the main engineering risk in world 2**: every structural change must update every
dependent weight vector consistently, and a misaligned vector does not crash, it
silently makes a creature read the wrong column. World 1 had one such invariant;
world 2 has three interacting ones. It is guarded by tests asserting the shape
after every kind of change, and by a long run whose completion is itself the
assertion.

### Actuators

- **`move`** — evaluated once per candidate cell; the creature goes to the
  highest. Absent means it never moves.
- **`breed`** — evaluated once, on its own cell; above a threshold it spends
  **half its current energy** on a child. Absent means it leaves no descendants.

**`breed_at` and its three companion constants are deleted.** World 1 decided
reproduction with a hand-written rule and a heritable threshold, which is exactly
the shape `hunt` had: a verb we wrote with a parameter bolted on. Making it an
output means a lineage can evolve *breed when food is near* or *breed when
nothing large is close*, which the rule forbade outright. Four constants leave
the economy and no rule replaces them: a creature that breeds itself down to
nothing simply leaves children too small to survive, and needs no floor to stop
it.

**There are only two actuators and that is a fact about this world, not an
oversight.** Very little here is physically distinct to *do*: consumption is
automatic on contact, and scent is left by moving because moving disturbs the
ground, which is physics rather than a gland a creature could choose to switch
off. Stealth is already available and always was: staying still is free and marks
nothing. If the finding is that the action space is too thin for actuators to
matter, the honest next addition is **effort**, spending more energy to move
further, which is physical and was left out here only to keep one world's worth
of change tractable.

### Resolution

`radius` 20 → 40, so 1261 cells → 4921. `regrowth_per_tick` 4 → 16, scaled with
area so plant DENSITY is unchanged and this is a change of scale rather than of
generosity.

The reason is not a prettier picture. Population should rise roughly fourfold,
and **drift falls as 1/N**. Drift is what wrecked the `breed_at` experiment in
the first place, where between-seed spread swamped every between-condition
difference. Costs about four times the compute and about four times the chart
payload; the payload is the part to watch, since the index page will be drawing
several thousand shapes per frame.

## What may set a constant

Unchanged from world 1, and it is the rule this project exists to keep.

A number may be chosen for **viability**: nothing goes extinct or extinction is
the finding, the population is not pinned at `max_creatures`, the energy books
balance, an instrument can resolve what it measures, and a run completes fast
enough to repeat across at least eight seeds.

A number may be chosen for **scale**: `max_sensors`, `max_sensor_range` and a new
`max_hidden` are safety valves against a runaway genome making one tick cost as
much as the whole disc. When one binds it is counted and reported rather than
left to look like a natural ceiling.

**A number may never be chosen because of what evolves in it.** "Sensors survive
at this rent" is not a reason to choose that rent.

Constants whose functional form no physics settles, named here rather than
defended later:

- **sensor rent rises linearly with range.** Reach costs; whether with the radius
  or with the area covered is undecided by anything in this world. Carried
  forward unchanged from world 1.
- **hidden nodes cost rent too**, on the same argument: a brain is a thing that
  must be run. Charged per node, flat, because unlike reach there is no geometry
  to derive a shape from.
- **the rectified activation** rather than any other nonlinearity, chosen for
  being integer and libm-free.

## What will be reported

Everything that varies, side by side, **with none of it privileged**. The probe
has no headline metric, because a probe that reports one number at the top is a
probe that will be run until that number moves, and this project has already made
that mistake once.

Viability, deaths by cause, share of energy from creatures, the sensor census
with **carriers, reach and attention** separately, hidden node counts, structural
gains and losses, signature count and spread, and the distribution across seeds.

## What would count as a finding

Stated in advance so nothing can be promoted to one afterwards.

1. **Perception that pays.** Sensors that both persist AND are acted on, meaning
   non-zero attention. World 1 had neither reliably, and carriers alone are not
   enough: an organ can be carried, charged for, and ignored.
2. **Topology that is used.** Hidden nodes persisting under rent, which they will
   only do if the nonlinearity is buying something a linear map could not.
3. **Conditional behaviour.** `self` sensors persisting with attention. They are
   useless to a linear brain by construction, so if they persist and are weighted,
   something is combining self-knowledge with what is nearby.
4. **Predation as a strategy rather than as weather.** A high share of energy
   from creatures TOGETHER with creature sensors that are carried and attended.
   World 1 had the first without the second, which is the distinction worth
   keeping.
5. **Divergence between seeds**, with within-seed spread smaller than
   between-seed spread. World 1 could not establish this from one run per seed
   and neither will this without more.

**None of these is expected.** The honest prior is world 1's result: one kit
fixed near 100%, and nothing else happening.

## The attribution cost, stated plainly

**Several things change at once, so a positive result cannot be attributed to any
one of them.** Scaling, proprioception, nonlinearity, topology, reproduction and
resolution all move together.

That is accepted deliberately. The three defects above are not independent: two
of them are provably useless without the third, so changing one at a time would
mean two worlds guaranteed in advance to show nothing. The question world 2 asks
is not *which change mattered* but *does this world have room for evolution at
all*, and that question does not decompose.

If the answer is yes, isolating which change did the work is world 3's job, and
it is a much better problem to have.

## The commitments

1. The rules are frozen before the first run and are not changed in response to
   what the first run shows.
2. Results are reported across many seeds as a distribution, including **nothing
   happened**, which remains a likely and acceptable outcome.
3. If the physics changes again, that is world 3. This file is superseded rather
   than edited, and its results are retired rather than carried forward.
4. World 1's results are retired now. They describe a different world and may not
   be quoted alongside anything from this one.
