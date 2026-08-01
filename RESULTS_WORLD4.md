# Results: world 4

Rules as committed with [PREREGISTRATION.md](PREREGISTRATION.md), untouched
between that commit and this run. 2000 ticks, 8 seeds, radius 10, 5m08s.

Measured and reported before the run, as required: **a cell sustains 22 a tick**
without being stripped, against a metabolism of 10. So a prudent lineage nets 12
a tick and a greedy one, living on the stripped floor, nets 2. Both livings
reachable; founding rates drawn across 0 to 400.

```
seed  final  still%  eats  meat%  body  brain  gspr  ground
1     582    99      249   8      1     1      79    17083
2     593    100     274   6      1     0      26     4841
3     574    100     306   8      1     0      31     5188
4     566    100     259   7      0     0      45     6620
5     567    100     311   7      0     0       9     3972
6     572    100     225   11     0     0      79    17282
7     586    99      191   12     1     1      86    25941
8     584    100     109   6      0     0      66    10769
```

## Against the pre-registered findings

**1. Movement that persists: NO.** 100% still in six seeds, 99% in two. Worlds 2
and 3 were the same.

**2. A feeding rate that settles: NO from the default start, YES from a narrow
one.** Mean `eats` ranges 109 to 311 around a founding average of about 200,
which is drift. Started instead where a gradient exists, it moves consistently
and in one direction. See the addendum below.

**3. Both livings coexisting: NO.**

**4 and 5. Perception and topology: NO.** Sensors and hidden nodes still round to
zero per creature.

**6. A landscape that differentiates: YES, and strongly.** `gspr` reached 26, 31,
45, 66, 79, 79 and 86 against a flat baseline of 10, where **worlds 2 and 3 sat
at 9 in almost every seed**. Ground totals rose with it, 3,972 to 25,941 against
world 3's 3,972 to 7,649.

**This is the first thing in four worlds that moved because of a change we
made.** Cells finally retain standing stock, so places become materially
different from one another, and the difference is made by how the creatures on
them feed.

## Why the feeding rate did not converge, which is the real finding

Prudence is **six times better** than greed for a stayer: 12 a tick against 2.
Selection did not find it, and the reason is structural rather than a matter of
time.

**The fitness landscape is flat over most of the trait's range.** A creature
feeding at 250 and one feeding at 242 both strip their cell to nothing and both
live on the seed floor, so there is **no difference between them for selection to
act on**. A gradient exists only near the sustainable line, somewhere below about
50. Getting there from a founding average of 200 means a random walk of some
twenty-five consecutive steps across a neutral plateau, with nothing favouring
any of them.

So the trait drifts, which is exactly what 109 to 311 across eight seeds looks
like. Seed 8 wandered down to 109 and the rest did not.

**A trait can be strongly advantageous at one end and still be unreachable, if
everything between here and there is equally bad.** That is a general point about
this world and probably about the next one.

## Addendum: the open question, closed

World 4's negative left two readings it could not separate. Either the neutral
plateau blocked selection, or prudence is simply not favoured. Same rules, same
fingerprint, different opening position: the founding feeding draw narrowed from
0-400 to **0-60, straddling the sustainable line of 22**, where a gradient exists.

    founding mean            29
    final mean, 8 seeds      65  71  89  110  118  124  140  163

**Every seed moved upward, away from prudence.** That is direction, not drift, and
it is consistent across all eight.

### So it was not the plateau. Prudence is not favoured.

Which is the opposite of what the arithmetic predicted, and the arithmetic was
not wrong: a prudent lineage really does net 12 a tick where a greedy one nets 2.
**What the arithmetic left out is how creatures die here.**

    deaths by being eaten     ~500,000 per run
    deaths by starving        ~10,000 per run

**Ninety-seven percent of deaths are being eaten.** Starving is a rounding error.
So the return on a cell that yields for ever is only collected by a creature that
survives to collect it, and the thing that decides survival is being larger than
whatever shares your cell.

A greedy creature on full ground takes hundreds in a single tick and is
immediately large. A prudent one takes twenty-two and stays small. The prudent
one does not starve. **It gets eaten**, long before its sustainable income
matters.

This is the classic reason prudent exploitation does not evolve: short-term
competitive ability beats long-run yield whenever the competition is direct and
immediate. Energy is armour in this world, and grabbing fast is how you get
armour.

### What this does and does not license

It says what happens **from this starting position**, and the physics is untouched
so it is the same game from a different opening. It does not say prudence could
never win under some other arrangement, and it says nothing about any other
world.

It does close world 4's ambiguity, which is what it was run for.

## What that implies for world 5

Heritable dispersal may have the same shape. If a child placed four cells away and
one placed forty cells away fare identically, the trait is a plateau and drift
decides. **The question to ask of any new trait is not whether its optimum is
better, but whether there is a gradient leading to it.**

## What is retired

The build, the tests and the instruments carry forward. The numbers do not.
