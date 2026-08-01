# Results: world 12

**The change:** a creature goes as far as it can pay to go, and carrying a body
costs. The fare per cell is `move_cost + carrying(structure)`, and a creature
will not re-enter a cell it has already stood in this tick.

No new constant. Corrects register entries **C.2** and **C.1**. Pre-registered
in [PREREGISTRATION_WORLD12.md](PREREGISTRATION_WORLD12.md).

5 seeds, 2000 ticks, 11 efficiencies, plus 12 seeds to 20,000 ticks.

## The headline

**The giants are gone.**

| | world 11 | world 12 |
|---|---|---|
| largest frame | 3,831 | **450** |
| largest store | 14,249 | **677** |
| creatures | 797 | **1,285** |
| mean lifespan | 1.97 | **2.67** |
| generations deep at 20,000 ticks | 220 to 470 | **~2,480** |
| `ground_spread` | 66 | **22** |
| individuals living off creatures | 10 | **27** |
| seeds alive at 20,000 ticks | 5 of 12 | 4 of 12 |
| founding lines left | 1 | 1 |

An order of magnitude off the largest body, sixty percent more creatures, and a
five-fold rise in generational turnover. Pricing the haul did in one change what
five worlds of pricing the hold could not: **it made being large expensive
enough to stop.**

## Against what was pre-registered

| # | Finding | Result |
|---|---|---|
| 1 | **A size axis appears**, small-and-fast against large-and-slow, both present at once | **PARTIAL, and in a shape I did not predict.** Within an island, no: every survivor is still one lineage running one strategy. **Between islands, strikingly.** Three survivors settled at about 1,050 creatures with bodies near 470; seed 312 settled at 117 creatures with a largest body of **11,452**. The tradeoff is real enough to produce two different worlds from the same rules, and not enough to hold both in one. |
| 2 | **Perception moves.** This was the target | **FAILED.** 0.07 to 0.10 sensors per creature. Eleven worlds and the number has not moved off the floor since world 7's accounting fix. |
| 3 | **`still_pct` falls and the landscape differentiates more** | **FAILED, and the landscape went the other way.** `ground_spread` 66 to 22, nearly flat. |
| 4 | **Lineages survive past one** | **FAILED.** All four survivors at one founding line of forty. **G.1** has now resisted worlds 9, 10, 11 and 12. |

And what was pre-registered **not** to happen:

| Prediction | Result |
|---|---|
| **Extinctions will probably rise again** | **CONFIRMED.** 5 seeds of 12 to 4. Third world running where stricter physics costs survival. |
| **The most likely outcome is still nothing** | **Wrong, and I am glad to have written it down.** This is the largest set of movements in the register since world 4. |

## Why the landscape flattened, which is world 10's finding a third time

`ground_spread` fell from 66 to 22, against a prediction that it would rise.

World 10 established that concentration in the ground tracks concentration in
**individuals**: a creature that hoards 14,000 and then dies drops the lot on one
cell. World 11 read the same mechanism backwards when bodies grew again and the
board got lumpier.

World 12 removes the hoarders. The largest store is now 677 rather than 14,249,
so nothing dies rich enough to make a rich cell. **A world of small creatures has
a flat landscape**, necessarily, and that follows from the mechanism rather than
being a separate finding.

## The perception result is the one that matters

The whole argument for this world was the register's own diagnosis: brains are
deleted because there is nothing to decide, and nothing to decide because flight
does not exist. Flight now exists. **Perception did not move.**

So the diagnosis is either wrong or incomplete. The most likely missing piece,
and it should have been obvious: **a creature cannot flee what it cannot afford
to see.** A sensor costs 10 a tick against a cell yield of about 22, and world 12
made movement cost *more*, so the budget for perception got tighter rather than
looser at exactly the moment perception became useful.

Speed made fleeing possible and simultaneously made it harder to pay for the
eyes that would tell you when to. That is a genuine interaction and it was not
in the pre-registration.

## What this world teaches

- **Pricing the haul did what pricing the hold could not.** Worlds 5 and 6
  charged for holding a body and size still ran away; charging for moving it
  capped bodies at a tenth of what they reached. A cost that only applies when
  you act is a different instrument from one that applies while you sit.
- **A tradeoff can be real between runs and absent within one.** Seed 312 is a
  world of few enormous creatures and its neighbours are worlds of many small
  ones, from identical rules. That is the clearest thing this project has
  produced about alternative stable states, and it is not coexistence.
- **Adding a capability is not the same as adding a reason.** The
  pre-registration said a capability is not a reason and predicted this might be
  a null on perception. It was, and for a reason worth having: the capability
  arrived with a bill that made the sense organ it needed less affordable.
