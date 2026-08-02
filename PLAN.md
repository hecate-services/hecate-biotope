# Plan

**REVISED after phase 0 and world 15.** The original order is below and mostly
stands; what changed is at the top, because the session produced one insight that
reorders everything.

## What the measurements changed

**Every price this project has ever levied that MOVED anything was proportional
to the body. Every price that scaled with an organ did nothing.**

| price | scales with | what happened |
|---|---|---|
| world 5, carrying | **structure**, 300 to 500 | size hard-bounded |
| world 12, the fare | **structure** | bodies capped tenfold |
| world 13, organs as tissue | a sensor, gained **whole** at 10 a tick | sensors 0.01 to 3.27 |
| world 15, the mouth | drifting in steps of **8**, worth 0.24 a tick | nothing |

A creature earns 87 to 231 a tick and spends 18 to 35, so **the whole cost side of
this world is a rounding error against income.** Drift beats selection below about
1% of income, which is 1 unit a tick, which is a tissue step of about 33. A sensor
clears that comfortably because it arrives whole. A mouth mutation is 0.24% and
does not.

**So the register has spent five worlds pricing organs while the thing that
determines whether a price is visible is the size of the MUTATION, not the size of
the organ.** That is `H.10`, it is measured, and it predicts which future traits
will be selectable before they are built.

**And pricing cannot fix the thing the project is actually stuck on.** The
register's own diagnosis is that brains are deleted because there is nothing to
decide. `H.10` says a price determines whether a trait is VISIBLE to selection,
never whether it is USEFUL. Fifteen worlds of pricing have produced no lasting
computation, and no sixteenth price will.

## Status, 2 August

**Phase 1 is done.** The join blocker is fixed (`c1c903e`), `accepts_migrants`
rides on every fact defaulting to false, and the join page is live with a `+` on
the biotope grid. A stranger can run an island today.

**R.1 to R.5 below are the next high priority and none is started.** They come
from measurements taken this session and are ordered by what they cost against
what they unblock. `R.1` is an hour and prevents the failure that cost world 15.

## Revised order

| # | Package | Why now | Kind | Size |
|---|---|---|---|---|
| R.1 | **Make `H.10` a gate.** The pre-registration template gains one line: any world adding a heritable trait states its per-mutation cost as a share of measured income and shows it clears ~1%. | It would have saved world 15 entirely, and it costs an hour | BUILD | XS |
| R.2 | **Fix `H.8`.** A `self` sensor pays for reach that `spatial/1` says is never read. | A straight defect, unambiguous, in the difference between two functions | BUILD | XS |
| R.3 | **Decide `H.9`.** A hidden node costs the same whatever it reads, which `B.3` objected to and world 13 did not fix. | **This one is about brain complexity directly.** Charging by fan-in makes a big brain properly expensive and a small one cheap, which is the shape every real neural economy has | CLAIM | M |
| R.4 | **Make the mouth selectable, then re-run world 15.** Sweep the mutation step rather than choosing it. | Not for the trophic split. Because it is the only route to a genuine conditional decision, which is what a hidden node is for | CLAIM | M |
| R.5 | **`H.7`, price the actuators.** Every organ here is priced and every act is free. **GATE RUN 2026-08-02, `scripts/can_an_act_be_priced.escript`: buildable ONLY with the rate swept well below `neural_cost`.** Charging an output by its wiring at `neural_cost` costs 28.4% of income per output and 94.7% for the complement a creature carries, which bans acting rather than pricing it. `H.10` gained a roof because of this. | Largest unpriced thing left, and the gate has now told us the one way to build it that cannot work | CLAIM | L |

**Phase 1 onward below is unchanged and still wanted.** The join blocker is still
an hour and still unblocks other people.

---

Everything discussed, in the order I would do it, with sizes so any of it can be
vetoed cheaply.

Each package says what it is, which end goal it serves, whether it is a **CLAIM**
or a **BUILD**, and roughly how big. A CLAIM is an assertion about the world that
could be wrong and gets a pre-registration frozen before the run. A BUILD is
plumbing and gets tests and a commit. Confusing the two is how a week disappears.

Sizes: **XS** an hour, **S** a sitting, **M** a day, **L** several days.

---

## Phase 0. Pay the debts first

Three things are owed, two of them scientific, and all three are cheap. A
published result currently rests on a confound I named and did not test.

| # | Package | Goal it serves | Kind | Size |
|---|---|---|---|---|
| 0.1 | **Settle the horizon confound.** Re-run the `neural_cost` sweep under world 14 at **2,000** ticks and compare against the 20,000-tick result. World 13's sweep ran to 2,000, so the claim "computation is higher under world 14" is currently indistinguishable from "we ran it ten times longer". | Knowing whether the one surviving result of the brains experiment is real | CLAIM (a control for an existing claim, criteria already fixed by the original) | S |
| 0.2 | **Register section H: the agency audit.** Enumerate every event in the world against whether a creature can perceive it and whether it can choose it. Three actuators against six things that simply happen, and one row with no sensor at all. | Finding the next several worlds by enumeration instead of by guessing | BUILD | S |
| 0.3 | **Correct `D.2`.** Its stated remedy calls the mouthless creature a herbivore. There are no plants; it is an absorber. This world has exactly two trophic levels and the wording hides that. | Not building on a wrong word in the register | BUILD | XS |
| 0.4 | **Measure kin structure.** Scent similarity *within* a lump against *between* lumps. Births are local and lumps persist a hundred generations, which is Hamilton's condition, and we have never looked. | Whether group structure already exists without anyone installing it | CLAIM | S |

---

## Phase 1. Let other people run an island

| # | Package | Goal it serves | Kind | Size |
|---|---|---|---|---|
| 1.1 | **Fix the join blocker.** `biotope_mesh:endpoint/0` requires a fleet realm and then discards it, so a stranger cannot publish without a secret they cannot obtain. When `HECATE_BIOTOPE_REALM` is set, the fleet realm should not be needed. | A creature evolving on a machine we do not own | BUILD | XS |
| 1.2 | **`accepts_migrants` on every fact**, defaulting to false. State on the fact rather than a separate `island_opened` event, because an island that announces itself open and then crashes leaves a record saying open for ever. An observer derives the transitions. | Honest onboarding copy, and the prerequisite for invasion | BUILD | XS |
| 1.3 | **The join page.** A `+` on the biotope grid leading to install, configure and run instructions, a choice of stations, and terms. | Same as 1.1 | BUILD | M |

**Terms, five points and no legalese.** Your island publishes what it is doing to
a public topic and anyone can read it. What is published is about the creatures,
plus the island name you choose and which station you dial, not about you. It is
outbound only: no inbound ports, no account, no key from us. Islands will
eventually exchange migrants, **opt-in and not yet built**, which is the honest
thing to say rather than implying it already happens. Worlds die, often within
the hour, and that is a result rather than a fault.

**The ask is a node, not money.** That matches the three asks the site already
makes. Money second, and say plainly there is no funding and no company.

**Stations must not be rendered as places.** `station-de-frankfurt` spent a long
time physically in Nuremberg. Offer the identities and say what they are.

---

## Phase 2. The island's own web UI

| # | Package | Goal it serves | Kind | Size |
|---|---|---|---|---|
| 2.1 | **Observe and configure locally.** Name the island, set the pace, choose a station, watch your own disc. `hecate_om` already serves HTTP for `/health`, so this extends a surface rather than adding a server. | An owner who can run an island without reading our config files | BUILD | M |

**The genome browser waits for Phase 4**, because it needs the wire format.

**One hard line.** Viewing genomes is free. **Editing one is not**, because the
moment an owner can hand-write a brain, that island stops being an experiment and
every claim from it is void. If it is ever built, the island must declare it on
every fact so a reader can exclude it. Same principle as `world:ruleset/0`: the
label travels with the thing. Not now, and not without that flag.

---

## Phase 3. The mouth

**The highest-value change on the table, and it goes before the genome format so
the format is frozen with it already in.**

Every creature currently occupies both trophic levels at once for free: it
absorbs from the ground, and it also consumes anything smaller with no organ and
no decision. Splitting them creates the first genuine niche in fourteen worlds.

| # | Package | Goal it serves | Kind | Size |
|---|---|---|---|---|
| 3.1 | **Pre-register.** | | CLAIM | S |
| 3.2 | **A mouth is tissue and `eat` is an actuator.** The organ is charged by weight like any other apparatus, which is world 13's rule already, so **the tradeoff arrives with nothing designed into it**: a mouth pays only where there is enough prey to cover its upkeep. That is density dependence out of arithmetic, and being common is what makes mouths pay. | `G.4`, `D.2`, and giving a brain its first genuinely conditional decision | CLAIM | L |

**What this unlocks without naming it.** Do not add a `flee` output and do not
add a `fight` output; those would be world 1's `hunt` again. `move` already
exists. What becomes optional is *eating*, and fight-or-flight falls out: a
creature that perceives something larger can weigh going away against staying,
and that is `self` multiplied by `creatures`, which is exactly the interaction a
hidden node is for and the one this register has been hunting since world 2.

**Be awake to the consequence.** If eating is a choice, a large creature that
declines leaves the small one alive. Being large stops being automatically lethal
to your neighbours and the contest changes shape. That is real physics, not a
bolt-on.

---

## Phase 4. The genome as a first-class thing

| # | Package | Goal it serves | Kind | Size |
|---|---|---|---|---|
| 4.1 | **Genome wire format.** CBOR-safe encode and decode with validation against the receiving island's caps. A body is a list of `{Field, Range}` **tuples** and macula rejects tuples outright, so nothing can be sent until this exists. Round-trip tested; an arriving genome is untrusted input and one malformed migrant with ten thousand sensors must not take a node down. | Invasion, the genome browser and ONNX export all need exactly this | BUILD | M |
| 4.2 | **ONNX export.** A downloadable brain that loads in onnxruntime or a browser. | Fourteen worlds of evolved brains, portable to people who will never run Erlang | BUILD | M |
| 4.3 | **Genome browser in the UI**, plus a hall of fame: deepest lineage, largest creature. | An owner who can see what their island made | BUILD | S |

**Why the genome is not ONNX.** ONNX encodes the brain's forward pass and nothing
else, and even for the brain it loses which input column *means* `ground at reach
2`. Mutation edits genome structure, so storing a flattened graph means
reverse-engineering it back before you can breed from it. A genome here is about
fifty integers and **the protobuf header alone is larger than the payload**.
Native on the wire, ONNX on the way out.

---

## Phase 5. Invasion

**Last, deliberately.** It is a BUILD and "too early" is the wrong axis, but it
should arrive after the mouth so migrants carry a stable genome, and after the
genome format exists at all. It also has a cost nothing else here has.

| # | Package | Goal it serves | Kind | Size |
|---|---|---|---|---|
| 5.1 | **`migrant_departed` and `migrant_settled`.** Two facts, not one: the sender's claim that it removed a creature and this much energy, the receiver's that it took it. **The gap between the two sums is the loss and it is visible to anyone.** Addressed to a single island, because on a shared topic with no addressing two islands could accept the same migrant and **create energy from nothing**. | `G.1`, which names invasion as the answer to its own problem | BUILD | L |
| 5.2 | **Accounting.** `emigrated` and `immigrated` on the books. A migrant nobody settles **has died in transit and its energy dissipates**, which needs no acknowledgement protocol and reuses an account that exists. | The First Law as a cross-island invariant | BUILD | M |
| 5.3 | **Subscription.** The island stops being publish-only, which changes `identity_spec`. There is already a test asserting the spec covers exactly what is published and no more. | | BUILD | S |
| 5.4 | **The observer closes the books.** The site sums across the fleet, keyed on `(island, run)` because an island that returns having begun a new world resets its totals. | Anyone can verify the ecosystem conserves energy from public facts alone | BUILD | M |

**The cost, stated so it is chosen rather than discovered.** The fleet configs say
the three islands are three runs of one experiment, and that is what makes
seed-to-seed comparison mean anything. **Connect them and they are one system.**
Migration must be opt-in per island so some stay isolated as controls, otherwise
the first thing invasion costs is the ability to say anything about seeds.

**And the global books only close over a window in which the set of live islands
is stable.** An island dark but alive keeps its energy and the observer's sum is
simply wrong until it speaks; an island dark for ever strands its energy unless
it is written off after some interval. That is a property of a federated system,
not a flaw to engineer away, and it should be stated rather than discovered.

**The open list is also a trust list.** Once strangers can join, an island's books
are only as trustworthy as the island, and someone could publish an emigration of
a million. That is *detectable*, which is most of what matters, but accepting a
migrant is opt-in and the list of islands you accept from is doing that second
job whether or not it is designed for it.

---

## Phase 6. Making the work findable and interpretable

**Both of these are owed, both are mostly assembly rather than invention, and
neither is a CLAIM.** Nothing here asserts anything about the world; they change
who can read what the world already said.

| # | What | Why | Kind | Size |
|---|---|---|---|---|
| 6.1 | **A Notebook on beam-campus-net.** The site already has the ELI5 Notebook pattern under `/research`. This research currently lives in **twelve `RESULTS_*.md` files, a physics register with nine sections and a plan**, none of which a visitor can find or would read in order. | Seventeen worlds of results that nobody outside this repo can reach | BUILD | M |
| 6.2 | **An event stream, so the fact feed becomes a narrative.** | An interpreter, human or LLM, that can say what HAPPENED rather than what IS | BUILD | M |

### 6.1 The Notebook, and what makes it hard

**It is not a table of contents.** The material is already organised by world,
and by world is the one order a newcomer cannot use: world 12 is unreadable
without world 5, and the register's letters cut across all of it.

**Three spines, and the choice between them is the whole design decision:**

| spine | reads as | costs |
|---|---|---|
| by world, 1 to 17 | a lab notebook, chronological, honest | nobody starts at world 1 |
| **by question** | "why do brains never appear", "why does one lineage always win" | needs the register re-cut, which is real work |
| by register entry | complete and already written | it is a reference, not a read |

**Recommendation: by question, with the worlds as evidence underneath.** The
project's best material is the negative results and the process failures, and
those only make sense as answers to a question somebody actually has.

**Four questions that already have answers**, each of which is a page:

1. **Why do brains never appear?** `H.10`, `H.11`, `H.12` and the behavioural
   test. The answer is not "they are useless", it is three separate
   demonstrations that this world could not express what was being asked for.
2. **Why does one lineage always win?** `G.1`, Kingman, the F_ST result, and
   lumps that turned out to be families.
3. **What does it cost to be wrong carefully?** The instrument section `I`, six
   failures of one shape, and `G.6`, which invalidated seventeen worlds of exact
   numbers and was found by one failing test.
4. **What is a world here?** The energy books, the First Law as a test rather
   than a claim, and a seed that reproduces exactly.

**Prerequisite, and it is small**: the site takes facts off the mesh and has no
access to this repo's markdown. Either the Notebook is written in
`beam-campus-net` and drifts, or it is **generated from this repo at build
time**. Generated. `I.6` is what a second copy of a truth does.

### 6.2 The event stream

**The fact feed is a CENSUS and an interpreter needs a NARRATIVE.** Today a fact
says `83 creatures, F_ST 61, depth 468`. It has never once said *a lineage that
held the north patch for two hundred generations was displaced*.

**Nothing emits events**, and that is the whole of the work. The world computes
every transition it would need to report and then throws the difference away,
because `snapshot/1` is a state and a state cannot say what changed.

**The shape, and it follows the rule this project already uses for the mesh:**
domain events stay local, and something decides explicitly what is worth
saying. An event is not a diff of two snapshots. A diff would emit thousands a
tick and say nothing.

**Six candidates, each already computable from state the world holds:**

| event | already computable from | why it is worth saying |
|---|---|---|
| `world_ended` | `extinct_at` | already logged, never published as an event |
| `lineage_lost` | `lineages` falling | `G.1`'s whole subject, currently visible only as a number going down |
| `lineage_fixed` | `lineages` reaching 1 | the moment a world becomes a monoculture |
| `patch_taken` / `patch_lost` | lump membership over time | the `RESULTS_LUMPS` finding, which no fact has ever carried |
| `organ_gained` / `organ_lost` | `sensors_gained`, `sensors_lost` | the counters exist and only their totals are published |
| `record_set` | deepest lineage, largest creature | what a hall of fame is made of |

**Two things to get right, both of which this project has been bitten by:**

- **An event is a claim about a transition, so it needs the tick it happened at
  and the run it belongs to.** `(island, run)` already keys the fleet's books
  because an island that begins a new world resets its totals.
- **Bounded.** A world that loses forty lineages in thirty ticks must not emit
  forty facts a second. Aggregate within a tick or do not emit.

**And it unblocks the thing nobody has asked for yet**: with events, an LLM can
be handed a world's history and asked what happened in it, which is the only
form in which this material is ever going to reach anyone who is not already
reading the register.

## Not scheduled

- **Backfill `:world-N` image tags** for worlds 1 to 13 by building from the last
  commit of each. Nice to have, nobody is blocked. **XS each, fiddly.**
- **Decide `A.6`.** World 14's floor is exactly zero below a neighbourhood mean of
  34, from integer division and not from choice. Measured at 1 to 4% of the board
  so it is not binding today. Adopt it deliberately or remove it. **XS.**
- **Scent has no actuator.** Marking is a side effect of moving, so a creature
  cannot choose to leave a trail or suppress one. Same shape as the mouth, much
  lower value.
- **No sensor for age.** "Breed before you die" is unreachable as a strategy,
  which is worth sitting with given `max_age` is 600.
- **Shrinking is not a decision.** `grow` is clamped at zero, so a creature can
  build but never deliberately catabolise.

---

## The one thing I would change about the order if pushed

Phase 3 before Phase 1. The mouth is the change most likely to produce something
worth showing other people, and inviting strangers to run world 14 means inviting
them to run a world we are about to replace. Against that: 1.1 is an hour, and
people running islands generates the long-baseline data that produced the lumps
finding, which no offline sweep would ever have found.
