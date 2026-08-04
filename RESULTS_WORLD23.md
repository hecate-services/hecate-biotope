# World 23: water in places, and a creature that dries out

**This exists to test `J.1`: that these brains stay small because the world asks
them only one question.**

Pre-registered in [PREREGISTRATION_WORLD23.md](PREREGISTRATION_WORLD23.md),
frozen before the first run. Five findings were named with their instruments.

> ## ⚠ EVERY NUMBER BELOW WAS TAKEN ON A LANDSCAPE THAT NO LONGER EXISTS
>
> World 23 laid water as **single cells on concentric rings**. On the default
> island that came out as one cell at the centre, a complete circular moat of
> thirty cells at distance five, and half a ring at distance ten, leaving
> **73% of the island with no water anywhere further out**.
>
> **World 24 replaced it with lakes and rivers**, and a river runs to the shore,
> so the dry rim is now 0%. Nothing here is re-run. Read the verdicts as verdicts
> about the ring world, because that is the world they were measured in, and the
> dry rim is a live candidate for why the result was a cull.

## The verdict, against what was written down beforehand

| # | pre-registered finding | reading | verdict |
|---|---|---|---|
| 1 | creatures evolve to **sense** water | 0-2% carry the field | **NEGATIVE** |
| 2 | they evolve to **move toward** it | approach 0-3%, control 4% | **NEGATIVE** |
| 3 | **predation rises** | 9% control, 2-5% with thirst | **NEGATIVE, and backwards** |
| 4 | the **frontier stops reaching zero** | 0-1 against a control of 0; explored FELL, 81 to 64-66 | **NEGATIVE** |
| 5 | **hidden nodes are carried more** | medians 0.48-1.16 against 0.33 | **DOES NOT SURVIVE ITS CONTROL** |

**And the pre-registration named exactly this combination in advance**, in the
paragraph headed *the strongest negative, written so it cannot be reinterpreted*:

> if creatures carry the water field at chance, breeders are no closer to water
> than anybody else, and the frontier still reaches zero, then **a second
> requirement does not give this world's brains anything to decide, and `J.1` is
> wrong.** That would be a finding about the register's own central diagnosis and
> would be worth more than a success.

All three conditions hold. **`J.1` is refuted by its own stated criterion**, and
the criterion is honoured rather than renegotiated now that it has bitten.

---

## The sweep

24 seeds to 8,000 ticks. `ctl` arms have `thirst` at zero: water present,
sensible, and harmless, which is world 22's physics on world 23's landscape.

| arm | dead/24 | pop | parched% | to water, birth | at end | approach | water sens | nodes min-med-max | meat% | depth | explored | front |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 61 ctl | 11 | 74 | 0% | 6.10 | 5.78 | 4% | 0% | 0.01-**0.33**-2.03 | 9% | 212 | 81 | 0 |
| 19 ctl | 12 | 80 | 0% | 10.07 | 9.32 | 8% | 0% | 0.00-**0.20**-1.14 | 9% | 228 | 74 | 0 |
| 0 | 21 | 72 | 16% | 0.00 | 0.00 | 0% | **100%** | 0.01-0.89-2.30 | 6% | 356 | 71 | 0 |
| 1 | 19 | 106 | 20% | 13.70 | 13.26 | 0% | 6% | 0.06-0.90-1.89 | 1% | 416 | 67 | 1 |
| 7 | 20 | 71 | 25% | 11.92 | 12.19 | 0% | 2% | 0.19-1.40-3.33 | 6% | 408 | 68 | 2 |
| 19 | 20 | 112 | 18% | 10.07 | 9.75 | 16% | 1% | 0.40-0.66-3.04 | 5% | 436 | 64 | 1 |
| 37 | 21 | 77 | 25% | 8.15 | 7.70 | 5% | 0% | 0.97-1.44-1.53 | 3% | 390 | 62 | 2 |
| 61 | 17 | 82 | 16% | 6.05 | 6.39 | **-5%** | 0% | 0.02-0.42-1.32 | 9% | 327 | 62 | 0 |

**The rule bites.** Thirst is 16-25% of all deaths and extinctions go from 11-12
of 24 to 17-21.

### ⚠ THE ZERO-HOLES ARM IS THE MOST INFORMATIVE ROW IN THE TABLE

**100% of creatures carry a sensor for water on an island that has none.**
Nothing there can carry information, so nothing can select for reading it. That
column is drift, and once it is drift at 100% it is drift at 0% too. `G.10` says
so directly: with `Ne` at 7.44 the drift floor is 6.72%, and every figure in the
`water sens` column is under it.

**So finding 1 is not "selection removed the sensor". It is "there was never a
signal to see".** The distinction matters because the first is a result about
water and the second is a result about this world's population size.

## Then 64 seeds on the arms that bit hardest

The thirst arms leave 3-7 seeds alive of 24, and a **control's own** node spread
runs 0.00 to 2.03. That cannot separate a real rise from seed noise, so the
control and the three arms with most bite were re-run with many more seeds.

⚠ Choosing arms after seeing a table is `I.3`'s shape. It is defensible only
because the full table above is published beside it, the arms were picked on
`parched%` and not on their node figure, and a narrow run can refute as easily as
confirm. Read them together or not at all.

| arm | dead/64 | pop | parched% | approach | water sens | nodes min-med-max | explored | front |
|---|---|---|---|---|---|---|---|---|
| 61 ctl | 36 | 74 | 0% | 4% | 0% | 0.01-**0.33**-2.03 | 81 | 0 |
| 7 | 56 | 79 | 22% | 0% | 2% | 0.11-**1.16**-3.33 | 66 | 1 |
| 19 | 54 | 104 | 18% | 3% | 0% | 0.08-**0.48**-3.20 | 64 | 1 |
| 37 | 57 | 87 | 17% | 2% | 0% | 0.00-**0.97**-2.64 | 65 | 0 |

**⚠ AND THE ONE PROPERTY I WAS TEMPTED BY VANISHED.** At 24 seeds the 37-hole arm
read 0.97-1.44-1.53, every living seed above both control medians. At 64 seeds
its minimum is **0.00**. Three seeds had said something four times in a row that
seven seeds do not say, which is the third time in this project a small-n reading
has agreed with what had just been built and been wrong.

## The control that decided it

Two explanations predict every table above: **a second requirement buys
computation** (`J.1`), and **dying a lot buys computation**. Thirst kills 84-89%
of seeds where the control kills 56%, so they are not separated by anything so
far.

So world 22's physics were run with mortality driven up the only other way there
is, by shrinking the island. `thirst` is zero throughout. 64 seeds.

| radius | dead | dead% | pop | nodes min-med-max |
|---|---|---|---|---|
| 20 | 36 | 56% | 74 | 0.01-**0.33**-2.03 |
| 16 | 44 | 68% | 63 | 0.00-**0.72**-1.90 |
| 14 | 51 | 79% | 55 | 0.00-**0.39**-2.05 |
| 12 | 53 | 82% | 33 | 0.00-**0.23**-3.85 |
| 10 | 60 | 93% | 10 | 0.00-**1.00**-3.00 |
| 8 | 64 | 100% | - | - |

**World 22's own nodes run 0.23 to 1.00 with no trend at all**, and one arm
spreads 0.00 to 3.85 within itself. The thirst arms' 0.48 to 1.16 sit inside
that range at every point.

**Finding 5 is not established.** It is not refuted either: the instrument cannot
tell a threefold difference from noise at these sample sizes, which is what the
pre-registration meant by scoring a small response UNTESTED rather than absent.

⚠ And the control has a bias, stated because it runs in my favour: a smaller
island holds fewer creatures, so `Ne` falls and drift rises, which pushes nodes
DOWN. The control is therefore harder on itself than on thirst, and thirst still
did not clear it.

## The manipulation check, which passes and only just

**A rule nobody has to obey tests nothing.** The store's leash is
`structure / thirst`, and `structure` has a median of 215, so a typical leash is
about **21 ticks**.

Against what? Two lifespans, and they differ by more than three times.

| | world 22 | world 23 |
|---|---|---|
| **LIFE per birth**, `pop x ticks / deaths` | 8.99 | 7.38 |
| **AGE of the living** | 34 | 23 |
| ratio | 3.8x | 3.1x |

**The living creature in world 23 is about as old as one full water store.** So
the typical creature that is alive has had to drink, at least once, and the world
really did pose the question. It did not pose it four times over, and a harsher
regime is where the interesting version of this experiment lives.

### ⚠ EVERY SELECTABILITY GATE IN THIS PROJECT USED THE SMALLER NUMBER

"Mean life is ten ticks and a creature moves one cell per tick" is in the
environmental gate, in `I.16`, and in the argument that produced `I.17`'s absurd
rule. That is the **birth-weighted** mean, and it is dominated by newborns dying
at once. A gate asking whether a creature can cross five cells to reach water is
asking about a creature that is going to live, and that creature is three to four
times older. `I.19`.

## What this world says

**A second requirement did not give these brains anything to decide.** They did
not learn to sense water, did not move toward it, did not hunt more, and explored
*fewer* ways of living than the control did. Whatever keeps computation out of
these creatures, it is not that the world asks only one question.

`G.10` remains the standing explanation and is now the only one left: at `Ne`
7.44 the drift floor is 6.72%, and nothing this project has priced, added or
required has produced a differential that clears it except by killing most of the
island. **The next world has to move `Ne`, not the physics.**

## What is owed

- **`Ne` measured on world 23**, not inherited from world 22. Every number above
  leans on 7.44 and none of it was re-measured under thirst.
- **A harsher thirst regime** where the leash is well inside a living creature's
  age, which is where the two-requirement question actually gets asked.
- **A node instrument with power.** `hidden_mean` cannot resolve a threefold
  difference against its own seed variance, and four worlds have now turned on it.
- **The reach histogram**, still owed since `I.7`.
