# Pre-registration: world 19

**Written before world 19 was built.** Corrects register entry **`H.11`**, and
bears directly on **`B.10`**. World 18 is superseded, not edited.

**A weight that is zero does nothing and is charged for anyway.**

## THE SELECTABILITY GATE

Measured 2026-08-02 by `scripts/what_does_a_neuron_cost.escript` and the weight
census below, both before anything was built.

| | value | how it was obtained |
|---|---|---|
| what a creature earns, per tick | **94** | measured, 24 seeds at 2,000 ticks |
| what one mutation of this trait changes the bill by | **10.0 a tick**, one weight at `neural_cost / upkeep_divisor` | computed from the cost expression |
| that as a share of earnings | **10.6%** | |
| the drift threshold | ~1% | |
| **does it clear** | **YES, ten times over** | |
| what the FULL complement costs | a node at 2.2 sensors is 3.2 weights, **33.6%**; a node with one live weight is **10.6%** | |
| **is that well under half** | **YES, once width can vary. It is not today, which is the point** | |

**Can the genome REPRESENT the variation this is meant to select among? YES, and
measured rather than assumed.** `brain_range` is 8 and `brain_mutation` is 1, so
a weight drifts in single steps across ±8 and zero is reachable. Censused over
four settled worlds: **3.4%, 8.4%, 9.2% and 15.2% of all weights are already
exactly zero**, with no incentive whatsoever, and 11% to 33% sit within one step
of zero.

**So the trait exists and is already varying. Nothing rewards it.**

## Why there is a world 19

`H.11`: *"`brain:founder/3` draws each hidden row at `width(Sensors, inputs)`,
which is `Sensors + 1`, and every structural mutation preserves it. So the
topology is fully connected by construction and a lineage cannot economise on
connections: the only way to make a hidden node cheaper is to drop a sensor. A
cost cannot select for a shape the genome cannot represent."*

World 16 charged a node by its wiring in order to select for narrower brains and
got wider ones, because width is not a trait: it is `sensors + 1` reported back.
**This makes width a trait.**

And `B.10`: a hidden node costs **33.6% of income** at a price that was never
chosen. Nine creatures in 431 carry one. **A node with one live connection would
cost 10.6%, which is what a sensor costs, and sensors are carried at 2.19 per
creature.**

## The single change

**A weight costs only if it is non-zero.**

`brain:hidden_weights/1` and `brain:output_weights/1` count live weights instead
of row length. Nothing else moves.

**IT COSTS NO NEW CONSTANT**, which no world here has managed before. The rule is
that you pay for what you use, and a weight of zero contributes exactly zero to
`dot/2`, so a creature behaves identically with or without it.

**NO NEW MUTATION OPERATOR EITHER.** Silencing is what the existing weight drift
already does; nothing has ever paid it for doing so. NEAT needs innovation
numbers to align genomes for crossover and reproduction here is clonal, so none
of that machinery is required.

**`neural_cost` IS SWEPT IN THE SAME EXPERIMENT**, which is not a second change:
it is the constant this rule re-prices, and `B.10` says its control was set to
reproduce a flat rent world 13 deleted and sits three to five times above the
step change world 13 found. **One world answers both entries or neither.**

## What would count as a finding

1. **Brains get NARROWER.** The thing `H.11` says is currently impossible.
   Instrument: **live weights per hidden node**, new, part of this world.
2. **Hidden nodes become common.** From 0.01 to 0.08 per creature at the world 18
   control. Instrument: `hidden_mean`, exists.
3. **The price at which computation appears moves down.** World 13 put the step
   change between 110 and 66. Instrument: the `neural_cost` sweep.
4. **Survival improves at the control.** `B.10`'s claim, re-measured on
   reproducible physics: world 16 saw 22 of 24 dead at the control against 9 at
   the cheap end. Instrument: the dead count per price.

## What will NOT happen, stated in advance

**Silencing may not persist.** Drift is symmetric and will knock a weight off
zero as readily as onto it, so a saving of 10.6% of income has to be held there
by selection every generation. **If nodes get cheaper and no narrower, that is
drift winning and the answer is that the trait is expressible but not holdable.**

**Nothing here makes a brain useful.** It makes one affordable. `H.12` says
movement cannot depend on hunger whatever the brain costs, and that is untouched.

**The strongest available negative**: if width becomes a trait, is selected on,
and computation still does not appear, then price was never what suppressed it
and `B.10` is answered rather than corrected.

## THE STALE INSTRUMENT GATE

| script | which rule it reads | last verified against it |
|---|---|---|
| `what_does_a_neuron_cost.escript` | `hidden_weights`, the bill | **owed: its marginal-cost arithmetic assumes full rows** |
| `can_an_act_be_priced.escript` | `output_weights` | **owed: same** |
| `sweep_acts.escript` | `output_weights` via the bill | unaffected in shape, values will move |
| `is_meat_worth_eating`, `how_often_do_they_meet` | not the bill | unaffected |

## The commitments

1. Rules frozen before the first run. Superseded, not edited.
2. Every seed reported, including **nothing happened**, and the dead.
3. `world:ruleset/0` says 19 in the same commit as the rules.
4. `lineages`, `depth`, uptake spread and **F_ST** beside the population.
5. New tests go red against world 18's physics before they are believed.
6. No test inherits `neural_cost` from the defaults; it is the swept constant.
7. No physics constant in a node config. `I.9`.
8. `cross-vm` passes before any result is claimed. `G.6`.
