# Results: world 6

**The change:** a creature's energy was split into a **store** and a
**structure**. Only structure costs upkeep, only structure wins a contest, and
turning one into the other is an output the brain decides.

Corrects register entry **B.5**. Pre-registered in
[PREREGISTRATION.md](PREREGISTRATION.md), including one amendment written before
the first run and recorded there.

5 seeds, 2000 ticks, default economy, nothing overridden. 0 of 5 extinct.

## The headline

**The first bimodal population this project has produced.** Two sizes, in all
five seeds, from rules that name no size and no role.

And **predation is now ubiquitous and worthless**: between 165,000 and 213,000
creatures were eaten, and not one creature alive is living off the result.

## Against what was pre-registered

Findings were fixed in advance. Each is answered whatever the answer is.

| # | Pre-registered finding | Result |
|---|---|---|
| 1 | **Variance returns**, `ground_spread` above the flat baseline of ten | **Marginal.** 12, 12, 13, 11, 12 by seed. World 5 was 9-10 and world 4 reached 26-86. A lift off the floor, not a return. |
| 2 | **Energy from creatures above zero** | **NO.** `meat%` is 0 in all five seeds, and the count of individuals taking more from creatures than from ground is **0**. |
| 3 | **A structure distribution with shape** | **YES, strongly.** Bimodal in every seed. |
| 4 | **Store and structure diverging** | **YES.** They are different quantities with different totals and they do not track each other across seeds. |
| 5 | **Perception that pays, topology that is used** | **NO.** 0 to 11 sensor carriers in a population of ~2,300. |

Predicted in advance as a non-effect: `still%` would probably stay at 100. It
did, at 99-100. That is the density relation, a separate entry, untouched here.

## Finding 3, which is the real one

Frame sizes, eight buckets from nothing to the largest alive, smallest first:

| seed | max | distribution |
|---|---|---|
| 1 | 118 | `[2202, 1, 2, 2, 35, 30, 9, 37]` |
| 2 | 130 | `[2145, 0, 1, 1, 60, 24, 36, 2]` |
| 3 | 99 | `[2184, 3, 0, 3, 2, 35, 22, 53]` |
| 4 | 105 | `[2211, 3, 1, 4, 4, 59, 15, 25]` |
| 5 | 120 | `[2231, 0, 5, 0, 41, 23, 28, 2]` |

Around 2,200 creatures with almost no frame, around 100 with a substantial one,
and **the middle buckets nearly empty**. That gap is the whole point: a spread
would fill them. This is two settled sizes, not a range.

It is reproducible across every seed, and nothing in the rules mentions a size,
a class or a threshold. The only thing that was added was that a frame costs
upkeep and wins contests while a store does neither.

## Finding 2, and the metric that nearly hid it

`meat%` is a **population-wide** ratio: meat over meat plus ground, summed
across every creature. When finding 3 came back bimodal, that raised an obvious
objection: a minority of a hundred living entirely by predation would be
invisible in a population mean dominated by 2,200 grazers, so `meat% = 0` might
mean nothing at all.

**So a second observable was added, after seeing finding 3 and before drawing
any conclusion**, and it is recorded here as having been added at that point
rather than in advance: a count of individuals that have taken more energy from
creatures than from ground.

It came back **0 in all five seeds**. The objection was wrong. The large class
is large and it eats the ground like everything else.

So the null is real and it is sharper than world 5's: between 165,000 and
213,000 creatures were consumed, about 95 a tick in a population of 2,300, and
**no lineage makes a living from it**. What gets eaten is nearly empty, so
eating it is worth nothing.

**Who does the killing is not known and must not be guessed at.** It is
tempting to hand it to the large class, since frame is what wins a contest, but
`meat# = 0` says no individual's intake is dominated by it, so the kills are
spread thinly rather than concentrated. Attributing them to the hundred would
be reading a story into a number that does not carry one. Counting kills per
frame bucket would settle it and was not measured.

That is a stronger statement than "predation does not happen". It happens
constantly and does not pay.

## Everything else, none of it privileged

| seed | final | peak | ground | stores | frames | born | starved | eaten | aged |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 2318 | 2341 | 15492 | 4498 | 10352 | 2150092 | 1951733 | 195732 | 309 |
| 2 | 2269 | 2352 | 15646 | 4632 | 11100 | 2142707 | 1927162 | 212965 | 311 |
| 3 | 2302 | 2405 | 15757 | 4677 | 10818 | 2151168 | 1958588 | 189987 | 291 |
| 4 | 2322 | 2418 | 15437 | 4739 | 9664 | 2169803 | 2001691 | 165526 | 264 |
| 5 | 2330 | 2395 | 15494 | 5134 | 8623 | 2187401 | 2018972 | 165853 | 246 |

| seed | still% | eats | store | frame | meat% | meat# | body | brain | move | bred | gspr |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 100 | 288 | 20 | 118 | 0 | 0 | 0 | 1 | 398 | 2264 | 12 |
| 2 | 99 | 254 | 62 | 130 | 0 | 0 | 1 | 0 | 405 | 2223 | 12 |
| 3 | 100 | 238 | 55 | 99 | 0 | 0 | 0 | 0 | 389 | 2260 | 13 |
| 4 | 100 | 270 | 45 | 105 | 0 | 0 | 0 | 0 | 588 | 2271 | 11 |
| 5 | 100 | 223 | 135 | 120 | 0 | 0 | 0 | 1 | 421 | 2295 | 12 |

Frames outweigh stores about two to one across the population, and the two
maxima do not track each other: seed 5 holds the largest store at 135 with a
middling frame, seed 3 the smallest frame at 99 with a middling store. Before
world 6 those were one number and could not disagree.

`starved` dwarfs `eaten` by roughly ten to one. In world 4 the ratio ran the
other way, and Raf was right that this was an artifact of counting plants as
creatures rather than a fact about predation.

## The caveat this result carries

World 6 differs from world 5 in **two** ways, not one, and the second was
forced by a bug found while asking why a single seed took over an hour:
`breed/1` rebuilt its herd index once per creature, so a creature decided
whether to breed while already seeing children its neighbours had just had.
That is the turn-order advantage `world.erl`'s own header says it removed, and
**worlds 2 to 5 all ran with it**. Fixing it made the phase linear instead of
quadratic: 250 ticks went from 532 seconds to 2.

It was found and fixed before any world 6 result existed, so it cannot have
been chosen in response to one. It is still a second change.

**A difference against world 5 cannot be attributed to the store and structure
split alone without a control**, and the control is world 5's rules re-run with
the herd hoisted. Not run. Named here so that skipping it stays a visible
decision.

Finding 3 does not rest on the comparison: a bimodal frame distribution cannot
exist in a world with no frame, whatever the herd fix did.

## What this leaves for the register

- **B.5 is corrected**, and the correction produced the project's first
  positive since world 4, of a different kind: population structure rather than
  landscape structure.
- **D.2, a predation apparatus, is now testable** where world 5 made it
  untestable. There is a size class that wins contests and there are 190,000
  kills a run to act on. What is missing is a reason to bother, since the
  benefit side is currently zero.
- The reason it is zero is that **prey are empty**, which points at C.2, being
  still costs nothing, rather than at D.2. Nothing can flee, so nothing needs
  to be worth catching.
