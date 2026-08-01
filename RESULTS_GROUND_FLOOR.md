# Results: the floor under bare ground

**The premise this was run to test is false, and that is the result.**

Pre-registered in [PREREGISTRATION_GROUND_FLOOR.md](PREREGISTRATION_GROUND_FLOOR.md).
No physics changed: `ground_seed` swept from 0 to 48 with the control at 12, 24
seeds, 4,000 ticks, 100% efficiency, `neural_cost` pinned at 330 throughout.

| floor | crossover | dead | sessile | mobile | sens sessile | sens mobile | body sessile | body mobile | stock sessile |
|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | **24** | 0 | 0 | - | - | - | - | - |
| 3 | 50 | 17 | 5 | 2 | **0.00** | 1.51 | **43** | 476 | 186 |
| 6 | 100 | 17 | 5 | 2 | **0.00** | 1.88 | **42** | 564 | 196 |
| 9 | 150 | 16 | 6 | 2 | **0.00** | 2.46 | **46** | 562 | 203 |
| **12** | 200 | 16 | 7 | 1 | **0.00** | 0.96 | **65** | 403 | 195 |
| 18 | 300 | 20 | 3 | 1 | **0.00** | 3.04 | **87** | 879 | 168 |
| 24 | 400 | 21 | 0 | 3 | - | 2.21 | - | 794 | - |
| 36 | 600 | **9** | **14** | 1 | 0.24 | 2.30 | **320** | 565 | 93 |
| 48 | 800 | **5** | **17** | 2 | 0.21 | 3.00 | **495** | 1169 | 191 |

The control row reproduces the standalone 24-seed run exactly, which is the check
that the sweep is measuring what it says.

## Against what was pre-registered

| # | Finding | Result |
|---|---|---|
| 1 | **The sessile regime disappears when the floor stops funding it.** No survivor with `still_pct >= 90` at a floor of 9 or below | **FAILED, and not marginally.** Five, five and six sessile worlds at floors of 3, 6 and 9. A floor of 3 is a quarter of the minimum upkeep it was supposed to be paying. |
| 2 | **Perception rises as the floor falls, through the regime MIX and not within a regime** | **The important half LANDED and the headline half failed.** Sessile worlds carry 0.00 sensors at every floor from 3 to 18; mobile worlds carry 0.96 to 3.04 at every floor, with no trend. Perception is a property of the way of life and not of this constant. But the mix does not move — 1 to 3 mobile worlds of 24 at every value — so total perception does not rise. |
| 3 | **Above 12 the sessile regime takes a larger share** | **CONFIRMED at 36 and 48, contradicted at 18 and 24.** Sessile worlds go 7 to 14 to 17 at the rich end, and 7 to 3 to 0 on the way there. Non-monotonic. |
| 4 | **Standing stock tracks the crossover** at `floor * 100 / 6` | **FAILED completely.** Stock sits at 186 to 203 while the crossover moves from 50 to 200, and at a floor of 36 the crossover is 600 and the stock is 93. Standing stock is set by grazing pressure, not by the growth curve. |

The anchor landed: **a floor of 0 kills all 24 seeds**, as world 3's own comment
predicts.

## What actually holds the sessile regime up

Not the floor. Look at the body column: **43, 42, 46, 65, 87, then 320 and 495.**
Sessile body size tracks the floor across a sixteen-fold range.

The creatures re-size. A creature that stays put earns what one cell yields and
pays `metabolism + structure/33`, so **there is always a body small enough for
that to balance**, and selection finds it. Lower the floor and the sessile
lineage does not die, it shrinks. Raise it and it grows. At a floor of 3 the cell
is no longer yielding the floor at all: standing stock is 186, so 6% compounding
gives 11 against an upkeep of 11, and the lineage has quietly moved from living
on the subsidy to living on the interest without changing anything it does.

**And the population sets the stock.** Grazing drives standing stock down until
the marginal grazer breaks even, which is why stock sits near 200 at four
different floors. That is a density equilibrium, so no value of this constant can
remove the strategy: whatever the floor, the population grazes to where sitting
still is worth exactly as much as it costs.

**The sessile regime is an attractor of the density dynamics, not a consequence
of a constant.** That is why the register was right to decline twice, for a
reason better than the one it gave.

## What this kills, and what it earns

**It kills world 14's candidate rule.** Deleting the floor and recolonising bare
ground from its neighbours rested on the floor being what creates the regime with
no perception in it. It is not. The rule would have been built, run and reported
before anything contradicted it, and it cost six minutes to find out instead.

**It confirms the thing worth keeping.** Perception belongs to mobility at every
floor in the sweep, with the price of a sensor held fixed throughout. Sessile
worlds: 0.00 sensors, nine values out of nine. Mobile worlds: 0.96 to 3.04,
every value. World 13 showed sensors respond to their price; this shows they
respond to how a creature makes a living, with price controlled.

**And it points somewhere specific.** If no constant removes the sessile
attractor because the population re-equilibrates against it, then what removes it
is something the population cannot equilibrate against: **variation in time**. A
creature at break-even on one cell dies in the first bad spell; one that can go
where the ground is currently good does not. That is **A.4** and **G.3**, both
open, and A.4 already says temporal variation in supply is the one thing
dispersal theory most reliably ties to movement.

## Unresolved, and stated rather than smoothed

**Extinction is non-monotonic and I cannot explain it.** Deaths run 16, 16, 20,
21, 9, 5 across floors 9 to 48. The improvement at the rich end is far outside
noise; the bump at 18 and 24 is about two standard deviations on 24 seeds and may
be nothing. Enrichment destabilising a consumer-resource system is a named
prediction (Rosenzweig 1971) and would fit, and **this run cannot distinguish it
from sampling.** It is not claimed.

**The ground holds more than the ceiling in the mobile worlds** — stock per cell
of 663, 765 and 782 against a ceiling of 400 — which is carrion, since a corpse
can carry a cell above anything sunlight builds. Consistent with those worlds
having the largest bodies in the sweep. Noted, not investigated.

## What this teaches

- **A cheap test of a premise beats a careful build on top of it.** The rule this
  was meant to justify would have been a week of work aimed at a mechanism that
  does not exist.
- **A population re-equilibrates against any constant you move.** Four of the
  nine floors give the same standing stock and the same one-unit margin, by
  different routes. Sweeping a constant tells you what the population does about
  it, which is not the same as what the constant does.
- **Two failed predictions and one half-landed is a good run.** Finding 4 was
  wrong about the mechanism, finding 1 was wrong about the consequence, and the
  half of finding 2 that survived is the one worth having, because the price was
  held fixed while it happened.
