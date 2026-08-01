# Pre-registration: world 8

> **SUPERSEDED** by [PREREGISTRATION.md](PREREGISTRATION.md). Kept whole and
> unedited as the record of what was committed to before world 8 ran. Its
> [results](RESULTS_WORLD8.md) are scored against the criteria below.

**Written before world 8 was run.** World 7 is superseded, not edited:
[PREREGISTRATION_WORLD7.md](PREREGISTRATION_WORLD7.md) and its
[results](RESULTS_WORLD7.md) stand as the record of a different world.

Thermodynamics at the classical scale still governs. See world 7's file for the
four laws applied one at a time; nothing here changes any of them.

## Why there is a world 8

**World 7 was full of ghosts.** Below 70% efficiency every frame was zero, and
those creatures went on eating at rate 250, carrying sensors, running a hidden
layer and breeding, exactly as well as anything with a body.

Raf looked at a picture of it and said a creature without a body makes no sense.
It does not, and the renderer was about to draw it faithfully.

**The cause is that a body was OPTIONAL.** Frame won contests and cost upkeep,
and that was the whole of it. Nothing a creature could do depended on having
one. That is the free-good pattern this register is built around, and it has
been sitting in plain sight since world 6 created the frame. World 7 only made
it visible by pricing building until nobody bothered.

## The single change

**Capacity is a property of structure. A creature cannot take in more than its
frame.**

    absorbed = min(uptake, frame, what is in the cell)

**No new constant.** It is a comparison between two quantities the world already
tracks, which is what makes it the deletion of a free good rather than an added
rule. There is no threshold and nobody chose a number.

Death from having no body follows rather than being decreed: such a creature
cannot feed, so it starves like anything else that cannot feed. **No rule
anywhere says a frame of zero is fatal.**

### What this does not do

It does not make a body mandatory by fiat, and it does not stop a creature
being born small. A founder cannot be born bodiless, since the split hands the
odd unit to the frame, and that is asserted rather than assumed.

## What it costs world 7's result

**One of world 7's findings is weakened and this is stated before the run.**

World 7 found frames collapsing to zero below 70% efficiency, and offered two
readings: real, or the integer-truncation artefact. **There is a third, and it
is this bug.** Frames collapsed in a world where having none was survivable. If
that measurement was of the ghost rather than of the Second Law, world 8 will
say so, and world 7's entry needs amending rather than quoting.

## What would count as a finding

Stated in advance.

1. **Ghosts become impossible.** `structure_max` above zero at every efficiency,
   where world 7 had it at zero from 70% down.
2. **Structure stops being optional**, so building happens despite the Second
   Law making it expensive. Frames present across the sweep rather than only at
   the top.
3. **Lifespan rises above 2.2 ticks.** A body is now an investment that pays
   over time, and it is the first thing in this world that would reward living
   longer. This has been the target since world 6 and has failed twice.
4. **The world 7 frame collapse is explained.** Either it returns once ghosts
   are impossible, which makes it the bug, or it does not, which makes it the
   Second Law or the truncation artefact after all.
5. **Density falls**, since feeding is now capped by something most creatures
   have very little of.

## What will NOT happen, stated in advance

**`still%` will probably stay high.** That is the density relation and it is
untouched. World 7 moved it off 100 for the first time, by an unrelated route.

**Extinction is a real risk at low efficiency and would be a result.** Feeding
is now bounded by a frame that the Second Law makes expensive to build, and
those two could close on each other. The sweep reports the boundary.

## The commitments

1. Rules frozen before the first run, not changed in response to it.
2. Reported across every seed and every efficiency, including **nothing
   happened**.
3. A further change is world 9. This file is superseded, not edited.
4. Worlds 1 to 7 are retired and may not be quoted alongside this.
5. **The register audit still follows**, applying one test to every entry:
   required by physics, permitted, or contrary. This world is the second entry
   in a row found by looking rather than by experimenting, which is the argument
   for doing it.
