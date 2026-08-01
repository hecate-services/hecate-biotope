# Pre-registration: world 5

> **SUPERSEDED** by [PREREGISTRATION.md](PREREGISTRATION.md). Kept whole and
> unedited. Its results are in [RESULTS_WORLD5.md](RESULTS_WORLD5.md): the change
> bit, and it undid world 4's positive, for a reason world 6 acts on.

**Written before world 5 was built.** World 4 is superseded, not edited:
[PREREGISTRATION_WORLD4.md](PREREGISTRATION_WORLD4.md) and its
[results](RESULTS_WORLD4.md) stand as the record of a different world.

## Why there is a world 5

World 4 gave this project its first genuine tradeoff — feed fast and strip the
cell, feed gently and it sustains you — and **the first trait in five worlds to
be selected rather than drift**. It moved consistently, in one direction, in all
eight seeds.

**It moved the wrong way.** Prudence pays six times what greed does and the
population went the other way, because a third term with no tradeoff attached
overrode it:

- large creatures win contests, deterministically
- **97% of all deaths are being eaten**; starvation is a rounding error
- and **holding energy costs nothing at all**

So energy is armour, armour is free, and grabbing fast is how you get it. The
sustainable-yield tradeoff was real and simply outvoted.

**A tradeoff only motors anything if nothing adjacent is free.** That is the
lesson of world 4, and this world acts on it.

## The single change

**Metabolism scales with what a creature holds.**

    metabolism = base + (energy / upkeep_divisor)

That is the whole of world 5. Nothing else changes: not the ground, not the
feeding rate, not the brain, not the sensors, not reproduction, not the disc.

### Why this and not the next entry in the register

The register's order is "follow the energy", which would put temporal variation
in supply next. **The ordering rule is amended, before this run and on the
record, to price free goods first.**

Not because they look promising. Because **they confound everything downstream**.
Introduce seasons while hoarding is free and hoarding wins, and a null result
cannot be told from a null-that-was-neutralised — which is nearly how world 4 was
misread. Until the free goods are priced, no other reading can be trusted.

### Linear, not Kleiber

Real metabolism scales as roughly mass to the three-quarters, which is
**sublinear and therefore favours large size** relative to linear. Adopting it
means choosing a fractional exponent: awkward in integers, and a magic number.

Linear is the plainest statement of "holding costs something" and needs no
exponent. If it proves too punishing, sublinear is the obvious refinement, and it
is better arrived at by measurement than assumed at the start.

### What it prices, and what it leaves live

- **Free good priced: holding energy.** A creature carrying 10,000 currently pays
  exactly what one carrying 10 pays.
- **Tradeoff left live: large wins contests but costs more to run; small is cheap
  but loses them.** As far as can be seen, nothing adjacent to that is free.

It also makes **being small a strategy rather than a failure**, which is the
precondition for anything resembling prey: prey are small and numerous, predators
large and few, and that split is arithmetically impossible while size is free.

## What may set a constant

Unchanged. A number may be chosen for **viability** or for **scale**, and **never
because of what evolves in it**. One constant is added, and its criterion is
fixed here, before measuring:

> the **largest** `upkeep_divisor` at which a creature feeding at the sustainable
> yield cannot grow beyond what one full cell holds.

**Largest** because that is the gentlest pricing that still binds. Anything
larger and the cap never bites and the change is inert — which is precisely how
world 3 failed, and how world 4's growth rate nearly did until the verifier
caught it.

It is built from quantities the world already has: the sustainable yield, the
base metabolism and the ground ceiling. Nothing new is invented, and it will be
derived by measurement with `scripts/verify_ground.escript` and the derivation
recorded, as every constant since world 2 has been.

Carried forward and already named: sensor rent linear in range, flat rent per
hidden node, the rectified activation, and the ground constants.

## What will be reported

Everything that varies, side by side, **with none of it privileged**, plus two
new observables the change requires:

- **the largest creature alive**, without which "size is now bounded" cannot be
  read at all
- **the distribution of creature size**, because a mean cannot tell one optimum
  from two

## What would count as a finding

Stated in advance.

1. **Size becomes bounded.** The largest creature stops climbing with time. This
   is the mechanical check that the change bit at all; without it nothing else
   here means anything.
2. **A size distribution with shape.** Currently everything converges on as-large-
   as-possible. If holding costs, there should be an optimum and a spread around
   it rather than a pile at the top.
3. **Small-and-many against large-and-few.** Two groups at different sizes
   persisting together. That is the role split arriving without either role being
   named, and it is what this world is really asking.
4. **The feeding rate settles.** World 4's trait may behave differently once
   grabbing fast no longer buys free armour.
5. **Perception that pays**, and **topology that is used**, meaning sensors and
   hidden nodes carried AND acted on.

## What this will NOT do, stated in advance

**It does not make movement pay.** That is the density relation, a separate
entry, untouched here. **`still%` may well stay at 100, and that would not be a
failure of this world.**

**It does not make eating a decision.** That is register entry 4.2 and the next
free good in the queue.

Saying so now is the point: a world judged against a question it was never built
to answer produces a fifth false negative.

## The commitments

1. Rules frozen before the first run, not changed in response to it.
2. Reported across many seeds as a distribution, including **nothing happened**,
   which three of the five corrections so far have produced and which is a result
   rather than a failure.
3. A further change is world 6. This file is superseded, not edited.
4. Worlds 1 to 4 are retired and may not be quoted alongside this.
