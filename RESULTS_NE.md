# `Ne` measured at last: about **7**, where every gate assumed 35 to 70

**The effective population of this world is roughly a tenth of its census, and
the drift floor is therefore several percent rather than under one.** Measured
with `scripts/how_small_is_this_population_really.escript`, 12 seeds, 4,000
ticks, world 22.

## THE NUMBER

| | |
|---|---|
| harmonic census, over the seeds that coalesced | **87.95** |
| `Ne`, coalescent estimate | **7.44** |
| `Ne` as a share of census | **8.5%** |
| **the drift floor, `1 / (2·Ne)`** | **6.72%** |
| what every gate in this project has assumed | **0.71% to 1.43%** |

**The floor is five to ten times higher than every selectability gate has
computed against.** `R.1` exists because world 15 ran forty-eight seeds to twenty
thousand ticks measuring a trait that drift was moving. This says world 15 was
not an isolated failure.

## What that does to the gates already run

| world | trait | its selection differential | against a 6.72% floor |
|---|---|---|---|
| 15 | a mouth | **0.24%** | **28× below.** Could not have worked. |
| 18 | an act, at `act_cost` 16 | **1.34%** | **5× below.** "At 16 nothing visible happens" — measured, and now explained. |
| 23 (proposed) | spoiling | **1.34%** | **5× below.** The gate passed it as "marginal, and marginal is acceptable here". It is not marginal. It is invisible. |
| 19 | silencing a hidden node | **10.6%** | **1.6× above.** Marginal in fact, and world 19 found drift winning, which is what barely-above-the-floor looks like. |

**Three worlds of "expressible and unused" now have one candidate cause, and it
is not any of the three capacities.** It is that the population which actually
breeds this world's future is about seven creatures.

## Why `Ne` is so far below the census

**Reproduction is extraordinarily unequal.** Measured at death, over completed
lives, across every seed:

| | |
|---|---|
| mean offspring per creature | **0.91 to 0.99** |
| variance in offspring | **8 to 104** |

A variance-to-mean ratio of 20 to 100. Most creatures leave nothing — 64% of
deaths are predation and the mean life is ten ticks — and a few leave a great
many. **The future comes from the few, and drift is set by how few.**

## ⚠ TWO BIASES, IN OPPOSITE DIRECTIONS, BOTH STATED

**Generation time is taken from `depth`, which counts generations along the
DEEPEST living line — the fastest breeder in the world.** That underestimates
generation time, overestimates the number of generations elapsed, and therefore
**overestimates `Ne`**. The true figure is at most 7.44.

**Only 5 of 12 seeds coalesced inside 4,000 ticks and only those are read.** A
seed with a larger `Ne` takes longer to coalesce and is censored by the window,
so the surviving sample is biased toward small `Ne` and **underestimates** it.

The two pull opposite ways and neither magnitude is known. **The robust claim is
the order of magnitude: `Ne` is about ten, not about seventy, and the floor is
several percent, not a fraction of one.** Even at a factor of two either way,
every trait priced under 1.4% is beneath it.

## And the second estimator, reported with its assumption broken

Crow and Kimura's variance formula gives **2.55**, and it assumes discrete
non-overlapping generations: everybody breeds, then everybody dies. This world
has neither, and applied here the formula returns values below one for some
seeds, which is not a population size. **It is in the table for its inputs, not
its output** — the offspring variance above is measured and real, and it says
`Ne` is far below `N` however the number is assembled.

The coalescent estimate is the one to read: it integrates over the actual
history, overlapping generations and all.

## What is owed

1. **Every gate in the register should be re-read against 6.72%**, not
   recomputed silently. World 23's pre-registration says its cost is "marginal,
   and marginal is the right answer here". That sentence is now wrong and the
   document is superseded rather than edited.
2. **A better generation time.** `depth` is the fastest line, not the mean.
   Mean age at reproduction would need a per-creature record of when it bred,
   which is one more counter beside `bred`.
3. **A longer window**, so the seeds with larger `Ne` are not censored out.
