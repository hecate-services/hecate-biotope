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
- **A constant that looks like a symmetry is still a constant.** The dowry is
  `div 2` and nobody has ever asked why, because halving reads as a law rather
  than a choice. Written `div 7` it would have been challenged two worlds ago.
