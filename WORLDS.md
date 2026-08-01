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
| **6** | separate the **store** from the **structure** (`B.5`) | in progress |

## The through-line

Three of five corrections changed nothing measurable, one produced the only
positive, and one made something worse. **All five are useful**: a correction
that changes nothing removes a simplification from the list of things that could
have been responsible, which is the only way this kind of map gets built.

Two rules came out of the run and now govern what gets built next:

- **A tradeoff only motors anything if nothing adjacent is free.** World 4's
  tradeoff was real and was outvoted by size costing nothing.
- **A correction can destroy the variance a later experiment needs.** World 5
  drove energy from creatures to zero, which makes `D.2` untestable until the
  store and the structure are separated.
