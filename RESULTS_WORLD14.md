# Results: world 14

**The change:** bare ground comes back from what is around it. `ground_seed` is
deleted and the floor under a cell is a share of the mean stock of its
neighbours, at a swept `recolonise_pct`.

Corrects register entry **A.5**, and **A.2** and **G.4** with it. Pre-registered
in [PREREGISTRATION_WORLD14.md](PREREGISTRATION_WORLD14.md).

24 seeds, 4,000 ticks, 100% efficiency, `neural_cost` pinned at 330 throughout.
**Control is 3**, which on a full board is a floor of 12: the `ground_seed`
worlds 2 to 13 used.

| rate | floor | dead | **spread** | sessile | mobile | **sensors** | still % | lines |
|---|---|---|---|---|---|---|---|---|
| 0 | 0 | **24** | - | 0 | 0 | - | - | - |
| 1 | 4 | 22 | **43** | **0** | 2 | **1.69** | 28 | 1 |
| 2 | 8 | 22 | **46** | **0** | 2 | **2.76** | 25 | 1 |
| **3** | **12** | **22** | **33** | **0** | **2** | **1.50** | **13** | 1 |
| 4 | 16 | 21 | **54** | **0** | 3 | **1.90** | 40 | 1 |
| 6 | 24 | 22 | **57** | **0** | 2 | **2.08** | 52 | 1 |
| 9 | 36 | 21 | 45 | 1 | 2 | 2.58 | 67 | 1 |
| 12 | 48 | 17 | 58 | 6 | 1 | 0.93 | 88 | 1 |
| 18 | 72 | **8** | 50 | **15** | 1 | 0.60 | **98** | 1 |

## The headline

**All four pre-registered findings landed. That has not happened here before.**

Compare the control row against world 13 at the same nominal floor of 12, which
is the same physics everywhere except once a neighbourhood has been grazed down:

| | world 13 | **world 14** |
|---|---|---|
| `ground_spread` | 22 to 25 | **33** |
| surviving worlds that are sessile | **7 of 8** | **0 of 2** |
| sensors per creature | 0.12 | **1.50** |
| `still_pct` | 99 to 100 | **13** |
| seeds dead of 24 | 16 | **22** |

**The lawn is gone.** Zero sessile survivors at every rate from 1 to 6, twelve
surviving worlds, all of them mobile. If the sessile share were still the 7-in-8
world 13 held at every floor tested, the chance of seeing none in twelve is about
one in seventeen billion.

## Against what was pre-registered

| # | Finding | Result |
|---|---|---|
| 1 | **The board becomes spatially structured**, `ground_spread` above the 22 to 25 it has held since world 12. The mechanism check, which voids the rest if it fails | **LANDED at every value with survivors**: 43, 46, 33, 54, 57, 45, 58, 50. At the control the same nominal floor produces 33 against 22 to 25. |
| 2 | **Being common costs something**, the sessile share falling below 7-of-8 | **LANDED, to zero.** A dense sessile population grazes its neighbourhood flat and a flat neighbourhood supplies no floor. **G.4** has been open since the section was written and no world had touched it. |
| 3 | **Perception rises above the 0.12 to 0.65 band** the floor sweep measured across every value of a constant | **LANDED, twelve-fold at the control.** 1.50 against 0.12, with the price of a sensor pinned at 330 throughout. |
| 4 | **`still_pct` falls** from 99 to 100 | **LANDED.** 13 at the control, and 13 to 52 across the whole lower half of the sweep. |

And what was pre-registered **not** to happen:

| Prediction | Result |
|---|---|
| **Extinctions will rise, and the world may sterilise** | **CONFIRMED, and it is the price of this world.** 22 of 24 dead at the control against world 13's 16, and `recolonise_pct = 0` kills all 24 exactly as a floor of 0 did. |
| **G.1 is untouched, every survivor at one founding line** | **CONFIRMED.** `lines` is 1 at every value in the sweep. |
| **There is still no variation in time** | **CONFIRMED.** A.4, G.3 and G.5 are untouched. This board varies in space as a consequence of what creatures do, and no tick differs from any other. |
| **The most likely outcome is still nothing** | **Wrong, and this is the first world where all four positive findings landed.** |

## The mechanism is confirmed, not just the headline

The pre-registration asked for something sharper than "perception rose": it asked
that sensors stay roughly constant **within** the mobile regime while the mobile
**share** grows, because that is what "perception belongs to a way of life"
predicts, and the opposite would mean the headline moved for a different reason.

Sensors per creature among mobile worlds: **1.69, 2.76, 1.50, 1.90, 2.08, 3.48,
1.94, 2.80.** No trend across a sweep that changes the floor eighteen-fold. The
mobile share went from 1-of-8 under world 13 to 2-of-2. **The mix changed and the
within-regime value did not**, which is exactly the shape that was written down
before the run.

## The other half of the sweep, which is monotone and is the cost

Raising the rate rebuilds the lawn and buys back survival:

| rate | 1 | 2 | 3 | 4 | 6 | 9 | 12 | 18 |
|---|---|---|---|---|---|---|---|---|
| sessile worlds | 0 | 0 | 0 | 0 | 0 | 1 | 6 | **15** |
| dead of 24 | 22 | 22 | 22 | 21 | 22 | 21 | 17 | **8** |
| sensors | 1.69 | 2.76 | 1.50 | 1.90 | 2.08 | 2.58 | 0.93 | **0.60** |
| still % | 28 | 25 | 13 | 40 | 52 | 67 | 88 | **98** |

A better-connected board is a more survivable board and a blinder one. **This
world is either harsh and seeing or generous and sightless**, and there is no
value in the sweep that is both. That is a genuine tradeoff and it is not one
anybody chose: it falls out of the same mechanism read at two strengths.

## What this does not settle, stated plainly

**Two survivors a row is thin.** At rates 1 to 6 each row is a mean over two
worlds. The direction repeats across six independent values and twelve surviving
worlds, which is what makes it strong, but no single row here would carry a claim
on its own.

**Whether the sensors are USED is still not established.** Carrying an organ and
reading it are different things and this measures carriage. That question needs a
lesion: take an evolved population, zero the sensor inputs, and see whether it
does worse. It has never been run and world 13's results file says the same.

**The mobile regime is not a second way of living, it is the only one left.**
`lines` is 1 at every value. Frequency dependence arrived and coexistence did
not, which is Chesson's distinction landing exactly where the register said it
would: this is a stabilising mechanism acting on a strategy, and it produced one
strategy rather than two.

**And it may be too harsh to deploy.** At the control 22 of 24 seeds die by tick
4,000. Screening tries 24 candidates and keeps one alive at tick 700, so an
island would usually find something to run, and some of what it finds will die
later. That is a deployment question and not a result.

## What this world teaches

- **A comment that describes a mechanism the code does not implement is a
  finding waiting to be collected.** `ground.erl` has said the floor is
  recolonisation from the surroundings since world 3. It was a constant. Five
  entries in this register are now that same shape.
- **Fix the half that was left.** World 3 diagnosed uniformity exactly, wrote
  down that a uniform resource which renews in place is the resource that
  selects for sitting still, and made recovery depend on the cell's own stock.
  The floor stayed uniform for eleven worlds and it was the term that mattered
  once a board is grazed down, which is the state a lawn drives it into.
- **The cheap test that killed the premise was what made the world worth
  building.** The [floor sweep](RESULTS_GROUND_FLOOR.md) refuted the magnitude
  argument in six minutes and left the shape argument standing. Had it not been
  run, this rule would have shipped with a justification that was false, and the
  right result for the wrong reason is worth much less.
