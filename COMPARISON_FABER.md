# hecate-biotope against faber-{tweann,neuroevolution}

**This exists so we stop maintaining two systems by accident.** Written 2026-08-03
after the question "is biotope even using the mechanisms built into faber, and why
not" — a question I had already answered twice, both times wrongly, by reading
`src/*.erl` and not the subdirectories.

## The timeline, because it decides how bad this is

| | |
|---|---|
| `faber-neuroevolution` last commit before biotope | **2026-07-29** |
| `hecate-biotope` first commit | **2026-07-31** |
| `faber-tweann` last commit | **2026-07-31**, the same day |

This was not a long-dead project being superseded. Work on faber stopped two days
before biotope started, and faber-tweann was live that same day.

## Size

| repo | source lines |
|---|---|
| faber-neuroevolution | 57,901 |
| faber-tweann | 20,428 |
| hecate-biotope | 6,030 |

## What each system actually is

**faber-tweann** — a TWEANN engine. Genotypes, NEAT innovation numbers, genome
crossover, and phenotypes built as **one Erlang process per neuron**
(`neuron.erl` spawns).

**faber-neuroevolution** — a population trainer over those genotypes. It has a
generational or steady-state loop, explicit **fitness**, and a strategy behaviour
(`evolution_strategy`) with implementations for generational, steady-state,
island, **novelty search** and **MAP-Elites**. On top sits the "Liquid
Conglomerate": thirteen *silos* that adaptively tune the search.

**hecate-biotope** — a continuous ecological world. No fitness function, no
generations, no selection step: creatures forage, breed and starve, and every
role is counted afterwards. Brains are pure integer arithmetic evaluated inside a
fold.

---

## The three decisive technical facts

These are the ones that determine whether a port is possible, and each was
checked in the source rather than inferred.

### 1. The domain SDK fixes the network's I/O width at compile time

`agent_definition:network_topology/0` returns `{Inputs, HiddenLayers, Outputs}`,
e.g. `{29, [32, 16], 9}`. Sensors and actuators are **modules** with a fixed
`input_count/0` and `output_count/0`. `agent_bridge` validates the two agree and
**throws `topology_mismatch`** if they do not.

**Biotope has no such number.** Which sensors a creature carries, how many, and
at what reach, is the thing being evolved, per individual, per birth. Two
creatures alive in the same world at the same instant have different input
widths. There is no population-wide I/O to declare.

This is not a detail to work around. The SDK models *an agent type with a fixed
sensor suite whose network evolves*. Biotope models *a population in which the
sensor suite itself is what evolves*.

### 2. A phenotype in faber is a process graph; in biotope it is a list of integers

`neuron.erl` spawns a process per neuron. Biotope evaluates a brain about
**eleven times per creature per tick** — seven of them for cells it is only
considering stepping into — as inline integer arithmetic.

⚠ **My earlier objection to this was wrong and I withdraw it.** BEAM processes
are ~300 bytes and hundreds of thousands are routine; at ~70 creatures a world
would need ~700 processes. The cost is message volume per evaluation, not the
process table, and it would be a factor, not an order of magnitude.

⚠ **My second objection was also wrong.** I said determinism blocked reuse.
`agent_environment` declares **`is_deterministic() -> boolean()`** as a callback.
faber already accounts for deterministic environments.

### 3. Every strategy assumes fitness and a selection step

`evolution_strategy` callbacks are `handle_evaluation_result/…`, `tick/1`,
`get_population_snapshot/1`. `novelty_strategy` takes
`#{fitness => F, metrics => #{behavior => [float()]}}`.

Biotope has **no fitness function and no generation boundary**. Nothing scores a
creature. Selection is that you starve.

`novelty_strategy` can run at `fitness_weight = 0`, so it does not *need* a
meaningful fitness — but it still needs a population to select from at a moment
in time, which biotope does not have.

---

## Genuine duplication: the same thing, built twice

| biotope | faber | verdict |
|---|---|---|
| `outcross.erl`, written 2026-08-03 | `genome_crossover.erl`, `innovation.erl` | **Real.** Different genome representations, so the code is not literally reusable, but the *design work* — how to align two genomes for recombination — was done twice. faber solves hidden-node alignment with innovation numbers; biotope aligns sensors by `{field, rank}` and admits in its own comments that hidden nodes align only by position. **faber has the better answer to the weaker half of mine.** |
| the three-node fleet | `island_strategy.erl` | **Real.** `island_strategy` has *zero* genome dependencies — ring/full/random migration topologies, `handle_migration/…`. Biotope's islands do not migrate at all yet, and this is what would implement it. |
| nothing | `checkpoint_manager.erl` | **Real gap.** Biotope has no persistence of any kind. A restart loses the world. |

## Apparent duplication: same words, different level

⚠ **I overstated this in conversation and am correcting it here.** Several faber
modules share biotope's vocabulary and operate on a completely different object.

| looks like a duplicate | what it actually is |
|---|---|
| `economic_silo` — "energy accounting, income/expenditure, bankruptcy" | The **compute budget of the search process**, per individual, with a time constant τ=20. Not an in-world energy economy. Biotope's energy is the *physics*; this is the *optimiser's* housekeeping. |
| `ecological_silo` — "niches, resource competition, carrying capacity" | Niche formation among **networks in a population**, tuning the search. Not creatures in a place. |
| `species_registry`, `agent_species` | **Explicitly declared** species: user-written modules, each with its own topology and fitness ("Foragers", "Predators"). Biotope's `kinds` are **emergent** — an architecture nobody declared, censused after the fact. faber documents a "Level 2" emergent speciation as well, so the gap is narrower than the words suggest, but `species_registry` is keyed by module and is not a census of what evolved. |
| `multispecies_environment:handle_interaction/3` | Genuinely close to biotope's predation, but between *declared* species. |

## Present in faber, absent from biotope, and worth having

1. **A novelty archive.** `novelty_strategy` and `map_elites_strategy` both keep
   an archive of behaviours seen. Biotope computes `kinds` every tick and throws
   it away. An archive of every architecture ever seen is the operational
   measure of whether the system is still discovering or has converged — which
   *is* open-endedness, measured.
2. **MAP-Elites.** Quality-diversity over a behaviour space. Biotope's `kind`
   is already a behaviour descriptor in all but name.
3. **Migration.** Islands that exchange individuals.
4. **Checkpointing.**
5. **Innovation numbers**, which solve the alignment weakness in `outcross.erl`.

## Present in biotope, absent from faber

1. **No fitness function at all.** This is the one genuinely novel commitment,
   and it is the thing novelty search was invented to *approximate*. Everything
   in faber takes a fitness; biotope has none to take.
2. **Morphology as the evolving unit.** Not weights inside a declared topology:
   *which organs exist* is the genotype.
3. **The physics register and pre-registration discipline.** A method, not code.

---

## Recommendation

**Do not port biotope into the faber domain SDK.** Fact 1 makes it a rewrite, not
a port: the SDK's central assumption is a fixed I/O width and biotope's central
claim is that there isn't one. Forcing it would delete the interesting property.

**Do take four things from faber, in this order:**

| # | what | cost | why first |
|---|---|---|---|
| 1 | **The archive**, as an instrument and never as a selector | S | It is the only measure of open-endedness we lack, it needs no change to selection, and biotope already computes the descriptor. |
| 2 | **`checkpoint_manager`** or ReckonDB in its place | S | A restart currently destroys a world. |
| 3 | **`island_strategy`'s migration** | M | Three islands that never exchange anything are three experiments, not a fleet. |
| 4 | **Innovation numbers**, per world, carried in the world record rather than ETS | M | Fixes the hidden-node alignment `outcross.erl` documents as its own weakness. |

**And settle the direction of travel explicitly**, because the two repos have
been drifting for four days:

- biotope is a **domain**: a world with physics and no objective.
- faber is an **engine**: population methods that need an objective, or an
  explicit archive in place of one.

They meet at the archive and at migration, and nowhere else without one of them
giving up what makes it what it is.

## What I got wrong, recorded so it is not repeated

1. Told you faber-neuroevolution was "an app and a supervisor" — it is 57,901
   lines, and I had listed only `src/*.erl`.
2. Told you process-per-neuron made reuse impractical — the cost is message
   volume, and at ~70 creatures it is a factor and not a barrier.
3. Told you determinism blocked reuse — `agent_environment` has an
   `is_deterministic/0` callback.
4. Then overstated the duplication in the other direction, calling the economic
   and ecological silos duplicates of biotope's economy and ecology when they
   operate on the search rather than on the world.

The rule that should have caught all four is in `CLAUDE.md`: *"When the source
code of a dependency is available, ALWAYS do a deep study before using it"*, with
*"guess at API from function names"* named as the anti-pattern.
