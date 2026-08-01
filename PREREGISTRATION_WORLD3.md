# Pre-registration: world 3

> **SUPERSEDED** by [PREREGISTRATION.md](PREREGISTRATION.md). Kept whole and
> unedited. Its results are in [RESULTS_WORLD3.md](RESULTS_WORLD3.md): the single
> change made no difference, and the reason it made none is what world 4 acts on.

**Written before world 3 was built.** World 2 is superseded, not edited:
[PREREGISTRATION_WORLD2.md](PREREGISTRATION_WORLD2.md) and its
[results](RESULTS_WORLD2.md) stand as the record of a different world, and
nothing measured there may be compared with anything measured here.

## Why there is a world 3

World 2 ended 100% sessile in every one of eight seeds, with no sensors, no
hidden nodes and a flat landscape. That was **not a tuning failure**. It was
forbidden by arithmetic, for every parameter choice:

1. Sessility is viable exactly when `influx > metabolism`.
2. Equilibrium density is set by energy balance, `d = influx / metabolism`.
3. A mover's income is `influx / d`, which by (2) is exactly `metabolism`.

So a mover nets **minus the fare**, always, while a stayer nets a surplus.
Sessility being viable at all forces more than one creature per cell, which
means a mover can never find more than a stayer already has.

**One change causes all of it.** World 2's ground refills at a fixed rate
regardless of how hard it is grazed. A cell stripped a thousand times recovers
exactly as fast as one never touched. That is a resource with no memory, and a
resource which is uniform and renews in place is precisely the resource that
selects for sitting still. It is sunlight, and plants do not move.

## The single change

**The ground's recovery depends on how much is left in it.**

    growth = min(ceiling - stock, max(ground_seed, stock * ground_growth_pct / 100))

`influx` is deleted. Bare ground recovers at `ground_seed`; ground with something
in it compounds. A corpse still sits above the ceiling and is not pushed down.

That is the whole of world 3. **Nothing else changes** — not the brain, not the
sensors, not reproduction, not the disc, not the death deposit. After two worlds
that each moved half a dozen things at once and could attribute nothing, this one
moves exactly one thing, and if the outcome differs it will be attributable.

### Why this is a correction and not an addition

Stored energy is biomass, and biomass regrows in proportion to itself. A fixed
rate independent of stock is the unphysical case, not the general one. Every
standard renewable-resource model, in fisheries and forestry alike, makes
recovery depend on the standing stock, and world 2 was the special case that
removes the dependence entirely.

### What it should break, mechanically

Step 2 of the proof. In world 2 total input is `C x influx` whatever anyone does,
so equilibrium density is fixed by the rules. Here **total productivity is
endogenous**: a population that strips everything holds the whole board near
zero and gets `C x ground_seed`, while one that grazes lightly holds stock near
the middle of the curve where growth is fastest. The population's own behaviour
sets how much there is to go round.

That also gives the Marginal Value Theorem something to bite on for the first
time. World 2 had no diminishing returns within a cell, so there was no leaving
rule to discover; here a stayer suppresses its own supply and a returning forager
finds what recovered in its absence.

**It may still not be enough.** A sessile stripper that can live on `ground_seed`
alone reproduces world 2's logic with `ground_seed` in place of `influx`. Whether
the endogenous productivity breaks that is exactly what this world asks, and the
honest prior is that it might not.

## What may set a constant

Unchanged, and it is the rule this project exists to keep. A number may be
chosen for **viability** or for **scale**, and **never because of what evolves in
it**. Two constants replace `influx`, and both criteria are fixed here, before
anything is measured.

**`ground_seed`** keeps world 2's criterion verbatim, so the two worlds differ in
one mechanism and not in how their constants were chosen:

> the smallest `ground_seed` at which a sensorless creature that never moves can
> accumulate enough to raise one child within `max_age`.

The least generous value at which the sessile option exists at all. Anything
smaller forbids plants outright.

**`ground_growth_pct`** is set from a property of the RESOURCE, with no reference
to any lifestyle. **This criterion was amended once, before any run, and the
original is kept here rather than quietly replaced.**

It first read:

> ~~the smallest `ground_growth_pct` at which ground stripped to nothing recovers
> to half the ceiling within one `max_age`.~~

`scripts/verify_ground.escript` showed that **does not discriminate**. At
`ground_seed` 12 the seed floor ALONE carries a bare cell to half the ceiling in
seventeen ticks, so every rate from zero upward satisfied it and the smallest was
zero. Growth would have been flat at 12 forever, the proportional term would
never once have fired below the ceiling, and **world 3 would have been world 2
exactly** — the single change it exists to make would have been inert.

It now reads:

> the smallest `ground_growth_pct` at which recovery is mostly COMPOUNDING rather
> than mostly linear, meaning the proportional term overtakes the seed floor
> below half the ceiling.

Still a property of the resource and of no lifestyle. It says only that the
mechanism operates at all, which is the same class of requirement as a sense
having something to discriminate, or an economy being able to express an option.
**It still does not guarantee movement pays**, and must not be raised until it
does: whether anything exploits the recovery is the question, not something to be
arranged.

The amendment is legitimate because it happened **before the experiment**, and it
is recorded because a criterion silently swapped after it fails is worth nothing.

### Derived

    ground_seed        12   (agrees with the arithmetic, and with world 2's)
    ground_growth_pct   6   (crossover at stock 200, exactly half the ceiling)

Both will be derived by measurement with `scripts/verify_ground.escript`, and the
derivation recorded, exactly as `influx` was.

Carried forward unchanged and already named: sensor rent rising linearly with
range, flat rent per hidden node, and the rectified activation.

## What will be reported

Everything that varies, side by side, **with none of it privileged**. The probe
has no headline metric, because a probe that reports one number at the top is a
probe that will be run until that number moves.

Viability, deaths by cause, the share of energy taken from creatures rather than
ground, the sensor census with carriers, reach and attention separately, hidden
node counts, structural gains and losses, signature count and spread, the
fraction of creatures that did not move, how unevenly the ground holds energy,
and the distribution of all of it across seeds.

## What would count as a finding

Stated in advance so nothing can be promoted to one afterwards.

1. **Movement that persists.** `still%` durably below 100. World 2 was at 100 in
   every seed, so anything short of it is a difference the single change caused,
   and this is the one the world was built to ask.
2. **Perception that pays.** Sensors that persist AND are acted on, meaning
   non-zero attention. Carriers alone are not enough: an organ can be carried,
   charged for, and ignored.
3. **Topology that is used.** Hidden nodes persisting under rent.
4. **Conditional behaviour.** `self` sensors persisting with attention, which are
   useless to a flat brain by construction.
5. **A landscape that differentiates.** `ground_spread` durably above the flat
   baseline of ten. World 2 sat at nine.
6. **Divergence between seeds**, with within-seed spread smaller than between.
   Not establishable from one run per seed and will not be claimed from one.

**None of these is expected.** The honest prior is world 2's result: everything
sits still and every organ is discarded. The proof that forbade it is repealed by
this change, which is not the same as saying the outcome is repealed.

## The commitments

1. The rules are frozen before the first run and are not changed in response to
   what the first run shows.
2. Results are reported across many seeds as a distribution, including **nothing
   happened**.
3. If the physics changes again, that is world 4. This file is superseded rather
   than edited and its results retired rather than carried forward.
4. World 2's results are retired now, and world 1's remain retired.
