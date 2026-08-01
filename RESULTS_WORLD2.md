# Results: world 2

Rules as committed with [PREREGISTRATION_WORLD2.md](PREREGISTRATION_WORLD2.md),
untouched between that commit and this run. 2000 ticks, 8 seeds, radius 10,
5m17s.

> **SUPERSEDED** by world 3. These describe a world whose ground refills at a
> fixed rate regardless of how hard it is grazed, and nothing here may be
> compared with anything measured under [PREREGISTRATION.md](PREREGISTRATION.md).

## The result

```
seed  final  still%  meat%  body  brain  gspr   ground-sensors  creature-  scent-  self-
1     587    100     6      0     1      35     2               2          0       0
2     570    100     6      1     0      9      2               0          2       2
3     585    100     5      0     0      9      1               2          0       2
4     577    100     4      0     0      9      0               0          0       1
5     622    100     3      0     0      9      1               0          0       1
6     577    100     10     1      1     36     -               -          -       -
7     569    100     7      0     1      9      -               -          -       -
8     584    100     10     1      1      9     -               -          -       -
```

**Every seed ended 100% sessile.** Not most of the population: all of it, in
every run. Sensors per creature rounded to zero, hidden nodes to zero, and
carriers of all four fields sat in the low single digits out of roughly 580
creatures. The whole evolvable apparatus of world 2, the open sensor set, the
hidden layer, proprioception, the outputs, was selected away and stayed away.

The landscape stayed flat: `gspr` 9 against a uniform baseline of 10 in six
seeds. The death-deposit rule conserved energy without structuring anything,
because everything dies everywhere at once and is grazed immediately.

0 of 8 extinct, population 569-622 on 331 cells, so about 1.75 creatures per
cell.

## Why, and it is not a tuning failure

This was **arithmetically forbidden**, for every parameter choice, and the proof
is three lines.

1. **Sessility is viable** exactly when `influx > metabolism`.
2. **Equilibrium density** is set by energy balance: all input `C x influx` is
   consumed by the cheapest lifestyle, so `N x metabolism = C x influx` and
   `d = influx / metabolism`.
3. **A mover's income** is `influx / d`, which by (2) is exactly `metabolism`.

So a mover nets `metabolism - metabolism - move_cost` = **minus the fare**,
always, while a stayer nets `influx - metabolism > 0`.

Sessility being viable at all forces `d > 1`, which means every cell is grazed
more than once per tick, which means a mover can never find more than a stayer
already has. **The two cannot both be viable at equilibrium for any positive
move cost.** Movement pays only while virgin ground lasts, and never again.

Predicted `d` was 1.2 and measured 1.75, higher because contest concentrates
energy in survivors, but the direction and the consequence are exactly as
derived.

## What that says about the design rather than the numbers

World 2's ground is **uniform, renews in place, and has no memory**: a cell
stripped a thousand times refills exactly as fast as one never touched. That is
sunlight. A resource which is uniform and renews in place is precisely the
resource that selects for sitting still, which is why plants do not move.

So world 2 contained one niche and one strategy, and dutifully found it. The
Marginal Value Theorem needs diminishing returns within a patch to have anything
to say, and world 2 has none: your cell yields the same every tick forever, so
there is no leaving rule for selection to discover.

**The honest reading is not that evolution failed here. It is that there was
nothing to evolve toward.**

## What is retired

Everything above belongs to world 2. The build, the tests and the instruments
carry forward; the numbers do not.
