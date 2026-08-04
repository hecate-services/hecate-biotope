# Why this track closed

**This exists so the next world does not repeat twenty-four of them.**

Closed 2026-08-04, after world 24. Nothing here is deleted: `WORLDS.md`,
`PHYSICS_REGISTER.md` and every `RESULTS_*` file stand as written. This says what
they add up to.

---

## The finding, and it is a real one

**At an effective population of 7.44, this world cannot select anything cheaper
than 6.72%, and nearly everything interesting is cheaper than that.**

`Ne` was measured once, late, at world 22, against a harmonic census of 87.95.
Every gate before it had guessed. Measured, the drift floor is `1/(2·Ne)` =
**6.72%**, and every price this project ever tuned sits under it:

| what was priced | differential | against a floor of 6.72% |
|---|---|---|
| a mouth, world 15 | **0.24%** | 28x too small to see |
| an act, world 18 | **1.34%** | 5x too small |
| silencing, world 19 | **10.6%** | above it, and marginal |

**Three worlds concluded a capacity was "expressible and unused", and the common
cause was never the capacity.** It was that nothing on offer was worth more than
noise to a population of seven.

That is not a failure to produce a result. It is a result about what a
small-population world can be asked.

## Four hypotheses, refuted on their own pre-registered criteria

| | claim | verdict |
|---|---|---|
| `J.1` | brains stay small because the world asks ONE question | **REFUTED**, world 23. A second requirement gave them nothing to decide: water carriers 0-2%, approach 0-3% against a control of 4%, and the ways of living explored FELL from 81 to 64. |
| `H.13` | a longer life buys computation | **REFUTED**, and worse: lifespan turned out not to be controllable. Driving metabolism from 20 to 1 makes life SHORTER, 11.46 to 8.83. |
| `B.10` | memory pays | **REFUTED**, world 21. A row gained one live weight per node, so memory did not fail to be used, **it made computation less affordable to have.** |
| `D.7` | concentration raises predation | **REFUTED**, world 23. Predation FELL, 9% to 2-5%. |

Each was written down before the run, with the instrument named and the negative
stated so it could not be reinterpreted. That discipline is the most valuable
thing built here and it transfers whole.

## Two structural admissions

**The baseline stayed at world 1 while the questions moved to world 20.**
`body.erl` records why world 1 was deleted: *"a world whose rules contain `eye`
cannot discover that seeing was worth doing."* Sound, when the claim is about
seeing. By world 15 the questions were about whether brains grow and whether
discovery stops, and under those questions sensors are scaffolding. **The search
budget went on re-deriving sensors instead of studying anything above them.**

**No act ever wrote to the world.** Four purposes: move, breed, grow, eat. Every
one acts on the creature itself or on what it consumes. Scent exists as a passive
signature, never as something a creature chooses to emit. So **signalling was
never expressible, and by world 16's own logic its absence was never evidence of
anything.** Deception, alarm, mimicry and cooperation were unreachable in every
world built here, and nobody noticed for twenty-four of them.

## What is NOT claimed

- **Not** that artificial life is impossible, or that neuroevolution does not
  work. This is a measurement of one world's `Ne`, not of the field.
- **Not** that the mechanisms are wrong. Memory, recombination, historical
  marking and a second requirement were each tested at a population where
  nothing of their size could have been seen. **They were not refuted so much as
  never given a fair test**, and the register says so in each case.
- **Not** that the negative results are weak. `J.1` was the register's own
  central diagnosis and it fell on a criterion written before the run. That is
  worth more than a success.

## What the process cost, and what it taught

Eight entries in the register are about how the work went wrong rather than about
the world, and they were the expensive part:

| | |
|---|---|
| `I.15` | an edit that matches nothing is indistinguishable from an edit that worked; `ruleset/0` reported world 19 for three worlds |
| `I.17` | "a round trip is impossible in one life" turned into "thirst is unbuildable", which does not follow, and produced a rule requiring creatures to breed while standing on water |
| `I.18` | the stale-instrument gate said "today" about a script that was already dead |
| `I.19` | every selectability gate used a birth-weighted lifespan, which describes newborns and is 3-4x smaller than the age of a creature that is actually alive |
| `I.20` | a test timeout was read as a crash, and its stack trace believed; the elapsed time was exactly 5.000s every run |
| `I.21` | a constant chosen on viability outlived the geometry it was swept under |

And one that was found five times in a single day: **a field computed by
`chart/1` or `snapshot/1` and never put on any wire.** `structures` was dropped
for four worlds, so a renderer that sizes a creature by its body never once had
the number. `water` was the entire subject of world 23 and reached no reader at
all. `senses`, `nodes` and `parched` followed. Each function was correct on its
own; the gap between them was not.

**The lesson is procedural and it is carried forward: a guard that compares two
sides of a boundary finds what a test of either side cannot.**

## What is worth keeping

- **The pre-registration discipline.** Named instruments, a stated negative, and
  a selectability gate. It refuted four of my own hypotheses.
- **The physics register.** Every finding and every error, with why.
- **The instruments**: behaviour descriptors and the archive, the census,
  portraits, `Ne` measurement, the wire-rules tests.
- **The wire discipline**: atom keys, no tuples, integers not floats, appended
  never inserted, and a fact version that moves on an append.

## Where it goes

[CHARTER.md](CHARTER.md). The world becomes the sum of the nodes, migration
becomes foundational, the body plan is given rather than re-derived, and there is
a channel a creature can write to.

**The first experiment there is not about creatures at all. It is about whether
the world can select anything.** That is these twenty-four worlds turned into a
first step.
