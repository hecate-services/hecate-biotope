# The worlds

One line per experiment: what single thing changed, and what happened.

**Worlds are numbered. Register entries are lettered** (`B.5`, `D.2`) — see
[PHYSICS_REGISTER.md](PHYSICS_REGISTER.md) for the catalogue of what this world
still gets wrong about energy, and which entry each world corrects.

| world | what changed | what happened |
|---|---|---|
| **1** | the original build: named actions (`graze`, `hunt`), named organs (`eye`, `nose`), plants as objects | Predation was constant and **nobody made a living from it**. No carnivore niche at any density where worlds survived. [results](RESULTS_WORLD1.md) |
| **2** | **physics only.** No named action or organ; no plants; death returns energy; readings in natural units; a `self` sensor; a hidden layer; reproduction became an output | **100% sessile in every seed**, every sensor and brain selected away. Not a tuning failure: forbidden by arithmetic for any parameter choice. [results](RESULTS_WORLD2.md) |
| **3** | ground recovery depends on its standing stock (`A.1`) | **Nothing.** A stayer holds its cell at zero, so a stock-dependent rule never fires in a populated world. [results](RESULTS_WORLD3.md) |
| **4** | feeding is rate-limited, and the rate is heritable (`D.1`) | **First positive.** The landscape differentiated, `ground_spread` 26–86 against 9 before, and the feeding rate became **the first trait ever selected rather than drifting**. It moved toward greed, because size was free. [results](RESULTS_WORLD4.md) |
| **5** | metabolism scales with what a creature holds (`B.1`) | Size became bounded, 66–99 against a founding 800. **It also undid world 4's positive**: landscape flat again, energy from creatures zero in every seed. [results](RESULTS_WORLD5.md) |
| **6** | separate the **store** from the **structure** (`B.5`) | **The first bimodal population.** Two settled sizes in every seed, ~2,200 with almost no frame and ~100 with a large one, from rules naming no size. Did **not** restore world 4's landscape variance, and predation is now ubiquitous and worthless: 165k-213k kills a run, nobody living off them. [results](RESULTS_WORLD6.md) |

## The through-line

Three of six corrections changed nothing measurable, **two produced a positive**,
and one made something worse. **All six are useful**: a correction that changes
nothing removes a simplification from the list of things that could have been
responsible, which is the only way this kind of map gets built.

The two positives are different in kind, and the difference is the finding.
World 4 structured the **landscape**; world 6 structured the **population**.
Neither structured the other: world 6's board stayed nearly flat and world 4's
creatures stayed one size.

Two rules came out of the run and now govern what gets built next:

- **A tradeoff only motors anything if nothing adjacent is free.** World 4's
  tradeoff was real and was outvoted by size costing nothing.
- **A correction can destroy the variance a later experiment needs.** World 5
  drove energy from creatures to zero, which made `D.2` untestable until the
  store and the structure were separated. World 6 separated them and unblocked
  it.
- **A thing can happen constantly and still not be a living.** World 6 kills
  190,000 creatures a run and no lineage eats for a living, because what gets
  eaten is empty. Counting events is not measuring a strategy.
