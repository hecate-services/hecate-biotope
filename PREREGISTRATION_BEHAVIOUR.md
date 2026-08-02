# Pre-registration: the behavioural test

**Written before the runner.** Not a world: it changes no rule and adds no
constant. It is the first measurement here that asks what a creature **does**
rather than what the population **is**.

**This exists so we can say whether the brains are ornaments.** Every measurement
in seventeen worlds is a census: how many sensors, how many nodes, how much
reach. **A census cannot tell an organ that works from an organ that is carried.**
`F.4` was just refuted and its refutation ends by saying the next instrument has
to watch individuals rather than totals. This is that instrument.

## THE SELECTABILITY GATE

| | value | how obtained |
|---|---|---|
| what a creature earns, per tick | ~100, measured 87 to 231 | `scripts/where_does_it_go.escript` |
| what one mutation changes the bill by | **n/a**: this changes no cost | |
| as a share of earnings | n/a | |
| the drift threshold | n/a | |
| **does it clear** | **not applicable** | |

**Can the genome represent the variation this is meant to detect?** **Yes, and
checked rather than assumed.** `world:inputs/5` puts the `self` reading in the
input vector, `brain:evaluate/3` computes every output as `dot(WI, Inputs) +
dot(WH, Acts)`, and the `move` output scores each candidate cell. So an output's
value depends on the `self` column through an ordinary weight. **No hidden node
is required**, which matters because `H.11` says a hidden node reads every input
and there are almost none in any world. A hunger-conditional decision is
representable by a single weight.

## The claim being tested

**Does an evolved creature choose differently when hungry than when full?**

If it does not, the `self` sensor is decorative, the brain is a fixed function of
the outside world, and "perception did not rise" stops being the interesting
question because perception is not being USED even where it exists.

## The two questions, which are different and both required

**1. CAN it?** Hold the world fixed, hold the creature's position fixed, vary
**only its store**, and see whether its ranking of the cells it could move to
changes.

**2. DOES IT EVER GET THE CHANCE?** A `self` reading is `energy div unit`, and at
the world 17 default the unit is 400. **A creature whose store stays inside one
400-wide band reads the same number its whole life**, and no brain can condition
on a constant. So measure the distribution of readings creatures ACTUALLY
experience.

**Question 2 can make question 1 moot and the reverse is not true.** If the
reading never changes in life, a null on question 1 says nothing about brains and
everything about the instrument they are given. **Reporting question 1 alone
would be the sixth instrument failure in this project and it would look like a
finding.**

## The instrument, named before the run

- `world:appraise/3`, to be added: what a creature makes of each cell it could
  move to, given a store. It calls the same `value/5` the world calls. **Not a
  reimplementation**: `I.6` was an instrument that computed its own version of a
  rule and drifted from it.
- **Scores, not the chosen cell.** `pick_best/2` breaks ties by drawing from the
  generator, so two identical appraisals can yield two different moves. Comparing
  choices would report the tie-break as a behavioural difference. **The claim is
  about the ranking.**
- Creatures with no `self` sensor are counted separately and are **not** in the
  denominator for question 1. They cannot respond by construction and averaging
  them in would dilute the answer with creatures that were never asked.

## What would count as a finding

1. **Some creature, somewhere, ranks the cells differently hungry than full.**
   Measured as the share of `self`-carrying creatures whose ranking changes
   across the store ladder. **Zero is a real answer and the expected one.**
2. **The share of `self`-carrying creatures whose reading ever changes within
   their own observed store range.** If this is near zero, finding 1 is
   unanswerable and that is the result.
3. **Whether the threshold, if any, sits where a survival decision would be
   made.** A creature that changes its mind only between 4,000 and 4,400 has a
   sense that resolves nothing about being nearly dead.
4. **How much weight the `self` column carries**, from `brain:attention/2`, which
   already exists. Zero weight is a creature that takes the measurement, pays for
   it, and acts on it with nothing.

## What will NOT happen, stated in advance

**The most likely outcome is that nothing changes anything, for the dullest
possible reason**: almost no creature carries a `self` sensor, and those that do
read 0 for their whole life because the unit is 400 and a typical store is
smaller. **That is not evidence that brains are useless.** It is evidence that
the hunger sense has never once been in a position to say anything, which is a
statement about `F.3` and the choice of `sense_scale`, not about computation.

**A positive result would be the first behavioural finding in this project** and I
do not expect one. If it appears, it must be checked against the tie-break above
before it is believed.

**This measures capability, not use in anger.** A creature that COULD rank
differently at a store it never reaches has still never made a hunger decision.
Finding 2 is what keeps finding 1 honest.

## The commitments

1. The instrument is named above and calls the world's own code.
2. Every creature reported, including the ones with no `self` sensor and
   including **nothing happened**.
3. Ranking, not chosen cell, so the generator's tie-break cannot be read as
   behaviour.
4. Findings 1 and 2 reported together, always. Neither is publishable alone.
5. Run only on physics that passes the `cross-vm` column of
   `scripts/same_seed_same_world.escript`, since before 2026-08-02 the same seed
   did not give the same creature. See `G.6`.
