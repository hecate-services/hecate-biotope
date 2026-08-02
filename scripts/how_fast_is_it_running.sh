#!/usr/bin/env bash
# IS THE ISLAND RUNNING AT THE PACE IT WAS TOLD TO RUN AT?
#
# `ask_fleet_world.sh` reports a tick. A tick is a POSITION and this asks for a
# RATE, which is a different question and the one that separates "a world that is
# young" from "a world that has stopped". Both read as a small number and only
# one of them is a fault.
#
# Two readings per node, spaced, one ssh each. The configured pace is read from
# the container's own environment rather than assumed, because the whole point is
# to compare what it is doing against what it was asked to do.
set -euo pipefail

NODES=${NODES:-"beam00.lab beam01.lab beam03.lab"}
USER_NAME=${USER_NAME:-rl}
CONTAINER=${CONTAINER:-biotope}
GAP=${GAP:-60}

read -r -d '' REMOTE <<'REMOTE_SCRIPT' || true
set -u
C=$(docker ps -q --filter name=CONTAINER_NAME | head -1)
[ -z "$C" ] && { echo "  not running"; exit 0; }
TPS=$(docker inspect "$C" --format '{{range .Config.Env}}{{println .}}{{end}}' \
      | grep '^HECATE_BIOTOPE_TICKS_PER_SLOT=' | cut -d= -f2)
SLOT=$(docker inspect "$C" --format '{{range .Config.Env}}{{println .}}{{end}}' \
      | grep '^HECATE_BIOTOPE_SLOT_MS=' | cut -d= -f2)
tick() {
  docker exec "$C" /app/bin/hecate_biotope rpc world_server snapshot \
    | tr ',' '\n' | grep -Eo '\<tick => *[0-9]+' | grep -Eo '[0-9]+' | head -1
}
T0=$(tick); S0=$(date +%s)
sleep GAP_S
T1=$(tick); S1=$(date +%s)
echo "  ticks_per_slot=${TPS:-default} slot_ms=${SLOT:-default}"
echo "  tick ${T0} -> ${T1} over $((S1 - S0))s"
awk -v a="$T0" -v b="$T1" -v s="$((S1 - S0))" \
  'BEGIN { printf "  measured %.3f ticks/s\n", (b - a) / s }'
REMOTE_SCRIPT

REMOTE="${REMOTE//CONTAINER_NAME/${CONTAINER}}"
REMOTE="${REMOTE//GAP_S/${GAP}}"

for node in ${NODES}; do
  echo "== ${node}"
  ssh -o ConnectTimeout=5 -o BatchMode=yes "${USER_NAME}@${node}" "${REMOTE}" \
    2>/dev/null || echo "  unreachable, or no biotope container"
done
