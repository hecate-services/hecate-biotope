# The worlds

One line per experiment: what single thing changed, and what happened.

> ## ⚠ WORLDS 1 TO 16 REPORT NUMBERS THAT CANNOT BE REPRODUCED
>
> A world was not a pure function of its seed until 2026-08-02, register `G.6`.
> The rows below are what was observed and are **not withdrawn**: the effects are
> large and an ordering fault perturbs a trajectory rather than pushing it one
> way, so the conclusions are expected to stand. **Exact figures are not
> reproducible** and must be re-measured before anything new is built on one.
> World 17 onward is checked by the `cross-vm` column of
> `scripts/same_seed_same_world.escript`.

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
| **16** | **a hidden node is charged by what it READS**: `hidden_weights` replaces `hidden_count` in the tissue expression, so a node wired to six inputs costs six times one wired to a single input, and sensors and brains become coupled (`H.9`, which is `B.3` still standing) | **COMPUTATION BECAME PRICE-SENSITIVE, AND THE WORLD TURNS OUT UNABLE TO EXPRESS A NARROW BRAIN.** Hidden nodes run 0.09 to **2.83** per creature across the sweep, a thirty-one-fold range against world 14's thirteen over the same prices and horizon, and 2.83 is the highest recorded here. It costs survival: **22 of 24 dead at the control**, falling to 9 at the cheap end. Two findings failed and one of them could never have succeeded: a hidden node ALWAYS reads every input, so width is `sensors + 1` and not a trait, the only way to make a node cheaper is to drop a sensor, and perception and computation cannot trade when the only lever moves both. Entered as **`H.11`**: a cost cannot select for a shape the genome cannot represent. `lines` 1 everywhere, F_ST 36 to 61 so world 14's structure survives a much dearer brain. [results](RESULTS_WORLD16.md) |
| **17** | **a reading is an INTENSITY, not a total**: a spatial field reports the mean over the cells in reach and the unit is the ceiling spread over a **swept** `sense_scale`, so every reach reads on one scale and reach means how far you average rather than how much you add (`F.2`, the third face of `A.6`) | **THE MECHANISM WORKS AND THE WORLD REJECTS IT.** Swept over 96 seeds and 20,000 ticks, **extinctions rise monotonically with resolution**: 80, 87, 89, 91, 94, 94, 93 as the scale goes 1, 2, 4, 8, 16, 32, 63. So viability, the only criterion this project allows, selects **1, the blindest setting on the sweep**, where a reach-0 ground sensor reads zero 87 to 100% of the time against world 16's 88 to 100%. **At reach 0, which is what the fleet carries, a mean over one cell is a sum over one cell: for the sensors that exist this world is arithmetically world 16.** Perception did not rise (2.19 against a target of 6.49) and hidden nodes did not move (≤0.08), which the pre-registration said in advance would be the answer: the problem was never the senses. **Three answers were given for one constant, 63 from tidiness, 2 from 24 seeds against non-reproducible physics, and 1 from 96 seeds; the middle one was deployed to the fleet.** It also caught the sixth instrument failure (`I.6`), voided its own first-observation table, and, while being written up, exposed **`G.6`: a world was never a pure function of its seed.** New: **`F.4`, whether a resolving sense is FATAL rather than useless**, which is the first question here whose answer would change what a world is for. [results](RESULTS_WORLD17.md) |
| **18** | **an act is TISSUE**: an output is charged by its wiring at a swept `act_cost`, so being able to do four things need not cost what being able to do none costs (`H.7`) | **A UNIFORM PRICE SELECTS ON EXACTLY THE CAPABILITIES WHOSE LOSS IS SURVIVABLE.** Over 48 seeds and 20,000 ticks, purposes per creature fall 3.71 to **2.06**, and not evenly: **`move` and `breed` are carried by 81 to 100% at every price** while **`eat` falls 91% to 2% and `grow` 84% to 6%**. Losing `breed` ends a lineage in one generation and world 14 left no sessile survivors, so those two cannot be shed; the other two can. **The price found the organs whose absence is survivable rather than the least useful ones**, predicted in advance from `H.12` and the first prediction here derived from another finding rather than from a guess. Costs survival, 40 to 47 dead of 48. Sensors fall 2.18 to 1.20 with it, which is world 16's coupling from the other side. **The default is 16, the most viable value clearing the pre-registered drift floor, and at 16 nothing visible happens**: the shedding needs four times the floor, which is a third bound on `H.10`. [results](RESULTS_WORLD18.md) |
| **19** | **a weight costs only if it is NON-ZERO**: `hidden_weights` and `output_weights` count live weights rather than row length, so a brain pays for what it uses rather than for the shape it was born in (`H.11`, re-pricing `B.10`) | **WIDTH BECAME EXPRESSIBLE AND SELECTION DID NOT USE IT. THE PRICE WAS THE THING.** Over 48 seeds at 20,000 ticks, live weights per node run 77 to 100% of full against a pre-change baseline of 85 to 97%: **a lineage can economise on connections now and does not**, because `brain_mutation` is 1 on a range of ±8 and a saving must be re-won every generation against a symmetric operator. That was the pre-registered risk and it landed. What DID move is survival: **41 of 48 dead at the control against 24 at `neural_cost` 11**, so `B.10` is confirmed and the default falls **thirty-fold from 330 to 11**. The 330 was never chosen: its own comment says it reproduces the flat rent world 13 deleted as a defect. Computation responds fifty-fold across the sweep (0.02 to 1.11 nodes per creature) and never overtakes perception (5.90 sensors). ⚠ A 2,000-tick run read a clean monotone narrowing that did not survive the horizon, on a column measured over the ~1% of creatures carrying a node. [results](RESULTS_WORLD19.md) |
| **20** | **a birth can have TWO parents**: a creature that breeds with somebody in the seven cells it can reach makes a child from both, aligning sensors by `{field, rank}`; alone, it clones exactly as before | **UNMEASURED AGAINST A CONTROL, and the control was deliberately deleted.** The radius was chosen on a measurement rather than on taste: a creature shares its CELL with another for 10% of its ticks and has someone in the seven cells for 55%, so co-location alone is about ONE encounter per lifetime, which is `D.7` exactly, and would have fired too rarely to be told from drift. Outcrossing fires on 73 to 84% of births. Twenty worlds of clonal reproduction meant a sensor invented in one family and a brain invented in another could never meet, which is Hill-Robertson interference with no answer. **It also surfaced a latent crash reachable since world 6**: `inputs_of/1` recovered a brain's sensor count from its own vectors and returned 0 when a brain had neither hidden layer nor outputs, and a child can now lose all four purposes in one birth. |
| **21** | **a creature carries what it just thought into the next tick**: a hidden row is `sensors + 1 + nodes`, the extra weights reading the previous tick's activations (Elman context), written once a tick and never during the eleven hypothetical evaluations | **MEMORY IS EXPRESSIBLE AND DOES NOT PAY.** Over 48 seeds at 20,000 ticks, deaths are equal or worse at eight of nine prices, **29 against 24 at `neural_cost` 11**, and hidden nodes FALL from 0.41 to 0.25 there. A row gained one live weight per node, so a node on one sensor went from two live weights to three: **memory did not fail to be used, it made computation less affordable to have.** The same shape as `B.10` found for computation itself. ⚠ A six-seed determinism check read four survivors against one and was reported as suggestive; forty-eight seeds say the opposite and it is withdrawn. [results](RESULTS_WORLD21.md) |
| **22** | **a hidden node has a NAME and a creature breeds with its own kind**: NEAT historical marking, per world and in the world record rather than in ETS, so two brains sharing a mark share a node and their weights for it are homologous; and a partner is the least strange in reach by scent | **DISCOVERY STILL STOPS.** Over 32 seeds to 8,000 ticks the frontier of newly-found ways-of-living runs 42, 9, 3, 2, 1, **0, 0, 0**: the median world has converged by tick 6,000 whatever its population is doing. Marks replaced the file's own admission that "computation recombines only by position", and assortative mating is NEAT's speciation achieved with a trait the world already documents as kin recognition, needing no compatibility threshold. Neither prevented convergence. ⚠ A single seed showed architectures RISING 5 to 17 and the frontier never reaching zero; thirty-two seeds say otherwise. **Second time in two days a one-seed reading agreed with what had just been built and was wrong.** |
| **23** | **there is WATER, it is only in some PLACES, and a creature DRIES OUT and must go back to drink**: a store of capacity `structure` draining by a swept `thirst` each tick, refilled to full by standing on a hole, death by drying counted separately as `parched`; a fifth field appended to `?FIELDS` so water can be perceived, and a swept number of holes placed in rings from the centre (`J.1`, `J.2`) | **`J.1` IS REFUTED, ON THE CRITERION THIS WORLD WROTE DOWN BEFORE IT RAN.** A second requirement gives these brains nothing to decide. Over 64 seeds to 8,000 ticks: water carriers **0-2%**, approach **0-3%** against a control of 4%, frontier **0-1** against 0, and ways of living explored FELL from **81 to 64-66**. Predation fell where `D.7` said it would rise. The one positive, nodes rising from 0.33 to 0.48-1.16, **does not survive its control**: world 22's own nodes run 0.23 to 1.00 across a mortality ladder with no trend, one arm spreading 0.00-3.85 within itself, while thirst kills 84-89% of seeds against 56%. ⚠ **The manipulation check PASSES** -- leash ~21 ticks against a living creature's age of 23 -- so the world did ask. ⚠ **The zero-holes arm is the most informative row**: 100% carry a sensor for water on an island that has none, so that column is drift and `G.10`'s 6.72% floor covers every figure in it. ⚠ At 24 seeds the 37-hole arm had every living seed above control; at 64 its minimum is 0.00, the third small-n reading here to agree with what had just been built and be wrong. **The first default, `thirst` 40, killed every seed at every hole count**, as did 20; the whole table sits beside the constant. ⚠ **AND THE FIRST DRAFT OF THIS WORLD WAS ABSURD**: it made breeding require standing on water, reasoned from "a round trip is impossible in one life, so thirst is unbuildable", which does not follow because the leash is `structure / thirst` and both are mine to pick. `I.17`. [results](RESULTS_WORLD23.md) - [pre-registration](PREREGISTRATION_WORLD23.md) |
| **24** | **the water is LAKES AND RIVERS, cut fresh for every island**: a budget of wet cells spent on blobs grown outward from a point and on walks that run from inland to the shore, drawn from the world's own RNG so each seed gets its own landscape; and water is put ON THE WIRE for the first time and drawn blue under the ground | **A CORRECTION, NOT AN EXPERIMENT.** Raf asked why the islands showed no rivers or lakes. Two answers, both mine: **water was never published at all** -- world 23 added it to the physics, to `?FIELDS`, to the sweep and to the pre-registration, and never to `world:chart/1`, so no page could draw the one thing that world was about, and there was not even an accessor to read the cells with. And **the shape was a bullseye**: single cells on rings spaced `radius div 4` apart, which came out as one cell at the centre, a complete circular MOAT of thirty cells at distance five, and half a ring at distance ten. ⚠ **73% of the island lay beyond the outermost water**, so for three quarters of the board "go and drink" was not a decision but a death sentence, which is a plausible reason world 23 culled rather than taught anything. Now **0%**. ⚠ It also surfaced a latent bug: `river/3` picked its source at `max(1, radius div 2)`, which is OFF THE BOARD on the small discs every conservation test runs on. **World 23's numbers were all taken on the rings and are not re-run**; they describe a landscape that no longer exists, and `RESULTS_WORLD23.md` says so at the top. |

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
