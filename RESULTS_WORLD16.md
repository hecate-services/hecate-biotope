# Results: world 16

**One finding landed, two failed, and the reason one of them failed is the most
useful thing here: this world cannot express a narrow brain at all.**

Pre-registered in [PREREGISTRATION_WORLD16.md](PREREGISTRATION_WORLD16.md), the
first world through the selectability gate. 24 seeds, 20,000 ticks, 100%
efficiency, `neural_cost` swept.

| price | dead of 24 | **nodes** | **width** | sensors | pop | lines | F_ST |
|---|---|---|---|---|---|---|---|
| **330** | 22 | **0.09** | 3.50 | 2.41 | 53 | 1 | 36 |
| 220 | 17 | 0.01 | 3.06 | 3.03 | 102 | 1 | 61 |
| 165 | 16 | 0.02 | 2.53 | 3.08 | 86 | 1 | 56 |
| 110 | 12 | 0.03 | 2.67 | 3.29 | 114 | 1 | 51 |
| 66 | 15 | 0.09 | 4.40 | 3.59 | 173 | 1 | 52 |
| 33 | 11 | 0.28 | 5.40 | 4.35 | 142 | 1 | 59 |
| 11 | 12 | 0.78 | 6.08 | 5.11 | 129 | 1 | 59 |
| 3 | 9 | **2.32** | 5.88 | 4.98 | 143 | 1 | 49 |
| **1** | 10 | **2.83** | 7.40 | 6.49 | 143 | 1 | 47 |

## Against what was pre-registered

| # | Finding | Result |
|---|---|---|
| 1 | **Hidden nodes become sensitive to the price** | **LANDED.** 0.09 to **2.83**, a thirty-one-fold range, against world 14's 0.15 to 1.97 over the same prices and horizon. The response is more than twice as steep, and 2.83 nodes per creature is the highest this project has recorded. |
| 2 | **Brains get narrower before they get shallower** | **FAILED, and it could never have succeeded.** Width runs 3.50, 3.06, 2.53, 2.67, 4.40, 5.40, 6.08, 5.88, 7.40 as the price falls: brains get **wider**, and the number tracks sensors almost exactly. See below. |
| 3 | **Perception and computation trade** | **FAILED, and reversed.** The half of surviving worlds carrying the most sensors carries **more** nodes, 1.51 against 0.43, not fewer. And the split is confounded: worlds at a low price have more of both, so splitting by sensors is largely splitting by price in disguise. |
| 4 | **The cheap end shows something the flat charge hid** | **PARTIALLY.** Nodes reach 2.83 per creature at a price of 1, higher than anything recorded before. Whether those brains compute anything is untouched by this world. |

And what was pre-registered **not** to happen:

| Prediction | Result |
|---|---|
| **Extinctions will rise sharply at the expensive end, possibly to everything** | **CONFIRMED at the top and it is severe**: 22 of 24 dead at the control against world 14's 16. It falls to 9 at the cheap end. |
| **`lineages` will be 1** | **CONFIRMED**, every price. **F_ST runs 36 to 61**, so the spatial structure world 14 built survives a much dearer brain. |
| **The most likely outcome is still nothing** | **Wrong.** The price response is real and large. |

## Why finding 2 could never have worked

**A hidden node always reads every input. There is no such thing as a narrow
one.**

`brain:founder/3` draws each hidden row at `width(Sensors, inputs)`, which is
`Sensors + 1`, and every structural mutation preserves that. So the width column
above is not a measurement of anything a creature can evolve: it is
`sensors + 1`, arithmetic, reported back.

That makes finding 2 unanswerable rather than answered, and it has a consequence
this world was built without noticing:

**The only way to make a hidden node cheaper is to drop a sensor.** Charging by
wiring was supposed to let a lineage economise on connections while keeping its
senses. It cannot. It can pay the bill or blind itself, and there is nothing in
between.

That is why finding 3 reversed as well. Sensors and nodes cannot trade against
each other when the only lever moves both.

**Entered as `H.11`.** It is the first structural limit found in the brain rather
than in the economy, and it bounds every future world that tries to price
computation: **a cost cannot select for a shape the genome cannot represent.**

## What this world did establish

**Charging by wire makes computation far more price-sensitive than charging by
node.** Thirty-one-fold against thirteen. The mechanism is not mysterious: under
a flat charge a node costs the same to a creature with six senses as to one with
none, so most of the population was being under-billed for its brain and the
price had little to bite on.

**And it costs survival, heavily.** 22 of 24 dead at the control. A brain priced
by its wiring is expensive enough that most foundings do not get through, which
is the risk the gate flagged before the run rather than after.

## What this teaches

- **The gate worked, and it does not catch everything.** It confirmed the trait
  was selectable, and it was. It had nothing to say about whether the *shape*
  being priced was one the genome could vary, and that is what finding 2 was
  really asking. **A second line belongs in the template: can the genome
  represent the variation this price is meant to select among?**
- **A measurement that is forced by arithmetic is not a measurement.** Width
  looked like a new instrument and is `sensors + 1` wearing a different name. It
  was flagged as a possible tautology before the run and turned out to be exactly
  that, which is the first time this week a trap was named in advance rather than
  discovered afterwards.
