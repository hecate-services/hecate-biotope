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
barren(Opts) ->
    world:new(maps:merge(#{initial_plants => 0,
                           regrowth_per_tick => 0,
                           population => 1,
                           radius => 3,
                           seed => 7}, Opts)).

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

existing_and_moving_both_cost_test() ->
    W0 = barren(#{metabolism => 3, move_cost => 2, start_energy => 100}),
    #{energy_total := Before} = world:snapshot(W0),
    #{energy_total := After} = world:snapshot(world:tick(W0)),
    ?assertEqual(100, Before),
    ?assertEqual(100 - 3 - 2, After).

%% The standing cost is charged whether or not the creature does anything, which
%% is the property that later makes an unused organ expensive.
metabolism_is_charged_every_tick_test() ->
    W = barren(#{metabolism => 5, move_cost => 0, start_energy => 100}),
    #{energy_total := After} = world:snapshot(world:tick(W, 10)),
    ?assertEqual(100 - 50, After).

%%==============================================================================
%% Where energy enters
%%==============================================================================

%% A world paved with plants: the creature cannot help but eat, so the gain is
%% attributable to eating and to nothing else.
eating_adds_exactly_one_plant_test() ->
    Paved = world:new(#{population => 1, radius => 1, regrowth_per_tick => 0,
                        plant_energy => 40, metabolism => 0, move_cost => 0,
                        start_energy => 10, breed_at => 100000, seed => 3}),
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
%% start_energy is comfortably BELOW breed_at, and that gap is the test. The
%% first version set them equal to mean "rich enough to ignore starvation, too
%% poor to breed", which is a contradiction: the creature bred on tick one and
%% two of them died of old age.
old_age_is_counted_as_old_age_test() ->
    W = barren(#{start_energy => 1000, metabolism => 0, move_cost => 0,
                 max_age => 3, breed_at => 100000}),
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
    W0 = barren(#{start_energy => 200, breed_at => 150, breed_cost => 75,
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
