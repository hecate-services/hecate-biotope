# The physics register

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

- **holding energy** (2.1) — flat metabolism regardless of mass
- **eating at all** (4.2) — no cost to subdue, and no decision either
- **eating a creature specifically** (4.3) — perfect trophic efficiency, so
  carnivory costs no more than grazing
- **being still** (3.2) — costs nothing and risks nothing, since nothing can find
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

## 1. Where energy enters

| # | The simplification | Status |
|---|---|---|
| 1.1 | Ground recovered at a fixed rate regardless of what was left in it | **CORRECTED**, world 3. No effect on anything: a stayer strips its cell to zero every tick, so nothing ever holds stock for a stock-dependent rule to act on. |
| 1.2 | Recovery is spatially uniform: no terrain, no fertile or barren ground | **OPEN, and deliberately so.** A terrain generator has free parameters, and the honest criterion for setting them would be "correlated over the distances a sensor can evolve to reach", which is choosing the world's structure so that sensors pay. Emergent enrichment has no such knob. |
| 1.3 | Standing stock is capped at a ceiling | **OPEN.** Real systems do saturate, so this is probably right, but the cap is a chosen number rather than a derived one. |
| 1.4 | Energy arrives everywhere at once, with no day, season or weather | **OPEN.** Temporal variation in supply is the one thing dispersal theory says most reliably drives movement, and this world has none: every tick is identical. |

## 2. What energy costs to hold

| # | The simplification | Status |
|---|---|---|
| 2.1 | **Metabolism is flat regardless of how much a creature holds.** One carrying 10,000 pays exactly what one carrying 10 pays | **OPEN. PRICES A FREE GOOD: holding energy.** Kleiber's law says otherwise for every organism ever measured. The consequence is that **size is a free good**, which is why grabbing fast beat prudence in world 4: energy is armour with no upkeep, so there is never a reason not to hoard. |
| 2.2 | Sensor rent rises with the radius of reach, not the area covered | **OPEN, and no physics settles it.** Named in the pre-registrations rather than defended. Area was rejected because at rent 1 a range-two sensor would cost nineteen a tick against a metabolism of ten, pricing reach out before selection saw it. |
| 2.3 | A hidden node costs a flat rent regardless of how many inputs it reads | **OPEN, and no physics settles it.** |
| 2.4 | Senescence is a fixed age, unrelated to how hard a creature has lived | **OPEN.** Ageing is energetic in real organisms; here it is a counter. |

## 3. What energy costs to act

| # | The simplification | Status |
|---|---|---|
| 3.1 | Movement costs the same whatever a creature weighs | **OPEN.** Removes the small-and-quick against large-and-slow axis entirely. |
| 3.2 | Everything moves exactly one cell per tick | **OPEN. PRICES A FREE GOOD: being still.** No pursuit and no flight, so escape does not exist and "prey" has no strategy available but being larger, which is the predator strategy. |
| 3.3 | Reproduction costs only the dowry: no gestation, no gamete production | **OPEN.** |
| 3.4 | Offspring are placed at a fixed distance by a fixed rule | **OPEN.** Dispersal is not heritable, so kin competition, which theory says drives movement in exactly this world's conditions, has nothing to act on. |
| 3.5 | The dowry is exactly half, and not heritable | **OPEN.** |

## 4. How energy transfers

| # | The simplification | Status |
|---|---|---|
| 4.1 | A creature absorbed everything in its cell instantly | **CORRECTED**, world 4. Feeding is rate-limited and heritable. Produced the first positive: the landscape differentiates, `ground_spread` 26-86 against 9 before. |
| 4.2 | **PRICES A FREE GOOD: eating. Consumption is unconditional and free.** The largest creature in a cell eats every smaller one, always, with no cost and no decision | **OPEN, and partly self-inflicted.** World 1 had a cost and a decision; removing the named verb `hunt` was right, and making consumption unconditional in the same change was a separate act that was never justified. **A creature cannot be a herbivore even in principle**: if it is the biggest thing present it eats, whether that suits it or not. |
| 4.3 | **Trophic efficiency is 100%.** A victim's entire energy transfers to whatever ate it | **OPEN. PRICES A FREE GOOD: eating creatures rather than ground.** Real food chains lose roughly nine tenths per level. As it stands, herbivory and carnivory are economically identical, so there is nothing to specialise *into*. |
| 4.4 | Absorption from the ground is likewise perfectly efficient | **OPEN**, and the same question. |

## 5. Where energy goes

| # | The simplification | Status |
|---|---|---|
| 5.1 | A creature that died simply ceased, and its energy was deleted | **CORRECTED**, world 2. Death returns everything to the cell it died on, which closed the books and made them checkable to the unit for the first time. |
| 5.2 | A corpse is available instantly and entire; there is no decay | **OPEN.** |
| 5.3 | Metabolism is the only true sink | **Probably correct.** Work leaves as heat; everything else circulates. |

## 6. Perception

| # | The simplification | Status |
|---|---|---|
| 6.1 | A sensor reads an exact sum with no noise, no error and no delay | **OPEN.** |
| 6.2 | Readings were divided by one shared constant regardless of magnitude | **CORRECTED**, world 2. Natural units per field. |

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
