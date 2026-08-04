# Pre-registration: spoiling the ground — **WITHDRAWN, NEVER BUILT**

> **⚠ WITHDRAWN 2026-08-04, one day after it was written and before a line of it
> was implemented. It never became a world and no longer carries a world number.**
>
> **Its gate was computed against an `Ne` nobody had measured.** The document
> puts the cost of a `spoil` output at 1.34% of income and calls that "marginal,
> and marginal is the right answer here". `Ne` was then measured at **7.44**,
> putting the drift floor at **6.72%**, so 1.34% is not marginal: it is **five
> times below the floor** and invisible to selection. `G.10`.
>
> **And it was gated as a trait when it is a change to the world.** The gate it
> ran asks whether selection can see an organ's cost. See `I.16` and the
> environmental gate now in the template.
>
> Kept as a record. The reasoning about spite under negative relatedness stands
> and may be worth returning to once creatures can be selected on anything.

**Written before world 23 was built.** Addresses register entry **J.2**, new
below. World 22 is superseded, not edited.

**A creature can spoil the ground it stands on.**

---

## THE SELECTABILITY GATE

**⚠ AND THE GATE AS WRITTEN DOES NOT FIT THIS WORLD, WHICH IS STATED HERE RATHER
THAN FUDGED.**

Every previous world put a PRICE on something and asked whether selection could
see the price. World 15 failed because its price moved the bill by 0.24% of
income, below the level at which drift beats selection, and one line of
arithmetic would have said so.

World 23 does not put a price on anything. It adds a CAPACITY, and the question
is whether selection can see what the capacity DOES. So the table is filled in
for the cost, because the cost still has to not swamp the effect, and a second
table is added for the effect, because that is the thing under test.

### The cost of carrying the organ

| | value | how it was obtained |
|---|---|---|
| what a creature earns, per tick | **117** | measured, `scripts/where_does_it_go.escript`, three surviving seeds at 124, 107, 120 |
| what one mutation of this trait changes the bill by, per tick | **1.57** | an output is charged its live wiring at `act_cost`: ~3.24 live weights × 16 ÷ `upkeep_divisor` 33 |
| that as a share of earnings | **1.34%** | |
| the drift threshold, `1 / (2·Ne)` | **0.71% at Ne = 70, 1.43% at Ne = 35** | population is 65 to 100; **`Ne` has never been measured here** |
| **does it clear the threshold** | **MARGINAL, AND THAT IS ACCEPTABLE HERE** | it clears at `Ne = 70` and fails at `Ne = 35` |
| what the FULL complement of this organ costs, as a share of income | **1.34%**, one output | **the roof** |
| **is that well under half** | **yes, comfortably** | the price is not a prohibition |

**A MARGINAL COST IS THE RIGHT ANSWER FOR THIS WORLD AND WOULD BE THE WRONG ONE
FOR ANY PREVIOUS WORLD.** World 18 measured exactly this and called it a defect:
at `act_cost` 16 "nothing visible happens", and shedding an output needs four
times the drift floor. Here that is the point. **The organ should be nearly free
so that selection sees its EFFECT rather than its rent.** If spoiling is not
adopted, we want to be able to say it was not worth doing, not that it was
unaffordable, which is what worlds 19 and 21 both ended up saying.

⚠ **`Ne` IS UNMEASURED AND THIS IS THE THIRD WORLD TO LEAN ON A GUESS FOR IT.**
Reproductive variance here is enormous: `lineages` collapses to 1 within a few
hundred ticks in every seed, which is the signature of an effective population
far below the census count. **Measuring `Ne` is owed and is not part of this
world**, but every gate that has used it has used an estimate, and if world 23
returns a null the honest first question is whether `Ne` is 10 rather than 70.

### The size of the effect, which is what is actually under test

| | value | how it was obtained |
|---|---|---|
| what one spoiling denies, at most | **≤ `min(uptake, structure)`**, the same bound eating already has | reuses `absorb/2`'s bound, no new constant |
| a full cell, as ticks of one creature's income | **3.4** | `ground_ceiling` 400 ÷ 117 earned per tick |
| a full cell, as a share of a LIFETIME's earnings | **34%** | mean life ~10 ticks, so lifetime earnings ~1,170 |
| **is the effect large enough for selection to see** | **YES, by an order of magnitude** | 34% against a drift floor near 1% |
| **who receives the effect** | ⚠ **MOSTLY THE SPOILER** | **61% of creatures are standing still**, measured |

**THE LAST ROW IS THE WHOLE EXPERIMENT AND IT PREDICTS FAILURE.** Spoiling harms
whoever feeds in that cell next. On a board where three creatures in five do not
move, that is usually the spoiler. The effect is enormous and its expected sign
is negative.

### Representability: can the genome express this at all?

**Yes, and this is the check world 16 failed.** `spoil` is an output, and outputs
are already a trait: `brain:toggle/5` gains and loses them, world 18 measured
purposes per creature falling 3.71 to 2.06 under price, and 68% of creatures
currently carry all four. A creature can have the organ or not, and can weight it
from -8 to +8. Nothing about the shape is unrepresentable.

**What may NOT be representable is the STRATEGY.** Spoiling pays only if the
spoiler leaves and a competitor arrives. That requires either coupling two acts
in one tick, which a brain can express since every output is evaluated from the
same inputs, or knowing that it is about to leave, which nothing tells it. This
is the honest weak point and is the reason for the strongest negative below.

---

## Why there is a world 23

**Every previous world changed what a creature COSTS. This one changes what a
creature can DO TO THE WORLD.**

Twenty-two worlds of creatures have influenced their island in exactly two ways,
both passive: a corpse enriches the cell it fell in, and moving leaves a scent
that fades. Neither is chosen. Nothing a creature decides has ever changed the
place it lives in.

That matters because of what the archive now measures. Over 32 seeds to 8,000
ticks the frontier of newly-found ways-of-living runs 42, 9, 3, 2, 1, **0, 0, 0**:
the median world stops discovering by tick 6,000 while its population carries on
at seventy-odd creatures. World 22 added historical marking and assortative
mating, and neither moved it.

The standing hypothesis for why is that **the environment is static**. A fixed
landscape has a finite number of ways to make a living, they are found, and the
search ends. Niche construction — organisms changing the environment that selects
them — is the standard precondition for open-ended evolution, and this world has
it only as a side effect of dying.

**Register entry `J.2`, new:** *the environment is not a participant.* Creatures
adapt to the island and the island does not adapt to them, so the fitness
landscape is exogenous and the search is a search of a fixed space.

## The single change

**A fifth purpose, `spoil`. When a creature's brain says spoil, energy is drawn
from the cell it stands on and dissipated instead of being eaten.**

**NO NEW CONSTANT.** The amount is bounded by `min(uptake, structure)`, which is
exactly the bound `absorb/2` already puts on eating, and the energy goes to
`dissipated`, which is where every other loss in this world already goes.
Spoiling is eating without swallowing.

⚠ **`spoil` IS APPENDED TO `?PURPOSES` AND NEVER INSERTED.**
`[move, breed, grow, eat]` become `[move, breed, grow, eat, spoil]`. Those
indexes travel on the wire inside `kind_table`, and
`the_wire_codes_for_fields_and_purposes_are_fixed_test` pins the order precisely
because reordering would silently change the meaning of every kind table ever
published: a reader would draw a creature that breeds where one that moves is.
That is `I.6` with a wire between the instrument and the reader.

## What would count as a finding

1. **The organ is carried.** A creature can have `spoil` and some do.
   **Instrument:** `brain:carried/1` via the purposes census;
   `scripts/sweep_acts.escript` reports purposes per creature and needs a column
   added for the share carrying each specific purpose, which **does not exist yet
   and is part of this world**.

2. **Spoiling actually happens.** Carrying an output and firing it are different
   things, and world 16 is the register entry for confusing them: a creature can
   pay for an organ its brain weights at zero. **Instrument:** a new world
   counter `spoiled`, total energy destroyed this way, published on the fact
   beside `dissipated`. **Does not exist yet and is part of this world.**

3. **The frontier moves.** The claim this world is for: a co-constructed
   environment keeps producing new ways to live. **Instrument:**
   `scripts/is_it_still_discovering.escript`, already built, 32 seeds to 8,000
   ticks, against the recorded baseline of 42, 9, 3, 2, 1, 0, 0, 0.

4. **Spoilers and their neighbours differ.** If spoiling pays at all it pays by
   being spatially structured: spoil here, feed there. **Instrument:** `F_ST`,
   already reported, against world 22's value on the same seeds.

## THE STALE INSTRUMENT GATE

| script | which rule it reads | last verified against it |
|---|---|---|
| `sweep_acts.escript` | `?PURPOSES` and the act price | world 18; **must be re-read: it will silently average over five purposes where it averaged four** |
| `what_kinds_are_alive.escript` | `?PURPOSES` order via `kind_of` | world 20; the order is appended so indexes 0–3 are stable |
| `world_facts:world_charted/2` | `purpose_code/1` indexes into `brain:purposes/0` | world 20, pinned by a test; **appending is safe, inserting is not** |
| `is_it_still_discovering.escript` | the archive and `frontier` | world 22, unchanged by this world |
| `where_does_it_go.escript` | income and the mouth's share | world 15; reads `uptake`, untouched here |
| `behaviour.erl` portraits | acts are not an axis | unaffected |

**And believe a test result only from `rm -rf _build`, whole.** See `I.8`.

## What will NOT happen, stated in advance

**SPOILING WILL BE EXPRESSIBLE AND UNUSED. This is the expected result and the
reasoning is arithmetic, not pessimism.**

Spoiling denies energy to whoever feeds in that cell next. **61% of creatures are
standing still**, measured, so for three creatures in five the next feeder is
itself. The organ costs 1.34% of income to carry and its expected effect on its
owner is *negative* at the population's measured mobility. Selection should
remove it, and the honest prediction is that the `spoil` output is carried by a
smaller share than any of the four existing purposes.

**THE STRONGEST AVAILABLE NEGATIVE, written out so it cannot be reinterpreted
afterwards:** if `spoil` is carried at a share indistinguishable from what an
unused output drifts to, and `spoiled` energy is a negligible fraction of
`dissipated`, and the frontier still reaches zero by tick 6,000, then **the
answer is that this world cannot support spite, and niche construction is not
what is closing the frontier.** That would be a finding about the ecology and it
would make the next world look at the environment rather than at the creatures.

**This is the fourth consecutive world to predict a null**, after width (19),
acts (18, partial) and memory (21). Three "expressible and unused" results in a
row is beginning to be the finding: something in this world systematically
prevents new capacities from being adopted. **That only holds as a claim if each
was predicted rather than rationalised afterwards**, which is what this section
is for.

⚠ **AND THE OPPOSITE MUST BE SAYABLE.** If spoiling IS adopted, the mechanism
will be spite under negative relatedness: harming a competitor less related to
you than the population average. This world acquired the machinery for that two
days ago — scent is kin recognition by its own documentation, and world 22 made
creatures breed with the least strange partner in reach. **That is a genuine
reason this null might fail where the last three did not**, and if it does, the
credit belongs to world 22 and not to this one.

## The commitments

1. Rules frozen before the first run, not changed in response to it. This file is
   superseded, not edited.
2. Every seed reported, including **nothing happened**, and including the dead.
3. `world:ruleset/0` says 23 in the same commit as the rules, `WORLDS.md` gains
   its row first, and `the_number_agrees_with_the_register_test` fails if they
   disagree. **Both sides were stale for three worlds** because I updated
   neither; see `I.15`.
4. `lineages`, `depth`, the uptake spread and **F_ST** reported beside the
   population.
5. New tests go red against world 22's physics before they are believed.
6. **No test names a swept constant by inheriting it.**
7. **A node config may name what a node IS and never what the physics ARE.**
8. **The two instruments in findings 1 and 2 are built and tested BEFORE the
   sweep runs**, not after. `I.7`: a pre-registered finding that names no
   instrument is a finding that cannot fail, and world 17 scored one UNTESTED
   after 24 seeds had run to 20,000 ticks.
9. **`spoil` is appended to `?PURPOSES`, never inserted**, and the existing wire
   test is extended to pin the five-element order before the rule is written.
