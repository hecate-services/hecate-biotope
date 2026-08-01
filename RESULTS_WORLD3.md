# Results: world 3

Rules as committed with [PREREGISTRATION.md](PREREGISTRATION.md), untouched
between that commit and this run. 2000 ticks, 8 seeds, radius 10, 5m11s.

## Against the pre-registered findings

**1. Movement that persists: NO.** `still%` is 100 in seven seeds and 99 in the
eighth. World 2 was 100 in all eight. **The single change made no difference to
the thing it was made for.**

**2. Perception that pays: NO.** Sensors per creature round to zero in six seeds
of eight. Carriers across all four fields sit in the low single digits out of
roughly 580 creatures, and attention is 0 or 1 wherever there are any.

**3. Topology that is used: NO.** Hidden nodes per creature round to zero.

**4. Conditional behaviour: NO.** `self` carriers 0-3 with attention 0-1.

**5. A landscape that differentiates: PARTIAL, and the one real difference.**
`gspr` reached 35, 39 and 53 in three seeds against a flat baseline of 10, where
world 2 sat at 9 in six of eight. So places did become materially different from
one another in some runs. It did not translate into anything moving.

**6. Divergence between seeds: not established**, and will not be claimed from one
run per seed.

0 of 8 extinct, population 549-597 on 331 cells.

## Why, and it is the same trap wearing a different coat

**A stayer holds its cell at zero stock, forever.** It absorbs everything every
tick, so there is never any standing stock for the proportional term to compound
from. Its income is therefore exactly `ground_seed`, the bare-ground floor, and
**stock-dependent growth does not touch it at all.**

That single quantity then sets both halves of world 2's proof:

- sessility is viable exactly when `ground_seed > metabolism`
- so equilibrium density is `ground_seed / metabolism` = 1.2 creatures per cell
- so every cell is stripped every tick
- **so no cell anywhere ever holds stock, and the compounding term never fires
  in a populated world at all**

The change is inert for exactly the reason the verifier caught it being inert at
`ground_growth_pct = 1`, one level deeper. There it never fired because the seed
floor dominated up to the ceiling; here it never fires because **nothing ever
gets above zero to compound**.

## What that identifies

**Total absorption is the culprit, not the growth curve.** A creature takes
everything, so every grazed cell sits at zero, and any stock-dependent rule
degenerates to its floor everywhere. Stock-dependence can only matter if cells
are permitted to hold stock, which requires either that creatures leave some
behind or that there are fewer creatures than cells. The second is forbidden by
sessility being viable on the floor.

I predicted twice that a mechanism would break this trap and was wrong twice.
The first prediction, that a fixed influx was the culprit, was right about the
symptom and wrong about the cure. **Recording that rather than a third
prediction.**

## What carries forward

The build, the tests, the instruments and the amendment record. The numbers do
not, and no figure here may be quoted alongside world 1's or world 2's.
