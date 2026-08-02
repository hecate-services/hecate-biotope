# Pre-registration: world 18

**Written before world 18 was built.** Corrects register entry **`H.7`**. World 17
is superseded, not edited.

**This exists so that acting costs something.** Every organ in this world is
priced and every act is free, so a creature carrying all four purposes pays
exactly what one carrying none pays. It is the largest unpriced thing left, and
it is the reverse of the arrangement the register spent five worlds building.

---

## THE SELECTABILITY GATE

Measured by `scripts/can_an_act_be_priced.escript` **before anything was built**,
which is what `R.1` exists for.

| | value | how it was obtained |
|---|---|---|
| what a creature earns, per tick | **94**, from `absorbed` over ticks and heads | measured, 24 seeds at 2,000 ticks |
| what one mutation of this trait changes the bill by, per tick | **`act_cost` ÷ 11**, since an output is ~3 weights over a divisor of 33 | computed from the mutation step and the cost expression |
| that as a share of earnings | **`act_cost` ÷ 1034** | |
| the drift threshold, `1 / (2·Ne)` | ~1% at these population sizes | Ne estimated from the population |
| **does it clear the threshold** | **above `act_cost` ≈ 10** | |
| what the FULL complement costs, as a share of income | **0.24% × `act_cost`**, at the ~2.5 outputs creatures carry | measured |
| **is that well under half** | **below `act_cost` ≈ 200** | |

**So the window is roughly 10 to 200 and the sweep spans both walls**, 0 to 330,
so the boundaries are measured rather than assumed. **Reusing `neural_cost` at
330 was the obvious build and the gate says it cannot work**: 28.4% of income per
output and **94.7% for the complement**, which does not price acting, it bans it,
and would have read as a dramatic result.

**Can the genome REPRESENT the variation this price is meant to select among?**

**COUNT yes, WIDTH no, and the experiment is therefore only about count.**
`brain:toggle/4` adds and removes a whole purpose, so how many a creature carries
is a trait. An output's WIDTH is `sensors + 1 + hidden nodes`, exactly as `H.11`
found for hidden nodes: it is not a trait, it is the body reported back.
**Charging an output by its wiring cannot select for narrower outputs and it is
not being asked to.** World 16 made precisely that mistake and this world names
it in advance.

**AND `H.12` SAYS THE FOUR PURPOSES ARE NOT EQUIVALENT.** Losing `breed` ends the
lineage in one generation, which is not selection against a price but removal
from the experiment. Losing `move` is survivable and world 14 made it close to
fatal. So a uniform price can only really bite on `eat` and `grow`, and **that
asymmetry is a prediction rather than a nuisance.**

---

## Why there is a world 18

`H.7`: **outputs pay nothing.** Sensors pay by reach, hidden nodes pay by wiring
since world 16, and a purpose is free. It also means `eat` being present is not a
tradeoff at all: world 15 priced the MOUTH and left the appetite free, so only
half of `H.1` was ever charged.

## The single change

**An output is tissue, charged by its wiring, at a swept `act_cost`.**

```
tissue = structure + mouth
       + (body mass + hidden weights) × neural_cost
       + output weights × act_cost
```

**It costs one new constant and that constant is SWEPT**, every value published:
**0, 8, 16, 33, 66, 132, 330**. Nothing derives a price for an act. **0 is world
17 exactly**, so the old behaviour sits inside the sweep rather than outside the
comparison, and the two walls the gate predicts sit inside it too.

## What would count as a finding

**Each names an instrument, and `purposes_hist` does not exist yet, so it is part
of this world.** `I.7`: a pre-registered finding that names no instrument is a
finding that cannot fail.

1. **The number of purposes carried responds to price.** Instrument:
   `purposes_mean` in `world:snapshot/1`, new. Under world 17 it is whatever it
   is and no price can have moved it, because there was none.
2. **`breed` is invariant and `eat` and `grow` are not.** Instrument:
   `purposes_hist`, a count of carriers per purpose, new. **This is the sharpest
   thing here**: a uniform price with a non-uniform consequence, predicted from
   `H.12` before the run rather than explained after it.
3. **Perception and action trade.** An output is `sensors + 1` wide, so every
   sensor makes every output dearer. Sensors should fall as `act_cost` rises.
   Instrument: `sensor_mean`, which exists. **This is world 16's coupling
   arriving from the other side**, and world 16 could not separate the two
   because its only lever moved both.
4. **It costs survival**, like every price in this register. Instrument: the
   dead count per scale in the sweep.

## What will NOT happen, stated in advance

**The most likely outcome is that the count moves and nothing else does**, which
would make this the fourth price to change a census and no behaviour.

**Narrow outputs will not appear**, because width is not a trait. Anyone reading
a fall in total output weight as "brains got tidier" is reading a fall in
sensors.

**THE STRONGEST AVAILABLE NEGATIVE**: `H.10`, `H.11` and `H.12` are three
findings that this world could not express what was being asked of it, and the
honest prior is that this is a fourth. **If pricing acts changes only how many
purposes are carried, and no creature acts differently for it, then acts were
never a free good worth pricing** and `H.7` should be closed as answered rather
than corrected.

**Extinctions will rise.** Every price here has cost survival and there is no
reason this one will not.

---

## THE STALE INSTRUMENT GATE

Scripts that read the bill, and when each was last checked against it.

| script | which rule it reads | last verified against it |
|---|---|---|
| `where_does_it_go.escript` | `tissue/2`, income and upkeep | **owed: must be re-run against world 18** |
| `income_and_upkeep.escript` | `tissue/2` | **owed** |
| `can_an_act_be_priced.escript` | `tissue/2`, output wiring | 2026-08-02, this world's own gate |
| `does_hunger_change_the_choice.escript` | `brain:evaluate/3`, not the bill | unaffected: world 18 changes no reading |
| `sweep_senses.escript` | `sense_scale` | unaffected |

**`I.6`: an instrument is correct when written and is made wrong by a change to
the thing it measures.** The first two read the bill this world edits.

## The commitments

1. Rules frozen before the first run. This file is superseded, not edited.
2. Every seed reported, including **nothing happened**, and including the dead.
3. `world:ruleset/0` says 18 in the same commit as the rules.
4. `lineages`, `depth`, the uptake spread and **F_ST** reported beside the
   population.
5. New tests go red against world 17's physics before they are believed.
6. **No test inherits `act_cost` from the defaults.** It is the swept constant of
   this world, so every test of the rule sets it explicitly. Three tests of the
   reading rule had to be repaired for exactly this in world 17.
7. **`act_cost` lives in `world:defaults()` and in no node config.** `I.9`.
8. **The `cross-vm` column of `same_seed_same_world.escript` passes before any
   result is claimed.** `G.6`: before 2026-08-02 the same seed did not give the
   same world, and every number from those worlds is unreproducible.
