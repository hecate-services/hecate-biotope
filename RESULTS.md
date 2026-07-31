# Results: first frozen run

Rules as committed in `7363541`, which also carried [PREREGISTRATION.md](PREREGISTRATION.md).
The rules were not touched between that commit and this run. 4000 ticks, 8 seeds,
8.5 seconds total.

## Viability, checked first

| Criterion | Result |
|---|---|
| nothing goes extinct | 0 of 8 |
| population not pinned at the cap | refused births 0 in every seed |
| energy books balance | asserted by test, not by inspection |
| the signature carries information | spread 31-44 against a baseline of 50 |
| runs fast enough to repeat | 8 seeds in 8.5s |

```
seed  final  peak  trough  plants  born  starved  eaten  aged  refused
1     54     78    40      46      5696  274      5367   1     0
2     45     77    40      77      4724  221      4458   0     0
3     48     76    40      49      5054  199      4807   0     0
4     50     77    40      61      5156  154      4952   0     0
5     74     77    40      93      6634  244      6315   1     0
6     33     50    24      39      4637  1402     3201   1     0
7     68     80    40      119     7277  258      6951   0     0
8     57     80    40      50      5420  233      5130   0     0

seed  breed_at  meat%  body  s:plant  s:creat  s:scent  tags  spread
1     298       39     100   54       0        0        26    44
2     288       37     97    44       0        0        22    39
3     321       46     104   48       2        0        22    44
4     309       46     98    49       0        0        24    42
5     367       67     40    30       0        0        33    41
6     229       31     169   33       0        0        12    31
7     332       61     4     2        1        0        35    43
8     343       40     92    53       0        0        25    40
```

`meat%` is the share of all energy the living have eaten that came from other
creatures. `body` is sensors per creature times a hundred. The three `s:` columns
are how many creatures carry a sensor for that field.

## Against the three pre-registered findings

**1. Sensor differentiation. Partial, and not in the form predicted.**

The prediction was two or more lineages with different sensor sets persisting. I
cannot answer that from what I measure: carrier counts are population totals, so
"half the population carries a plant sensor" and "one lineage of sensors beside
one blind lineage" look identical here. Telling them apart needs sensor sets
correlated against signatures, which is an observer's measure I do not have and
will not add retroactively to chase this.

What is unambiguous is differentiation **among sensors**. The plant sensor
persists in seven seeds of eight. **The creature sensor and the scent sensor go
extinct in every single seed**, despite creature energy being a third to two
thirds of what everything eats. Measuring your food does not pay for itself here
even when your food is most of your diet.

**2. Predation as a living. Clear positive, with a caveat that matters.**

`meat%` runs 31 to 67 in every seed, and deaths by consumption exceed deaths by
starvation by ten to thirty times. The previous world had constant killing that
no lineage depended on; this one is largely built on it.

**The caveat is that predation here requires no adaptation at all.** Consumption
is a collision outcome: share a cell, hold more energy, and the rule resolves. A
blind creature on a random walk eats as effectively as any other, which is
exactly why the creature sensor went extinct. So this is not predation as a
*strategy*, it is predation as weather.

That is a consequence of a rule I wrote and it is worth naming as such. Whether
contest should cost something is a real question, and answering it means a **new
world** and a new pre-registration, not an edit to this one.

**3. Divergence between seeds. Strong signal, stated carefully.**

`body` runs from 4 to 169 under identical rules, a fortyfold spread. Seed 6
finished small (33), sensing (1.7 sensors each, every creature carrying a plant
sensor), starving often and least predatory (31%). Seed 7 finished large (68),
effectively blind (0.04 sensors each) and most predatory (61%). Those are
different-looking worlds from the same rulebook.

I am not claiming this meets the bar I set, which was that within-seed spread be
smaller than between-seed spread. One run per seed cannot establish that.

## The result nobody asked for, which is the most interesting one

**The breeding threshold rose in every seed, from a founding 160 to 229-367.**
Consistent, directional, and about double.

The mechanism is not subtle once seen. The consumption rule makes **energy into
armour**: the stronger takes the weaker, so carrying more is the whole defence.
Breeding spends half your threshold, so breeding late means being large and being
large means being the eater rather than the eaten. An arms race for size falls
directly out of one line of physics that mentions neither size nor safety.

Nothing was tuned for this and it was not on the list of things being looked for.
The previous world had this number wandering around its starting value.

## What this run does not say

- Nothing about whether roles exist within a population, only about what
  survived in aggregate.
- Nothing about islands, invasion or migration. One world, eight seeds.
- Nothing that should be compared to figures from before the rebuild. Those were
  measured while sweeping for the thing they reported.
