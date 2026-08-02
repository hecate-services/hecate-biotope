#!/usr/bin/env bash
# WHICH WORLD THIS SOURCE TREE IS, printed as a bare integer.
#
# `world:ruleset/0' is the single place that says which world the physics is, it
# lives with the rules rather than in configuration, and there is a test that
# fails if it disagrees with WORLDS.md. This reads that one place rather than
# adding a second, because two places for a version number is two places for it
# to drift and the label being wrong is exactly the failure `ruleset/0' exists to
# prevent — world 13's physics shipped labelled world 12 and nothing noticed.
#
# GREPPED RATHER THAN EVALUATED. The image build has no compiled tree and adding
# a compile step to read one integer would double the build for it. The pattern
# is anchored hard enough that it matches the definition and nothing else, and
# the script refuses to guess: no match or more than one is an error, never a
# default, because a wrong tag silently points at the wrong physics.
set -euo pipefail

RULES=${RULES:-apps/hecate_biotope/src/advance_world/world.erl}

matches=$(grep -cE '^\s+#\{number => [0-9]+,$' "${RULES}" || true)

if [ "${matches}" != "1" ]; then
  echo "world_number.sh: expected exactly one 'number => N' in ${RULES}, found ${matches}" >&2
  exit 1
fi

grep -oE '^\s+#\{number => [0-9]+,$' "${RULES}" | grep -oE '[0-9]+'
