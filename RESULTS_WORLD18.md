# Results: world 18

**An act is tissue, charged by its wiring at a swept `act_cost`.** Scored against
`PREREGISTRATION_WORLD18.md`, frozen before the rules.
`scripts/sweep_acts.escript`, 48 seeds, 20,000 ticks.

## THE HEADLINE

**A uniform price selects on exactly the capabilities whose loss is survivable,
and not at all on the ones whose loss is fatal.**

| `act_cost` | dead | purposes | `move` | `breed` | `eat` | `grow` | sensors | pop |
|---|---|---|---|---|---|---|---|---|
| **0**, world 17 | 40 | 3.71 | 96 | 99 | 91 | 84 | 2.18 | 103 |
| 8 | 40 | 3.38 | 98 | 99 | 66 | 73 | 2.46 | 69 |
| **16** | 41 | 3.74 | 85 | 99 | 94 | 94 | 1.98 | 96 |
| 33 | 43 | 3.35 | 94 | 98 | 61 | 80 | 2.19 | 66 |
| 66 | 44 | 2.49 | 98 | 96 | **28** | **25** | 1.92 | 53 |
| 132 | 44 | 2.18 | 81 | 96 | **21** | **18** | 1.75 | 54 |
| 330 | 47 | 2.06 | 100 | 97 | **2** | **6** | 1.20 | 94 |

`move` and `breed` are carried by 81 to 100% of creatures **at every price**.
`eat` falls from 91% to **2%** and `grow` from 84% to **6%**.

**Losing `breed` ends a lineage in one generation. Losing `move` is close to
fatal since world 14 made sessile life impossible.** Those are the two that do
not move. `eat` and `grow` are the two a creature can live without, and those are
the two that go. **The price did not find the least useful organs. It found the
ones whose absence is survivable**, which is a different thing and is the whole
result.

## The four pre-registered findings

**1. The number of purposes carried responds to price. LANDED.** 3.71 per
creature at the control to **2.06** at the dearest. It is the first thing in this
world that a price has moved cleanly since world 13 moved perception.

**2. `breed` is invariant and `eat` and `grow` are not. LANDED, and it was
predicted in advance from `H.12`**, which was itself found the same day. That is
the first time a prediction here has come from another finding rather than from a
guess about ecology. `move` was not named in the prediction and behaved the same
way, for the same reason: world 14 left no sessile survivors, so a creature that
cannot move is a creature that dies.

**3. Perception and action trade. WEAK, and the direction only.** Sensors run
2.18, 2.46, 1.98, 2.19, 1.92, 1.75, **1.20**: down overall and not monotone. An
output is `sensors + 1 + hidden` wide, so every sensor makes every output dearer,
and the coupling is real; the effect is small against the noise of four to eight
surviving seeds. **World 16 could not separate perception from computation
because its only lever moved both. This has the same problem from the other
side** and does not solve it.

**4. It costs survival. LANDED.** 40, 40, 41, 43, 44, 44, **47** dead of 48. Every
price in this register has cost survival and this is no exception.

**Hidden nodes remain at nothing**, 0.00 to 0.02 per creature, at every price.
Nothing here made computation worth having, which nobody claimed it would.

## The observation from before the sweep, which did not survive it

Recorded in the commit that built this world, from one seed: at `act_cost` 8 the
output bill is 1.84 a tick, about 2% of income, and seed 5 fell from 82 creatures
to 5. I offered a mechanism, that the charge is **regressive** because a newborn
inherits its parent's whole brain and pays for it while carrying a fraction of
the frame.

**The sweep does not support it.** At `act_cost` 8 the death count is **40 of 48,
identical to the control**. Seed 5 was seed 5.

**That is the fifth time in this project a mechanism has been proposed before
being measured, and the fourth time the measurement disagreed.** It is in the
record because it was written down as an observation rather than a finding, which
is the only reason it costs nothing.

## `act_cost` is 16, and the rule that chose it

**Viability, among the values that clear the pre-registered floor.**

The floor is in the gate table of `PREREGISTRATION_WORLD18.md`, fixed before the
run: a mutation must move the bill by about 1% of income or drift swamps it,
which puts the floor near `act_cost` 10. **0 and 8 are below it**, so 8 would
measure drift exactly as world 15's mouth did, and 0 is not a price at all.

Among 16, 33, 66, 132 and 330, the fewest deaths is **16**, at 41 of 48 against
the control's 40. **One seed in 48 is what pricing acts costs.**

**AND AT 16 THE EFFECT IS NOT VISIBLE**, which has to be said plainly: `eat` and
`grow` sit at 94% and 94%, higher than the control's 91 and 84. The shedding
begins at 66 and is unmistakable by 330. **So the gate's floor is a necessary
condition and not a sufficient one**: clearing the drift threshold makes a price
selectable in principle, and this one needs to be four times the floor before
anything moves. That is a new thing to know about `H.10` and it belongs there.

**The honest reading is that the fleet will run a price that changes almost
nothing**, chosen by a rule fixed in advance, and that the interesting part of
this world lives at prices no island should run.

## What this leaves

- **`H.10` gains a third bound.** It had a floor, and today a roof. This adds
  that the floor is not sufficient: a price can clear it and still move nothing
  for another factor of four.
- **Whether shedding `eat` is adaptive or merely tolerated.** At 330 only 2% of
  creatures can eat another creature and 47 seeds of 48 are dead. That is
  consistent with a population being stripped of everything it can survive
  losing, on its way out, rather than with a tradeoff being resolved.
- **`H.7` is corrected rather than closed.** The pre-registration said that if
  pricing acts changed only a census and no creature acted differently, acts were
  never a free good worth pricing. A creature without `eat` never eats. It is a
  behavioural change, not a census change.
