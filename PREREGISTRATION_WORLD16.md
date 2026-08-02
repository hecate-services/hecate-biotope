# Pre-registration: world 16

**Written before world 16 was built.** Corrects register entry **H.9**, which is
**B.3** still standing after world 13 marked it settled. World 15 is superseded,
not edited.

## THE SELECTABILITY GATE

The first world to go through it. It exists because world 15 did not.

| | value | how obtained |
|---|---|---|
| what a creature earns, per tick | **~100**, measured 87 to 231 | `scripts/where_does_it_go.escript` |
| what one mutation changes the bill by | **10 to 60 a tick**: gaining or losing a hidden node costs `inputs × neural_cost ÷ divisor`, and inputs is sensors + 1 | computed from the mutation operator and the cost expression |
| as a share of earnings | **10% to 60%** | |
| the drift threshold, `1 / (2·Ne)` | **~1%** at an effective population near 50 | |
| **does it clear** | **yes, by ten to sixty times, at every body size** | |

**It clears because a hidden node arrives WHOLE.** That is the same property that
let world 13 move sensors with a price and denied it to world 15's drifting
mouth, and it is now checked before anything is built rather than diagnosed
afterwards.

**The gate also flags the risk in the other direction**, which no other world has
had to state: at the control price a three-sensor creature would pay **40% of its
income per hidden node**. That is not too small to select on, it is possibly too
large to survive. The sweep below is what that risk requires.

## Why there is a world 16

**A hidden node costs the same whatever it reads.** `brain:hidden_count/1` is
`length(H)`, so a node wired to six inputs costs exactly what one wired to a
single input costs.

`B.3` objected to precisely this and is marked **CORRECTED** by world 13. World
13 changed how the charge is levied, from a flat rent to tissue, and did not
change **what it is levied on**. The entry reads as settled and the shape it
complained about is still here, which is why `H.9` exists.

**And it is the one pricing defect that bears on the project's own question.**
This world cannot currently express the difference between a cheap reflex and an
expensive integrator: a brain that combines everything it can see is free
relative to one that looks at a single number. No neural economy anywhere works
that way, and fifteen worlds have reported hidden nodes at the floor without the
cost of a large one ever having been charged.

## The single change

**A hidden node is charged by the weights it holds, not by existing.**

`hidden_count/1` becomes a count of weights rather than of nodes, so a node with
`I` inputs costs `I` units of neural tissue instead of one. Everything else is
untouched: the same `neural_cost`, the same `carrying/2`, the same tissue
expression since world 13.

**NO NEW CONSTANT**, and one consequence worth naming in advance: **sensors and
brains become coupled.** Gaining a sensor now raises the price of every hidden
node the creature carries, because every hidden vector gains a column. That is
not a side effect to be minimised; it is what a wiring cost means, and it is the
first time in this world that perception and computation trade against each
other rather than being billed separately.

**The magnitude is SWEPT**, exactly as world 13 swept it. The shape change alone
makes a typical brain about four times dearer at the control, so `neural_cost`
runs from 330 down, every value published, and **330 is the point where the
comparison with worlds 13 to 15 lives.**

## What would count as a finding

1. **Hidden nodes become sensitive to the price**, having been at 0.00 to 0.43
   across every world at the control. **This is the target**: any organ this
   world can select on should move when its price moves, and a flat charge is
   why it has not.
2. **Brains get NARROWER before they get shallower.** A hidden node reading two
   inputs survives where one reading six does not, so the surviving brains should
   be wired to fewer inputs at a given depth. Reported as mean inputs per hidden
   node, which no world has ever measured.
3. **Perception and computation trade.** Creatures carrying many sensors carry
   fewer hidden nodes than creatures carrying few, at the same price, because the
   sensors made the nodes expensive. Reported as the correlation across surviving
   worlds.
4. **The cheap end shows something the flat charge hid.** Below some price a
   brain wide enough to combine several inputs becomes affordable, and if
   computation is ever going to appear here that is where it appears.

## What will NOT happen, stated in advance

**Extinctions will rise sharply at the expensive end**, and possibly to
everything. A three-sensor creature paying 40% of income per node is a real risk
and the gate says so above rather than discovering it in the results.

**`lineages` will be 1** and **F_ST** is the number reported beside it.

**The world is still perfectly constant.** **A.4**, **G.3** and **G.5** stand.

**Actuators are still free** (`H.7`) and eating is still the only act with an
organ. This world does not touch that.

**And the most likely outcome is still nothing.** Sixteen worlds have produced no
lasting computation. Making a brain's cost realistic is not the same as giving it
something to compute, and `H.10` is explicit that a price can only make a trait
visible to selection, never useful. **If hidden nodes move with the price and
then sit at the floor wherever the price is survivable, that is the answer and it
is worth having.**

**The strongest available negative:** hidden nodes are already so rare that
charging more for them changes nothing measurable, and the sweep reads flat at
every price. That would say the flat charge was never what held them down.

## The commitments

1. Rules frozen before the first run, not changed in response to it. This file is
   superseded, not edited.
2. Every price reported, including **nothing happened**, and including the dead.
3. `world:ruleset/0` says 16 in the same commit as the rules, and a test fails if
   it does not.
4. `lineages`, `depth`, the uptake spread and **F_ST** reported beside the
   population.
5. New tests go red against world 15's physics before they are believed.
6. **Mean inputs per hidden node is reported whatever happens**, because finding
   2 is the only one that could distinguish a brain getting cheaper from a brain
   getting simpler, and no world has ever measured the shape of these brains at
   all.
