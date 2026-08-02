# Results: the lumps are places, not families

**Raf noticed it on the public page after leaving the islands running
overnight**, which is the only way it could have been noticed: the pattern needs
thousands of ticks to set and every offline run in this project stops at 4,000.

Measured by `scripts/why_lumps.escript`, which reproduces each live island
offline from its own seed, because a world is a pure function of its seed.
Islands at ticks 35,689 / 35,754 / 35,742 under world 14 at the control.

| island | `ground_spread` | creatures | blobs | vs random | biggest blob | vs random | ground under them | hidden nodes |
|---|---|---|---|---|---|---|---|---|
| beam00 | **24** | 23 | 23 | 22 | **4%** | 6% | **0.5×** | **0.00** |
| beam01 | **83** | 74 | **30** | 56 | **31%** | 3% | **72×** | **0.16** |
| beam03 | **89** | 85 | **44** | 65 | **25%** | 2% | **94×** | **0.25** |

## The lumps are real, and they are places

**Half as many groups as chance, and the biggest holds ten times what chance
would put in it.** On beam03 the largest connected group of occupied cells holds
25% of the population where random scattering of the same 76 cells gives 2%.

**The ground under them is 72 to 94 times richer than the ground elsewhere.**
Not twice, not three times. The creatures are living on isolated rich patches in
a board that is otherwise nearly bare.

And the one that settles what kind of clump it is:

| island | 10 ticks | 50 | 200 | 1,000 | **5,000** | ticks per generation |
|---|---|---|---|---|---|---|
| beam01 | 841 | 408 | 437 | 429 | **481** | 49 |
| beam03 | 560 | 399 | 453 | 211 | **274** | 42 |

A cell occupied now is still occupied **five thousand ticks later at 4.8 and 2.7
times chance**. That is **about a hundred generations**. The creatures in a lump
have been replaced a hundred times over and the lump has not moved.

**A child is placed on a random neighbouring cell of its parent**, so local birth
alone produces clumps and has since world 1. But demographic clumps drift and
dissolve on the timescale of a generation, and these do not decay measurably
between 50 ticks and 5,000. **The lump is a property of the place.**

## The island without a patchy board has no lumps

beam00 is the control this could not have been designed better to have. Same
rules, same tick, same binary, different seed: `ground_spread` 24 against 83 and
89, and its blob statistics are **indistinguishable from random** — 23 groups
against 22, largest holding 4% against 6%. Its creatures sit on ground **poorer**
than average, it is 8% still against their 60%, and it has **no hidden nodes at
all**.

Lumping is not a property of world 14's rules. It is a property of the state the
board settles into, and it appears exactly where the board is patchy.

## What I got wrong, stated plainly

I explained this to Raf as the absorbing state biting: world 14's floor is
`mean(neighbours) * 3 div 100`, which is **exactly zero** for any neighbourhood
averaging under 34 of a ceiling of 400, and the compounding term is exactly zero
under a stock of 17, so a bare cell in a bare neighbourhood should gain nothing
for ever.

**The arithmetic is right and it is not what is binding here.** Measured, the
share of the board gaining exactly nothing is **1% and 4%** on the two lumpy
islands. Almost every cell is recovering. What makes the off-patch ground poor is
that it recovers by about one unit a tick from a floor that is small when the
neighbourhood is poor, while mobile creatures crop it — slow recovery against
grazing, not an absorbing desert.

The threshold is real, is unintended, and is [entered in the
register](PHYSICS_REGISTER.md) as **A.6**. It is not the explanation for the
lumps.

## The part worth chasing

**Hidden nodes are 0.00 on the flat island and 0.16 and 0.25 on the lumpy ones**,
at the same `neural_cost` of 330 that held them at 0.01 for twelve worlds.

There is a mechanism that would explain it, and it is the first thing in this
project that would make a brain worth paying for. A linear brain scores a
candidate cell as a weighted sum of what it reads there. That is enough to climb
a gradient, which is what these creatures do: 101 of 118 carry a ground sensor
with real attention on it. But on a patchy board the value of a cell is **not
monotone in any single reading**: a rich cell shared with six others is worth
less than a poorer empty one, and value is something like stock **over**
competitors. **A linear brain can add and cannot divide.** A hidden node is
exactly the organ that lets one input modulate another.

On a flat board there is nothing to combine, because stock and crowding are both
uniform everywhere. That is beam00, and beam00 has no hidden nodes.

**This is an association across three islands and nothing more.** It is not
established, and the obvious experiment is:

1. **Does hidden-node count track `ground_spread` across many seeds** at a fixed
   price? Cheap, and it either survives or it does not.
2. **Re-run world 13's `neural_cost` sweep under world 14.** World 13 found
   computation appears only below a price of about 66. If structure makes
   computation worth paying for, hidden nodes should appear at a **higher** price
   under world 14 than under 13. That is a sharp, falsifiable claim and it would
   be the first evidence in fourteen worlds that this world can select for a
   brain rather than merely afford one.

## What this teaches

- **Some findings need wall-clock time and no offline run will produce them.**
  Every sweep here stops at 4,000 ticks; the lumps are visible at 35,000. The
  fleet is not a demo of the science, it is an instrument with a longer baseline
  than any script, and this is the first result that came out of it.
- **A statistic that saturates is worse than none.** The first version measured
  "share of occupied cells touching another occupied cell" and read 97 against a
  random 98, which would have been reported as "no clustering". At those
  densities almost every cell touches another whether clustered or not.
  Connected components do not saturate and gave a factor of ten.
- **Explaining before measuring cost me the right answer.** The absorbing-state
  story was arithmetically correct, mechanically plausible, and contributes 1% of
  the board. It would have gone into the register as the cause.
