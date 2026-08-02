# Results: world 15

**All four pre-registered findings failed, and the reason is one thing: a mouth
mutation is smaller than the resolution of the bill it changes.** The world was
built correctly, the experiment ran, and it tested nothing, because the trait it
depends on cannot be selected at all.

Pre-registered in [PREREGISTRATION_WORLD15.md](PREREGISTRATION_WORLD15.md).
48 seeds, 20,000 ticks, 100% efficiency, default price. **8 survived.**

## The distribution of mouths, which is the whole question

Bins of 50, from 0 to 400.

| seed | mean | pop | mouths per bin | shape |
|---|---|---|---|---|
| 46 | **9** | 34 | `[34,0,0,0,0,0,0,0]` | one mode |
| 39 | **27** | 61 | `[61,0,0,0,0,0,0,0]` | one mode |
| 9 | **58** | 59 | `[17,42,0,0,0,0,0,0]` | one mode |
| 5 | **90** | 62 | `[2,31,28,1,0,0,0,0]` | one mode |
| 12 | **119** | 135 | `[0,34,68,33,0,0,0,0]` | one mode |
| 14 | **318** | 52 | `[0,0,0,0,0,0,52,0]` | one mode |
| 20 | **319** | 79 | `[0,0,0,0,0,17,61,1]` | one mode |
| 23 | **329** | 54 | `[0,0,0,0,0,51,3]`* | one mode |

**Every one is unimodal and contiguous. Not one has a gap.** No world holds two
ways of living. The populations that spread across several bins are a single
cloud of drift around one mode, not two clusters.

\* printed as `[0,0,0,0,0,0,51,3]`.

## Against what was pre-registered

| # | Finding | Result |
|---|---|---|
| 1 | **A trophic split appears and both sides persist** | **FAILED.** Eight worlds, eight unimodal distributions, no bimodality anywhere. |
| 2 | **Mouths track density** | **FAILED.** Mean mouth by population third: 163, 193, 138. No trend. Meat 12%, 0%, 6%. No trend. |
| 3 | **Perception moves, specifically the `creatures` field** | **FAILED, and starkly.** Ground sensors are carried by 76 to 100% of every population. Creature sensors are at 0 to 11% in seven of eight worlds. **Nothing learned to look at what it might eat.** |
| 4 | **Hidden nodes rise** | **FAILED.** 0.00 to 0.43, median 0.04, against world 14's 0.15 at the same horizon. |

Extinctions did not rise (40 of 48 against world 14's 42 of 48) and `lineages` is
1 in all eight, both as pre-registered.

## Why all four failed, and it is one reason

**Seventy-five percent of mouth mutations cost exactly nothing.**

The mutation step is 8. The upkeep divisor is 33. Upkeep is
`(structure + mouth + apparatus) div 33`, so a step of 8 changes what is paid
only when it crosses a multiple of 33.

| mouth, on a body of 400 | bill per tick |
|---|---|
| 0 | 12 |
| 9 | **12** |
| 27 | **12** |
| 119 | 15 |
| 329 | 22 |

A creature carrying a mouth of 27 pays **exactly what one carrying none pays**.
Seeds 46 and 39 did not shed the organ; at that size there is nothing to shed.
And seed 23 carries a mouth of 329, pays nearly double metabolism for it, takes
**0%** of its food from creatures, and persists — because although the gradient
is real at that end, three steps in four along it are invisible.

**The observed spread is what drift alone predicts.** A random walk of ±8 over
roughly 500 generations has a standard deviation near 179; the modes across
worlds run 9 to 329 about a founding draw averaging 200. Nothing here needs
selection to explain it.

## So the pre-registration is untested, not refuted

This is worth being exact about. World 15 asked whether a costly organ produces a
niche. What it measured is whether an organ **whose cost the world cannot
resolve** produces a niche, and the answer to that is no and was never in doubt.
The four findings are recorded as failed because that is what the criteria say,
and none of them is evidence about trophic structure.

## The A.6 explanation was wrong, and re-running with the fix proves it

**Withdrawn.** I explained this null by saying integer truncation made the trait
unselectable: `(structure + mouth) div 33` with a drift step of 8, so three
mutations in four cost nothing. That arithmetic is right **at a fixed body size**
and a real body is not fixed. Over a body drifting across 300 to 500 the
truncated lifetime bill runs 11.64, 11.88 and 12.44 units a tick for mouths of 0,
8 and 27. **The gradient survives truncation.**

The fix went in anyway, because carrying the fraction is strictly more correct
and costs nothing. Re-running this experiment with it changes nothing
interpretable:

| seed | mouth, truncated | mouth, exact |
|---|---|---|
| 5 | 90 | **159** |
| 12 | 119 | **41** |
| 14 | 318 | **80** |
| 39 | 27 | **204** |
| 46 | 9 | **120** |

Up, down, down, up, up. **No direction.** The extremes narrow (9 to 329 becomes
32 to 204) and survivors fall from 8 to 6, but the trait drifts either way and
meat stays at 0 to 6%. Exactly what a random walk does when you change its
increments: a different walk, the same regime.

## So what is the null actually about

**Look at `meat%`: 0, 2, 1, 0, 6, 2.** Almost no energy in these worlds comes
from creatures at all, whatever size mouth they carry.

That is the simplest available explanation and it has nothing to do with pricing:
**there is nothing to eat.** Populations run 32 to 85 on 1,261 cells, three to
seven percent occupancy, so two creatures sharing a cell is a rare event and a
mouth spends its whole existence waiting for one. An organ cannot be selected for
by an opportunity that does not arrive.

It also explains the failure of finding 2 without any appeal to arithmetic. Mouths
were predicted to track density; the densest third here holds 79 creatures, which
is not dense. The world 14 boards that reached 221 are where the prediction could
have been tested and this run never got there.

**That is a claim and it is not tested.** It would need density varied
deliberately rather than left to the seed.

## What `A.6` still is

A real observation about the arithmetic and **not** an explanation for anything
yet. Costs are quantised, the ground floor really does switch off below a
neighbourhood mean of 34, and the bill is now carried at full precision because
that is simply more correct. What it is **not** is the reason a mouth drifts, and
the register says so.

## What did work

**Eating is a decision now, and that part is solid.** Four tests verify it, three
of them go red against world 14's physics. A cell can hold a large creature and a
small one and leave both standing, which was never possible before, and the
implementation taught something the pre-registration had wrong: **the mouth
bounds killing, not eating.** World 11 bounds intake once across both sources, so
a narrow mouth that leaves a carcass grazes it back off the same cell in the same
tick. Being narrow costs nothing while nobody else is standing there.

**And the between-world differentiation is real**, whatever produced it: modes
cluster at 9 to 27, 58 to 119, and 318 to 329. Three regimes across eight worlds,
which is the same shape world 12 found for body size and the fleet shows for
board patchiness. It cannot be attributed to selection for the reason above.

## What this teaches

- **Three instruments failed in one investigation and each was caught later than
  the last should have taught.** `carnivores_pct` counted carriers of a nonzero
  integer and read 94 to 100 across worlds from toothless to a quarter
  carnivorous. Replacing it with a count of occupied histogram bins still could
  not tell a bimodal split from a diffuse cloud. Only printing the bins answered
  the question. The rule that keeps emerging: **a summary of a distribution
  cannot answer a question about its shape.**
- **A name can carry a claim.** `carnivores_pct` named a type in a world whose
  entire design forbids types, in a repo whose spectator page says in as many
  words that there is no carnivore flag to set. Raf caught it, along with
  "herbivore" a day earlier.
- **A cost you cannot see is a cost that does not exist.** The mouth is charged,
  provably, and a unit test fails without it. It is charged in units the mutation
  cannot reliably move it by, which is a completely different thing and shows up
  in no test of the mechanism.
