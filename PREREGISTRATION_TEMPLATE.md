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
| what the FULL complement of this organ costs, as a share of income | | **the roof** |
| **is that well under half** | | **if no, the price is a prohibition, stop** |

**Measured, not assumed.** The last estimate of income here was out by a factor
of ten, which is what turned a fifty-percent selection differential on paper into
a four-percent one in fact.

**AND A SECOND QUESTION THE GATE MUST ASK, added after world 16.** Can the
genome REPRESENT the variation this price is meant to select among? World 16
charged a hidden node by its wiring in order to select for narrower brains, and a
hidden node always reads every input, so narrowness is not a trait a creature can
have. The price was selectable and the shape was not, and no amount of data would
have said so. See `H.11`.

**AND A ROOF, added after running the gate on `R.5` before building it.** A price
reused from elsewhere can miss in either direction. World 15's mouth moved the
bill by 0.24% of income and measured drift. Charging an output by its wiring at
`neural_cost` moves it by 28% per output and **94.7% for the complement a
creature actually carries**, which does not create a tradeoff, it bans the organ,
and it would have read as a dramatic result. **Both failures have one cause: a
rate taken from somewhere else instead of swept.** See `H.10`.

**A trait that arrives WHOLE clears this easily and one that drifts usually does
not.** A sensor is gained or lost entire at 10 a tick, which is 10% of earnings;
a mouth drifts in steps worth 0.24%. That difference, and not the ecology, is why
a price moved one and not the other.

---

## THE ENVIRONMENTAL GATE

**Use this instead of the selectability gate when the change is to the WORLD
rather than to a creature. Added 2026-08-04 after the gate above was applied to
the watering hole and reported that it failed.**

The gate above asks whether selection can see a TRAIT'S COST. It is the right
question for "should this organ be priced at X" and the wrong question for
"should the island contain water". **An environmental change does not add a trait
that must clear a drift floor. It changes the landscape that every trait already
present is selected against**, and the differential it creates is usually
enormous rather than marginal.

Applying the trait gate to an environmental change reports a failure that is not
there. See `I.16`.

| | value | how it was obtained |
|---|---|---|
| the differential the change creates, as a share of fitness | | breeding or not, eating or not, living or not: usually tens of percent |
| **is that above the drift floor** | | `1/(2·Ne)`, and **`Ne` is 7.44, so the floor is 6.72%** — `G.10` |
| **can a creature PHYSICALLY respond within one life** | | **the binding question.** Mean life is ten ticks and a creature moves one cell per tick |
| what share of the population could respond | | **if it is low, the change is a filter and not a pressure** |
| **can a creature PERCEIVE the change** | | a requirement nobody can sense is a lottery, not a selection pressure. `?FIELDS` is fixed and adding to it is part of the world |
| what the change costs in new constants | | swept, with every value published, or derived from something that exists |

**⚠ THE PHYSICAL BOUND IS NOT ABOUT MONEY AND IS USUALLY THE ONE THAT BITES.**
The watering hole's first gate found a round trip costs 22–48% of a lifetime's
earnings, which is affordable, and then that **no arrangement of holes is
reachable round-trip at all**: ten ticks of life against one cell per tick. The
money was never the problem. **A rule requiring a creature to reach something
ONCE is affordable where a rule requiring it repeatedly is not**, and that
distinction is a design decision the gate must force.

**AND A FILTER IS NOT A PRESSURE.** If only a quarter of the population can
respond, the change kills three quarters and selects on where they happened to be
born. That may be interesting and it is not adaptation, and a pre-registration
must say which it expects.

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

**AND THE INSTRUMENT MUST EXIST BEFORE THE RUN, added after world 17.** Finding 3
there was "reach differentiates", nothing in the repo reports the distribution of
reach, and the finding could therefore neither succeed nor fail. It was scored
UNTESTED after 24 seeds had been run to 20,000 ticks. **A pre-registered finding
that names no instrument is a finding that cannot fail**, which is the same
defect as a criterion chosen afterwards, wearing the opposite disguise. Name the
script and the field, and if it does not exist yet, it is part of the world.

---

## THE STALE INSTRUMENT GATE

**Any world that changes a rule must list every script that reads that rule and
say when each was last checked against it.**

Added after world 17, where `what_can_they_see.escript` was written in the commit
BEFORE the rules it justified, was CORRECT when written, and was made wrong by
the change it existed to measure. It kept reporting sums under a world that
computes means, and it voided the pre-registration's own first-observation table.

| script | which rule it reads | last verified against it |
|---|---|---|
| | | |

**The check is what a script was COMPILED AGAINST, not what it prints.** The
reach-0 column was byte-identical before and after the repair, because one cell
divided by one cell is the same arithmetic, and reach 0 is the column a reviewer
reads first. **An instrument that agrees with you where you look is the hardest
kind to catch.** See `I.6`.

**And believe a test result only from `rm -rf _build`, whole.** Removing
`_build/test` alone leaves the default profile's beams reachable, and on
2026-08-02 the same unchanged source gave three failures, then one, then none.
See `I.8`.

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
6. **No test names a swept constant by inheriting it.** Every test of a rule that
   involves a swept constant sets that constant explicitly. Three tests of the
   reading rule derived their expected values from `world:defaults()`, so the
   sweep's answer turned them red for the one reason that is not a fault, and a
   test that follows a swept constant asserts nothing about the rule anyway.
7. **A node config may name what a node IS and never what the physics ARE.** A
   constant that lives in a deployment config is a version handshake nobody
   performs: the config and the image ship from different repos on different
   cadences, and an unknown economy key is a startup failure by design. It cost
   two hours of a dead island on 2026-08-02. See `I.9`.
