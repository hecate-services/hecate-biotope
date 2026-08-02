# The physics register

> **Naming.** Entries here are lettered (`B.5`, `D.2`) and **worlds are numbered**
> (world 4, world 5). They were both numbered once and it was impossible to tell
> "world 2.5" from an entry id. See [WORLDS.md](WORLDS.md) for what each world
> did and what happened.

Every place this world simplifies the behaviour of energy, whether that
simplification has been corrected, and what happened when it was.

**This exists because the goal is to exhaust the pathways, not to predict which
one works.** Five worlds have each been preceded by a guess about what would
emerge, and the guesses have been wrong every time and were never the point. A
world is a coordinate on a map, not a bet. What makes the map trustworthy is that
the pathways were enumerated BEFORE it was known which mattered, so the order of
work cannot be chosen by what looks promising.

## The line this register walks

Biology is legitimate as **evidence about how energy behaves in living systems**,
and illegitimate as a **statement about what should emerge**.

"Metabolism scales with mass" is a fact about energy and belongs here. "Predators
should appear" is a conclusion and must never be installed. Every entry below is
of the first kind, and an entry earns its place by being a fact about energy that
this world currently gets wrong, not by being likely to produce anything.

## What an entry is actually worth: does it price a free good?

Raf, on method: **tradeoff** is the load-bearing word.

The precise claim is not that tradeoffs drive evolution. Evolution runs without
them: if longer legs are always better, legs get longer, and we have had plenty
of that. Sensors were removed, feeding rate climbed, brains were deleted. All
real selection, all converging on one answer.

**Tradeoffs are the motor of DIVERSITY.** When increasing one good decreases
another, the best point becomes conditional, so different circumstances give
different optima and there is finally something to be good at. Without one there
is a single answer and everything finds it.

It fits every result this project has:

| | live tradeoff? | outcome |
|---|---|---|
| `breed_at`, world 1 | designed as one, but children almost never starved, so the cost side was near zero | drifted |
| scent signature | none: costs nothing, does nothing for its bearer | drifted |
| the nose, world 1 | yes, but rent exceeded the gain about threefold | selected out |
| sensors, every world | rent against information, and information is worthless when nothing moves | selected out |
| stock-dependent recovery, world 3 | created none: a stayer's income was unchanged | nothing happened |
| **feeding rate, world 4** | **yes, genuinely: eat now against the cell sustaining you later** | **the first trait in five worlds to be SELECTED rather than drift** |

### And the refinement world 4 forced

That tradeoff was live and it still resolved toward greed, because a third term
with no tradeoff attached overrode it: large creatures win contests, 97% of all
deaths are being eaten, and **holding energy costs nothing**.

**A tradeoff only motors anything if nothing adjacent is free. One free good
neutralises every tradeoff it touches.**

### The free goods currently in this world

- ~~**holding energy** (B.1)~~ — priced in world 5, and pricing it cost the only
  positive the project had. A free good is not simply a defect to be removed:
  something may be living on it.
- **eating at all** (D.2) — no cost to subdue, and no decision either
- **eating a creature specifically** (D.3) — perfect trophic efficiency, so
  carnivory costs no more than grazing
- **being still** (C.2) — costs nothing and risks nothing, since nothing can find
  you

Every failure recorded here traces to one of those four. **An entry that prices a
free good is worth more than one that does not**, and the four above are marked
in the tables.

### Why the brains keep being deleted

**COMPUTATION IS HIGHER UNDER WORLD 14 AND PATCHINESS IS NOT WHY.** Tested and
the hypothesis reversed. Hidden nodes read 0.00, 0.16 and 0.25 on three live
islands whose boards had `ground_spread` 24, 83 and 89, which looked like a
gradient and was not: pooled over **164 surviving worlds**, hidden nodes run
**1.68, 1.72 and 0.80** from the flattest third to the patchiest. The patchiest
boards carry the LEAST computation and the MOST creatures, 221 against 125, and
they carry less of every organ including sensors. **Patchiness does not buy a
reason to compute, it buys crowding, and crowding taxes every organ.** The flat
island that started this had 23 creatures: it was not a flat board, it was a
nearly empty one.

What survives is that **hidden nodes are above the twelve-world floor of 0.01 at
every price under world 14**, 0.15 at the control where world 13 recorded 0.01.
**That result is confounded by the horizon** — this ran to 20,000 ticks and world
13's sweep to 2,000 — and testing the horizon is the cheapest thing left. The
mechanism argument that a linear brain can add and cannot divide is untouched by
this and unsupported by it. See
[RESULTS_BRAINS_AND_STRUCTURE.md](RESULTS_BRAINS_AND_STRUCTURE.md).


A brain is the organ for resolving a tradeoff CONDITIONALLY: eat fast when the
cell is rich, flee when small, fight when large. It is worth its rent exactly
when the right answer depends on circumstance.

This world has **one drive**. Hunger, survival and reproduction all reduce to
*get more energy*, which is food, armour and offspring at once. Nothing pulls
against anything. And the one place a genuinely competing drive could have lived
is gone: **flight does not exist** because nothing can escape, and **fight is not
optional** because consumption is unconditional.

So the brains are not being deleted for being too small. **They are being deleted
because there is nothing to decide.**

## The order of work

**Price the free goods first, then follow the energy.**

The second half is structural and was fixed before any of it was attempted:
where energy enters, what it costs to hold, what it costs to act, how it
transfers, where it goes. It cannot be quietly re-sorted toward whatever seems
promising this week.

The first half is an amendment, made after world 4 and recorded rather than
slipped in. **Free goods confound everything downstream of them.** World 4
introduced a genuine tradeoff, the tradeoff was live, and it was overridden by
size being free; read less carefully, that result would have said "feeding rate
does not matter" when the truth was "feeding rate was outvoted".

Any correction made while an adjacent free good remains gives an **uninterpretable
result**: a null cannot be told from a null-that-was-neutralised. So the free
goods marked in the tables come first, and the amendment is on grounds of
confounding rather than of promise. That distinction is the whole reason it is
allowed.

---

## A. Where energy enters

| # | The simplification | Status |
|---|---|---|
| A.1 | Ground recovered at a fixed rate regardless of what was left in it | **CORRECTED**, world 3. No effect on anything: a stayer strips its cell to zero every tick, so nothing ever holds stock for a stock-dependent rule to act on. |
| A.2 | Recovery is spatially uniform: no terrain, no fertile or barren ground | **CORRECTED**, world 14, **by the route this entry named as the acceptable one.** No terrain generator and no free parameter chosen to make sensors pay: the floor under a cell is a share of what its neighbours hold, so structure arises from where creatures have grazed. `ground_spread` runs 33 to 58 against the 22 to 25 it held from world 12, and at the control the SAME nominal floor gives 33, and the live islands reach **83 and 89 at 35,000 ticks**, which beats every world in this register including world 4's 86. **AND THE STRUCTURE IS LOAD-BEARING, measured rather than admired.** The living gather into blobs holding ten times the share chance would put in the largest, on ground **72 to 94 times richer** than the rest of the board, and **a cell occupied now is still occupied five thousand ticks later at up to 4.8 times chance — about a hundred generations**, so the lump outlives its inhabitants many times over and is a property of the PLACE. A child is placed on a neighbouring cell, so local birth makes clumps on its own, but demographic clumps dissolve within a generation and these do not decay between 50 ticks and 5,000. The island whose board stayed flat (`ground_spread` 24) has blob statistics **indistinguishable from random** on the same binary at the same tick, which is the control nobody had to design. See [RESULTS_LUMPS.md](RESULTS_LUMPS.md) and [RESULTS_WORLD14.md](RESULTS_WORLD14.md). Formerly: **OPEN, and deliberately so.** A terrain generator has free parameters, and the honest criterion for setting them would be "correlated over the distances a sensor can evolve to reach", which is choosing the world's structure so that sensors pay. Emergent enrichment has no such knob. |
| A.3 | Standing stock is capped at a ceiling | **OPEN.** Real systems do saturate, so this is probably right, but the cap is a chosen number rather than a derived one. |
| A.6 | **Recolonisation has a hard threshold nobody wrote**, put there by integer division | **OPEN, and found by looking at a picture.** World 14's floor is `mean(neighbours) * recolonise_pct div 100`, which at the control of 3 is **exactly zero for any neighbourhood averaging under 34** of a ceiling of 400, and the compounding term `E * 6 div 100` is **exactly zero under a stock of 17**. So the rule as STATED decays smoothly toward nothing and the rule as IMPLEMENTED switches off at 8.5% of the ceiling: a bare cell in a bare neighbourhood gains nothing at all, for ever, and can only be healed from outside. That is an absorbing state and a bistable board, and nobody chose it. **This is the fifth entry of the shape 'a mechanism described one way and implemented another'** after C.6, B.7, B.8 and world 13's flat fee, and the first where the discrepancy is arithmetic rather than structural. **It may be right**: real recolonisation does have thresholds, in propagule pressure and Allee effects, and a smooth rule that never quite reaches zero is the less physical of the two. It is open because it must be adopted deliberately or removed, not because it is wrong. **MEASURED AND IT IS NOT WHAT IS BINDING TODAY**: the share of the board gaining exactly nothing is 1% and 4% on the two live islands that show the strongest spatial structure, so slow recovery against mobile grazing is doing the work and this threshold is not. See [RESULTS_LUMPS.md](RESULTS_LUMPS.md). |
| A.4 | Energy arrives everywhere at once, with no day, season or weather | **OPEN, and the ground floor sweep now points here specifically.** Temporal variation in supply is the one thing dispersal theory says most reliably drives movement, and this world has none: every tick is identical. **A.5 established that no constant removes the sessile attractor**, because the population re-equilibrates against whatever value it is given: graze the stock down until sitting still is worth exactly what it costs, and re-size the body to suit. What a population cannot equilibrate against is variation in TIME. A creature at break-even on one cell dies in the first bad spell; one that can go where the ground is currently good does not. See [RESULTS_GROUND_FLOOR.md](RESULTS_GROUND_FLOOR.md) and **G.3**, which is this entry read from the other side. |
| A.5 | **The seed rate is a floor a stripped cell gets for nothing**, and it was set in world 4 by asking whether a creature that sits still and does nothing could fund a child on it | **CORRECTED**, world 14, after being tested first and the obvious reading refuted. `ground_seed` is deleted and the floor is a share of the mean stock of the NEIGHBOURING cells at a swept `recolonise_pct`, control 3, which on a full board is the 12 those worlds used. **All four pre-registered findings landed, which had not happened here before**: `ground_spread` 22-25 to **33 at the same nominal floor** and 43 to 58 across the sweep, **zero sessile survivors at every rate from 1 to 6** against 7-of-8 under world 13, sensors per creature 0.12 to **1.50** with the price PINNED, and `still_pct` 99-100 to **13**. **The lawn is gone.** The price is survival: 22 of 24 seeds dead at the control against 16, and rate 0 kills all 24. Raising the rate rebuilds the lawn and buys back survival monotonically, so **this world is either harsh and seeing or generous and sightless**. See [RESULTS_WORLD14.md](RESULTS_WORLD14.md). **The magnitude reading was tested first and was WRONG**, which is what made the shape argument worth acting on: [RESULTS_GROUND_FLOOR.md](RESULTS_GROUND_FLOOR.md) swept the old constant 0 to 48 and the sessile lineage merely re-sized, 43 to 495, while grazing held the stock near 200 at four different floors. Formerly: **DOWNGRADED: this constant does not matter, and the reason it does not is worth more than the entry was.** Swept 0 to 48 over 24 seeds at a pinned sensor price, see [RESULTS_GROUND_FLOOR.md](RESULTS_GROUND_FLOOR.md). The sessile, sightless regime survives a floor of **3**, a quarter of the upkeep it was supposed to be paying, because **the lineage re-sizes**: sessile body runs 43, 42, 46, 65, 87, 320, 495 as the floor rises 3 to 48. A creature that stays put earns one cell's yield and pays `metabolism + structure/33`, so there is always a body small enough to balance, and at a floor of 3 the lineage has quietly moved from living on the subsidy to living on 6% compounding without changing anything it does. **And grazing sets the stock**: standing stock sits near 200 at four different floors, driven there by the population until the marginal grazer breaks even. So this is a density equilibrium and **no value of this constant removes the strategy** — the population re-equilibrates against whatever you set. The register declined to act twice and was right, for a better reason than it gave. What the sweep DID establish, with the price of a sensor held fixed throughout, is that **perception belongs to a way of life**: sessile worlds carry 0.00 sensors at every floor from 3 to 18, mobile worlds carry 0.96 to 3.04 at every floor, and the mix does not shift. A floor of **0** kills all 24 seeds, as world 3's comment predicts. Formerly: **the criterion that set it has gone stale.** That creature paid only metabolism in world 4. Since world 5 it also pays upkeep on the frame it was founded with and cannot shed, so the criterion now asks for a seed of 24 against the 12 configured, and `scripts/verify_ground.escript` reports DISAGREES. **Not acted on, twice deliberately.** The reachability the criterion exists to establish is the yield line, which passes: a prudent stayer nets 22 against a cost of 10. What fails is a lineage that strips its cell and then sits on the bare floor, and **world 3 made that fatal on purpose**. Raising the seed to rescue it would undo world 3. It went unseen through two worlds because the script had an unbound variable and would not compile, which is the more useful lesson: **a verification that cannot run is worse than none, because it is still cited.** |

## B. What energy costs to hold

| # | The simplification | Status |
|---|---|---|
| B.1 | **Metabolism is flat regardless of how much a creature holds.** One carrying 10,000 pays exactly what one carrying 10 pays | **CORRECTED**, world 5, **and the correction was LINEAR, which is harsher than anything nature does.** Kleiber's three-quarter exponent is empirical, contested against two-thirds, and shows curvature rather than being constant, so it is a robust regularity and not a law. But every candidate exponent is SUBLINEAR: cost per unit mass falls as size rises. Linear holds it constant, so large size was taxed more heavily here than in any real organism. See B.5 for the deeper error. Priced the free good and size became hard-bounded, largest creature 66-99 against a founding 800. **It also UNDID world 4's positive**: the landscape flattened from a spread of 26-86 back to 9-10, and energy from creatures fell to zero in every seed. Creatures can no longer store, so they no longer differ, so contests move nothing and no place becomes different from another. **Some variance was living on that free good.** Kleiber's law says otherwise for every organism ever measured. The consequence is that **size is a free good**, which is why grabbing fast beat prudence in world 4: energy is armour with no upkeep, so there is never a reason not to hoard. |
| B.2 | Sensor rent rises with the radius of reach, not the area covered | **CORRECTED**, world 13, though not in the way this entry expected. The shape survives — a sensor weighs its reach plus itself — and what changed is that it is no longer a RENT at all. An organ is tissue and is charged by `carrying/2` like every other gram. The entry's own worry was that a wrong shape would price reach out before selection saw it; the flat fee did that regardless of shape. |
| B.3 | A hidden node costs a flat rent regardless of how many inputs it reads | **CORRECTED**, world 13, and it was the cause of twelve worlds of nulls. A flat fee among rates is the same defect as a law applied at one site: a cell yields about 22 a tick and one node cost 10 of it, so a creature with one eye and one thought could not pay for the ground it stood on. **Perception was never useless, it was unaffordable.** Priced as tissue and swept, sensors go from 0.00 to 3.27 per creature and hidden nodes from 0.01 to 2.68 as the price falls, with total reach from 12 to 2,506 and extinctions from 3 seeds in 5 to none. What physics does not settle is how much dearer neural tissue is, so `neural_cost` is swept and every value published; 330 is the control and reproduces worlds 2 to 12 exactly. **It settles the null and not the usefulness**: a nearly free organ drifts, which this register has warned about since world 4. See [RESULTS_WORLD13.md](RESULTS_WORLD13.md). |
| B.4 | Senescence is a fixed age, unrelated to how hard a creature has lived | **OPEN.** Ageing is energetic in real organisms; here it is a counter. |
| B.5 | **Energy conflates a STORE with a STRUCTURE.** One number is a creature's fat reserve, its body, its weapon in a contest and its reproductive capital, all at once | **CORRECTED**, world 6. These have opposite physics: an inert store costs almost nothing to hold, which is what fat is FOR, while working tissue is expensive to run. World 5 priced the conflated quantity and so taxed reserves as though they were tissue. **The result was first written up as two settled sizes and that claim is WITHDRAWN**: frames are bimodal in all five seeds, but mean age per bucket climbs 1 to ~400, so the large are the old. What survives is a measured adult and juvenile structure ~200x apart in lifespan, which a constant hazard cannot produce, and whose cause is not established because no earlier world measured age. It did NOT restore world 4's landscape variance (`ground_spread` 11-13 against 26-86) and did not make predation pay. See [RESULTS_WORLD6.md](RESULTS_WORLD6.md). |

| B.6 | **A body was OPTIONAL.** Frame won contests and cost upkeep, and that was the whole of it: nothing a creature could do depended on having one | **CORRECTED**, world 8. Capacity became a property of structure, `absorbed = min(uptake, frame, cell)`, which is a comparison between two quantities the world already tracked rather than a new constant. **Ghosts became impossible**: largest frame alive runs 400 to 560 at every one of the eleven efficiencies, where world 7 had it at zero from 70% down. It also **ended every seed**, and not for want of energy. See [RESULTS_WORLD8.md](RESULTS_WORLD8.md) and G.1. |

| B.7 | **Capacity bounds grazing and not predation.** World 8 said a creature cannot take in more than its frame and applied it at one of the two sites where energy enters a creature | **CORRECTED**, world 10. Energy from creatures fell 31% to 21%, the largest store halved from 23,446 to 12,555, and **predation survived being priced**, which is the strongest result: D.2 stays off zero. The landscape got SMOOTHER, 86 to 60, against the prediction that carrion would roughen it — the jackpot was what had been making it rough, so life was differentiating the ground by HOARDING and not by dying. It did NOT touch G.1: all nine surviving seeds are still at one founding line of forty. Two ways of feeding are not two niches. See [RESULTS_WORLD10.md](RESULTS_WORLD10.md). Formerly: `absorb/2` bounds grazing by `min(uptake, frame, cell)`. `take_them/3` bounds predation by nothing at all: it sums the whole of every weaker creature in the cell and hands all of it over in one tick, so a creature that can sip 400 a tick from the ground can swallow unlimited victims of unlimited size in the same tick. The live fleet takes 41% of its energy that way. **Nobody wrote this rule** and it is invisible in either function alone, because it lives in the DIFFERENCE between two code paths, which is exactly where C.6 hid for five worlds. The correction costs no constant, and conservation then forces carrion: what a predator cannot hold has to go somewhere, and the only place is the ground. |

| B.8 | **Capacity is per SOURCE, not per creature**, and only the winner of a cell ate at all | **CORRECTED**, world 11. Two defects in one function, both invisible inside it: anything that tied with the strongest survived the contest and then did not feed, and the winner took a body's worth of meat AND a body's worth of ground in the same tick. **The tie case turned out to be almost irrelevant** (at 800 creatures on 1,261 cells most cells hold one or none) and the double helping was the whole of it: seeds surviving 20,000 ticks fell from 9 of 12 to 5, while `from_creatures_pct` did not move at all. **Predators were living on the bug** — the correction changed what predation is worth, not how much of it happens. Every positive prediction failed and the pre-registered risk landed. See [RESULTS_WORLD11.md](RESULTS_WORLD11.md). Formerly: The stated law is that a creature cannot take in more than its frame; what is implemented is that it cannot take more than its frame FROM ANY ONE SOURCE, which nobody wrote. **World 10 made it worse**: the carrion a predator cannot finish is buried on its own cell inside `devour`, and `absorb` runs immediately afterwards on that same cell, so a predator grazes its own spillage a second time in the same tick. Introduced by the world 10 correction and not foreseen in its pre-registration. Correcting it is a deletion and costs no constant. See [AUDIT_ENERGY_PATHS.md](AUDIT_ENERGY_PATHS.md). |
| B.9 | **The body is infinitely plastic.** `invest` converts the whole store into frame in one tick and `eat_own_frame` converts the whole frame back, both bounded by the amount rather than by any rate | **OPEN.** Matter enters a creature at a bounded rate and moves between its two compartments at an unbounded one. Nothing here grows or shrinks over time, where real growth is rate-limited because assembly needs time and surfaces (von Bertalanffy). **It matters because contests are decided on structure**: size is a switch rather than an investment, with no lag between deciding to be large and being large, which neutralises any tradeoff between carrying energy where it is mobile and edible and building it where it is safe. Unlike B.8 this is a new rule rather than a deletion, so it costs a constant and does not go first. |

## C. What energy costs to act

| # | The simplification | Status |
|---|---|---|
| C.1 | Movement costs the same whatever a creature weighs | **CORRECTED**, world 12, together with C.2 because neither works alone: unbounded steps at a flat fare would be a free good handed to the large. The fare is `move_cost + carrying(structure)`, reusing the expression that already prices holding a frame, so no second constant decides how heavy legs are. **It capped bodies at a tenth of what they had reached** (largest frame 3,831 to 450) where five worlds of pricing the HOLD had not. |
| C.2 | Everything moves exactly one cell per tick | **CORRECTED**, world 12. A creature now goes as far as it can pay to go, so flight exists for the first time. **The thing it was supposed to unlock did not happen**: perception is still at 0.10 sensors per creature. The most likely reason, and it was not pre-registered, is that a creature cannot flee what it cannot afford to SEE, and this change made movement dearer at exactly the moment sight became useful. Population rose 60%, generational turnover five-fold, and the seeds split into alternative stable states — many small creatures, or a world of few enormous ones. See [RESULTS_WORLD12.md](RESULTS_WORLD12.md). |
| C.3 | Reproduction costs only the dowry: no gestation, no gamete production | **OPEN, and worlds 6 AND 7 now say it is the one that matters.** World 7 priced every transformation and lifespan did not rise, so the churn is not caused by transfers being free. Mean lifespan is 2.2 ticks and 2,264 of 2,318 creatures can breed, so breeding every tick is the dominant move and the population is held permanently above what the ground can feed. **No apparatus can amortise over two ticks**, which is the constraint underneath every null in this register. Subsumed by D.3, which prices it as one case of a general law rather than as a special rule for reproduction. |
| C.4 | Offspring are placed at a fixed distance by a fixed rule | **OPEN.** Dispersal is not heritable, so kin competition, which theory says drives movement in exactly this world's conditions, has nothing to act on. |
| C.5 | The dowry is exactly half, and not heritable | **OPEN, and world 8 makes it the most damaging entry in this register.** Half is not required by physics. Conservation requires the child's material to come from the parent and the Second Law requires the assembly to dissipate; neither says anything about the amount, exactly as with the efficiency in D.3. `div 2` is a chosen constant wearing the costume of a symmetry, and had it been written `div 7` it would have been questioned two worlds ago. **It is also multiplicative and lossy**, so `child frame = parent frame × efficiency / 200`, which is geometric decay per generation. Measured deepest generation ever alive: **7 at 100%, 4 at 70%, 1 at 30%**, against 5, 3 and 2 predicted from that ratio before the run. This is the mechanism behind D.3's frame collapse and behind world 8 ending sterile. Theory says the amount is a life-history trait and not a constant at all: under Smith and Fretwell (1974) per-offspring investment is set by how survival scales with size and the NUMBER is what floats, and this world fixes the number at one and floats the investment at 50%, which is backwards. |
| C.7 | **Reproduction is paid by dismembering the parent's own body.** Half the frame goes to the child, alongside half the store | **CORRECTED**, world 9, and it is the largest single result in this register. The engine restarted: 54 to 129 generations of descent alive at 2000 ticks against world 8's best of 15 ever reached, births still happening at the run limit, 3 seeds of 5 surviving where world 8 lost every seed at every efficiency. It also **brought back world 4's landscape** (`ground_spread` 86 against 9 to 30 since world 5) and **produced the first predation living in this register** (D.2). It does nothing below 90%, where the lossy dowry delivers a child too small to feed itself. See [RESULTS_WORLD9.md](RESULTS_WORLD9.md). Formerly: Never justified: the code says both halves split alike "because structure is energy in another form", which is true and does not make taking it obligatory. Real organisms provision offspring from reserve, which is what a reproductive buffer is in Kooijman's Dynamic Energy Budget theory, and resorbing working tissue to breed happens once at the end of a life rather than every tick. Harmless until world 8 made the frame the cap on feeding; from then on it halves the organ that pays for everything, geometrically and per generation. See C.5 for the arithmetic and [RESULTS_WORLD8.md](RESULTS_WORLD8.md) for what it cost. |
| C.6 | **The movement fare was the one cost that could not be paid from your own body** | **CORRECTED**, world 7, and it was never in this register because nobody knew it was a rule. Every other cost could be covered by catabolising a frame; the fare pushed the store negative and a negative store was death, so moving when you could not afford it was fatal however much body was left to burn. **It held perception at zero for five worlds.** Removing it, which conservation forced, took sensors from 0.01 to 2.52 per creature and hidden nodes from 0.01 to 1.80 at an efficiency where nothing is lossy. **The lesson is the entry: a bookkeeping error can be a physical rule in disguise, and only exact conservation finds it.** |

| C.8 | **Building costs no WORK, only a transformation loss, and at the control efficiency that loss is zero** | **OPEN, and it is a free good hiding behind a law.** `built(Amount, Eff) = Amount * Eff * Eff / 10000`, so at 100% a thousand units of store become a thousand units of frame and nothing is dissipated. The squaring makes building harsher than other transformations at every OTHER efficiency, which is why it looked priced. Biosynthesis has an overhead that is not a transfer loss: energy spent making the tissue that does not end up in it, empirically 20-40% and a named coefficient in Kooijman's DEB. Every other act here carries a CHARGE that is paid regardless of efficiency (metabolism, the movement fare, sensor and hidden rent, carrying). Building and eating are the only two acts with no charge at all, and eating with no charge is D.2. **With B.9 this compounds**: at 100% the store and the frame are freely, instantly and reversibly interconvertible, so world 6's separation of the two is undone at exactly the setting the fleet runs. |

## D. How energy transfers

| # | The simplification | Status |
|---|---|---|
| D.1 | A creature absorbed everything in its cell instantly | **CORRECTED**, world 4. Feeding is rate-limited and heritable. Produced the first positive: the landscape differentiates, `ground_spread` 26-86 against 9 before. |
| D.2 | **PRICES A FREE GOOD: eating. Consumption is unconditional and free.** The largest creature in a cell eats every smaller one, always, with no cost and no decision | **OPEN, partly self-inflicted, and the RIGHT FORM is now known.** World 1 had a cost and a decision; removing the named verb `hunt` was right and making consumption unconditional in the same change was never justified. So every creature is an obligate predator on every smaller creature it meets, which is why **97% of all deaths are being eaten** — an artifact rather than a finding. Real plants do not consume their neighbours, and not because they are a different TYPE, which was correctly abolished, but because **a tree has no mouth**. So the correction is not "make eating cost" but **make eating require an apparatus that costs rent**, exactly like a sensor. A creature that has not invested cannot consume another however large it is, and lives on ground alone. **That is a herbivore as a tradeoff rather than a type.** **UPDATED by world 9: the "worthless" half is no longer true.** `from_creatures_pct` runs 18 to 33 and 5 to 31 individuals draw more from creatures than from ground, both zero in every world since 4. Checked against the alternative reading and it is **not infanticide**: mean age of the eaten is 1.5 to 7.7 ticks against a mean lifespan of 2.1 to 7.9, so the prey tracks the population's own age distribution rather than being newborns. The cause is that world 9 creates a standing spread of sizes for the first time, since parents keep their frames and grow while children start small. **Eating still costs nothing and requires no apparatus, so this remains OPEN**: a living now exists where none did, and it is still available to everything for free. **World 10 priced the CAPACITY and not the apparatus** (B.7), which halved the return without removing the living: 21% and 12 individuals, so the niche is real enough to survive being taxed. Pricing an apparatus is now a meaningful experiment rather than a tax on something nobody uses, which is what it would have been in any world before 9. |
| D.3 | **EVERY ENERGY TRANSFORMATION IN THIS WORLD IS 100% EFFICIENT.** Not one simplification but ONE LAW BROKEN AT SIX SITES | **CORRECTED**, world 7, swept from 100% to 10% rather than chosen. It **differentiated the landscape**, `ground_spread` 13 to 30 against a flat 10, which is the Prigogine prediction and the only thing pre-registered from theory that landed. It **destroyed structure**, frames going from 102 to 0. **AMENDED by world 8, and this reading is withdrawn.** Two explanations were offered here, the Second Law or integer truncation, and world 8's pre-registration named a third, the ghost bug. It is none of the three: the frame collapse is C.5 compounding, at a ratio of `efficiency / 200` per generation, so below 70% two generations strip a lineage of its body. This entry may not be quoted for the collapse. It **shortened lives** rather than lengthening them, which was the direct target and failed in the opposite direction. Predation did not move. The world survives to 20% efficiency, against a prediction that it would die across most of the range. See [RESULTS_WORLD7.md](RESULTS_WORLD7.md). |
| D.4 | Absorption from the ground is likewise perfectly efficient | **SUBSUMED BY D.3.** Kept as the record of when it was noticed separately, before it was clear that the same law was broken at every site rather than at two of them. |
| D.5 | **One efficiency fits all six transformations** | **OPEN, and created by the fix for D.3.** Real efficiencies differ widely by process: assimilation runs about 20-50% in herbivores against about 80% in carnivores, and production efficiency varies more still. Six values would be six undefended parameters, so one is the honest first correction and differentiating them needs a reason rather than a preference. |

| D.6 | **A contest tie is broken by id, so the same creature always wins it** | **OPEN.** `resolve` sorts `{structure, id}` and reverses, so among equal structures the HIGHER id takes the cell, which is the later-born. Every other decision with a tie in it draws: `pick_best` threads the rng for movement. This one does not, so identical creatures do not get a coin flip, they get a rule, and the rule systematically favours the younger. Small, and it is exactly the class of thing this register exists to catch: an asymmetry nobody wrote. |

## E. Where energy goes

| # | The simplification | Status |
|---|---|---|
| E.1 | A creature that died simply ceased, and its energy was deleted | **CORRECTED**, world 2. Death returns everything to the cell it died on, which closed the books and made them checkable to the unit for the first time. |
| E.2 | A corpse is available instantly and entire; there is no decay | **OPEN.** |
| E.3 | Metabolism is the only true sink | **Probably correct.** Work leaves as heat; everything else circulates. |

## F. Perception

| # | The simplification | Status |
|---|---|---|
| F.1 | A sensor reads an exact sum with no noise, no error and no delay | **OPEN.** |
| F.2 | Readings were divided by one shared constant regardless of magnitude | **CORRECTED**, world 2. Natural units per field. |

## G. Whether the world can still change

**This section exists because world 8 ended rich, and every entry above it is
about energy.** Eight worlds of exact energy accounting could not have found what
killed world 8, because none of them measured whether the population could still
become anything else. Fisher prices adaptation in the variance available to
select on. No variance, no adaptation, and no correction anywhere else in this
register can substitute for it.

| # | The simplification | Status |
|---|---|---|
| G.1 | **Variance enters this world through exactly one operator, birth**, so selection against reproduction is selection against the variance source itself | **OPEN, and it is what ended world 8.** Trait mutation, brain mutation and body mutation all ride on reproduction. When breeding became self-harm the world kept the founders that refuse, and after that nothing new could be produced at any price. The last birth falls between ticks 5 and 35, so **94 to 99 percent of every run happens with the engine already off.** Measured by `lineages`, `depth` and the uptake spread, which are observables and which no rule reads. The design already names one variance source that does not require local birth, **invasion between islands**, and every world from 1 to 9 has been a single island without it. **World 9 restarted the engine at high efficiency** and did not change its structure: birth is still the only operator that produces variance, so the same failure remains available whenever breeding is punished. **Below 90% the engine is still dead**, deepest generation 0 or 1 as in world 8. **And the drain did not stop, it slowed**: `scripts/seed_survival.escript` ran twelve seeds to 20,000 ticks and **all nine survivors were down to ONE founding line out of forty**, at depths of 276 to 488 generations. A world 9 island is a monoculture within a few hours. Lineages are lost and cannot be regained, because nothing here recombines and nothing arrives from outside, so this entry stays OPEN however well reproduction works. The same survey found that **every extinction is early** (601, 630, 725, and nothing between 725 and 20,000), so an island fails in its founding phase or not at all. **World 10 tested a second food source against this and it did nothing**: carrion is a real second route to a meal, and all nine survivors are still at ONE founding line. Whatever holds more than one lineage is not another way to eat. **AMENDED: the collapse itself is the null expectation and this entry read as though it were a fault.** All lineages in a finite asexual population coalesce to one ancestor eventually (Kingman 1982), in of order N generations under drift alone. At populations of 700 to 900 that is around 800 generations and ours arrive by 264 to 488, which is faster than drift and is the signature of selective sweeps: with no recombination, a good mutation carries its whole genome to fixation. So the question this entry poses is not why the lines collapse but **what could ever hold more than one**, and theory gives a short list: recombination, spatial structure, frequency dependence, or variation in time. World 10 ruled out "another way to eat" empirically. **A founding is ANCESTRY AND NOT A KIND**, and nothing here should be read as a count of species: the tag is inherited unchanged, can never split, and two creatures inside one line diverge past two lines within a few hundred generations. |
| G.2 | **A strategy of never reproducing is survivable here**, because `max_age` is 600 against a generation time of about 2 | **OPEN.** Fitness zero is removed in one generation in nature and persists for six hundred ticks here, so a census counts individuals whose lineages are already extinct. Individual persistence outruns lineage persistence by roughly two orders of magnitude. See B.4: senescence as a counter is what sets the 600. |
| G.3 | **The world is perfectly constant.** No day, no season, no weather, no disturbance | **OPEN, and it is A.4 read from the other side.** A constant environment has a point optimum, and a point optimum is the opposite of diversity. This is also what makes bet-hedging unpayable (Cohen 1966, Slatkin 1974) and the storage effect inoperable (Chesson 2000). |
| G.5 | **Every source of chance in this world is genetic. There is no environmental stochasticity at all** | **OPEN, and Raf named it.** Every `rand:uniform_s` call lives in `body.erl`, `brain.erl`, founding placement or offspring placement: mutation and where things start. After that the world is exact. The ground grows by a deterministic rule, sensors read exact sums with no noise (F.1), nothing dies at random, and a contest is decided by size (D.6). **So selection is a fixed function of phenotype and the best phenotype sweeps**, which is a large part of why lineages collapse to one (G.1) and cannot be blamed on asexuality alone. Fluctuating selection is one of the four things theory says maintains diversity and this world has none of it, which makes A.4 and G.3 more load-bearing than they looked. **Reproducibility is NOT the same claim** and is not in question: a world is a pure function of its seed by construction, which is what makes a pre-registered criterion mean anything, and it is compatible with any amount of noise inside the world. |
| G.4 | **Almost nothing here is frequency dependent**: being common costs nothing and being rare buys nothing | **CORRECTED**, world 14, **and it did not buy coexistence.** Being common now costs: a dense sessile population grazes its own neighbourhood flat and a flat neighbourhood supplies no floor, so the lawn destroys its own subsidy. Sessile survivors went to ZERO at every rate from 1 to 6 where world 13 had 7 in 8. **But `lines` is 1 at every value in the sweep.** Chesson's distinction lands exactly where this entry said it would: a stabilising mechanism arrived, acted on a strategy, and produced ONE strategy rather than two. Frequency dependence is necessary and is not sufficient. See [RESULTS_WORLD14.md](RESULTS_WORLD14.md). Formerly: **OPEN.** Chesson's distinction is the relevant one: tradeoffs are *equalising*, they shrink fitness differences and slow exclusion. Coexistence needs something *stabilising*, where rare does better than common. Contests are decided by size, so commonness is neutral. With one limiting resource, the exclusion principle predicts one strategy however many tradeoffs are added. |

---

## Not simplifications

Things sometimes mistaken for physics gaps that are constraints or conventions,
and are not on the list to be corrected:

- The hex grid, and a disc rather than a rectangle. A choice of coordinates.
- Integer arithmetic and a rectified activation. Chosen to keep a run
  bit-identical from its seed, which is what makes the whole world probeable
  offline in seconds.
- Simultaneous movement with no turn order. Removes an artefact rather than
  adding one.
- Safety valves (`max_creatures`, `max_sensors`, `max_hidden`,
  `max_sensor_range`). Guards against a mistuned run allocating without bound,
  counted and reported whenever one binds.

## What this register is for

When a world is proposed, it should name the entry it corrects. When a world is
finished, its entry gets its result written here whatever that result is,
including **no effect**, which three of the five corrections so far have had.

**A correction that changes nothing is not a failure.** It removes a
simplification from the list of things that could have been responsible, which is
the only way a map of this kind ever gets built.

And when a world is proposed, it should say **which free good it prices, and
which tradeoff that leaves live**. A correction that leaves everything adjacent
free will be overridden the way world 4's was, however physical it is.

**A correction can also destroy the variance a later experiment needs.** World 5
priced size and drove energy from creatures to zero in every seed, which made
entry D.2 **untestable**: the benefit side of a predation apparatus was nothing,
so it would be selected out whatever it cost. So the queue is not fixed once and
for all: an entry can be blocked by an earlier correction, and B.5 preceded D.2
for that reason. **World 6 unblocked it**, which is the first time this register
has been used to schedule work and had the schedule pay off.

**But world 6 also moved the queue again.** D.2 is testable now and is still the
wrong next entry: 190,000 kills a run yield nothing because what gets eaten is
empty, and prey are empty because nothing can flee. **C.2, being still costs
nothing, now precedes D.2.** A predation apparatus with no escape to defeat is
an apparatus for a problem the world does not have.

**A verification that cannot run is worse than none, because it is still cited.**
`scripts/verify_ground.escript` had an unbound variable and would not compile
for two whole worlds while its derivations continued to be quoted as though they
had been checked. See A.5.
