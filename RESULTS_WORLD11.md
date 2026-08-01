# Results: world 11

**The change:** feeding is a property of a creature, not of a contest, and it is
bounded once. Every creature the contest leaves alive feeds from what is left
where it stands, up to `min(uptake, frame)` counting meat and ground together.

No new constant. Corrects register entry **B.8**. Pre-registered in
[PREREGISTRATION_WORLD11.md](PREREGISTRATION_WORLD11.md).

5 seeds, 2000 ticks, 11 efficiencies, plus 12 seeds to 20,000 ticks.

## The headline

**Every positive prediction failed, and the one risk I wrote down landed
hardest.**

| | world 10 | world 11 |
|---|---|---|
| seeds alive at 20,000 ticks | 9 of 12 | **5 of 12** |
| creatures at 100% | 918 | **797** |
| largest store | 12,555 | **14,249** |
| largest frame | 3,683 | **3,831** |
| `ground_spread` | 60 | **66** |
| energy from creatures | 21% | 21% |
| mean lifespan | 2.31 | 1.97 |
| founding lines left | 1 | 1 |

Correcting the books made the world markedly harsher, and it did **not** produce
any of the three things the correction was expected to produce.

## Against what was pre-registered

| # | Finding | Result |
|---|---|---|
| 1 | **Density rises**, since a tie no longer costs a whole meal | **FAILED, and it fell.** 918 to 797. The tie case is rare: at about 800 creatures on 1,261 cells most cells hold one creature or none, so the sharing almost never fires. What fired instead was the other half of the correction. |
| 2 | **`from_creatures_pct` falls further** from 21% | **FAILED, no movement.** 21% at 100%, 15 to 21 across twelve seeds at 20,000 ticks against world 10's 16 to 24. |
| 3 | **Being large stops paying twice**, so frame and store fall again | **FAILED, and both rose.** Store 12,555 to 14,249, frame 3,683 to 3,831. |

And what was pre-registered **not** to happen:

| Prediction | Result |
|---|---|
| **Extinctions may rise** | **CONFIRMED, and this is the result.** Nine seeds of twelve reached 20,000 ticks under world 10; five do now. Removing the second helping took a real subsidy out of the world. |
| **The monoculture is untouched** | **CONFIRMED.** Every survivor is at one founding line of forty, exactly as before. **G.1** is unmoved, as stated. |
| **Perception will not move** | **HELD.** 0.07 sensors per creature. |

## What the failures say

**Predators were living on the bug.** The one change that mattered was the
double helping: a creature that made a kill used to take its body's worth of
meat and then its body's worth of ground. Removing it did not reduce how much
predation happens, which is why `from_creatures_pct` did not move. It reduced
what predation was **worth**, and a third of the seeds that used to survive no
longer do.

**Fewer and larger, on a lumpier board.** Population fell while both frame and
store rose and `ground_spread` went back up from 60 to 66. The world now
supports fewer creatures, the ones that persist are bigger, and their deaths
concentrate the ground again. That is the reverse of world 10's finding and by
the same mechanism read backwards: concentration in the ground tracks
concentration in individuals.

## One generalisation is now dented

World 9's survey found **every extinction was early**: 601, 630, 725, and
nothing between 725 and 20,000. That was repeated for world 10 and used to argue
that an island fails in its founding phase or not at all.

**Seed 101 died at tick 1,174.** Well past the founder cohort ageing out, and
past anything previously observed. The claim should now read "almost always
early", and the fleet's own configs quote the stronger version.

## What this world teaches

- **A correction can be right and cost something, and both must be reported.**
  The books are now honest: one creature, one capacity, whatever it eats. The
  price was a third of the surviving seeds. That is the price of the books
  rather than a fault, and it is the second world running where making the
  physics stricter made the world poorer.
- **Three failed predictions in one world is a good run, not a bad one.** Each
  was a specific claim about which half of the correction would matter, and the
  measurement says plainly that it was the double helping and not the tie. That
  is information a vaguer prediction would not have bought.
- **The tie case was almost irrelevant, and I could have known.** At 800
  creatures on 1,261 cells, most cells hold nought or one, so "everyone in a
  cell eats" changes almost nothing. A density estimate before the run would
  have said so, and would have made the pre-registration sharper.
