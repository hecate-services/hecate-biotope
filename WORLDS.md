# The worlds

One line per experiment: what single thing changed, and what happened.

**Worlds are numbered. Register entries are lettered** (`B.5`, `D.2`) — see
[PHYSICS_REGISTER.md](PHYSICS_REGISTER.md) for the catalogue of what this world
still gets wrong about energy, and which entry each world corrects.

| world | what changed | what happened |
|---|---|---|
| **1** | the original build: named actions (`graze`, `hunt`), named organs (`eye`, `nose`), plants as objects | Predation was constant and **nobody made a living from it**. No carnivore niche at any density where worlds survived. [results](RESULTS_WORLD1.md) |
| **2** | **physics only.** No named action or organ; no plants; death returns energy; readings in natural units; a `self` sensor; a hidden layer; reproduction became an output | **100% sessile in every seed**, every sensor and brain selected away. Not a tuning failure: forbidden by arithmetic for any parameter choice. [results](RESULTS_WORLD2.md) |
| **3** | ground recovery depends on its standing stock (`A.1`) | **Nothing.** A stayer holds its cell at zero, so a stock-dependent rule never fires in a populated world. [results](RESULTS_WORLD3.md) |
| **4** | feeding is rate-limited, and the rate is heritable (`D.1`) | **First positive.** The landscape differentiated, `ground_spread` 26–86 against 9 before, and the feeding rate became **the first trait ever selected rather than drifting**. It moved toward greed, because size was free. [results](RESULTS_WORLD4.md) |
| **5** | metabolism scales with what a creature holds (`B.1`) | Size became bounded, 66–99 against a founding 800. **It also undid world 4's positive**: landscape flat again, energy from creatures zero in every seed. [results](RESULTS_WORLD5.md) |
| **6** | separate the **store** from the **structure** (`B.5`) | **Mean lifespan is 2.2 ticks.** Frames came out bimodal, which I first read as two livings and withdrew: mean age climbs 1 to 400 across the buckets, so it is age structure. What survives is an adult and juvenile split ~200x apart in lifespan, which a constant hazard cannot produce. Landscape stayed flat; predation is ubiquitous and worthless. [results](RESULTS_WORLD6.md) |

| **7** | **the Second Law**: every transformation loses a share, swept from 100% to 10% (`D.3`) | **Perception moved for the first time since world 2**, sensors 0.01 to 2.52 per creature, and it was the FIRST law that did it, not the second: it appears at 100% where nothing is lossy. The Second Law differentiated the landscape (`ground_spread` 13 to 30) and destroyed structure entirely. Lifespan fell instead of rising. [results](RESULTS_WORLD7.md) |

| **8** | **capacity is a property of structure**: `absorbed = min(uptake, frame, cell)` (`B.6`) | **Ghosts became impossible**, largest frame 400-560 at every efficiency against zero from 70% down in world 7. And **every seed ended**, 42 of 45 at exactly tick 602, which is `max_age` arriving: the survivors are the FOUNDERS, they stopped breeding before tick 35, and they died of old age on the same day. Not for want of energy. They carry stores of 11,643 to **183,500** against the 400 they were born with. **The world ran out of variation, not energy** (`G.1`). [results](RESULTS_WORLD8.md) |

| **9** | **reproduction is paid out of the store**: a parent does not dismantle its own body to make a child (`C.7`) | **The engine restarted and the world stopped ending.** 3 seeds of 5 run the full 2000 ticks at 100%, still giving birth at the limit, with creatures **54 to 129 generations** descended from the founding against world 8's best of 15. **World 4's landscape came back** (`ground_spread` 86 against 9-30 since world 5) and **something eats for a living for the first time** (`from_creatures_pct` 18-33, 5-31 individuals, zero in every world since 4). Checked and it is NOT infanticide. Dead below 90%: at low efficiency a child is delivered too little to feed itself. [results](RESULTS_WORLD9.md) |

| **10** | **capacity bounds meat too**: a predator takes `min(uptake, frame, what is there)` and what it cannot hold is buried as carrion (`B.7`) | **The jackpot is gone and almost nothing else moved.** World 8 bounded intake by the body at ONE of the two sites energy enters a creature; predation was bounded by nothing, so a kill was worth the whole victim. Energy from creatures 31% to **21%**, largest store 23,446 to **12,555**. **The landscape got SMOOTHER, not lumpier** (`ground_spread` 86 to 60), against the prediction: the jackpot was what made it rough, so life was differentiating the ground by HOARDING rather than by dying. Predation survived being priced, which is the strongest thing here. **Lineages still collapse to 1 of 40** — two ways of feeding are not two niches (`G.1`). [results](RESULTS_WORLD10.md) |

| **11** | **feeding belongs to a creature, not to a contest, and is bounded once**: every survivor in a cell feeds from what is left, up to `min(uptake, frame)` counting meat and ground TOGETHER (`B.8`) | **Every positive prediction failed and the one risk landed.** Only the winner had been eating, and it had been eating twice. Removing the second helping did not change how much predation happens (21%, unmoved) but changed what it is WORTH: seeds surviving 20,000 ticks fell from **9 of 12 to 5**. Density fell rather than rose (918 to 797), and frame and store ROSE rather than falling. Fewer, larger creatures on a lumpier board (`ground_spread` 60 to 66). **Predators were living on the bug.** Lineages still 1 of 40, as pre-registered. [results](RESULTS_WORLD11.md) |

| **12** | **speed**: a creature goes as far as it can pay to go, and the fare per cell is `move_cost + carrying(structure)` (`C.2`, `C.1`) | **THE GIANTS ARE GONE.** Largest frame 3,831 to **450**, largest store 14,249 to **677**, creatures 797 to **1,285**, generations deep at 20,000 ticks ~250 to **~2,480**. Pricing the HAUL did in one change what five worlds of pricing the HOLD could not. The landscape flattened to 22 as a consequence, because concentration in the ground tracks concentration in individuals and there are no hoarders left. **Perception still did not move** (0.10): flight now exists and a creature still cannot afford the eyes to use it. A size axis appeared BETWEEN seeds, not within one — three survivors near 470, one at **11,452**. [results](RESULTS_WORLD12.md) |

| **13** | **an organ is tissue**: `sensor_rent` and `hidden_rent` deleted, apparatus carried by the same `carrying/2` that prices a body, at a swept `neural_cost` (`B.2`, `B.3`) | **PERCEPTION WAS NEVER USELESS, IT WAS UNAFFORDABLE.** A cell yields ~22 a tick and one sensor cost 10 of it, so one eye plus one thought plus staying alive cost more than the ground gives. Priced as tissue and swept: sensors **0.00 to 3.27** per creature, hidden nodes **0.01 to 2.68**, total reach **12 to 2,506**, extinctions 3 seeds in 5 down to **none**. A step change between 110 and 66, and worlds 2-12 sat far above it by accident. **Settles the twelve-world null, not the usefulness** — a nearly free organ drifts. Lineages still 1 of 40 at every price. **Run without a pre-registration, so exploratory.** [results](RESULTS_WORLD13.md) |
| **14** | **bare ground comes back from what is AROUND it**: `ground_seed` deleted, the floor is a share of the mean stock of the neighbouring cells at a swept `recolonise_pct` (`A.5`, `A.2`, `G.4`) | **THE LAWN IS GONE, AND ALL FOUR PRE-REGISTERED FINDINGS LANDED**, which had not happened here before. At the SAME nominal floor of 12: `ground_spread` 22-25 to **33**, sessile survivors **7 of 8 to ZERO**, sensors per creature 0.12 to **1.50** with the price PINNED, `still_pct` 99-100 to **13**. Zero sessile survivors at every rate from 1 to 6, twelve worlds, all mobile. The mechanism is confirmed and not just the headline: sensors within the mobile regime are flat across an eighteen-fold sweep, so the MIX changed and the within-regime value did not. **G.4 corrected and coexistence did NOT follow**: `lines` is 1 everywhere. The price is survival, 22 of 24 dead against 16, and raising the rate rebuilds the lawn monotonically, so the world is either harsh and seeing or generous and sightless. [results](RESULTS_WORLD14.md) |
| **15** | **a mouth is tissue and eating is a decision**: `mouth` is a heritable integer charged by the expression that already prices a frame, `eat` becomes the fourth purpose, and a creature consumes another only if it can and chooses to (`D.2`, `H.1`, targets `G.4`) | **ALL FOUR FINDINGS FAILED AND THE EXPERIMENT IS UNTESTED RATHER THAN REFUTED.** Eight surviving worlds, eight UNIMODAL mouth distributions, no bimodality anywhere: no world holds two ways of living. And none of that is evidence about trophic structure, because **75% of mouth mutations cost exactly nothing**: the drift step is 8, the upkeep divisor is 33, and a creature carrying a mouth of 27 pays what one carrying none pays. The spread of modes across worlds, 9 to 329 about a founding 200, is what a random walk predicts with no selection at all. **`A.6` generalises to every cost in the world and now blocks.** What DID work: eating is a decision, a cell can hold a large creature and a small one and leave both standing, and the mouth turns out to bound KILLING rather than eating. [results](RESULTS_WORLD15.md) |

## The through-line

Of seven corrections, three changed nothing measurable, **three produced a
positive**, and one made something worse. **All six are useful**: a correction that changes
nothing removes a simplification from the list of things that could have been
responsible, which is the only way this kind of map gets built.

The two positives are different in kind. World 4 structured the **landscape**;
world 6 revealed structure in the **population**. Neither produced the other.

**And world 6 is a lesson in reading a distribution too quickly.** A bimodal
histogram in all five seeds looked like two ways of living. One extra
measurement, mean age per bucket, showed the large are simply the old. The shape
was real and the story was wrong, and only a question from Raf about what
overpopulation does energetically produced the number that settled it.

Two rules came out of the run and now govern what gets built next:

- **A tradeoff only motors anything if nothing adjacent is free.** World 4's
  tradeoff was real and was outvoted by size costing nothing.
- **A correction can destroy the variance a later experiment needs.** World 5
  drove energy from creatures to zero, which made `D.2` untestable until the
  store and the structure were separated. World 6 separated them and unblocked
  it.
- **A thing can happen constantly and still not be a living.** World 6 kills
  190,000 creatures a run and no lineage eats for a living, because what gets
  eaten is empty. Counting events is not measuring a strategy.
- **A shape is not a story.** Two modes in a size histogram can be two
  strategies or it can be children and adults, and the histogram cannot tell you
  which. Ask what else differs between the modes before naming them.
- **A bookkeeping error can be a physical rule in disguise.** World 6 charged the
  movement fare in a way that made it, alone among costs, unpayable from your own
  body. Nobody wrote that rule and nobody could see it, and it held perception at
  zero for five worlds. It surfaced only because conservation was made exact.
- **The fire is set by the sun, not by the efficiency.** World 7 burns the same
  total across a tenfold change in efficiency, because in a steady state
  everything that enters must leave as heat. Efficiency changes how much living
  happens per unit burned, never how much burns.
- **Nothing evolves in a world with no lifetimes.** Mean lifespan is 2.2 ticks
  and every apparatus is priced per tick, so no investment can ever repay. This
  is the constraint underneath every null in the register.
- **A world can be rich and finished at the same time.** World 8 ends with
  creatures carrying four hundred times what they were founded with, and it ends
  because nothing has been born since tick 15. Eight worlds of exact energy
  accounting could not have found that, because none of them measured whether the
  population could still change. Measure the engine, not only the vehicle.
- **A tradeoff with an exit is not a tradeoff.** World 8 offered "breed and halve
  yourself" against "do not breed". The second is not a point on the surface, it
  is stepping off it. An axis one end of which leaves the game produces one
  strategy and a terminus, never diversity.
- **Ask whether a law holds at EVERY site, not where it was introduced.** Twice
  now a rule has hidden in the DIFFERENCE between two code paths rather than
  inside either: the movement fare that could not be paid from your own body
  (`C.6`), and world 8's capacity bound applied to grazing and not to predation
  (`B.7`). Neither function was wrong on its own. This is the most productive
  question in the register.
- **Twelve nulls can share one cause, and the cause can be a pricing error.**
  Every results file since world 2 recorded perception at the floor and reasoned
  about why nothing needed to see. The answer was arithmetic, and it sat in the
  register the whole time as B.2 and B.3, both marked *no physics settles it*. A
  flat fee among rates is the same defect as a law applied at one site.
- **Pricing the haul is a different instrument from pricing the hold.** Worlds 5
  and 6 charged for holding a body and size still ran away. World 12 charged for
  MOVING it and bodies capped at a tenth of what they had reached. A cost that
  applies only when you act bites where a standing charge does not.
- **A tradeoff can be real between runs and absent within one.** World 12's seeds
  split into worlds of many small creatures and a world of few enormous ones,
  from identical rules. Alternative stable states, which is not coexistence.
- **Adding a capability is not adding a reason.** Flight became possible and
  perception still did not move, because the same change made the eyes needed to
  use it less affordable. A capability can arrive with a bill that cancels it.
- **A correction can be right and cost something, and both get reported.** World
  11 made the feeding books honest and a third of the surviving seeds died. That
  is the price of the books, not a fault, and it is the second world running
  where stricter physics made a poorer world.
- **"Every extinction is early" is now only "almost always".** Worlds 9 and 10
  saw nothing die between tick 725 and 20,000, and the fleet configs quote that.
  World 11 killed seed 101 at tick 1,174.
- **A prediction can fail informatively.** World 10 predicted carrion would make
  the landscape lumpier and it made it smoother, because the jackpot was what had
  been making it rough. Removing a mechanism is sometimes the only way to see what
  it was doing.
- **A constant that looks like a symmetry is still a constant.** The dowry is
  `div 2` and nobody has ever asked why, because halving reads as a law rather
  than a choice. Written `div 7` it would have been challenged two worlds ago.
