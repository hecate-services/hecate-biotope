# Results: phase 0

Two measurements, both of which change something. The horizon confound is
settled, and the lumps turn out to be families.

---

# 0.1 The confound is dead: world 14 really did raise computation

[RESULTS_BRAINS_AND_STRUCTURE.md](RESULTS_BRAINS_AND_STRUCTURE.md) reported
hidden nodes above the twelve-world floor at every price and immediately said the
result could not be trusted, because that run went to **20,000** ticks and world
13's went to **2,000**. "Computation is higher under world 14" and "computation
is higher after ten times as long" made the same prediction.

Same code, same seeds, same prices, horizon as an argument. **At world 13's own
horizon:**

| price | world 13, 2,000 ticks | **world 14, 2,000 ticks** | world 14, 20,000 ticks |
|---|---|---|---|
| **330** (control) | **0.01** | **0.27** | 0.15 |
| 220 | 0.05 | 0.58 | 0.83 |
| 165 | 0.02 | 0.59 | 0.66 |
| 110 | 0.02 | 0.82 | 0.87 |
| 66 | 0.65 | 0.95 | 0.89 |
| 33 | 0.42 | 0.92 | 1.34 |
| 11 | 1.13 | 1.16 | 1.50 |
| 3 | 2.68 | 1.42 | 2.01 |
| 1 | 0.46 | 1.33 | 1.97 |

**At the control price, at an identical horizon, world 14 gives 27 times world
13's computation.** The confound is dead: the rise is the world and not the
clock.

It is strongest exactly where world 13 was flattest. At the four most expensive
prices world 13 recorded 0.01 to 0.05 and world 14 records 0.27 to 0.82, a
twenty- to fortyfold gap. At the cheap end the two converge, which is what you
would expect if world 13's cheap end was already at whatever the ceiling is.

**And the reversal needs time.** The tertile pattern at 2,000 is 0.83, 1.34,
1.00, with no clean order. At 20,000 it is 1.68, 1.72, 0.80 and the patchiest
third is decisively lowest. Whatever suppresses computation on patchy boards
takes thousands of ticks to arrive, which is consistent with the crowding
explanation: the patchiest boards get their large populations late.

**What raised it is still unknown.** The design that would have said so was the
one that failed. Not patchiness, not the horizon, and no candidate has been
tested.

---

# 0.4 The lumps are families

Measured on the exact islands and ticks that
[RESULTS_LUMPS.md](RESULTS_LUMPS.md) established the lumps on, reproduced offline
from their seeds. `scent` is a heritable neutral marker; `scent:spread/1` is a
normalised mean pairwise difference, 0 for clonal and about 50 for unrelated. So
Wright's F_ST applies directly as `(total − within) / total`.

| island | `ground_spread` | spread **within** a lump | spread **across** the island | **F_ST** |
|---|---|---|---|---|
| beam00 | 24 | 0 | 39 | *(void, see below)* |
| **beam01** | 83 | **14** | **41** | **65** |
| **beam03** | 89 | **17** | **44** | **61** |

**Sixty-one to sixty-five percent of the genetic variation sits between lumps
rather than inside them.** Inside a lump the population is close kin, at 14 to 17
against an unrelated baseline near 50. Across the island as a whole it sits at 41
to 44, which is nearly unrelated.

For scale, Wright called F_ST above 0.25 "very great" differentiation, and human
continental populations run about 0.10 to 0.15. **These lumps are more
differentiated from one another than human continents are.**

Nobody installed this. Births are placed on a neighbouring cell, world 14 made
the board patchy, and the lumps persist about a hundred generations. That is
exactly Hamilton's condition for kin structure, arriving as a consequence of two
rules that were written for other reasons.

**beam00's 100 is an artefact and not a result.** It has 23 creatures on 23
separate cells, so every "lump" is a single creature, no group has a pair to
compare, `within` is an average of nothing, and the ratio degenerates. An island
with no lumps has no F_ST. It is left in the table so nobody recomputes it and
believes it.

## What this does and does not license

**It does not show group selection.** It shows the *precondition*: a population
structured into persistent, highly related, mutually differentiated demes. Whether
anything is selected at the group level is a separate question and needs a trait
whose effect on the group differs from its effect on the individual. This world
has no such trait yet, and **the mouth would be the first**, because a lump that
collectively over-consumes destroys the patch it lives on.

**The marker is neutral and that cuts both ways.** `scent` is inherited with a
mutation rate and nothing reads it for fitness, so this measures ancestry
cleanly and says nothing about adaptation. It is the right instrument for
relatedness and the wrong one for anything else.

**`lineages` is still 1.** Every creature descends from one founder, and F_ST of
65 is *within* that single line. The two numbers are not in conflict and it is
worth being explicit: `lineages` counts founders with surviving descendants and
can only fall, while F_ST measures how the variation that exists is apportioned
in space. **A monoculture can be strongly structured**, and this one is.

---

## What this teaches

- **Naming a confound is not the same as testing it.** The horizon caveat was
  written down honestly and would have sat there indefinitely. It cost one
  parameter and one run to kill, and it turned a result that could not be quoted
  into one that can.
- **The instrument was already in the world.** F_ST needed no new physics, no new
  fact and no new constant: a neutral heritable marker and a spread function had
  been sitting there since world 2, and the question had simply never been asked.
- **`lineages` has been answering the wrong question for six worlds.** `G.1` reads
  every survivor collapsing to one line as the engine dying. It is now clear that
  a world can be one lineage and still hold most of its variation between groups,
  which is a different and much more interesting state than a monoculture.
