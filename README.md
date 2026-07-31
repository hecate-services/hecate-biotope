# hecate-biotope

**This exists so creatures can live, eat, breed and die on a node you do not own.**

A biotope is one island. It holds a bounded world with its own local conditions,
an open population of creatures whose bodies are assembled from organs, and an
energy economy that decides which of them get to reproduce. One biotope per node.
Islands meet later, by exchanging migrants over the mesh.

## Status: a world runs, and nothing has a brain

Plants grow, creatures forage, breed and starve, and the island says what is
happening on the mesh. There is no organ, no brain and no evolution yet.

Measured over 2000 ticks and five seeds rather than asserted: no seed goes
extinct, the population settles into a band around 65 to 85 after an opening
overshoot to 115, and plants oscillate against it. Starvation outnumbers old age
by about seventy to one, which is the number that matters: the population is
**resource-limited**, so selection pressure exists. Raising `metabolism` to 3
starves it to about 20 with plants piling up ungrazed; raising
`regrowth_per_tick` to 12 pushes it to about 220 with plants grazed down.

`scripts/probe_economy.escript` is the instrument for that.

**Creatures random-walk, which is a choice rather than a placeholder.** A random
walker has no perception, so it cannot prejudge what senses should exist, and it
is permanently useful as the null forager every later brain has to beat.

It announces no capability, because a capability is a promise that something
answers when another service calls it, and a biotope so far only speaks. When it
accepts a migrant, that is a capability and it will say so.

## The two facts

| topic | fact | carries | rate |
|-------|------|---------|------|
| `<ns>/world` | `world_advanced` | counts and totals | `HECATE_BIOTOPE_PUBLISH_MS` |
| `<ns>/chart` | `world_charted` | where everything is | `HECATE_BIOTOPE_CHART_MS`, 0 is off |

Separate on purpose. A statistics reader should not pay for a hundred and
seventy coordinates it will never draw, and the two want different rates: a
chart keeps up with the eye, a statistic is small enough to keep forever.

**The island id is in the payload and never in the topic.** A thousand islands
must not become a thousand topics, and a reader who wants "all islands" has to
be able to ask for it. The namespace separates whole deployments, a laptop from
the fleet, and is not how islands are told apart.

Positions are flat integer lists with a stride of two, `[Q1, R1, Q2, R2 | ...]`.
A pair would be a tuple and tuples do not survive this mesh cleanly; a map per
entity would repeat two keys a hundred and seventy times a frame for nothing.

Totals rather than rates, because a rate is recoverable from two totals and a
total is not recoverable from rates, so a reader that misses a fact can catch
up. Every fact carries the tick, because publishing runs on wall clock and the
world runs on its own pace: two consecutive facts may be one tick apart or a
million, and without the tick a stalled world and a slow one look identical.

**Facts leave on their own realm.** They are meant to be read by a public
website, and handing a public web container the fleet realm tag would let
anything in it read sentinel sightings and warden facts too.

    net.beamcampus.biotope
    7f73d3d9361bb16d4bed2812428ea6e6257a6f50c9de7ac8c581665dc0d01171

Unset falls back to the fleet realm. A malformed tag is an error rather than a
fallback, because falling back on a typo would publish public facts onto the
operational realm and report success.

Worth stating plainly: stations are realm-agnostic, so a realm is a routing
namespace and not an enforced permission. What this buys is that a public web
box never holds the fleet tag.

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
| `HECATE_BIOTOPE_REALM` | fleet realm | 64-hex realm the facts go out on. Malformed is an error, not a fallback. |
| `HECATE_BIOTOPE_ISLAND` | hostname | Which island this is. **Set it explicitly in a container**: docker makes the hostname the container ID, so the island would be renamed by every recreate. |
| `HECATE_BIOTOPE_NS` | `biotope` | Topic namespace. Separates whole deployments, not islands. |
| `HECATE_BIOTOPE_TICKS_PER_SLOT` | `1` | Ticks per slot. With `slot_ms`, covers watching and searching with one mechanism. |
| `HECATE_BIOTOPE_SLOT_MS` | `100` | Yield between slots. `1` slot of `1000` ticks is roughly a million ticks a second. |
| `HECATE_BIOTOPE_PUBLISH_MS` | `1000` | How often `world_advanced` goes out. |
| `HECATE_BIOTOPE_CHART_MS` | `1000` | How often `world_charted` goes out. `0` turns the picture off entirely. |
| `HECATE_BIOTOPE_SEED` | `42` | RNG seed. A world is a function of its parameters. |
| `HECATE_BIOTOPE_ECON` | none | Economy overrides, `key=value` comma separated, same syntax as the probe. An unknown key refuses to start. |
| `HECATE_HEALTH_PORT` | `8483` | Health endpoint. Chosen clear of the siblings on the same box. |
| `HECATE_NODE_NAME` | `hecate_biotope` | Erlang node name. |
| `HECATE_NODE_HOST` | `127.0.0.1` | Erlang node host. |
| `HECATE_COOKIE` | `hecate_biotope` | Erlang cookie. |
| `MACULA_STATION_SEEDS` | none | Station to dial. Deliberately not defaulted: naming a realm costs nothing, dialling a production station from every dev clone does. |

**For a picture that moves smoothly, `chart_ms` wants to be about
`1000 / ticks_per_second`.** The image defaults run well and watch badly: ten
ticks a second against one frame a second means creatures jump ten steps between
frames. The deployed island is set to two ticks a second with a frame every
500ms. Every fact carries `ticks_per_second`, so a viewer can say which it is
looking at rather than guessing.

## Deployment

CI builds on every push to `main` and pushes `ghcr.io/hecate-services/hecate-biotope:latest`
plus the semver tag. The node pulls `:latest` under watchtower, so a merge is a
deploy and a rollback is pinning the compose to a semver tag.

The deployment descriptor lives in `macula-demo`, not here, because that is where
the fleet's GitOps state is reconciled from.

## Licence

Apache-2.0.
