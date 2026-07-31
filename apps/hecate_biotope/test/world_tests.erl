%% @doc The energy economy, asserted rather than eyeballed.
%%
%% The point of these is not that the world "works". It is that energy goes
%% exactly where the four numbers say it goes, because every later question
%% (does a population persist, does an organ pay for itself, do roles appear)
%% is asked in units of energy and is meaningless if the books do not balance.
-module(world_tests).

-include_lib("eunit/include/eunit.hrl").

%% A world with no plants at all: none sown at creation and none regrowing, so
%% nothing enters and every change in the energy total is attributable.
%%
%% `initial_plants => 0' IS LOAD BEARING. Without it these were not barren, and
%% six of them measured a creature eating while claiming to measure metabolism.
%% They passed nothing; they failed loudly, which is the only reason it was
%% caught at all.
%% `organ_upkeep => 0' IS LOAD BEARING FOR THE SAME REASON. These measure the
%% BASE economy, and a founding body is drawn at random, so leaving upkeep on
%% would add somewhere between zero and three per tick depending on the seed. The
%% four tests that broke when organs arrived all broke exactly this way, off by
%% the number of organs the seed happened to deal. Upkeep gets its own tests
%% below rather than contaminating these.
barren(Opts) ->
    world:new(maps:merge(#{initial_plants => 0,
                           regrowth_per_tick => 0,
                           organ_upkeep => 0,
                           population => 1,
                           radius => 3,
                           seed => 7}, Opts)).

%% A brain that always grazes, whatever it perceives: every weight zero except
%% the grazing bias, so grazing outscores hunting and resting unconditionally.
%% Paired with an empty body it makes a creature whose behaviour is known, which
%% is what a test of MOVEMENT needs. Without it a resting creature would look
%% exactly like a broken move_cost.
always_graze() ->
    [0, 0, 0, 0, 1,
     0, 0, 0, 0, 0,
     0, 0, 0, 0, 0].

%%==============================================================================
%% Making one
%%==============================================================================

starts_with_the_population_it_was_asked_for_test() ->
    W = world:new(#{population => 12, radius => 5}),
    ?assertEqual(12, world:population(W)),
    ?assertEqual(0, world:at_tick(W)).

%% Same parameters, same world. Nothing here reads a clock or the process
%% dictionary, so a run is a function of its arguments and a failing run can be
%% reproduced from the numbers in its own snapshot.
same_seed_same_world_test() ->
    A = world:tick(world:new(#{seed => 99, population => 20}), 50),
    B = world:tick(world:new(#{seed => 99, population => 20}), 50),
    ?assertEqual(world:snapshot(A), world:snapshot(B)).

different_seed_different_world_test() ->
    A = world:tick(world:new(#{seed => 1, population => 20}), 50),
    B = world:tick(world:new(#{seed => 2, population => 20}), 50),
    ?assertNotEqual(world:snapshot(A), world:snapshot(B)).

%%==============================================================================
%% What it costs to exist and to act
%%==============================================================================

%% The creature is pinned to grazing so that it certainly moves. A resting
%% creature pays no move_cost, correctly, and would make this look like a leak.
existing_and_moving_both_cost_test() ->
    W0 = barren(#{metabolism => 3, move_cost => 2, start_energy => 100,
                  founder_body => [], founder_brain => always_graze()}),
    #{energy_total := Before} = world:snapshot(W0),
    #{energy_total := After} = world:snapshot(world:tick(W0)),
    ?assertEqual(100, Before),
    ?assertEqual(100 - 3 - 2, After).

%% The standing cost is charged whether or not the creature does anything.
metabolism_is_charged_every_tick_test() ->
    W = barren(#{metabolism => 5, move_cost => 0, start_energy => 100}),
    #{energy_total := After} = world:snapshot(world:tick(W, 10)),
    ?assertEqual(100 - 50, After).

%% THE NUMBER THAT MAKES DIFFERENTIATION POSSIBLE AT ALL. If a sense were free
%% every lineage would keep every organ, every creature would be a fully equipped
%% omnivore, and no dietary role could ever appear however long it ran. Charged
%% per organ, every tick, used or not.
an_organ_costs_its_upkeep_every_tick_test() ->
    Bare = barren(#{metabolism => 1, organ_upkeep => 4, move_cost => 0,
                    start_energy => 100, founder_body => [],
                    founder_brain => always_graze()}),
    Eyed = barren(#{metabolism => 1, organ_upkeep => 4, move_cost => 0,
                    start_energy => 100, founder_body => [eye],
                    founder_brain => always_graze()}),
    #{energy_total := WithoutEye} = world:snapshot(world:tick(Bare, 10)),
    #{energy_total := WithEye} = world:snapshot(world:tick(Eyed, 10)),
    ?assertEqual(100 - 10, WithoutEye),
    ?assertEqual(100 - 10 - 40, WithEye).

%% Two organs cost twice one, so a generalist is strictly poorer than either
%% specialist and has to earn the difference back.
upkeep_scales_with_the_number_of_organs_test() ->
    Cost = fun(Body) ->
                   W = barren(#{metabolism => 0, organ_upkeep => 3,
                                move_cost => 0, start_energy => 100,
                                founder_body => Body,
                                founder_brain => always_graze()}),
                   #{energy_total := E} = world:snapshot(world:tick(W, 10)),
                   100 - E
           end,
    ?assertEqual(0, Cost([])),
    ?assertEqual(30, Cost([eye])),
    ?assertEqual(60, Cost([eye, nose])),
    ?assertEqual(90, Cost([eye, gut, nose])).

%%==============================================================================
%% Where energy enters
%%==============================================================================

%% A world paved with plants: the creature cannot help but eat, so the gain is
%% attributable to eating and to nothing else.
eating_adds_exactly_one_plant_test() ->
    Paved = world:new(#{population => 1, radius => 1, regrowth_per_tick => 0,
                        plant_energy => 40, metabolism => 0, move_cost => 0,
                        organ_upkeep => 0, start_energy => 10,
                        breed_at => 100000, seed => 3}),
    #{energy_total := E0, plants := P0} = world:snapshot(Paved),
    #{energy_total := E1, plants := P1, eaten := Ate} =
        world:snapshot(world:tick(Paved)),
    ?assertEqual(Ate * 40, E1 - E0),
    ?assertEqual(Ate, P0 - P1).

%% Nothing enters a barren world, so the total can only fall.
a_barren_world_only_loses_energy_test() ->
    W = barren(#{population => 5, start_energy => 60}),
    Totals = [begin
                  #{energy_total := E} = world:snapshot(world:tick(W, N)),
                  E
              end || N <- lists:seq(0, 10)],
    ?assertEqual(lists:reverse(lists:sort(Totals)), Totals).

%%==============================================================================
%% Death, by cause
%%==============================================================================

starvation_is_counted_as_starvation_test() ->
    W = barren(#{start_energy => 4, metabolism => 1, move_cost => 1}),
    #{population := Pop, starved := S, aged_out := O} =
        world:snapshot(world:tick(W, 5)),
    ?assertEqual(0, Pop),
    ?assertEqual(1, S),
    ?assertEqual(0, O).

%% Old age and starvation are different findings. A single death count cannot
%% tell "the population crashed" from "the population grew old", so they are
%% never summed.
%% "Rich enough to ignore starvation, too poor to breed" now has to be expressed
%% by starting BELOW the breed floor, not by naming an enormous breed_at: the
%% threshold is a per-creature trait and is clamped to a sane range, so a founder
%% asking for 100000 is simply given the ceiling and breeds immediately. The
%% earlier version of this test set start_energy and breed_at equal, which was a
%% contradiction for a different reason and was fixed once already.
old_age_is_counted_as_old_age_test() ->
    W = barren(#{start_energy => 30, breed_floor => 40, metabolism => 0,
                 move_cost => 0, max_age => 3}),
    #{population := Pop, starved := S, aged_out := O} =
        world:snapshot(world:tick(W, 6)),
    ?assertEqual(0, Pop),
    ?assertEqual(0, S),
    ?assertEqual(1, O).

%%==============================================================================
%% What a surplus buys
%%==============================================================================

%% Birth conserves energy: the parent pays exactly what the child receives, so
%% the only sink in the whole world is metabolism plus movement. That is what
%% makes a drifting energy total a bug rather than a mystery.
breeding_conserves_energy_test() ->
    W0 = barren(#{start_energy => 200, breed_at => 150,
                  metabolism => 0, move_cost => 0, max_age => 100000}),
    #{energy_total := Before, population := P0} = world:snapshot(W0),
    #{energy_total := After, population := P1} = world:snapshot(world:tick(W0)),
    ?assertEqual(Before, After),
    ?assertEqual(P0 + 1, P1).

a_creature_below_the_threshold_does_not_breed_test() ->
    W = barren(#{start_energy => 100, breed_at => 150, metabolism => 0,
                 move_cost => 0}),
    #{population := P} = world:snapshot(world:tick(W)),
    ?assertEqual(1, P).

%% The cap is a safety valve against a mistuned run, not a model parameter, so
%% hitting it must be visible rather than looking like a stable ceiling.
refused_births_are_counted_test() ->
    W = world:new(#{population => 4, max_creatures => 4, start_energy => 500,
                    breed_at => 100, breed_cost => 50, metabolism => 0,
                    move_cost => 0, max_age => 100000, radius => 3, seed => 5}),
    #{population := P, births_refused := R} = world:snapshot(world:tick(W)),
    ?assertEqual(4, P),
    ?assert(R > 0).

%%==============================================================================
%% The second trophic level
%%==============================================================================

%% A crowd on a single cell: radius 0 is one hex, so everyone is always in reach
%% of everyone else and a hunt cannot miss for want of a neighbour.
%%
%% BREEDING IS PUT OUT OF REACH rather than merely made unlikely. A successful
%% hunter ends the tick carrying its victim's energy as well as its own, which is
%% exactly the surplus that buys a child, so a population count would otherwise
%% mix kills and births and say nothing about either. The threshold is a
%% per-creature trait clamped to the ceiling, so raising it means raising both.
crowd(N, Opts) ->
    barren(maps:merge(#{population => N, radius => 0, start_energy => 100,
                        metabolism => 0, move_cost => 0,
                        breed_at => 1000000, breed_ceiling => 1000000,
                        max_age => 100000, founder_brain => only(hunt)}, Opts)).

only(hunt) -> [0,0,0,0,0,  0,0,0,0,1,  0,0,0,0,0];
only(rest) -> [0,0,0,0,0,  0,0,0,0,0,  0,0,0,0,1].

%% ENERGY CHANGES HANDS, IT IS NOT CREATED. The victim's whole balance moves to
%% the attacker and the only loss is the strike, so the books stay as readable as
%% they were when plants were the sole source. A predation that minted energy
%% would make every later population figure meaningless.
a_creature_can_eat_a_creature_test() ->
    W = crowd(2, #{attack_cost => 30, founder_body => []}),
    #{energy_total := Before, population := P0} = world:snapshot(W),
    #{energy_total := After, population := P1, killed := K, starved := S} =
        world:snapshot(world:tick(W)),
    ?assertEqual(200, Before),
    ?assertEqual(2, P0),
    ?assertEqual(1, P1),
    ?assertEqual(1, K),
    ?assertEqual(0, S),
    ?assertEqual(Before - 30, After).

%% Predation, starvation and old age are three different findings. A single death
%% count could not tell "they ate each other" from "the plants ran out".
predation_is_counted_apart_from_the_other_deaths_test() ->
    W = crowd(2, #{attack_cost => 0, founder_body => []}),
    #{killed := K, starved := S, aged_out := O} = world:snapshot(world:tick(W)),
    ?assertEqual(1, K),
    ?assertEqual(0, S),
    ?assertEqual(0, O).

%% A WASTED TURN IS THE PRICE OF A BAD DECISION, and selection needs to be able
%% to see it. A creature that decides to hunt with nothing in reach lunges at
%% air: it pays for the step and gains nothing.
a_hunter_with_no_prey_wastes_its_turn_test() ->
    W = crowd(1, #{attack_cost => 30, move_cost => 7, radius => 3,
                   founder_body => []}),
    #{energy_total := After, killed := K} = world:snapshot(world:tick(W)),
    ?assertEqual(100 - 7, After),
    ?assertEqual(0, K).

%% RESTING IS THE ONLY FREE INTENT, and that is what makes waiting out a bad
%% patch possible. Without it the cheapest strategy in a barren world does not
%% exist and every brain is forced to burn energy having opinions.
resting_pays_only_metabolism_test() ->
    W = crowd(1, #{metabolism => 2, move_cost => 100, radius => 3,
                   founder_body => [], founder_brain => only(rest)}),
    #{energy_total := After} = world:snapshot(world:tick(W, 5)),
    ?assertEqual(100 - 10, After).

%% WHAT THE EYE IS FOR WHEN HUNTING. A hunter that can see takes the fattest
%% neighbour, which in a crowd means taking whoever has just eaten and
%% compounding it; a blind one takes whoever is to hand.
%%
%% Both worlds run from the same seed and shuffle identically, so the difference
%% in how much of the crowd is left after one tick is the targeting and nothing
%% else.
the_eye_picks_the_fattest_prey_test() ->
    Blind = crowd(4, #{attack_cost => 0, founder_body => []}),
    Sighted = crowd(4, #{attack_cost => 0, founder_body => [eye],
                         organ_upkeep => 0}),
    #{population := PBlind} = world:snapshot(world:tick(Blind)),
    #{population := PSighted} = world:snapshot(world:tick(Sighted)),
    ?assert(PSighted < PBlind).

%%==============================================================================
%% Trails
%%==============================================================================

%% A MOVING CREATURE MARKS THE GROUND AND A STILL ONE DOES NOT, and that
%% asymmetry is load bearing rather than flavour. It makes resting a way to HIDE
%% as well as a way to save energy, which hands prey a counter-move against being
%% tracked. An arms race needs both sides to have one.
moving_leaves_a_trail_and_resting_does_not_test() ->
    Walker = crowd(1, #{radius => 3, founder_body => [],
                        founder_brain => only(hunt)}),
    Sitter = crowd(1, #{radius => 3, founder_body => [],
                        founder_brain => only(rest)}),
    #{scent_cells := Walked} = world:snapshot(world:tick(Walker, 5)),
    #{scent_cells := Sat} = world:snapshot(world:tick(Sitter, 5)),
    ?assert(Walked > 0),
    ?assertEqual(0, Sat).

%% A TRAIL THAT NEVER FADED WOULD BE A ROAD, and a board where every cell smells
%% equally carries exactly as much information as one where none does. The mark
%% is dropped rather than kept at zero, so the map holds only what still smells.
a_trail_fades_to_nothing_test() ->
    W = crowd(1, #{radius => 3, scent_per_tick => 10, scent_decay => 2,
                   scent_ceiling => 10, founder_body => [],
                   founder_brain => only(hunt)}),
    #{scent_cells := Fresh} = world:snapshot(world:tick(W, 1)),
    ?assertEqual(1, Fresh),
    %% Ten laid down, two lost per tick: gone on the fifth fade, and the
    %% creature must be gone too or it would keep laying more.
    Dead = world:tick(crowd(1, #{radius => 3, start_energy => 1,
                                 metabolism => 1, scent_ceiling => 10,
                                 scent_decay => 2, founder_body => [],
                                 founder_brain => only(hunt)}), 10),
    #{population := Pop, scent_cells := Stale} = world:snapshot(Dead),
    ?assertEqual(0, Pop),
    ?assertEqual(0, Stale).

%% THE ONLY WAY IN THIS WORLD TO ACT ON SOMETHING THAT CANNOT BE PERCEIVED. A
%% hunter with nothing in reach either wanders, which is what the population did
%% before any of this existed, or follows the strongest trail out of its cell.
%% That difference is the entire case for the organ, so it is asserted on the
%% observable that matters: whether the hunting actually lands.
a_nose_finds_prey_that_wandering_does_not_test() ->
    Hunt = fun(Body) ->
                   W = world:new(#{population => 30, radius => 10, seed => 12,
                                   initial_plants => 40, regrowth_per_tick => 4,
                                   organ_upkeep => 0, max_age => 100000,
                                   breed_at => 1000000, breed_ceiling => 1000000,
                                   founder_body => Body,
                                   founder_brain => only(hunt)}),
                   #{killed := K} = world:snapshot(world:tick(W, 60)),
                   K
           end,
    ?assert(Hunt([nose]) > Hunt([])).

%%==============================================================================
%% What the population turned out to be
%%==============================================================================

%% DIET IS OBSERVED, NEVER DECLARED. There is no herbivore field and no carnivore
%% flag; a creature is whatever its meals say it is. A world that labelled its
%% creatures could not discover that the labels were wrong.
%% MUTATION IS TURNED OFF, and finding out why took a failing run. With it on,
%% a founding population of pure grazers had invented hunting and eaten its own
%% best-fed members inside forty ticks. That is the machinery working exactly as
%% intended and it is the whole point of the increment, but it means "a world of
%% grazers" is not something the default rules will hold still for. Here the
%% lineage is frozen so the CLASSIFIER is what is under test.
a_creature_that_only_grazes_is_counted_a_herbivore_test() ->
    W = world:new(#{population => 6, radius => 2, initial_plants => 18,
                    regrowth_per_tick => 6, metabolism => 0, move_cost => 0,
                    organ_upkeep => 0, breed_at => 400, max_age => 100000,
                    start_energy => 50, seed => 5,
                    brain_mutation => 0, body_mutation => 1000000,
                    founder_body => [eye], founder_brain => always_graze()}),
    #{diet := Diet} = world:snapshot(world:tick(W, 40)),
    ?assert(maps:get(herbivores, Diet) > 0),
    ?assertEqual(0, maps:get(carnivores, Diet)),
    ?assertEqual(0, maps:get(omnivores, Diet)).

%% THE UNDECIDED BUCKET IS LOAD BEARING. A newborn has eaten nothing, and calling
%% it a herbivore on the strength of zero meals would fill a fast-breeding world
%% with imaginary vegetarians and hide what the adults are actually doing.
a_creature_that_has_not_eaten_yet_has_no_diet_test() ->
    #{diet := Diet, population := Pop} =
        world:snapshot(world:new(#{population => 5, seed => 8})),
    ?assertEqual(Pop, maps:get(undecided, Diet)),
    ?assertEqual(0, maps:get(herbivores, Diet)),
    ?assertEqual(0, maps:get(carnivores, Diet)).

%% Every living creature falls in exactly one bucket, so the four numbers are a
%% partition of the population rather than four overlapping counts.
the_diet_buckets_partition_the_population_test() ->
    #{diet := Diet, population := Pop} =
        world:snapshot(world:tick(world:new(#{population => 30, seed => 3}), 300)),
    ?assertEqual(Pop, lists:sum(maps:values(Diet))).

%% An organ whose prevalence falls costs more than it earns in this world, which
%% is a finding about the world rather than about the organ. Reported for the
%% LIVING population, so it tracks what survived rather than what was born.
organ_prevalence_is_reported_test() ->
    #{organs := Organs, population := Pop} =
        world:snapshot(world:new(#{population => 20, seed => 4})),
    ?assertEqual(lists:sort(body:organs()), lists:sort(maps:keys(Organs))),
    ?assert(lists:all(fun(N) -> N =< Pop end, maps:values(Organs))).

%%==============================================================================
%% Does anything live
%%==============================================================================

%% THE QUESTION THE WHOLE INCREMENT EXISTS TO ASK. A random walker has no
%% perception, so this is the floor: whatever the defaults give away for free.
%% If a population of coins cannot last 500 ticks the economy is too mean for any
%% brain to be worth evolving, and if it never falls it is too generous to select
%% anything. The bound is deliberately loose; it is a smoke alarm, not a finding.
the_default_economy_sustains_a_population_test() ->
    W = world:tick(world:new(#{population => 40, seed => 11}), 500),
    #{population := Pop, starved := S, births_refused := R} = world:snapshot(W),
    ?assert(Pop > 0),
    ?assert(S > 0),
    ?assertEqual(0, R).

%%==============================================================================
%% Which rules this world runs under
%%==============================================================================

%% TWO ISLANDS RUNNING DIFFERENT ECONOMIES ARE NOT COMPARABLE, and without this
%% nothing on the wire would say so. Differentiated local pressure is the point
%% of having more than one island, so they will deliberately differ, and a
%% spectator plotting two populations together would be comparing two games.
identical_economies_share_a_fingerprint_test() ->
    A = world:new(#{seed => 1, radius => 9}),
    B = world:new(#{seed => 2, radius => 9}),
    #{econ_id := IdA} = world:snapshot(A),
    #{econ_id := IdB} = world:snapshot(B),
    %% Different seeds are different WORLDS but the same RULES, and it is the
    %% rules that decide comparability.
    ?assertEqual(IdA, IdB).

one_changed_number_changes_the_fingerprint_test() ->
    #{econ_id := Default} = world:snapshot(world:new(#{})),
    #{econ_id := Leaner} = world:snapshot(world:new(#{metabolism => 2})),
    ?assertNotEqual(Default, Leaner).

%% Map iteration order is not a promise, so the canonical form sorts. Built by
%% hand rather than with term_to_binary, whose bytes are only stable within an
%% OTP release: two honest islands on different releases would otherwise compute
%% different ids for identical rules.
fingerprint_is_short_lowercase_hex_test() ->
    #{econ_id := Id} = world:snapshot(world:new(#{})),
    ?assertEqual(16, byte_size(Id)),
    ?assertMatch({match, _}, re:run(Id, "^[0-9a-f]{16}$")).

%% The values travel too, because a fingerprint answers "same or different" and
%% a reader also wants "how". Ten small integers a second is not a cost.
the_economy_itself_travels_with_the_fingerprint_test() ->
    #{econ := Econ} = world:snapshot(world:new(#{metabolism => 2})),
    ?assertEqual(2, maps:get(metabolism, Econ)),
    ?assertEqual(maps:keys(world:defaults()), maps:keys(Econ)).

%%==============================================================================
%% Extinction
%%==============================================================================

%% EXTINCTION IS PERMANENT AND THAT IS A PROPERTY OF THE RULES. Nothing external
%% reseeds a world, and a population of zero has no way to produce a birth. So a
%% dead island goes on publishing forever: its plants regrow, its tick advances,
%% and every fact after the last death is identical to the one before.
%%
%% Population zero says the world is empty NOW. The tick it emptied is the part
%% no later sample carries, and it is the only thing worth recording.
a_world_that_dies_records_when_test() ->
    W = barren(#{population => 3, start_energy => 4, metabolism => 1,
                 move_cost => 1}),
    #{extinct_at := Before} = world:snapshot(W),
    ?assertEqual(undefined, Before),
    #{population := Pop, extinct_at := At} = world:snapshot(world:tick(W, 10)),
    ?assertEqual(0, Pop),
    ?assert(is_integer(At)).

%% Recorded once, on the transition, and never revised. Restamping every tick
%% would turn the one interesting number into the current one.
the_tick_of_death_is_not_revised_test() ->
    W = world:tick(barren(#{population => 2, start_energy => 4, metabolism => 1,
                            move_cost => 1}), 10),
    #{extinct_at := At} = world:snapshot(W),
    #{extinct_at := Later} = world:snapshot(world:tick(W, 500)),
    ?assertEqual(At, Later).

%% A LIVING WORLD CARRIES NO EXTINCTION AT ALL, not a sentinel. A tick of -1 or 0
%% for a living world is the kind of number that gets plotted by accident.
a_living_world_publishes_no_extinction_test() ->
    Fact = world_facts:world_advanced(world:snapshot(world:new(#{})),
                                      world_pace:from_map(#{})),
    ?assertNot(maps:is_key(extinct_at, Fact)).

a_dead_world_publishes_the_tick_it_died_test() ->
    Dead = world:tick(barren(#{population => 1, start_energy => 4,
                               metabolism => 1, move_cost => 1}), 10),
    Fact = world_facts:world_advanced(world:snapshot(Dead),
                                      world_pace:from_map(#{})),
    ?assert(maps:is_key(extinct_at, Fact)),
    ?assertEqual(0, maps:get(population, Fact)).

%% The plants keep growing with nothing to eat them, which is the honest record
%% of what an empty world does and is quietly the most interesting line on the
%% chart after a collapse.
plants_recover_after_everything_dies_test() ->
    W = world:tick(world:new(#{population => 1, start_energy => 4,
                               metabolism => 1, move_cost => 1,
                               initial_plants => 0, regrowth_per_tick => 4,
                               radius => 5, seed => 3}), 10),
    #{population := 0, plants := Early} = world:snapshot(W),
    #{plants := Later} = world:snapshot(world:tick(W, 50)),
    ?assert(Later > Early).
