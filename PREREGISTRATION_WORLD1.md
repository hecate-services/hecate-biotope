# Pre-registration: world 1

> **SUPERSEDED** by [PREREGISTRATION.md](PREREGISTRATION.md). Kept whole and
> unedited, because a pre-registration that gets revised after the results are in
> is not a pre-registration. See [RESULTS_WORLD1.md](RESULTS_WORLD1.md).

**Written before the rebuilt world was run for the first time.** Committed in the
same change as the rebuild, so the commit history shows it was not written after
seeing the answer.

## Why this file exists

An earlier round of work set `scent_mutation` to whichever value produced the
most carnivores, after five parameter sweeps that all shared that success
criterion. That is circular: the carnivores were the thing being claimed as a
discovery, so choosing the rule by them installs the result and then reports
finding it.

Raf caught it, twice, and the second time he was pointing at something larger
than parameters. The rules themselves contained biology. There were actions
called `graze` and `hunt`, organs called `eye` and `nose`, and a diet statistic
that counted which of two verbs had fired. A world whose physics already says
"hunt" cannot discover predation.

So the world was rebuilt, and this file fixes the rules of engagement in advance.

## The line

**Physics is ours to write. Biology never is.**

| Ours | Not ours |
|------|----------|
| energy, space, cost, persistence, inheritance | what eats what |
| what kinds of thing exist | what is worth measuring |
| how far a thing can move in a tick | what a creature does with a turn |
| how fast a mark fades | whether anything follows one |

Concretely, the rebuilt world contains **no named action and no named organ**.
The only decision a creature makes is which of the seven reachable cells to
occupy. Consumption is one rule that does not know what it is eating: whatever
shares your cell and cannot contest you becomes yours, a plant never contests,
and a creature contests with its energy. Grazing, predation, fleeing and ambush
are all descriptions an observer may apply to where things went.

## What may set a constant

A number may be chosen for **viability**, which says nothing about what evolves:

- nothing goes extinct, or extinction is the finding rather than the noise
- the population is not pinned against `max_creatures`
- the energy books balance
- a sense has something to discriminate, or its rent buys nothing
- the run completes in time to be repeated across seeds

A number may be chosen for **scale**: safety valves such as `max_sensors` and
`max_sensor_range` exist so a mistuned economy cannot make one tick cost as much
as the whole disc. When one binds, it is counted and reported rather than left to
look like a natural ceiling.

A number may **never** be chosen because of what evolves in it. "Predators appear
at this value" is not a reason to choose that value.

Two constants have forms that no physics settles, and both are named here rather
than defended later:

- **sensor rent rises linearly with range.** Reach costs; that much is physical.
  Whether it costs with the radius or with the area covered is not decided by
  anything in this world. Area was rejected because at rent 1 a range-two sensor
  would cost nineteen a tick against a metabolism of one, pricing reach out of
  existence before selection saw it. That is a judgement about the economy being
  able to express the option, not about what should win.
- **`scent_mutation = 3`** was derived from a property of the signal with diet
  never consulted: two independent signatures differ in half their components, so
  50 is the unrelated baseline, and the requirement stated before looking was to
  reach half of that in every seed at the coarsest drift that clears it.

## What will be reported

Everything that varies, side by side, with **none of it privileged**. The probe
deliberately has no headline metric, because a probe that reports one number at
the top is a probe that will be run until that number moves.

- viability: extinctions, population range, refused births, energy books
- deaths by cause: starved, aged out, consumed
- `from_creatures_pct`: share of eaten energy that came from other creatures
- sensor census per field: carriers and total reach
- signature: distinct tags and spread
- mean breeding threshold

## The commitments

1. The rules are frozen before the first run and are not changed in response to
   what the first run shows.
2. Results are reported across many seeds as a distribution, including
   **"nothing happened"**, which is a likely and acceptable outcome.
3. If the physics is changed later, that is a **new world**. Results from this
   one are retired, not carried forward, and this file is superseded rather than
   edited.
4. Prior results are retired now. Every carnivore figure quoted before the
   rebuild was measured while sweeping for carnivores and must not be cited.
   Negatives and bug fixes survive: a creature following its own scent trail was
   a defect whatever the outcome.

## What would count as a finding

Stated in advance so that nothing can be promoted to a finding afterwards.

- **Sensor differentiation.** Two or more lineages that carry materially
  different sensor sets and persist. A single set fixed near 100% in every seed
  is the null result and is just as reportable.
- **Predation as a living.** `from_creatures_pct` well above zero and stable,
  rather than a large number of kills that no lineage depends on. The previous
  world had constant killing that nobody lived on, and that distinction is the
  one worth keeping.
- **Divergence between islands.** Same rules, different seeds, settling in
  different places. Requires the within-seed spread to be smaller than the
  between-seed spread, which the earlier `breed_at` work failed and reported.

None of these is expected. The honest prior, from the last frozen run of the
previous world, is that one kit fixes near 100% and nothing else happens.
