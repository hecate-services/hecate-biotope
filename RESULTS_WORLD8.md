# Results: world 8

**The change:** capacity is a property of structure. A creature cannot take in
more than its frame.

    absorbed = min(uptake, frame, what is in the cell)

No new constant. Corrects register entry **B.6**. Pre-registered in
[PREREGISTRATION_WORLD8.md](PREREGISTRATION_WORLD8.md).

5 seeds, 2000 ticks, 11 efficiencies.

## The headline

**World 8 did not run out of energy. It ran out of variation.**

Every seed at every efficiency goes extinct, which reads like a world too poor to
live in. It is the opposite. The creatures alive at tick 595 carry stores of
**11,643 to 183,500** against the **400** they were founded with, no birth was
ever refused, and they still do not reproduce. One of them holds a third of what
the entire board can store.

They are not starving. They are hoarding, and they are sterile.

## What kind of extinction

Not a collapse and not a dwindle. **42 of 45 seeds at efficiency 30 and above die
at exactly tick 602**, and `max_age` is 600.

The descent ladder says the same thing a second way. For most seeds the tick the
population first falls below 4, below 2, and below 1 are **the same tick**. The
world goes from a steady handful to nothing in one step, which bad luck does not
do and a ratchet does not finish in one tick.

| eff | dies at 602 | exceptions |
|---|---|---|
| 100 | 4 of 5 | one at 608 |
| 95 | 3 of 5 | one at 605, one at 1035 |
| 90 down to 30 | 5 of 5 | none |
| 20 | 3 of 5 | starve at 57 and 85 |
| 10 | 0 of 5 | all starve, 22 to 79 |

At efficiency 30 and above, the world ends because its founders reach six hundred
years old on the same day. Nothing replaced them.

## Who the survivors are

At t=595, one tick short of the age limit:

| eff | pop | of those, founders | births after t=200 | largest frame | largest store | births refused |
|---|---|---|---|---|---|---|
| 100 | 3 to 14 | all but one seed | 0 in 4 of 5 | 1,173 to 4,345 | 80,314 to 183,500 | 0 |
| 70 | 2 to 5 | all | 0 in 5 of 5 | 1,590 to 2,185 | 30,064 to 82,694 | 0 |
| 30 | 1 to 5 | all | 0 in 5 of 5 | **exactly 400** | 11,643 to 23,410 | 0 |

**Population equals founders in 14 of 15 runs.** At 30% the largest frame alive is
exactly the 400 a founder is born with, so those creatures never built a unit and
never bred, since breeding would have halved it. They sat still for six hundred
ticks and got rich.

The only gate left in the code is the brain's own output. `max_creatures` never
bound, and `E > 1` is satisfied by a factor of a hundred thousand.

## The engine stopped at tick 15

The world gained two carried observables for this, `lineage` and `generation`,
which no rule reads.

| eff | last birth | deepest generation ever alive | deepest still alive | ticks frozen |
|---|---|---|---|---|
| 100 | 10 to 20, one at 210 | 5 to 15 | 0 in 4 of 5 | 391 to 592 |
| 70 | 10 to 35 | 3 to 5 | 0 in 5 of 5 | 566 to 591 |
| 30 | 5 to 30 | **1** in 4 of 5 | 0 in 5 of 5 | 571 to 596 |

**94 to 99 percent of every run happens after the last birth.** A world running
with the engine off is not a slow world, it is a finished one, and every world
before this reported the population without ever asking whether it could still
change.

At 30% efficiency **no lineage ever reaches a second generation in four seeds of
five.** Not one.

## Why: the dowry compounds

Reproduction takes `E div 2` and `S div 2`, and world 8 made the frame the cap on
feeding. So giving away half your structure permanently halves the rate at which
you can take food in, and you must rebuild on the reduced income.

The transfer is also lossy, so:

> child frame = parent frame × efficiency / 200

That is geometric decay per generation, and it is the whole of it. Starting from
400, the generations before a lineage falls under the roughly 11 units of frame
that pay metabolism at all:

| eff | multiplier per generation | predicted | **measured deepest ever** |
|---|---|---|---|
| 100 | 0.50 | about 5 | **7** |
| 70 | 0.35 | about 3 | **4** |
| 30 | 0.15 | about 2 | **1** |

**The prediction was written before the measurement was taken.** The world does
not sterilise itself by decree. It sterilises because breeding is self-harm, and
one round of selection over forty random founders kept exactly those that refuse.

Then the crowd died, the board recovered, and the survivors stayed rich and
barren, because refusing is what they are.

## Against what was pre-registered

| # | Finding | Result |
|---|---|---|
| 1 | **Ghosts become impossible.** `structure_max` above zero at every efficiency | **CONFIRMED.** 400 to 560 at every one of the eleven, where world 7 had zero from 70% down. |
| 2 | **Structure stops being optional**, frames present across the sweep | **HALF.** Frames are present everywhere, but at 40% and below the largest is exactly 400, the founder's own. Nothing is *built* below 50%. |
| 3 | **Lifespan rises above 2.2 ticks** | **MET, and it means the opposite of what was wanted.** 3.7 to 24.6 ticks against 2.19 in world 7. The rise is a handful of frozen founders sitting in an average, not an apparatus repaying over time. It describes nobody: most creatures still die in about two ticks and the survivors last six hundred. |
| 4 | **World 7's frame collapse is explained** | **NOT ANSWERABLE AS FRAMED, and answered another way.** The comparison was never like for like: world 7 was measured at t=2000 with every founder long dead, and world 8 has no live population at t=2000 at all. What settles it instead is the arithmetic above plus generation depth. |
| 5 | **Density falls** | **CONFIRMED, hard.** 3 to 27 creatures at t=20 against world 6's ~2,300. |
| not | **`still%` will probably stay high** | **FAILED, and this is a real one.** 40 to 81 against 97-98 in world 7 and 99-100 in world 6. At these densities there is no reason to sit still: the board is empty and the food is elsewhere. |

## What it costs world 7, which was declared in advance

World 7 reported frames collapsing to zero below 70% efficiency and offered two
readings, the Second Law or integer truncation. The pre-registration named a
third, the ghost bug.

**It is none of the three. It is the dowry compounding**, and the ratio is
`efficiency / 200` per generation. Below 70% two generations strip a lineage of
its body, which is why the column read zero. World 7's entry **D.3** is amended
rather than quoted.

## What this world teaches

- **A world can be rich and finished at the same time.** Every measure of wealth
  in world 8 rises while the thing that matters goes to zero at tick 15. Energy
  was never the binding constraint and eight worlds of energy accounting could
  not have found this, because none of them measured variance.
- **Fitness zero is survivable here, and it should not be.** A strategy of never
  reproducing wins the census because `max_age` is 600 against a generation time
  of about 2. Individual persistence outruns lineage persistence by two orders of
  magnitude, so the world counts individuals whose lines are already extinct.
- **A tradeoff with an exit is not a tradeoff.** The axis on offer was breed and
  halve yourself, against do not breed. The second is not a point on the surface,
  it is stepping off it, and diversity cannot come from an axis one end of which
  leaves the game.
- **Measure the engine, not only the vehicle.** `lineages`, `depth` and the
  uptake spread cost a handful of integers a tick and they retro-apply to every
  world in this register.
- **A census of an empty world is not a census.** The first run of the engine
  script read the final snapshot and reported a depth of zero everywhere, while
  the trajectory printed beside it showed six. Both came from the same run.
