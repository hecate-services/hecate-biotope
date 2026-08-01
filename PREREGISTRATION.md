# Pre-registration: world 7

**Written before world 7 was built.** Corrects register entry **D.3**. World 6 is
superseded, not edited: [PREREGISTRATION_WORLD6.md](PREREGISTRATION_WORLD6.md)
and its [results](RESULTS_WORLD6.md) stand as the record of a different world.

## The paradigm, stated once

**Thermodynamics at the classical scale is the governing law of this world, and
no rule may violate one or evade one.** Raf's, and it is the right foundation:
the laws are the only physics we have that is not contingent on Earth, on
carbon, or on evolution having happened. Everything else we have written is a
constant somebody chose or biology smuggled in wearing a physics coat.

Two limits on that, named so nobody has to rediscover them.

**The laws constrain, they do not specify.** You cannot run a simulation of the
Second Law. That a creature exists, occupies a hex and reaches seven cells is
not thermodynamics and never will be. So the operative rule is the weaker and
still ruthless one: **no rule may create energy, and none may transform it for
free.**

**The laws give the sign, never the size.** The Second Law says efficiency is
below one. It does not say what it is. Carnot bounds a heat engine by its
temperatures and this world has none. So one free constant survives, and it is
**swept rather than chosen**, for reasons under "What may set a constant".

## The four laws against this world

Applied one at a time, honestly, including where a law has nothing to say.

### Zeroth: temperature is consistent and transitive

**VACUOUS HERE, and deliberately left so.** This world is **isothermal**: it sits
in contact with a heat sink at one fixed temperature, and degraded energy leaves
freely. With one temperature everywhere the Zeroth Law is trivially satisfied and
does no work.

**Temperature is therefore NOT introduced, because it would be ornament.** It
would be a number that changes nothing. Temperature earns its place only when the
sink becomes finite, so heat accumulates where it is made and export is limited.
That is a separate register entry and a later world, and it is where the Zeroth
Law starts mattering.

### First: energy is conserved

**LIVE, and currently untested.** Metabolism, rent and movement fares simply
**vanish** from the books today. The books test checks that the tracked pools
agree with each other, which is a weaker statement than conservation, and the
world has therefore never actually been audited.

World 7 adds a **dissipation account**. Every unit that leaves a creature arrives
somewhere, so

    ground + stores + frames + dissipated

is exactly constant except for what the sun adds. The First Law becomes an exact
equality test instead of an approximate one.

**This is an instrument, not ornament.** The distinction matters given the no
ornament rule, so here it is: **ornament is a RULE that changes nothing.** An
observable that measures something is not ornament, and a counter that turns a
law from a claim into a test is the opposite of it.

### Second: entropy never decreases

**LIVE, and completely absent today.** Every transformation in this world is
perfectly efficient, which is a perpetual motion machine of the second kind. The
round trip from store to frame and back returns exactly what it cost.

At fixed temperature, in units where `T = 1`, entropy production **is** the heat
produced. So the dissipation account above is the entropy account, and the Second
Law becomes the testable statement that it never decreases. No separate entropy
number is invented, because at one temperature it would be the same number twice.

### Third: entropy approaches a constant as temperature approaches zero

**VACUOUS HERE.** Nothing approaches zero temperature in an isothermal world.
Stated rather than quietly skipped, so the claim to comply with all four is not
doing work it has not earned.

## The single change

**Every energy transformation pays a degradation cost, and the cost is counted
in STEPS.**

One constant `E`, the efficiency of one degradation step. A transformation that
takes two steps pays `E` twice. That is the whole rule, and the six sites fall
out of it rather than being assigned:

| # | transformation | steps | efficiency |
|---|---|---|---|
| 1 | ground into a store | absorb | `E` |
| 2 | creature into a store | assimilate | `E` |
| 3 | **store into frame** | mobilise, then synthesise | **`E²`** |
| 4 | frame into store | catabolise | `E` |
| 5 | parent into child | divide | `E` |
| 6 | corpse into ground | decay | `E` |

**Why building is the expensive one, and why that is not a preference.** Turning
a store into a frame creates a low-entropy structure, and the Second Law says
local order has to be paid for with a larger disorder elsewhere. It is two
transformations, not one: the store is mobilised and then synthesised into
structure. Every organism pays this, which is why anabolism is expensive and
catabolism releases energy.

**One constant, and the ordering derives from counting steps rather than from
being asserted.** Six separate efficiencies would be six undefended numbers, and
real efficiencies do differ by process, but nothing in thermodynamics tells us by
how much. That one constant fits every site is a simplification and is logged as
register entry **D.5**.

### What is deliberately NOT done

- **No temperature.** Ornament at one temperature. See Zeroth above.
- **No separate entropy quantity.** It would be the dissipation account renamed.
- **No different efficiency for eating creatures than for eating ground.** Real
  carnivores assimilate better than herbivores, but that is a **biological** fact
  about tissue similarity, not a thermodynamic law, and this world may not write
  it. See the prediction below, which follows from refusing it.
- **No finite heat sink.** It is the interesting entry and it is a second change.

## What may set a constant

`E` is **swept, not chosen.** The run reports every value from 95% down to the
point where the world dies, and the extinction boundary is part of the result.

This is the strongest available defence against steering: a value cannot be
picked for the result it gives if all of them are published. Thermodynamics fixes
the sign and has nothing to say about the size, and inventing a criterion to
manufacture a single number would be exactly the tuning-for-outcome this project
forbids.

## What will be reported

Everything that varies, at every value of `E`, with none of it privileged. Plus
the dissipation account, which is new, and `ground_spread`, which for the first
time is a prediction rather than a curiosity.

## What would count as a finding

Stated in advance.

1. **Lifespan rises above 2.2 ticks.** The direct target. World 6 showed a mean
   lifespan of 2.2 ticks against a `max_age` of 600, with 309 creatures out of
   2,150,092 births ever reaching it, and **no apparatus can amortise over two
   ticks**. Pricing building and reproduction should make breeding every tick
   stop being the dominant move.
2. **Density falls below world 6's ~2,300**, and the population stops sitting
   permanently above what the ground can feed.
3. **`ground_spread` rises above 11 to 13.** This is Prigogine's prediction and
   the sharpest one available: a system far from equilibrium should organise
   *because* structure dissipates a gradient faster than disorder does. World 6
   has genuine throughflow and produces almost no local order, and one candidate
   reason is that its dissipation has no structure at all, happening entirely as
   a flat per-tick tax. World 7 distributes it across every transformation.
4. **Something amortises.** Sensor carriers above the 0 to 11 they have been
   stuck at in every world, or hidden nodes above ~0.
5. **Age and size decouple.** Creatures of the same age at different sizes, which
   is what world 6 looked like and turned out not to be.

## What will NOT happen, stated in advance

**Predation will get worse, not better, and that is correct physics.** A uniform
`E` does not make eating creatures more profitable than eating ground, since both
lose the same fraction in one step. But the energy in a creature has already been
through one transformation to get there, so eating it is **cumulatively** lossier
than eating the ground it came from. That is precisely why real food chains are
short and top predators rare.

So `from_creatures_pct` should **fall**. If it rises, something is wrong with the
implementation rather than interesting about the world.

This is worth stating plainly because it cuts against what we have been hoping
for since world 1. Thermodynamics says carnivory is a worse living unless it buys
something back, and this world refuses to write the thing that buys it back.

**`still%` may well stay at 100.** That is the density relation and it is
untouched here.

## The commitments

1. Rules frozen before the first run, not changed in response to it.
2. Reported across many seeds and every value of `E`, including **nothing
   happened**.
3. A further change is world 8. This file is superseded, not edited.
4. Worlds 1 to 6 are retired and may not be quoted alongside this.
5. **The full thermodynamic audit of the register follows this world**, applying
   one test to every entry: required by physics, permitted by it, or contrary to
   it. `max_age` as a counter, contests decided by size, and a movement fare
   independent of mass are already known to fail it.
