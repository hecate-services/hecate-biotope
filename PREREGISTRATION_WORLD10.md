# Pre-registration: world 10

> **ARCHIVED COPY** of the criteria as frozen before world 10 ran, committed at
> `6b89286`. [PREREGISTRATION.md](PREREGISTRATION.md) remains the current file
> until world 11 supersedes it. Scored in [RESULTS_WORLD10.md](RESULTS_WORLD10.md).

**Written before world 10 was built.** Corrects register entry **B.7**. World 9
is superseded, not edited:
[PREREGISTRATION_WORLD9.md](PREREGISTRATION_WORLD9.md) and its
[results](RESULTS_WORLD9.md) stand as the record of a different world.

Thermodynamics at the classical scale still governs. See world 7's file for the
four laws applied one at a time; nothing here changes any of them.

## Why there is a world 10

**World 8's rule was applied at one of the two sites where energy enters a
creature.**

Grazing has been bounded since world 8 by `min(uptake, frame, what is in the
cell)`. Predation has never been bounded by anything. `take_them/3` sums the
whole of every weaker creature sharing the cell and hands all of it to the
winner in a single tick, so a creature that can sip four hundred a tick from the
ground can swallow an unlimited number of unlimited-size victims in the same
tick. The live fleet is currently taking 41% of its energy that way.

**Nobody wrote that rule.** It lives in the difference between two code paths,
which is precisely where the movement fare hid for five worlds before entry
**C.6** found it. The lesson recorded there was that a bookkeeping asymmetry can
be a physical rule in disguise and only exact accounting finds it; the method
that follows from it is to ask whether the same law holds at every site. Asked
here, the answer was no.

## The single change

**Capacity bounds meat too.**

    absorbed = min(uptake, frame, what is there)

at both feeding sites rather than one.

**No new constant.** It is the expression already in `absorb/2`.

### What conservation forces

**What the predator cannot hold is a corpse.** The energy has to go somewhere,
and the only place is the ground it died on, deposited through `bury/3` exactly
as every other corpse is, decay and all. That is not a second change: it is the
First Law, and refusing it would destroy energy.

So a kill now leaves **carrion**, and eating something you could not have killed
becomes a way of making a living that nobody designed in.

### What this does not do

**Who dies is unchanged.** The contest still goes to the largest structure and
every weaker creature in the cell still loses. Only how much of them the winner
can use has changed.

It does not price an apparatus for eating, which is how **D.2** frames the
eventual fix. That correction costs a constant and this one does not, so it goes
second: if predation still pays after the cap, pricing an apparatus is a real
experiment, and if it does not, pricing an apparatus nobody uses would measure
nothing.

## What would count as a finding

Stated in advance.

1. **`from_creatures_pct` falls** from its current 18 to 33. The jackpot is
   gone: a kill is now worth what a body can hold, not what the victim was worth.
2. **Carrion appears.** Cells above the ceiling multiply, so `ground_spread`
   rises from its already high 86 and the rose above-ceiling colour, which never
   fired at all before world 9, becomes common.
3. **Lineages survive past one.** Every one of nine seeds collapses to a single
   founding line by 20,000 ticks today. More than one way of making a living is
   the first mechanism this world has had that could hold more than one lineage,
   and this is the direct test of entry **G.1**.
4. **Being large stops being purely good.** A large creature is currently both
   unbeatable and a jackpot. After this it is unbeatable and mostly unusable, so
   the reward for growing should flatten.

## What will NOT happen, stated in advance

**Predation may stop paying entirely and return to zero.** That would undo world
9's first-ever positive on **D.2**, where `from_creatures_pct` moved off zero for
the first time since world 4. It is a real risk of this change and it is written
down here rather than explained afterwards. **It would be a result and not a
failure**, and it must not be reported as a regression.

**Perception will not move.** Nothing here changes what a sensor or a hidden
node costs, and thinking is still unaffordable below a body of roughly 30 to 40.

**The world is still perfectly constant.** Entries **G.3** and **A.4** are
untouched: no day, no season, no weather. Whatever coexistence this produces has
to come from frequency dependence rather than from variation in time.

## The commitments

1. Rules frozen before the first run, not changed in response to it.
2. Reported across every seed and every efficiency, including **nothing
   happened**.
3. A further change is world 11. This file is superseded, not edited.
4. Worlds 1 to 9 are retired and may not be quoted alongside this.
5. **The engine is reported beside the population**, `lineages`, `depth` and the
   uptake spread, as it has been since world 9.
6. **The register audit still follows.** One test applied to every entry:
   required by physics, permitted, or contrary. This world is the fourth in a
   row found by looking rather than by experimenting, and the thing that found
   it was asking whether one law held at every site rather than at the site
   where it was introduced.
