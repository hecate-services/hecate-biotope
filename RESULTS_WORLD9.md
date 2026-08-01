# Results: world 9

**The change:** reproduction is paid out of the store. A parent does not
dismantle its own body to make a child.

No new constant. Corrects register entry **C.7**. Pre-registered in
[PREREGISTRATION.md](PREREGISTRATION.md), **including an amendment declaring a
consequence that was not in the change as first written**, both fixed before the
first run and committed as `dd8a9bc`.

5 seeds, 2000 ticks, 11 efficiencies.

## The headline

**The engine restarted, and the world stopped ending.**

World 8 died in every seed at every efficiency, with its last birth between ticks
5 and 35. World 9 at full efficiency runs to the 2000-tick limit in 3 seeds of 5,
**still giving birth at the last tick measured**, with living creatures **54, 68
and 129 generations** descended from the founding.

| | world 8 | world 9 at 100% |
|---|---|---|
| deepest generation ever alive | 5 to 15 | **54 to 129** |
| last birth | tick 5 to 35 | still going at the limit |
| share of the run after the last birth | 94 to 99% | **0%** |
| seeds surviving 2000 ticks | 0 of 5 at every efficiency | 3 of 5 |

## And two things nobody asked for

**The landscape differentiated, hard.** `ground_spread` is **86** at 100%, where
10 is flat. World 4 produced 26 to 86 and world 5 destroyed it; worlds 5 through
8 ran at 9 to 30 and never recovered it. It is back at the top of world 4's range
without anything being done to the ground.

**Something makes a living off other creatures for the first time in this
register.** `from_creatures_pct` is 18 to 33 and 5 to 31 individuals draw more
from creatures than from ground. **Both have been exactly zero in every world
since world 4**, and entry D.2 records predation as ubiquitous and worthless:
97% of deaths were by being eaten and no lineage ever ate for a living, because
what got eaten was empty.

## The predation is not infanticide, and that had to be checked

The pre-registration declared, before the run, that a parent now keeps its whole
frame and so **outweighs its newborn at every founding energy**. A newborn is the
lightest thing on the board and loses every contest it enters. If the new
predation were parents eating their own children, calling it a niche would be
world 6's bimodal histogram all over again: a shape read as a story.

So the world gained one observable, the age of everything ever eaten.

| eff | seed | mean age of the eaten | mean lifespan |
|---|---|---|---|
| 100 | 1 | 3.75 | 2.09 |
| 100 | 2 | 2.45 | 2.52 |
| 100 | 5 | 2.17 | 2.12 |
| 95 | 1 | 2.73 | 2.33 |
| 95 | 2 | 1.53 | 2.63 |
| 95 | 5 | **7.72** | **7.91** |
| 80 | 5 | **7.18** | **7.03** |

**The eaten track the population's own age distribution**, sometimes above it,
never at the 1.00 that infanticide would produce. The two long-lived seeds are
the strongest evidence, because there most of the population is not a newborn and
the eaten are still at the average.

**The mechanism is the size spread, not the babies.** Until world 9, breeding
halved a parent toward its child every time, so the population kept collapsing
back toward one size. Now parents keep their frames and grow, children start
small, and a standing hierarchy of sizes exists for the first time. Predation
pays because there is something to be bigger than.

## Against what was pre-registered

| # | Finding | Result |
|---|---|---|
| 1 | **Lineages get past the first few generations** | **CONFIRMED at high efficiency, FAILED at low.** 54 to 129 generations at 100%. At 30% the deepest generation ever alive is still 0 or 1, exactly as in world 8. |
| 2 | **The last birth moves late** | **CONFIRMED.** Births are still happening at the run limit in the surviving seeds. |
| 3 | **Extinction at 602 stops being the ending** | **CONFIRMED for the survivors.** The seeds that still die, die at 601, which is the founding cohort ending as before. Nothing in between. |
| 4 | **The uptake spread stops draining** | **PARTIAL.** 124 to 311 at 100% against world 8's 0 to 277. Not a clean result and it needs a proper variance measure rather than a range. |

And what was pre-registered **not** to happen:

| Prediction | Result |
|---|---|
| **Lifespan will fall back toward 2 ticks** | **CONFIRMED.** 2.12 at 100%, against world 8's 3.7 to 24.6. As stated in advance, this is world 8's artefact being removed and not a regression. |
| **Density will rise, possibly a great deal** | **CONFIRMED but bounded.** 105 to 907 against world 8's 4 to 16. It did not return to world 6's ~2,300. |
| **Perception will not move** | **HELD.** 0.22 sensors per creature at 100%, 0.80 at 95%, 2.33 at 80%, against world 7's 2.52 at 100%. Nothing here changed what apparatus costs. |
| **Diversity will not appear** | **FAILED, and this is the interesting one.** Two ways of making a living now coexist. The prediction was argued from G.3 and G.4, which are untouched and still true, so the argument was not wrong about the world; it was wrong that one strategy must therefore win. |

## The efficiency boundary, and one oddity

| eff | seeds surviving 2000 ticks |
|---|---|
| 100 | 3 of 5 |
| 95 | 3 of 5 |
| 90 | **0 of 5** |
| 80 | 1 of 5 |
| 70 and below | 0 of 5 |

**90% is out of order** and sits between two efficiencies that both survive. With
5 seeds this is most likely seed variance rather than structure, and it is
recorded rather than explained. It should not be quoted as a boundary.

At 30% the world is unchanged from world 8: last birth at ticks 10 to 15, deepest
generation 0 or 1, dead at 601. The dowry is delivered lossily, so at low
efficiency a child receives so little that it is born too small to feed itself,
and the change cannot help. **World 9 fixed the ratchet and not the loss.**

## What this world teaches

- **A world can be one deletion away from working.** Nothing was added. The
  parent stopped being dismembered, and eight worlds of nulls turned into a
  population that persists, differentiates its landscape and feeds on itself.
- **The thing that had to go was never a rule anyone defended.** `S div 2` sat in
  the breeding code with a comment explaining that structure is energy in another
  form. True, and it never made taking it obligatory.
- **A consequence declared in advance is worth more than one explained
  afterwards.** The newborn size asymmetry was found by a failing test before the
  run, written into the pre-registration, and then measured and cleared. Had it
  been noticed after the predation result, no reading of that result would have
  been trustworthy.
- **Two positives from earlier worlds came back together.** World 4's landscape
  and a predation living have never coexisted before, and neither was targeted.
  Whatever produced them is the standing size spread, which is the one thing this
  change creates.
