# Pre-registration: world 23

**Written before world 23 was built.** Addresses register entries **J.1** and
**J.2**. World 22 is superseded, not edited.

**A creature can only breed while it is standing on water.**

The spoiling world that briefly held this number is
[withdrawn](PREREGISTRATION_SPOIL_WITHDRAWN.md): its gate was computed against an
`Ne` nobody had measured, and it was gated as a trait when it was a change to the
world.

---

## THE ENVIRONMENTAL GATE

**This is a change to the island, not to a creature, so it is gated as one.**
`I.16`: the selectability gate asks whether selection can see a trait's cost,
which is the wrong question here and reported a failure that was not there.

| | value | how it was obtained |
|---|---|---|
| the differential the change creates | **100%** | a creature that never reaches water leaves no descendants at all |
| **is that above the drift floor** | **YES, by fifteenfold** | floor is **6.72%** at the measured `Ne` of 7.44, `G.10` |
| **can a creature physically respond within one life** | **YES, ONE WAY** | mean life 10 ticks, one cell per tick, fare 22 against 117 earned |
| what share of the population could respond | **50% at 7 holes, 66% at 19, 86% at 37** | `scripts/can_they_reach_the_water.escript`, 12 seeds settled to 2,000 ticks |
| **can a creature perceive it** | **NOT YET — and that makes it part of this world** | `?FIELDS` is `[creatures, ground, scent, self]` and contains no water |
| what it costs in new constants | **one, the number of holes, and it is SWEPT** | every value published |

**⚠ A ROUND TRIP IS IMPOSSIBLE AND THAT IS WHY THE RULE IS SHAPED THIS WAY.**
Measured: at one hole the mean distance is 13 cells, and a creature that lives
ten ticks and moves one cell a tick **cannot get there and back at any
arrangement**. Thirst — a store that drains and must be topped up — would require
exactly that and is therefore unbuildable in this world. **A rule that requires
reaching water ONCE is affordable where a rule that requires reaching it
repeatedly is not.** That is a design decision the gate forced, and the first
version of this world would have been built without it.

### The representability check, which this world fails without a second change

**A requirement nobody can sense is a lottery, not a selection pressure.** World
16 is the register entry for pricing a shape the genome cannot express. If water
exists and no creature can perceive it, selection cannot favour going to water;
it can only kill whatever was born too far away. That is a **filter**, and the
gate above says a filter must be declared as one rather than reported as
adaptation.

So `water` is appended to `?FIELDS`, making it the fifth thing a sensor can
measure. This is inseparable from the rule rather than a second change, exactly
as world 15's mouth was inseparable from `eat`: a capacity nobody can act on is
not a capacity.

**⚠ APPENDED AND NEVER INSERTED.** `[creatures, ground, scent, self]` become
`[creatures, ground, scent, self, water]`. Those indexes travel on the wire
inside `kind_table` and
`the_wire_codes_for_fields_and_purposes_are_fixed_test` pins the order, because
reordering would silently change the meaning of every kind table ever published.
`I.6` with a wire between the instrument and the reader.

---

## Why there is a world 23

**`J.1`: a creature has exactly one requirement, so the scarcest thing is always
the same thing.** The register's own words: *"This world has ONE drive... Nothing
pulls against anything... So the brains are not being deleted for being too
small. They are being deleted because there is nothing to decide."*

Liebig's Law of the Minimum, 1840: organisms have several independent
requirements and the scarcest binds. This world has one, so there is a single
optimum — get more energy — and a brain has nothing to weigh against anything.

**`J.2`: the environment is not a participant.** Twenty-two worlds of creatures
have influenced their island only passively. Nothing a creature decides has ever
changed the place it lives in, and a static landscape has a finite number of ways
to make a living.

**And `G.10` says this is the only class of change that can be selected here.**
With the drift floor at 6.72%, every price this project has tweaked was
invisible: a mouth at 0.24%, an act at 1.34%, silencing at 10.6% and marginal.
**An environmental change that decides whether you breed at all is a 100%
differential.** Three worlds concluded a capacity was "expressible and unused"
and the common cause was never the capacity.

**It also composes with `D.7`.** Predation is suppressed by opportunity, not
economics: creatures get nought to one chances in a life because 54 to 84 of them
on 1,261 cells almost never meet. **Everything that breeds will now be at a
hole.** `what_would_a_waterhole_buy.escript` measured what concentration is worth
before any of this was built: the share of creatures standing on something
strictly smaller rises from 6.1% to **17.0% at threefold crowding and 38.5% at
tenfold**.

## The single change

**Breeding requires standing on a water cell.** Water is a fixed set of cells,
never consumed, never depleted. There is no thirst store, no drain, no death from
dryness and no new rule about any of those.

**ONE NEW CONSTANT, AND IT IS SWEPT: the number of holes.** Few big holes
concentrate hardest and are furthest away; many small ones are reachable and
concentrate least. **That tension is the experiment**, which `PLAN.md` named
before any of it was measured, and every value is published.

Holes are placed as rings from the centre outward, which concentrates most for a
given count.

## What would count as a finding

1. **Creatures evolve to sense water.** The `water` field is carried by more
   creatures than chance. **Instrument:** `body:census/1`, which already reports
   carriers, reach and attention per field. Exists.

2. **They evolve to move toward it.** Carrying a sensor and acting on it are
   different things, which is `world 16`'s entry. **Instrument:** mean distance
   from a breeder to its nearest hole, against the same figure for the population
   at large. **Does not exist and is part of this world.**

3. **Predation rises.** `D.7`'s prediction, made before the watering hole
   existed. **Instrument:** `from_creatures_pct`, already reported, against
   world 22's value on the same seeds.

4. **The frontier stops reaching zero.** The claim `J.2` is for.
   **Instrument:** `scripts/is_it_still_discovering.escript` against the recorded
   baseline of 42, 9, 3, 2, 1, 0, 0, 0, and
   `scripts/is_the_frontier_real_or_is_it_the_ruler.escript` to check the
   descriptor has not simply saturated again.

5. **Hidden nodes are carried more.** The conditional — go when you must, eat
   otherwise — needs a nonlinearity, which is `B.10` and `H.12`. This is the
   first world in which a brain has two things to weigh. **Instrument:**
   `hidden_mean`, already reported. ⚠ **And it is underpowered**: nodes run 0.16
   to 0.80 and only a twofold response is detectable, so a smaller one will be
   scored UNTESTED rather than absent.

## THE STALE INSTRUMENT GATE

| script | which rule it reads | last verified against it |
|---|---|---|
| `what_can_they_see.escript` | `?FIELDS` and `body:reading/4` | world 17, where it was `I.6`; **must be re-read: it will average over five fields where it averaged four** |
| `world_facts:world_charted/2` | `field_code/1` indexes into `body:fields/0` | world 20, pinned by a test; **appending is safe, inserting is not** |
| `sweep_senses.escript` | `?FIELDS` | world 17; same five-versus-four hazard |
| `behaviour.erl` | the three behaviour axes | world 22; water is not an axis and the archive keeps its 125 cells |
| `can_they_reach_the_water.escript` | fare, income, lifespan | **today** |
| `is_it_still_discovering.escript` | the archive | world 22, unchanged |

**And believe a test result only from `rm -rf _build`, whole.** `I.8`.

## What will NOT happen, stated in advance

**THE MOST LIKELY OUTCOME IS A FILTER RATHER THAN AN ADAPTATION, and the gate
above demands this be said.** At seven holes only half the population can reach
water within a life. If creatures do not evolve to sense and approach it, world
23 will simply kill everyone born too far out and select on birthplace. **That
would look like a result and would be a cull.** Finding 2 is the one that
separates them, and it is the reason a new instrument is owed before the sweep.

**Extinction is expected to rise, possibly sharply.** Half the seeds already die.
A rule that forbids breeding away from water can only reduce the number of
successful births, and at one hole it may kill every seed. **If every arm dies,
the sweep has measured a prohibition and not a tradeoff**, and the answer is more
holes, not a different conclusion.

**And the strongest negative, written so it cannot be reinterpreted:** if
creatures carry the water field at chance, breeders are no closer to water than
anybody else, and the frontier still reaches zero, then **a second requirement
does not give this world's brains anything to decide, and `J.1` is wrong.** That
would be a finding about the register's own central diagnosis and would be worth
more than a success.

## The commitments

1. Rules frozen before the first run. This file is superseded, not edited.
2. Every seed reported, including **nothing happened**, and including the dead.
3. `world:ruleset/0` says 23 in the same commit as the rules, and `WORLDS.md`
   gains its row **first**. Both were stale for three worlds; `I.15`.
4. `lineages`, `depth`, the uptake spread and **F_ST** reported beside the
   population.
5. New tests go red against world 22's physics before they are believed.
6. **No test names a swept constant by inheriting it.**
7. **A node config may name what a node IS and never what the physics ARE.**
8. **Finding 2's instrument is built and tested BEFORE the sweep runs.** `I.7`:
   a finding that names no instrument cannot fail, and it is the one that tells a
   filter from an adaptation.
9. **`water` is appended to `?FIELDS`, never inserted**, and the wire test is
   extended to pin the five-element order before the rule is written.
10. **Medians are taken over LIVING worlds, and the dead are counted separately.**
    A median over all seeds is dominated by graveyards: it read 21 cells where
    living worlds had reached 76, and it nearly confirmed a finding of mine by a
    factor of five on the strength of that.
