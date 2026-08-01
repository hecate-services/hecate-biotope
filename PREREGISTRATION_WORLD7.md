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
local order must be paid for with a larger disorder elsewhere. Every organism
pays it, which is why anabolism is expensive and catabolism releases energy.

**The DIRECTION is required. The SHAPE is chosen, and I say so rather than let
it read as derived.** Squaring gets building strictly harsher than everything
else using one constant instead of two. Any monotone penalty would satisfy the
law equally well. Logged with `D.5`.

**Where the line falls, since this is the third time it has come up.**
*Thermodynamics prices the steps. Chemistry counts them.* Building costs more
because it creates order, which is the Second Law speaking. Meat converts more
cheaply than ground because prey tissue resembles the consumer's, and how many
steps that saves is a fact about particular chemistry. The first is in this
world. The second is not, and is its own entry.

## Three things that would go wrong quietly

### The First Law does not currently hold, and cannot be added on top

A creature today pays metabolism it does not have, goes to minus thirty, dies,
and `whole()` floors at zero so **those thirty units never existed**. Charging
against nothing. A dissipation account laid over that will never close.

So spending is capped at what a creature actually holds across store and frame,
and it dies if that is not enough. The outcome is identical and the accounting
becomes true. **This is a rule change forced by the First Law**, not an extra.

### Integer truncation writes a rule nobody chose

At 60% efficiency, building fewer than three units yields zero frame and still
costs the store. That is a **minimum transaction size** appearing from nowhere.
It is left in, because the alternative is floating point and losing bit-exact
replay, but it is an artefact and not physics, and any threshold effect near the
low end of the sweep should be suspected of being this before anything else.

### The control does NOT reproduce world 6, and this was found the hard way

**This subsection originally claimed `E = 100` is world 6 exactly. It is not,
and the claim is withdrawn.** See the amendment below, which is the more
important part of this file.

## AMENDMENT: world 7 contains TWO changes, not one

**Written after the first sweep ran and before any results were written.**
Declared rather than absorbed quietly, because absorbing it quietly is how the
last comparison got muddied and I would be doing it twice.

### What the second change is

The First Law requires every cost to arrive in the dissipation account,
**including the movement fare**. In world 6 the fare used a raw subtraction that
pushed a creature's store negative, and a negative store was death. Every other
cost could be covered by catabolising your own frame. **The fare alone could
not.** Move when you could not afford it and you died, however much body you had
left to burn.

All costs are now payable alike. I believe that is correct, since nothing
justifies a fare being uniquely un-payable from your own tissue when metabolism
is not, and the First Law makes the old behaviour unrecoverable in any case. But
it is a **second change**, it was not pre-registered, and this document said the
opposite.

### What it did, measured before this was written

At `E = 100`, where **nothing is lossy and the Second Law can do nothing**:

| | `still%` | sensors per creature | hidden nodes per creature |
|---|---|---|---|
| world 6 | 99-100 | 0.00-0.01 | 0.00-0.01 |
| world 7 at `E = 100` | 97-98 | **2.52** | **1.80** |

Perception has been pinned at zero in every world since world 2. **It moved when
the accounting became honest, not when the physics did.**

### What the experiment therefore is

Not a two-way comparison that is now spoiled, but a three-way one that is
cleaner than what was originally planned, because the sweep already separates
the two changes:

| condition | what it isolates |
|---|---|
| world 6, published | the true control |
| world 7 at `E = 100` | the **First Law** fix alone |
| world 7 below `E = 100` | the **Second Law** on top of it |

Every finding below must therefore say **which of the two** it is attributed to,
and a result that appears at `E = 100` may not be credited to the Second Law
whatever else is true about it.

### Why this is in the file rather than fixed away

Reverting is not available: conservation requires the fare to be accounted. The
alternative was to leave the claim standing and let a reader assume the control
was world 6. That would have attributed this project's first perception to the
wrong law.

## The likely outcome, stated in advance

**The world may die across most of the range.** It already lives hand to mouth:
mean lifespan 2.2 ticks and a population permanently above what the ground can
feed. Take a real fraction off every transfer and it may not survive at all.

If it dies at 95% that says little about the Second Law and a great deal about
the other constants, namely **that they were only viable because transfers were
free**. That is a result and will be reported as one.

**One constant, and the ordering derives from counting steps rather than from
being asserted.** Six separate efficiencies would be six undefended numbers, and
real efficiencies do differ by process, but nothing in thermodynamics tells us by
how much. That one constant fits every site is a simplification and is logged as
register entry **D.5**.

### What is deliberately NOT done

- **No temperature.** Ornament at one temperature. See Zeroth above.
- **No separate entropy quantity.** It would be the dissipation account renamed.
- **No different step count for eating creatures than for eating ground**, which
  makes this world the test of whether predation pays without one. An earlier
  draft justified leaving it out by calling assimilation efficiency biology
  rather than thermodynamics. **That justification was wrong** and is withdrawn;
  it follows from the step-counting rule itself. See the predation section, which
  now predicts no direction at all.
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
3. **`from_creatures_pct` moves at all**, in either direction, having been 0 in
   all five seeds of world 6. No direction is predicted; see the section below.
4. **`ground_spread` rises above 11 to 13.** This is Prigogine's prediction and
   the sharpest one available: a system far from equilibrium should organise
   *because* structure dissipates a gradient faster than disorder does. World 6
   has genuine throughflow and produces almost no local order, and one candidate
   reason is that its dissipation has no structure at all, happening entirely as
   a flat per-tick tax. World 7 distributes it across every transformation.
5. **Something amortises.** Sensor carriers above the 0 to 11 they have been
   stuck at in every world, or hidden nodes above ~0.
6. **Age and size decouple.** Creatures of the same age at different sizes, which
   is what world 6 looked like and turned out not to be.

## What will NOT happen, stated in advance

**`still%` may well stay at 100.** That is the density relation and it is
untouched here.

## Predation: the direction is NOT predicted, and an earlier draft got this wrong

A first draft of this file predicted that predation would get worse, on the
grounds that energy in a creature has already been degraded once to get there.
**Raf objected that meat is denser than grass, and the objection is correct.**
The claim is withdrawn and no direction is predicted. What follows is why,
because the reasoning matters more than the retraction.

**Two different questions were conflated.** Whether carnivory is lossy for the
ECOSYSTEM, which it is and which is why food chains are short, is not the same
as whether eating a creature beats eating ground for an INDIVIDUAL deciding
right now. A uniform `E` scales both by the same factor and therefore changes
their ratio not at all.

**Two effects then fight, and which wins is not determined in advance:**

- lossy transformation means less energy reaches bodies at all, so prey get
  emptier, and predation is worth less
- longer lives, which is finding 1, mean more time to accumulate, so bodies get
  richer, and predation is worth more

**And the concentration argument is real.** A cell holds about 12 energy. A
large creature in world 6 held a frame of 100 to 130. Ten times as much, in one
place, and this world's `devour` takes the WHOLE of it instantly with no rate
limit, while grazing is capped by `uptake`. That asymmetry already favours
predation heavily and it is fiat rather than physics: see register entry `D.2`.

### What the paradigm actually says, which is the opposite of the first draft

Real carnivores assimilate about 80% of what they eat against roughly 20-50%
for herbivores. An earlier draft dismissed that as biology rather than
thermodynamics. **That dismissal was wrong**, because under this world's own
step-counting rule it follows directly: the number of degradation steps depends
on how far the source material sits from the destination, and prey tissue is
already organised much like the consumer's own.

Taken seriously, eating a body could hand a creature **ready-made structure at
`E`, one step to reorganise**, where building the same frame from its own store
costs `E²`. **Predation as a shortcut to structure**, derived from the paradigm
rather than asserted, and the exact thermodynamic form of Raf's point about
energy density.

**World 7 does NOT include it**, deliberately. It keeps a uniform step count
everywhere, which makes this world the test of whether predation can pay
WITHOUT the shortcut. If predation dies here, that is evidence the differentiated
version is needed, and entry `D.5` acquires a physical justification instead of
remaining a preference. Building both at once would leave neither answered.

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
