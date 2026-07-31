%% @doc The physics, asserted rather than eyeballed.
%%
%% The point of these is not that the world "works". It is that energy goes
%% exactly where the rules say it goes, because every later question is asked in
%% units of energy and is meaningless if the books do not balance.
%%
%% NOTHING HERE ASSERTS A BIOLOGICAL OUTCOME. There is no test that predators
%% appear, that a sensor survives, or that roles differentiate, and there must
%% never be one: those are the things the world exists to answer, and a test that
%% demanded them would turn a failed prediction into a broken build and quietly
%% pressure the rules until it passed. What is asserted is that the rules are the
%% rules. See PREREGISTRATION.md.
-module(world_tests).

-include_lib("eunit/include/eunit.hrl").

%% A world with no plants at all: none sown at creation, none regrowing, and no
%% rent, so nothing enters and every change in the energy total is attributable.
%%
%% `initial_plants => 0' and `sensor_rent => 0' are both LOAD BEARING. Without
%% the first these were not barren and quietly measured a creature eating while
%% claiming to measure metabolism. Without the second a founding body is drawn at
%% random, so the bill would vary with the seed by however many sensors it dealt.
barren(Opts) ->
    world:new(maps:merge(#{initial_plants => 0,
                           regrowth_per_tick => 0,
                           sensor_rent => 0,
                           population => 1,
                           radius => 3,
                           seed => 7}, Opts)).

%% A creature that cannot perceive anything and is indifferent to staying: no
%% sensors, so one weight, and it is zero. Every cell scores alike and the choice
%% is a coin, which is the null forager the whole design rests on.
blind() -> #{founder_body => [], founder_brain => [0]}.

%% Sensors and weights are positional and must stay in step, so tests that set
%% both say so together.
with(Sensors, Weights) ->
    #{founder_body => Sensors, founder_brain => Weights}.

%%==============================================================================
%% Making one
%%==============================================================================

starts_with_the_population_it_was_asked_for_test() ->
    W = world:new(#{population => 12, radius => 5}),
    ?assertEqual(12, world:population(W)),
    ?assertEqual(0, world:at_tick(W)).

%% Same parameters, same world. Nothing reads a clock or the process dictionary,
%% so a run is a function of its arguments and a surprising run can be reproduced
%% from the numbers in its own snapshot.
same_seed_same_world_test() ->
    A = world:tick(world:new(#{seed => 99, population => 20}), 50),
    B = world:tick(world:new(#{seed => 99, population => 20}), 50),
    ?assertEqual(world:snapshot(A), world:snapshot(B)).

different_seed_different_world_test() ->
    A = world:tick(world:new(#{seed => 1, population => 20}), 50),
    B = world:tick(world:new(#{seed => 2, population => 20}), 50),
    ?assertNotEqual(world:snapshot(A), world:snapshot(B)).

%% Founders are spread across every shape the rules allow, so selection has
%% something to sort on the first tick instead of waiting for mutation to invent
%% variety. Asserted on bodies because they are the coarsest of the four.
founders_are_not_all_alike_test() ->
    W = world:new(#{population => 40, seed => 3}),
    #{sensors := Census} = world:snapshot(W),
    Carriers = [maps:get(carriers, F) || F <- maps:values(Census)],
    ?assert(lists:sum(Carriers) > 0),
    ?assert(lists:any(fun(N) -> N < 40 end, Carriers)).

%%==============================================================================
%% What it costs to exist and to act
%%==============================================================================

%% A creature with no sensors and a zero weight is indifferent between staying
%% and moving, so this pins the weight instead: staying is worth less than
%% nothing, which makes it certainly move and the step certainly billed.
existing_and_moving_both_cost_test() ->
    W0 = barren(maps:merge(#{metabolism => 3, move_cost => 2,
                             start_energy => 100}, with([], [-1]))),
    #{energy_total := Before} = world:snapshot(W0),
    #{energy_total := After} = world:snapshot(world:tick(W0)),
    ?assertEqual(100, Before),
    ?assertEqual(100 - 3 - 2, After).

%% STAYING IS THE ONLY FREE OPTION, and that is what makes sitting out a bad
%% patch reachable at all. Without it the cheapest strategy in a barren world
%% does not exist and every creature is forced to burn energy having opinions.
staying_costs_nothing_but_metabolism_test() ->
    W = barren(maps:merge(#{metabolism => 2, move_cost => 100,
                            start_energy => 100}, with([], [1]))),
    #{energy_total := After} = world:snapshot(world:tick(W, 5)),
    ?assertEqual(100 - 10, After).

metabolism_is_charged_every_tick_test() ->
    W = barren(maps:merge(#{metabolism => 5, move_cost => 0,
                            start_energy => 100}, blind())),
    #{energy_total := After} = world:snapshot(world:tick(W, 10)),
    ?assertEqual(100 - 50, After).

%% THE ONLY FORCE THAT CAN REMOVE A SENSOR. If measuring were free every lineage
%% would accumulate every measurement, the fully equipped generalist would never
%% be at a disadvantage, and nothing could ever specialise in anything.
a_sensor_costs_its_rent_every_tick_test() ->
    Cost = fun(Sensors, Weights) ->
                   W = barren(maps:merge(#{metabolism => 0, sensor_rent => 2,
                                           move_cost => 0, start_energy => 200},
                                         with(Sensors, Weights))),
                   #{energy_total := E} = world:snapshot(world:tick(W, 10)),
                   200 - E
           end,
    ?assertEqual(0, Cost([], [0])),
    %% Rent rises with reach: range 0 is one unit of rent, range 2 is three.
    ?assertEqual(20, Cost([{plants, 0}], [0, 0])),
    ?assertEqual(60, Cost([{plants, 2}], [0, 0])),
    %% And it is charged per sensor, so a generalist pays for each.
    ?assertEqual(40, Cost([{plants, 0}, {creatures, 0}], [0, 0, 0])).

%%==============================================================================
%% Where energy enters
%%==============================================================================

%% Energy enters only by eating a plant, and exactly one plant's worth per plant.
%% Asserted as a relation rather than a fixed number so that it holds whether or
%% not the creature happened to move onto one.
eating_adds_exactly_one_plant_test() ->
    W = world:new(maps:merge(#{population => 1, radius => 1,
                               regrowth_per_tick => 0, initial_plants => 4,
                               plant_energy => 40, metabolism => 0,
                               move_cost => 0, sensor_rent => 0,
                               start_energy => 10, breed_at => 100000,
                               seed => 3}, blind())),
    #{energy_total := E0, plants := P0} = world:snapshot(W),
    #{energy_total := E1, plants := P1, plants_eaten := Ate} =
        world:snapshot(world:tick(W)),
    ?assertEqual(Ate * 40, E1 - E0),
    ?assertEqual(Ate, P0 - P1).

a_barren_world_only_loses_energy_test() ->
    W = barren(maps:merge(#{population => 5, start_energy => 60}, blind())),
    Totals = [begin
                  #{energy_total := E} = world:snapshot(world:tick(W, N)),
                  E
              end || N <- lists:seq(0, 10)],
    ?assertEqual(lists:reverse(lists:sort(Totals)), Totals).

%%==============================================================================
%% Consumption: one rule that does not know what it is eating
%%==============================================================================

%% Everyone on one cell, since radius 0 is a single hex. Breeding is put out of
%% reach because a creature that has just eaten another is carrying exactly the
%% surplus that buys a child, and a population count would otherwise mix the two.
crowd(N, Opts) ->
    barren(maps:merge(maps:merge(#{population => N, radius => 0,
                                   start_energy => 100, metabolism => 0,
                                   move_cost => 0, breed_at => 1000000,
                                   breed_ceiling => 1000000,
                                   max_age => 100000}, blind()), Opts)).

%% A PLANT CANNOT CONTEST AND SO IS ALWAYS TAKEN. Nothing about being a plant
%% appears in the rule; it is simply a thing in the cell with no energy of its
%% own to hold anyone off.
a_plant_is_taken_by_whoever_stands_on_it_test() ->
    W = crowd(1, #{initial_plants => 1, radius => 0, plant_energy => 40}),
    #{energy_total := Before, plants := P0} = world:snapshot(W),
    #{energy_total := After, plants := P1} = world:snapshot(world:tick(W)),
    ?assertEqual(1, P0),
    ?assertEqual(0, P1),
    ?assertEqual(Before + 40, After).

%% EQUALS DO NOT CONSUME EACH OTHER. Two creatures of identical energy share a
%% cell indefinitely, which is what stops the rule being "whoever is listed
%% first wins" and makes the outcome a function of the world.
equals_do_not_consume_each_other_test() ->
    #{population := Pop, consumed := Eaten} =
        world:snapshot(world:tick(crowd(2, #{}), 5)),
    ?assertEqual(2, Pop),
    ?assertEqual(0, Eaten).

%% AND THE RULE DOES NOT KNOW IT IS PREDATION. Something holding more energy
%% takes something holding less, exactly as it takes a plant, and the same line
%% of code does both. Nothing here is aware that one case is a plant and the
%% other an animal.
%%
%% Radius 0 is a single cell and a child is placed on a neighbour, of which there
%% are none, so parent and child end up standing together. The dowry is half the
%% threshold, so the child is always the poorer of the two.
the_stronger_takes_the_weaker_test() ->
    W = barren(maps:merge(#{population => 1, radius => 0, start_energy => 200,
                            breed_at => 150, breed_floor => 150,
                            breed_ceiling => 150, breed_mutation => 0,
                            metabolism => 0, move_cost => 0,
                            max_age => 100000}, blind())),
    Look = fun(N) ->
                   #{population := P, energy_total := E, consumed := C} =
                       world:snapshot(world:tick(W, N)),
                   {P, E, C}
           end,
    %% Alone, and the whole world is 200.
    ?assertEqual({1, 200, 0}, Look(0)),
    %% A child is born. The parent paid exactly what the child received, so the
    %% total has not moved and nothing has been eaten.
    ?assertEqual({2, 200, 0}, Look(1)),
    %% Now they share a cell. The parent holds 125 against the child's 75 and
    %% takes it, and immediately has the surplus to breed again. ENERGY IS
    %% UNCHANGED BY THE TAKING: it changed hands, none was minted or destroyed.
    ?assertEqual({2, 200, 1}, Look(2)).

%%==============================================================================
%% Death, by cause
%%==============================================================================

starvation_is_counted_as_starvation_test() ->
    W = barren(maps:merge(#{start_energy => 4, metabolism => 1, move_cost => 1},
                          with([], [-1]))),
    #{population := Pop, starved := S, aged_out := O, consumed := C} =
        world:snapshot(world:tick(W, 5)),
    ?assertEqual(0, Pop),
    ?assertEqual(1, S),
    ?assertEqual(0, O),
    ?assertEqual(0, C).

%% Three causes, never summed. "The population crashed" and "the population grew
%% old" are different findings and one total cannot tell them apart.
old_age_is_counted_as_old_age_test() ->
    W = barren(maps:merge(#{start_energy => 30, breed_floor => 40,
                            metabolism => 0, move_cost => 0, max_age => 3},
                          blind())),
    #{population := Pop, starved := S, aged_out := O} =
        world:snapshot(world:tick(W, 6)),
    ?assertEqual(0, Pop),
    ?assertEqual(0, S),
    ?assertEqual(1, O).

%%==============================================================================
%% What a surplus buys
%%==============================================================================

%% Birth conserves energy: the parent pays exactly what the child receives, so
%% the only sinks are metabolism, rent and movement. That is what makes a
%% drifting energy total a bug rather than a mystery.
breeding_conserves_energy_test() ->
    W0 = barren(maps:merge(#{start_energy => 200, breed_at => 150,
                             metabolism => 0, move_cost => 0,
                             max_age => 100000}, blind())),
    #{energy_total := Before, population := P0} = world:snapshot(W0),
    #{energy_total := After, population := P1} = world:snapshot(world:tick(W0)),
    ?assertEqual(Before, After),
    ?assertEqual(P0 + 1, P1).

a_creature_below_the_threshold_does_not_breed_test() ->
    W = barren(maps:merge(#{start_energy => 100, breed_at => 150,
                            metabolism => 0, move_cost => 0}, blind())),
    #{population := P} = world:snapshot(world:tick(W)),
    ?assertEqual(1, P).

%% A CHILD MUST BE ITS PARENT'S SHAPE. The brain carries one weight per sensor
%% plus one for staying, so a body and a brain out of step is the worst bug
%% available here: nothing crashes, and every weight after the change quietly
%% starts valuing a different measurement.
every_child_has_a_brain_that_fits_its_body_test() ->
    W = world:tick(world:new(#{population => 30, seed => 5,
                               body_mutation => 1}), 300),
    #{sensor_mean := Mean, population := Pop} = world:snapshot(W),
    ?assert(Pop > 0),
    %% Reaching here at all means no creature scored a cell with a mismatched
    %% weight list, which would have crashed lists:zip in brain:value/3.
    ?assert(Mean >= 0).

%% The cap is a safety valve against a mistuned run, not a model parameter, so
%% hitting it must be visible rather than looking like a stable ceiling.
refused_births_are_counted_test() ->
    W = barren(maps:merge(#{population => 4, max_creatures => 4,
                            start_energy => 500, breed_at => 100,
                            metabolism => 0, move_cost => 0,
                            max_age => 100000}, blind())),
    #{population := P, births_refused := R} = world:snapshot(world:tick(W)),
    ?assertEqual(4, P),
    ?assert(R > 0).

%%==============================================================================
%% Trails
%%==============================================================================

%% A MOVING CREATURE MARKS THE GROUND AND A STILL ONE DOES NOT. That asymmetry
%% makes staying put a way to go unnoticed as well as a way to save energy, which
%% is the only counter available to something being tracked.
moving_leaves_a_trail_and_staying_does_not_test() ->
    Walker = barren(maps:merge(#{radius => 3}, with([], [-1]))),
    Sitter = barren(maps:merge(#{radius => 3}, with([], [1]))),
    #{scent_cells := Walked} = world:snapshot(world:tick(Walker, 5)),
    #{scent_cells := Sat} = world:snapshot(world:tick(Sitter, 5)),
    ?assert(Walked > 0),
    ?assertEqual(0, Sat).

%% A trail that never faded would be a road, and a board where every cell smells
%% alike carries exactly as much information as one where none does.
a_trail_fades_to_nothing_test() ->
    W = barren(maps:merge(#{radius => 3, start_energy => 3, metabolism => 1,
                            scent_per_tick => 10, scent_decay => 2,
                            scent_ceiling => 10}, with([], [-1]))),
    #{population := Pop, scent_cells := Stale} =
        world:snapshot(world:tick(W, 12)),
    ?assertEqual(0, Pop),
    ?assertEqual(0, Stale).

%%==============================================================================
%% Reading a world
%%==============================================================================

%% NOTHING THE OBSERVER COUNTS IS READ BY THE PHYSICS. That separation is what
%% makes it legitimate to count diet at all: it is a description applied
%% afterwards, never a category the world enforces.
where_energy_came_from_is_counted_test() ->
    Grazed = world:new(maps:merge(#{population => 1, radius => 1,
                                    initial_plants => 7, regrowth_per_tick => 0,
                                    metabolism => 0, move_cost => 0,
                                    sensor_rent => 0, breed_at => 100000,
                                    seed => 2}, blind())),
    #{from_creatures_pct := Share} = world:snapshot(world:tick(Grazed, 3)),
    ?assertEqual(0, Share).

%% Zero for a population that has eaten nothing, rather than a crash or a
%% nonsense average.
a_population_that_has_eaten_nothing_has_no_share_test() ->
    #{from_creatures_pct := Share} =
        world:snapshot(world:new(#{population => 5, seed => 8})),
    ?assertEqual(0, Share).

%% A census of what survived, by field. Not a verdict about what was useful: the
%% two are only the same thing after enough generations that drift is outvoted.
the_sensor_census_covers_every_field_test() ->
    #{sensors := Census, population := Pop} =
        world:snapshot(world:new(#{population => 20, seed => 4})),
    ?assertEqual(lists:sort(body:fields()), lists:sort(maps:keys(Census))),
    Carriers = [maps:get(carriers, F) || F <- maps:values(Census)],
    ?assert(lists:all(fun(N) -> N =< Pop end, Carriers)).

%%==============================================================================
%% Which rules this world runs under
%%==============================================================================

identical_economies_share_a_fingerprint_test() ->
    #{econ_id := IdA} = world:snapshot(world:new(#{seed => 1, radius => 9})),
    #{econ_id := IdB} = world:snapshot(world:new(#{seed => 2, radius => 9})),
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

the_economy_itself_travels_with_the_fingerprint_test() ->
    #{econ := Econ} = world:snapshot(world:new(#{metabolism => 2})),
    ?assertEqual(2, maps:get(metabolism, Econ)),
    ?assertEqual(maps:keys(world:defaults()), maps:keys(Econ)).

%%==============================================================================
%% Extinction
%%==============================================================================

%% EXTINCTION IS PERMANENT AND THAT IS A PROPERTY OF THE RULES. Nothing reseeds a
%% world and a population of zero cannot produce a birth, so a dead island goes
%% on publishing forever: its plants regrow, its tick advances, and every fact
%% after the last death is identical to the one before. The tick it emptied is
%% the only part no later sample carries.
a_world_that_dies_records_when_test() ->
    W = barren(maps:merge(#{population => 3, start_energy => 4,
                            metabolism => 1, move_cost => 1}, with([], [-1]))),
    #{extinct_at := Before} = world:snapshot(W),
    ?assertEqual(undefined, Before),
    #{population := Pop, extinct_at := At} = world:snapshot(world:tick(W, 10)),
    ?assertEqual(0, Pop),
    ?assert(is_integer(At)).

the_tick_of_death_is_not_revised_test() ->
    W = world:tick(barren(maps:merge(#{population => 2, start_energy => 4,
                                       metabolism => 1, move_cost => 1},
                                     with([], [-1]))), 10),
    #{extinct_at := At} = world:snapshot(W),
    #{extinct_at := Later} = world:snapshot(world:tick(W, 50)),
    ?assertEqual(At, Later).

%%==============================================================================
%% What a spectator is given
%%==============================================================================

%% Flat integers rather than pairs, because a pair is a tuple and tuples do not
%% survive this mesh cleanly, and a map per entity would repeat the keys `q' and
%% `r' for every creature for no information.
the_chart_is_flat_coordinate_lists_test() ->
    W = world:new(#{population => 5, radius => 3, initial_plants => 7, seed => 2}),
    #{creatures := Cs, plants := Ps, radius := R, tick := T} = world:chart(W),
    ?assertEqual(10, length(Cs)),
    ?assertEqual(0, length(Cs) rem 2),
    ?assertEqual(0, length(Ps) rem 2),
    ?assertEqual(3, R),
    ?assertEqual(0, T),
    ?assert(lists:all(fun is_integer/1, Cs ++ Ps)).

%% ONE ENERGY PER CREATURE, IN THE SAME ORDER. A parallel list rather than
%% interleaved: interleaving would make the creature stride 3 while plants stayed
%% 2, and a reader that got it wrong would draw a plausible and completely wrong
%% picture instead of failing.
%%
%% Worth carrying because ENERGY IS ARMOUR here. The stronger consumes the
%% weaker, so how big a creature is is the most informative thing about it, and
%% without this every dot is drawn identical.
energies_run_parallel_to_creatures_test() ->
    W = world:new(#{population => 6, radius => 3, start_energy => 90, seed => 4}),
    #{creatures := Cs, energies := Es} = world:chart(W),
    ?assertEqual(length(Cs) div 2, length(Es)),
    ?assertEqual(lists:duplicate(6, 90), Es).

%% A creature awaiting the reaper carries a negative balance, and a viewer sizing
%% a dot by it would be asked for a negative radius.
a_starving_creature_charts_no_negative_energy_test() ->
    W = barren(maps:merge(#{population => 3, start_energy => 2,
                            metabolism => 5}, blind())),
    #{energies := Es} = world:chart(world:tick(W)),
    ?assert(lists:all(fun(E) -> E >= 0 end, Es)).

%% Position AND strength, interleaved at three, because a mark has no list to run
%% parallel to. The signature is left out on purpose: it would double the payload
%% and a spectator has nothing to compare it against.
scent_charts_as_position_and_strength_test() ->
    Walker = barren(maps:merge(#{radius => 3, scent_per_tick => 10},
                               with([], [-1]))),
    #{scent := Marks} = world:chart(world:tick(Walker, 3)),
    ?assert(length(Marks) > 0),
    ?assertEqual(0, length(Marks) rem 3),
    Strengths = strengths(Marks),
    ?assert(lists:all(fun(S) -> S > 0 end, Strengths)).

strengths([]) -> [];
strengths([_Q, _R, S | Rest]) -> [S | strengths(Rest)].

%% An empty world charts as empty lists rather than as missing keys, so a viewer
%% draws nothing instead of having to interpret a gap.
an_empty_world_charts_empty_lists_test() ->
    W = world:tick(barren(maps:merge(#{population => 1, start_energy => 2,
                                       metabolism => 5}, blind())), 20),
    #{creatures := Cs, energies := Es, scent := Sc} = world:chart(W),
    ?assertEqual([], Cs),
    ?assertEqual([], Es),
    ?assertEqual([], Sc).

%% Sorted, so two charts of the same world are the same bytes and a diff between
%% frames means something.
the_chart_is_stable_test() ->
    W = world:tick(world:new(#{population => 8, radius => 4, seed => 6}), 20),
    ?assertEqual(world:chart(W), world:chart(W)).

%% ONE SIGNATURE PER CREATURE, IN THE SAME ORDER, so a viewer can colour them by
%% kinship. A creature reads a trail by how unlike itself it smells, so this is
%% what relatedness IS here, and comparing creatures against each other is the
%% only way to see whether a population has become one family or several without
%% reading it off a table.
signatures_run_parallel_to_creatures_test() ->
    W = world:new(#{population => 6, radius => 3, seed => 4,
                    founder_scent => 2#10110010}),
    #{creatures := Cs, signatures := Sigs} = world:chart(W),
    ?assertEqual(length(Cs) div 2, length(Sigs)),
    ?assertEqual(lists:duplicate(6, 2#10110010), Sigs).

%% A CENSUS SAYS WHAT THE POPULATION IS BUILT FROM NOW; these say whether that is
%% still moving. Both flat is a settled body plan and both climbing is a lineage
%% churning through them, which a census alone cannot tell apart.
structural_change_is_counted_test() ->
    Settled = world:tick(world:new(#{population => 20, seed => 9,
                                     body_mutation => 1000000}), 200),
    #{sensors_gained := G0, sensors_lost := L0} = world:snapshot(Settled),
    ?assertEqual(0, G0),
    ?assertEqual(0, L0),

    Churning = world:tick(world:new(#{population => 20, seed => 9,
                                      body_mutation => 1}), 200),
    #{sensors_gained := G1, sensors_lost := L1} = world:snapshot(Churning),
    ?assert(G1 > 0),
    ?assert(L1 > 0).

%% AN ORGAN THAT EXISTS AND AN ORGAN THAT MATTERS ARE DIFFERENT THINGS, and the
%% census reports both. A creature can pay rent every tick for a measurement its
%% brain weights at zero, so carriers alone would overstate perception and a
%% population could look equipped while being effectively blind.
the_census_separates_carrying_from_acting_test() ->
    Ignored = world:new(#{population => 5, radius => 3, seed => 2,
                          founder_body => [{creatures, 1}],
                          founder_brain => [0, 0]}),
    #{sensors := Census} = world:snapshot(Ignored),
    Field = maps:get(creatures, Census),
    ?assertEqual(5, maps:get(carriers, Field)),
    ?assertEqual(0, maps:get(attention, Field)),

    Heeded = world:new(#{population => 5, radius => 3, seed => 2,
                         founder_body => [{creatures, 1}],
                         founder_brain => [7, 0]}),
    #{sensors := Acted} = world:snapshot(Heeded),
    ?assertEqual(700, maps:get(attention, maps:get(creatures, Acted))).
