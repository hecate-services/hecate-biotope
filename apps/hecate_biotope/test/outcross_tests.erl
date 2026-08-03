-module(outcross_tests).

-include_lib("eunit/include/eunit.hrl").

%%==============================================================================
%% Aligning two bodies
%%==============================================================================

%% THE SECOND GROUND SENSOR IN ONE PARENT IS THE SECOND GROUND SENSOR IN THE
%% OTHER, and rank is what makes that true. Position is an accident of the order
%% mutations happened to arrive in: a parent that grew scent before ground has
%% them at positions 1 and 2, and one that grew them the other way round has the
%% same two organs at 2 and 1.
rank_not_position_is_what_aligns_test() ->
    A = outcross:ranked([{ground, 0}, {scent, 1}]),
    B = outcross:ranked([{scent, 2}, {ground, 3}]),
    %% Same two organs, opposite positions, and the map says so.
    ?assertEqual(lists:sort(maps:keys(A)), lists:sort(maps:keys(B))),
    ?assertEqual({1, 0}, maps:get({ground, 0}, A)),
    ?assertEqual({2, 3}, maps:get({ground, 0}, B)).

a_body_can_carry_the_same_field_twice_test() ->
    M = outcross:ranked([{ground, 0}, {ground, 2}, {scent, 1}]),
    ?assertEqual({1, 0}, maps:get({ground, 0}, M)),
    ?assertEqual({2, 2}, maps:get({ground, 1}, M)),
    ?assertEqual({3, 1}, maps:get({scent, 0}, M)).

an_empty_body_ranks_to_nothing_test() ->
    ?assertEqual(#{}, outcross:ranked([])).

%%==============================================================================
%% The shape of a child, which is the whole engineering risk
%%==============================================================================

%% ⚠ EVERY WEIGHT VECTOR MUST MATCH THE CHILD'S OWN BODY, and this is the one
%% bug here that would not crash. `brain.erl' says it about mutation and calls it
%% the main engineering risk of world 2; recombination is that risk with two
%% genomes. A hidden row one column short does not fail, it silently values the
%% ground as though it were a scent.
%%
%% Run over many random pairs, because the failure needs a particular combination
%% of differing bodies, differing hidden counts and a dropped node to appear.
every_child_is_internally_consistent_test() ->
    lists:foreach(fun check_pair/1, lists:seq(1, 400)).

check_pair(Seed) ->
    Rng0 = rand:seed_s(exsss, {Seed, Seed * 7, Seed * 13}),
    {A, Rng1} = a_creature(Rng0),
    {B, Rng2} = a_creature(Rng1),
    {Child, _Rng} = outcross:traits(A, B, econ(), Rng2),
    consistent(Child).

consistent(#{body := Body, brain := #{hidden := Hidden, outputs := Outputs}}) ->
    Inputs = length(Body) + 1,
    Nodes = length(Hidden),
    %% A hidden row reads every input AND every node's last-tick activation:
    %% `sensors + 1 + nodes' since world 21. An output reads inputs and this
    %% tick's nodes, and deliberately not memory.
    [?assertEqual(Inputs + Nodes, length(Row)) || Row <- Hidden],
    %% Every output reads every input AND every hidden node.
    lists:foreach(fun(#{inputs := Ins, hidden := Hids}) ->
                          ?assertEqual(Inputs, length(Ins)),
                          ?assertEqual(Nodes, length(Hids))
                  end, maps:values(Outputs)),
    %% And the body itself is sensors the world recognises.
    lists:foreach(fun({F, R}) ->
                          ?assert(lists:member(F, body:fields())),
                          ?assert(R >= 0)
                  end, Body).

%% A CHILD CARRIES NOTHING NEITHER PARENT HAD. Recombination shuffles; it does
%% not invent. Anything new must come from the mutation that runs afterwards, or
%% the two are confounded and world 20 cannot be told from a change to the
%% mutation operator.
nothing_arrives_that_neither_parent_carried_test() ->
    lists:foreach(fun no_invention/1, lists:seq(1, 200)).

no_invention(Seed) ->
    Rng0 = rand:seed_s(exsss, {Seed, Seed * 3, Seed * 11}),
    {A, Rng1} = a_creature(Rng0),
    {B, Rng2} = a_creature(Rng1),
    {#{body := Body, brain := #{hidden := H}}, _Rng} =
        outcross:traits(A, B, econ(), Rng2),
    Between = fields_of(A) ++ fields_of(B),
    lists:foreach(fun({F, _R}) -> ?assert(lists:member(F, Between)) end, Body),
    %% Nor more hidden nodes than the better-endowed parent had.
    ?assert(length(H) =< max(nodes_of(A), nodes_of(B))).

fields_of(#{body := Body}) -> [F || {F, _R} <- Body].
nodes_of(#{brain := #{hidden := H}}) -> length(H).

%% TWO IDENTICAL PARENTS MUST PRODUCE THEIR OWN GENOME. Every coin is then a
%% choice between two identical things, so recombination is a no-op, and if it
%% is not then something is being lost or invented in the copying itself.
%%
%% The fixture's body is in canonical order for the reason the next test
%% explains: a child's is, and a parent's need not be.
two_identical_parents_make_a_copy_test() ->
    A = creature([{creatures, 1}, {ground, 0}, {scent, 2}],
                 [[1, 2, 3, 4, 5, 6], [5, 6, 7, 8, 9, 1]],
                 #{move => #{inputs => [1, 1, 1, 1], hidden => [2, 3]},
                   eat => #{inputs => [4, 0, 4, 0], hidden => [0, 1]}}),
    {Child, _Rng} = outcross:traits(A, A, econ(), rand:seed_s(exsss, {5, 5, 5})),
    ?assertEqual(maps:get(body, A), maps:get(body, Child)),
    ?assertEqual(maps:get(brain, A), maps:get(brain, Child)).

%% ⚠ AN OUTCROSSED CHILD'S BODY COMES OUT IN CANONICAL ORDER, and that is a real
%% side effect worth stating rather than discovering later.
%%
%% Alignment is done on `{Field, Rank}' and the child is built by walking those
%% keys sorted, so a parent whose sensors arrived in the order mutation happened
%% to add them has a child whose sensors are in field order. **The creature is
%% unchanged**: every weight column is permuted with its sensor, so it measures
%% the same things and values them identically. Only the order it lists them in
%% is different, and nothing in the world reads that order except the brain,
%% which was permuted to match.
a_childs_sensors_come_out_in_a_canonical_order_test() ->
    Jumbled = creature([{scent, 1}, {ground, 0}],
                       [[7, 3, 9, 4]],
                       #{move => #{inputs => [7, 3, 9], hidden => [1]}}),
    {#{body := Body, brain := #{hidden := [Row]}}, _Rng} =
        outcross:traits(Jumbled, Jumbled, econ(), rand:seed_s(exsss, {2, 2, 2})),
    ?assertEqual([{ground, 0}, {scent, 1}], Body),
    %% The ground weight was second and is now first, carried with its sensor.
    %% `here' belongs to no sensor so it does not move, and the memory weight for
    %% the single node follows it.
    ?assertEqual([3, 7, 9, 4], Row).

%% A WEIGHT FOR AN ORGAN THE PARENT NEVER HAD IS ZERO, not random and not
%% borrowed. The same rule `brain:follow_body/2' uses when mutation grows a
%% sensor: the child begins by ignoring what it can newly perceive.
a_borrowed_organ_arrives_unattended_test() ->
    %% One parent measures the ground and nothing else; the other measures scent
    %% and nothing else, with a weight of 5 on it.
    %% One sensor, one node, so a hidden row is [sensor, here, memory].
    A = creature([{ground, 0}], [[3, 9, 2]], #{move => #{inputs => [3, 9],
                                                        hidden => [1]}}),
    B = creature([{scent, 0}], [[5, 9, 2]], #{move => #{inputs => [5, 9],
                                                       hidden => [1]}}),
    {#{body := Body, brain := #{outputs := Os}}, _Rng} =
        outcross:traits(A, B, econ(), rand:seed_s(exsss, {1, 2, 3})),
    #{move := #{inputs := Ins}} = Os,
    ?assertEqual(length(Body) + 1, length(Ins)),
    %% Whichever parent's output was taken, it can only have a non-zero weight
    %% on the field that parent actually carried. So at most one sensor weight
    %% is non-zero however the coins fell.
    Sensors = lists:droplast(Ins),
    ?assert(length([W || W <- Sensors, W =/= 0]) =< 1).

%% ⚠ THE SAME PAIR AND THE SAME RNG MUST GIVE THE SAME CHILD. `G.6' is what
%% happens when a draw takes its order from a map: nineteen worlds in which the
%% same seed did not give the same world. This file iterates four fields, ranks,
%% node indexes and four purposes, all in fixed order, and never a map.
the_same_parents_and_seed_give_the_same_child_test() ->
    Rng0 = rand:seed_s(exsss, {9, 9, 9}),
    {A, Rng1} = a_creature(Rng0),
    {B, Rng2} = a_creature(Rng1),
    ?assertEqual(outcross:traits(A, B, econ(), Rng2),
                 outcross:traits(A, B, econ(), Rng2)).

%% Bodies grow only through mutation, so recombination must respect the valve
%% too: a child of two well-equipped parents cannot exceed it by taking the
%% union.
a_child_cannot_exceed_the_safety_valve_test() ->
    Wide = [{creatures, 1}, {ground, 1}, {scent, 1}, {self, 1}],
    A = creature(Wide, [], #{}),
    B = creature([{creatures, 2}, {ground, 2}, {scent, 2}, {self, 2}], [], #{}),
    Econ = maps:merge(econ(), #{max_sensors => 2}),
    {#{body := Body}, _Rng} =
        outcross:traits(A, B, Econ, rand:seed_s(exsss, {4, 4, 4})),
    ?assert(length(Body) =< 2).

%%==============================================================================
%% Fixtures
%%==============================================================================

econ() -> world:defaults().

%% A creature with a random body and a brain that matches it, which is the only
%% kind the world ever holds.
a_creature(Rng0) ->
    {Body, Rng1} = body:founder(econ(), Rng0),
    {Brain, Rng2} = brain:founder(length(Body), econ(), Rng1),
    {#{body => Body, brain => Brain, scent => 7, uptake => 40, mouth => 20},
     Rng2}.

creature(Body, Hidden, Outputs) ->
    #{body => Body, brain => #{hidden => Hidden, outputs => Outputs},
      scent => 1, uptake => 10, mouth => 10}.
