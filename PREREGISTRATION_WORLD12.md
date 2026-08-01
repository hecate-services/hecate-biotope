# Pre-registration: world 12

> **ARCHIVED COPY** of the criteria as frozen before world 12 ran.

**Written before world 12 was built.** Corrects register entries **C.2** and
**C.1**. World 11 is superseded, not edited:
[PREREGISTRATION_WORLD11.md](PREREGISTRATION_WORLD11.md) and its
[results](RESULTS_WORLD11.md) stand as the record of a different world.

Thermodynamics at the classical scale still governs.

## Why there is a world 12

**This is the largest behavioural change since world 2, and unlike the last four
it is not a deletion of a free good.** It changes what a creature can DO. That is
said first because it is the reason to be careful with it.

The register has carried its own diagnosis for several worlds and I have walked
past it each time:

> The brains are not being deleted for being too small. **They are being deleted
> because there is nothing to decide.**

And it says why. This world has one drive: hunger, survival and reproduction all
reduce to *get more energy*. Nothing pulls against anything. The one place a
competing drive could have lived is gone, because **flight does not exist**:
movement is simultaneous and everything moves exactly one cell per tick, so an
adjacent predator can never be outrun. Prey has no strategy available except
being larger, which is the predator's strategy.

Ten worlds of pricing free goods have not touched that, because it is not a free
good. It is a missing capability.

## The single change

**A creature goes as far as it can pay to go, and carrying a body costs.**

    fare per cell = move_cost + carrying(structure)

It steps while it prefers somewhere else and can pay, and it will not re-enter a
cell it has already stood in this tick.

**No new constant.** The fare is `move_cost` plus the expression that already
prices holding a frame, at the same divisor: hauling a body and holding one cost
alike.

### Why it is one rule and not two

Unbounded steps at a flat fare would be **a free good handed to the large**. A
big creature is rich, so it would be big AND fast, and size would dominate
harder than it already does. The mass term is what makes speed a tradeoff rather
than another advantage of being big, and the register opens with exactly this:
*a tradeoff only motors anything if nothing adjacent is free.*

The no-revisiting clause is termination, not physics: two cells that each prefer
the other would trade a creature back and forth until it had burned its whole
body. Nothing may be in the same place twice in one moment.

## What would count as a finding

Stated in advance.

1. **A size axis appears.** Small-and-fast against large-and-slow, with both
   present at once, which is the first tradeoff in this world where neither end
   leaves the game.
2. **Perception moves.** Sensors have been paid for and worthless for ten worlds
   because nothing could be done with what they saw. Seeing something larger
   nearby is worth paying for only once fleeing is possible. This is the target.
3. **`still_pct` falls further** and the landscape differentiates more, because
   movement is now something a creature can spend on rather than a fixed tax.
4. **Lineages survive past one.** Two ways of living that both persist is the
   first mechanism this world has had that could hold more than one founding,
   and **G.1** has resisted everything so far.

## What will NOT happen, stated in advance

**Extinctions will probably rise again.** Movement got more expensive for
anything large and a walk can now run a creature down to nothing. Worlds 10 and
11 each cost survival for the sake of honest books; this may too, and that is a
result rather than a fault.

**The world is still perfectly constant.** **G.3** and **A.4** are untouched: no
day, no season, no weather.

**And the most likely outcome is still nothing.** Nine of eleven worlds so far
have produced no movement on perception. A capability is not a reason, and if
there is still nothing worth deciding then speed will simply be selected to
whatever value is cheapest and this will read as another null.

## The commitments

1. Rules frozen before the first run, not changed in response to it.
2. Reported across every seed and every efficiency, including **nothing
   happened**.
3. A further change is world 13. This file is superseded, not edited.
4. Worlds 1 to 11 are retired and may not be quoted alongside this.
5. **The engine is reported beside the population**, `lineages`, `depth` and the
   uptake spread.
6. This is the first world in five that did NOT come out of the register audit,
   and it is the first in five that adds a capability rather than removing a
   subsidy. Both are worth noticing if it produces something.
