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
| A.2 | Recovery is spatially uniform: no terrain, no fertile or barren ground | **OPEN, and deliberately so.** A terrain generator has free parameters, and the honest criterion for setting them would be "correlated over the distances a sensor can evolve to reach", which is choosing the world's structure so that sensors pay. Emergent enrichment has no such knob. |
| A.3 | Standing stock is capped at a ceiling | **OPEN.** Real systems do saturate, so this is probably right, but the cap is a chosen number rather than a derived one. |
| A.4 | Energy arrives everywhere at once, with no day, season or weather | **OPEN.** Temporal variation in supply is the one thing dispersal theory says most reliably drives movement, and this world has none: every tick is identical. |
| A.5 | **The seed rate is a floor a stripped cell gets for nothing**, and it was set in world 4 by asking whether a creature that sits still and does nothing could fund a child on it | **OPEN, and the criterion that set it has gone stale.** That creature paid only metabolism in world 4. Since world 5 it also pays upkeep on the frame it was founded with and cannot shed, so the criterion now asks for a seed of 24 against the 12 configured, and `scripts/verify_ground.escript` reports DISAGREES. **Not acted on, twice deliberately.** The reachability the criterion exists to establish is the yield line, which passes: a prudent stayer nets 22 against a cost of 10. What fails is a lineage that strips its cell and then sits on the bare floor, and **world 3 made that fatal on purpose**. Raising the seed to rescue it would undo world 3. It went unseen through two worlds because the script had an unbound variable and would not compile, which is the more useful lesson: **a verification that cannot run is worse than none, because it is still cited.** |

## B. What energy costs to hold

| # | The simplification | Status |
|---|---|---|
| B.1 | **Metabolism is flat regardless of how much a creature holds.** One carrying 10,000 pays exactly what one carrying 10 pays | **CORRECTED**, world 5, **and the correction was LINEAR, which is harsher than anything nature does.** Kleiber's three-quarter exponent is empirical, contested against two-thirds, and shows curvature rather than being constant, so it is a robust regularity and not a law. But every candidate exponent is SUBLINEAR: cost per unit mass falls as size rises. Linear holds it constant, so large size was taxed more heavily here than in any real organism. See B.5 for the deeper error. Priced the free good and size became hard-bounded, largest creature 66-99 against a founding 800. **It also UNDID world 4's positive**: the landscape flattened from a spread of 26-86 back to 9-10, and energy from creatures fell to zero in every seed. Creatures can no longer store, so they no longer differ, so contests move nothing and no place becomes different from another. **Some variance was living on that free good.** Kleiber's law says otherwise for every organism ever measured. The consequence is that **size is a free good**, which is why grabbing fast beat prudence in world 4: energy is armour with no upkeep, so there is never a reason not to hoard. |
| B.2 | Sensor rent rises with the radius of reach, not the area covered | **OPEN, and no physics settles it.** Named in the pre-registrations rather than defended. Area was rejected because at rent 1 a range-two sensor would cost nineteen a tick against a metabolism of ten, pricing reach out before selection saw it. |
| B.3 | A hidden node costs a flat rent regardless of how many inputs it reads | **OPEN, and no physics settles it.** |
| B.4 | Senescence is a fixed age, unrelated to how hard a creature has lived | **OPEN.** Ageing is energetic in real organisms; here it is a counter. |
| B.5 | **Energy conflates a STORE with a STRUCTURE.** One number is a creature's fat reserve, its body, its weapon in a contest and its reproductive capital, all at once | **CORRECTED**, world 6. These have opposite physics: an inert store costs almost nothing to hold, which is what fat is FOR, while working tissue is expensive to run. World 5 priced the conflated quantity and so taxed reserves as though they were tissue. **The result was first written up as two settled sizes and that claim is WITHDRAWN**: frames are bimodal in all five seeds, but mean age per bucket climbs 1 to ~400, so the large are the old. What survives is a measured adult and juvenile structure ~200x apart in lifespan, which a constant hazard cannot produce, and whose cause is not established because no earlier world measured age. It did NOT restore world 4's landscape variance (`ground_spread` 11-13 against 26-86) and did not make predation pay. See [RESULTS_WORLD6.md](RESULTS_WORLD6.md). |

| B.6 | **A body was OPTIONAL.** Frame won contests and cost upkeep, and that was the whole of it: nothing a creature could do depended on having one | **CORRECTED**, world 8. Capacity became a property of structure, `absorbed = min(uptake, frame, cell)`, which is a comparison between two quantities the world already tracked rather than a new constant. **Ghosts became impossible**: largest frame alive runs 400 to 560 at every one of the eleven efficiencies, where world 7 had it at zero from 70% down. It also **ended every seed**, and not for want of energy. See [RESULTS_WORLD8.md](RESULTS_WORLD8.md) and G.1. |

## C. What energy costs to act

| # | The simplification | Status |
|---|---|---|
| C.1 | Movement costs the same whatever a creature weighs | **OPEN.** Removes the small-and-quick against large-and-slow axis entirely. |
| C.2 | Everything moves exactly one cell per tick | **OPEN. PRICES A FREE GOOD: being still.** No pursuit and no flight, so escape does not exist and "prey" has no strategy available but being larger, which is the predator strategy. |
| C.3 | Reproduction costs only the dowry: no gestation, no gamete production | **OPEN, and worlds 6 AND 7 now say it is the one that matters.** World 7 priced every transformation and lifespan did not rise, so the churn is not caused by transfers being free. Mean lifespan is 2.2 ticks and 2,264 of 2,318 creatures can breed, so breeding every tick is the dominant move and the population is held permanently above what the ground can feed. **No apparatus can amortise over two ticks**, which is the constraint underneath every null in this register. Subsumed by D.3, which prices it as one case of a general law rather than as a special rule for reproduction. |
| C.4 | Offspring are placed at a fixed distance by a fixed rule | **OPEN.** Dispersal is not heritable, so kin competition, which theory says drives movement in exactly this world's conditions, has nothing to act on. |
| C.5 | The dowry is exactly half, and not heritable | **OPEN, and world 8 makes it the most damaging entry in this register.** Half is not required by physics. Conservation requires the child's material to come from the parent and the Second Law requires the assembly to dissipate; neither says anything about the amount, exactly as with the efficiency in D.3. `div 2` is a chosen constant wearing the costume of a symmetry, and had it been written `div 7` it would have been questioned two worlds ago. **It is also multiplicative and lossy**, so `child frame = parent frame × efficiency / 200`, which is geometric decay per generation. Measured deepest generation ever alive: **7 at 100%, 4 at 70%, 1 at 30%**, against 5, 3 and 2 predicted from that ratio before the run. This is the mechanism behind D.3's frame collapse and behind world 8 ending sterile. Theory says the amount is a life-history trait and not a constant at all: under Smith and Fretwell (1974) per-offspring investment is set by how survival scales with size and the NUMBER is what floats, and this world fixes the number at one and floats the investment at 50%, which is backwards. |
| C.7 | **Reproduction is paid by dismembering the parent's own body.** Half the frame goes to the child, alongside half the store | **OPEN, and world 9 addresses it.** Never justified: the code says both halves split alike "because structure is energy in another form", which is true and does not make taking it obligatory. Real organisms provision offspring from reserve, which is what a reproductive buffer is in Kooijman's Dynamic Energy Budget theory, and resorbing working tissue to breed happens once at the end of a life rather than every tick. Harmless until world 8 made the frame the cap on feeding; from then on it halves the organ that pays for everything, geometrically and per generation. See C.5 for the arithmetic and [RESULTS_WORLD8.md](RESULTS_WORLD8.md) for what it cost. |
| C.6 | **The movement fare was the one cost that could not be paid from your own body** | **CORRECTED**, world 7, and it was never in this register because nobody knew it was a rule. Every other cost could be covered by catabolising a frame; the fare pushed the store negative and a negative store was death, so moving when you could not afford it was fatal however much body was left to burn. **It held perception at zero for five worlds.** Removing it, which conservation forced, took sensors from 0.01 to 2.52 per creature and hidden nodes from 0.01 to 1.80 at an efficiency where nothing is lossy. **The lesson is the entry: a bookkeeping error can be a physical rule in disguise, and only exact conservation finds it.** |

## D. How energy transfers

| # | The simplification | Status |
|---|---|---|
| D.1 | A creature absorbed everything in its cell instantly | **CORRECTED**, world 4. Feeding is rate-limited and heritable. Produced the first positive: the landscape differentiates, `ground_spread` 26-86 against 9 before. |
| D.2 | **PRICES A FREE GOOD: eating. Consumption is unconditional and free.** The largest creature in a cell eats every smaller one, always, with no cost and no decision | **OPEN, partly self-inflicted, and the RIGHT FORM is now known.** World 1 had a cost and a decision; removing the named verb `hunt` was right and making consumption unconditional in the same change was never justified. So every creature is an obligate predator on every smaller creature it meets, which is why **97% of all deaths are being eaten** — an artifact rather than a finding. Real plants do not consume their neighbours, and not because they are a different TYPE, which was correctly abolished, but because **a tree has no mouth**. So the correction is not "make eating cost" but **make eating require an apparatus that costs rent**, exactly like a sensor. A creature that has not invested cannot consume another however large it is, and lives on ground alone. **That is a herbivore as a tradeoff rather than a type.** |
| D.3 | **EVERY ENERGY TRANSFORMATION IN THIS WORLD IS 100% EFFICIENT.** Not one simplification but ONE LAW BROKEN AT SIX SITES | **CORRECTED**, world 7, swept from 100% to 10% rather than chosen. It **differentiated the landscape**, `ground_spread` 13 to 30 against a flat 10, which is the Prigogine prediction and the only thing pre-registered from theory that landed. It **destroyed structure**, frames going from 102 to 0. **AMENDED by world 8, and this reading is withdrawn.** Two explanations were offered here, the Second Law or integer truncation, and world 8's pre-registration named a third, the ghost bug. It is none of the three: the frame collapse is C.5 compounding, at a ratio of `efficiency / 200` per generation, so below 70% two generations strip a lineage of its body. This entry may not be quoted for the collapse. It **shortened lives** rather than lengthening them, which was the direct target and failed in the opposite direction. Predation did not move. The world survives to 20% efficiency, against a prediction that it would die across most of the range. See [RESULTS_WORLD7.md](RESULTS_WORLD7.md). |
| D.4 | Absorption from the ground is likewise perfectly efficient | **SUBSUMED BY D.3.** Kept as the record of when it was noticed separately, before it was clear that the same law was broken at every site rather than at two of them. |
| D.5 | **One efficiency fits all six transformations** | **OPEN, and created by the fix for D.3.** Real efficiencies differ widely by process: assimilation runs about 20-50% in herbivores against about 80% in carnivores, and production efficiency varies more still. Six values would be six undefended parameters, so one is the honest first correction and differentiating them needs a reason rather than a preference. |

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
| G.1 | **Variance enters this world through exactly one operator, birth**, so selection against reproduction is selection against the variance source itself | **OPEN, and it is what ended world 8.** Trait mutation, brain mutation and body mutation all ride on reproduction. When breeding became self-harm the world kept the founders that refuse, and after that nothing new could be produced at any price. The last birth falls between ticks 5 and 35, so **94 to 99 percent of every run happens with the engine already off.** Measured by `lineages`, `depth` and the uptake spread, which are observables and which no rule reads. The design already names one variance source that does not require local birth, **invasion between islands**, and every world from 1 to 8 has been a single island without it. |
| G.2 | **A strategy of never reproducing is survivable here**, because `max_age` is 600 against a generation time of about 2 | **OPEN.** Fitness zero is removed in one generation in nature and persists for six hundred ticks here, so a census counts individuals whose lineages are already extinct. Individual persistence outruns lineage persistence by roughly two orders of magnitude. See B.4: senescence as a counter is what sets the 600. |
| G.3 | **The world is perfectly constant.** No day, no season, no weather, no disturbance | **OPEN, and it is A.4 read from the other side.** A constant environment has a point optimum, and a point optimum is the opposite of diversity. This is also what makes bet-hedging unpayable (Cohen 1966, Slatkin 1974) and the storage effect inoperable (Chesson 2000). |
| G.4 | **Almost nothing here is frequency dependent**: being common costs nothing and being rare buys nothing | **OPEN.** Chesson's distinction is the relevant one: tradeoffs are *equalising*, they shrink fitness differences and slow exclusion. Coexistence needs something *stabilising*, where rare does better than common. Contests are decided by size, so commonness is neutral. With one limiting resource, the exclusion principle predicts one strategy however many tradeoffs are added. |

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
