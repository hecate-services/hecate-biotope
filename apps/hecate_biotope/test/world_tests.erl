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

%% As above but it converts a fixed amount of store into structure every tick.
builder(Amount) ->
    #{founder_body => [],
      founder_brain => #{hidden => [],
                         outputs => #{grow => #{inputs => [Amount],
                                                hidden => []}}}}.

%% As above but it will breed on the first tick it can.
fertile() ->
    #{founder_body => [],
      founder_brain => #{hidden => [],
                         outputs => #{breed => #{inputs => [1], hidden => []}}}}.

%% `upkeep_divisor' is set out of reach for the same reason `sensor_rent' is
%% zeroed: these measure the BASE economy, and world 5 made holding energy cost
%% something, so a creature carrying eight hundred would otherwise be billed
%% twenty-four a tick and every sum below would be off by an amount that varied
%% with how fed it was. The cost gets its own tests rather than contaminating
%% these.
quiet(Opts) ->
    world:new(maps:merge(#{population => 1, radius => 3, seed => 7,
                           upkeep_divisor => 1000000}, Opts)).

%% Everything in the world is in the ground, in a creature's store, or built into
%% its structure. THREE TERMS SINCE WORLD 6, because structure is energy in
%% another form and leaving it out would make every transfer into it look like a
%% leak.
books(W) ->
    #{energy_total := Stores, structure_total := Structures,
      ground_total := Ground} = world:snapshot(W),
    Stores + Structures + Ground.

%% THE FIRST LAW, whole. `books/1' above only ever compared the pools against
%% each other, which is a weaker statement than conservation: before world 7
%% metabolism simply vanished, and a creature could pay costs it did not have.
%% Adding what left the pools closes it.
closed_books(W) ->
    #{dissipated := Gone} = world:snapshot(W),
    books(W) + Gone.

%% A world with the sun switched off, so nothing enters and the total can only
%% be conserved or leak. With ground entering there is nothing to test against.
sealed(Opts) ->
    quiet(maps:merge(#{ground_seed => 0, ground_growth_pct => 0,
                       population => 12, radius => 3, seed => 5,
                       max_age => 60, start_energy => 400}, Opts)).

%% THE FIRST LAW HOLDS EXACTLY, at every efficiency, which is the whole point of
%% the dissipation account. Energy is not destroyed by a lossy transformation, it
%% leaves the pools as heat, and the account is where it goes.
%%
%% Run across the sweep rather than at one value, because a rounding error in one
%% of the six sites would show at some efficiencies and not others.
nothing_is_created_or_destroyed_at_any_efficiency_test() ->
    lists:foreach(fun(Eff) ->
                          W = sealed(#{transfer_efficiency => Eff}),
                          ?assertEqual({Eff, closed_books(W)},
                                       {Eff, closed_books(world:tick(W, 200))})
                  end, [100, 95, 80, 60, 40, 20, 1]).

%% AND IT NEVER CLIMBS, which is the Second Law. In units where T is 1 the
%% dissipation account IS the entropy account, so this is that law stated as a
%% test rather than as an intention.
entropy_never_falls_test() ->
    W = sealed(#{transfer_efficiency => 60}),
    Series = [begin
                  #{dissipated := D} = world:snapshot(world:tick(W, N)),
                  D
              end || N <- lists:seq(0, 40, 4)],
    ?assertEqual(lists:sort(Series), Series),
    ?assert(lists:last(Series) > 0).

%% A LOSSY WORLD REALLY IS LOSSIER, which sounds obvious and is the check that
%% the efficiency is wired to anything at all. Three of the six sites were once
%% added to a snapshot and left out of the report, so wiring is worth testing.
%%
%% MEASURED PER UNIT MOVED, and the first version of this measured the TOTAL,
%% which is a different claim and not a true one. A sealed world holds a fixed
%% amount of energy, so what a low efficiency changes is not how much can ever
%% burn but how fast anything happens, and at 20% the creatures starve early and
%% stop transacting. Total dissipation over a fixed window therefore peaks in the
%% MIDDLE, near 60%, and falls at both ends: 16,537 at 90%, 17,142 at 60%,
%% 14,845 at 40%, 10,140 at 20%. That is a maximum-power curve of the shape Odum
%% and Pinkerton describe, and the old assertion was monotone only by accident.
%%
%% What IS monotone is the loss per unit transferred, because that is the law
%% itself rather than a consequence of it: 95, 126, 229, 369 and 949 units burnt
%% per hundred absorbed, as efficiency falls from 100 to 20.
a_lower_efficiency_loses_more_of_what_it_moves_test() ->
    Ratio = fun(Eff) ->
                    #{dissipated := D, absorbed := A} =
                        world:snapshot(world:tick(
                                         sealed(#{transfer_efficiency => Eff}),
                                         60)),
                    D * 100 div max(A, 1)
            end,
    Falling = [Ratio(Eff) || Eff <- [100, 90, 60, 40, 20]],
    ?assertEqual(lists:sort(Falling), Falling),
    ?assert(hd(Falling) < lists:last(Falling)).

%%==============================================================================
%% The books
%%==============================================================================

%% THE INVARIANT WORLD 1 COULD NEVER CHECK, because it destroyed the energy of
%% anything that died of old age. It could assert only that the total FELL, never
%% that it fell by exactly what was spent, so any other leak would have hidden
%% behind the one it had built in.
a_still_world_conserves_energy_exactly_test() ->
    W = quiet(maps:merge(#{ground_seed => 0, ground_growth_pct => 0, metabolism => 0, sensor_rent => 0,
                           hidden_rent => 0, max_age => 100000}, inert())),
    Totals = [books(world:tick(W, N)) || N <- lists:seq(0, 20)],
    ?assertEqual(1, length(lists:usort(Totals))).

%% The only sink is the work of staying alive.
existing_is_the_only_leak_test() ->
    W = quiet(maps:merge(#{ground_seed => 0, ground_growth_pct => 0, metabolism => 7, sensor_rent => 0,
                           hidden_rent => 0, max_age => 100000}, inert())),
    ?assertEqual(books(W) - 70, books(world:tick(W, 10))).

%% THE MOVER'S BILL IS NO LONGER A FIXED NUMBER, and that is world 12. A creature
%% crosses as many cells as it can pay for rather than exactly one, so what it
%% spends says how far it went. The stayer is still exact, because standing still
%% is still free.
moving_costs_over_and_above_existing_test() ->
    Opts = #{ground_seed => 0, ground_growth_pct => 0, metabolism => 3, move_cost => 5, sensor_rent => 0,
             hidden_rent => 0, max_age => 100000},
    Still = quiet(maps:merge(Opts, inert())),
    Moving = quiet(maps:merge(Opts, restless())),
    Existing = 30,
    ?assertEqual(books(Still) - Existing, books(world:tick(Still, 10))),

    Spent = books(Moving) - books(world:tick(Moving, 10)),
    Travel = Spent - Existing,
    %% `upkeep_divisor' is out of reach in `quiet', so the body adds nothing to
    %% the fare here and every cell crossed costs exactly `move_cost'.
    ?assert(Travel > 0),
    ?assertEqual(0, Travel rem 5),
    %% And more than the single cell a tick this world allowed until now.
    ?assert(Travel > 10 * 5).

%% DEATH RETURNS ENERGY TO THE GROUND IT DIED ON. World 1 deleted it, and a
%% well-fed creature could be carrying hundreds.
dying_of_old_age_returns_its_energy_to_the_ground_test() ->
    W = quiet(maps:merge(#{ground_seed => 0, ground_growth_pct => 0, metabolism => 0, sensor_rent => 0,
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

%% Recovery stops at the ceiling rather than accumulating without bound.
%% Asserted with nobody there to graze it: with a creature present the WORLD
%% total keeps rising, correctly, because the ceiling caps a CELL and influx goes
%% on arriving. An earlier version of this asserted the world total and was
%% simply wrong about what the ceiling means.
the_ground_fills_to_its_ceiling_and_no_further_test() ->
    W = world:new(#{radius => 1, population => 0, ground_seed => 100, ground_growth_pct => 0,
                    ground_ceiling => 250, seed => 7}),
    #{ground_total := Early} = world:snapshot(world:tick(W, 50)),
    #{ground_total := Late} = world:snapshot(world:tick(W, 200)),
    ?assertEqual(hex:cells(1) * 250, Early),
    ?assertEqual(Early, Late).

%%==============================================================================
%% Absorbing, contesting, and one rule for both
%%==============================================================================

%% A CREATURE TAKES AT MOST WHAT ITS BODY CAN, and what it does not take stays.
%% World 3 took everything, so every grazed cell sat at zero and stock-dependent
%% recovery collapsed to its floor everywhere.
absorbing_is_limited_by_the_creature_test() ->
    W = grazer(70, #{ground_ceiling => 300}),
    #{energy_total := E1, ground_total := G1} = world:snapshot(world:tick(W)),
    %% ASSERTED AS A GAIN rather than as a total. A founder is half store and
    %% half structure since world 6, so what it starts with carried depends on
    %% `start_energy', and world 8 had to raise that so the BODY would not be
    %% what capped the rate. A total couples this test to a number it is not
    %% about, and did in fact break on it.
    ?assertEqual(70, E1 - 2000),
    %% Its own cell keeps the 230 it could not take; every other cell is full.
    ?assertEqual((hex:cells(3) - 1) * 300 + 230, G1).

%% A CREATURE WITHOUT A BODY IS A GHOST, and world 7 was full of them: below 70%
%% efficiency every frame was zero and those creatures went on eating, sensing,
%% thinking and breeding exactly as well as any other.
%%
%% Nothing anywhere says a frame of zero is fatal. Such a creature cannot feed,
%% so it starves like anything else that cannot feed, and death from having no
%% body is a CONSEQUENCE rather than a decree.
%%
%% A FOUNDER CANNOT BE BORN BODILESS, which is worth knowing and is asserted
%% here: the split hands the odd unit to the frame, so the smallest founder the
%% rules allow still has one. A ghost can therefore only arise by catabolising
%% itself down to nothing, and then it is already dead.
a_founder_always_has_at_least_some_body_test() ->
    W = quiet(maps:merge(#{start_energy => 1}, inert())),
    #{structure_total := Frame, energy_total := Store} = world:snapshot(W),
    ?assertEqual(1, Frame),
    ?assertEqual(0, Store).

%% AND HAVING ONE IS WHAT LIFTS THE CAP, which is the other half of the rule: the
%% same creature on the same ground, differing only in whether it has a body,
%% eats or does not.
what_a_creature_can_take_in_is_bounded_by_its_frame_test() ->
    Fed = fun(Start) ->
                  W = quiet(maps:merge(#{ground_seed => 400,
                                         ground_growth_pct => 0,
                                         ground_ceiling => 400, metabolism => 0,
                                         sensor_rent => 0, hidden_rent => 0,
                                         max_age => 100000,
                                         start_energy => Start,
                                         founder_uptake => 400}, inert())),
                  #{absorbed := A} = world:snapshot(world:tick(W)),
                  A
          end,
    %% Frames of 5, 50 and 200 against an appetite of 400 and a full cell.
    ?assertEqual(5, Fed(10)),
    ?assertEqual(50, Fed(100)),
    ?assertEqual(200, Fed(400)).

%% A creature cannot take more than is there, however fast it feeds.
absorbing_cannot_exceed_what_is_in_the_cell_test() ->
    W = grazer(1000, #{ground_ceiling => 250}),
    #{energy_total := E1} = world:snapshot(world:tick(W)),
    ?assertEqual(250, E1 - 2000).

%% FEED GENTLY AND THE CELL SUSTAINS YOU INDEFINITELY. Below what the ground can
%% put back, the standing stock holds and the income never falls.
a_gentle_feeder_does_not_exhaust_its_cell_test() ->
    W = grazer(5, #{ground_seed => 5, ground_growth_pct => 0,
                    ground_ceiling => 300}),
    Ground = fun(N) ->
                     #{ground_total := G} = world:snapshot(world:tick(W, N)),
                     G - (hex:cells(3) - 1) * 300
             end,
    ?assertEqual(Ground(20), Ground(60)).

%% FEED HARDER THAN THE GROUND COMES BACK AND YOU STRIP IT. Overgrazing is
%% possible now, and what it costs is that your income collapses to the bare
%% floor: exactly the seed rate, whatever your body could have handled.
a_greedy_feeder_strips_its_cell_and_lives_on_the_floor_test() ->
    W = grazer(1000, #{ground_seed => 7, ground_growth_pct => 0,
                       ground_ceiling => 300}),
    Settled = world:tick(W, 5),
    #{energy_total := Before} = world:snapshot(Settled),
    #{energy_total := After} = world:snapshot(world:tick(Settled, 10)),
    ?assertEqual(70, After - Before).

%% A sensorless, brainless creature that cannot move or breed, feeding at a
%% pinned rate, so every unit of energy is attributable to absorption.
grazer(Rate, Opts) ->
    quiet(maps:merge(maps:merge(#{ground_seed => 0, ground_growth_pct => 0,
                                  metabolism => 0, sensor_rent => 0,
                                  hidden_rent => 0, max_age => 100000,
                                  %% FOUNDED LARGE SO THE BODY IS NOT WHAT BINDS.
                                  %% Since world 8 a creature cannot take in more
                                  %% than its frame, and a founder gets half its
                                  %% starting energy as one, so 4000 leaves a
                                  %% frame of 2000 against rates in the hundreds.
                                  %% These tests are about the RATE, and a body
                                  %% quietly capping it would make them pass or
                                  %% fail for the wrong reason.
                                  start_energy => 4000,
                                  founder_uptake => Rate}, inert()), Opts)).

%% THE LINE BETWEEN THE TWO LIVINGS, derived from the growth curve rather than
%% chosen. Below it a lineage can hold a cell for good; above it the cell is
%% stripped and staying becomes fatal.
the_sustainable_yield_is_derived_from_the_curve_test() ->
    Flat = maps:merge(world:defaults(), #{ground_seed => 9,
                                          ground_growth_pct => 0,
                                          ground_ceiling => 400}),
    %% With no compounding the best a cell can do is its floor.
    ?assertEqual(9, ground:sustainable(Flat)),
    Compounding = maps:merge(world:defaults(), #{ground_seed => 12,
                                                 ground_growth_pct => 6,
                                                 ground_ceiling => 400}),
    ?assert(ground:sustainable(Compounding) > 12).

%% A child feeds nearly as its parent did, so a lineage DRIFTS through feeding
%% rates rather than resampling them.
a_child_feeds_nearly_as_its_parent_did_test() ->
    %% A real ceiling, because the trait is bounded by one: a creature takes at
    %% most a full cell's worth per tick, so a world with no ground at all would
    %% clamp every feeding rate to nothing and measure the clamp.
    W = quiet(maps:merge(#{population => 1, radius => 0, ground_seed => 0,
                           ground_growth_pct => 0, ground_ceiling => 400,
                           metabolism => 0, sensor_rent => 0, hidden_rent => 0,
                           max_age => 100000, start_energy => 400,
                           uptake_mutation => 3,
                           founder_uptake => 200}, fertile())),
    #{uptake_mean := Mean, population := Pop} =
        world:snapshot(world:tick(W, 1)),
    ?assertEqual(2, Pop),
    ?assert(Mean >= 198 andalso Mean =< 202).

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

%% AND SINCE WORLD 9 AN EVEN SPLIT NO LONGER MAKES THEM EQUALS.
%%
%% Until world 8 this test asserted the opposite, and it was right to: the dowry
%% took half the store AND half the frame, so for an even founding the two came
%% out exactly equal, and equals do not consume each other. It read
%% `{4, 0, 200}' on the second tick, two equals both breeding again.
%%
%% World 9 pays the dowry out of the store alone and the parent keeps its whole
%% frame, so **a parent now outweighs its newborn at every founding energy, even
%% and odd alike**. Nobody wrote that rule; it falls out of the change, which is
%% why it is declared in PREREGISTRATION.md before the run rather than explained
%% afterwards. What it means in the world is that a newborn is the lightest thing
%% on the board and loses every contest it enters, including with its parent.
a_parent_outweighs_its_newborn_at_any_split_test() ->
    W = family(200),
    ?assertEqual({2, 0, 200}, look(W, 1)),
    ?assertEqual({2, 1, 200}, look(W, 2)).

%% MUTATION OFF, and finding out why cost a debugging round. With it on, the
%% child's breed weight is nudged from 1 to 0 or 2, and a 0 means it declines to
%% reproduce, so the second generation is not the clone the arithmetic here
%% assumes. That is the machinery working; it just makes a rule impossible to
%% isolate, which is what these two want to do.
family(Energy) ->
    quiet(maps:merge(#{population => 1, radius => 0, ground_seed => 0, ground_growth_pct => 0,
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
    W = quiet(maps:merge(#{population => 2, radius => 0, ground_seed => 0, ground_growth_pct => 0,
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
                   W = quiet(#{ground_seed => 0, ground_growth_pct => 0, metabolism => 0, sensor_rent => 2,
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
                   W = quiet(#{ground_seed => 0, ground_growth_pct => 0, metabolism => 0, sensor_rent => 0,
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
    W = quiet(maps:merge(#{ground_seed => 5, ground_growth_pct => 0, metabolism => 0, sensor_rent => 0,
                           hidden_rent => 0, max_age => 100000}, inert())),
    #{still_pct := Still} = world:snapshot(world:tick(W, 5)),
    ?assertEqual(100, Still).

%% Staying still leaves no trail, which makes sitting tight a way to go unnoticed
%% as well as a way to save energy, and is the only counter to being tracked.
moving_leaves_a_trail_and_staying_does_not_test() ->
    Opts = #{ground_seed => 5, ground_growth_pct => 0, metabolism => 0, sensor_rent => 0, hidden_rent => 0,
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
    W = quiet(maps:merge(#{ground_seed => 100, ground_growth_pct => 0, metabolism => 0, sensor_rent => 0,
                           hidden_rent => 0, max_age => 100000}, inert())),
    #{population := Pop} = world:snapshot(world:tick(W, 50)),
    ?assertEqual(1, Pop).

%% Birth conserves energy, and costs half of whatever the parent happens to be
%% carrying rather than a fixed sum.
breeding_conserves_energy_and_costs_half_test() ->
    W = quiet(maps:merge(#{ground_seed => 0, ground_growth_pct => 0, ground_ceiling => 0, metabolism => 0,
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
    W = quiet(maps:merge(#{ground_seed => 0, ground_growth_pct => 0, ground_ceiling => 0, metabolism => 30,
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
    W = quiet(maps:merge(#{ground_seed => 0, ground_growth_pct => 0, ground_ceiling => 0, metabolism => 0,
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
    W = quiet(maps:merge(#{population => 3, ground_seed => 0, ground_growth_pct => 0, ground_ceiling => 0,
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
    W = quiet(maps:merge(#{population => 4, max_creatures => 4, ground_seed => 0, ground_growth_pct => 0,
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

%%==============================================================================
%% The shape of the population
%%==============================================================================

%% A MEAN CANNOT BE SKIMMED PAST WHEN IT IS A DISTRIBUTION. "0.01 sensors per
%% creature" reads as nearly none without saying whether that is one creature in
%% a hundred carrying one or something else entirely, and the difference matters:
%% one is an apparatus being selected away, the other is one being maintained
%% rarely.
a_population_that_carries_nothing_is_one_bar_at_zero_test() ->
    W = quiet(maps:merge(#{population => 12, radius => 3}, inert())),
    #{sensor_hist := Sensors, hidden_hist := Hidden} = world:snapshot(W),
    ?assertEqual(12, hd(Sensors)),
    ?assertEqual(0, lists:sum(tl(Sensors))),
    ?assertEqual(12, hd(Hidden)),
    ?assertEqual(0, lists:sum(tl(Hidden))).

%% Every creature is counted exactly once, so the bars are a partition of the
%% population rather than overlapping tallies.
the_bars_partition_the_population_test() ->
    W = world:tick(world:new(#{population => 30, radius => 6, seed => 5,
                               body_mutation => 1,
                               brain_mutation_structural => 1}), 200),
    #{population := Pop, sensor_hist := Sensors, hidden_hist := Hidden,
      uptake_hist := Rates} = world:snapshot(W),
    ?assertEqual(Pop, lists:sum(Sensors)),
    ?assertEqual(Pop, lists:sum(Hidden)),
    ?assertEqual(Pop, lists:sum(Rates)).

%% Bounded by the safety valves, so the lists are short and fixed-length however
%% elaborate anything gets, and cost a handful of integers a second.
the_bars_are_bounded_by_the_safety_valves_test() ->
    W = world:new(#{population => 5, radius => 3, max_sensors => 4,
                    max_hidden => 3}),
    #{sensor_hist := Sensors, hidden_hist := Hidden} = world:snapshot(W),
    ?assertEqual(5, length(Sensors)),
    ?assertEqual(4, length(Hidden)).

%% A FEEDING RATE RUNS TO HUNDREDS, so a bar per value would be unreadable. Eight
%% buckets is enough to see a shape and few enough to draw on a card, and the top
%% one catches anything at the ceiling rather than losing it.
feeding_rates_are_drawn_in_buckets_test() ->
    Gentle = world:new(#{population => 8, radius => 3, ground_ceiling => 400,
                         founder_uptake => 10}),
    #{uptake_hist := Low} = world:snapshot(Gentle),
    ?assertEqual(8, length(Low)),
    ?assertEqual(8, hd(Low)),
    Voracious = world:new(#{population => 8, radius => 3,
                            ground_ceiling => 400, founder_uptake => 400}),
    #{uptake_hist := High} = world:snapshot(Voracious),
    ?assertEqual(8, lists:last(High)).

%% Zeroes rather than a short list for an empty world, so a reader plotting bars
%% gets a flat chart instead of a gap it has to interpret.
an_empty_world_has_empty_bars_test() ->
    W = world:tick(quiet(maps:merge(#{population => 1, ground_seed => 0,
                                      ground_growth_pct => 0,
                                      ground_ceiling => 0, metabolism => 30,
                                      start_energy => 20}, inert())), 5),
    #{population := Pop, sensor_hist := Sensors} = world:snapshot(W),
    ?assertEqual(0, Pop),
    ?assertEqual(0, lists:sum(Sensors)),
    ?assert(length(Sensors) > 1).

%%==============================================================================
%% What it costs to be large
%%==============================================================================

%% THE FREE GOOD WORLD 5 PRICES. Metabolism was flat: one creature carrying ten
%% thousand paid exactly what one carrying ten paid, so energy was armour and
%% armour was free. That is why world 4's feeding tradeoff was overridden, since
%% large creatures win contests and 97% of deaths are being eaten.
holding_energy_costs_by_the_unit_test() ->
    Cost = fun(Energy, Divisor) ->
                   W = quiet(maps:merge(#{ground_seed => 0,
                                          ground_growth_pct => 0,
                                          ground_ceiling => 0, metabolism => 0,
                                          sensor_rent => 0, hidden_rent => 0,
                                          max_age => 100000,
                                          start_energy => Energy,
                                          upkeep_divisor => Divisor},
                                        inert())),
                   books(W) - books(world:tick(W))
           end,
    %% Eight hundred to start is four hundred of STRUCTURE, and only structure
    %% is billed: five a tick at a divisor of eighty. What a creature carries is
    %% nearly free to hold, which is what fat is for.
    ?assertEqual(5, Cost(800, 80)),
    %% Twice the frame, twice the bill.
    ?assertEqual(10, Cost(1600, 80)),
    %% A gentler divisor costs less for the same frame.
    ?assertEqual(2, Cost(800, 160)).

%% AND A STORE IS NOT BILLED AT ALL, which is the whole of world 6. Two creatures
%% with the same frame pay the same however differently they are provisioned, so
%% they can once more be unlike one another. World 5 taxed the reserve as though
%% it were tissue and flattened every difference between them.
carrying_a_store_is_nearly_free_test() ->
    Cost = fun(Store) ->
                   W = quiet(maps:merge(#{ground_seed => 0,
                                          ground_growth_pct => 0,
                                          ground_ceiling => 0, metabolism => 0,
                                          sensor_rent => 0, hidden_rent => 0,
                                          max_age => 100000,
                                          start_energy => Store,
                                          upkeep_divisor => 1000000},
                                        inert())),
                   books(W) - books(world:tick(W))
           end,
    ?assertEqual(0, Cost(200)),
    ?assertEqual(0, Cost(20000)).

%% It is charged ON TOP of everything else rather than instead of it.
holding_is_charged_beside_the_other_costs_test() ->
    W = quiet(maps:merge(#{ground_seed => 0, ground_growth_pct => 0,
                           ground_ceiling => 0, metabolism => 7,
                           sensor_rent => 0, hidden_rent => 0,
                           max_age => 100000, start_energy => 400,
                           upkeep_divisor => 100}, inert())),
    %% Seven to exist, and two for the two hundred of frame that four hundred
    %% starting energy leaves after the half-split.
    ?assertEqual(books(W) - 9, books(world:tick(W))).

%% A creature already in debt is about to be reaped, and billing it for a
%% negative balance would HAND IT ENERGY rather than take any.
a_creature_in_debt_is_not_paid_to_carry_it_test() ->
    W = quiet(maps:merge(#{ground_seed => 0, ground_growth_pct => 0,
                           ground_ceiling => 0, metabolism => 500,
                           sensor_rent => 0, hidden_rent => 0,
                           start_energy => 100, upkeep_divisor => 10},
                         inert())),
    Totals = [books(world:tick(W, N)) || N <- lists:seq(0, 4)],
    ?assertEqual(lists:reverse(lists:sort(Totals)), Totals).

%% STRUCTURE IS BOUNDED, and without this nothing else about world 5 or 6 can be
%% read. A creature that keeps building climbs until its frame costs what it
%% earns, and stops.
%%
%% It has to be a BUILDER to show this. Before world 6 the test could use an
%% inert creature, because everything it held was billed; now a store is free, so
%% one that never converts would simply accumulate for ever and the test would
%% measure nothing.
structure_stops_climbing_where_upkeep_meets_income_test() ->
    W = quiet(maps:merge(#{ground_seed => 8, ground_growth_pct => 0,
                           ground_ceiling => 8, metabolism => 0,
                           sensor_rent => 0, hidden_rent => 0,
                           max_age => 1000000, start_energy => 2,
                           upkeep_divisor => 50, founder_uptake => 8},
                         builder(100))),
    #{structure_max := Early} = world:snapshot(world:tick(W, 300)),
    #{structure_max := Late} = world:snapshot(world:tick(W, 3000)),
    ?assert(Early > 100),
    ?assertEqual(Early, Late).

%% A CONTEST IS DECIDED BY FRAME AND NOT BY PROVISIONS. A fat small creature
%% loses to a lean large one, which before world 6 was not expressible at all:
%% hoarding and being formidable were the same number.
the_leaner_larger_creature_takes_the_fatter_smaller_one_test() ->
    W = quiet(maps:merge(#{population => 1, radius => 0, ground_seed => 0,
                           ground_growth_pct => 0, ground_ceiling => 0,
                           metabolism => 0, sensor_rent => 0, hidden_rent => 0,
                           max_age => 100000, start_energy => 201,
                           brain_mutation => 0,
                           brain_mutation_structural => 1000000,
                           body_mutation => 1000000}, fertile())),
    %% The parent keeps the odd unit of frame, so it is the larger and takes the
    %% child back, and the whole world is unchanged by the taking.
    #{population := P, consumed := C} = world:snapshot(world:tick(W, 2)),
    ?assertEqual(1, C),
    ?assertEqual(2, P),
    ?assertEqual(books(W), books(world:tick(W, 2))).

%% The largest alive and the shape of the sizes, because a mean cannot tell one
%% optimum from two and "bounded" cannot be read from an average at all.
size_is_reported_as_a_largest_and_a_shape_test() ->
    W = world:tick(world:new(#{population => 30, radius => 6, seed => 4}), 100),
    #{population := Pop, energy_max := Max, energy_hist := Bars} =
        world:snapshot(W),
    ?assert(Max > 0),
    ?assertEqual(Pop, lists:sum(Bars)),
    ?assertEqual(8, length(Bars)).

%% An empty world has no largest creature, rather than a crash or a stale one.
an_empty_world_has_no_largest_creature_test() ->
    W = world:tick(quiet(maps:merge(#{ground_seed => 0, ground_growth_pct => 0,
                                      ground_ceiling => 0, metabolism => 30,
                                      start_energy => 20}, inert())), 5),
    #{population := Pop, energy_max := Max} = world:snapshot(W),
    ?assertEqual(0, Pop),
    ?assertEqual(0, Max).

%%==============================================================================
%% Capacity bounds MEAT too, which is world 10
%%==============================================================================

%% WORLD 8'S RULE ARRIVING AT THE SITE IT MISSED. Grazing has been bounded by
%% `min(uptake, frame, cell)' since world 8; predation was bounded by nothing at
%% all, so a creature that could sip its frame's worth from the ground could
%% swallow an unlimited number of unlimited-size victims in the same tick.
%%
%% Radius 0 is one cell, so parent and child stand together and the parent, which
%% keeps its whole frame since world 9, always wins. `founder_uptake' is set to a
%% number far below what the child is worth, which is what makes the bound
%% visible: without it the parent's own frame would be the binding term and the
%% test would pass for the wrong reason.
a_predator_takes_only_what_its_body_can_hold_test() ->
    W = world:tick(hungry(200, 10), 2),
    #{energy_max := Store, consumed := Eaten} = world:snapshot(W),
    %% The child is worth 50 and the parent can take 10 of it.
    ?assertEqual(1, Eaten),
    ?assert(Store =< 60).

%% AND WHAT IT CANNOT HOLD IS A CORPSE. Conservation forces this rather than
%% anyone choosing it: the energy has to go somewhere and the only place is the
%% ground it died on. The ground starts and stays at nothing in this fixture, so
%% anything found there was left by the kill.
a_kill_leaves_carrion_on_the_ground_test() ->
    Before = world:snapshot(world:tick(hungry(200, 10), 1)),
    After  = world:snapshot(world:tick(hungry(200, 10), 2)),
    ?assertEqual(0, maps:get(ground_total, Before)),
    ?assert(maps:get(ground_total, After) > 0).

%% AND THE BOOKS STILL CLOSE OVER IT. A cap that dropped the remainder instead of
%% burying it would destroy energy and read as a perfectly healthy world.
eating_only_part_of_a_victim_conserves_the_rest_test() ->
    W = hungry(200, 10),
    ?assertEqual(closed_books(W), closed_books(world:tick(W, 2))).

%% A parent that will breed, in a single cell, feeding at a chosen rate.
hungry(Energy, Uptake) ->
    quiet(maps:merge(#{population => 1, radius => 0, ground_seed => 0,
                       ground_growth_pct => 0, ground_ceiling => 0,
                       metabolism => 0, sensor_rent => 0, hidden_rent => 0,
                       max_age => 100000, brain_mutation => 0,
                       brain_mutation_structural => 1000000,
                       body_mutation => 1000000, uptake_mutation => 0,
                       founder_uptake => Uptake,
                       start_energy => Energy}, fertile())).

%%==============================================================================
%% Feeding belongs to a creature, not to a contest, which is world 11
%%==============================================================================

%% ONLY THE WINNER ATE. `absorb' ran for the strongest creature in a cell and for
%% nobody else, so anything that tied with it survived the contest and then did
%% not feed at all. Sharing a cell with an equal cost a creature its entire meal.
%%
%% ASSERTED ON THE EXACT AMOUNT, because the first version of this test asserted
%% only that the pair gained SOMETHING, which one eater satisfies as easily as
%% two. It passed with the fix reverted, which makes it not a test.
%%
%% Two identical founders on one cell, uptake 30 against a frame of 200, so each
%% may draw exactly 30 and neither can eat the other.
everyone_left_standing_in_a_cell_eats_test() ->
    #{absorbed := Fed} = world:snapshot(world:tick(crowded(), 1)),
    ?assertEqual(60, Fed).

%% AND THE WINNER ATE TWICE. World 8 bounds grazing by min(uptake, frame) and
%% world 10 bounds meat by the same expression; applied independently they let a
%% creature that made a kill take its body's worth of meat AND its body's worth
%% of ground in the same tick.
%%
%% `absorbed' counts GROUND intake alone, which is the exact quantity the second
%% helping was made of. A parent whose whole capacity went on its child must draw
%% nothing from the cell it is standing on, however much is there.
a_kill_does_not_buy_a_second_helping_test() ->
    Bred = world:tick(hungry(200, 10), 1),
    #{absorbed := Before} = world:snapshot(Bred),
    #{absorbed := After, consumed := Eaten} = world:snapshot(world:tick(Bred, 1)),
    ?assertEqual(1, Eaten),
    ?assertEqual(Before, After).

crowded() ->
    quiet(maps:merge(#{population => 2, radius => 0, ground_seed => 0,
                       ground_growth_pct => 0, ground_ceiling => 5000,
                       metabolism => 0, sensor_rent => 0, hidden_rent => 0,
                       max_age => 100000, uptake_mutation => 0,
                       founder_uptake => 30, start_energy => 400}, inert())).

%%==============================================================================
%% Speed, and what it costs to be heavy, which is world 12
%%==============================================================================

%% A CREATURE GOES AS FAR AS IT CAN PAY TO GO. Everything moved exactly one cell
%% per tick before, at the same speed for everyone, which is why flight did not
%% exist: movement is simultaneous, so an adjacent predator could never be
%% outrun and prey had no strategy but being larger.
%%
%% THAT CLAIM IS ASSERTED OVER TEN TICKS in
%% `moving_costs_over_and_above_existing_test' above, and deliberately not over
%% one: a walk ends as soon as nothing is preferred to here, and on a uniform
%% board every cell ties, so a single tick is a coin toss rather than a
%% measurement.

%% AND CARRYING A BODY COSTS, or the speed would be a free good handed to the
%% large. A big creature is rich, so without this it would be big AND fast and
%% size would dominate harder than before. The fare is `move_cost' plus the same
%% expression that prices holding a frame, so hauling and holding cost alike.
%%
%% Two creatures, identical but for their bodies, on an empty board: the heavier
%% one gets less far for the same fare.
a_heavier_creature_pays_more_for_the_same_ground_test() ->
    Spent = fun(Energy) ->
                    W = quiet(maps:merge(#{ground_seed => 0,
                                           ground_growth_pct => 0,
                                           metabolism => 0, move_cost => 5,
                                           sensor_rent => 0, hidden_rent => 0,
                                           max_age => 100000,
                                           upkeep_divisor => 10,
                                           start_energy => Energy}, restless())),
                    #{dissipated := D} = world:snapshot(world:tick(W, 1)),
                    D
            end,
    %% A founder is half store and half frame, so the larger founding is the
    %% heavier creature. Same number of cells crossed would cost it more.
    ?assert(Spent(800) > Spent(80)).

%% A WALK ENDS RATHER THAN LOOPING. Two cells that each prefer the other would
%% trade a creature back and forth until it had burned its whole body, so a
%% creature will not re-enter a cell it has already stood in this tick. Nothing
%% may be in the same place twice in one moment.
%%
%% Asserted as the world still advancing at all: a walk that did not terminate
%% would hang here rather than fail.
a_walk_terminates_test() ->
    W = quiet(maps:merge(#{ground_seed => 0, ground_growth_pct => 0,
                           metabolism => 0, move_cost => 1, sensor_rent => 0,
                           hidden_rent => 0, max_age => 100000,
                           population => 6, radius => 2,
                           start_energy => 100000}, restless())),
    #{tick := T, population := P} = world:snapshot(world:tick(W, 20)),
    ?assertEqual(20, T),
    ?assert(P > 0).
