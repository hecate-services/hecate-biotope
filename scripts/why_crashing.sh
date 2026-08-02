#!/usr/bin/env bash
# WHY IS THE ISLAND RESTARTING? One ssh per node, one pass, no retry loop.
#
# `ask_fleet_world.sh` answers "which world", which a node in a restart loop
# still answers correctly a second after it comes back up. A tick counter of 186
# on a node that has been up for a day is the tell, and that script has no way to
# say so because it never asks how long the container has been running.
#
# So this asks the three things that separate a crash loop from a slow world:
#
#   RestartCount and StartedAt   how many times, and how long since the last one
#   the tail of the log          what it said on the way down
#   the exit status              OOM kill and a BEAM crash look identical in the
#                                log tail, because an OOM kill leaves no log at all
#
# Reads only. Nothing here restarts, pulls or removes anything.
set -euo pipefail

NODES=${NODES:-"beam00.lab beam01.lab beam03.lab"}
USER_NAME=${USER_NAME:-rl}
CONTAINER=${CONTAINER:-biotope}
LOG_LINES=${LOG_LINES:-40}

read -r -d '' REMOTE <<'REMOTE_SCRIPT' || true
set -u
C=$(docker ps -aq --filter name=CONTAINER_NAME | head -1)
if [ -z "$C" ]; then
  echo "  no container matching CONTAINER_NAME"
  exit 0
fi
echo "  --- state"
docker inspect "$C" --format \
  '  name={{.Name}}
  status={{.State.Status}}
  restarts={{.RestartCount}}
  exit={{.State.ExitCode}}
  oom={{.State.OOMKilled}}
  started={{.State.StartedAt}}
  finished={{.State.FinishedAt}}
  image={{.Config.Image}}
  policy={{.HostConfig.RestartPolicy.Name}}
  memlimit={{.HostConfig.Memory}}'
echo "  --- image identity"
docker image inspect "$(docker inspect "$C" --format '{{.Image}}')" \
  --format '  created={{.Created}}
  digest={{index .RepoDigests 0}}' 2>/dev/null || echo "  image gone"
echo "  --- economy the CONTAINER is actually running"
docker inspect "$C" --format '{{range .Config.Env}}{{println .}}{{end}}' \
  | grep -E 'HECATE_BIOTOPE_(ECON|SEED|SCREEN|TICKS|SLOT|ISLAND)' \
  | sed 's/^/  /' || echo "  no biotope env set"
echo "  --- worlds that ENDED (a live island reseeds, and says so)"
docker logs "$C" 2>&1 | grep -c 'ended at tick' | sed 's/^/  endings=/'
docker logs "$C" 2>&1 | grep 'ended at tick' | tail -8 | sed 's/^/  /'
echo "  --- host memory"
free -m | sed 's/^/  /'
echo "  --- log tail (LOG_LINES_N lines)"
docker logs --tail LOG_LINES_N "$C" 2>&1 | sed 's/^/  /'
REMOTE_SCRIPT

REMOTE="${REMOTE//CONTAINER_NAME/${CONTAINER}}"
REMOTE="${REMOTE//LOG_LINES_N/${LOG_LINES}}"

for node in ${NODES}; do
  echo "== ${node}"
  ssh -o ConnectTimeout=5 -o BatchMode=yes "${USER_NAME}@${node}" "${REMOTE}" \
    2>&1 || echo "  unreachable"
done
