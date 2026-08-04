# Charter: the world is the sum of the nodes

**This exists so that adding a machine to the mesh adds land to a living world.**

Opened 2026-08-04. The track it replaces is closed and its reasons are in
[WHY_THIS_TRACK_CLOSED.md](WHY_THIS_TRACK_CLOSED.md).

---

## The one idea

**There is one world. Each node holds a piece of it, and migration is how the
pieces are one world rather than many.**

Every island so far ran its own private world and published pictures of it. Three
nodes meant three unrelated experiments. From here, three nodes mean **one world
three times the size**, and a fourth node enlarges it again.

Nothing is central. No node holds the world, no node is authoritative, and there
is no simulator that anybody could point at. **The world exists only as the sum
of what the nodes are doing**, which is the mesh-is-the-computer paradigm meant
literally rather than as a deployment story.

### The properties this buys, which are not metaphors

**A network partition is a geographic barrier.** Two groups of islands that
cannot reach each other are allopatric, and allopatric populations diverge. That
is not an analogy for speciation, it has the same consequence.

**A node going down is a regional extinction**, not an outage. The system
degrades biologically instead of technically, and the survivors recolonise.

**Latency, churn and topology become ecology.** Distance in the mesh is distance
on the ground. The network's real properties stop being an implementation detail
and become the terrain.

**And an empty island is recolonised rather than reseeded.** That single change
attacks the deepest problem the old track had, below.

## Why this is the first move and not a flourish

`Ne` was **7.44** against a census of 87.95, a ratio of 0.085. That put the drift
floor at 6.72% and made nearly every mechanism invisible. Three things drive it,
and a metapopulation answers all three:

| what depresses `Ne` | why it happens here | what migration does |
|---|---|---|
| small census | one island, 70 to 120 creatures | the world is every island at once |
| **huge variance in offspring** | most births die at age zero: 9 ticks per birth against 34 for the living | unchanged, and must be attacked separately |
| **bottlenecks** | `Ne` over time is a HARMONIC mean, and worlds crash constantly: 46 to 54 seeds of 64 die outright | recolonisation replaces reseeding-from-nothing |

**`accepts_migrants` has been on the wire since the beginning and has always been
false.** The hook was designed in and never used.

⚠ **And structure is not automatically a gain.** Too little migration and demes
drift apart independently, which lowers local `Ne` and makes things worse.
Migration rate is a swept constant and `F_ST` is already computed.

## The rules this track runs under

1. **A mechanism is chosen by its fitness differential against the MEASURED drift
   floor, before it is built.** Under the floor means do not build it, or raise
   `Ne` first. This gate already existed and failed only because it guessed at
   `Ne`.
2. **`Ne` is a live instrument, published every window.** If it falls below the
   level at which the pressure under study could be seen, **the run declares
   itself invalid** rather than producing a null that then gets interpreted.
3. **Give the plan, evolve the parameters.** Everything below the claim is
   scaffolding and is handed over. Everything at or above it must emerge, and the
   pre-registration says plainly which is which.
4. **One claim at a time.** World 23 bundled a rule, a new field and a new
   geometry, then could not attribute its own result.
5. **Smaller in code than what it replaces**, despite being richer in biology. If
   it is not, the old habits have been smuggled in.

## What gets built

**Body plan, given.** Sensors and actuators on the same channels, a gut, a size,
a brain whose input and output slots the plan fixes. What evolves: reach, gain,
thresholds, attention, brain topology and weights, gut allocation, body size.

*A sense is a `(medium, reach)` pair and nothing more.* Touch is reach zero,
smell is a diffusing field that decays, vision is long reach on a fast field,
hearing is long reach on a field that decays quickly. `body.erl` already had
`(field, range)`; this is that idea taken seriously.

⚠ **A fixed plan makes genomes alignable, which deletes a subsystem.** Historical
marking and outcross alignment existed to align genomes of different shapes.
World 22 added both and neither prevented convergence. Under a fixed plan,
crossover is meaningful without either.

**A channel a creature can write to.** One act: emit on a channel at an
intensity, into a field others can sense. Colour, voice and temperature are one
mechanism at different reach and decay, exactly as vision and smell are.
Emitting costs energy, so honest and dishonest signalling have an economics
rather than a stipulation.

**Geography, tuned as a migration knob.** Barriers and occupancy, one creature to
a cell, so space is genuinely contested. Chosen by its measured effect on `Ne`
and `F_ST`, never for how it looks. World 23's lesson is that imposed geography
culls.

**Excretion.** A creature that eats here and voids there moves nutrients across
the map, and the landscape becomes a product of behaviour that feeds back on
where feeding is worth doing. Water holes were an environment imposed on
creatures and produced a cull; this one is made by them.

## Carried over, and dropped

**Carried:** the pre-registration discipline, the physics register and its `I`
entries, behaviour descriptors and the archive, the census, `Ne` measurement, the
wire rules, the boundary guards that compare two sides rather than one.

**Dropped:** NEAT marks and outcross alignment, obsolete under a fixed plan.
Thirst, which measurement showed to be a size filter and not a distance rule.

**Flagged re-testable, not dead:** memory. It cost more than it returned at
`Ne` 7.44, which is a population where its size could not have been seen.

## Order of work

Classified, because the rule is to say it out loud.

| # | work | kind | why in this order |
|---|---|---|---|
| 1 | substrate: metapopulation, migration, geography, body plan, channels | **BUILD** | asserts nothing about the world; tests and a commit, no gate |
| 2 | **"migration raises `Ne` above the drift floor"** | **CLAIM** | every later result depends on this being true |
| 3 | **"signalling emerges and clears the floor"** | **CLAIM** | the first mechanism proposed here whose differential is plausibly an order of magnitude above the floor: predation is 38% of deaths, and a call that changes whether you are eaten is worth far more than 7% |

**The first experiment is not about creatures. It is about whether the world can
select anything at all.**

## Owed before any of it starts

- **A migration protocol.** A creature crossing between nodes is live state on
  the wire, not an observability fact. Serialisation, an arrival handshake, and
  lineage identity that survives the crossing.
- **A ruling on time.** Islands tick at their own pace. The simplest answer, and
  the one that is also biologically honest, is that **time is local**: a migrant
  is ticked by whatever island now holds it.
- **A ruling on the record.** A world spanning nodes is not a pure function of a
  seed and cannot be replayed. **The event store replaces replay**, which is what
  ReckonDB is for and what the notebook slice already does.
- **Trust.** A hostile node can inject creatures. Realm identity exists; naming
  the problem is in scope here, solving it is not.

## History

Numbering continues rather than restarting. The register cross-references
`G.10`, `I.21` and the rest from everywhere, and a clean slate in the numbering
would break the one asset worth keeping. **The break is marked in `WORLDS.md`,
not hidden by starting again at one.**
