# The physics register

> ## ⚠ EVERY NUMBER MEASURED BEFORE 2026-08-02 IS HISTORICAL
>
> A world was not a pure function of its seed until that date, for all seventeen
> worlds. See **`G.6`**. The measurements below are what was observed; they
> **cannot be reproduced**, because the physics that produced them depended on
> what the VM had loaded as well as on the seed.
>
> **They are not withdrawn.** The effects they report are large and the
> ordering fault perturbs a trajectory rather than biasing it in a direction, so
> the CONCLUSIONS are expected to stand. What cannot be relied on is any exact
> figure: a tick of death, a population, a percentage.
>
> **Deliberately not re-run.** Re-deriving sixteen worlds costs more than it buys
> when no conclusion is in doubt. Anything that DOES come to depend on an exact
> old figure must be re-measured before it is leaned on, and said so at the time.
>
> Everything from world 17 onward is reproducible and is checked by the
> `cross-vm` column of `scripts/same_seed_same_world.escript`.

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
| A.6 | **Every cost in this world is a staircase**, and any trait whose mutation step falls between the treads cannot be selected | **OPEN. PROMOTED, THEN THE PROMOTION WAS OVER-CLAIMED, AND THIS IS THE CORRECTION.** Filed as a curiosity about the ground and it is not about the ground: upkeep is `(structure + mouth + apparatus) div 33` and the drift step is 8, so **at a FIXED body size three mutations in four change the bill by nothing** and a creature carrying a mouth of 27 pays what one carrying none pays. That arithmetic is correct and I drew a conclusion from it that does not follow. **A REAL BODY IS NOT FIXED.** It grows and shrinks across a range far wider than the divisor, so the truncation averages out: over a body drifting across 300 to 500, the truncated lifetime bill runs 11.64, 11.88 and 12.44 units a tick for mouths of 0, 8 and 27. **The gradient survives truncation.** And the test written to prove otherwise passes whether the fraction is carried or discarded, which is the honest red check failing. So **truncation was NOT shown to be what stopped world 15's mouth being selected**, and that explanation is withdrawn until something measures it. The fix is kept because carrying the fraction is strictly more correct and costs nothing; it is not kept because it was shown to matter. See [RESULTS_WORLD15.md](RESULTS_WORLD15.md). Formerly: **it now blocks.** Upkeep is `(structure + mouth + apparatus) div 33` and the drift step for a heritable integer is 8, so **75% of mouth mutations cost exactly nothing** and a creature carrying a mouth of 27 pays what one carrying none pays. World 15 built a costly organ, ran 48 seeds to 20,000 ticks, and all four of its findings failed for this reason alone: the observed spread of mouths, 9 to 329 about a founding 200, is what a random walk of plus or minus 8 over 500 generations predicts with no selection at all. **`uptake` has the same step and the same divisor**, and world 4 recorded that it drifted and never converged and reasoned about gradients in the resource; this is a second and simpler explanation that was available the whole time. **Nothing further should be built on a heritable integer until this is decided.** See [RESULTS_WORLD15.md](RESULTS_WORLD15.md). Formerly, and still true: **found by looking at a picture.** World 14's floor is `mean(neighbours) * recolonise_pct div 100`, which at the control of 3 is **exactly zero for any neighbourhood averaging under 34** of a ceiling of 400, and the compounding term `E * 6 div 100` is **exactly zero under a stock of 17**. So the rule as STATED decays smoothly toward nothing and the rule as IMPLEMENTED switches off at 8.5% of the ceiling: a bare cell in a bare neighbourhood gains nothing at all, for ever, and can only be healed from outside. That is an absorbing state and a bistable board, and nobody chose it. **This is the fifth entry of the shape 'a mechanism described one way and implemented another'** after C.6, B.7, B.8 and world 13's flat fee, and the first where the discrepancy is arithmetic rather than structural. **It may be right**: real recolonisation does have thresholds, in propagule pressure and Allee effects, and a smooth rule that never quite reaches zero is the less physical of the two. It is open because it must be adopted deliberately or removed, not because it is wrong. **MEASURED AND IT IS NOT WHAT IS BINDING TODAY**: the share of the board gaining exactly nothing is 1% and 4% on the two live islands that show the strongest spatial structure, so slow recovery against mobile grazing is doing the work and this threshold is not. See [RESULTS_LUMPS.md](RESULTS_LUMPS.md). |
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
| D.2 | **PRICES A FREE GOOD: eating. Consumption is unconditional and free.** The largest creature in a cell eats every smaller one, always, with no cost and no decision | **OPEN, partly self-inflicted, and the RIGHT FORM is now known.** World 1 had a cost and a decision; removing the named verb `hunt` was right and making consumption unconditional in the same change was never justified. So every creature is an obligate predator on every smaller creature it meets, which is why **97% of all deaths are being eaten** — an artifact rather than a finding. Real plants do not consume their neighbours, and not because they are a different TYPE, which was correctly abolished, but because **a tree has no mouth**. So the correction is not "make eating cost" but **make eating require an apparatus that costs rent**, exactly like a sensor. A creature that has not invested cannot consume another however large it is, and lives on ground alone. **CORRECTED, world 15, in mechanism though not in consequence: see H.1.** AND IT IS NOT A HERBIVORE, which is what this entry used to say, NOR A CARNIVORE, which is what the measurement was first called: this world has no types, only investments, and naming one in a snapshot field is the same error as world 1's `hunt` verb. Raf caught both. There are no plants: world 2 deleted them, so what a mouthless creature does is take up energy that has gathered in the substrate, which is osmotrophy — a microbe, a fungus, a root — and not grazing. **This world has exactly two trophic levels available and no more**, absorb from the ground or consume another creature, because there is nothing to graze that is not alive. That is why `from_creatures_pct` sits between 4 and 21 and never climbs: there is only one rung up. **So every creature currently occupies BOTH levels at once for free**, and splitting them is what would create the first genuine niche here. Raf caught the wrong word 2026-08-02. **UPDATED by world 9: the "worthless" half is no longer true.** `from_creatures_pct` runs 18 to 33 and 5 to 31 individuals draw more from creatures than from ground, both zero in every world since 4. Checked against the alternative reading and it is **not infanticide**: mean age of the eaten is 1.5 to 7.7 ticks against a mean lifespan of 2.1 to 7.9, so the prey tracks the population's own age distribution rather than being newborns. The cause is that world 9 creates a standing spread of sizes for the first time, since parents keep their frames and grow while children start small. **Eating still costs nothing and requires no apparatus, so this remains OPEN**: a living now exists where none did, and it is still available to everything for free. **World 10 priced the CAPACITY and not the apparatus** (B.7), which halved the return without removing the living: 21% and 12 individuals, so the niche is real enough to survive being taxed. Pricing an apparatus is now a meaningful experiment rather than a tax on something nobody uses, which is what it would have been in any world before 9. |
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
| F.3 | **A reading was a TOTAL, so one unit could not serve every reach** | **CORRECTED**, world 17, **and the world rejected the correction.** A spatial field now reports the MEAN over the cells in reach, so reach means how far you average rather than how much you add up, and `sense_scale` sets how many steps of the range a full cell spans. Swept over **96 seeds** and 20,000 ticks, **deaths rise monotonically with resolution**: 80, 87, 89, 91, 94, 94, 93 as the scale goes 1, 2, 4, 8, 16, 32, 63. So the viability criterion selects **1, the blindest setting on the sweep**, at which a reach-0 ground sensor reads zero 87 to 100% of the time against 88 to 100% under world 16. **At reach 0, which is what the fleet carries, a mean over one cell IS a sum over one cell, so for the sensors that exist this world is arithmetically world 16.** Perception did not rise (2.19 per creature against a target of 6.49) and hidden nodes did not move (0.00 to 0.08). The mechanism is confirmed and its price is survival. See [RESULTS_WORLD17.md](RESULTS_WORLD17.md). |
| F.4 | **Whether a resolving sense is FATAL rather than merely useless** | **REFUTED as stated**, 2026-08-02, by `scripts/why_resolution_kills.escript`, 48 seeds, state read at a fixed early tick across every seed including the doomed. The mechanism proposed was overgrazing: a sense that resolves the ground lets creatures find and strip the best cells, the population grazes its neighbourhood flat, loses world 14's neighbour subsidy and starves. **It predicts the standing ground stock FALLS as resolution rises. It RISES**, 468k to 486k at tick 100 and 457k to 492k at tick 500, monotonically, in the wrong direction. **And nothing else moves either**: starvation is 91 to 92% of deaths at every scale, movement is 80 to 84% at every scale, and the population at tick 100 is 10 to 13 at every scale. The death gradient is real, 40 of 48 seeds at scale 1 against 48 of 48 at scale 63, and **none of the obvious observables distinguishes the worlds that produce it.** Creatures at high resolution starve in the middle of MORE food than creatures at low resolution, which is the opposite of a foraging story. Whatever kills them is not visible in cause of death, movement, standing stock or early population, and finding it needs an instrument that watches individuals rather than totals. **The premise cost one script and one run**, which is the fourth time a mechanism has been proposed here before being measured and the fourth time the measurement disagreed. |

## G. Whether the world can still change

**This section exists because world 8 ended rich, and every entry above it is
about energy.** Eight worlds of exact energy accounting could not have found what
killed world 8, because none of them measured whether the population could still
become anything else. Fisher prices adaptation in the variance available to
select on. No variance, no adaptation, and no correction anywhere else in this
register can substitute for it.

| # | The simplification | Status |
|---|---|---|
| G.1 | **Variance enters this world through exactly one operator, birth**, so selection against reproduction is selection against the variance source itself | **OPEN, and it is what ended world 8.** Trait mutation, brain mutation and body mutation all ride on reproduction. When breeding became self-harm the world kept the founders that refuse, and after that nothing new could be produced at any price. The last birth falls between ticks 5 and 35, so **94 to 99 percent of every run happens with the engine already off.** Measured by `lineages`, `depth` and the uptake spread, which are observables and which no rule reads. The design already names one variance source that does not require local birth, **invasion between islands**, and every world from 1 to 9 has been a single island without it. **World 9 restarted the engine at high efficiency** and did not change its structure: birth is still the only operator that produces variance, so the same failure remains available whenever breeding is punished. **Below 90% the engine is still dead**, deepest generation 0 or 1 as in world 8. **And the drain did not stop, it slowed**: `scripts/seed_survival.escript` ran twelve seeds to 20,000 ticks and **all nine survivors were down to ONE founding line out of forty**, at depths of 276 to 488 generations. A world 9 island is a monoculture within a few hours. Lineages are lost and cannot be regained, because nothing here recombines and nothing arrives from outside, so this entry stays OPEN however well reproduction works. The same survey found that **every extinction is early** (601, 630, 725, and nothing between 725 and 20,000), so an island fails in its founding phase or not at all. **World 10 tested a second food source against this and it did nothing**: carrion is a real second route to a meal, and all nine survivors are still at ONE founding line. Whatever holds more than one lineage is not another way to eat. **AMENDED: the collapse itself is the null expectation and this entry read as though it were a fault.** All lineages in a finite asexual population coalesce to one ancestor eventually (Kingman 1982), in of order N generations under drift alone. At populations of 700 to 900 that is around 800 generations and ours arrive by 264 to 488, which is faster than drift and is the signature of selective sweeps: with no recombination, a good mutation carries its whole genome to fixation. So the question this entry poses is not why the lines collapse but **what could ever hold more than one**, and theory gives a short list: recombination, spatial structure, frequency dependence, or variation in time. World 10 ruled out "another way to eat" empirically. **AND `lineages` HAS BEEN ANSWERING THE WRONG QUESTION.** World 14's boards are structured, and measured on the two islands that show lumps the **F_ST is 65 and 61**: sixty-odd percent of the genetic variation sits BETWEEN lumps rather than inside them, with spread of 14 to 17 within a lump against 41 to 44 across the island and an unrelated baseline near 50. Wright called anything above 25 very great differentiation and human continental populations run 10 to 15. **These are one lineage and strongly structured at the same time**, which is not a contradiction: `lineages` counts founders with surviving descendants and can only fall, while F_ST measures how the variation that exists is apportioned in space. A monoculture can be strongly structured and this one is, so reading `lineages` of 1 as "the engine is dead" was wrong. Nobody installed this: local birth, a patchy board and lumps that persist a hundred generations is Hamilton's condition arriving out of two rules written for other reasons. It is the PRECONDITION for group selection and not evidence of it, which needs a trait whose effect on the group differs from its effect on the individual, and **the mouth would be the first** because a lump that collectively over-consumes destroys the patch it lives on. See [RESULTS_PHASE0.md](RESULTS_PHASE0.md). **A founding is ANCESTRY AND NOT A KIND**, and nothing here should be read as a count of species: the tag is inherited unchanged, can never split, and two creatures inside one line diverge past two lines within a few hundred generations. |
| G.2 | **A strategy of never reproducing is survivable here**, because `max_age` is 600 against a generation time of about 2 | **OPEN.** Fitness zero is removed in one generation in nature and persists for six hundred ticks here, so a census counts individuals whose lineages are already extinct. Individual persistence outruns lineage persistence by roughly two orders of magnitude. See B.4: senescence as a counter is what sets the 600. |
| G.3 | **The world is perfectly constant.** No day, no season, no weather, no disturbance | **OPEN, and it is A.4 read from the other side.** A constant environment has a point optimum, and a point optimum is the opposite of diversity. This is also what makes bet-hedging unpayable (Cohen 1966, Slatkin 1974) and the storage effect inoperable (Chesson 2000). |
| G.5 | **Every source of chance in this world is genetic. There is no environmental stochasticity at all** | **OPEN, and Raf named it.** Every `rand:uniform_s` call lives in `body.erl`, `brain.erl`, founding placement or offspring placement: mutation and where things start. After that the world is exact. The ground grows by a deterministic rule, sensors read exact sums with no noise (F.1), nothing dies at random, and a contest is decided by size (D.6). **So selection is a fixed function of phenotype and the best phenotype sweeps**, which is a large part of why lineages collapse to one (G.1) and cannot be blamed on asexuality alone. Fluctuating selection is one of the four things theory says maintains diversity and this world has none of it, which makes A.4 and G.3 more load-bearing than they looked. **Reproducibility is NOT the same claim** and is not in question: a world is a pure function of its seed by construction, which is what makes a pre-registered criterion mean anything, and it is compatible with any amount of noise inside the world. ⚠ **THAT LAST SENTENCE WAS FALSE WHEN WRITTEN AND IS CORRECTED IN `G.6`.** It was reasoned from the shape of the code, "every `rand` call threads its state, therefore pure", and the reasoning was sound about randomness and silent about ORDER. The rest of this entry stands. |
| G.6 | **A world was a pure function of its seed AND of what the VM had loaded**, which is not a pure function of its seed | **CORRECTED**, 2026-08-02, and it had been true for all seventeen worlds. `brain:nudge_all/3' drew a random number per weight while walking `maps:to_list' of a map keyed by purpose ATOMS, and `world:consume/1' resolved cells in `maps:values' order and fed each cell's occupants in `maps:fold' order. **None of those orders is promised by Erlang, and the order you get depends on VM-global state.** Measured: running `brain_tests` before the identical computation moved a world's energy at TICK ONE, 14,588 to 14,590, on the same seed with the same beams, verified by md5, and a byte-identical economy. By tick 100 it was the difference between a live creature and an empty world. **This is the discrepancy `scripts/same_seed_same_world.escript` was written to investigate and could not see**: seed 303 ended at 601 offline and at 630 on the fleet, and the script reported "repeatable: yes" because both of its columns compare runs INSIDE ONE VM, where the atom table is already fixed. A release and a script load modules in different orders, so **the fleet and the laboratory were running different physics.** Fixed by sorting both sites, which is what the other four phases of the tick already did. The script gains a **cross-vm** column that runs two operating-system processes with opposite module load order; verified red before the fix, where five of six seeds disagree. **The fix CHANGES RESULTS**, so every number measured before this date is a measurement of a world that cannot be reproduced: seed 101 moves from dying at 1,116 to dying at 820. |
| G.4 | **Almost nothing here is frequency dependent**: being common costs nothing and being rare buys nothing | **CORRECTED**, world 14, **and it did not buy coexistence.** Being common now costs: a dense sessile population grazes its own neighbourhood flat and a flat neighbourhood supplies no floor, so the lawn destroys its own subsidy. Sessile survivors went to ZERO at every rate from 1 to 6 where world 13 had 7 in 8. **But `lines` is 1 at every value in the sweep.** Chesson's distinction lands exactly where this entry said it would: a stabilising mechanism arrived, acted on a strategy, and produced ONE strategy rather than two. Frequency dependence is necessary and is not sufficient. See [RESULTS_WORLD14.md](RESULTS_WORLD14.md). Formerly: **OPEN.** Chesson's distinction is the relevant one: tradeoffs are *equalising*, they shrink fitness differences and slow exclusion. Coexistence needs something *stabilising*, where rare does better than common. Contests are decided by size, so commonness is neutral. With one limiting resource, the exclusion principle predicts one strategy however many tradeoffs are added. |

---

## H. What a creature can know and what it can do

**This section exists because eating went thirteen worlds without an actuator and
nobody noticed.** Every section above is organised around energy: where it
enters, what it costs to hold, to act, to transfer, where it goes. Perception got
its own section only because world 1 got the units wrong. **Agency never got
one**, so "what can a creature actually decide" had never been written down
anywhere, and a gap you have not enumerated is a gap you find by accident.

Raf's instruction, 2026-08-02: *think in terms of sensors and actuators, not "it
just happens"*.

There are four things a creature can sense and **three it can do**.
`-define(PURPOSES, [move, breed, grow])`. Everything else on this board happens
TO it.

| what happens to a creature | can it perceive it | can it **choose** it |
|---|---|---|
| moving | yes: `ground`, `creatures`, `scent`, `self` read at each candidate cell | **`move`** |
| reproducing | yes, `self` | **`breed`** |
| building structure | yes, `self` | **`grow`** |
| absorbing from the ground | yes, `ground` | **no.** `uptake` is heritable and is never read from the outputs |
| consuming another creature | yes, `creatures` | **no.** Automatic for whatever is largest in the cell |
| being consumed | yes, `creatures` | **no.** Avoidable only by not being there |
| catabolising structure | yes, `self` | **no.** `grow` is clamped at `max(0, Wanted)`, so a creature can build and never deliberately shrink |
| leaving a scent mark | yes, `scent` | **no.** A side effect of moving |
| ageing | **no** | no |

| # | The simplification | Status |
|---|---|---|
| H.1 | **Eating is neither perceived as a choice nor made as one**, and needs both an organ and an actuator | **CORRECTED, world 15, and the experiment it enabled is UNTESTED rather than refuted.** `eat` is the fourth purpose and a mouth is tissue, so a cell can now hold a large creature and a small one and leave both standing. What the implementation taught and the pre-registration had wrong: **the mouth bounds KILLING, not eating**, because world 11 bounds intake once across both sources, so a narrow mouth that leaves a carcass grazes it back off the same cell in the same tick. Being narrow costs nothing while nobody else is standing there. **All four findings failed and none of them is evidence about trophic structure**, because `A.6` makes the organ unselectable: see [RESULTS_WORLD15.md](RESULTS_WORLD15.md). Formerly: **`D.2` seen from this side.** `D.2` asks for the organ, a mouth that costs upkeep, and that is only the smaller half. The missing half is that `eat` is not one of the three purposes at all, so consumption is not a decision either party makes. **Both together are what make fight-or-flight reachable without naming it**: `self` reads identically for every candidate cell so it cancels exactly in a linear comparison, and "am I bigger than that" is `self` multiplied by `creatures`, which is the first decision in this world whose answer depends on your state relative to another's, and precisely what a hidden node is for. Do NOT add a `flee` or a `fight` output; `move` exists and naming the behaviour is world 1's `hunt` again. See [PLAN.md](PLAN.md) phase 3. |
| H.2 | **The feeding rate is inherited and never decided.** A creature cannot eat gently today and greedily tomorrow | **OPEN.** World 4 made `uptake` heritable, which was the first trait ever selected here rather than drifting, and it has been a fixed property of an individual ever since. Nothing lets a creature respond to what is in front of it. |
| H.3 | **Shrinking is not a decision.** `grow` is clamped at nothing, so structure is a one-way investment | **OPEN, and it interacts with `B.9`.** A creature can convert store into frame and cannot convert it back on purpose; the reverse happens only automatically, when starving. So "build while it is safe and liquidate when it is not" is unreachable, which is exactly the conditional the `grow` output was introduced to permit. |
| H.4 | **Marking is a side effect of moving**, not an act | **OPEN, low value.** A creature cannot choose to leave a trail or to suppress one. The only control is not moving, which the register already notes makes sitting tight a way to go unnoticed. |
| H.5 | **A creature cannot perceive its own age** | **OPEN.** `max_age` is 600 against a generation time of about 2, and `G.2` records that never reproducing is survivable here. "Breed before you die" is not a strategy anything could evolve, because nothing can tell how close it is. |
| H.6 | **Being consumed cannot be resisted**, only avoided by not being there | **OPEN, and downstream of H.1.** The contest is decided on structure alone with no defence available at any price. Worth leaving alone until eating is a choice: flight plus size may be sufficient, and if they are not, that is a finding rather than an assumption. |
| H.7 | **AN ACTUATOR COSTS NOTHING AT ALL.** `move`, `breed`, `grow` and `eat` are weight vectors and none of them is counted in `tissue/2` | **OPEN, and it is the largest unpriced thing left in this world.** Sensors pay by reach and hidden nodes pay by the node; **outputs pay nothing**, so a creature carrying all four purposes pays exactly what one carrying none pays. Every organ in this world is priced and every act is free, which is the reverse of the arrangement the register spent five worlds building. It also means `eat` being present is not a tradeoff at all: world 15 priced the MOUTH and left the appetite free, and only half of `H.1` was ever charged. |
| H.8 | **A `self` sensor pays for reach it cannot use** | **CORRECTED**, 2026-08-02. `body:mass/1` now charges reach only where `spatial/1` says it is read, so `{self, 4}` costs one unit rather than five and every spatial field is unchanged. Verified red against the old expression. Formerly: **small, and unambiguous.** `body:mass/1` charges `Range + 1` for every sensor, and `body:spatial(self)` is `false`, so a `self` sensor's reach is never read by anything. A creature carrying `{self, 4}` pays five units of neural tissue for four units of nothing. Nobody wrote that rule; it lives in the difference between the pricing function and the reading function, which is where `C.6` and `B.8` both hid. |
| H.9 | **A hidden node costs the same whatever it reads**, and `B.3` was marked corrected without this being fixed | **CORRECTED**, world 16. `hidden_weights/1` replaces `hidden_count/1` in the tissue expression, and computation became **thirty-one-fold** price-sensitive against world 14's thirteen, reaching 2.83 nodes per creature at the cheapest price, the highest recorded here. It costs survival heavily: 22 of 24 dead at the control. **And it exposed `H.11`**, which is the more useful finding. Formerly: **OPEN.** `brain:hidden_count/1` is `length(H)`, so a node reading ten inputs costs what a node reading one costs. `B.3`'s complaint was exactly this and world 13 changed how the charge is levied, from a flat rent to tissue, without changing what it is levied on. The entry reads as settled and the shape it objected to is still here. |
| H.10 | **What this world can select on, measured**: a mutation must move the bill by about one unit a tick or drift swamps it | **OPEN, and now a GATE**: [PREREGISTRATION_TEMPLATE.md](PREREGISTRATION_TEMPLATE.md) requires any world adding or changing a heritable trait to fill in the per-mutation cost as a share of measured income and stop if it does not clear the threshold. It is the first quantitative statement about what this world can evolve at all.** Measured rather than reasoned: a creature EARNS 87 to 231 a tick and SPENDS 18 to 35, so the surplus is three- to eightfold and every organ here is small against income. Drift beats selection below `s = 1/(2Ne)`, which at an effective population near 50 is about 1%, so a mutation must change the bill by roughly **1 unit a tick** to be visible. The bill moves in units of `1/33`, so **the tissue step must be about 33**. The mouth drifts in steps of **8**, four times too small, and drifts. A sensor is gained or lost **whole** at 10 a tick, which is 10% of earnings, and world 13 moved sensors with a price. **That is why a price worked on one organ and not the other, and it is a property of the mutation operator rather than of the ecology.** See [RESULTS_WORLD15.md](RESULTS_WORLD15.md). **AMENDED 2026-08-02: A PRICE HAS A ROOF AS WELL AS A FLOOR, and this entry only ever wrote down the floor.** Running the gate on `R.5` before building it, `scripts/can_an_act_be_priced.escript`, charging an output by its wiring at `neural_cost` clears the floor twenty-eight times over at **28.4% of income per output**, and then keeps going: the outputs a creature ACTUALLY carries would cost **94.7% of what it earns**. That is not a tradeoff to be selected within, it is a PROHIBITION, and the world it produces is one where nothing acts. **It would have read as a dramatic result.** So the gate asks two questions now: is the step big enough for selection to see (about 1% of income), and is the full complement small enough for a creature to afford (well under half). World 15's mouth failed the floor and `R.5` at the obvious rate fails the roof, which are opposite errors with the same cause: **a price reused from elsewhere rather than swept.** |
| H.12 | **A sense cannot inform a decision whose FORM cancels it. Movement here can never depend on hunger** | **OPEN, and found by the first measurement in this project that watched individuals.** Moving is a RANKING over the seven cells a creature could occupy; `self` is not spatial, so it reads the same at every one of them and adds an identical constant to all seven scores. **A constant added to every alternative cannot reorder them, at any weight.** Measured over 431 `self`-carrying creatures: **0 change where they move** at any store from 0 to 12,800, and **430 of 431 have every candidate cell's score shift by an identical amount**, which is the mechanism rather than a summary of it. Acting is a THRESHOLD, `breed > 0` at one place with nothing to cancel against, and **428 of 431 change whether they want to breed, grow or eat.** So the brains are NOT ornaments: they condition on hunger wherever hunger can be heard. The only thing that could break the symmetry is the rectifier inside a hidden node, and **9 creatures in 431 carry one**, which is `H.11` and `F.3` arriving together. **Third of its kind after `H.10` and `H.11`: before measuring whether something evolved, check whether this world can express it.** See [RESULTS_BEHAVIOUR.md](RESULTS_BEHAVIOUR.md). |
| H.11 | **A hidden node always reads EVERY input. This world cannot express a narrow brain** | **OPEN, and found by world 16 failing to measure something.** `brain:founder/3` draws each hidden row at `width(Sensors, inputs)`, which is `Sensors + 1`, and every structural mutation preserves it. So the topology is fully connected by construction and a lineage cannot economise on connections: **the only way to make a hidden node cheaper is to drop a sensor.** World 16 charged a node by its wiring expecting narrower brains and got wider ones, because width is not a trait, it is `sensors + 1` reported back. It also explains why perception and computation did not trade there: they cannot, when the only lever moves both. **A cost cannot select for a shape the genome cannot represent**, which bounds every future world that tries to price computation and is a second thing the selectability gate has to ask. See [RESULTS_WORLD16.md](RESULTS_WORLD16.md). |

---

## I. What the instruments can be trusted to say

**A new section, and it should have existed five failures ago.** Everything above
is a claim about the world. These are claims about the apparatus, and this
project has now been wrong about the apparatus more often than about the physics.

**They are all one shape: a selector that matches something, just not the thing.**
Every one passed its own reading, none was caught by looking at a summary, and
each was found only by going back to raw output or to what a file was compiled
against.

| # | What was measured instead of what was meant | Status |
|---|---|---|
| I.1 | `carnivores_pct` counted **carriers of a nonzero integer**, not creatures living off creatures | **CORRECTED.** It read 94 to 100 across worlds ranging from toothless to a quarter carnivorous, which is the signature of a selector matching a field's existence rather than its meaning. |
| I.2 | An **occupied-bin count** was used to ask whether a distribution was bimodal | **CORRECTED.** A count of non-empty bins cannot tell bimodal from diffuse; both fill many bins. **A summary of a distribution cannot answer a question about its shape**, which is the general form of this whole section. |
| I.3 | **"Share of cells touching another"** was used to measure clustering | **CORRECTED.** It measures density. On a board with a fixed cell count the two move together, so it agreed with the intended quantity often enough to look right. |
| I.4 | `html =~ "--network host"` matched **the prose describing the command**, not the command | **CORRECTED.** A documentation test that passes because the page explains the thing it is meant to check is present. |
| I.5 | `String.split(~r{</?code>})` matched **a tag**, not the block it delimits | **CORRECTED.** |
| I.6 | `what_can_they_see.escript` called `body:reading/3` after world 17 added a cell count, so it **divided seven cells by one** and reported sums under a world that computes means | **CORRECTED**, 2026-08-02, and the most instructive of the six. The script was written in the commit BEFORE the rules it was measuring, and was CORRECT when written: world 16 genuinely summed. **It was made wrong by a change to the thing it measures, which no reading of its output could reveal.** The reach-0 column stayed byte-identical, because one cell divided by one cell is the same arithmetic, and reach 0 is the column a reviewer checks first. It invalidated the "first observation" table in [PREREGISTRATION_WORLD17.md](PREREGISTRATION_WORLD17.md). **The general rule: when a rule changes, every instrument that reads it is stale until shown otherwise, and the check is what it was compiled against rather than what it prints.** |
| I.7 | **Nothing reports the distribution of sensor REACH**, so world 17's third pre-registered finding could not be scored at all | **OPEN.** The snapshot carries total reach per field and a histogram of sensor COUNTS, which is a different question. Mean reach per sensor can be derived and rises from 0.40 to 1.21 across the sweep, but a mean cannot distinguish a population that spread out from one that shifted together, and "reach differentiates" is entirely a claim about spread. **A pre-registered finding that names no instrument is a finding that cannot fail**, which is the second lesson and belongs in the template. |
| I.8 | **A half-clean `_build` runs a mixture of two worlds** and reports it as a test result | **OPEN, mitigation only.** `rm -rf _build/test` is the remedy this repo has written down and it is not sufficient: the default profile's beams are still reachable, so a suite can pass against constants the source no longer has, or fail against constants it does. On 2026-08-02 the same suite gave 3 failures, then 1, then 0, on unchanged source. **`rm -rf _build`, whole, is the only state worth believing a test result from.** |
| I.9 | **A physics constant living in a deployment config is a version handshake nobody performs** | **CORRECTED**, 2026-08-02, by moving `sense_scale` into `world:defaults()` and deleting the override. It sat in `HECATE_BIOTOPE_ECON` in `macula-demo`, a different repo on a different release cadence, and an unknown economy key is a startup failure by design. beam01 pulled the config that named the key before it pulled the image that had it and spent two hours in a boot-crash loop with the fix already on the box. **The same failure had happened once before, and the config files carry a written prediction that it would happen again**, which it did, in the same shape, because a warning in a comment is not a mechanism. The rule that replaces it: **a node config may name what a node IS and never what the physics ARE.** |

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
