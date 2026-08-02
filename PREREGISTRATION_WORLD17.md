# Pre-registration: world 17

**Written before world 17 was built.** Corrects register entry **F.2**, which
world 2 marked corrected, and the third face of **A.6**. World 16 is superseded,
not edited.

## THE GATE

| | value | how obtained |
|---|---|---|
| what a creature earns, per tick | ~100, measured 87 to 231 | `scripts/where_does_it_go.escript` |
| what one mutation changes the bill by | **unchanged**: this world alters no cost | |
| as a share of earnings | n/a | |
| the drift threshold | n/a | |
| **does it clear** | **not applicable, and that is the point** | |

**This world changes no price.** It changes what a sensor can *resolve*, which is
upstream of every price: an organ that reads nothing cannot pay for itself at any
cost. The gate's first question does not apply and its second one does.

**Can the genome represent the variation this is meant to select among?** Yes,
and unlike world 16 it is checked rather than assumed. Reach is already a
heritable integer that mutation moves in both directions, and after this change
different reaches produce genuinely different readings rather than one blind
value and one saturated one.

## Why there is a world 17

Measured with `scripts/what_can_they_see.escript` before this was written:

| | |
|---|---|
| ground sensor at reach 0, share of cells reading **zero** | **88 to 100%** |
| ground sensor at reach 1, share reading zero | 9 to 20% |
| ground sensor at reach 1, **maximum** reading | **49 to 54** of a ceiling of 63 |
| `self`, share of creatures reading **zero** | **35 to 54%** |

**One unit cannot serve every reach.** A reading is a sum over the cells in
range divided by a fixed unit, so the magnitude grows with the area while the
scale does not. At reach 0 the instrument is blind almost always; at reach 1 it
is already near the top of its range and reach 2 can only saturate.

And the live fleet carries reach-0 ground sensors almost exclusively. **Creatures
are paying for the one configuration that reads nothing.**

`self` is the same defect in a place that matters more. It is not stuck at zero,
it reads up to 45, but it reads zero for a third to a half of the population and
those are the ones with least in store. **The hunger sense is blind exactly where
a survival decision would be made.** A creature cannot tell low from critical.

## The single change

**A reading is an intensity, not a total.**

- A spatial field reports the **mean over the cells in reach**, not the sum, so
  every reach reads on one scale and reach buys spatial averaging rather than
  magnitude. That is how a sense works: brightness, concentration, not
  integrated photons.
- The unit becomes **`ground_ceiling ÷ reading_ceiling`**, so a full cell reads at
  the top of the range and a typical one reads in the middle of it.

**NO NEW CONSTANT**: the unit is derived from two that exist. `scent` keeps its
own unit, which the measurement shows already resolves properly, and the divisor
is floored at one so no field can divide by zero.

**What reach means changes, and that is the substance.** It stops being "how much
I add up" and becomes "how far I average over". A wide sensor sees a smoother,
larger picture and a narrow one sees exactly where it stands.

## What would count as a finding

1. **Reach stops being nearly free of information.** A reach-0 sensor resolves
   its own cell, so carrying one is a real choice rather than a tax. Measured as
   the share of readings equal to zero, which is 88 to 100% today.
2. **Perception rises further**, having reached 1.50 per creature under world 14
   and 6.49 at the cheapest price under world 16. **This is the target.**
3. **Reach differentiates.** Today the population is almost all reach 0 because
   reach costs and buys nothing. If reaches spread out, the tradeoff between
   seeing near and seeing wide exists for the first time.
4. **Hidden nodes move**, because a `self` reading that varies is the first input
   whose value depends on the creature's own state rather than on the world, and
   combining it with anything requires a hidden node.

## What will NOT happen, stated in advance

**Nothing here makes a brain useful.** It makes the instruments legible.
`H.10` is explicit that a price can only make a trait visible; the same is true
of a reading. **If perception rises and computation does not, that is the answer**
and it says the problem was never the senses.

**Extinctions may move in either direction** and I decline to predict which. A
world whose creatures can suddenly see the ground properly may forage better and
survive more, or crowd the good cells and survive less.

**`lineages` will be 1** and F_ST is reported beside it.

**And the most likely outcome is still nothing.** Seventeen worlds. The one thing
that has ever moved perception a long way is world 14's patchy board, which gave
it something to see, not a cheaper or clearer instrument.

## The commitments

1. Rules frozen before the first run. This file is superseded, not edited.
2. Every value reported, including **nothing happened**, and including the dead.
3. `world:ruleset/0` says 17 in the same commit as the rules.
4. `lineages`, `depth`, the uptake spread and **F_ST** reported beside the
   population, plus **the share of readings that are zero**, which is the number
   this world exists to move and would otherwise be invisible.
5. New tests go red against world 16's physics before they are believed.
