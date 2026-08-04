%% @doc The biotope: plants, creatures, and the energy that moves between them.
%% PURE. No processes, no mesh, no clock, no ets.
%%
%% ==========================================================================
%% PHYSICS IS OURS TO WRITE. BIOLOGY NEVER IS.
%% ==========================================================================
%%
%% This module was rebuilt from the previous one for a single reason: it used to
%% contain biology. There were actions called `graze' and `hunt', organs called
%% `eye' and `nose', and a diet statistic that counted which of two verbs had
%% fired. A world whose rules already say "hunt" cannot discover predation, and
%% calling the result emergent is close to circular. Raf caught it and was right.
%%
%% So the rules below concern energy, space, cost, persistence and inheritance,
%% and nothing else. What eats what, what is worth measuring, and whether there
%% are roles at all are consequences to be observed, never rules to be written.
%%
%% THE ONLY DECISION A CREATURE MAKES IS WHERE TO BE. It values the seven cells
%% it can reach, its own included, and goes to the best. Everything an observer
%% might call a behaviour falls out of that one choice:
%%
%%   going where plant energy is          is grazing
%%   going where creature energy is       is predation
%%   avoiding creature energy             is fleeing
%%   staying where trails run             is ambush
%%
%% None of those words appear in this file.
%%
%% CONSUMPTION IS ONE RULE THAT DOES NOT KNOW WHAT IT IS EATING. Whatever shares
%% your cell and cannot contest you is consumed and its energy becomes yours. A
%% plant never contests. A creature contests with its energy. That single line
%% generates the whole trophic structure, and it names no trophic level.
%%
%% NOBODY MOVES FIRST. Every creature values the world as it stands at the start
%% of the tick and they all move together, so there is no turn order to confer an
%% advantage and no shuffle needed to hide one. The previous version resolved
%% creature by creature and had to randomise the order to stop old lineages
%% eating first forever; simultaneity removes the problem rather than papering
%% over it, and it removed a good deal of code with it.
%%
%% STILL NO PROCESS PER CREATURE. Purity is what lets thousands of ticks across
%% many seeds run offline in seconds, and that has already stopped a fortnight of
%% work being built on a trait that turned out not to move. A body of processes
%% is a fine RUNTIME for these rules and a poor place to discover them.
-module(world).

-export([new/0, new/1, tick/1, tick/2, snapshot/1, chart/1, defaults/0, econ_id/1]).
-export([ruleset/0]).
-export([population/1, ground_energy/1, at_tick/1, alive/2]).
-export([appraise/3, consider/3, creatures/1]).
-export([depart/2, arrive/2]).

-type hex() :: hex:hex().
-type id() :: pos_integer().


%% Where a creature may go: its own cell and the six around it. Not a rule about
%% behaviour, a statement about how far a thing can travel in one tick.
-define(REACH, 1).

%% How many buckets a continuous trait is drawn in. Enough to see a shape, few
%% enough to fit on a card.
-define(BUCKETS, 8).

-type creature() :: #{id := id(),
                      at := hex(),
                      %% WHAT IT CAN TAKE FROM THE LIVING, per tick. Zero is a
                      %% creature that cannot kill and lives on the ground alone,
                      %% which is most of what has ever lived here.
                      mouth := non_neg_integer(),
                      %% THE FRACTION OF ITS UPKEEP NOT YET CHARGED, in
                      %% numerator units. Never energy: only whole units are ever
                      %% taken and every one is credited to `dissipated'. See
                      %% `charge_one/2' and register entry A.6.
                      owed := non_neg_integer(),
                      energy := integer(),
                      age := non_neg_integer(),
                      born := non_neg_integer(),
                      parent := id() | none,
                      %% WHICH FOUNDING IT DESCENDS FROM AND HOW FAR DOWN.
                      %% Observables, read by no rule and used to treat no
                      %% creature differently. Declared here because dialyzer
                      %% noticed they were not: `descent/3' matches on both, and
                      %% against a type that did not have them that match could
                      %% never succeed, which is a lie the type was telling about
                      %% code that works.
                      lineage := id(),
                      generation := non_neg_integer(),
                      %% Everything heritable. `breed_at' is gone: deciding
                      %% reproduction by a hand-written rule with a heritable
                      %% threshold was exactly the shape `hunt' had, a verb we
                      %% wrote with a parameter bolted on. It is an OUTPUT now.
                      body := body:body(),
                      brain := brain:brain(),
                      %% HOW FAST IT CAN FEED, per tick. A bodily capacity and
                      %% not a rule: nothing reads it but the arithmetic of
                      %% absorption, and it says nothing about when or whether
                      %% to do anything.
                      %%
                      %% Feed slower than the ground recovers and a cell holds a
                      %% standing stock you can draw on for good. Feed faster and
                      %% you strip it, your income collapses to the bare floor,
                      %% and you move or starve. OVERGRAZING IS POSSIBLE NOW, and
                      %% fatal to whatever does it.
                      uptake := non_neg_integer(),
                      %% WHAT IT IS BUILT OF, as opposed to what it is carrying.
                      %% World 5 had one number for both and taxed a fat reserve
                      %% as though it were working tissue, which flattened every
                      %% difference between creatures. A store is nearly free to
                      %% hold, which is what fat is FOR; structure is expensive
                      %% to run and is what wins a contest.
                      structure := non_neg_integer(),
                      scent := scent:tag(),
                      %% WHAT THIS CREATURE HAS ACTUALLY EATEN, by where the
                      %% energy came from. An observer's record, not a rule:
                      %% nothing in the physics reads these, and no creature is
                      %% ever treated differently for what they contain.
                      from_ground := non_neg_integer(),
                      from_creatures := non_neg_integer(),
                      %% Whether it stayed put this tick. The plant-ness of a
                      %% creature, observed rather than declared.
                      still := boolean()}.

-type econ() :: #{transfer_efficiency := pos_integer(),
                  recolonise_pct := non_neg_integer(),
                  sense_scale := pos_integer(),
                  ground_growth_pct := non_neg_integer(),
                  ground_ceiling := pos_integer(),
                  uptake_mutation := non_neg_integer(),
                  upkeep_divisor := pos_integer(),
                  metabolism := non_neg_integer(),
                  move_cost := non_neg_integer(),
                  %% How much dearer a unit of neural tissue is than a unit of
                  %% body. Since world 13 an organ is charged by weight like any
                  %% other tissue, so the two flat rents this replaced are gone.
                  neural_cost := non_neg_integer(),
                  %% What being ABLE to act costs, per unit of output wiring.
                  %% World 18. Zero is world 17.
                  act_cost := non_neg_integer(),
                  water_holes := non_neg_integer(),
                  thirst := non_neg_integer(),
                  max_sensors := pos_integer(),
                  max_sensor_range := non_neg_integer(),
                  scent_per_tick := non_neg_integer(),
                  scent_decay := pos_integer(),
                  scent_ceiling := pos_integer(),
                  scent_mutation := pos_integer(),
                  brain_range := pos_integer(),
                  brain_mutation := non_neg_integer(),
                  brain_mutation_structural := pos_integer(),
                  founder_max_hidden := non_neg_integer(),
                  max_hidden := non_neg_integer(),
                  body_mutation := pos_integer(),
                  start_energy := pos_integer(),
                  max_age := pos_integer(),
                  radius := non_neg_integer(),
                  max_creatures := pos_integer()}.

%% How recently a behaviour has to have first appeared to count as new. A
%% thousand ticks is about a hundred generations at this world's lifespan, which
%% is long enough that a rare behaviour is not missed and short enough that a
%% world which stopped discovering last night reads as stopped.
-define(FRONTIER, 1000).

%% The largest a single lake may be, in cells. Not a physics constant and not
%% swept: `water_holes' decides how much water there is, and this only decides
%% whether that budget arrives as a few big bodies or many small ones. Twelve
%% because a lake wants a shore worth settling and a disc of 1,261 cells cannot
%% hold many more without the whole board being wet.
-define(LAKE_MAX, 12).

-record(world, {tick = 0 :: non_neg_integer(),
                econ :: econ(),
                ground :: ground:ground(),
                %% ==========================================================
                %% WHERE THE WATER IS, WORLD 23
                %% ==========================================================
                %%
                %% A fixed set of cells, never consumed and never depleted. The
                %% first thing in twenty-three worlds that exists in some PLACES
                %% and not others: energy appears everywhere the sun reaches, and
                %% `J.1' is that a creature with one requirement has nothing to
                %% decide because the scarcest thing is always the same thing.
                %%
                %% Breeding requires standing on one. Not thirst: a store that
                %% drains would require commuting, and a creature that lives ten
                %% ticks and moves one cell a tick cannot commute anywhere at any
                %% arrangement of holes. Measured before the rule was written.
                water = #{} :: #{{integer(), integer()} => true},
                %% Where something has walked and how recently, each mark
                %% carrying the signature of what left it.
                scent = #{} :: #{hex() => scent:mark()},
                creatures = #{} :: #{id() => creature()},
                next_id = 1 :: id(),
                rng :: rand:state(),
                %% Totals since the world began, never reset. A rate is
                %% recoverable from two totals and the reverse is not true.
                born = 0 :: non_neg_integer(),
                %% EVERY UNIT THAT LEFT THE POOLS, and the reason the First Law
                %% is a test here rather than a claim. Before world 7 metabolism
                %% simply vanished, so the books could only be checked against
                %% themselves. Now ground + stores + frames + dissipated is
                %% exactly constant apart from what the sun adds.
                %%
                %% At one temperature this is also the entropy account, in units
                %% where T = 1, so the Second Law is the statement that it never
                %% falls.
                dissipated = 0 :: non_neg_integer(),
                starved = 0 :: non_neg_integer(),
                aged_out = 0 :: non_neg_integer(),
                %% Deaths by being eaten, kept apart from the other two because
                %% "the population crashed" is not a finding and three causes
                %% sharing one total cannot be told apart afterwards.
                consumed = 0 :: non_neg_integer(),
                %% THE AGE OF EVERYTHING EVER EATEN, summed. An observable, read
                %% by no rule. World 9 is the first world in which anything makes
                %% a living off other creatures, and the same world made a
                %% newborn the lightest thing on the board, which was declared in
                %% PREREGISTRATION.md before the run. Those are different
                %% findings and only this number tells them apart: a predator
                %% niche eats what is out there, and eating your own newborns
                %% eats things one tick old.
                eaten_age = 0 :: non_neg_integer(),
                absorbed = 0 :: non_neg_integer(),
                births_refused = 0 :: non_neg_integer(),
                %% SENSORS GAINED AND LOST AT BIRTH, cumulatively. A census says
                %% what the population is built from NOW; these say whether that
                %% is still moving. Both climbing together is a lineage churning
                %% through body plans; both flat is a settled one, and a census
                %% alone cannot tell those apart.
                sensors_gained = 0 :: non_neg_integer(),
                sensors_lost = 0 :: non_neg_integer(),
                %% HOW MANY BIRTHS HAD TWO PARENTS, world 20. Outcrossing is
                %% FACULTATIVE: a creature that breeds with nobody in reach
                %% clones itself exactly as it did for nineteen worlds. So the
                %% treatment is applied by the board rather than by a constant,
                %% and this counter is the dose. Without it a null result cannot
                %% be told from a rule that never fired.
                outcrossed = 0 :: non_neg_integer(),
                %% Died of thirst. THE DOSE OF WORLD 23: without it, "the rule
                %% changed nothing" and "the rule killed everything" are the same
                %% in every other column.
                parched = 0 :: non_neg_integer(),
                %% ⚠ THE TWO NUMBERS THAT KEEP THE FIRST LAW ACROSS A SEA.
                %%
                %% Energy carried off this island by migrants, and energy carried
                %% onto it. Every joule has been in the ground, in a store or in
                %% a structure for twenty-four worlds, and a creature leaving is
                %% the first thing that can take some somewhere this world cannot
                %% see. Without these two the island's own books still balance
                %% while the archipelago quietly gains or loses whatever was in
                %% transit.
                departed = 0 :: non_neg_integer(),
                arrived = 0 :: non_neg_integer(),
                %% ⚠ EVERY CROSSING THIS ISLAND HAS ALREADY ACCEPTED.
                %%
                %% At-most-once is enforced HERE, at the destination, and not by
                %% hoping the transport never retries. A retry is a normal event
                %% on a mesh: an acknowledgement can be lost after the creature
                %% landed, and the sender is then obliged to try again.
                %%
                %% The receipts alone cannot catch a double delivery, and that is
                %% worth stating because it was the first design: `arrived' rises
                %% by exactly what the stores rise by, so the books balance just
                %% as neatly for a creature admitted twice as for one admitted
                %% once. A guard that cannot fail is not a guard.
                seen = #{} :: #{integer() => true},
                %% ⚠ WHETHER THIS ISLAND TAKES MIGRANTS, AND IT IS NOT PHYSICS.
                %%
                %% A world option rather than an economy constant, deliberately.
                %% `HECATE_BIOTOPE_ECON' put beam01 in a two-hour crash loop for
                %% exactly this confusion, and the rule that came out of it is
                %% that a node's config may name what a node IS and never what
                %% the physics ARE. Who an island admits is what it is.
                border = open :: open | closed,
                %% ==========================================================
                %% EVERY WAY OF LIVING THIS WORLD HAS EVER FOUND
                %% ==========================================================
                %%
                %% Keyed by behaviour cell, holding when it was first seen and
                %% the deepest lineage that ever behaved that way. It is the
                %% idea from novelty search and MAP-Elites and NOT the method:
                %% **nothing selects on it.** Selection here is still that you
                %% starve.
                %%
                %% IT EXISTS BECAUSE THERE IS NO FITNESS CURVE TO PLOT. A world
                %% with no objective cannot say a run "improved", only what
                %% changed, so the replacement measurement is how much of the
                %% space of ways-of-living has been found and whether new ones
                %% are still turning up. **Cells discovered per thousand ticks
                %% going to zero is this world's definition of converged**, and
                %% nothing before this could have said it.
                %% ⚠ NEAT'S HISTORICAL MARKING, PER WORLD AND NOT PER NODE OF
                %% AN ETS TABLE. faber keeps innovation numbers in ETS plus
                %% `counters', which is global mutable state: two worlds sharing
                %% a VM would share a counter and a world would stop being a
                %% pure function of its seed. `G.6' cost nineteen worlds of
                %% results and is not being reintroduced for this.
                %%
                %% Monotonic and never reused. A number that came back would
                %% tell a later recombination that two unrelated nodes were the
                %% same organ.
                next_mark = 1 :: pos_integer(),
                archive = #{} :: #{non_neg_integer() =>
                                       {non_neg_integer(), non_neg_integer()}},
                extinct_at = undefined :: non_neg_integer() | undefined,
                %% THE NUMBER THIS WHOLE WORLD UNFOLDED FROM, carried so it can be
                %% published. A world is a pure function of it, proven by
                %% scripts/same_seed_same_world.escript, so an island that says
                %% which seed it is running is an island anyone can replay exactly.
                %%
                %% That is what makes it safe for a live island to choose a FRESH
                %% one at boot rather than replaying the same life after every
                %% restart. Reproducible science, unrepeatable exhibit: the two
                %% only conflict while the seed is a secret.
                seed = 42 :: integer()}).

-opaque world() :: #world{}.
-export_type([world/0, creature/0, econ/0]).

%%==============================================================================
%% The economy
%%==============================================================================

%% EVERY NUMBER HERE IS SET FOR VIABILITY OR FOR SCALE, NEVER FOR AN OUTCOME.
%% See PREREGISTRATION.md for the criteria, written down before the first run.
%% @doc Which world this is, and one sentence a stranger can read.
%%
%% IT LIVES WITH THE RULES AND NOT IN CONFIGURATION, because it is a property of
%% the physics in this file rather than of how a node happened to be started. Two
%% islands running the same binary are the same world by construction and no
%% environment variable can make them disagree about it. A node showing world 5
%% while another shows world 6 is telling the truth about what it is running,
%% which is exactly the question a reader has when two cards disagree.
%%
%% CHANGE IT IN THE SAME COMMIT AS THE RULES. WORLDS.md carries the long version
%% and PREREGISTRATION.md the reasoning; this is the label on the tin.
-spec ruleset() -> #{number := pos_integer(), line := binary()}.
ruleset() ->
    #{number => 24,
      %% ⚠ THE LINE MUST BE TRUE AT THE VALUE THE FLEET RUNS. A first version
      %% said "being able to act costs something", written while the default was
      %% still 0, and it would have gone out on every published fact describing
      %% an economy no island had. The fleet deploys from main automatically, so
      %% there is no window in which a label is merely aspirational.
      %%
      %% True at 16: four purposes cost more than none. It does NOT say a
      %% creature sheds what it cannot afford, because at 16 it does not; that
      %% needs four times the price and RESULTS_WORLD18.md says so.
      line => <<"The water is lakes and rivers, cut fresh for every island, "
                "and a river runs all the way to the shore, so no part of the "
                "land is too far from a drink to live on.">>}.

-spec defaults() -> econ().
defaults() ->
    #{%% WHERE ENERGY ENTERS THE WORLD, and the one thing world 3 changed.
      %%
      %% Recovery depends on what is LEFT: bare ground comes back at
      %% `ground_seed', and ground with something in it compounds by
      %% `ground_growth_pct'. World 2 added a fixed amount regardless, which made
      %% a stripped cell recover as fast as an untouched one and made movement
      %% arithmetically impossible for every parameter choice. See ground.erl.
      %%
      %% BOTH NUMBERS ARE DERIVED FROM CRITERIA FIXED BEFORE MEASURING, in
      %% PREREGISTRATION.md, and neither refers to what evolves:
      %%
      %%   recolonise_pct     REPLACED ground_seed IN WORLD 14, and is not
      %%                      derived from a criterion at all: it is SWEPT, and
      %%                      3 is the control because on a full board every
      %%                      neighbour sits at the ceiling of 400 and
      %%                      400 * 3 / 100 is the 12 that worlds 2 to 13 used.
      %%
      %%                      The criterion it replaces was "the smallest at
      %%                      which a sensorless creature that never moves can
      %%                      raise one child within max_age", world 2's, kept
      %%                      verbatim for eleven worlds. It presupposed the
      %%                      answer to the question this project keeps asking,
      %%                      and RESULTS_GROUND_FLOOR.md shows the magnitude
      %%                      never mattered: swept 0 to 48, the sessile lineage
      %%                      simply re-sizes and the population grazes the stock
      %%                      to wherever the marginal grazer breaks even.
      %%                      What mattered was that the floor was
      %%                      UNCONDITIONAL.
      %%
      %%   ground_growth_pct  the smallest at which recovery is mostly
      %%                      COMPOUNDING rather than mostly linear, meaning the
      %%                      proportional term overtakes the seed floor below
      %%                      half the ceiling. AMENDED before any run: the
      %%                      original asked only that bare ground reach half the
      %%                      ceiling within a lifetime, and the verifier showed
      %%                      the SEED FLOOR ALONE does that in seventeen ticks,
      %%                      so every rate satisfied it and zero was smallest.
      %%                      Growth would have stayed linear and world 3 would
      %%                      have been world 2 exactly.
      %%                      A property of the RESOURCE and of no lifestyle: it
      %%                      says recovery is meaningful on the timescale life
      %%                      runs at. AMENDED before any run: see below.
      %%
      %% `ground_growth_pct' is derived by scripts/verify_ground.escript and
      %% recorded there. `recolonise_pct' is derived by nothing and swept.
      %% HOW MANY STEPS OF THE READING RANGE A FULL CELL SPANS, and the one
      %% constant world 17 adds. At 1 a full cell reads 1 and everything below it
      %% reads nothing; at 63 a full cell fills the range and every maximum pins
      %% at the ceiling. Blind at the bottom, or blind at the top.
      %%
      %% SWEPT, because nothing derives it and picking the tidy expression is
      %% what put it at 63. `ground_ceiling div reading_ceiling' is one point on
      %% a range and there was never an argument for it beyond neatness.
      %% scripts/sweep_senses.escript, 96 seeds, 20,000 ticks:
      %%
      %%   scale    1     2     4     8    16    32    63
      %%   dead    80    87    89    91    94    94    93
      %%
      %% ONE, ON FEWEST EXTINCTIONS AND NOTHING ELSE. That is the single
      %% exception the standing rule allows, and no part of the choice refers to
      %% sensors, reach, brains or population. **DEATHS RISE MONOTONICALLY WITH
      %% RESOLUTION**, so the criterion this world sets its constants by chooses
      %% the BLINDEST instrument available, and that is the world 17 result
      %% rather than a disappointing side effect of it. See RESULTS_WORLD17.md
      %% and `F.4'.
      %%
      %% ⚠ TWO EARLIER ANSWERS WERE WRONG AND BOTH ARE INSTRUCTIVE. The first
      %% sweep read 63, from tidiness. The second read 2, from 24 seeds against
      %% physics that was not reproducible (`G.6'); at 24 seeds the top three
      %% scales tie at 21 deaths and cannot choose at all. **A criterion that
      %% cannot separate its candidates is not a criterion**, and the fix was
      %% four times the seeds rather than a tie-break invented afterwards.
      %%
      %% ⚠ AND 1 IS NOT WORLDS 2 TO 16. Those worlds SUMMED over the cells in
      %% reach; every scale here takes the MEAN. The two coincide only at reach
      %% 0, where one cell is one cell. No setting of this constant recovers the
      %% old rule for a wide sensor.
      %%
      %% IT LIVES HERE AND NOT IN A NODE CONFIG. It spent world 17 as
      %% `HECATE_BIOTOPE_ECON=sense_scale=2' on three beams, which is how beam01
      %% spent two hours in a boot-crash loop: the node pulled a config naming
      %% this key before it pulled the image that had it, and an unknown economy
      %% key is a startup failure by design. A physics constant in a deployment
      %% config is a version handshake nobody performs. See `I.9'.
      sense_scale       => 1,
      recolonise_pct    => 3,
      ground_growth_pct => 6,
      ground_ceiling    => 400,
      %% HOW FAR A CHILD'S FEEDING RATE MAY DRIFT FROM ITS PARENT'S. The rate
      %% itself is a heritable trait rather than a constant, because a fixed one
      %% would decide globally and by my hand whether staying put works: above
      %% what a cell can sustainably yield, everything must move; below it,
      %% nothing need. See PREREGISTRATION.md. This is a scale constant of the
      %% same kind as brain_mutation, small and symmetric so a lineage drifts
      %% rather than resamples.
      uptake_mutation   => 8,
      %% HOW MUCH A CREATURE MAY HOLD PER UNIT OF EXTRA UPKEEP, and the whole of
      %% world 5. Metabolism was flat: one carrying ten thousand paid exactly
      %% what one carrying ten paid, so SIZE WAS A FREE GOOD. That is why world
      %% 4's feeding tradeoff was overridden. Large creatures win contests, 97%
      %% of deaths are being eaten, and armour cost nothing, so grabbing fast
      %% won however badly it treated the ground.
      %%
      %% Linear rather than the three-quarter power real organisms show, which is
      %% SUBLINEAR and would favour large size relative to this. Adopting it means
      %% choosing a fractional exponent, awkward in integers and a magic number;
      %% linear is the plainest statement that holding costs something. If it
      %% proves too punishing, sublinear is the refinement to reach BY
      %% MEASUREMENT rather than to assume.
      %%
      %% Derived from the criterion fixed in PREREGISTRATION.md before measuring:
      %% the LARGEST divisor at which a creature feeding at the sustainable yield
      %% cannot grow beyond what one full cell holds. Largest because that is the
      %% gentlest pricing that still binds, and a cap that never bites is how
      %% world 3 failed. Recorded by scripts/verify_ground.escript.
      upkeep_divisor    => 33,
      %% WHAT IT COSTS TO EXIST AND TO ACT, at ten times world 1's grain. Scaling
      %% every energy quantity by one factor changes nothing about the world and
      %% buys the resolution to set the ratio above to within a tenth, which
      %% integers at the old grain could not express.
      metabolism        => 10,
      move_cost         => 10,
      %% WHAT A GRAM OF APPARATUS WEIGHS AGAINST A GRAM OF BODY.
      %%
      %% An organ is tissue and is charged by `carrying/2' like any other tissue
      %% since world 13. What physics does not settle is how much DEARER neural
      %% tissue is, and biology says it genuinely is: a human brain is about 2%
      %% of the mass and 20% of the energy.
      %%
      %% So this is SWEPT and every value published, exactly as `transfer_efficiency'
      %% is. 330 IS THE CONTROL: at an `upkeep_divisor' of 33 it reproduces the
      %% flat rent of 10 a tick that worlds 2 to 12 charged, so those worlds are a
      %% point on this sweep rather than a different game.
      %% ==========================================================================
      %% ELEVEN, AND THE 330 IT REPLACES WAS NEVER CHOSEN
      %% ==========================================================================
      %%
      %% Its own comment said why it was 330: "at the divisor of 33 it reproduces
      %% the old flat rent of 10 a tick exactly". That flat rent is what world 13
      %% DELETED as a defect, and `B.2' and `B.3' both objected to it. **The
      %% replacement was calibrated to reproduce the thing it replaced**, which is
      %% continuity with a deleted rule rather than a criterion, and it stood for
      %% six worlds.
      %%
      %% Swept under world 19's live-wiring rule, 48 seeds, 20,000 ticks:
      %%
      %%   neural   330  220  165  110   66   33   11    3    1
      %%   dead      41   39   33   33   33   29   24   29   28
      %%
      %% ELEVEN, ON FEWEST EXTINCTIONS AND NOTHING ELSE. The control killed 85%
      %% of the seeds it was given and this kills 50%. No part of the choice
      %% refers to sensors, nodes, width, population or depth, and
      %% RESULTS_WORLD19.md publishes every value so the criterion can be checked
      %% rather than trusted.
      %%
      %% ⚠ A THIRTY-FOLD REDUCTION, and the largest change to this world's
      %% economy since world 13 made an organ tissue. Every result about brains
      %% not appearing, from world 13 onward, was measured at 330.
      neural_cost       => 11,
      %% ==========================================================================
      %% WHAT AN ACT COSTS TO BE ABLE TO DO, and the one constant world 18 adds
      %% ==========================================================================
      %%
      %% Until now a purpose was free. Every organ in this world was priced and
      %% every act was not, so a creature carrying `move', `breed', `eat' and
      %% `grow' paid exactly what one carrying none paid. `H.7', and the largest
      %% unpriced thing left.
      %%
      %% SWEPT, because nothing derives a price for an act, and the sweep spans
      %% both walls the gate predicted rather than sitting between them:
      %%
      %%   0    world 17 exactly, so the old behaviour is inside the comparison
      %%   ~10  the drift floor: below it a mutation moves the bill by under 1%
      %%        of what a creature earns and selection cannot see it (`H.10')
      %%   ~200 the roof: above it the complement a creature actually carries
      %%        costs most of its income, which does not price acting, it bans it
      %%
      %% `scripts/can_an_act_be_priced.escript' measured both before this was
      %% built, which is what `R.1' exists for. Reusing `neural_cost' at 330 was
      %% the obvious build and it fails the roof at 94.7% of income.
      %%
      %% ⚠ IT SELECTS ON COUNT AND NOT ON WIDTH. An output is `sensors + 1 +
      %% hidden' wide and that is the body reported back, not a trait, exactly as
      %% `H.11' found for hidden nodes. What a creature can vary is how many
      %% purposes it carries. See PREREGISTRATION_WORLD18.md.
      %%
      %% SWEPT, 48 seeds, 20,000 ticks:
      %%
      %%   act_cost    0    8   16   33   66  132  330
      %%   dead       40   40   41   43   44   44   47
      %%   eat %      91   66   94   61   28   21    2
      %%   grow %     84   73   94   80   25   18    6
      %%   move %     96   98   85   94   98   81  100
      %%   breed %    99   99   99   98   96   96   97
      %%
      %% SIXTEEN, ON VIABILITY AMONG THE VALUES THAT CLEAR THE PRE-REGISTERED
      %% FLOOR. The floor was fixed before the run at about 10, where a mutation
      %% moves the bill by 1% of income; 0 is no price at all and 8 is below it
      %% and would measure drift exactly as world 15's mouth did. Of the rest, 16
      %% kills fewest: 41 seeds of 48 against the control's 40. **One seed in 48
      %% is what pricing acts costs.**
      %%
      %% ⚠ AND AT 16 THE EFFECT IS NOT VISIBLE. `eat' and `grow' sit at 94% and
      %% 94%, above the control. The shedding begins at 66 and is unmistakable by
      %% 330. **Clearing the drift floor makes a price selectable in principle and
      %% this one needs four times the floor before anything moves**, which is a
      %% third bound on `H.10' and is recorded there. The fleet therefore runs a
      %% price that changes almost nothing, chosen by a rule fixed in advance,
      %% and the interesting part of this world lives where no island should be.
      act_cost          => 16,
      %% Safety valves against a runaway genome making one tick cost as much as
      %% the whole disc. Not model parameters: rent is what should bound a
      %% creature, and when one of these binds it is counted and reported.
      %%
      %% ⚠ `max_sensors' WAS 8 AND 8 WAS BINDING, measured 2026-08-03: 18 to 22%
      %% of the population sat AT it at 20,000 ticks, so the sentence above was
      %% false for six worlds and world 19's sensor column was a ceiling rather
      %% than a response to price. Nothing counted it and nothing reported it,
      %% because the counting was never written.
      %%
      %% 12 BY A RULE FIXED BEFORE THE NUMBERS: the smallest cap leaving under 5%
      %% of the population at it. Smallest, because a cap set to infinity is not
      %% a braver experiment, it is an unbounded one.
      %%
      %% **12, 16 and 24 give the identical world** in every column measured, so
      %% no lineage ever tries to exceed 12 and the valve has genuinely stopped
      %% deciding. It is also CHEAPER to run: 399 ms per thousand ticks against
      %% 466 at 8, because the pile of eight-sensor creatures the old cap
      %% sustained cost more to read than the population that replaces it.
      %%
      %% AND IT WAS NOT ONLY CENSORING THE MEASUREMENT. `body:grow/3' declines
      %% the mutation at the cap, so a creature that would have grown another
      %% sensor never grew it AND NEVER PAID FOR IT. The valve was a subsidy
      %% against a mutation the lineage could not afford, which is why lifting it
      %% LOWERS the sensor mean, from 5.10 to 4.60, rather than raising it.
      %% Deaths are unchanged at 14 of 32 seeds, so nothing about survival turned
      %% on this.
      %% ⚠ HOW MANY WATERING HOLES, AND IT IS THE EXPERIMENT RATHER THAN A
      %% SETTING. Few big holes concentrate hardest and are furthest away; many
      %% small ones are reachable and concentrate least. Measured before the
      %% world was built: the share of creatures able to reach one INSIDE A LIFE
      %% is 26% at one hole, 50% at seven, 66% at nineteen and 86% at
      %% thirty-seven. Swept, with every value published.
      %%
      %% ⚠ 241, RE-SWEPT FOR LAKES AND RIVERS, AND THE OLD DEFAULT WAS THE WORST
      %% ARM ON THE BOARD. 61 was chosen on viability under CONCENTRIC RINGS. The
      %% geometry changed in world 24 and the number was carried over, which is a
      %% constant surviving the world it was measured in.
      %%
      %% Contiguity costs coverage: a twelve-cell lake serves a smaller area than
      %% twelve scattered cells, so the same 61 cells that put a creature 6.05
      %% away as a bullseye put it 8.59 away as a landscape.
      %%
      %% 24 seeds to 4,000 ticks, dead of 24, control 15:
      %%
      %%   31: 16   61: 22   91: 17   121: 19   181: 18   241: 16   361: 17
      %%
      %% Flat, with 31 and 241 tied at the bottom. A tie at 24 seeds is a tie
      %% decided by noise, so the tied arms and 61 were re-run at 64 seeds:
      %%
      %%   arm        dead/64   parched%   cells to water
      %%   control        37        0%          6.91
      %%   31            52       24%          9.67
      %%   61            54       23%          7.03      <- the old default
      %%   241           46       16%          2.36      <- chosen
      %%
      %% Fewest extinctions and nothing else. Thirst still takes 16% of all
      %% deaths here, so the rule is not being switched off, and it still costs
      %% nine seeds against a world with no thirst at all.
      %%
      %% ⚠⚠ AND THE SWEEP SAYS THIS IS A SIZE FILTER, NOT A DISTANCE ONE.
      %% Distance to water falls from 9.67 cells to 2.36, a fourfold improvement,
      %% and thirst deaths fall only from 24% to 16%. A rule about reaching water
      %% would be nearly abolished by flooding the island. This one is not,
      %% because capacity is `structure' and a small creature carries a leash of
      %% a tenth of a tick wherever the water happens to be.
      water_holes       => 241,
      %% ⚠ HOW FAST A CREATURE DRIES OUT, per tick, and it is SWEPT because
      %% nothing derives it. Capacity is the creature's own `structure', so a
      %% bigger animal carries more water and no second constant is needed, and
      %% the interval between drinks is `structure / thirst' ticks.
      %%
      %% THE LEASH THIS SETS IS THE EXPERIMENT. A creature must return to water
      %% every `structure / thirst' ticks, so it can live that many cells out and
      %% no further. Wander beyond the leash and you die; stay inside it and you
      %% compete with everything else that is also inside it. That is a watering
      %% hole.
      %%
      %% ⚠ CHOSEN ON VIABILITY AND NOTHING ELSE, and the first guess was lethal.
      %% 40 was written down by hand and **killed every seed at every hole
      %% count**. Measured over 12 seeds to 4,000 ticks, deaths of 12:
      %%
      %%   thirst   19 holes   61 holes
      %%       40       12         12      every world dead
      %%       20       12         12      every world dead
      %%       10        9          7      quarter of all deaths are thirst
      %%        5        9          8
      %%        0        6          -      world 22, the control
      %%
      %% So 10, which costs ONE extra dead seed against a world with no thirst at
      %% all and still kills a quarter of everything that dies. No part of that
      %% choice refers to sensors, brains, distance or the frontier; the whole
      %% table is here so the criterion can be checked rather than trusted.
      thirst            => 10,
      max_sensors       => 12,
      max_sensor_range  => 4,
      max_hidden        => 6,
      founder_max_hidden => 2,
      %% What a moving creature leaves behind, how fast it fades, how much one
      %% cell can hold, and how fast a signature drifts. Scent is not energy and
      %% is not rescaled.
      scent_per_tick    => 10,
      scent_decay       => 2,
      scent_ceiling     => 30,
      scent_mutation    => 3,
      %% How large a weight may grow, how far each moves per birth, and how often
      %% the SHAPE of a brain changes rather than its numbers.
      brain_range       => 8,
      brain_mutation    => 1,
      brain_mutation_structural => 20,
      %% One birth in this many changes the body: a sensor gained, lost or
      %% re-reached, the three equally likely so nothing pushes bodies to grow.
      body_mutation     => 20,
      start_energy      => 800,
      max_age           => 600,
      %% HOW MUCH OF A TRANSFORMATION ARRIVES, as a percentage. The Second Law
      %% fixes the sign and says nothing about the size, so this is SWEPT rather
      %% than derived and the run reports every value.
      %%
      %% 100 is world 6 exactly, which makes it the control rather than a
      %% separate world to compare against.
      transfer_efficiency => 100,
      radius            => 20,
      %% WELL ABOVE THE CELL COUNT, because if sitting still pays then the board
      %% fills, and a covered board is a FOREST rather than a mistuning. A field
      %% of grass is a population at the carrying capacity of the ground.
      max_creatures     => 6000}.

%%==============================================================================
%% Making a world
%%==============================================================================

%% What a world takes that is not an economy constant: where it starts rather
%% than what it costs to live there.
-define(WORLD_OPTS, [seed, population, border, founder_body, founder_brain,
                     founder_scent, founder_uptake, founder_uptake_max,
                     founder_mouth]).

-spec new() -> world().
new() -> new(#{}).

reject_unknown([]) -> ok;
reject_unknown(Unknown) ->
    error({unknown_world_opts, lists:sort(Unknown),
           lists:sort(maps:keys(defaults()) ++ ?WORLD_OPTS)}).

%% Opts override the economy, plus `seed', `population' and the `founder_*'
%% overrides.
%%
%% AN UNKNOWN KEY IS AN ERROR AND WAS SILENTLY DROPPED UNTIL WORLD 14.
%% `maps:with/2' kept the keys the economy has and threw the rest away, so a
%% caller asking for a constant that no longer exists got the default and no
%% complaint. World 13 deleted `sensor_rent' and `hidden_rent' and nineteen test
%% sites went on setting them to zero for another world, each one reading like a
%% configured experiment and doing nothing at all.
%%
%% `world_server' has refused unknown keys from the environment since world 9 for
%% exactly this reason. It was refusing them at one of the two doors.
-spec new(map()) -> world().
new(Opts) ->
    reject_unknown(maps:keys(Opts) -- (maps:keys(defaults()) ++ ?WORLD_OPTS)),
    Econ = maps:merge(defaults(), maps:with(maps:keys(defaults()), Opts)),
    Seed = maps:get(seed, Opts, 42),
    Rng0 = rand:seed_s(exsss, {Seed, Seed, Seed}),
    Radius = maps:get(radius, Econ),
    {Water, Rng} = water(maps:get(water_holes, Econ), Radius, Rng0),
    populate(maps:get(population, Opts, 40), Opts,
             #world{econ = Econ, ground = ground:new(Radius, Econ), rng = Rng,
                    water = Water, seed = Seed,
                    border = maps:get(border, Opts, open)}).

populate(0, _Opts, W) -> W;
populate(N, Opts, #world{econ = Econ, rng = Rng0, next_mark = M0} = W) ->
    {At, Rng1} = random_cell(maps:get(radius, Econ), Rng0),
    {Traits, M1, Rng2} = founder_traits(Econ, Opts, M0, Rng1),
    %% A FOUNDER IS HALF STORE AND HALF STRUCTURE. Splitting the two forces a
    %% starting ratio, and even is the least-informative one: it favours neither
    %% carrying nor building, and mutation and the `grow' output decide the rest.
    Start = maps:get(start_energy, Econ),
    populate(N - 1, Opts,
             add_creature(At, Start div 2, Start - Start div 2, none, Traits,
                          W#world{rng = Rng2, next_mark = M1})).

%% ==========================================================================
%% WHERE THE WATER GOES: LAKES AND RIVERS
%% ==========================================================================
%%
%% ⚠ THIS REPLACED CONCENTRIC RINGS, WHICH WERE A BULLSEYE AND NOT A LANDSCAPE.
%% The old arrangement laid single cells on rings spaced `radius div 4' apart.
%% At the default it came out as one cell at the centre, a COMPLETE CIRCULAR MOAT
%% of thirty cells at distance five, and half a ring at distance ten, leaving
%% **73% of the island with no water anywhere further out**. Nothing about it
%% resembled water and the dry rim is a plausible reason world 23 culled rather
%% than taught anything: for three quarters of the board "go and drink" was not a
%% decision, it was a death sentence.
%%
%% Two shapes, because they ask different questions of a creature:
%%
%%   A LAKE is a blob. It is somewhere to live NEXT TO, and it concentrates: the
%%          creatures that settle around one are near each other, which is what
%%          `J.1' wanted and what a ring of isolated cells could never give.
%%
%%   A RIVER runs from inland to the rim. It is a CORRIDOR, so it puts water
%%          within reach of the outer island without covering it, and a creature
%%          that finds one can follow it. Rings put nothing past distance ten.
%%
%% ⚠ AND IT IS RANDOM PER SEED, WHICH THE RING VERSION REFUSED TO BE. Its comment
%% argued that a random scatter makes the hole count and the luck of the draw
%% inseparable. That is true of ONE seed and false of twenty-four: over a sweep
%% the geometry averages out, and a fixed geometry instead guarantees that every
%% seed shares whatever artefact the arrangement happens to have. The bullseye is
%% what that costs, and it cost a world.
%%
%% Zero is a legal and meaningful setting: it is world 22 with an extra field
%% nobody can use, and it is the control arm of the sweep.
water(0, _Radius, Rng) -> {#{}, Rng};
water(Budget, Radius, Rng) ->
    %% ⚠ CAPPED AT THE ISLAND. `water_holes' is a budget of CELLS and a caller
    %% may ask for more than the board has: `world_tests' asks for 999 on a
    %% radius-5 disc of 91 cells, meaning "enough that thirst never binds".
    %% Without this, carving loops for ever once every cell is already wet.
    carve(min(Budget, length(hex:disc(Radius))), Radius, #{}, Rng,
          Budget * 4 + 16).

%% Features are cut until the budget of water cells is spent, so `water_holes'
%% still means "how many cells are wet" and every sweep ever run against it stays
%% comparable.
%%
%% ⚠ AND THE FUEL IS NOT DECORATION. A feature can land entirely on cells that
%% are already wet and add nothing, so "keep going until the budget is met" is
%% not by itself a terminating loop. The fuel bounds the attempts; a world that
%% runs out simply has slightly less water than asked for, which is visible in
%% `water_holes' on the snapshot rather than hidden.
carve(_Budget, _Radius, Water, Rng, 0) -> {Water, Rng};
carve(Budget, _Radius, Water, Rng, _Fuel) when map_size(Water) >= Budget ->
    {Water, Rng};
carve(Budget, Radius, Water, Rng0, Fuel) ->
    {Coin, Rng1} = rand:uniform_s(2, Rng0),
    {Cells, Rng2} = feature(Coin, Radius, Budget - map_size(Water), Rng1),
    carve(Budget, Radius, wet(Cells, Water), Rng2, Fuel - 1).

wet(Cells, Water) -> maps:merge(Water, maps:from_keys(Cells, true)).

feature(1, Radius, Room, Rng) -> lake(Radius, Room, Rng);
feature(2, Radius, Room, Rng) -> river(Radius, Room, Rng).

%% A LAKE: pick a cell and grow outward into it. Sizes are drawn rather than
%% fixed so an island has both ponds and something worth walking to.
lake(Radius, Room, Rng0) ->
    {At, Rng1} = random_cell(Radius, Rng0),
    {Size, Rng2} = rand:uniform_s(min(Room, ?LAKE_MAX), Rng1),
    spread([At], [At], Size - 1, Radius, Rng2).

spread(Blob, _Edge, 0, _Radius, Rng) -> {Blob, Rng};
%% NO SHORE LEFT TO GROW FROM. Every cell of the blob is hemmed in by itself or
%% by the rim, which happens on a small island long before the size drawn is
%% reached. The lake is simply as big as it can be.
spread(Blob, [], _Left, _Radius, Rng) -> {Blob, Rng};
spread(Blob, Edge, Left, Radius, Rng0) ->
    {N, Rng1} = rand:uniform_s(length(Edge), Rng0),
    From = lists:nth(N, Edge),
    grown(free(From, Blob, Radius), Blob, Edge, From, Left, Radius, Rng1).

%% A cell with no room left stops being a place to grow from, which is what keeps
%% this from spinning when a blob closes in on itself.
grown([], Blob, Edge, From, Left, Radius, Rng) ->
    spread(Blob, Edge -- [From], Left, Radius, Rng);
grown(Free, Blob, Edge, _From, Left, Radius, Rng0) ->
    {N, Rng1} = rand:uniform_s(length(Free), Rng0),
    Next = lists:nth(N, Free),
    spread([Next | Blob], [Next | Edge], Left - 1, Radius, Rng1).

free(From, Blob, Radius) ->
    [C || C <- hex:neighbours_in(From, Radius), not lists:member(C, Blob)].

%% A RIVER: start inland and run for the rim, never turning back on itself. The
%% walk takes any neighbour that is no nearer the centre than the current cell,
%% so it wanders sideways and still gets there.
%% ⚠ THE SOURCE IS INLAND BUT NEVER OFF THE ISLAND. `max(1, Radius div 2)' was
%% written to keep a source away from the very centre and puts it OUTSIDE the
%% board on a radius-0 or radius-1 disc, which every conservation test in
%% `world_tests' runs on. The cap is the island itself.
river(Radius, Room, Rng0) ->
    {At, Rng1} = random_cell(min(Radius, max(1, Radius div 2)), Rng0),
    flow(At, [], min(Room, Radius * 2), Radius, Rng1).

flow(At, Cells, 0, _Radius, Rng) -> {[At | Cells], Rng};
flow(At, Cells, Left, Radius, Rng0) ->
    onward(seaward(At, Radius), At, Cells, Left, Radius, Rng0).

%% Reaching the rim ends the river. There is nowhere further to run.
onward([], At, Cells, _Left, _Radius, Rng) -> {[At | Cells], Rng};
onward(Options, At, Cells, Left, Radius, Rng0) ->
    {N, Rng1} = rand:uniform_s(length(Options), Rng0),
    flow(lists:nth(N, Options), [At | Cells], Left - 1, Radius, Rng1).

seaward(At, Radius) ->
    Here = hex:distance(At, {0, 0}),
    [C || C <- hex:neighbours_in(At, Radius),
          hex:distance(C, {0, 0}) >= Here].

%% Everything heritable, drawn fresh and SPREAD. The first generation should
%% already contain every shape of creature the rules allow, so selection has
%% something to sort on tick one rather than waiting for mutation to invent it.
%%
%% Any of it may be GIVEN instead of drawn. That is not a testing hook: it is how
%% a world is founded with a known creature, which is what a control run needs
%% and what a transplanted migrant would arrive through.
founder_traits(Econ, Opts, Mark0, Rng0) ->
    {Body, Rng1} = given(founder_body, Opts, fun body:founder/2, Econ, Rng0),
    {Brain, Mark1, Rng2} = founder_brain(maps:get(founder_brain, Opts, draw),
                                         Body, Mark0, Econ, Rng1),
    {Tag, Rng3} = given(founder_scent, Opts, fun scent:founder/2, Econ, Rng2),
    Widest = maps:get(founder_uptake_max, Opts,
                      maps:get(ground_ceiling, Econ)),
    {Rate, Rng4} = given(founder_uptake, Opts, rates_up_to(Widest), Econ, Rng3),
    %% DRAWN EXACTLY AS THE GUT IS, because both bound what enters a creature in
    %% a tick and they differ only in which source. ZERO IS A LEGITIMATE
    %% CREATURE and is the null everything else is measured against, the same
    %% argument `body:founder/2' makes for a creature that measures nothing.
    {Mouth, Rng5} = given(founder_mouth, Opts, rates_up_to(Widest), Econ, Rng4),
    {#{body => Body, brain => Brain, scent => Tag, uptake => Rate,
       mouth => Mouth}, Mark1, Rng5}.

%% Uniform across the range. The default ceiling is DERIVED rather than chosen:
%% no more than a full cell holds can be taken from it.
%%
%% NARROWABLE, BECAUSE WORLD 4 LEFT A QUESTION OPEN THAT ONLY THIS CAN CLOSE. Its
%% feeding rate drifted and never converged, though prudence pays six times what
%% greed does, and the reason looked structural: everything above the sustainable
%% line strips the cell and lives on the same floor, so there is NO GRADIENT over
%% most of the range and selection has nothing to climb. From a founding average
%% of 200 the optimum near 22 is twenty-five neutral steps away.
%%
%% That leaves two readings and the run cannot tell them apart: the plateau
%% blocked selection, or prudence is not actually favoured. Starting the draw
%% where the gradient exists separates them.
%%
%% IT IS A STARTING CONDITION AND NOT A RULE. The physics is untouched, the
%% economy fingerprint is unchanged, and a result from a narrow start says only
%% what happens FROM THERE. It would not license a claim about what happens from
%% anywhere else.
rates_up_to(Max) ->
    fun(_Econ, Rng0) ->
            {N, Rng1} = rand:uniform_s(Max + 1, Rng0),
            {N - 1, Rng1}
    end.

given(Key, Opts, Draw, Econ, Rng) ->
    specified(maps:get(Key, Opts, draw), Draw, Econ, Rng).

specified(draw, Draw, Econ, Rng) -> Draw(Econ, Rng);
specified(Given, _Draw, _Econ, Rng) -> {Given, Rng}.

%% A brain is sized from the body it will steer, so this one cannot be drawn
%% without knowing the body first.
founder_brain(draw, Body, Mark0, Econ, Rng) ->
    brain:founder(body:sensor_count(Body), Mark0, Econ, Rng);
%% A GIVEN BRAIN CARRIES NO HISTORY, because it did not happen here: a control
%% run or a transplanted migrant arrives with nodes this world never grew. They
%% get fresh marks so they cannot be mistaken for anything already present.
founder_brain(Given, _Body, Mark0, _Econ, Rng) ->
    Count = length(maps:get(hidden, Given, [])),
    {Given#{marks => lists:seq(Mark0, Mark0 + Count - 1)}, Mark0 + Count, Rng}.

add_creature(At, Energy, Structure, Parent, Traits, #world{next_id = Id, creatures = Cs,
                                                tick = T, born = B} = W) ->
    {Line, Gen} = descent(Parent, Id, Cs),
    C = maps:merge(#{id => Id, at => At, energy => Energy, age => 0,
                     structure => Structure, memory => blank(Traits),
                     born => T, parent => Parent, still => true,
                     %% WHAT IT HAS DONE, as against what it is. `origin' is the
                     %% cell it was born in and `moved' counts the ticks it
                     %% actually went somewhere, which are the two things a
                     %% behaviour descriptor needs and the only two the world
                     %% was not already keeping.
                     origin => At, moved => 0, bred => 0,
                     %% BORN FULL, from the parent that carried it there. A
                     %% newborn that had to find water in its first tick would
                     %% make being born away from a hole immediately fatal, which
                     %% is a rule about birth rather than about thirst.
                     water => Structure,
                     lineage => Line, generation => Gen,
                     %% A NEWBORN OWES NOTHING, which slightly under-charges the
                     %% very short-lived. At a generation time near forty ticks
                     %% against a divisor of thirty-three that is a fraction of
                     %% one tick's bill, and it is the same direction the old
                     %% truncation erred in rather than a new bias.
                     owed => 0,
                     from_ground => 0, from_creatures => 0},
                   Traits),
    W#world{next_id = Id + 1, creatures = Cs#{Id => C}, born = B + 1}.

%% WHICH FOUNDING A CREATURE DESCENDS FROM AND HOW FAR DOWN, carried rather than
%% reconstructed, because by the time anyone asks the parent is usually dead and
%% the chain no longer exists to walk.
%%
%% AN OBSERVABLE AND NOT A RULE. Nothing reads either of these to decide anything
%% and no creature is treated differently for its ancestry. They exist because
%% Fisher prices adaptation in the variance available to select on, and world 8
%% ended with a population that could not change while this world had no way to
%% say so. A world whose deepest surviving line is zero generations deep has
%% selected nothing: it has filtered its founding once and stopped.
descent(none, Id, _Cs) -> {Id, 0};
descent(Parent, _Id, Cs) ->
    #{lineage := Line, generation := Gen} = maps:get(Parent, Cs),
    {Line, Gen + 1}.

%%==============================================================================
%% Leaving, and arriving
%%==============================================================================
%%
%% ⚠ THESE TWO ARE THE ONLY DOORS IN OR OUT OF A WORLD, and they are the only
%% place the first law can be broken. Every other joule in this file moves
%% between the ground, a store and a structure, and `world_tests' asserts the
%% total never changes. A migrant takes some of it somewhere this island cannot
%% see.
%%
%% So both sides keep a receipt. `departed' and `arrived' appear on the snapshot,
%% and the invariant that replaces conservation-on-one-island is
%%
%%     books + dissipated + departed - arrived
%%
%% which is fixed per island, and sums across the archipelago to a total that
%% moves only if a creature was duplicated or lost in transit.
%%
%% ⚠⚠ AND DEPARTURE IS NOT DEATH. A departing creature is not reaped, does not
%% return its body to the ground, and is not counted in `starved', `consumed',
%% `aged_out' or `parched'. Folding it into any of those would make an island
%% that exports well look like an island that dies well, which are opposite
%% findings.

%% @doc Take a creature off this island, packed for the crossing.
%%
%% The world loses it here and NOTHING has it yet. That is deliberate and it is
%% the whole safety argument: the caller holds the only copy and must not drop it
%% until a receiver has acknowledged, because a migrant delivered twice is free
%% energy and one lost in flight is energy destroyed.
-spec depart(id(), world()) -> {ok, migrant:packed(), world()} | {error, atom()}.
depart(Id, #world{creatures = Cs} = W) ->
    leaving(maps:find(Id, Cs), Id, W).

leaving(error, _Id, _W) ->
    {error, no_such_creature};
leaving({ok, C}, Id, #world{creatures = Cs, departed = Out, rng = Rng0} = W) ->
    %% Drawn from the world's own stream, so an island remains a pure function of
    %% its seed and two departures never share a crossing.
    {Crossing, Rng1} = rand:uniform_s(1 bsl 60, Rng0),
    Packed = migrant:pack(C, Crossing),
    {ok, Packed, W#world{creatures = maps:remove(Id, Cs), rng = Rng1,
                         departed = Out + migrant:energy_of(Packed)}}.

%% @doc Put a creature that came from somewhere else onto this island.
%%
%% ⚠ THE MIGRANT IS VALIDATED AND MAY BE REFUSED. This is the first input to a
%% world that the world did not produce, it arrives from a node anybody may be
%% running, and a body and a brain that disagree on width crash the tick rather
%% than drawing oddly. `migrant:unpack/1' checks the shape; this refuses what it
%% rejects and the caller declines the animal.
-spec arrive(migrant:packed(), world()) ->
          {ok, world()} | {turned_away, atom()} | {error, atom()}.
arrive(Packed, W) ->
    landed(migrant:unpack(Packed), Packed, W).

landed({error, Why}, _Packed, _W) ->
    {error, Why};
landed({ok, _C}, #{crossing := X}, #world{seen = Seen}) when is_map_key(X, Seen) ->
    {error, already_arrived};
landed({ok, C}, #{crossing := X} = Packed, W) ->
    %% ⚠ TWO QUESTIONS, ASKED SEPARATELY. Above: is this a creature at all, which
    %% is fixed and technical and answers `{error, _}' because there is no animal
    %% to hand back. Here: will we have it, which is a judgement about a creature
    %% that is perfectly fine, and answers `{turned_away, Why}' so the caller can
    %% return it alive.
    considered(border:consider(C, gates(W)), C, X, Packed, W).

%% What the border is allowed to know about this island. Deliberately small: a
%% rule that could read the whole world would grow into one that reads a
%% creature's lineage before anybody decided that was a policy this world has.
gates(#world{border = Border, creatures = Cs, econ = Econ}) ->
    #{border => Border, population => map_size(Cs),
      max_creatures => maps:get(max_creatures, Econ)}.

considered({turn_away, Why}, _C, _X, _Packed, _W) ->
    {turned_away, Why};
considered(admit, C, X, Packed,
       #world{creatures = Cs, econ = Econ, next_id = Id, seen = Seen,
              rng = Rng0, tick = T, arrived = In} = W) ->
    %% A MIGRANT MAKES LANDFALL AT RANDOM, because nothing in this world knows
    %% which way it came and inventing a shore would be inventing a geography.
    {At, Rng1} = random_cell(maps:get(radius, Econ), Rng0),
    Settled = C#{id => Id, at => At, born => T, parent => none, still => true,
                 origin => At},
    {ok, W#world{creatures = Cs#{Id => Settled}, next_id = Id + 1, rng = Rng1,
                 seen = Seen#{X => true},
                 arrived = In + migrant:energy_of(Packed)}}.

%%==============================================================================
%% The tick
%%==============================================================================

-spec tick(world()) -> world().
tick(W) -> tick(W, 1).

%% EIGHT PHASES IN A FIXED ORDER, each one a rule of the world. Charging before
%% moving means a creature that cannot afford to exist does not get a free step.
%% Moving before consuming means arriving somewhere feeds you this tick. Fading
%% last means a trail laid this tick is at full strength when the next begins.
-spec tick(world(), non_neg_integer()) -> world().
tick(W, 0) -> W;
tick(W, N) ->
    W1 = charge(W),
    W2 = drink(move_all(W1)),
    W3 = consume(W2),
    W4 = build(breed(W3)),
    W5 = reap(W4),
    W6 = W5#world{ground = ground:grow(W5#world.ground, W5#world.econ)},
    W7 = fade(W6),
    %% ⚠ LAST, AND ONCE. Everything above asks the brain questions, seven of them
    %% about cells the creature only considered stepping into. This is the single
    %% place an answer is KEPT, taken from where the creature actually ended up,
    %% so what it remembers cannot depend on the order its options were weighed.
    W8 = recall(W7),
    W9 = note_behaviours(W8),
    tick(W9#world{tick = W9#world.tick + 1}, N - 1).

%% Mean hex distance from a creature to its nearest hole, times a hundred. Zero
%% holes reports zero rather than infinity: a world with no water has nothing to
%% be far from, and it is the control arm.
to_water(#world{water = Water}) when map_size(Water) =:= 0 -> 0;
to_water(#world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
to_water(#world{creatures = Cs, water = Water}) ->
    Holes = maps:keys(Water),
    Sum = lists:sum([nearest_hole(maps:get(at, C), Holes)
                     || C <- maps:values(Cs)]),
    Sum * 100 div map_size(Cs).

nearest_hole(At, Holes) -> lists:min([hex:distance(At, H) || H <- Holes]).

%% HOW MANY WAYS OF LIVING TURNED UP RECENTLY. Measured over a window rather
%% than since the beginning, because a total can only rise and would report a
%% long-converged world as a thriving one.
age_mean(#world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
age_mean(#world{creatures = Cs}) ->
    lists:sum([maps:get(age, C) || C <- maps:values(Cs)]) div map_size(Cs).

%% The portraits of every living creature, tallied. No random numbers are drawn,
%% so folding a map is safe here.
portraits(#world{creatures = Cs, econ = Econ}) ->
    Radius = maps:get(radius, Econ),
    Ceiling = maps:get(ground_ceiling, Econ),
    lists:foldl(fun(C, Acc) -> tally_portrait(C, Radius, Ceiling, Acc) end,
                #{}, maps:values(Cs)).

tally_portrait(C, Radius, Ceiling, Acc) ->
    maps:update_with(behaviour:portrait(C, Radius, Ceiling), fun bump/1, 1, Acc).

commonest_portrait(#world{creatures = Cs}) when map_size(Cs) =:= 0 -> <<>>;
commonest_portrait(W) -> element(2, top_portrait(W)).

portrait_share(#world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
portrait_share(#world{creatures = Cs} = W) ->
    element(1, top_portrait(W)) * 100 div map_size(Cs).

%% Sorted before the maximum, so a tie is broken by the phrase itself rather
%% than by whatever order the map happened to give. `G.6' is about draws taking
%% their order from a map; this draws nothing, but a census that reported a
%% different winner on each call for the same world would be just as useless.
top_portrait(W) ->
    lists:max([{N, P} || {P, N} <- lists:sort(maps:to_list(portraits(W)))]).

frontier(#world{archive = A, tick = T}) ->
    map_size(maps:filter(fun(_Cell, {First, _Best}) -> T - First < ?FRONTIER end,
                         A)).

deepest_elite(#world{archive = A}) when map_size(A) =:= 0 -> 0;
deepest_elite(#world{archive = A}) ->
    lists:max([Best || {_First, Best} <- maps:values(A)]).

%% Sorted, so the same world always publishes the same bytes.
flatten_archive(A) ->
    lists:append([[Cell, First, Best]
                  || {Cell, {First, Best}} <- lists:sort(maps:to_list(A))]).

%% ==========================================================================
%% THE ARCHIVE, WHICH IS AN INSTRUMENT AND NEVER A SELECTOR
%% ==========================================================================
%%
%% Every creature alive is described and its cell recorded. A cell holds the tick
%% it was FIRST seen and the deepest generation ever reached by something living
%% that way.
%%
%% ⚠ THE ELITE IS AN OBSERVATION, NOT AN OBJECTIVE. MAP-Elites keeps the best
%% individual per cell and BREEDS FROM IT. Nothing here breeds from anything: a
%% creature reproduces when its own brain says so and it has the energy, exactly
%% as before. The depth recorded is what happened, and reading it back into
%% selection would turn this world into the kind of thing it exists not to be.
%%
%% No random numbers are drawn, so folding a map is safe here where `G.6' forbids
%% it elsewhere.
note_behaviours(#world{creatures = Cs, econ = Econ, tick = T,
                       archive = A} = W) ->
    Radius = maps:get(radius, Econ),
    W#world{archive = maps:fold(fun(_Id, C, Acc) -> note_one(C, Radius, T, Acc)
                                end, A, Cs)}.

note_one(C, Radius, Tick, Acc) ->
    Cell = behaviour:cell(C, Radius),
    Depth = maps:get(generation, C, 0),
    maps:update_with(Cell, deepen(Depth), {Tick, Depth}, Acc).

deepen(Depth) -> fun({First, Best}) -> {First, max(Best, Depth)} end.

%% ==========================================================================
%% DRINKING, WHICH IS WORLD 23
%% ==========================================================================
%%
%% AFTER MOVING, because a creature that walks to the water drinks when it
%% arrives rather than next tick. Everyone dries out by `thirst'; anyone standing
%% on water is full again regardless.
%%
%% ⚠ WATER IS NOT ENERGY AND IS NOT IN THE BOOKS. It is not eaten, not
%% transferred, not dissipated and not conserved: a hole is inexhaustible and a
%% corpse returns none of it. Running dry kills you, and that is the whole of its
%% economy. Threading it through the energy accounts would have made every
%% conservation test in this file a test of two currencies at once.
%%
%% CAPACITY IS `structure', so a bigger creature goes longer between drinks and
%% no constant says so. The leash a creature lives on is `structure / thirst'
%% ticks of walking, out and back.
%%
%% ⚠ AND THAT MAKES THIS A SIZE FILTER BEFORE IT IS A DISTANCE ONE, which was not
%% the intent. Measured over 603 creatures at 12 seeds, `structure' runs from 1 to
%% 8,181 with a median of 215, so at `thirst' 10 the leash runs from a TENTH OF A
%% TICK to eight hundred. Thirst is nearly free for a large creature and
%% immediately fatal to a small one, and the trait it selects on is therefore body
%% size, which is heritable and already under selection for other reasons.
%%
%% It is left as it is rather than quietly replaced by a flat capacity: reusing
%% `structure' is what kept this world to one new constant, the consequence is
%% measured and written down in `PREREGISTRATION_WORLD23.md', and a constant
%% swapped after seeing what it did is `I.3'.
%%
%% `maps:map' is safe: nothing here draws a random number.
drink(#world{creatures = Cs, econ = Econ, water = Water} = W) ->
    Thirst = maps:get(thirst, Econ),
    W#world{creatures = maps:map(fun(_Id, C) -> sip(C, Water, Thirst) end, Cs)}.

sip(#{at := At, structure := S, water := Held} = C, Water, Thirst) ->
    C#{water => filled(maps:is_key(At, Water), S, Held - Thirst)}.

filled(true, Structure, _Left) -> max(0, Structure);
filled(false, _Structure, Left) -> Left.

%% ==========================================================================
%% WHAT A CREATURE CARRIES INTO THE NEXT TICK, WHICH IS WORLD 21
%% ==========================================================================
%%
%% Twenty worlds evaluated a brain as a pure function of the current instant, so
%% every strategy of the form "I have been hungry for a while", "I came from over
%% there", "that patch was better than this one" was not unevolved but
%% INEXPRESSIBLE. No price this project has ever swept could have made one
%% appear.
%%
%% What is carried is exactly what the hidden layer just computed, so memory
%% costs no new constant, is as large as the brain and no larger, and a creature
%% with no hidden layer carries none and behaves exactly as it did in world 20.
%%
%% `maps:map' is safe here where it would not be elsewhere: this draws no random
%% numbers, so the order it visits creatures in cannot reach the world. `G.6' is
%% about folds that feed the generator.
recall(#world{creatures = Cs} = W) ->
    Herd = herd(Cs),
    W#world{creatures = maps:map(fun(_Id, C) -> remembered(C, Herd, W) end, Cs)}.

remembered(#{at := At} = C, Herd, W) ->
    C#{memory => brain:recall(maps:get(brain, C), inputs(C, At, At, Herd, W),
                              memory(C))}.

%% A creature born this tick has a memory of the right SHAPE and no content: one
%% zero per hidden node. The shape has to be right from the first instant,
%% because a row is `sensors + 1 + nodes' wide by construction and a short memory
%% would make `dot/2' read a truncated row.
memory(C) -> maps:get(memory, C, []).

blank(#{brain := Brain}) -> lists:duplicate(brain:hidden_count(Brain), 0).

%% Existing costs energy, and so does carrying the means to measure or the means
%% to think. THIS IS WHERE CAPABILITY IS PAID FOR: a sensor nothing acts on, or a
%% hidden node nothing listens to, makes its owner strictly poorer than a
%% neighbour without one.
charge(#world{creatures = Cs} = W) ->
    lists:foldl(fun charge_one/2, W, lists:sort(maps:keys(Cs))).

%% ==========================================================================
%% A.6: THE BILL IS CARRIED AT FULL PRECISION AND ONLY WHOLE UNITS ARE CHARGED
%% ==========================================================================
%%
%% `carrying/2' is an integer division, so a bill of 12.8 was charged as 12 and
%% the 0.8 was thrown away every tick. That is not a rounding nicety: the drift
%% step for a heritable integer is 8 and the divisor is 33, so THREE MUTATIONS IN
%% FOUR CHANGED THE BILL BY NOTHING AT ALL, and a creature carrying a mouth of 27
%% paid exactly what one carrying none paid. World 15 built a costly organ, ran
%% forty-eight seeds to twenty thousand ticks, and measured drift, because the
%% cost it was measuring did not exist at the resolution the trait moved in.
%%
%% SO THE FRACTION IS KEPT RATHER THAN DISCARDED. `owed' carries the numerator
%% forward, whole units are charged as they accumulate, and over enough ticks a
%% creature pays exactly `(structure + mouth + apparatus) / divisor' a tick with
%% nothing lost. A mouth of 27 now costs 27 over thirty-three ticks instead of
%% nothing for ever.
%%
%% CONSERVATION IS UNTOUCHED, which is the property that could not be risked.
%% `owed' is a counter of fractions and never energy: only whole units are ever
%% taken from a creature and every one of them is credited to `dissipated'. The
%% books close exactly as before and the existing test proves it at seven
%% efficiencies.
charge_one(Id, #world{creatures = Cs, econ = Econ} = W) ->
    C = maps:get(Id, Cs),
    #{owed := Owed} = C,
    Accrued = Owed + tissue(C, Econ),
    Divisor = max(1, maps:get(upkeep_divisor, Econ)),
    Cost = maps:get(metabolism, Econ) + Accrued div Divisor,
    burn(Id, C#{owed => Accrued rem Divisor}, Cost, W).

%% @doc Charge a creature and record where the energy went.
%%
%% NOTHING IS SPENT THAT WAS NEVER HELD, which is what the First Law costs us.
%% Before world 7 a creature paid metabolism it did not have, went to minus
%% thirty and died, and the floor at zero meant those thirty units had never
%% existed. Charging against nothing. No dissipation account can be laid over
%% that, because the books will not close.
%%
%% So it pays from the store, then by eating its own frame, and stops when there
%% is nothing left. A creature left holding nothing at all is dead, which is a
%% tick earlier than before and honest.
burn(Id, C, Cost, #world{creatures = Cs, econ = Econ} = W) ->
    {Paid, C1} = settle(C, Cost, maps:get(transfer_efficiency, Econ)),
    W#world{creatures = Cs#{Id => C1},
            dissipated = W#world.dissipated + Paid}.

settle(#{energy := E} = C, Cost, Eff) ->
    FromStore = min(Cost, max(0, E)),
    eat_own_frame(C#{energy => E - FromStore}, Cost - FromStore, FromStore, Eff).

%% STARVATION EATS THE BODY, and eating it is a transformation like any other, so
%% it loses its share. A starving creature therefore has to break down MORE frame
%% than the debt it is covering, which is why starving is expensive and why the
%% round trip out to a frame and back is not free.
eat_own_frame(C, 0, Paid, _Eff) ->
    {Paid, C};
eat_own_frame(#{structure := S} = C, _Short, Paid, _Eff) when S =< 0 ->
    {Paid, C};
eat_own_frame(#{energy := E, structure := S} = C, Short, Paid, Eff) ->
    Taken = min(S, needed_frame(Short, Eff)),
    Delivered = Taken * Eff div 100,
    Covered = min(Short, Delivered),
    {Paid + Covered + (Taken - Delivered),
     C#{energy => E + Delivered - Covered, structure => S - Taken}}.

%% To deliver N usable units at efficiency Eff you must break down more than N,
%% rounded up, because a fraction of a unit cannot be broken down twice.
needed_frame(Short, Eff) -> (Short * 100 + Eff - 1) div Eff.

%% ==========================================================================
%% AN ORGAN IS TISSUE, AND TISSUE IS CHARGED BY THE RATE TISSUE IS CHARGED AT
%% ==========================================================================
%%
%% Sensors and hidden nodes used to pay a FLAT RENT while a body paid a RATE.
%% That is the same inconsistency as C.6, B.7 and B.8: a law applied at one site
%% and not another, and it is the one this register has been walking past for
%% eleven worlds while recording its consequence in every results file.
%%
%% THE CONSEQUENCE, IN ARITHMETIC. A cell yields about 22 a tick. Metabolism is
%% 10, one sensor was 10, one hidden node was 10. **One eye plus one thought plus
%% staying alive cost more than the ground a creature stands on can give.**
%% Perception has measured 0.10 sensors and 0.01 hidden nodes per creature for
%% twelve worlds, and it was never being selected away for being useless. It was
%% unaffordable at any usefulness.
%%
%% So the apparatus is mass, and mass is charged by `carrying/2' like every other
%% gram. `body:mass/1' is the sensor's reach plus itself, the same shape the flat
%% rent used; a hidden node is one unit.
%%
%% ONE CONSTANT, AND NOBODY CHOOSES IT. Physics says a brain is tissue and tissue
%% costs by mass. It does not say how much dearer neural tissue is than
%% structural tissue, and biology says it genuinely is dearer: a human brain is
%% about 2% of the mass and 20% of the budget. So `neural_cost' is SWEPT and
%% every value published, exactly as world 7 swept the efficiency, and 330 is the
%% control because at the divisor of 33 it reproduces the old flat rent of 10 a
%% tick exactly. World 12 is therefore a point on this sweep rather than a
%% different world.
%% WHAT A CREATURE IS MADE OF, in units of tissue, before anything is divided.
%% Kept whole so `charge_one/2' can carry the fraction; `upkeep/2' below still
%% reports the per-tick bill for anything that wants to read it.
tissue(#{body := Body, brain := Brain, structure := S, mouth := Mouth}, Econ) ->
    S + Mouth
        + (body:mass(Body) + brain:hidden_weights(Brain))
              * maps:get(neural_cost, Econ)
        %% WORLD 18: AN ACT IS TISSUE TOO. Sensors pay by reach and hidden nodes
        %% pay by wiring, and until now a purpose was free: a creature carrying
        %% all four paid exactly what one carrying none paid. `H.7'.
        %%
        %% Charged by wiring like a hidden node, because an output vector IS
        %% wiring and the alternative is a flat fee, which is the shape world 13
        %% deleted from this world and `B.2' and `B.3' both objected to.
        + brain:output_weights(Brain) * maps:get(act_cost, Econ).

%% (`upkeep/2' is gone: `charge_one/2' owns the bill now, because the fraction
%% has to be carried across ticks and a per-tick function cannot do that.)

%% @doc What a transformation delivers, and what it costs to have delivered it.
%%
%% ONE CONSTANT, APPLIED AT EVERY SITE. The Second Law says no transformation is
%% free; it does not say by how much, so the size is swept rather than chosen and
%% only the sign is claimed.
delivered(Amount, Eff) -> Amount * Eff div 100.

%% BUILDING ORDER COSTS MORE, because creating a low-entropy structure has to be
%% paid for with a larger disorder elsewhere. That direction is the Second Law.
%% The SHAPE is chosen: squaring makes building strictly harsher than everything
%% else using one constant rather than two, and any monotone penalty would obey
%% the law equally well. Logged as register entry D.5.
built(Amount, Eff) -> Amount * Eff * Eff div 10000.

%% WHAT IT COSTS TO BE LARGE, charged on STRUCTURE alone. World 5 charged it on
%% everything a creature held, so a reserve was taxed as though it were working
%% tissue, and creatures could no longer differ in what they carried.
%%
%% A store is nearly free to hold. That is what fat is for.
carrying(S, Econ) ->
    max(0, S) div max(1, maps:get(upkeep_divisor, Econ)).

%%------------------------------------------------------------------------------
%% Moving: the only decision about WHERE
%%------------------------------------------------------------------------------

%% EVERY CREATURE VALUES THE SAME WORLD, the one at the start of the tick, and
%% they all move at once. Nobody sees anybody else's move before making their own,
%% which removes turn order as a source of advantage without needing a shuffle to
%% hide it.
%% ==========================================================================
%% A CREATURE GOES AS FAR AS IT CAN PAY TO GO, AND CARRYING A BODY COSTS
%% ==========================================================================
%%
%% Everything moved exactly one cell per tick, at a fare that ignored what it
%% weighed. Those are register entries `C.2' and `C.1', and together they are
%% why this world has only ever had ONE DRIVE.
%%
%% Movement is simultaneous and was the same speed for everyone, so an adjacent
%% predator could never be outrun: FLIGHT DID NOT EXIST, and prey had no
%% strategy available except being larger, which is the predator strategy.
%% Nothing pulled against anything, and the register's own diagnosis of ten
%% worlds of deleted brains follows from it: they are not being deleted for
%% being too small, they are being deleted because THERE IS NOTHING TO DECIDE.
%%
%% ONE RULE, TWO CLAUSES, AND THEY MUST ARRIVE TOGETHER. Unbounded steps at a
%% flat fare would be a free good handed to the large: a big creature is rich, so
%% it would be big AND fast, and size would dominate harder than before. The
%% fare has to scale with what is being hauled, or the tradeoff is not a
%% tradeoff. That is exactly the lesson world 4 taught and this register opens
%% with: a tradeoff only motors anything if nothing adjacent is free.
%%
%% NO NEW CONSTANT. The fare is `move_cost' plus `carrying/2', the same
%% expression that already prices holding a body, at the same divisor. Hauling
%% it and holding it cost alike.
%%
%% A CREATURE WILL NOT RE-ENTER A CELL IT HAS ALREADY STOOD IN THIS TICK, which
%% terminates the walk and is the only honest way to: two cells that each prefer
%% the other would otherwise trade a creature back and forth until it had burned
%% its whole body, and a thing cannot be in the same place twice in one moment.
move_all(#world{creatures = Cs} = W) ->
    Herd = herd(Cs),
    lists:foldl(fun(Id, Acc) -> travel(Id, Herd, Acc) end, W,
                lists:sort(maps:keys(Cs))).

travel(Id, Herd, #world{creatures = Cs} = W) ->
    #{at := At} = maps:get(Id, Cs),
    walk(Id, Herd, [At], settled(Id, W)).

%% Standing still is the default and costs nothing, so a creature that never
%% moves is marked still before the first step is considered.
settled(Id, #world{creatures = Cs} = W) ->
    W#world{creatures = Cs#{Id => (maps:get(Id, Cs))#{still => true}}}.

walk(Id, Herd, Been, #world{creatures = Cs, rng = Rng0} = W) ->
    #{at := At} = C = maps:get(Id, Cs),
    {Choice, Rng1} = where(brain:has(move, maps:get(brain, C)), Id, C, At, Herd,
                           W, Rng0),
    onward(Choice, Been, Id, Herd, W#world{rng = Rng1}).

%% Three ways a walk ends: nothing is preferred to here, the only preferred cell
%% has already been stood in this tick, or the fare cannot be paid.
onward({_Id, At, At}, _Been, _Id2, _Herd, W) -> W;
onward({_Id, _From, To}, Been, Id, Herd, W) ->
    keep_going(lists:member(To, Been) orelse not affords(Id, W), To, Been, Id,
               Herd, W).

keep_going(true, _To, _Been, _Id, _Herd, W) -> W;
keep_going(false, To, Been, Id, Herd, W) ->
    walk(Id, Herd, [To | Been], step(Id, To, W)).

%% WHAT IT COSTS TO CARRY YOURSELF ONE CELL. `carrying/2' is the same expression
%% that prices holding a frame, so hauling a body and holding it cost alike and
%% no second constant decides how heavy legs are.
fare(#{structure := S}, Econ) -> maps:get(move_cost, Econ) + carrying(S, Econ).

%% Paid from the store or from the frame, like every other cost since C.6, so a
%% creature can run itself down to nothing. What it cannot do is run on credit.
affords(Id, #world{creatures = Cs, econ = Econ}) ->
    #{energy := E, structure := S} = C = maps:get(Id, Cs),
    E + S >= fare(C, Econ).

%% Creature energy indexed by cell, gathered once per tick, so a sensor reading is
%% a lookup rather than a scan of the population.
herd(Cs) -> maps:fold(fun gather_flesh/3, #{}, Cs).

gather_flesh(_Id, #{at := At, energy := E}, Acc) ->
    maps:update_with(At, fun(Total) -> Total + E end, E, Acc).

%% AN ABSENT OUTPUT MEANS THE THING IS NOT DONE, and that has to be enforced here
%% rather than left to the arithmetic. Without this a creature with no `move'
%% scores every cell at zero, the tie is broken by drawing, and six times in seven
%% it wanders off and is charged the fare. Losing the output would then not be an
%% evolutionary event at all, merely a way to move at random while paying for it.
where(false, Id, _C, At, _Herd, _W, Rng) ->
    {{Id, At, At}, Rng};
where(true, Id, C, At, Herd, #world{econ = Econ} = W, Rng0) ->
    Options = [At | hex:neighbours_in(At, maps:get(radius, Econ))],
    Scored = [{value(C, Cell, At, Herd, W), Cell} || Cell <- Options],
    {To, Rng1} = pick_best(Scored, Rng0),
    {{Id, At, To}, Rng1}.

%% @doc WHAT A CREATURE MAKES OF EACH CELL IT COULD MOVE TO, if its store held
%% `Energy'. An observable, like `snapshot/1': it reads a rule and changes
%% nothing, and no rule reads it.
%%
%% THE WORLD'S OWN `value/5', NOT A COPY OF IT. `I.6' was an instrument that
%% computed its own version of a rule, was correct when written, and silently
%% stopped agreeing when the rule changed. An instrument that shares the code
%% path cannot drift from it.
%%
%% SCORES AND NOT A CHOSEN CELL, deliberately. `pick_best/2' breaks ties by
%% drawing from the generator, so two identical appraisals can produce two
%% different moves, and anything comparing CHOICES would report the tie-break as
%% a change of mind. What a creature thinks is the ranking.
%%
%% THE HERD IS RECOMPUTED FROM THE ALTERED CREATURE, because a creature's own
%% store is part of what a `creatures' sensor reads at its own cell. Varying the
%% store without varying that would appraise a world that cannot exist.
-spec appraise(world(), id(), non_neg_integer()) -> [{hex(), integer()}].
appraise(#world{creatures = Cs, econ = Econ} = W, Id, Energy) ->
    C = (maps:get(Id, Cs))#{energy => Energy},
    Cs1 = Cs#{Id => C},
    At = maps:get(at, C),
    Herd = herd(Cs1),
    W1 = W#world{creatures = Cs1},
    [{Cell, value(C, Cell, At, Herd, W1)}
     || Cell <- [At | hex:neighbours_in(At, maps:get(radius, Econ))]].

%% @doc WHAT A CREATURE WANTS TO DO WHERE IT STANDS, if its store held `Energy'.
%%
%% THE COMPANION TO `appraise/3' AND A DIFFERENT KIND OF DECISION, which is the
%% whole reason both exist. Moving is a RANKING across seven cells, so an input
%% that reads the same at every one of them shifts all the scores together and
%% cannot reorder anything. `breed', `grow' and `eat' are THRESHOLDS on one
%% output at one place, so there is nothing for a constant to cancel against and
%% the same input can decide the answer.
%%
%% Measuring one and reporting it as "behaviour" would be a claim about the
%% creature that is really a claim about which decision was looked at.
-spec consider(world(), id(), non_neg_integer()) ->
          #{brain:purpose() => integer()}.
consider(#world{creatures = Cs, econ = Econ} = W, Id, Energy) ->
    C = (maps:get(Id, Cs))#{energy => Energy},
    Cs1 = Cs#{Id => C},
    At = maps:get(at, C),
    brain:evaluate(maps:get(brain, C),
                   inputs(C, At, At, herd(Cs1), W#world{creatures = Cs1}),
                   memory(C), Econ).

%% @doc The living creatures, by id. An observable: the individuals themselves,
%% which every other reader of this module has so far been spared needing.
%% `snapshot/1' answers what the POPULATION is and cannot answer a question about
%% one creature's behaviour.
-spec creatures(world()) -> #{id() => creature()}.
creatures(#world{creatures = Cs}) -> Cs.

value(C, Cell, At, Herd, W) ->
    Outputs = brain:evaluate(maps:get(brain, C), inputs(C, Cell, At, Herd, W),
                             memory(C), W#world.econ),
    maps:get(move, Outputs, 0).

%% What a creature perceives of one candidate cell, in sensor order, then `here'.
%% `here' is an ordinary input rather than a special case, and it is why staying
%% put is expressible: movement costs and standing still does not, so a creature
%% that cannot tell where it already is cannot be sedentary on purpose.
inputs(#{body := Body} = C, Cell, At, Herd, W) ->
    [read(Sensor, Cell, C, Herd, W) || Sensor <- Body] ++ [here(Cell, At)].

here(Cell, Cell) -> 1;
here(_Cell, _At) -> 0.

read({self, _Range}, _Cell, #{energy := E}, _Herd, #world{econ = Econ}) ->
    %% NOT SPATIAL, so there is one cell to average over and the reach it may
    %% carry is read by nothing. See `H.8'.
    body:reading(self, E, 1, Econ);
read({Field, Range}, Cell, C, Herd, #world{econ = Econ} = W) ->
    body:reading(Field, gather(Field, Cell, Range, C, Herd, W),
                 length(hex:within(Cell, Range, maps:get(radius, Econ))), Econ).

gather(ground, Cell, Range, _C, _Herd, #world{ground = G, econ = Econ}) ->
    ground:within(Cell, Range, maps:get(radius, Econ), G);
%% A WATERED CELL READS AT THE CEILING AND A DRY ONE AT NOTHING. Summed over the
%% cells in reach and divided by how many there are, like every other spatial
%% field, so a reach-2 sensor reports the SHARE of its neighbourhood that is wet
%% rather than how many wet cells it can see. That is what makes reach mean
%% "how far do I average over" here as it does everywhere else, `F.2'.
gather(water, Cell, Range, _C, _Herd, #world{water = Water, econ = Econ}) ->
    Cells = hex:within(Cell, Range, maps:get(radius, Econ)),
    body:reading_ceiling() * length([C || C <- Cells, maps:is_key(C, Water)]);
%% A CREATURE DOES NOT PERCEIVE ITSELF AS SOMETHING IN THE WORLD. Its own energy
%% is subtracted from its own cell, or every creature would read the largest
%% concentration of flesh as wherever it is standing.
gather(creatures, Cell, Range, #{at := At, energy := E}, Herd,
       #world{econ = Econ}) ->
    Field = hex:within(Cell, Range, maps:get(radius, Econ)),
    lists:sum([maps:get(H, Herd, 0) || H <- Field]) - own(lists:member(At, Field), E);
%% A mark reads by how UNLIKE the reader it smells, so a creature's own trail and
%% its children's are nearly invisible to it.
gather(scent, Cell, Range, #{scent := Mine}, _Herd,
       #world{scent = Scent, econ = Econ}) ->
    Field = hex:within(Cell, Range, maps:get(radius, Econ)),
    lists:sum([foreign(maps:get(H, Scent, none), Mine) || H <- Field]).

own(true, E) -> max(0, E);
own(false, _E) -> 0.

foreign(none, _Mine) -> 0;
foreign(Mark, Mine) -> scent:perceived(Mark, Mine).

%% Ties are broken by drawing, not by taking the first. Candidates are generated
%% in a fixed compass order, so taking the first would make every indifferent
%% creature drift the same way forever and call it a random walk.
pick_best(Scored, Rng0) ->
    Best = lists:max([S || {S, _Cell} <- Scored]),
    pick([Cell || {S, Cell} <- Scored, S =:= Best], Rng0).

%% Staying still is free and leaves no trail. Moving costs and marks the ground:
%% that asymmetry makes sitting tight a way to go unnoticed as well as a way to
%% save energy, and it is the only counter available to something being tracked.
step(Id, To, #world{creatures = Cs, econ = Econ} = W) ->
    C = maps:get(Id, Cs),
    W1 = burn(Id, C#{at => To, still => false,
                     moved => maps:get(moved, C, 0) + 1}, fare(C, Econ),
              W#world{creatures = Cs#{Id => C}}),
    mark(To, maps:get(scent, C), W1).

mark(At, Tag, #world{scent = Scent, econ = Econ} = W) ->
    Fresh = strength(maps:get(At, Scent, none)) + maps:get(scent_per_tick, Econ),
    Capped = min(maps:get(scent_ceiling, Econ), Fresh),
    W#world{scent = Scent#{At => {Capped, Tag}}}.

strength(none) -> 0;
strength({S, _Tag}) -> S.

%%------------------------------------------------------------------------------
%% Consuming: one rule that does not know what it is eating
%%------------------------------------------------------------------------------

%% WHATEVER SHARES YOUR CELL AND CANNOT CONTEST YOU BECOMES YOURS, and then you
%% absorb whatever the ground there has gathered. Energy in the ground never
%% contests. A creature contests with its energy, and equals do not consume each
%% other.
%%
%% There is no separate path for eating a plant, because there are no plants. In
%% world 1 there were two functions with two names and two counters, which is
%% precisely why its claim to have deleted the herbivore/carnivore split was
%% false: the split survived as a structural fact about what exists.
consume(#world{creatures = Cs} = W) ->
    Herd = herd(Cs),
    lists:foldl(fun({_At, Ids}, Acc) -> resolve(lists:sort(Ids), Herd, Acc) end,
                W, consume_order(Cs)).

%% ⚠ SORTED TWICE, FOR THE SAME REASON `brain:nudge_all/3' IS. `resolve/3'
%% threads the world, and with it the generator, through the cells one at a time,
%% so the ORDER OF THE CELLS is part of the physics. It came from
%% `maps:values', which promises no order, and the occupants of a cell came from
%% prepending in `maps:fold' order, which decides WHO EATS FIRST where two
%% creatures share a cell. Neither is a property of this world.
%%
%% Every other phase of the tick already sorts: `charge', `move_all', `breed' and
%% `build' all fold over `lists:sort(maps:keys(Cs))'. This phase and the brain
%% were the two that did not, and consistency with the four that did is the whole
%% argument for the order chosen. Register `G.6'.
consume_order(Cs) -> lists:sort(maps:to_list(occupancy(Cs))).

occupancy(Cs) -> maps:fold(fun share_cell/3, #{}, Cs).

share_cell(Id, #{at := At}, Acc) ->
    maps:update_with(At, fun(Together) -> [Id | Together] end, [Id], Acc).

%% ==========================================================================
%% FEEDING IS A PROPERTY OF A CREATURE, NOT OF A CONTEST, AND IT IS BOUNDED ONCE
%% ==========================================================================
%%
%% This function was wrong in two ways that were invisible in it and visible
%% only across it, which is now the third time in this register: `C.6' was the
%% movement fare, `B.7' was capacity at one feeding site and not the other, and
%% this is `B.8'.
%%
%% ONLY THE WINNER ATE. `absorb' was called for the strongest creature in the
%% cell and for nobody else, so anything that tied with it survived the contest
%% and then did not feed at all. Sharing a cell with an equal cost a creature its
%% entire meal, and no rule anywhere says that.
%%
%% AND THE WINNER ATE TWICE. World 8 bounds grazing by `min(uptake, frame)' and
%% world 10 bounds meat by the same, INDEPENDENTLY, so a creature that made a
%% kill took its body's worth of meat and then its body's worth of ground in the
%% same tick. The stated law is that a creature cannot take in more than its
%% body allows. What was implemented is that it cannot take more than its body
%% allows FROM ANY ONE SOURCE.
%%
%% World 10 handed that a second mouthful without noticing: the carrion a
%% predator cannot finish is buried on its own cell inside `devour', and the
%% grazing ran immediately afterwards on that same cell.
%%
%% So every creature still standing feeds, once, up to its own capacity, from
%% what is left where it stands. Strongest first, because that is the order the
%% contest already established and an earlier grazer really does strip the cell.
%% NO NEW CONSTANT: the bound is the expression that was already at both sites.
%% ==========================================================================
%% WORLD 15: NOTHING IS EATEN UNLESS SOMETHING CHOOSES TO EAT IT
%% ==========================================================================
%%
%% Until now consumption was unconditional. The largest creature in a cell took
%% every smaller one, always, with no organ and no decision, which `D.2' has
%% called a free good since world 4 and `H.1' calls the missing half of it: `eat'
%% was not one of the purposes at all, so neither party decided anything.
%%
%% NOW A CONSUMER MUST BE ABLE AND WILLING. Able means a mouth, which is tissue
%% and is paid for every tick whether or not it is used. Willing means its brain
%% said so this tick. The strongest that is both takes the weaker; **if nobody in
%% the cell can or will, nothing is eaten and everyone lives.**
%%
%% THE RANK IS UNCHANGED and so is who loses. A creature that declines does not
%% shield anything: the next one down that can and will is the consumer, which is
%% the general form and avoids the arbitrary rule where a large toothless
%% creature protects its neighbours by standing there.
%%
%% GATHERED ONCE, like `breed/1', so a creature decides against the world as it
%% was when the phase began rather than one its neighbours have already eaten
%% their way through.
resolve(Ids, Herd, #world{creatures = Cs} = W) ->
    %% CONTEST IS DECIDED BY STRUCTURE, not by what a creature is carrying, so a
    %% fat small creature loses to a lean large one. Before world 6 the two were
    %% one number and hoarding was the same thing as being formidable.
    Ranked = lists:reverse(lists:sort([{maps:get(structure, maps:get(I, Cs)), I}
                                       || I <- Ids])),
    Order = [I || {_E, I} <- Ranked],
    hunted(predator(Order, Herd, W), Order, W).

%% The strongest that both carries a mouth and asked to use it, or `none'.
predator([], _Herd, _W) -> none;
predator([Id | Rest], Herd, W) -> willing_to_eat(Id, Rest, Herd, W).

willing_to_eat(Id, Rest, Herd, #world{creatures = Cs, econ = Econ} = W) ->
    #{at := At, mouth := Mouth} = C = maps:get(Id, Cs),
    Outputs = brain:evaluate(maps:get(brain, C), inputs(C, At, At, Herd, W),
                             memory(C), Econ),
    chose(Mouth > 0 andalso maps:get(eat, Outputs, 0) > 0, Id, Rest, Herd, W).

chose(true, Id, _Rest, _Herd, _W) -> Id;
chose(false, _Id, Rest, Herd, W) -> predator(Rest, Herd, W).

%% NOBODY ATE, so everybody grazes. This is the branch that did not exist before
%% world 15 and it is the whole change: a cell can now hold a large creature and
%% a small one and simply leave them both standing.
hunted(none, Order, W) ->
    graze(surviving(Order, W), none, 0, W);
hunted(Winner, Order, W) ->
    {W1, Eaten} = devour(Winner, [I || I <- Order, I =/= Winner], W),
    graze(surviving(Order, W1), Winner, Eaten, W1).

%% Everything the contest left alive, in the order the contest ranked it.
surviving(Ids, #world{creatures = Cs}) ->
    [I || I <- Ids, maps:is_key(I, Cs)].

%% The winner arrives here having already taken `Eaten' of its capacity as meat,
%% so what it may still draw from the ground is what remains of that same bound.
graze([], _Winner, _Eaten, W) -> W;
graze([Winner | Rest], Winner, Eaten, W) ->
    graze(Rest, Winner, Eaten, absorb(Winner, Eaten, W));
graze([Id | Rest], Winner, Eaten, W) ->
    graze(Rest, Winner, Eaten, absorb(Id, 0, W)).

devour(_Winner, [], W) -> {W, 0};
devour(Winner, Losers, #world{creatures = Cs} = W) ->
    #{structure := Mine} = maps:get(Winner, Cs),
    Weaker = [I || I <- Losers, maps:get(structure, maps:get(I, Cs)) < Mine],
    take_them(Weaker, Winner, W).

take_them([], _Winner, W) -> {W, 0};
%% A VICTIM YIELDS BOTH HALVES AS STORE. Structure is energy in another form, so
%% eating something digests its body into what you are carrying, and the books
%% close over ground plus stores plus structures.
%% A PREDATOR TAKES WHAT ITS BODY CAN HOLD, AND NO MORE, WHICH IS WORLD 8'S RULE
%% ARRIVING AT THE SITE IT MISSED.
%%
%% World 8 said a creature cannot take in more than its frame and applied it to
%% `absorb/2', where grazing is bounded by `min(uptake, frame, what is in the
%% cell)'. Energy enters a creature at TWO sites and the other one was left
%% alone, so until world 10 a creature that could sip four hundred a tick from
%% the ground could swallow an unlimited number of unlimited-size victims in a
%% single one. beam00 was taking 41% of its energy that way.
%%
%% NOBODY WROTE THAT RULE. It lived in the difference between two code paths,
%% which is exactly where the movement fare hid for five worlds (C.6). The only
%% way to find this kind of thing is to ask whether the same law holds at every
%% site, and the answer here was no.
%%
%% NO NEW CONSTANT: the bound is the expression already in `absorb/2'.
%%
%% WHAT THE PREDATOR CANNOT HOLD IS A CORPSE, and conservation forces that rather
%% than anyone choosing it: the energy has to go somewhere and the only place is
%% the ground it died on, buried exactly as every other corpse is. So a kill now
%% leaves CARRION, and eating something you could not have killed becomes a way
%% of living that nobody designed in.
%%
%% Who dies is unchanged. The contest still goes to the largest and every weaker
%% creature in the cell still loses; only how much of them the winner can use has
%% changed.
%% AND SINCE WORLD 15 THE MOUTH IS THE THIRD BOUND. A gut bounds what comes in
%% from the ground, a frame bounds what a creature can hold at all, and a mouth
%% bounds what it can take from the living. That is what mouth size BUYS, and it
%% is why the trait is drawn on the same scale as `uptake': the two are the same
%% quantity measured at the two sites energy enters a creature.
take_them(Weaker, Winner, #world{creatures = Cs, econ = Econ} = W) ->
    Carcass = lists:sum([whole(maps:get(I, Cs)) || I <- Weaker]),
    #{energy := E, from_creatures := F, at := At, mouth := Mouth,
      uptake := Want, structure := Body} = C = maps:get(Winner, Cs),
    Eaten = min(Carcass, min(Mouth, min(Want, max(0, Body)))),
    %% THE SAME LOSS AS EATING GROUND, and deliberately the same. Prey tissue
    %% really does convert more cheaply than raw material, but HOW MANY steps
    %% that saves is a fact about particular chemistry rather than about
    %% thermodynamics. This world prices steps and does not count them, so
    %% predation gets no discount here and world 7 is the test of whether it can
    %% pay without one.
    Gain = delivered(Eaten, maps:get(transfer_efficiency, Econ)),
    Fed = C#{energy => E + Gain, from_creatures => F + Gain},
    Ate = W#world{creatures = maps:without(Weaker, Cs#{Winner => Fed}),
                  dissipated = W#world.dissipated + (Eaten - Gain),
                  consumed = W#world.consumed + length(Weaker),
                  eaten_age = W#world.eaten_age
                      + lists:sum([maps:get(age, maps:get(I, Cs)) || I <- Weaker])},
    {bury(At, Carcass - Eaten, Ate), Eaten}.

%% A CREATURE TAKES AT MOST WHAT ITS BODY CAN, and that is the whole of world 4.
%% World 3 took everything, so every grazed cell sat at zero, so stock-dependent
%% recovery collapsed to its floor everywhere and the mechanism never once fired
%% in a populated world.
%%
%% Now a cell keeps whatever was not taken, and what a creature earns depends on
%% how hard it feeds against how fast the ground comes back. Feed gently and the
%% cell holds a standing stock indefinitely; feed hard and it is stripped, income
%% falls to the bare floor, and staying becomes fatal.
whole(#{energy := E, structure := S}) -> max(0, E) + max(0, S).

%% A CREATURE WITHOUT A BODY IS A GHOST, and world 7 was full of them: below
%% 70% efficiency every frame was zero, and those creatures ate, sensed, thought
%% and bred exactly as well as any other. Raf looked at a picture of it and said
%% it makes no sense, which it does not.
%%
%% The cause was that a body was OPTIONAL. It won contests and cost upkeep and
%% that was the whole of it; nothing a creature could do depended on having one.
%% So CAPACITY IS A PROPERTY OF STRUCTURE: you cannot take in more than your
%% body can hold, because there is nothing to take it in through.
%%
%% NO NEW CONSTANT. This is a comparison between two quantities the world already
%% tracks, not a threshold anybody chose, which is what makes it a deletion of a
%% free good rather than an added rule.
%%
%% Death from having no body is then a CONSEQUENCE rather than a decree: a
%% creature with no frame cannot feed, so it starves like anything else that
%% cannot feed. No rule anywhere says a frame of zero is fatal.
absorb(Id, Already, #world{creatures = Cs, ground = G} = W) ->
    #{at := At, energy := E, from_ground := P, uptake := Want,
      structure := Body} = C = maps:get(Id, Cs),
    %% WHAT IS LEFT OF ONE BOUND, not a second helping of it. `Already' is what
    %% this creature has taken as meat in this same tick, and before world 11
    %% the two were counted apart, so a kill bought a whole extra body's worth.
    Rate = max(0, min(Want, max(0, Body)) - Already),
    {Drawn, G1} = ground:draw(At, Rate, G),
    %% ASSIMILATION IS A TRANSFORMATION AND LOSES ITS SHARE. What leaves the
    %% ground is not what arrives in the creature, and the difference is heat.
    Gain = delivered(Drawn, maps:get(transfer_efficiency, W#world.econ)),
    W#world{creatures = Cs#{Id => C#{energy => E + Gain,
                                     from_ground => P + Gain}},
            ground = G1,
            dissipated = W#world.dissipated + (Drawn - Gain),
            absorbed = W#world.absorbed + Gain}.

%%------------------------------------------------------------------------------
%% Breeding, dying, fading
%%------------------------------------------------------------------------------

%% BUILDING IS A DECISION TOO, and it has to be. Splitting the store from the
%% structure forces a rule for how one becomes the other, and "a creature grows
%% when it has a surplus" would be biology written into the physics: the exact
%% shape of `breed_at', deleted in world 2 for that reason.
%%
%% THE OUTPUT'S VALUE IS THE AMOUNT, clamped to what the creature is carrying, so
%% it needs no constant of its own. A creature with no `grow' output never builds
%% at all, which is a living rather than a death sentence: it stays whatever size
%% it was born and spends everything on children instead.
%% THE HERD IS GATHERED ONCE, as `move_all' gathers it and as `herd/1' says it
%% is meant to be. Rebuilding it per creature made every creature in the fold see
%% the ones before it, which is the turn-order advantage this module's header
%% says it removed, and it made the phase quadratic in the population: at 2,263
%% creatures a single seed of 2,000 ticks took over an hour.
build(#world{creatures = Cs} = W) ->
    Herd = herd(Cs),
    lists:foldl(fun(Id, Acc) -> build_one(Id, Herd, Acc) end, W,
                lists:sort(maps:keys(Cs))).

build_one(Id, Herd, #world{creatures = Cs, econ = Econ} = W) ->
    #{at := At} = C = maps:get(Id, Cs),
    Outputs = brain:evaluate(maps:get(brain, C), inputs(C, At, At, Herd, W),
                             memory(C), Econ),
    invest(affordable(maps:get(grow, Outputs, 0), maps:get(energy, C)), Id, W).

%% BOTH ENDS CLAMPED AT NOTHING. A creature in debt has nothing to build with, and
%% clamping only against its store would let the shortfall through as a NEGATIVE
%% amount and run the transfer backwards, turning debt into structure and making a
%% starving creature grow. That drove structure below zero, which the books ought
%% to make impossible.
affordable(Wanted, Store) -> min(max(0, Wanted), max(0, Store)).

invest(0, _Id, W) -> W;
invest(Amount, Id, #world{creatures = Cs, econ = Econ} = W) ->
    #{energy := E, structure := S} = C = maps:get(Id, Cs),
    Made = built(Amount, maps:get(transfer_efficiency, Econ)),
    W#world{creatures = Cs#{Id => C#{energy => E - Amount,
                                     structure => S + Made}},
            dissipated = W#world.dissipated + (Amount - Made)}.

%% A CHILD IS A DECISION NOW, not a threshold. The brain is asked, on its own
%% cell, and above zero it spends HALF its current energy on a child placed
%% alongside. Zero is the natural boundary for a signed value and needs no
%% constant of its own.
%%
%% No floor stops a creature breeding itself down to nothing: one that does
%% leaves children too small to survive, and that is a bad strategy rather than an
%% illegal one. Four constants left the economy here and no rule replaced them.
%% GATHERED ONCE, for the same two reasons as `build/1' above. Here the artefact
%% was that a creature asked whether to breed while already seeing the children
%% its neighbours had just had, which is a decision made against a world that
%% does not exist yet for anybody else.
breed(#world{creatures = Cs} = W) ->
    Herd = herd(Cs),
    %% WHO IS WHERE, GATHERED ONCE, for the same reason the flesh is: a creature
    %% must not find a mate among the children its neighbours had earlier in this
    %% same fold. The board a creature breeds against is the board everyone else
    %% bred against.
    Near = occupancy(Cs),
    lists:foldl(fun(Id, Acc) -> breed_one(Id, Herd, Near, Acc) end, W,
                lists:sort(maps:keys(Cs))).

breed_one(Id, Herd, Near, #world{creatures = Cs, econ = Econ} = W) ->
    #{at := At, energy := E} = C = maps:get(Id, Cs),
    Outputs = brain:evaluate(maps:get(brain, C), inputs(C, At, At, Herd, W),
                             memory(C), Econ),
    willing(maps:get(breed, Outputs, 0) > 0 andalso E > 1, Id, Near, W).

willing(false, _Id, _Near, W) -> W;
willing(true, Id, Near, #world{creatures = Cs, econ = Econ} = W) ->
    room(map_size(Cs) < maps:get(max_creatures, Econ), Id, Near, W).

room(false, _Id, _Near, #world{births_refused = R} = W) ->
    W#world{births_refused = R + 1};
%% A PARENT DOES NOT DISMANTLE ITS OWN BODY TO MAKE A CHILD, and until world 9 it
%% did: half the frame went with half the store.
%%
%% World 8 is what made that fatal. Once capacity became a property of structure,
%% handing over half your frame permanently halved the rate at which you can feed,
%% and the transfer is lossy, so it compounds:
%%
%%     child frame = parent frame * efficiency / 200
%%
%% Deepest generation ever alive came out at 7, 4 and 1 at efficiencies 100, 70
%% and 30. Lineages that bred vanished within a few generations, selection kept
%% the founders that refuse to breed, and after tick 35 nothing new was ever born
%% in a world whose survivors were carrying four hundred times what they were
%% founded with. A TRADEOFF ONE END OF WHICH IS LEAVING THE GAME IS NOT A
%% TRADEOFF.
%%
%% So reproduction is paid out of the reserve, which is what a reserve is for and
%% what a reproductive buffer is in Kooijman's Dynamic Energy Budget theory. NO
%% NEW CONSTANT: the dowry is still half the store, and the child is founded from
%% it by the same split that founds a founder from `start_energy'.
room(true, Id, Near, #world{creatures = Cs, econ = Econ, rng = Rng0} = W) ->
    #{at := At, energy := E} = C = maps:get(Id, Cs),
    Dowry = E div 2,
    Eff = maps:get(transfer_efficiency, Econ),
    Given = delivered(Dowry, Eff),
    %% HALF STORE AND HALF FRAME, the odd unit to the frame, exactly as a founder
    %% is made. Even is the least-informative split: it favours neither carrying
    %% nor building and leaves the ratio to mutation and to what the child earns.
    %% A child of nothing could not feed, which since world 8 is fatal.
    Store = Given div 2,
    Built = Given - Store,
    {Where, Rng1} = pick(hex:neighbours_in(At, maps:get(radius, Econ)), Rng0),
    {Mate, Rng2} = partner(Id, At, Near, Cs, Econ, Rng1),
    {Traits, Change, Mark1, Rng3} = inherit_traits(C, Mate, Econ,
                                                  W#world.next_mark, Rng2),
    %% WHAT THE PARENT GIVES UP IS NOT WHAT THE CHILD RECEIVES. Assembling a
    %% second creature is a transformation and pays like every other one.
    Bred = maps:get(bred, C, 0) + 1,
    W1 = note_change(Change,
                     note_mate(Mate,
                               W#world{creatures = Cs#{Id => C#{energy => E - Dowry,
                                                               bred => Bred}},
                                       dissipated = W#world.dissipated + (Dowry - Given),
                                       next_mark = Mark1, rng = Rng3})),
    add_creature(Where, Store, Built, Id, Traits, W1).

%% ==========================================================================
%% WHO ELSE IS IN REACH, WHICH IS WORLD 20
%% ==========================================================================
%%
%% THE SEVEN CELLS A CREATURE CAN STEP INTO: its own and the six around it. Not a
%% new notion of nearness, but the one the world already has, the same
%% neighbourhood `where/7' chooses a move from and `body:reading/4' averages a
%% sensor over.
%%
%% ⚠ THE RADIUS WAS MEASURED, NOT CHOSEN. `scripts/is_anyone_in_reach.escript',
%% run before any of this was written: a creature shares its CELL with another
%% for 10% of its ticks and has someone in the seven cells for 55%. At a mean
%% life near nine ticks, co-location alone is about ONE encounter per lifetime,
%% which is `D.7' exactly ("nought to one chances in an entire life") and would
%% have made outcrossing fire so rarely that the result could not be told from
%% drift. Co-location is the narrower rule and it was rejected on the number.
%%
%% NOBODY CONSENTS AND NOBODY PAYS. The partner contributes genes and no energy,
%% and is not asked. Mate choice and a cost of sex are each a second experiment.
partner(Id, At, Near, Cs, Econ, Rng0) ->
    Me = maps:get(Id, Cs),
    Reach = [At | hex:neighbours_in(At, maps:get(radius, Econ))],
    %% Sorted, because `G.6' is what happens when a draw takes its order from a
    %% map: nineteen worlds where the same seed gave different worlds.
    Others = lists:sort([P || Cell <- Reach, P <- maps:get(Cell, Near, []),
                              P =/= Id]),
    drawn(kin_first(Me, Others, Cs), Cs, Rng0).

%% ==========================================================================
%% IT BREEDS WITH ITS OWN KIND, WHICH IS HOW A NOVELTY SURVIVES BEING RARE
%% ==========================================================================
%%
%% NEAT protects a new topology by letting it compete only inside its own species
%% until it has had time to be optimised, because a structural novelty is almost
%% always worse than the thing it must eventually beat, and dies before it can
%% get better. **This world has exactly that problem**: a new hidden node arrives
%% weighted zero everywhere, so it changes nothing and costs rent, and world 19
%% measured drift removing it faster than selection could find a use.
%%
%% World 20 made it worse. Outcrossing across seven cells means a rare lineage
%% breeds with whatever is locally common and has its genome diluted on the spot.
%%
%% THE ECOLOGICAL FORM OF NEAT'S ANSWER, USING A TRAIT THIS WORLD ALREADY HAS.
%% `scent:strangeness/2' is how unlike two signatures are, and its own
%% documentation says it "hands the world kin recognition for free, because your
%% children are at distance zero". A creature therefore breeds with the least
%% strange partner in reach. Two members of a novel lineage smell alike, so they
%% find each other, and a novelty gets a few generations among its own before it
%% has to meet the crowd.
%%
%% NO NEW CONSTANT AND NO THRESHOLD. NEAT needs a compatibility distance chosen
%% by hand; this needs only "the nearest", which is a comparison and not a
%% number. And it changes NOTHING about who survives: it is a rule about whom you
%% breed WITH, never about whom you beat.
kin_first(_C, [], _Cs) -> [];
kin_first(C, Others, Cs) ->
    Mine = maps:get(scent, C),
    Ranked = lists:sort([{scent:strangeness(Mine, maps:get(scent, maps:get(P, Cs))),
                          P} || P <- Others]),
    {Nearest, _P} = hd(Ranked),
    %% ⚠ ALL THE EQUALLY-CLOSE ONES, NOT THE FIRST OF THEM. Signatures are eight
    %% bits and strangeness runs 0 to 8, so ties are the common case rather than
    %% the exception. Taking the head of a sorted list would break every tie by
    %% LOWEST ID, which is the founding order, and `which_founder_wins.escript'
    %% exists because this project has been suspicious of exactly that dimension
    %% before. The draw below is over the whole tied set.
    [P || {S, P} <- Ranked, S =:= Nearest].

drawn([], _Cs, Rng) -> {alone, Rng};
drawn(Others, Cs, Rng0) ->
    {N, Rng1} = rand:uniform_s(length(Others), Rng0),
    {maps:get(lists:nth(N, Others), Cs), Rng1}.

note_mate(alone, W) -> W;
note_mate(_Mate, #world{outcrossed = N} = W) -> W#world{outcrossed = N + 1}.

note_change({added, _Pos}, #world{sensors_gained = G} = W) ->
    W#world{sensors_gained = G + 1};
note_change({dropped, _Pos}, #world{sensors_lost = L} = W) ->
    W#world{sensors_lost = L + 1};
note_change(none, W) ->
    W.

%% Three heritable things, mutated together. THE BODY AND THE BRAIN MUST STAY IN
%% STEP: a weight vector out of order with the sensor list is the one bug here
%% that does not crash, because every weight past the change point quietly starts
%% valuing a different measurement.
%% ⚠ RECOMBINATION HAPPENS FIRST AND MUTATION IS UNCHANGED. World 20 adds a way
%% for two genomes to become one and takes nothing away: the blended traits go
%% through exactly the same body mutation, brain topology mutation and weight
%% nudge that a clone has gone through since world 2. So a difference between
%% worlds 19 and 20 is recombination and cannot be anything else.
inherit_traits(Parent, Mate, Econ, Mark0, Rng0) ->
    {Source, Rng1} = combined(Mate, Parent, Econ, Rng0),
    mutate_traits(Source, Econ, Mark0, Rng1).

combined(alone, Parent, _Econ, Rng) -> {Parent, Rng};
combined(Mate, Parent, Econ, Rng) -> outcross:traits(Parent, Mate, Econ, Rng).

mutate_traits(Parent, Econ, Mark0, Rng0) ->
    #{body := Body, brain := Brain, scent := Tag, uptake := Rate,
      mouth := Mouth} = Parent,
    {ChildBody, Change, Rng1} = body:inherit(Body, Econ, Rng0),
    %% THE CHILD'S OWN SENSOR COUNT, passed rather than recovered: a brain with
    %% no hidden layer and no outputs has no shape to recover one from, and used
    %% to answer zero.
    {ChildBrain, Mark1, Rng2} = brain:inherit(Brain, Change, length(ChildBody),
                                              Mark0, Econ, Rng1),
    {ChildTag, Rng3} = scent:inherit(Tag, Econ, Rng2),
    {ChildRate, Rng4} = inherit_rate(Rate, Econ, Rng3),
    %% THE SAME DRIFT AS THE GUT AND NO NEW CONSTANT. `uptake_mutation' is
    %% described in this file as a scale constant of the same kind as
    %% `brain_mutation', small and symmetric so a lineage drifts rather than
    %% resamples. That is a property of heritable integers here and not of
    %% feeding, so it governs both.
    {ChildMouth, Rng5} = inherit_rate(Mouth, Econ, Rng4),
    {#{body => ChildBody, brain => ChildBrain, scent => ChildTag,
       uptake => ChildRate, mouth => ChildMouth}, Change, Mark1, Rng5}.

%% A small symmetric nudge so a lineage drifts through feeding rates rather than
%% resampling them.
%%
%% BOUNDED BY WHAT A CELL CAN HOLD, which is a gut and not a rule: a creature
%% takes at most one full cell's worth in a tick, so a corpse-enriched cell,
%% which sits above the ceiling and can hold far more, takes several ticks to
%% drain. Above that bound the trait would be neutral anyway, since `draw/3'
%% already refuses to hand over more than is there, and an unbounded trait drifts
%% into numbers that mean nothing and make the population average meaningless.
inherit_rate(Rate, Econ, Rng0) ->
    Mut = maps:get(uptake_mutation, Econ),
    {Step, Rng1} = rand:uniform_s(2 * Mut + 1, Rng0),
    Moved = Rate + Step - Mut - 1,
    {max(0, min(maps:get(ground_ceiling, Econ), Moved)), Rng1}.

%% DEATH RETURNS ENERGY TO THE GROUND IT DIED ON, and world 1 simply deleted it.
%% Not rounded away: a well-fed creature could be carrying hundreds and reaping it
%% destroyed every unit, which meant the energy books were never checkable at all.
%%
%% It is also where soil comes from. A deposit is not capped by `ground_ceiling',
%% so a cell where things have died is richer than any untouched cell can be, and
%% somewhere the population is dense the deaths keep coming and the ground stays
%% better than average. THE LANDSCAPE DIFFERENTIATES ITSELF AND LIFE IS WHAT
%% DIFFERENTIATES IT.
reap(#world{creatures = Cs, econ = Econ} = W) ->
    MaxAge = maps:get(max_age, Econ),
    Reaped = maps:fold(fun(Id, C, Acc) -> reap_one(Id, C, MaxAge, Acc) end,
                       W#world{creatures = #{}}, Cs),
    note_extinction(map_size(Reaped#world.creatures), Reaped).

note_extinction(0, #world{extinct_at = undefined, tick = T} = W) ->
    W#world{extinct_at = T};
note_extinction(_Alive, W) ->
    W.

%% IN DEBT WITH NOTHING LEFT TO CONVERT. Exactly nothing in store is spent rather
%% than dead: a creature that has just built its whole reserve into a frame still
%% has the frame, and eats it next tick if it must.
reap_one(_Id, #{energy := E, structure := St, at := At} = C, _MaxAge,
         #world{starved = S} = W)
  when E =< 0, St =< 0 ->
    bury(At, whole(C), W#world{starved = S + 1});
%% ⚠ RUNNING DRY IS ITS OWN CAUSE OF DEATH AND IS COUNTED SEPARATELY. Folded
%% into starvation it would be invisible, and "the world got harsher" and "the
%% world got thirsty" are different findings. Checked before age and after
%% starvation, so a creature that is both empty and dry is recorded as starved,
%% which is the older cause.
reap_one(_Id, #{water := Dry, at := At} = C, _MaxAge,
         #world{parched = P} = W) when Dry =< 0 ->
    bury(At, whole(C), W#world{parched = P + 1});
reap_one(_Id, #{age := A, at := At} = C, MaxAge,
         #world{aged_out = O} = W) when A > MaxAge ->
    bury(At, whole(C), W#world{aged_out = O + 1});
reap_one(Id, #{age := A} = C, _MaxAge, #world{creatures = Cs} = W) ->
    W#world{creatures = Cs#{Id => C#{age => A + 1}}}.

%% A CORPSE DECAYS, and decay is a transformation. What reaches the ground is
%% less than what the creature was carrying, and the rest is heat.
bury(At, Amount, #world{ground = G, econ = Econ} = W) ->
    Left = delivered(max(0, Amount), maps:get(transfer_efficiency, Econ)),
    W#world{ground = ground:deposit(At, Left, G),
            dissipated = W#world.dissipated + (max(0, Amount) - Left)}.

%% Every mark weakens and one that has weakened to nothing is dropped, so the map
%% holds only ground that still smells. Without the fade a busy cell becomes a
%% permanent road, and a board where everywhere smells alike carries exactly as
%% much information as one where nowhere does.
fade(#world{scent = Scent, econ = Econ} = W) ->
    Decay = maps:get(scent_decay, Econ),
    Weaken = fun(H, {S, Who}, Acc) -> linger(S - Decay, Who, H, Acc) end,
    W#world{scent = maps:fold(Weaken, #{}, Scent)}.

linger(S, _Who, _H, Acc) when S =< 0 -> Acc;
linger(S, Who, H, Acc) -> Acc#{H => {S, Who}}.

%%==============================================================================
%% Reading a world: statistics only, never rules
%%==============================================================================

%% NOTHING BELOW IS READ BY THE PHYSICS. These are an observer's numbers, and no
%% creature is ever treated differently for what any of them say. That separation
%% is what makes it legitimate to count diet at all: it is a description applied
%% afterwards, not a category the world enforces.
-spec snapshot(world()) -> map().
snapshot(#world{econ = Econ} = W) ->
    #{tick => W#world.tick,
      population => map_size(W#world.creatures),
      %% One half of the world's books. The other is the creatures, and together
      %% they only change by influx in and by what living costs.
      ground_total => ground:total(W#world.ground),
      %% HOW UNEVENLY THE GROUND HOLDS ENERGY: the percentage lying in the
      %% richest tenth of cells. Ten means flat. Anything above says places have
      %% become different from each other, and since nothing installed terrain,
      %% whatever difference exists was made by things dying.
      ground_spread => ground:spread(W#world.ground),
      born => W#world.born,
      starved => W#world.starved,
      aged_out => W#world.aged_out,
      consumed => W#world.consumed,
      absorbed => W#world.absorbed,
      births_refused => W#world.births_refused,
      %% ==================================================================
      %% WORLD 23: THE DOSE, AND THE ONE NUMBER THAT TELLS A CULL FROM AN
      %% ADAPTATION
      %% ==================================================================
      %%
      %% `parched' counts creatures that ran dry. Without it, "the rule changed
      %% nothing" and "the rule killed everything" are indistinguishable in
      %% every other column.
      %%
      %% ⚠ `to_water_mean' IS THE FINDING. The pre-registration predicts a
      %% FILTER rather than an adaptation: at seven holes half the population
      %% cannot reach water in a lifetime, so world 23 may simply kill whatever
      %% was born too far out and select on birthplace. That would look like a
      %% result and would be a cull.
      %%
      %% Creatures are scattered at random when a world is founded, so the mean
      %% distance to the nearest hole AT TICK ZERO is the null. If it falls,
      %% creatures are approaching water and that is adaptation. If it holds,
      %% the rule is a sieve.
      parched => W#world.parched,
      %% Energy that left with migrants and energy that came with them. A reader
      %% adding `energy_total + structure_total + ground_total + dissipated +
      %% departed - arrived' gets a number that does not move, on any island, and
      %% summing it over the archipelago is the only place the crossing itself is
      %% audited.
      departed => W#world.departed,
      arrived => W#world.arrived,
      to_water_mean => to_water(W),
      water_holes => map_size(W#world.water),
      %% THE DOSE, AND A NULL IS UNREADABLE WITHOUT IT. Outcrossing is
      %% facultative: it fires only when somebody is in reach, so "recombination
      %% changed nothing" and "recombination almost never happened" look
      %% identical in every other column.
      outcrossed => W#world.outcrossed,
      %% ==================================================================
      %% HOW MUCH OF THE SPACE OF WAYS-OF-LIVING HAS BEEN FOUND
      %% ==================================================================
      %%
      %% `explored' is how many of the 125 behaviour cells have ever held a
      %% creature. `frontier' is how many were first seen in the last thousand
      %% ticks, and it is the one number here that answers "is this world still
      %% discovering anything". **A frontier of zero is convergence**, and it is
      %% the closest thing a world with no fitness function has to a curve.
      %%
      %% `deepest_elite' is the deepest lineage any behaviour ever produced,
      %% which says whether the ways of living that were found were survivable
      %% or merely visited.
      %% ==================================================================
      %% WHAT MOST CREATURES HERE ARE ACTUALLY LIKE, IN WORDS
      %% ==================================================================
      %%
      %% Every other line of this census is a number or a count of a shape. This
      %% is the commonest way of MAKING A LIVING, spelled out, and the share of
      %% the population living that way.
      %%
      %% ⚠ ADJECTIVES DERIVED FROM BINS, NEVER A SPECIES. "grazes, sessile,
      %% breeds hard" describes measurements; "pigs" would assert a kind of
      %% thing, and there are no kinds of thing here, only a continuum with bins
      %% drawn through it. `body.erl' records what naming did to world 1.
      commonest_way => commonest_portrait(W),
      commonest_way_pct => portrait_share(W),
      %% ⚠ AND HOW OLD THEY ARE, BESIDE IT, BECAUSE THE TWO CONFOUND.
      %%
      %% A creature needs ticks to move anywhere, eat anything or make a child,
      %% and the mean life here is about nine of them. So a large share of any
      %% living population is simply YOUNG, and reads as "barren, starving"
      %% because it has not had time to be anything else. On the first live run
      %% the commonest portrait was exactly that, at 36%.
      %%
      %% **That is not a fault in the portrait and it is a trap for a reader**:
      %% "most creatures are barren and starving" sounds like a dying world and
      %% describes a nursery. No threshold is introduced to hide it, because a
      %% cutoff age would be a constant nobody could justify. The age is
      %% published instead, so the confound is visible rather than removed.
      age_mean => age_mean(W),
      explored => map_size(W#world.archive),
      frontier => frontier(W),
      behaviour_space => behaviour:bins() * behaviour:bins() * behaviour:bins(),
      deepest_elite => deepest_elite(W),
      %% The occupied cells themselves, so a reader can draw the map rather than
      %% be told a count. Flat: cell, first seen, best depth.
      archive => flatten_archive(W#world.archive),
      archive_stride => 3,
      energy_total => total_energy(W),
      %% STRUCTURE REPORTED APART FROM STORE, because a mean of the two added
      %% together is exactly the conflation world 6 exists to undo.
      %% THE FIRST LAW AS A TEST RATHER THAN A CLAIM. Every unit that left the
      %% pools is here, so ground + stores + frames + dissipated is exactly
      %% constant apart from what the sun adds. At one temperature this is also
      %% the entropy account, so the Second Law is the statement that it never
      %% falls.
      dissipated => W#world.dissipated,
      structure_total => total_structure(W),
      structure_max => largest_structure(W),
      radius => maps:get(radius, W#world.econ),
      econ => W#world.econ,
      econ_id => econ_id(W#world.econ),
      seed => W#world.seed,
      extinct_at => W#world.extinct_at,
      %% THE PLANT-NESS OF THE POPULATION, observed and never declared: the
      %% percentage that did not move this tick. A creature that stays where it
      %% is and lives off what gathers there IS a plant, and nothing in the rules
      %% calls it one.
      still_pct => still_share(W),
      hidden_mean => mean_hidden(W),
      %% HOW WIDE A THOUGHT IS, in inputs per hidden node, times a hundred.
      %% Committed to in world 16's pre-registration whatever the result, because
      %% it is the only number that separates a brain getting CHEAPER from a
      %% brain getting SIMPLER, and no world before 16 measured the shape of
      %% these brains at all.
      hidden_inputs_mean => mean_fan_in(W),
      %% THE NEW AXIS. Prudence against greed, as the population settled it, and
      %% nothing anywhere calls either of those.
      uptake_mean => mean_uptake(W),
      %% ==================================================================
      %% HOW MUCH MOUTH THE POPULATION CARRIES, WORLD 15
      %% ==================================================================
      %%
      %% NOT `carnivores_pct', WHICH IS WHAT THIS WAS FIRST CALLED AND WAS WRONG
      %% TWICE OVER. Raf caught both. "Herbivore" is wrong because there are no
      %% plants and a mouthless creature is an absorber. "Carnivore" is worse:
      %% it names a TYPE, and this world has no types, only investments. The
      %% spectator page has said for two worlds that nothing in the rules names
      %% a predator and there is no carnivore flag to set, and then a carnivore
      %% flag was added.
      %%
      %% AND A SHARE OF CARRIERS COULD NOT HAVE ANSWERED ANYTHING. `mouth > 0'
      %% is satisfied by a mouth of one, and the trait is a drifting integer, so
      %% it read 94 to 100 percent across worlds ranging from functionally
      %% toothless to a quarter carnivorous. The histogram is the instrument the
      %% question needed: whether a single population holds both ways of living
      %% is a statement about the SHAPE of the distribution, which no share and
      %% no mean can carry.
      mouth_mean => mean_mouth(W),
      mouth_hist => binned(mouth_values(W), maps:get(ground_ceiling, Econ)),
      %% ==================================================================
      %% THE ENGINE, MEASURED RATHER THAN ASSUMED
      %% ==================================================================
      %%
      %% Every world so far has reported what the population IS and none has
      %% reported whether it can still become anything else. Those are different
      %% questions and world 8 is the case that separates them: four to sixteen
      %% creatures, enormously rich, and frozen.
      %%
      %% `lineages' is how many foundings are still represented, `depth' how far
      %% the deepest surviving line has descended, and the uptake pair the spread
      %% of the one heritable quantity that visibly varies. Selection has nothing
      %% to act on when the spread is nothing, and no rule of this world can
      %% change that, which is why it is reported beside the population rather
      %% than derived afterwards.
      lineages => count_lineages(W),
      depth => deepest(W),
      uptake_min => uptake_min(W),
      uptake_max => uptake_max(W),
      %% WHERE THE LIVING GOT THEIR ENERGY, as a percentage that came from other
      %% creatures. Zero means nothing alive has ever eaten anything that could
      %% have eaten it back. This replaces the herbivore and carnivore buckets,
      %% which needed thresholds nobody could justify and named two roles the
      %% world had no opinion about.
      from_creatures_pct => predation_share(W),
      %% HOW MANY INDIVIDUALS LIVE THAT WAY, which the share above cannot say.
      %% That share is a sum over the WHOLE POPULATION, so a minority living
      %% entirely off other creatures is invisible in it whenever the majority
      %% draws more from the ground in total. World 6's frame histogram came back
      %% bimodal, which is what exposed the gap: a population mean cannot answer
      %% a question about a subgroup.
      %%
      %% Counted, not named. A creature that has taken more from creatures than
      %% from ground is one the world treats exactly like every other, and the
      %% comparison is made here by an observer after the fact.
      fed_by_creatures => living_off_creatures(W),
      %% HOW OLD THE EATEN WERE, in hundredths of a tick. World 9 is the first
      %% world where anything lives off other creatures, and it is also the world
      %% that made a newborn the lightest thing on the board. A mean near one
      %% says the prey is newborns and the niche is infanticide; a mean well
      %% above the population's own mean lifespan says something else is being
      %% hunted. The share cannot tell them apart and neither can the count.
      eaten_age_mean => share(W#world.consumed, W#world.eaten_age),
      %% WHAT THE POPULATION IS BUILT FROM, per field: how many carry a sensor
      %% for it and how much total reach is devoted to it. A census, not a
      %% verdict: it says what survived, not what was useful.
      sensors => sensor_census(W),
      %% THE SHAPE OF THE POPULATION, not its average. A mean of 0.01 sensors per
      %% creature is easy to read as "nearly none" without saying what that
      %% means: one creature in a hundred carrying one, or something else
      %% entirely. A count at each value cannot be skimmed past, and a
      %% distribution pinned wholly at zero states plainly that the apparatus has
      %% been selected away rather than merely worn thin.
      %%
      %% Bounded by the safety valves, so these are short fixed-length lists and
      %% cost a handful of integers a second.
      sensor_hist => histogram(sensor_counts(W), maps:get(max_sensors, Econ)),
      hidden_hist => histogram(hidden_counts(W), maps:get(max_hidden, Econ)),
      %% Binned, because a feeding rate runs to hundreds and a bar per value
      %% would be unreadable. This is the one that actually varies today.
      uptake_hist => binned(uptake_values(W), maps:get(ground_ceiling, Econ)),
      %% THE LARGEST CREATURE ALIVE, without which "size is now bounded" cannot
      %% be read at all, and the shape of the population's sizes, because a mean
      %% cannot tell one optimum from two.
      energy_max => largest(W),
      energy_hist => binned(energies(W), largest(W)),
      %% AND THE SAME FOR THE FRAME, because world 6's whole question is whether
      %% these two came apart. A maximum says how large the largest got and
      %% cannot say whether the population sits at one size or several, which is
      %% the pre-registered finding: lineages that carry much and build little,
      %% or the reverse.
      structure_hist => binned(structures(W), largest_structure(W)),
      %% HOW OLD THE CREATURES IN EACH FRAME BUCKET ARE, which is what tells a
      %% bimodal size distribution apart from an AGE STRUCTURE. Measure a village
      %% and find two heights, and you have either two kinds of person or else
      %% children and adults. Same numbers, entirely different claim.
      %%
      %% Rising steadily with the bucket means the large are simply the old, and
      %% "two livings" is an overclaim. Flat across the buckets means creatures of
      %% the same age settled at different sizes, which is the real thing.
      age_by_frame => age_by_frame(W),
      movers => outputs_with(move, W),
      breeders => outputs_with(breed, W),
      sensor_mean => mean_sensors(W),
      %% HOW MANY THINGS A CREATURE CAN DO, and WHICH. World 18 prices the
      %% ability to act, so "how many purposes are carried" is the quantity it
      %% moves, and a mean alone cannot answer the question it raises: `H.12'
      %% says the four are not equivalent, because losing `breed' ends a lineage
      %% in one generation and losing `eat' does not. A count per purpose is what
      %% tells a price acting on all four apart from one acting on two.
      %% HOW WIDE A HIDDEN NODE ACTUALLY IS, in live weights per node times a
      %% hundred. World 19's own finding: `H.11` says a narrow brain cannot be
      %% expressed, so nothing has ever needed to measure narrowness.
      hidden_width => mean_width(W),
      %% ==========================================================================
      %% HOW MANY KINDS OF CREATURE ARE ALIVE, as against how many ancestors
      %% ==========================================================================
      %%
      %% `lineages' counts founders with surviving descendants. It can only fall,
      %% it has read 1 since world 9, and `G.1' warns in its own words that **a
      %% founding is ANCESTRY AND NOT A KIND**. Eighteen worlds reported that 1 as
      %% a monoculture.
      %%
      %% A KIND is what a creature IS: its sorted body, how many hidden nodes it
      %% carries, and which purposes it has. Weights and scalars are variation
      %% WITHIN a kind, the way allele frequencies are within a species; topology
      %% is the kind. Measured at 5,000 ticks, worlds reading `lineages' of 1
      %% carry **5 to 27 distinct architectures**, with the commonest holding 20
      %% to 80 percent.
      %%
      %% Sorted on both axes so a kind cannot depend on map or list order. `G.6'.
      kinds => count_kinds(W),
      %% What share of the living the commonest architecture holds, so a world of
      %% twenty kinds where one holds 95% is not read as a world of twenty kinds.
      kind_max_pct => biggest_kind(W),
      purposes_mean => mean_purposes(W),
      purposes_hist => purpose_census(W),
      %% Whether the body plan is still moving at all.
      sensors_gained => W#world.sensors_gained,
      sensors_lost => W#world.sensors_lost,
      %% Properties of the signature, independent of anything evolved to use it.
      scent_cells => map_size(W#world.scent),
      scent_tags => length(lists:usort(tags(W))),
      scent_spread => scent:spread(tags(W))}.

%% Bodies paired with how much attention each of their inputs receives, because a
%% carried sensor and a used one are different things and only the brain knows
%% how many vectors read a given column.
sensor_census(#world{creatures = Cs}) ->
    body:census([{B, brain:attention(Br, length(B))}
                 || #{body := B, brain := Br} <- maps:values(Cs)]).

%% Per purpose, in the fixed order `brain:purposes/0' gives, so two islands and
%% two ticks are always comparable position by position.
%% ⚠ THE WORLD IS PASSED THROUGH AND NOT REBUILT. A first version constructed
%% `#world{creatures = Cs}' to hand to `outputs_with/2', which defaults every
%% other field to `undefined' and violates its own record's types. Dialyzer read
%% it as a function with no local return and took `snapshot/1' down with it,
%% which is the whole reason that gate is in the pipeline.
purpose_census(W) -> [outputs_with(P, W) || P <- brain:purposes()].

count_kinds(#world{creatures = Cs}) -> map_size(kind_tally(Cs)).

biggest_kind(#world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
biggest_kind(#world{creatures = Cs}) ->
    Counts = maps:values(kind_tally(Cs)),
    lists:max([0 | Counts]) * 100 div map_size(Cs).

%% Named rather than nested, because a fun inside `maps:update_with' inside a
%% fold is three levels and elvis holds this repo to two.
kind_tally(Cs) -> lists:foldl(fun tally_kind/2, #{}, maps:values(Cs)).

tally_kind(C, Acc) -> maps:update_with(kind_of(C), fun bump/1, 1, Acc).

bump(N) -> N + 1.

%% THE BODY SORTED, THE PURPOSES SORTED, AND THE HIDDEN LAYER AS A COUNT. Two
%% creatures of one kind differ only in weights and scalars, which drift
%% continuously and would make every creature unique if they counted.
kind_of(#{body := Body, brain := Brain}) ->
    {lists:sort(Body), length(maps:get(hidden, Brain)),
     lists:sort(maps:keys(maps:get(outputs, Brain)))}.

mean_width(#world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
mean_width(#world{creatures = Cs}) ->
    Widths = [brain:live_per_node(Br) || #{brain := Br} <- maps:values(Cs)],
    Carrying = [W || W <- Widths, W > 0],
    mean_of(Carrying).

%% Averaged over the creatures that HAVE a node. A creature with no hidden layer
%% is not narrow, it is absent, and folding its zero in would report a world
%% getting narrower every time a node was deleted.
mean_of([]) -> 0;
mean_of(L) -> lists:sum(L) div length(L).

mean_purposes(#world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
mean_purposes(#world{creatures = Cs}) ->
    Total = lists:sum([length(brain:carried(Br))
                       || #{brain := Br} <- maps:values(Cs)]),
    Total * 100 div map_size(Cs).

outputs_with(_Purpose, #world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
outputs_with(Purpose, #world{creatures = Cs}) ->
    length([x || #{brain := Br} <- maps:values(Cs), brain:has(Purpose, Br)]).

still_share(#world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
still_share(#world{creatures = Cs}) ->
    length([x || #{still := true} <- maps:values(Cs)]) * 100 div map_size(Cs).

%% How many creatures sit at each value, from none up to the cap. A cap is a
%% safety valve rather than a model parameter, so anything at it is counted there
%% rather than dropped.
histogram(Values, Max) ->
    Empty = maps:from_keys(lists:seq(0, Max), 0),
    Tally = lists:foldl(fun(V, Acc) -> bump(min(Max, V), Acc) end, Empty, Values),
    [maps:get(I, Tally) || I <- lists:seq(0, Max)].

%% THE SAME, IN BUCKETS, for a quantity that runs to hundreds. Eight is enough to
%% see a shape and few enough to draw on a card, and the top bucket catches
%% anything at the ceiling rather than losing it.
binned(Values, Ceiling) ->
    Width = max(1, (Ceiling + 1) div ?BUCKETS),
    histogram([min(?BUCKETS - 1, V div Width) || V <- Values], ?BUCKETS - 1).

bump(Key, Acc) -> maps:update_with(Key, fun(N) -> N + 1 end, Acc).

largest(#world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
largest(#world{creatures = Cs}) ->
    lists:max([max(0, E) || #{energy := E} <- maps:values(Cs)]).

energies(#world{creatures = Cs}) ->
    [max(0, E) || #{energy := E} <- maps:values(Cs)].

structures(#world{creatures = Cs}) ->
    [max(0, S) || #{structure := S} <- maps:values(Cs)].

age_by_frame(#world{creatures = Cs} = W) ->
    Width = max(1, (largest_structure(W) + 1) div ?BUCKETS),
    Grouped = lists:foldl(fun(C, Acc) -> by_bucket(C, Width, Acc) end, #{},
                          maps:values(Cs)),
    [mean_age(maps:get(B, Grouped, [])) || B <- lists:seq(0, ?BUCKETS - 1)].

by_bucket(#{structure := S, age := A}, Width, Acc) ->
    Bucket = min(?BUCKETS - 1, max(0, S) div Width),
    maps:update_with(Bucket, fun(L) -> [A | L] end, [A], Acc).

mean_age([]) -> 0;
mean_age(Ages) -> lists:sum(Ages) div length(Ages).

sensor_counts(#world{creatures = Cs}) ->
    [length(B) || #{body := B} <- maps:values(Cs)].

mean_fan_in(#world{creatures = Cs}) ->
    Nodes = lists:sum([brain:hidden_count(B) || #{brain := B} <- maps:values(Cs)]),
    Wires = lists:sum([brain:hidden_weights(B) || #{brain := B} <- maps:values(Cs)]),
    fan_in(Wires, Nodes).

fan_in(_Wires, 0) -> 0;
fan_in(Wires, Nodes) -> Wires * 100 div Nodes.

hidden_counts(#world{creatures = Cs}) ->
    [brain:hidden_count(Br) || #{brain := Br} <- maps:values(Cs)].

uptake_values(#world{creatures = Cs}) ->
    [U || #{uptake := U} <- maps:values(Cs)].

mean_uptake(#world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
mean_uptake(#world{creatures = Cs}) ->
    lists:sum([U || #{uptake := U} <- maps:values(Cs)]) div map_size(Cs).

mean_mouth(#world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
mean_mouth(#world{creatures = Cs}) ->
    lists:sum([M || #{mouth := M} <- maps:values(Cs)]) div map_size(Cs).

mouth_values(#world{creatures = Cs}) ->
    [M || #{mouth := M} <- maps:values(Cs)].

count_lineages(#world{creatures = Cs}) ->
    map_size(maps:from_keys([L || #{lineage := L} <- maps:values(Cs)], [])).

deepest(#world{creatures = Cs}) ->
    lists:max([0 | [G || #{generation := G} <- maps:values(Cs)]]).

uptake_min(W) -> extreme(fun lists:min/1, uptake_values(W)).

uptake_max(W) -> extreme(fun lists:max/1, uptake_values(W)).

extreme(_F, []) -> 0;
extreme(F, Rates) -> F(Rates).

mean_hidden(#world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
mean_hidden(#world{creatures = Cs}) ->
    Total = lists:sum([brain:hidden_count(B) || #{brain := B} <- maps:values(Cs)]),
    Total * 100 div map_size(Cs).

tags(#world{creatures = Cs}) -> [T || #{scent := T} <- maps:values(Cs)].

mean_sensors(#world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
mean_sensors(#world{creatures = Cs}) ->
    Total = lists:sum([length(B) || #{body := B} <- maps:values(Cs)]),
    Total * 100 div map_size(Cs).

%% Of all the energy the living have ever eaten, what share came from creatures.
%% Zero for a population that has eaten nothing, rather than a crash.
living_off_creatures(#world{creatures = Cs}) ->
    length([Id || {Id, #{from_ground := P, from_creatures := M}}
                      <- maps:to_list(Cs), M > P]).

predation_share(#world{creatures = Cs}) ->
    Vals = maps:values(Cs),
    Plants = lists:sum([P || #{from_ground := P} <- Vals]),
    Meat = lists:sum([M || #{from_creatures := M} <- Vals]),
    share(Plants + Meat, Meat).

share(0, _Meat) -> 0;
share(Total, Meat) -> Meat * 100 div Total.

%% @doc A short, stable fingerprint of the rules this world runs under.
%%
%% Two islands running different economies are not comparable and nothing else on
%% the wire would say so. Canonical bytes are built by hand rather than with
%% term_to_binary, whose output is only stable WITHIN an OTP release: two honest
%% islands on different releases would otherwise compute different ids for
%% identical rules, which destroys the only property a fingerprint has.
-spec econ_id(econ()) -> binary().
econ_id(Econ) ->
    Pairs = [[atom_to_list(K), $=, integer_to_list(V)]
             || {K, V} <- lists:sort(maps:to_list(Econ))],
    Canonical = lists:join($,, Pairs),
    <<Short:8/binary, _/binary>> = crypto:hash(sha256, iolist_to_binary(Canonical)),
    string:lowercase(binary:encode_hex(Short)).

%% @doc Where everything is, as flat coordinate lists `[Q1, R1, Q2, R2 | ...]'.
%%
%% Flat integers rather than pairs, because a pair is a tuple and tuples do not
%% survive this mesh cleanly, and because a map per entity would repeat the keys
%% `q' and `r' for every creature for no information. Sorted, so two charts of
%% the same world are the same bytes and a diff between frames means something.
%% ENERGY AND SCENT TRAVEL TOO, because they are the two things about this world
%% that are SPATIAL and were invisible. Positions alone draw a world where every
%% creature is identical and nothing has happened anywhere, which is a picture of
%% neither of the two results this world actually produced: that energy is armour
%% and that the ground remembers who walked on it.
%%
%% `energies' runs parallel to `creatures', one per creature in the same order,
%% rather than being interleaved. Interleaving would make the creature stride 3
%% while plants stayed 2, and a reader that got that wrong would draw a plausible
%% and completely wrong picture rather than failing.
%%
%% `scent' IS interleaved, at a stride of 3, because a mark is a position AND a
%% strength and there is no list it runs parallel to. The signature is left out:
%% it would double the payload and a spectator has nothing to compare it against.
-spec chart(world()) -> #{ids := [integer()], creatures := [integer()],
                          energies := [integer()],
                          structures := [integer()],
                          signatures := [integer()], uptakes := [integer()],
                          ground := [integer()],
                          water := [integer()],
                          scent := [integer()],
                          kind_of := [integer()], kind_table := [integer()],
                          senses := [integer()], nodes := [integer()],
                          radius := non_neg_integer(), tick := non_neg_integer()}.
chart(#world{creatures = Cs, ground = G, scent = Scent, water = Water,
             econ = Econ, tick = Tick}) ->
    Ids = lists:sort(maps:keys(Cs)),
    #{creatures => flatten_hexes([maps:get(at, maps:get(Id, Cs)) || Id <- Ids]),
      %% WHO EACH MARK IS, in the same order as everything else.
      %%
      %% A spectator drawing one frame does not need this. A spectator ANIMATING
      %% between two frames cannot do without it: creature number three in this
      %% frame is a different creature from number three in the next as soon as
      %% anything is born or eaten, and at a mean lifespan of about two ticks
      %% that is every frame. Matching by position in the list would slide marks
      %% across the board that never moved.
      ids => Ids,
      %% Floored at zero: a creature awaiting the reaper carries a negative
      %% balance, and a viewer sizing a dot by it would be asked to draw a
      %% negative radius.
      energies => [max(0, maps:get(energy, maps:get(Id, Cs))) || Id <- Ids],
      %% WHAT EACH ONE IS BUILT OF, as against what it is carrying, same order.
      %% Sending only the store would draw a fat creature and a large one exactly
      %% alike, and since world 6 those are the two ends of a real axis: frame
      %% wins contests and costs upkeep, store is cheap and useless in a fight.
      structures => [max(0, maps:get(structure, maps:get(Id, Cs))) || Id <- Ids],
      %% WHO IS RELATED TO WHOM, one signature per creature in the same order.
      %% The scent MARKS deliberately leave this out, because there are hundreds
      %% of them and a viewer has nothing to compare one against. Creatures are a
      %% different case on both counts: there are tens, and they can be compared
      %% against EACH OTHER, which is the only way to see whether a population is
      %% one family or several without reading a number off a table.
      signatures => [maps:get(scent, maps:get(Id, Cs)) || Id <- Ids],
      %% HOW FAST EACH ONE FEEDS, same order again. The axis world 4 is about,
      %% and unlike a signature it is a quantity with a meaning a viewer can put
      %% on a scale: below what the ground sustains is a creature that can hold
      %% its cell for good, above it one that strips the cell and must move.
      uptakes => [maps:get(uptake, maps:get(Id, Cs)) || Id <- Ids],
      %% The ground as position and amount, at a stride of three. Only cells
      %% holding something are sent: an empty cell is one a spectator draws bare,
      %% and on a grazed board most of them are.
      %% ==========================================================================
      %% WHAT KIND EACH CREATURE IS, AND WHAT THE KINDS ARE
      %% ==========================================================================
      %%
      %% ONE INDEX PER CREATURE AND THE ARCHITECTURES SENT ONCE. A hundred
      %% creatures share five to twenty-seven body plans, so sending a genome per
      %% head would send the same twenty structures a hundred times. The kind IS
      %% the shared structure; that is what makes it worth being a thing.
      %%
      %% `kind_of' runs parallel to `ids', `energies' and the rest, so a viewer
      %% colours by architecture the same way it sizes by structure. `kind_table'
      %% is one record per distinct kind, in the same index order.
      %%
      %% ⚠ FLAT INTEGERS AND LENGTH PREFIXES, no tuples and no nesting, because
      %% the wire rules in `world_facts' forbid both and a genome is the first
      %% thing here that is not a fixed-width record. A kind reads:
      %%
      %%     nsensors, field, range, field, range, ..., nhidden, npurposes, p, ...
      %%
      %% `field' and `p' are indexes into `body:fields/0' and `brain:purposes/0',
      %% which are fixed lists. **A test pins both orders**: reordering either
      %% would silently change the meaning of every kind table ever published,
      %% which is `I.6' with a wire between it and the reader.
      %% WHAT EACH CREATURE IS MADE OF, per creature, so a mark can show its
      %% traits and not only its size. Sensors and hidden nodes are the two
      %% things that define it and neither was ever drawable.
      senses => [length(maps:get(body, maps:get(Id, Cs))) || Id <- Ids],
      nodes => [brain:hidden_count(maps:get(brain, maps:get(Id, Cs)))
                || Id <- Ids],
      kind_of => kind_indexes(Cs, Ids),
      kind_table => kind_table(Cs),
      ground => flatten_ground(G),
      %% ⚠ WORLD 23 ADDED WATER TO THE PHYSICS AND NEVER TO THE WIRE, so for the
      %% whole of that world the island page could not draw the one thing the
      %% world was about. There was not even an accessor: the cells lived in this
      %% record and nothing outside could read them.
      %%
      %% Position only, no amount. A cell is wet or it is not, water is never
      %% consumed and never depleted, so an amount column would carry the same
      %% number in every entry.
      water => flatten_hexes(lists:sort(maps:keys(Water))),
      scent => flatten_scent(Scent),
      radius => maps:get(radius, Econ),
      tick => Tick}.

flatten_hexes(Hexes) -> lists:append([[Q, R] || {Q, R} <- Hexes]).

%% The distinct kinds present, in a fixed order, so an index means the same thing
%% in `kind_of' and in `kind_table'. Sorted rather than map order: `G.6'.
kinds_present(Cs) ->
    lists:usort([kind_of(C) || C <- maps:values(Cs)]).

kind_indexes(Cs, Ids) ->
    Present = kinds_present(Cs),
    [index_of(kind_of(maps:get(Id, Cs)), Present) || Id <- Ids].

index_of(Kind, Present) -> position(Kind, Present, 0).

position(Kind, [Kind | _Rest], N) -> N;
position(Kind, [_Other | Rest], N) -> position(Kind, Rest, N + 1);
position(_Kind, [], _N) -> -1.

kind_table(Cs) ->
    lists:append([encode_kind(K) || K <- kinds_present(Cs)]).

encode_kind({Body, Hidden, Purposes}) ->
    [length(Body)]
        ++ lists:append([[field_code(F), R] || {F, R} <- Body])
        ++ [Hidden, length(Purposes)]
        ++ [purpose_code(P) || P <- Purposes].

field_code(Field) -> position(Field, body:fields(), 0).

purpose_code(Purpose) -> position(Purpose, brain:purposes(), 0).

flatten_ground(G) ->
    lists:append([[Q, R, E] || {{Q, R}, E} <- lists:sort(maps:to_list(G)),
                               E > 0]).

flatten_scent(Scent) ->
    lists:append([[Q, R, S] || {{Q, R}, {S, _Tag}} <- lists:sort(maps:to_list(Scent))]).

%% The single number that says whether the books balance. Energy enters only by
%% eating a plant and leaves only by metabolism, rent and movement, so a run
%% whose total climbs without plants being eaten has a leak.
total_energy(#world{creatures = Cs}) ->
    lists:sum([E || #{energy := E} <- maps:values(Cs)]).

total_structure(#world{creatures = Cs}) ->
    lists:sum([S || #{structure := S} <- maps:values(Cs)]).

largest_structure(#world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
largest_structure(#world{creatures = Cs}) ->
    lists:max([max(0, S) || #{structure := S} <- maps:values(Cs)]).

-spec population(world()) -> non_neg_integer().
population(#world{creatures = Cs}) -> map_size(Cs).

-spec ground_energy(world()) -> non_neg_integer().
ground_energy(#world{ground = G}) -> ground:total(G).

-spec at_tick(world()) -> non_neg_integer().
at_tick(#world{tick = T}) -> T.

-spec alive(id(), world()) -> boolean().
alive(Id, #world{creatures = Cs}) -> maps:is_key(Id, Cs).

%%==============================================================================
%% Randomness, threaded explicitly
%%==============================================================================

random_cell(Radius, Rng0) ->
    {Q, Rng1} = rand:uniform_s(2 * Radius + 1, Rng0),
    {R, Rng2} = rand:uniform_s(2 * Radius + 1, Rng1),
    H = {Q - Radius - 1, R - Radius - 1},
    retry(hex:in_disc(H, Radius), H, Radius, Rng2).

%% Rejection sampling: a bounding box on a hex disc is about three quarters disc,
%% so this retries rarely and is uniform, which sampling the box and clamping
%% would not be. Clamping piles every out-of-range draw onto the rim.
retry(true, H, _Radius, Rng) -> {H, Rng};
retry(false, _H, Radius, Rng) -> random_cell(Radius, Rng).

pick([], Rng) -> {{0, 0}, Rng};
pick(Options, Rng0) ->
    {N, Rng1} = rand:uniform_s(length(Options), Rng0),
    {lists:nth(N, Options), Rng1}.
