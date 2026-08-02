# Session handover: hecate-biotope, worlds 14 to 17

**Date:** 2026-08-02. **Repos touched:** `hecate-services/hecate-biotope`,
`beam-campus/beam-campus-net`, `macula-io/macula-demo`. All pushed to `github`
(or `origin` where origins are already flipped).

---

## Where things stand right now

- **The fleet runs world 17.** beam00, beam01, beam03. beam02 has no biotope,
  which is normal.
- **A sense-resolution sweep is running** in the background at 20,000 ticks,
  writing to the session scratchpad. It is the one unfinished piece.
- **The join page is live** at `/research/workbench/biotope/join`, so a stranger
  can run an island.
- **Everything is committed and green**: 192 tests, dialyzer clean, elvis clean.

**On resume, do these three things first:**

1. Read the sweep result (`sweep_senses.escript` output) and write it up against
   `PREREGISTRATION_WORLD17.md`.
2. `./scripts/ask_fleet_world.sh` to see what 24 hours of world 17 produced. The
   single best finding of this session came from letting islands run overnight
   and nothing offline reproduces it.
3. `./scripts/why_lumps.escript name:seed:ticks ...` on the live seeds, which is
   how that finding was made.

---

## What shipped

| world | change | outcome |
|---|---|---|
| **14** | bare ground recovers from what is around it | **all four findings landed**, the first time. The lawn is gone. |
| **15** | a mouth is tissue, eating is a decision | all four failed; **untested rather than refuted** |
| **16** | a hidden node is charged by what it reads | computation became 31-fold price-sensitive; exposed `H.11` |
| **17** | a reading is an intensity, not a total | senses resolve; **calibration still being swept** |

Plus: `world:ruleset/0` label fix, `A.6` fraction carrying, `H.8` self-reach fix,
the selectability gate, image tagging by world, the join page, station inventory
and probe, `world:new/1` rejecting unknown options.

---

## The findings that matter

**The lumps are places, not families... and then they were families.** Creatures
form blobs that persist ~100 generations on ground 72 to 94× richer than
elsewhere. Then F_ST came out at **61 to 65**, so the lumps are also close kin and
more differentiated from each other than human continents are. Nobody installed
that: local birth plus a patchy board plus persistence is Hamilton's condition
arriving from two rules written for other reasons.

**`lineages` has been answering the wrong question since world 9.** It counts
founders and can only fall. A world can be one lineage and strongly structured at
once. **F_ST is now reported beside it** and the register says so.

**`H.10`, the selectability threshold.** A creature earns 87 to 231 a tick and
spends 18 to 35, so the whole cost side is a rounding error. Drift beats selection
below ~1% of income, which is a tissue step of about 33. **Every price this
project ever levied that moved anything scaled with the body; every price that
scaled with an organ did nothing.** This is now a gate in the pre-registration
template.

**`H.11`, and it is the deepest.** A hidden node always reads every input, so this
world **cannot express a narrow brain**. The only way to make a node cheaper is to
drop a sensor. **A cost cannot select for a shape the genome cannot represent**,
which bounds every future world that tries to price computation.

**`H.7`: actuators are free.** Every organ is priced and every act costs nothing.
Largest unpriced thing left.

---

## Open questions, in the order I would take them

1. **Finish world 17.** Sweep result, write-up, register.
2. **The behavioural test that has never been run.** Every measurement here is a
   census. Show an evolved creature the same situation hungry and full and see
   whether it chooses differently. **If it does not, the brains are ornaments
   however many nodes they carry.** This is the project's actual question and
   nothing has ever asked it.
3. **`R.5` / `H.7`**: price the actuators, at a step selection can see.
4. **World 15 re-run** once a mouth is selectable, for the conditional decision
   rather than the trophic split.
5. **Phase 2**: the island's own web UI, observe and configure only.
6. **Phase 4**: genome wire format, then ONNX export and the genome browser.
7. **Phase 5**: invasion. Costs the replicates, so opt-in per island.

Full plan with sizes and CLAIM/BUILD labels is in `PLAN.md`.

---

## Process lessons, which cost more than the physics did

**Five instrument failures, all the same shape: a selector that matches
something, just not the thing.**

- `carnivores_pct` counted carriers of a nonzero integer, reading 94 to 100
  across worlds from toothless to a quarter carnivorous
- occupied-bin-count could not tell bimodal from diffuse
- "share of cells touching another" measured density, not clustering
- `html =~ "--network host"` matched the prose, not the command
- `String.split(~r{</?code>})` matched a tag, not the block

**Each passed while measuring the wrong thing, and each was caught only by
looking at raw output rather than a summary.** The rule: *a summary of a
distribution cannot answer a question about its shape.*

**Four premises explained before being measured. Three were wrong.**

- the absorbing state: arithmetically real, 1 to 4% of the board
- patchiness driving brains: **reversed** on 164 worlds
- truncation hiding selection: **survived its own red check**
- rare encounters: refuted, creatures get 2 to 10 chances per lifetime

**The one that went right** was the ground-floor sweep: it tested a premise in six
minutes and killed a week of building. And `how_often_do_they_meet` killed a
whole world before it cost anything. **Measure the premise first** is the habit
worth keeping.

**Two silent edit failures.** A `str.replace` that matched nothing because
`mix format` had reindented the target, and a revert that failed to compile so a
red check printed nothing and looked like a pass. **Verify the edit landed, and
verify a red check actually ran.**

---

## Traps that will bite again

- **`_build/test` goes stale.** `rebar3 eunit` builds `test`, escripts read
  `default`. `rm -rf _build/test` when a test disagrees with a script.
- **`warnings_as_errors`** means a hand-made revert often will not compile, so
  the red check silently prints nothing.
- **Double quotes in `git commit -m`** break the shell. Use `-F` with a file.
- **`ping6` proves nothing here**: this host has an IPv6 route and no working
  IPv6 path, so it returns silence even for known-live stations.
- **Station names are not places.** `station-de-frankfurt` was the Nuremberg box
  and is on Linode now. Seven stations resolve and all seven answer; 23 more
  names in the configs resolve to nothing.
- **The macula wire has no floats problem any more but atoms become TEXT**, so a
  published `true` arrives as the string `"true"`, which is truthy in Elixir.

---

## Deployment

CI builds on push to `main` and watchtower pulls. Images are now tagged
`:world-N` as well as `:latest`, so a past world can be pinned; past worlds
before 14 have no tag and would need backfilling from their last commit.

Fleet config is `macula-demo/infrastructure/beam0*/biotope-config.env`.
`HECATE_BIOTOPE_SCREEN_TRIES=60` because world 14 onward kills most seeds.

---

## Still owed

- The sweep write-up (running).
- A **Notebook on beam-campus-net** for this research. The site already has the
  ELI5 Notebook pattern under `/research`, and everything here currently lives in
  eleven `RESULTS_*.md` files, a physics register with eight sections and a plan,
  none of which a visitor can find. **This is the right next thing after world
  17** and it is mostly assembly rather than invention.
- Observability that an LLM could interpret. The fact stream is a **census** and
  not a **narrative**: it says "83 creatures, F_ST 61", never "a lineage that held
  the north patch for 200 generations was displaced". An interpreter needs
  events. Nothing emits them.
