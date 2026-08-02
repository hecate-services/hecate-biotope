# Results: world 17

**A reading is an intensity, not a total.** Scored against
`PREREGISTRATION_WORLD17.md`, which was frozen before the rules and amended once,
before any result was claimed, to sweep the constant it had picked.

> **Everything here is measured against physics repaired on 2026-08-02.** Partway
> through this write-up a world turned out not to be a pure function of its seed
> (`G.6`), so the first sweep and the first sensing measurements were discarded
> and both were run again. The discarded numbers are kept in the section at the
> foot of this file, because what they said and how confidently they said it is
> the most useful thing in the whole world.

## THE HEADLINE

**The mechanism works and the world rejects it.** Every setting that makes a
sense legible kills nearly every seed, so the criterion this project sets its
constants by, viability and nothing else, selects `sense_scale = 1`: the
coarsest, blindest instrument on the sweep. At that setting a reach-0 ground
sensor reads zero **87 to 100%** of the time, against **88 to 100%** under world
16.

**For the sensors that actually exist, world 17 changed nothing.** The fleet
carries reach-0 ground sensors almost exclusively, and at reach 0 a mean over one
cell is the same arithmetic as a sum over one cell. World 17 is arithmetically
identical to world 16 for the population it was built to help.

That was not one of the four things the pre-registration listed as possible
findings, and it is a stronger answer than any of them.

## The sweep

`scripts/sweep_senses.escript`, **96 seeds**, 20,000 ticks. `sense_scale` is how
many steps of the reading range a full cell spans, so a larger number is a finer
instrument.

| scale | dead | alive | sensors | reach | hidden | pop | spread | lines | depth |
|---|---|---|---|---|---|---|---|---|---|
| **1** | **80** | **16** | **2.19** | **102** | **0.05** | **84** | **43** | **1** | **468** |
| 2 | 87 | 9 | 2.35 | 148 | 0.03 | 97 | 33 | 1 | 524 |
| 4 | 89 | 7 | 1.47 | 125 | 0.08 | 114 | 36 | 1 | 550 |
| 8 | 91 | 5 | 1.19 | 16 | 0.06 | 141 | 50 | 1 | 603 |
| 16 | 94 | 2 | 0.81 | 9 | 0.02 | 211 | 44 | 1 | 576 |
| 32 | 94 | 2 | 0.80 | 37 | 0.01 | 270 | 69 | 1 | 525 |
| 63 | 93 | 3 | 0.89 | 20 | 0.00 | 204 | 52 | 1 | 396 |

`sensors` and `hidden` are per creature, `reach` is total sensor reach carried by
the population. Averages are over the SURVIVING seeds only, so the bottom rows
rest on two or three worlds and their spreads should not be read hard.

**Deaths rise monotonically with resolution**, 80 through 94, breaking only at
the last row and by one seed. **Even the best setting kills 83% of its seeds.**

**96 seeds and not 24, because 24 could not choose.** At 24 seeds the top three
scales tied at 21 deaths each. A criterion that cannot separate its candidates is
not a criterion, and the answer to that is more seeds, not a tie-break invented
after seeing the tie.

## What the senses actually read

`scripts/what_can_they_see.escript`, 2,000 ticks, seeds 5, 12, 14, 39, 46, 8. A
shorter horizon and a different seed set from the sweep, so these rows may not be
read as the sweep's worlds.

| scale | alive of 6 | reach-0 reads zero | reach-0 max | `self` reads zero |
|---|---|---|---|---|
| **1**, chosen | **5** | **87 to 100%** | **0 to 24** | **19 to 73%** |
| 2 | 3 | 83 to 91% | 2 to 31 | 11 to 42% |
| 8 | 1 | 78% | 63 | 14% |
| 63 | 1 | 12% | 63 | 8% |
| *world 16, for reference* | | *88 to 100%* | *6 to 54* | *35 to 54%* |

**The tradeoff is monotone in both directions and that is the finding.** Every
step that makes the instrument legible costs seeds; every step that saves seeds
blinds the instrument. At the viable end it is world 16 again.

**`self` is the only place the change even shows**, and it shows ambiguously: 19
to 73% reading zero against world 16's 35 to 54%, which overlaps and is worse at
the top. The hunger sense is where a survival decision would be made and it is
still blind for most of the population most of the time.

## The four pre-registered findings

**1. Reach stops being nearly free of information. FAILED at the chosen scale.**
87 to 100% of reach-0 ground readings are zero, against 88 to 100% under world 16.
It is legible at scale 63, where 12% read zero, and 93 of 96 seeds die there.

**2. Perception rises further. FAILED against its own target.**
The target was 6.49 sensors per creature, world 16's figure at the cheapest
price. The best any scale reaches is **2.35**, and the chosen scale gives 2.19
against world 14's 1.50. Perception did not rise.

**3. Reach differentiates. UNTESTED, and the pre-registration named no
instrument.**
Nothing in this repo reports the distribution of reach. Mean reach per sensor,
derived from the published averages, runs 0.55, 0.65, 0.74, 0.10, 0.05, 0.17,
0.11 across the sweep: not monotone, and a mean cannot distinguish a population
that spread out from one that shifted together, which is the whole claim.
**Owed: a reach histogram.** Register entry `I.7`.

**4. Hidden nodes move. REFUTED.**
0.00 to 0.08 hidden nodes per creature at every scale on the sweep. Making the
`self` reading legible produced nothing that combines it with anything. The
pre-registration said in advance that this would be the answer: **"if perception
rises and computation does not, that is the answer, and it says the problem was
never the senses."** Perception did not rise either.

**`lineages` is 1 at every scale**, as stated in advance.

## What this world actually established

**`F.4`: a resolving sense may be FATAL rather than merely useless.** World 14
made bare ground recover from its neighbours, so a population that grazes its own
neighbourhood flat loses its subsidy. A sense that resolves the ground should let
creatures find and strip the best cells faster. The monotone death curve is
consistent with that and does not establish it.

**It is the first question here whose answer would change what a world is for.**
Seventeen worlds have asked why perception stays at the floor, and every one
assumed the answer was a missing reason or an unaffordable price. If seeing
better is what kills you, the question has been the wrong way round the whole
time, and `F.4` is how to find out.

Note the shape of the sweep, which points the same way: as resolution rises,
**population rises** (84 to 270) while **seeds surviving falls** (16 to 2). The
worlds that make it are more crowded. That is what an intensified scramble for
the best cells would look like, and it is one more thing consistent with `F.4`
rather than evidence for it.

## The constant is now a default, not a fleet override

`sense_scale` is **1** in `world:defaults()`.

**Chosen on viability and nothing else**, the single exception the standing rule
allows: 80 deaths of 96 against 87, 89, 91, 94, 94 and 93. No part of the choice
refers to sensors, brains, reach or population.

**And it moves into the rules rather than staying in three node configs.** It sat
in `HECATE_BIOTOPE_ECON` on beam00, beam01 and beam03, which is how beam01 spent
two hours in a boot-crash loop on 2026-08-02: a config in `macula-demo` named a
constant in this repo, the node pulled the config before the image that knew the
name, and `world_server` refuses to start on an unknown economy key. **A physics
constant in a deployment config is a version handshake nobody performs.** Register
entry `I.9`.

## THE DISCARDED NUMBERS, AND WHY THEY ARE THE POINT

Two earlier answers were produced, published into three node configs, deployed to
a live fleet, and were wrong.

| | value | how it was reached | what was wrong |
|---|---|---|---|
| first | **63** | `ground_ceiling ÷ reading_ceiling` | tidiness. Nothing derived it. |
| second | **2** | 24 seeds, "fewest extinctions" | physics that was not reproducible (`G.6`), and 24 seeds cannot separate the top three anyway |
| third | **1** | 96 seeds, same criterion, fixed physics | |

The second answer is the instructive one. It was reached by the right criterion,
applied honestly, with the whole table published so it could be checked, and it
was still wrong, twice over. **Publishing your working does not make the working
correct.** The two faults it could not have caught by inspection were a
determinism bug that had been present for seventeen worlds and a sample too small
to distinguish its candidates, and only the second is visible in the output.

Three instrument-level facts also came out of this world and are in the register:

- **`I.6`**: `what_can_they_see.escript` was written in the commit BEFORE world
  17's rules, was correct when written, and was made wrong by the change it
  existed to measure. It kept calling `body:reading/3` after a cell count was
  added, so it divided seven cells by one and reported sums under a world that
  computes means. **It voided this world's own first-observation table.**
- **`I.7`**: finding 3 named no instrument and could therefore neither succeed
  nor fail.
- **`I.8`**: `rm -rf _build/test` is not enough to trust a test result. The same
  unchanged source gave three failures, then one, then none.
