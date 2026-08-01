# Results: world 5

Rules as committed with [PREREGISTRATION.md](PREREGISTRATION.md), untouched
between that commit and this run. 2000 ticks, 8 seeds, radius 10, 5m27s.

`upkeep_divisor` derived by measurement before the run: **33**, the largest that
still binds, settling a sustainably-fed creature at 396 against a ceiling of 400.

```
seed  final  biggest  eats  meat%  gspr  starved  eaten    aged  ground
1     634    81       242   0      9     4970     587744   401   3972
2     656    66       220   0      9     5237     584013   402   3972
3     645    66       218   0      9     6165     599958   398   3972
4     627    99       146   0     10     6846     553890   391   3975
5     649    67       235   0      9     4833     574419   372   3972
6     632    98       147   0      9     4249     558251   362   3972
7     655    97       217   0      9     4506     564032   392   3972
8     639    98       255   0      9     5230     564222   377   3972
```

## Against the pre-registered findings

**1. Size becomes bounded: YES, emphatically.** The largest creature alive is 66
to 99, against a founding energy of **800**. The population equilibrated at about
an eighth of the size it started at, and stayed there. The change bit.

**2. A size distribution with shape: NO.** Everything is small and much of a
muchness.

**3. Small-and-many against large-and-few: NO.** Only small-and-many.

**4. The feeding rate settles: NO.** Still drifting, 146 to 255.

**5. Perception and topology: NO.** Sensors and hidden nodes round to zero.

## And it undid world 4's positive

This is the part worth reporting loudest.

| | world 4 | world 5 |
|---|---|---|
| `ground_spread` | **26 to 86** | **9 to 10** |
| energy from creatures | 3 to 12% | **0 in every seed** |
| ground held | 3,972 to 25,941 | 3,972 in seven of eight |

World 4's landscape differentiated, which was this project's first and only
positive. **World 5 flattened it back to baseline**, and made eating other
creatures energetically worthless.

## The mechanism

**Pricing size removed the variance everything else depended on.**

Creatures can no longer store, so they no longer *differ*. A cell's occupant
cannot hoard, so grazing pressure is the same everywhere and the ground is held
uniformly at the bare floor: 3,972 is exactly 331 cells times the seed rate.
Nothing anywhere accumulates, so no place becomes different from another.

And contest is decided by whoever holds more. When nobody holds much, the
differences are tiny and **the energy that changes hands is negligible**. Note
that consumption did not become rarer — 554,000 to 600,000 creatures were eaten,
*more* than world 4's 482,000 to 517,000. It became **worthless**. A parent at 81
breeds, the child gets 40 and the parent keeps 41, and the parent eats it back
for 40. Enormous churn moving almost nothing.

So predation here did not decline. It was reduced to an accounting entry.

## The general shape of it

**Size being free was bad because it dominated every tradeoff. Size being priced
is bad because it removes the differences that contests need.** A free good is
not simply a defect to be eliminated: some variance in the world was living on it.

That is the first time in this project that correcting a simplification has made
something demonstrably worse, and it is a more useful result than another null.

## One arbitrary point, named rather than defended

The criterion anchored the divisor to **one full cell**: a creature feeding at
the sustainable yield may not grow beyond what a cell holds. That anchor was a
choice among defensible ones — `start_energy` would have given 66 and a gentler
bound. A different anchor gives a different divisor and probably a different
world.

**This is recorded and not acted on.** Retuning it now, having seen that 33
flattened the landscape, would be choosing a constant for the outcome it
produces, which is the one thing forbidden throughout.

## What is retired

The build, the tests and the instruments carry forward. The numbers do not.
