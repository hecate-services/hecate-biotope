# Results: world 21

**A creature carries what it just thought into the next tick.** Measured with
`scripts/sweep_neural.escript`, 48 seeds, 20,000 ticks, against the world 19/20
run of the identical script at the same cap.

## THE HEADLINE

**Memory is expressible now and it does not pay. It made a node dearer, so
fewer are carried, and slightly more seeds die.**

| `neural_cost` | dead/48 w19 → **w21** | hidden nodes w19 → **w21** | sensors w19 → **w21** |
|---|---|---|---|
| 330 control | 41 → **44** | 0.02 → 0.01 | 2.03 → 2.02 |
| 220 | 39 → **42** | 0.04 → 0.01 | 1.97 → 2.34 |
| 165 | 33 → **40** | 0.03 → 0.02 | 2.91 → 2.97 |
| 110 | 33 → **35** | 0.05 → 0.02 | 2.59 → 3.59 |
| 66 | 33 → **33** | 0.07 → 0.08 | 3.60 → 3.09 |
| 33 | 29 → **31** | 0.14 → 0.07 | 4.56 → 4.07 |
| **11** | **24 → 29** | 0.41 → 0.25 | 4.74 → 4.11 |
| 3 | 29 → **29** | 0.60 → 0.82 | 5.64 → 4.88 |
| 1 | 28 → **29** | 0.98 → 0.57 | 5.34 → 4.96 |

**Deaths are equal or worse at eight of nine prices.** At `neural_cost` 11, the
value chosen on viability, it is 29 against 24.

## Why, and it is not mysterious

**A NODE GOT DEARER AND NOTHING MADE IT WORTH MORE.** A hidden row went from
`sensors + 1` to `sensors + 1 + nodes` weights, so at world 19's control a node on
one sensor went from two live weights to three: a 50% price rise on the one organ
this world already carries least. `neural_cost` charges live wiring and memory is
wiring, which was the point of pricing it that way, and the bill arrived.

The census shows it directly: at `neural_cost` 11 hidden nodes fall from **0.41
to 0.25** per creature. Memory did not fail to be used. **It made computation
less affordable, so there was less of it to use memory with.**

## ⚠ AND ONE OBSERVATION MADE EARLIER TODAY IS WITHDRAWN

The determinism check, six seeds to 2,000 ticks, showed four surviving under
world 21 against one under world 19 and none under world 20, with lineage depth
69 to 80 against 30. It was reported as suggestive and explicitly not claimed.

**It was noise.** Six seeds on an instrument built to compare two runs of one
seed, not to measure survival. Forty-eight seeds at ten times the horizon say the
opposite. The lesson is `I.2`'s shape one more time: a summary of six runs cannot
answer a question about a distribution, and the temptation to read one is
strongest when it agrees with the thing just built.

## What this does NOT say

**It does not say memory is useless.** It says memory priced as ordinary wiring,
in a world where computation was already the least affordable organ, is a net
cost over 20,000 ticks. Three things would each change the test and none has been
run:

- **A horizon long enough to need it.** Mean life here is about nine ticks and a
  creature is evaluated against static ground. A strategy that pays only when
  conditions change cannot pay in a world that does not change.
- **Something worth remembering.** The environment has no periodicity, no day,
  no season, no moving resource. `J.1` and the watering hole would give memory
  something to be about.
- **A price of its own.** Recurrent weights are charged at the same rate as
  sensory ones. Nothing says they should be, and that is a constant nobody has
  swept.

## The register entries this earns

- `H.13` — **memory is expressible and unaffordable**, the same shape as `B.10`
  found for computation itself: the trait was never useless, it was priced out.
- `I.13` — **a six-seed instrument was read as a result** because it agreed with
  what had just been built.
