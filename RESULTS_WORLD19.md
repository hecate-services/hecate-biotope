# Results: world 19

**A weight costs only if it is non-zero.** Scored against
`PREREGISTRATION_WORLD19.md`, frozen before the rules.
`scripts/sweep_neural.escript`, 48 seeds, **20,000 ticks**.

## ⚠ RE-RUN 2026-08-03: THE CAP WAS BINDING AND THE SWEEP WAS RE-RUN

**`max_sensors` was 8 and 18 to 22% of the population sat at it**, so the sensor
column below was partly a ceiling. `B.11`. The cap is now **12**, chosen by a rule
fixed before the numbers (the smallest leaving under 5% at it), and the whole
sweep was re-run at 48 seeds and 20,000 ticks. `AT-CAP` is **0 at every price**
now, so the sweep certifies its own sensor column rather than leaving a reader to
wonder.

| `neural_cost` | dead/48 | sensors | hidden nodes | WIDTH |
|---|---|---|---|---|
| | old → new | old → new | old → new | old → new |
| 330 control | 41 → **41** | 2.03 → **2.03** | 0.02 → **0.02** | 3.00 → **3.00** |
| 220 | 39 → **39** | 1.97 → **1.97** | 0.04 → **0.04** | 3.00 → **3.00** |
| 165 | 33 → **33** | 2.91 → **2.91** | 0.03 → **0.03** | 3.00 → **3.00** |
| 110 | 33 → **33** | 2.59 → **2.59** | 0.05 → **0.05** | 2.90 → **2.90** |
| 66 | 33 → **33** | 3.86 → 3.60 | 0.05 → 0.07 | 4.00 → **4.00** |
| 33 | 29 → **29** | 4.56 → **4.56** | 0.06 → 0.14 | 4.66 → 4.62 |
| **11** | **24 → 24** | 4.94 → 4.74 | 0.53 → 0.41 | 5.54 → 5.00 |
| 3 | 29 → **29** | 4.85 → 5.64 | 0.30 → 0.60 | 5.53 → 6.00 |
| 1 | 28 → **28** | 5.90 → 5.34 | 1.11 → 0.98 | 6.20 → 5.93 |

### 1. THE HEADLINE IS UNTOUCHED, AT EVERY PRICE

**Deaths are identical in all nine rows: 41, 39, 33, 33, 33, 29, 24, 29, 28.**
Not close, identical. `neural_cost` 11 is still the best value on viability at 24
of 48, still against 41 at the control, and `B.10` stands exactly as written. The
one criterion this project allows for setting a constant did not move at all.

### 2. THE FOUR MOST EXPENSIVE ROWS ARE BYTE-IDENTICAL, WHICH IS THE CHECK

330 through 110 reproduce the old run in every column. That is what a
non-binding valve looks like and it is the reason to believe the rest: **a
creature that cannot afford eight sensors never meets the cap**, so those rows
could not have changed, and if they had, something other than the cap would have
been different between the runs.

### 3. THE HIDDEN-NODE RESPONSE BECAME MONOTONE

Old: 0.02, 0.04, 0.03, 0.05, 0.05, 0.06, **0.53, 0.30**, 1.11 — a fall from 11 to
3 in the middle of a rising trend. New: 0.02, 0.04, 0.03, 0.05, 0.07, 0.14,
**0.41, 0.60, 0.98** — rising throughout the cheap half. The reversal was an
artefact of the cap: sensors and nodes compete for the same tissue budget, so a
population pinned at eight sensors was spending on perception it could not
economise on.

### 4. THE SENSOR SLOPE SURVIVES AND IS NOISIER THAN IT LOOKED

2.03 at the control to 5.34 at the cheapest, so "sensors respond to the price of
tissue" holds. But it is **no longer monotone at the cheap end**: 5.64 at
`neural_cost` 3 against 5.34 at 1. The old run's smooth climb to 5.90 was partly
the ceiling doing the smoothing, and the honest reading is that below about 11
the sensor count stops being an ordered response to price.

**AND ONE NUMBER QUOTED ELSEWHERE IS WITHDRAWN.** "5.90 sensors at `neural_cost`
1" appears in `B.10` and in the text below. It is **5.34** under a valve that is
not binding, and the 5.90 was measured with a fifth of the population pinned at
the cap.

Everything below this line is the original write-up, at `max_sensors` 8, kept
because the correction is only legible against it.

---

## THE HEADLINE

**Width became expressible and selection did not use it. The price was the thing
that mattered, and it was set three decades of worlds ago to match a rule that
had been deleted.**

| `neural_cost` | dead/48 | pop | sensors | hidden nodes | WIDTH | width as % of full |
|---|---|---|---|---|---|---|
| **330** control | **41** | 63 | 2.03 | 0.02 | 3.00 | 99% |
| 220 | 39 | 61 | 1.97 | 0.04 | 3.00 | ~100% |
| 165 | 33 | 78 | 2.91 | 0.03 | 3.00 | 77% |
| 110 | 33 | 80 | 2.59 | 0.05 | 2.90 | 81% |
| 66 | 33 | 76 | 3.86 | 0.05 | 4.00 | 82% |
| 33 | 29 | 71 | 4.56 | 0.06 | 4.66 | 84% |
| **11** | **24** | 74 | 4.94 | **0.53** | 5.54 | 93% |
| 3 | 29 | 81 | 4.85 | 0.30 | 5.53 | 95% |
| 1 | 28 | 65 | 5.90 | **1.11** | 6.20 | 90% |

## The four pre-registered findings

**1. Brains get narrower. THE PRE-REGISTERED NEGATIVE LANDED INSTEAD.**

Width is a trait now: the rule changed and a lineage *can* economise. **It does
not.** Live weights per node run 77% to 100% of the full `sensors + 1`, and the
baseline before anything rewarded silence was **85% to 97%**, censused over four
worlds. The measured widths sit inside the range that unpriced zeros already
occupied.

The pre-registration said exactly this would be the risk: *"Drift is symmetric
and will knock a weight off zero as readily as onto it, so a saving of 10.6% of
income has to be held there by selection every generation. If nodes get cheaper
and no narrower, that is drift winning."*

**Drift won.** `brain_mutation` is 1 on a range of ±8, so every birth is a fresh
chance to un-silence a connection, and a saving must be re-won every generation
against a mutation operator that does not care.

**⚠ AND A SHORTER RUN SAID THE OPPOSITE, WHICH IS THE INSTRUMENT LESSON.** At
2,000 ticks the same sweep read WIDTH 1.00 at the control, a third of full, and
looked like a clean monotone narrowing. It was a median over the ~1% of creatures
carrying any node at all. **At the expensive end this column is measured on a
handful of individuals and should not be read there.**

**2. Hidden nodes become common. PARTIAL.** 0.02 per creature at the control to
**1.11** at the cheapest, a fifty-fold response. But even at the cheapest price a
creature carries **1.11 nodes against 5.90 sensors**. Computation responds to
price and never overtakes perception.

**3. The price at which computation appears moves down. NO.** The step is between
33 and 11, where world 13 put it between 110 and 66. Making a node able to be
narrow did not make it appear sooner, because it did not become narrow.

**4. Survival improves. LANDED, AND IT IS THE RESULT.** **41 of 48 dead at the
control against 24 at `neural_cost` 11.** The control kills 85% of the seeds it
is given; 11 kills 50%. Replicated at both horizons: the 2,000-tick run read 40
against 23.

## `B.10` is confirmed on viability

The control was never chosen. Its own comment says it is 330 *"because at the
divisor of 33 it reproduces the old flat rent of 10 a tick exactly"* — the flat
rent world 13 deleted as a defect and `B.2` and `B.3` both objected to. **A
constant calibrated to reproduce the thing it replaced.**

Measured on reproducible physics, it is **the worst value on the sweep bar one**,
and it has been in force for six worlds. Every result about brains not appearing
from world 13 onward was measured there.

**AND ONE CLAIM MADE EARLIER TODAY IS WITHDRAWN.** On the short run I said a node
had become cheaper than a sensor and was carried 186 times less often, therefore
price could not be what suppressed computation. That rested on the WIDTH of 1.00
which did not survive the horizon. At 20,000 ticks a node at the control is 3.00
weights against a sensor's 1, so **it costs three times a sensor and is carried a
hundred times less**, which is entirely consistent with price mattering. The
inference was drawn from the artefact, not the measurement.

## `neural_cost` is 11, on viability and nothing else

Fewest extinctions: 24 of 48, against 41, 39, 33, 33, 33, 29, 29 and 28. No part
of the choice refers to sensors, nodes, width, population or depth. The whole
sweep is above so the criterion can be checked rather than trusted.

**It is a thirty-fold reduction and it is the largest single change to this
world's economy since world 13 made an organ tissue.** At 11 a creature carries
4.94 sensors against the control's 2.03, and 0.53 hidden nodes against 0.02.

## What this leaves

- **Silencing is expressible and not holdable.** The obvious follow-up is
  whether a lower `brain_mutation` lets selection hold a zero, which is a
  question about the mutation operator rather than about brains, and `H.10`
  already says the operator decides more here than the ecology does.
- **A node still loses to a sensor at every price.** A sensor brings information
  into the creature; a hidden node only recombines what the outputs already read
  directly, since every output reads every input. **The marginal value of a node
  is the value of the nonlinearity alone**, and nothing has measured that.
- **`D.7` and `J.1` are unblocked.** The plan held the watering hole behind
  `B.10` so that water would not be measured in a world whose harshness was an
  accident. It is no longer an accident.
