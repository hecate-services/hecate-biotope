#!/usr/bin/env bash
# ASK EACH ISLAND WHICH WORLD IT IS RUNNING, rather than inferring it.
#
# `check_fleet_world.sh` reports the image each node has, which is a different
# question and answers this one only by assumption. That assumption has already
# been wrong once: the cards read "world 6" for an hour while the physics was 7,
# and the rollout was then confirmed from a digest by the same person who had
# just built `world:ruleset/0` so that nobody would have to.
#
# It also reports the efficiency each island is ACTUALLY running under, because
# world 9 lives only above about 90 percent: a node still carrying a world 7
# override is a world that will be extinct by the time anyone looks at it, and
# nothing about the image would say so.
#
# ONE ssh per node, no retry loop. Run it again if you want a later answer.
set -euo pipefail

NODES=${NODES:-"beam00.lab beam01.lab beam03.lab"}
USER_NAME=${USER_NAME:-rl}
CONTAINER=${CONTAINER:-biotope}

# `rpc' AND NOT `eval'. They look interchangeable and are not: `eval' starts a
# FRESH vm with none of the applications running, so it answered `ok' for a world
# it had never advanced, which is worse than an error because it looks like a
# reading. `rpc' reaches the node that is actually alive.
#
# It takes a module and a function, not an expression, so the fields are pulled
# out of the printed snapshot rather than formatted on the far side.
#
# THE CONTAINER IS NOT CALLED `biotope'. Compose names it after the project and
# the service, so `docker exec biotope' answers "No such container" on a
# perfectly healthy node, which reads exactly like a fleet that is down.
# NO LEADING-SPACE ANCHORS. The printed term wraps where it likes, so anchoring
# on indentation silently dropped exactly the fields this script exists to check:
# `depth', `lineages' and `dissipated' are the three that only a world 9 build
# has, and an empty result for them reads as "not deployed" whether or not it is.
# WHICH REGIME, not just which world. World 12 found two stable states from the
# same rules: many small creatures on a flat board, or a few enormous ones on a
# lumpy one. `structure_max' and `ground_spread' are what tell them apart, and
# without them three islands that differ by a factor of twelve in population look
# like a bug rather than the most interesting result here.
#
# WORD-ANCHORED, because underscore is a word character and the first version of
# this list was not. `seed' matched inside `ground_seed' and `tick' inside
# `scent_per_tick', so every node reported a phantom `seed => 12' and
# `tick => 10' alongside its real ones: two economy constants wearing the names
# of two state variables. Exactly the kind of reading this script exists to stop
# anyone taking on trust.
NAMES='number|seed|tick|population|transfer_efficiency|depth|lineages'
NAMES="${NAMES}|from_creatures_pct|extinct_at|structure_max|structure_total"
NAMES="${NAMES}|ground_spread|sensor_mean|hidden_mean|scent_spread|still_pct"
NAMES="${NAMES}|energy_total|ground_total|uptake_min|uptake_mean|uptake_max"
FIELDS="\\<(${NAMES}) => *[a-z0-9_]*"

for node in ${NODES}; do
  echo "── ${node}"
  ssh -o ConnectTimeout=5 -o BatchMode=yes "${USER_NAME}@${node}" \
    "C=\$(docker ps -q --filter name=${CONTAINER} | head -1); \
     { docker exec \$C /app/bin/hecate_biotope rpc world ruleset; \
       docker exec \$C /app/bin/hecate_biotope rpc world_server snapshot; } \
       | tr ',' '\n' | grep -Eo '${FIELDS}' | sed 's/^ *//' | sort | sed 's/^/  /'" \
    2>/dev/null || echo "  unreachable, or no biotope container"
done
