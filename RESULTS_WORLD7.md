# Results: world 7

**The change:** every energy transformation loses a share, at all six sites,
with building paying twice because creating order must be paid for with a larger
disorder elsewhere. One constant, **swept from 100% down to 10% rather than
chosen**.

Corrects register entry **D.3**. Pre-registered in
[PREREGISTRATION.md](PREREGISTRATION.md), **including an amendment declaring a
second change that was not pre-registered**, written before these results.

5 seeds, 2000 ticks, 11 efficiencies.

## Read this first: there are three conditions, not two

World 7 contains two changes. The sweep separates them, and **every finding
below says which one it belongs to.**

| condition | isolates |
|---|---|
| world 6, published | the true control |
| world 7 at `E = 100`, where nothing is lossy | the **First Law** fix alone |
| world 7 below `E = 100` | the **Second Law** on top of it |

A result that appears at `E = 100` **cannot be the Second Law**, because at 100%
no transformation loses anything. That rule decides most of what follows.

## The headline, and it is not the one that was expected

**Perception has been pinned at zero in every world since world 2. It moved. And
it moved for the First Law, not the Second.**

Same probe, same parameters, at an efficiency where nothing is lossy:

| | `still%` | sensors per creature | hidden nodes per creature |
|---|---|---|---|
| world 6 | 99-100 | 0.00-0.01 | 0.00-0.01 |
| world 7 at `E = 100` | 97-98 | **2.52** | **1.80** |

The cause is the accounting. Conservation requires the movement fare to be
charged like everything else, and once it is, it becomes payable by catabolising
your own frame. **In world 6 the fare alone was not.** Move when you could not
afford it and you died, however much body you had left to burn. That single
asymmetry was holding perception at zero for five worlds.

So the finding is uncomfortable and worth stating plainly: **the world's first
eyes appeared when the books became honest, not when the physics did.**

## Against what was pre-registered

| # | Finding | Result | Whose |
|---|---|---|---|
| 1 | **Lifespan rises above 2.2 ticks** | **FAILED, and the opposite happened.** 2.19 at `E = 100`, falling to 1.24 by `E = 20`. | Second Law made it worse |
| 2 | **Density falls below ~2,300** | **CONFIRMED, but only below 50%.** 2,414 at 50%, then 1,038, 768, 519, 202. | Second Law |
| 3 | **`from_creatures_pct` moves at all** | **FAILED.** 0 at every efficiency, and 0 individuals living off creatures. | neither |
| 4 | **`ground_spread` rises above 11-13** | **CONFIRMED strongly.** 12-15 down to `E = 50`, then 27, 29, 30, 30. | **Second Law** |
| 5 | **Something amortises** | **CONFIRMED, hugely.** Sensors 0.01 to 2.52, hidden nodes 0.01 to 1.80. | **First Law** |
| 6 | **Age and size decouple** | **NOT ANSWERED.** The sweep does not measure age against frame, and below 70% there is no frame left to measure. | — |

## The sweep

`life` is mean ticks alive times 100, so 219 is 2.19. `gspr` is ground energy in
the richest tenth of cells, where 10 is flat. `burnt` is the dissipation
account, which at one temperature is the entropy account.

| eff% | dead | pop | life | gspr | meat% | meat# | store | frame | eats | sens | brain | burnt |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 100 | 0 | 2314 | 219 | 15 | 0 | 0 | 48 | 102 | 246 | 3063 | 180 | 30565677 |
| 95 | 0 | 2425 | 203 | 13 | 0 | 0 | 29 | 9 | 253 | 3527 | 187 | 30582465 |
| 90 | 0 | 2419 | 204 | 14 | 0 | 0 | 32 | 8 | 265 | 3862 | 231 | 30582349 |
| 80 | 0 | 2431 | 204 | 13 | 0 | 0 | 22 | 6 | 240 | 4064 | 191 | 30575689 |
| 70 | 0 | 2424 | 204 | 12 | 0 | 0 | 21 | 0 | 248 | 2966 | 183 | 30588717 |
| 60 | 0 | 2428 | 204 | 13 | 0 | 0 | 18 | 0 | 230 | 3967 | 209 | 30580886 |
| 50 | 0 | 2414 | 203 | 14 | 0 | 0 | 12 | 0 | 255 | 3065 | 219 | 30583729 |
| 40 | 0 | 1038 | 149 | 27 | 0 | 0 | 24 | 0 | 79 | 1207 | 201 | 30541889 |
| 30 | 0 | 768 | 134 | 29 | 0 | 0 | 23 | 0 | 68 | 533 | 219 | 30532494 |
| 20 | 0 | 519 | 124 | 30 | 0 | 0 | 20 | 0 | 149 | 884 | 159 | 30510500 |
| 10 | **2** | 202 | 138 | 30 | 0 | 0 | 25 | 0 | 361 | 672 | 182 | 30540454 |

## What the Second Law did

### It differentiated the landscape, which is the one thing pre-registered from theory

`ground_spread` sits at 12-15 from 100% down to 50%, then jumps to **27, 29, 30,
30**. Flat is 10. World 4 reached 26-86 and world 5 and 6 fell back to 9-15.

This was finding 4 and it was Prigogine's prediction: a system held far from
equilibrium should organise, because structure dissipates a gradient faster than
disorder does. It is credited to the Second Law rather than the First on the
rule above, since it does not appear at 100% and it **tracks the efficiency**
rather than switching on.

The mechanism is not established. The obvious candidate is that a smaller
population grazes less uniformly, since density collapses over the same range.
**Spread and density are confounded here and this run cannot separate them.**

### It destroyed structure, and did so far too sharply

Largest frame: 102 at 100%, **9 at 95%**, 8, 6, then **0 from 70% down**.

A 5% cost removed 91% of the structure. That response is wildly out of
proportion to its cause, and there are two readings:

- **Real.** Building pays the efficiency twice and starving pays it again on the
  way back out, so the round trip out to a frame and home is heavily lossy. In a
  world where the mean life is two ticks, a body you paid a premium for is never
  recovered. Under that reading, **world 6's store and frame split is undone by
  world 7**: frames stop existing the moment they cost anything.
- **An artefact**, and it was named in advance. Integer truncation writes a
  minimum transaction size: at low efficiency a small build yields nothing and
  still costs the store. The pre-registration says any threshold effect should be
  suspected of being this first, and this is a threshold effect.

Distinguishing them takes a run at finer efficiency steps between 95 and 100 and
was not done.

### It shortened lives rather than lengthening them

Finding 1 was the direct target and it failed in the opposite direction: 2.19 at
the top, 1.24 by `E = 20`. Pricing transformation did not make breeding every
tick stop being the dominant move. It made everything poorer instead.

## What the First Law did

Everything in the headline: sensors, hidden nodes, and movement off 100% still.
All of it present at `E = 100`, where the Second Law does nothing.

**It also made the First Law testable at all**, which is the quieter half. Before
this, metabolism vanished from the books and a creature could pay costs it did
not have. There is now a dissipation account, `ground + stores + frames +
dissipated` is exactly constant apart from the sun, and it is asserted at seven
efficiencies. Breaking the accounting at a single site turns that test red, which
was checked rather than assumed.

## Two predictions I made in advance and got wrong

**"The world may die across most of the range."** It does not. 5 of 5 seeds
survive down to 20%, and only at 10% do 2 of 5 die. The world is far more robust
to dissipation than I expected.

**"`still%` may well stay at 100."** It dropped to 97-98. Small, and the first
movement this project has recorded.

## One thing nobody predicted, and it is a First Law consequence

**`burnt` is essentially constant across the entire sweep**, 30.51M to 30.59M, a
spread of under 0.3% while efficiency falls by a factor of ten.

That has to be true and it is worth saying why. In a steady state everything the
sun puts in must eventually leave as heat, so **total dissipation is set by the
supply, not by the efficiency**. Efficiency does not change how much the world
burns. It changes how much living gets done per unit burned.

Which reframes the whole sweep: the low-efficiency rows are not poorer worlds
burning less. They are the same fire supporting fewer creatures.

## What this leaves for the register

- **D.3 is corrected.** The Second Law is present at every site and the First Law
  is a test rather than a claim.
- **A new entry is owed** for the movement fare asymmetry, since it was a real
  and unregistered rule that held perception at zero for five worlds, and nothing
  in the register named it.
- **D.5, one efficiency for all six sites, is now the live question.** Structure
  collapsing at 95% says the building penalty is doing almost all the work, and
  whether that is physics or integer truncation is unresolved.
- **`C.3`, reproduction is free, survives untouched.** Lifespan did not move,
  which is the constraint underneath every null here, and world 7 did not reach
  it.
