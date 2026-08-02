# Pre-registration: world N

**Written before world N was built.** Corrects register entry **X.Y**. World N-1
is superseded, not edited.

---

## THE SELECTABILITY GATE

**Any world adding or changing a heritable trait must fill this in before
anything is built, and must stop if it fails.**

This exists because world 15 did not have it. A mouth was given a price, forty
eight seeds were run to twenty thousand ticks, all four findings failed, and the
trait had simply drifted: each mutation moved the bill by 0.24% of what a
creature earns, which is below the level at which drift beats selection. **The
experiment could not have worked and one line of arithmetic would have said so.**
See `H.10` and [RESULTS_WORLD15.md](RESULTS_WORLD15.md).

| | value | how it was obtained |
|---|---|---|
| what a creature earns, per tick | | measured, `scripts/where_does_it_go.escript` |
| what one mutation of this trait changes the bill by, per tick | | computed from the mutation step and the cost expression |
| that as a share of earnings | | |
| the drift threshold, `1 / (2·Ne)` | | Ne estimated from the population |
| **does it clear the threshold** | | **if no, stop** |

**Measured, not assumed.** The last estimate of income here was out by a factor
of ten, which is what turned a fifty-percent selection differential on paper into
a four-percent one in fact.

**A trait that arrives WHOLE clears this easily and one that drifts usually does
not.** A sensor is gained or lost entire at 10 a tick, which is 10% of earnings;
a mouth drifts in steps worth 0.24%. That difference, and not the ecology, is why
a price moved one and not the other.

---

## Why there is a world N

What the register says is wrong, and why it is worth a world rather than a
sweep.

## The single change

One rule. State whether it costs a new constant, and if it does, say what
criterion sets it or say that it is **swept** with every value published.

## What would count as a finding

Numbered, specific, and each capable of failing on its own. State the instrument
for each: **a summary of a distribution cannot answer a question about its
shape**, which this project has now learned three times in one investigation.

## What will NOT happen, stated in advance

Including the most likely outcome, which is usually nothing, and **the strongest
available negative** written out so it cannot be reinterpreted afterwards.

## The commitments

1. Rules frozen before the first run, not changed in response to it. This file is
   superseded, not edited.
2. Every seed reported, including **nothing happened**, and including the dead.
3. `world:ruleset/0` says N in the same commit as the rules, and a test fails if
   it does not.
4. `lineages`, `depth`, the uptake spread and **F_ST** reported beside the
   population. The first counts founders and can only fall; the last measures how
   the variation that exists is apportioned in space, and a monoculture can be
   strongly structured.
5. New tests go red against the previous world's physics before they are
   believed.
