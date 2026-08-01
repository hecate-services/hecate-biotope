#!/usr/bin/env bash
# Which world each island in the fleet is actually running.
#
# A rollout is not instant: CI pushes an image, each node pulls it on its own
# timer, and until a node has turned over it is publishing the OLD physics under
# the same econ id as the new. This asks each node directly rather than guessing
# from how long ago the push was.
#
# DOCKER, NOT PODMAN. The beam boxes run podman for the hecate daemons, but the
# biotope fleet is deployed with docker plus watchtower out of macula-demo. Using
# the wrong one reports every node as "no container", which reads exactly like a
# fleet that is down.
#
# ONE ssh per node, no retry loop. Run it again if you want a later answer.
set -euo pipefail

NODES=${NODES:-"beam00.lab beam01.lab beam02.lab beam03.lab"}
USER_NAME=${USER_NAME:-rl}
CONTAINER=${CONTAINER:-biotope}

# A node with no biotope container is a normal answer, not a failure, and it has
# to SAY so. `docker ps` with no match exits 0 and prints nothing, so a bare `||`
# never fires and the node silently vanishes from the report, which reads as a
# formatting glitch rather than as a fact about the fleet.
for node in ${NODES}; do
  printf '%-12s ' "${node}"
  line=$(ssh -o ConnectTimeout=5 -o BatchMode=yes "${USER_NAME}@${node}" \
    "docker ps --filter name=${CONTAINER} \
       --format '{{.Image}} started={{.RunningFor}}' ; \
     docker inspect --format 'image={{slice .Image 7 19}}' \
       \$(docker ps -q --filter name=${CONTAINER}) 2>/dev/null" \
    2>/dev/null | tr '\n' ' ') || line=""
  echo "${line:-no ${CONTAINER} container, or unreachable}"
done
