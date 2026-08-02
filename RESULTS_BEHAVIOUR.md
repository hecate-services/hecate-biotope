# Results: the behavioural test

**Scored against `PREREGISTRATION_BEHAVIOUR.md`, frozen before the runner.**
`scripts/does_hunger_change_the_choice.escript`, 48 seeds settled 2,000 ticks,
585 creatures alive, 431 of them carrying a `self` sensor.

## THE HEADLINE

**The brains are not ornaments, and the question was malformed.**

| | of 431 `self`-carrying creatures |
|---|---|
| change **where they move** when hungry | **0** |
| change whether they want to **breed, grow or eat** | **428** |
| whose every candidate cell shifts by an identical amount | 430 |
| who ever cross a reading boundary in their own life | 206 |

**Almost every creature conditions its actions on hunger. Not one conditions its
movement on hunger. Neither is a fact about brains: both are facts about the
shape of the decision.**

## Why movement cannot depend on hunger, measured rather than asserted

Moving is a **ranking**. `world:appraise/3` scores the seven cells a creature
could occupy and `pick_best/2` takes the best. The `self` reading is **not
spatial**: `body:spatial(self)` is `false` and `world:read/5` returns the same
number whatever cell is being considered. So hunger adds **the same constant to
all seven scores**, and a constant added to every alternative cannot reorder
them.

**430 of 431 creatures show exactly that**: every cell's score moves by an
identical amount between one store and the next. **A creature could weight hunger
a thousandfold and still move identically.**

The single exception has a hidden node, whose rectifier is the only nonlinearity
in this world and the only thing that can break the symmetry. **It still does not
change its ranking.** Nine creatures in 431 carry a hidden node at all, which is
`H.11` and `F.3` arriving together: the one component that could make hunger
matter to movement is the component nothing can afford.

Acting is a **threshold**. `breed_one/3` asks `breed > 0`, `build_one/3` asks
what `grow` affords, and `willing_to_eat/4` asks the same of `eat`. There is one
option and nothing for a constant to cancel against, so the same reading decides
the answer. **428 of 431 flip at least one of the three somewhere on the ladder.**

## The four pre-registered findings

**1. Some creature ranks the cells differently hungry than full. ZERO, and it is
structural rather than evolutionary.** Not one creature in 431, at any store from
0 to 12,800. The pre-registration expected zero and expected it to mean the
sensor was decorative. **It means something better defined**: the sensor is read,
weighted and acted on, and movement is the one decision it provably cannot reach.

**2. The share whose reading ever changes within their own store range. 206 of
431, just under half.** So the hunger sense is not inert in life: for most of a
population it says at least two different things. Finding 1's zero is therefore
NOT the dull artefact the pre-registration warned it would probably be. **The
warning was right to be written and wrong about this world.**

**3. Whether the threshold sits where a survival decision is made. Not answered
here.** The act flips somewhere on a ladder spanning 0 to 12,800, and where it
flips per creature is not reported. Owed.

**4. Weight on the `self` column. Mean 21**, from `brain:attention/2`, against a
weight range of ±`brain_range`. Non-zero, so the measurement is taken, paid for
and read. The movement pathway consumes it and can do nothing with it.

## What this changes

**The handover's framing was: "show an evolved creature the same situation hungry
and full and see whether it chooses differently. If it does not, the brains are
ornaments however many nodes they carry."** It does not, for movement, and the
brains are not ornaments. The conditional is false because a ranking and a
threshold are different machines and only one of them can hear a constant.

**`H.12`, and it is the third of its kind.** `H.11` said a cost cannot select for
a shape the genome cannot represent. This says **a sense cannot inform a decision
whose form cancels it**, and neither is discoverable by running more seeds.
`H.10`, `H.11` and `H.12` are all the same lesson: before measuring whether
something evolved, check whether this world can express it at all.

**What it does NOT say.** It does not say creatures forage well, or that the acts
they condition are conditioned sensibly, or that any of it improves survival.
`breed > 0` flipping with store is a mechanism working, not a strategy working.
Whether hunger-conditional breeding is any GOOD is a different measurement and
nobody has made it.

## What is owed

- **Where the threshold sits** per creature, finding 3.
- **Whether conditioning helps.** Compare survival between lineages that flip
  their acts with store and lineages that do not.
- **A spatial hunger signal, if movement is ever meant to depend on state.** The
  honest options are a hidden node cheap enough to carry, or an input that
  differs per cell. Both are worlds and neither is proposed here.
