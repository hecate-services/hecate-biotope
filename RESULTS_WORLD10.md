# Results: world 10

**The change:** capacity bounds meat too. A predator takes `min(uptake, frame,
what is there)`, exactly as a grazer does, and what it cannot hold is buried on
the cell as carrion.

No new constant. Corrects register entry **B.7**. Pre-registered in
[PREREGISTRATION_WORLD10.md](PREREGISTRATION_WORLD10.md).

5 seeds, 2000 ticks, 11 efficiencies, plus 12 seeds to 20,000 ticks.

## The headline

**The jackpot is gone and almost nothing else moved.**

| | world 9 | world 10 |
|---|---|---|
| energy from creatures | 31% | **21%** |
| largest store | 23,446 | **12,555** |
| largest frame | 4,689 | **3,683** |
| `ground_spread` | 86 | **60** |
| founding lines left at 20,000 ticks | **1** of 40 | **1** of 40 |
| mean lifespan | 2.12 | 2.31 |
| dissipated | 27.9M | 28.8M |

Two of the four things pre-registered happened, one failed, and one **happened
in the opposite direction with a better explanation than the one predicted**.

## The prediction that went the wrong way, and what it taught

**I predicted carrion would make the landscape lumpier. It made it smoother.**
`ground_spread` fell from 86 to 60, where 10 is flat.

The reasoning was that scattering corpses across kill sites adds rich cells. What
it missed is where the lumpiness was coming from in the first place.

In world 9 a predator swallowed its victim **entire**, so a successful one
accumulated a store of 23,446, and when that creature eventually died its whole
hoard landed on a single cell. **The landscape was differentiated by hoarding,
not by dying.** Remove the jackpot and stores halve, so deposits are smaller and
more numerous, and the board evens out.

The landscape is still strongly structured, 60 against 10 for flat, and nothing
installed terrain. But the reading of world 4's positive needs care from here:
concentration in the ground was tracking concentration in individuals.

## Against what was pre-registered

| # | Finding | Result |
|---|---|---|
| 1 | **`from_creatures_pct` falls** | **CONFIRMED.** 31 to 21 at 100%, and 16 to 24 across twelve seeds at 20,000 ticks. |
| 2 | **Carrion appears, `ground_spread` rises** | **FAILED, and in the opposite direction.** 86 to 60. See above: the jackpot was the thing making it lumpy. |
| 3 | **Lineages survive past one** | **FAILED, flatly.** All nine survivors of twelve seeds are at exactly one founding line out of forty, identical to world 9. Carrion is not a second niche. |
| 4 | **Being large stops being purely good** | **CONFIRMED.** Largest frame 4,689 to 3,683, largest store 23,446 to 12,555. |

And what was pre-registered **not** to happen:

| Prediction | Result |
|---|---|
| **Predation may stop paying entirely** | **It did not.** 21% and 12 individuals living mainly off creatures, against zero in every world from 5 to 8. World 9's positive on D.2 survives the pricing, which is the strongest thing this world says. |
| **Perception will not move** | **HELD.** 0.13 sensors per creature against 0.22. |
| **The world is still perfectly constant** | Untouched, as stated. |

## The cost, and it is honest to name it

**Survival at 2,000 ticks got worse**: 3 seeds of 5 to 2 at 100%, 3 to 1 at 95%,
1 to 0 at 80%. At 20,000 ticks over twelve seeds the count is unchanged at nine
alive, though the membership shifted: seed 311 now lives where it died, and 309
now dies where it lived.

**The mechanism is a second dissipation step and it was not pre-registered.** The
uneaten remainder pays the efficiency loss on the way into the ground, as every
corpse does, and pays it again when something grazes it. In world 9 that energy
crossed one boundary; now it crosses two. That is correct physics and it is
strictly harsher, which shows up hardest at 95% where the fleet's own margin is
thinnest.

Five seeds is a small sample and the two horizons disagree, so the harshness is
recorded rather than claimed.

## What this world teaches

- **Ask whether a law holds at EVERY site, not at the site where it was
  introduced.** World 8 bounded intake by the body and bounded it in one of the
  two functions where energy enters a creature. Nothing was wrong in either
  function; the rule lived in the difference between them, exactly as the
  movement fare did in C.6. That is now twice, and it is the most productive
  question in this register.
- **A prediction can fail informatively.** The landscape got smoother because the
  jackpot was what made it rough, which is a fact about world 9 that world 9
  could not have told us. It took removing the mechanism to see what the
  mechanism was doing.
- **Two ways of feeding are not two niches.** Carrion is a real second route to a
  meal and it did not hold a second lineage for a single seed. Entry **G.1**
  stands untouched: this world still loses 39 of its 40 foundings, and whatever
  fixes that is not a second food source.
