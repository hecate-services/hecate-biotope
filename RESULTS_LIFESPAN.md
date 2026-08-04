# Does a longer life buy a brain? No — and life is not for sale

**`H.13` refuted and withdrawn**, two hours after it was written. Measured with
`scripts/does_a_longer_life_buy_a_brain.escript`, 24 seeds, 6,000 ticks, world 22.

## THE HEADLINE, AND IT IS NOT THE ONE THE EXPERIMENT WAS FOR

**Lifespan is not a parameter of this world. It is an emergent invariant, and
neither obvious lever moves it.**

| lever | value | dead/24 | **LIFE** | pop | eaten% | starved% | **NODES** | explored | frontier |
|---|---|---|---|---|---|---|---|---|---|
| metabolism | 20 | 14 | 11.46 | 78 | 67% | 32% | 0.27 | 65 | 0 |
| metabolism | 15 | 14 | 12.23 | 78 | 61% | 38% | 0.29 | 65 | 0 |
| metabolism | 10 | 13 | 9.77 | 82 | 68% | 30% | 0.16 | 74 | 0 |
| metabolism | 7 | 14 | 9.55 | 80 | 67% | 32% | 0.42 | 72 | 1 |
| metabolism | 5 | 13 | 12.59 | 86 | 68% | 31% | 0.53 | 74 | 1 |
| metabolism | 3 | 12 | 10.09 | 120 | 68% | 31% | 0.67 | 58 | 0 |
| metabolism | 1 | 12 | 8.83 | 126 | 69% | 30% | 0.24 | 60 | 0 |
| radius | 10 | 23 | 5.18 | 5 | 12% | 87% | 0.80 | 48 | 0 |
| radius | 20 | 13 | 9.77 | 82 | 68% | 30% | 0.16 | 74 | 0 |
| radius | 30 | 17 | 9.41 | 159 | 77% | 22% | 0.32 | 63 | 0 |
| radius | 40 | 12 | 11.39 | 288 | 78% | 21% | 0.22 | 62 | 0 |

**A TWENTYFOLD REDUCTION IN THE COST OF EXISTING BUYS NOTHING.** `metabolism` 20
to 1 moves mean life from 11.46 to **8.83**, which is the wrong direction, and
every value in between wanders in the nine-to-thirteen band. A fourfold change in
`radius` moves it from 5.18 to 11.39 and the whole range across eleven settings
of two levers is about 2.4x, most of it noise.

**THE MECHANISM IS VISIBLE IN THE TABLE AND IT IS THE CONFOUND PREDICTED IN
ADVANCE.** The script's own documentation said: *"Cheaper living produces more
survivors, more crowding and more predation, so lifespan may not rise at all."*
Population runs 78 → 126 as living gets cheaper, and `eaten%` sits at 67–69%
throughout. **Predation is density-dependent, so it regulates the population and
the lifespan together.** Make living cheaper and the world makes more creatures,
not older ones.

## The finding the experiment was for

**REFUTED.** The longer-lived half of the arms carries **0.35** hidden nodes
against **0.38** in the shorter-lived half, against a 2-fold response stated
before the run. There is no response, and what there is points the wrong way.

`H.13` claimed that three worlds of "expressible and unused" were about the
clock. On this evidence they were not. **The clock cannot be moved, and where it
does move, computation does not follow.**

## ⚠ THE CAVEAT THAT KEEPS THIS HONEST

**The instrument may lack the power to see a modest effect.** Hidden nodes run
0.16 to 0.80 across every arm: a small, noisy quantity measured as a median over
24 seeds, of which half die. A response of 30% would be invisible here and only
the 2-fold response named in advance could have been detected.

So the accurate statement is **no response detected at the stated size**, not
"proven absent". A stronger instrument would carry more seeds and report the
distribution rather than the median, which is `I.2`'s shape and is owed.

## What this leaves, and it is now the only candidate standing

**`Ne` has never been measured**, and every selectability gate in this project
has guessed at it, including world 23's yesterday. If the effective population is
10 rather than 70, the drift floor is 5% and nearly every trait ever priced here
was below it. Founding lines collapse to 1 within a few hundred ticks in every
seed, which is the signature of an `Ne` far below the census count.

**Two explanations were on the table for three consecutive nulls. One is now
refuted. The other has never been measured.**

## And one thing every row agrees on

**`frontier` is 0 in nine of eleven arms and 1 in the other two.** Under every
setting of both levers, at every population from 5 to 288, the world stops
finding new ways to live. Convergence is not sensitive to the cost of living or
to the size of the board.
