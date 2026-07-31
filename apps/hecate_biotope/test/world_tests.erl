%% @doc The physics of world 2, asserted rather than eyeballed.
%%
%% NOTHING HERE ASSERTS A BIOLOGICAL OUTCOME. There is no test that plants
%% appear, that predators appear, or that a sensor survives, and there must never
%% be one: those are the things the world exists to answer, and a test demanding
%% them would turn a failed prediction into a broken build and quietly pressure
%% the rules until it passed. What is asserted is that the rules are the rules.
%% See PREREGISTRATION.md.
-module(world_tests).

-include_lib("eunit/include/eunit.hrl").

%% A creature that perceives nothing, moves nowhere and never breeds: no sensors,
%% so one input, `here', and no outputs at all. The stillest, cheapest thing the
%% rules allow, which makes every energy sum attributable.
inert() ->
    #{founder_body => [], founder_brain => #{hidden => [], outputs => #{}}}.

%% As above but it will move: a `move' output that prefers anywhere to here.
restless() ->
    #{founder_body => [],
      founder_brain => #{hidden => [],
                         outputs => #{move => #{inputs => [-1], hidden => []}}}}.

%% As above but it will breed on the first tick it can.
fertile() ->
    #{founder_body => [],
      founder_brain => #{hidden => [],
                         outputs => #{breed => #{inputs => [1], hidden => []}}}}.

quiet(Opts) ->
    world:new(maps:merge(#{population => 1, radius => 3, seed => 7}, Opts)).

%% Everything in the world is either in the ground or in a creature.
books(W) ->
    #{energy_total := Creatures, ground_total := Ground} = world:snapshot(W),
    Creatures + Ground.

%%==============================================================================
%% The books
%%==============================================================================

%% THE INVARIANT WORLD 1 COULD NEVER CHECK, because it destroyed the energy of
%% anything that died of old age. It could assert only that the total FELL, never
%% that it fell by exactly what was spent, so any other leak would have hidden
%% behind the one it had built in.
a_still_world_conserves_energy_exactly_test() ->
    W = quiet(maps:merge(#{influx => 0, metabolism => 0, sensor_rent => 0,
                           hidden_rent => 0, max_age => 100000}, inert())),
    Totals = [books(world:tick(W, N)) || N <- lists:seq(0, 20)],
    ?assertEqual(1, length(lists:usort(Totals))).

%% The only sink is the work of staying alive.
existing_is_the_only_leak_test() ->
    W = quiet(maps:merge(#{influx => 0, metabolism => 7, sensor_rent => 0,
                           hidden_rent => 0, max_age => 100000}, inert())),
    ?assertEqual(books(W) - 70, books(world:tick(W, 10))).

moving_costs_over_and_above_existing_test() ->
    Opts = #{influx => 0, metabolism => 3, move_cost => 5, sensor_rent => 0,
             hidden_rent => 0, max_age => 100000},
    Still = quiet(maps:merge(Opts, inert())),
    Moving = quiet(maps:merge(Opts, restless())),
    ?assertEqual(books(Still) - 30, books(world:tick(Still, 10))),
    ?assertEqual(books(Moving) - 80, books(world:tick(Moving, 10))).

%% DEATH RETURNS ENERGY TO THE GROUND IT DIED ON. World 1 deleted it, and a
%% well-fed creature could be carrying hundreds.
dying_of_old_age_returns_its_energy_to_the_ground_test() ->
    W = quiet(maps:merge(#{influx => 0, metabolism => 0, sensor_rent => 0,
                           hidden_rent => 0, max_age => 3,
                           start_energy => 500}, inert())),
    Before = books(W),
    After = world:tick(W, 6),
    #{population := Pop, aged_out := Aged, energy_total := InCreatures} =
        world:snapshot(After),
    ?assertEqual(0, Pop),
    ?assertEqual(1, Aged),
    ?assertEqual(0, InCreatures),
    ?assertEqual(Before, books(After)).

%% Ambient supply stops at the ceiling rather than accumulating without bound.
%% Asserted with nobody there to graze it: with a creature present the WORLD
%% total keeps rising, correctly, because the ceiling caps a CELL and influx goes
%% on arriving. An earlier version of this asserted the world total and was
%% simply wrong about what the ceiling means.
the_ground_fills_to_its_ceiling_and_no_further_test() ->
    W = world:new(#{radius => 1, population => 0, influx => 100,
                    ground_ceiling => 250, seed => 7}),
    #{ground_total := Early} = world:snapshot(world:tick(W, 50)),
    #{ground_total := Late} = world:snapshot(world:tick(W, 200)),
    ?assertEqual(hex:cells(1) * 250, Early),
    ?assertEqual(Early, Late).

%%==============================================================================
%% Absorbing, contesting, and one rule for both
%%==============================================================================

absorbing_takes_the_whole_cell_test() ->
    W = quiet(maps:merge(#{influx => 0, ground_ceiling => 300, metabolism => 0,
                           sensor_rent => 0, hidden_rent => 0,
                           max_age => 100000, start_energy => 100}, inert())),
    #{energy_total := E1, ground_total := G1} = world:snapshot(world:tick(W)),
    ?assertEqual(400, E1),
    ?assertEqual((hex:cells(3) - 1) * 300, G1).

%% AND THE SAME RULE TAKES A CREATURE. Something holding more takes something
%% holding less, exactly as it takes what is in the ground, and there is no
%% separate path for either. World 1 had two functions with two names, which is
%% precisely why its claim to have deleted the herbivore split was false.
%%
%% Radius 0 is one cell and a child is placed on a neighbour, of which there are
%% none, so parent and child stand together. The dowry is half, so the child is
%% always the poorer.
the_stronger_takes_the_weaker_test() ->
    W = family(201),
    ?assertEqual({1, 0, 201}, look(W, 0)),
    %% A child is born and the parent paid exactly what it received.
    ?assertEqual({2, 0, 201}, look(W, 1)),
    %% They share a cell. An odd split leaves the parent one unit richer, so it
    %% takes the child back and immediately has the surplus to breed again.
    ?assertEqual({2, 1, 201}, look(W, 2)).

%% AND A PARENT CANNOT EAT AN EVENLY SPLIT CHILD, which falls out of the new
%% rule rather than being written anywhere. The dowry is half, so for an even
%% energy the two come out exactly equal, and equals do not consume each other.
%% World 1 could not express this: its dowry was half a THRESHOLD rather than
%% half of what the parent was carrying, so a parent was almost always richer
%% than its newborn.
an_evenly_split_parent_and_child_are_equals_test() ->
    W = family(200),
    ?assertEqual({2, 0, 200}, look(W, 1)),
    ?assertEqual({4, 0, 200}, look(W, 2)).

%% MUTATION OFF, and finding out why cost a debugging round. With it on, the
%% child's breed weight is nudged from 1 to 0 or 2, and a 0 means it declines to
%% reproduce, so the second generation is not the clone the arithmetic here
%% assumes. That is the machinery working; it just makes a rule impossible to
%% isolate, which is what these two want to do.
family(Energy) ->
    quiet(maps:merge(#{population => 1, radius => 0, influx => 0,
                       ground_ceiling => 0, metabolism => 0, sensor_rent => 0,
                       hidden_rent => 0, max_age => 100000,
                       brain_mutation => 0, brain_mutation_structural => 1000000,
                       body_mutation => 1000000,
                       start_energy => Energy}, fertile())).

look(W, N) ->
    Ticked = world:tick(W, N),
    S = world:snapshot(Ticked),
    {maps:get(population, S), maps:get(consumed, S), books(Ticked)}.

equals_do_not_consume_each_other_test() ->
    W = quiet(maps:merge(#{population => 2, radius => 0, influx => 0,
                           ground_ceiling => 0, metabolism => 0,
                           sensor_rent => 0, hidden_rent => 0,
                           max_age => 100000}, inert())),
    #{population := Pop, consumed := Eaten} = world:snapshot(world:tick(W, 5)),
    ?assertEqual(2, Pop),
    ?assertEqual(0, Eaten).

%%==============================================================================
%% What it costs to be equipped
%%==============================================================================

%% THE ONLY FORCE THAT CAN REMOVE A SENSOR. If measuring were free every lineage
%% would accumulate every measurement and the fully equipped generalist would
%% never be at a disadvantage.
a_sensor_costs_its_rent_every_tick_test() ->
    Cost = fun(Sensors) ->
                   W = quiet(#{influx => 0, metabolism => 0, sensor_rent => 2,
                               hidden_rent => 0, max_age => 100000,
                               start_energy => 900, founder_body => Sensors,
                               founder_brain => #{hidden => [],
                                                  outputs => #{}}}),
                   books(W) - books(world:tick(W, 10))
           end,
    ?assertEqual(0, Cost([])),
    %% Rent rises with reach: range 0 is one unit, range 2 is three.
    ?assertEqual(20, Cost([{ground, 0}])),
    ?assertEqual(60, Cost([{ground, 2}])),
    %% And is charged per sensor, so a generalist pays for each.
    ?assertEqual(40, Cost([{ground, 0}, {creatures, 0}])).

%% A BRAIN IS A THING THAT MUST BE RUN. Without rent on hidden nodes a lineage
%% accumulates capacity it never uses, exactly as it would accumulate senses.
a_hidden_node_costs_its_rent_every_tick_test() ->
    Cost = fun(Hidden) ->
                   W = quiet(#{influx => 0, metabolism => 0, sensor_rent => 0,
                               hidden_rent => 3, max_age => 100000,
                               start_energy => 900, founder_body => [],
                               founder_brain => #{hidden => Hidden,
                                                  outputs => #{}}}),
                   books(W) - books(world:tick(W, 10))
           end,
    ?assertEqual(0, Cost([])),
    ?assertEqual(30, Cost([[0]])),
    ?assertEqual(60, Cost([[0], [0]])).

%%==============================================================================
%% Deciding
%%==============================================================================

%% A creature with no `move' output never moves, and in this world that is a
%% living rather than a death sentence: it takes what gathers where it stands.
without_a_move_output_it_stays_put_test() ->
    W = quiet(maps:merge(#{influx => 5, metabolism => 0, sensor_rent => 0,
                           hidden_rent => 0, max_age => 100000}, inert())),
    #{still_pct := Still} = world:snapshot(world:tick(W, 5)),
    ?assertEqual(100, Still).

%% Staying still leaves no trail, which makes sitting tight a way to go unnoticed
%% as well as a way to save energy, and is the only counter to being tracked.
moving_leaves_a_trail_and_staying_does_not_test() ->
    Opts = #{influx => 5, metabolism => 0, sensor_rent => 0, hidden_rent => 0,
             max_age => 100000},
    #{scent_cells := Walked, still_pct := Moving} =
        world:snapshot(world:tick(quiet(maps:merge(Opts, restless())), 5)),
    #{scent_cells := Sat} =
        world:snapshot(world:tick(quiet(maps:merge(Opts, inert())), 5)),
    ?assert(Walked > 0),
    ?assertEqual(0, Moving),
    ?assertEqual(0, Sat).

%% A CHILD IS A DECISION NOW, not a threshold. `breed_at' and its three companion
%% constants are gone: deciding reproduction by a hand-written rule with a
%% heritable parameter was exactly the shape `hunt' had.
without_a_breed_output_it_leaves_no_descendants_test() ->
    W = quiet(maps:merge(#{influx => 100, metabolism => 0, sensor_rent => 0,
                           hidden_rent => 0, max_age => 100000}, inert())),
    #{population := Pop} = world:snapshot(world:tick(W, 50)),
    ?assertEqual(1, Pop).

%% Birth conserves energy, and costs half of whatever the parent happens to be
%% carrying rather than a fixed sum.
breeding_conserves_energy_and_costs_half_test() ->
    W = quiet(maps:merge(#{influx => 0, ground_ceiling => 0, metabolism => 0,
                           sensor_rent => 0, hidden_rent => 0,
                           max_age => 100000, start_energy => 400}, fertile())),
    #{population := Pop} = world:snapshot(world:tick(W)),
    ?assertEqual(2, Pop),
    ?assertEqual(books(W), books(world:tick(W))).

%%==============================================================================
%% Making one
%%==============================================================================

starts_with_the_population_it_was_asked_for_test() ->
    W = world:new(#{population => 12, radius => 5}),
    ?assertEqual(12, world:population(W)),
    ?assertEqual(0, world:at_tick(W)).

%% Same parameters, same world. Nothing reads a clock or the process dictionary.
same_seed_same_world_test() ->
    A = world:tick(world:new(#{seed => 99, population => 20, radius => 6}), 50),
    B = world:tick(world:new(#{seed => 99, population => 20, radius => 6}), 50),
    ?assertEqual(world:snapshot(A), world:snapshot(B)).

different_seed_different_world_test() ->
    A = world:tick(world:new(#{seed => 1, population => 20, radius => 6}), 50),
    B = world:tick(world:new(#{seed => 2, population => 20, radius => 6}), 50),
    ?assertNotEqual(world:snapshot(A), world:snapshot(B)).

%% A VIRGIN WORLD IS FULL, because nothing has drained it. The opening of a run
%% is colonisation of a standing larder rather than equilibrium, and that
%% transient must not be read as the answer.
a_new_world_is_full_and_flat_test() ->
    W = world:new(#{radius => 4, ground_ceiling => 250, population => 0}),
    #{ground_total := G, ground_spread := Spread} = world:snapshot(W),
    ?assertEqual(hex:cells(4) * 250, G),
    ?assert(Spread =< 11).

%%==============================================================================
%% Death, by cause
%%==============================================================================

starvation_is_counted_as_starvation_test() ->
    W = quiet(maps:merge(#{influx => 0, ground_ceiling => 0, metabolism => 30,
                           sensor_rent => 0, hidden_rent => 0,
                           start_energy => 60}, inert())),
    #{population := Pop, starved := S, aged_out := O, consumed := C} =
        world:snapshot(world:tick(W, 5)),
    ?assertEqual(0, Pop),
    ?assertEqual(1, S),
    ?assertEqual(0, O),
    ?assertEqual(0, C).

%% Three causes, never summed. "The population crashed" and "the population grew
%% old" are different findings and one total cannot tell them apart.
old_age_is_counted_as_old_age_test() ->
    W = quiet(maps:merge(#{influx => 0, ground_ceiling => 0, metabolism => 0,
                           sensor_rent => 0, hidden_rent => 0,
                           max_age => 3}, inert())),
    #{population := Pop, starved := S, aged_out := O} =
        world:snapshot(world:tick(W, 6)),
    ?assertEqual(0, Pop),
    ?assertEqual(0, S),
    ?assertEqual(1, O).

%% EXTINCTION IS PERMANENT AND THAT IS A PROPERTY OF THE RULES: nothing reseeds a
%% world and a population of zero cannot produce a birth. A dead island keeps
%% publishing, its ground refilling and its tick advancing, so the moment it
%% emptied is the one thing no later sample carries.
a_world_that_dies_records_when_and_does_not_revise_it_test() ->
    W = quiet(maps:merge(#{population => 3, influx => 0, ground_ceiling => 0,
                           metabolism => 30, sensor_rent => 0,
                           hidden_rent => 0, start_energy => 60}, inert())),
    ?assertEqual(undefined, maps:get(extinct_at, world:snapshot(W))),
    #{population := Pop, extinct_at := At} = world:snapshot(world:tick(W, 10)),
    ?assertEqual(0, Pop),
    ?assert(is_integer(At)),
    #{extinct_at := Later} = world:snapshot(world:tick(W, 60)),
    ?assertEqual(At, Later).

%%==============================================================================
%% Structure, and the one bug that does not crash
%%==============================================================================

%% A brain carries one weight per input in EVERY hidden node and EVERY output, so
%% a body that gains or loses a sensor leaves several vectors a column out of step
%% at once. Nothing crashes when that goes wrong: every weight past the change
%% point simply reads a different measurement, and the creature behaves like a
%% garbled version of its parent for reasons no test would name.
%%
%% Reaching the end of a long run with heavy structural churn means no creature
%% ever evaluated a cell with a mismatched vector, which would have crashed
%% lists:zip. That is what this asserts, and it is why it runs so long.
bodies_and_brains_stay_in_step_through_churn_test() ->
    W = world:tick(world:new(#{population => 30, radius => 6, seed => 17,
                               body_mutation => 1,
                               brain_mutation_structural => 1}), 400),
    #{population := Pop, hidden_mean := Hidden} = world:snapshot(W),
    ?assert(Pop >= 0),
    ?assert(Hidden >= 0).

%% The cap is a safety valve against a mistuned run, not a model parameter, so
%% hitting it must be visible rather than looking like a stable ceiling.
refused_births_are_counted_test() ->
    W = quiet(maps:merge(#{population => 4, max_creatures => 4, influx => 0,
                           ground_ceiling => 0, metabolism => 0,
                           sensor_rent => 0, hidden_rent => 0,
                           max_age => 100000, start_energy => 400}, fertile())),
    #{population := P, births_refused := R} = world:snapshot(world:tick(W)),
    ?assertEqual(4, P),
    ?assert(R > 0).

%%==============================================================================
%% Which rules this world runs under
%%==============================================================================

identical_economies_share_a_fingerprint_test() ->
    #{econ_id := IdA} = world:snapshot(world:new(#{seed => 1, radius => 9})),
    #{econ_id := IdB} = world:snapshot(world:new(#{seed => 2, radius => 9})),
    ?assertEqual(IdA, IdB).

one_changed_number_changes_the_fingerprint_test() ->
    #{econ_id := Default} = world:snapshot(world:new(#{radius => 4})),
    #{econ_id := Leaner} = world:snapshot(world:new(#{radius => 4,
                                                      metabolism => 20})),
    ?assertNotEqual(Default, Leaner).

fingerprint_is_short_lowercase_hex_test() ->
    #{econ_id := Id} = world:snapshot(world:new(#{radius => 3})),
    ?assertEqual(16, byte_size(Id)),
    ?assertMatch({match, _}, re:run(Id, "^[0-9a-f]{16}$")).

%%==============================================================================
%% What a spectator is given
%%==============================================================================

the_chart_is_flat_integer_lists_test() ->
    W = world:new(#{population => 5, radius => 3, seed => 2}),
    #{creatures := Cs, energies := Es, signatures := Sigs,
      ground := G, scent := Sc, radius := R} = world:chart(W),
    ?assertEqual(10, length(Cs)),
    ?assertEqual(5, length(Es)),
    ?assertEqual(5, length(Sigs)),
    ?assertEqual(0, length(G) rem 3),
    ?assertEqual(0, length(Sc) rem 3),
    ?assertEqual(3, R),
    ?assert(lists:all(fun is_integer/1, Cs ++ Es ++ Sigs ++ G ++ Sc)).

%% Only cells holding something are sent: an empty cell is one a spectator draws
%% bare, and on a grazed board most of them are.
an_emptied_cell_is_left_out_of_the_chart_test() ->
    Virgin = world:chart(world:new(#{radius => 2, population => 0})),
    ?assertEqual(hex:cells(2) * 3, length(maps:get(ground, Virgin))),
    Bare = world:chart(world:new(#{radius => 2, population => 0,
                                   ground_ceiling => 0})),
    ?assertEqual([], maps:get(ground, Bare)).

%% Sorted, so two charts of the same world are the same bytes and a diff between
%% frames means something.
the_chart_is_stable_test() ->
    W = world:tick(world:new(#{population => 8, radius => 4, seed => 6}), 20),
    ?assertEqual(world:chart(W), world:chart(W)).
