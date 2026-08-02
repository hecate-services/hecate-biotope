# Results: structure did not make computation worth paying for

**The claim was wrong, and it was wrong in the opposite direction.**

Pre-registered in
[PREREGISTRATION_BRAINS_AND_STRUCTURE.md](PREREGISTRATION_BRAINS_AND_STRUCTURE.md).
`neural_cost` over world 13's steps, under world 14, 48 seeds, 20,000 ticks, 100%
efficiency. 164 worlds survived of 432.

## The pooled analysis, which was the primary one

| third of worlds | worlds | `ground_spread` | **hidden nodes** | sensors | population |
|---|---|---|---|---|---|
| flattest | 54 | 36 | **1.68** | 4.53 | 125 |
| middle | 54 | 55 | **1.72** | 5.05 | 146 |
| **patchiest** | 56 | **85** | **0.80** | 3.46 | **221** |

**Hidden nodes are lowest on the patchiest boards.** Not flat, which was the
stated negative: reversed. The patchiest third carries less than half the
computation of the flattest, on more than twice the seeds' worth of evidence that
the three live islands offered.

## The price sweep

| price | dead of 48 | alive | spread | **hidden** | sensors | pop | still | lines | depth |
|---|---|---|---|---|---|---|---|---|---|
| **330** | 42 | **6** | 51 | **0.15** | 2.49 | 72 | 34 | 1 | 448 |
| 220 | 38 | 10 | 55 | 0.83 | 2.44 | 103 | 46 | 1 | 464 |
| 165 | 35 | 13 | 62 | 0.66 | 2.87 | 119 | 50 | 1 | 463 |
| 110 | 33 | 15 | 61 | 0.87 | 3.48 | 122 | 51 | 1 | 446 |
| 66 | 34 | 14 | 69 | 0.89 | 3.38 | 170 | 62 | 1 | 400 |
| 33 | 30 | 18 | 58 | 1.34 | 4.39 | 116 | 56 | 1 | 371 |
| 11 | 21 | 27 | 62 | 1.50 | 4.86 | 207 | 73 | 1 | 365 |
| 3 | 21 | 27 | 60 | 2.01 | 5.35 | 192 | 72 | 1 | 329 |
| 1 | 14 | 34 | 54 | 1.97 | 5.30 | 204 | 74 | 1 | 334 |

## Against what was pre-registered

| # | Finding | Result |
|---|---|---|
| 1 | **Hidden nodes at the CONTROL price rise above the twelve-world floor**, defined in advance as above 0.10 | **LANDED, and it is confounded.** 0.15 against the 0.01 worlds 2 to 13 recorded, and every price in the sweep is above the threshold. **But this ran to 20,000 ticks and world 13's sweep ran to 2,000**, so part or all of the rise may be the horizon rather than the world. I did not notice when writing the pre-registration. It is not a clean result. |
| 2 | **Pooled over every surviving world, hidden nodes rise with `ground_spread`** | **FAILED, AND REVERSED.** 1.68, 1.72, 0.80 from flattest to patchiest. This was the primary analysis and the whole reason for the design. |
| 3 | **The direction test: `ground_spread` stays flat as brains get cheap** | **LANDED.** 51, 55, 62, 61, 69, 58, 62, 60, 54 across an eighteen-fold price range: no trend. Brains getting cheaper does not make boards patchier, so the arrow does not point the way I was worried it might. It now has nothing to explain. |
| 4 | **Sensors do NOT show the same pattern as hidden nodes** | **FAILED, and the test was badly designed.** Sensors track hidden nodes everywhere: 2.49 to 5.30 across the price sweep while hidden went 0.15 to 1.97, and 4.53 / 5.05 / 3.46 across the tertiles against 1.68 / 1.72 / 0.80. **`neural_cost` prices sensors AND hidden nodes together**, since both are apparatus charged by weight since world 13, so a price sweep could never have separated them. I should have seen that before running it. |

And what was pre-registered **not** to happen:

| Prediction | Result |
|---|---|
| **G.1 untouched, every survivor at one founding line** | **CONFIRMED.** `lines` is 1 at all nine prices. |
| **Extinctions high at the expensive end, falling with the price** | **CONFIRMED.** 42 of 48 dead at the control, 14 at the cheapest. |
| **The most likely outcome is still nothing** | **Correct about the mechanism and wrong about the direction.** I predicted a null as most likely; what arrived was a reversal, which is more informative. |

## What actually explains the reversal

Look at the population column of the tertile table: **125, 146, 221**. The
patchiest boards carry **the most creatures**, and they carry the least
apparatus of any kind — sensors as well as hidden nodes.

That is a coherent story and it is not the one I told. A patchy board concentrates
the same energy into fewer, richer cells. More creatures fit, competition inside
a patch is fiercer, and the individuals are poorer, so they can afford less of
everything. **Patchiness does not buy a reason to compute. It buys crowding, and
crowding taxes every organ.**

The three-island reading that prompted this — 0.00, 0.16 and 0.25 against
`ground_spread` 24, 83 and 89 — **is not reproduced at 164 worlds**. beam00, the
flat one with no hidden nodes, had 23 creatures; the flattest tertile here
averages 125. It was not a flat board, it was a nearly empty one, and I read
three points as a gradient.

## What survives

**Computation is higher under world 14 than it was under world 13 at every
price**, and that much is real even though the cause is not established. World 13
recorded 0.01 hidden nodes at 330 and 2.68 at its cheapest; this records 0.15 and
1.97. The floor moved up and the ceiling moved down.

**Whatever raised it, it is not board patchiness.** The candidates left are the
horizon, which is the confound named above and is the cheapest thing to test, and
something else about world 14 that this design was not built to see.

## What this teaches

- **Three points are not a gradient, and I knew that and did it anyway.** The
  pre-registration said "three islands is three islands" and then built a whole
  experiment on the shape they made. The right reading of the fleet was that
  beam00 was nearly empty, which is visible in the same table I quoted.
- **A discriminator has to vary the two things separately.** Finding 4 was meant
  to separate computation from affordability and could not, because the one
  constant it swept prices both. That is a design error and no amount of data
  would have fixed it.
- **The direction test was the cheapest thing here and the only one that came
  back clean.** It cost nothing extra, it ruled out the confound I was most
  worried about, and it is the part of this design worth keeping.
- **A reversal is worth more than the null I predicted.** "Nothing happened"
  would have left the fleet reading intact and unexplained. This says the
  association was an artefact of population size and points at crowding, which is
  a mechanism that can be tested.
