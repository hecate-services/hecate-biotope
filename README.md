# hecate-biotope

**This exists so creatures can live, eat, breed and die on a node you do not own.**

A biotope is one island. It holds a bounded world with its own local conditions,
an open population of creatures whose bodies are assembled from organs, and an
energy economy that decides which of them get to reproduce. One biotope per node.
Islands meet later, by exchanging migrants over the mesh.

## Status: scaffold, and honest about it

The service boots, joins the mesh, answers `/health`, and holds no world. There
is no creature, no organ, no world tick and no evolution in this repository yet.

That is the intended order of work. The release, the image, the CI pipeline and
the deployment descriptor are tedious to retrofit and dull to write; the world is
the interesting part. Doing the dull end first means the interesting end is never
blocked waiting for it, and every increment from here lands on a running node
instead of on a laptop.

It announces no capability and asks the realm for no authority, because it can do
nothing yet. Both lists grow when the thing they name exists. Advertising
`biotope.receive_migrant` before anything can receive a migrant would put a lie
on the mesh where another service could find it and call it.

## What is coming, and in what order

The design is settled to the point below and no further.

**The energy economy comes first, before a single organ.** Four numbers decide
whether anything interesting happens: where energy enters the world, what it
costs to *have* an organ, what it costs to *use* one, and what a creature does
with a surplus. The standing cost per organ is the one that matters and the one
usually left out. If organs are free to own then every creature grows every
organ, the omnivore always wins, and dietary roles never appear no matter how
long it runs.

**A body is a collection of organs; a brain is a neural network.** Organs are
grouped by what they are for rather than by modality: motion, feed, combat,
senses, transport. Every sense is bidirectional, so smell has both a sensor and
an actuator, which makes a pheromone a thing a creature can learn to leave and
another can learn to read.

**An organ is a behaviour, not a process.** Write the organ once as a module with
a pure sense or act function, and let the runtime be either a supervised process
in the live world or a plain call in a loop when many lifetimes have to run
headless. The organ author does not know which they are in.

**The population is open.** Creatures are born, eat, starve and die inside the
world; nothing external decides who reproduces. This is the configuration that
collapsed in the Flatland experiments, and it collapsed for a reason that an
organ budget removes: there, the only way for a predator to stop over-consuming
was to stop eating, so restraint and starvation were the same act. A creature
that can shift its diet has a middle to occupy.

## Provenance

The shape comes from `beam-campus/swai` (2024, abandoned), where the body plan
existed as a directory tree of sensor and actuator groups, the islands existed as
scapes carrying `resource_availability` and `arena_toxicity_level`, and neither
was ever wired to anything. The organ files were mostly empty and the brain was a
heartbeat that ticked and did nothing. The ideas were right and the wiring was
missing; this is the wiring.

The service skeleton, the mesh plumbing and the realm split are lifted from the
sibling `hecate-robo-rumbler`.

## Running it

    rebar3 compile
    rebar3 eunit
    rebar3 lint

    scripts/health.sh                      # against a running node

Building the image needs a Rust toolchain, because macula ships a QUIC NIF and
the alpine build compiles it from source rather than fetching one linked against
a different libc.

    podman build -t hecate-biotope -f Containerfile .

## Configuration

| Variable | Default | Meaning |
|----------|---------|---------|
| `HECATE_REALM` | required | 64-hex fleet realm tag. No default: a biotope that guesses its realm announces itself where nobody can attribute it. |
| `HECATE_HEALTH_PORT` | `8483` | Health endpoint. Chosen clear of the siblings on the same box. |
| `HECATE_NODE_NAME` | `hecate_biotope` | Erlang node name. |
| `HECATE_NODE_HOST` | `127.0.0.1` | Erlang node host. |
| `HECATE_COOKIE` | `hecate_biotope` | Erlang cookie. |
| `MACULA_STATION_SEEDS` | none | Station to dial. Deliberately not defaulted: naming a realm costs nothing, dialling a production station from every dev clone does. |

## Deployment

CI builds on every push to `main` and pushes `ghcr.io/hecate-services/hecate-biotope:latest`
plus the semver tag. The node pulls `:latest` under watchtower, so a merge is a
deploy and a rollback is pinning the compose to a semver tag.

The deployment descriptor lives in `macula-demo`, not here, because that is where
the fleet's GitOps state is reconciled from.

## Licence

Apache-2.0.
