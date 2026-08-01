# Pre-registration: world 6

**Written before world 6 was built.** Corrects register entry **B.5**. World 5 is
superseded, not edited: [PREREGISTRATION_WORLD5.md](PREREGISTRATION_WORLD5.md)
and its [results](RESULTS_WORLD5.md) stand as the record of a different world.

## Why there is a world 6

World 5 priced the free good it set out to price. Size became hard-bounded, 66 to
99 against a founding 800. **And it undid world 4's only positive**: the landscape
flattened from a spread of 26-86 back to 9-10, and energy taken from creatures
fell to zero in every seed.

The reason is that **it priced the wrong thing**, and Raf named it. A creature's
energy here is at once its **fat reserve**, its **body**, its **weapon in a
contest** and its **reproductive capital**. Those have opposite physics:

- an inert store costs almost nothing to hold — that is what fat is *for*
- working tissue is expensive to run

World 5 taxed the reserve as though it were tissue. **No scaling exponent fixes
that**, because the quantity being scaled is two things welded together. (And
linear was harsher than nature anyway: Kleiber's exponent is empirical, contested
and curved, but every candidate is *sublinear*, meaning cost per unit mass falls
with size, where linear holds it constant.)

## The single change

**A creature has a store and a structure, and only structure costs upkeep.**

    upkeep    = base + rent + structure / upkeep_divisor
    contest   is decided by STRUCTURE, not by what a creature is carrying
    growing   moves store into structure, and is an output

Everything else is unchanged.

### Why growing has to be a decision

Splitting the two forces a rule for how one becomes the other, and *"a creature
grows when it has a surplus"* would be biology written into the physics — the
exact shape of `breed_at`, deleted in world 2. Making it an **output** is the
same treatment reproduction already gets, needs no new machinery beyond a third
purpose, and is more general: a lineage can evolve to grow when safe and hoard
when not.

**The output's value is the amount**, clamped to what the creature is carrying.
No new constant, and outputs are already integers.

### Both halves still conserve

Structure is energy in another form, so the world's books become
`ground + stores + structures`, and every transfer moves between those terms
without changing the total:

- **breeding** splits store and structure alike, so matter and energy both halve
- **consumption** turns the victim's store *and* structure into the winner's store
- **death** returns both to the cell

The books test carries forward unchanged, which is the check that this was done
properly.

### What it prices, and what it leaves live

- **Free good NOT re-created:** structure still costs, so size is not free again.
- **Variance restored:** stores may differ freely, so creatures can once more be
  unlike one another, which is what world 5 destroyed.
- **Tradeoff left live:** structure wins contests and costs upkeep; store is
  cheap and useless in a fight. **A fat small creature loses to a lean large
  one.**

## An amendment, written before the first run

**2026-08-01, after the rules were frozen and before any result existed.**
Recorded rather than folded in silently.

`breed/1` and the new `build/1` rebuilt the herd index **once per creature**
inside their folds, so a creature evaluated later saw the children its
neighbours had just had and the conversions they had just made. That is a
turn-order advantage, and this module's header says in as many words that it
removed turn order:

> EVERY CREATURE VALUES THE SAME WORLD, the one at the start of the tick, and
> they all move at once. Nobody sees anybody else's move before making their own.

`move_all` obeys it. Those two phases did not. Both now gather the herd once,
as `herd/1`'s own comment always said it was for.

**Why this is not tuning.** No world 6 result existed when it was found, so it
cannot have been a change made in response to one. It was found by asking why a
single seed was taking over an hour: the per-creature rebuild is quadratic in
the population, and at 2,263 creatures 250 ticks took 532 seconds. It now takes
2. The bug and the delay are the same bug.

**What it costs, stated plainly.** `breed/1` has carried this since breeding
became an output, so **worlds 2 to 5 all ran with it**. World 6 therefore
differs from world 5 in two ways rather than one: the pre-registered store and
structure split, and this. Any comparison drawn against world 5 has to carry
that caveat, and a difference cannot be attributed to the split alone without a
control.

**The control this needs**, if the finding turns on the comparison: world 5's
rules re-run with the herd hoisted, which separates the two changes. Not run
yet, and named here so that deciding later to skip it is a visible decision.

## What may set a constant

Unchanged. No new constant is introduced: `upkeep_divisor` carries over and is
simply applied to structure instead of to everything. Its criterion and its
derivation stand, and it will be re-derived against the new rule and the
derivation recorded.

## What will be reported

Everything that varies, with none of it privileged, plus **structure separately
from store**, since a mean of the two added together is exactly the conflation
this world exists to undo.

## What would count as a finding

Stated in advance.

1. **Variance returns.** `ground_spread` above the flat baseline of ten again.
   World 4 reached 26-86, world 5 fell back to 9-10.
2. **Energy from creatures above zero.** World 5 drove it to zero, which is what
   currently makes register entry `D.2` untestable.
3. **A structure distribution with shape**, rather than everything at one size.
4. **Store and structure diverging** — lineages that carry much and build little,
   or the reverse. That is the fat-versus-muscle axis and neither is named.
5. **Perception that pays**, and **topology that is used**.

## What this will NOT do, stated in advance

It does not make movement pay, and **`still%` may well stay at 100**. That is the
density relation, a separate entry, untouched here.

## The commitments

1. Rules frozen before the first run, not changed in response to it.
2. Reported across many seeds, including **nothing happened**.
3. A further change is world 7. This file is superseded, not edited.
4. Worlds 1 to 5 are retired and may not be quoted alongside this.
