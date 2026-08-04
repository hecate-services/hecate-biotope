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
%% Historical marking, which is what makes two nodes the same node
%%==============================================================================

%% ⚠ THE CLAIM MARKS EXIST TO MAKE TRUE. Two cousins that both inherited a node
%% from a common ancestor share its mark, so recombination treats their weights
%% for it as the SAME weight and mixes them. Before marks, this file's own
%% comment read: "a hidden node has no name, so it is aligned by index and
%% nothing else ... perception recombines by organ, computation only by
%% position."
%%
%% Here the shared node sits at DIFFERENT POSITIONS in the two parents, so index
%% alignment would pair it with the wrong node in both directions.
a_shared_node_is_recognised_wherever_it_sits_test() ->
    %% Mother: her own node 9, then the shared node 4.
    Mother = marked([{ground, 0}], [[1, 0, 0, 0], [2, 0, 0, 0]], [9, 4],
                    #{move => #{inputs => [1, 0], hidden => [5, 6]}}),
    %% Father: the shared node 4 first, then his own node 7.
    Father = marked([{ground, 0}], [[2, 0, 0, 0], [3, 0, 0, 0]], [4, 7],
                    #{move => #{inputs => [1, 0], hidden => [8, 9]}}),
    {#{brain := #{marks := Marks, outputs := Os}}, _Rng} =
        outcross:traits(Mother, Father, econ(), rand:seed_s(exsss, {1, 1, 1})),
    %% Mark 4 is carried by both, so the child is guaranteed to have it; 7 and 9
    %% are one parent's alone and are coins.
    ?assert(lists:member(4, Marks)),
    ?assertEqual(lists:usort(Marks), Marks),
    %% AND THE OUTPUT'S WEIGHT FOR IT IS THE HOMOLOGOUS ONE. Mother holds mark 4
    %% SECOND and weighs it 6; father holds it FIRST and weighs it 8. Whichever
    %% output the child took, its weight for mark 4 is that parent's weight for
    %% MARK 4 and not for whatever happened to sit at the same index. Aligning by
    %% index would have given 5 or 9, which are the weights for two unrelated
    %% nodes that merely share a position.
    #{move := #{hidden := Hids}} = Os,
    Weight = lists:nth(index_of(4, Marks), Hids),
    ?assert(Weight =:= 6 orelse Weight =:= 8),
    ?assert(Weight =/= 5 andalso Weight =/= 9).

%% A MARK IS NEVER REUSED, so two nodes grown in different lineages are never
%% mistaken for one. The counter is per world and monotone.
%%
%% ⚠ AND THE FIXTURE IS ASSERTED, because `lists:foreach' over an empty world
%% passes and says nothing. World 23 killed seed 77 down to ONE creature and this
%% test went on passing, having checked a single brain.
%% ⚠ Wrapped: ticks a live world, and eunit's default timeout is five seconds.
marks_are_handed_out_once_and_never_returned_test_() ->
    {timeout, 300,
     fun() ->
        W = world:tick(world:new(#{seed => 101, population => 40}), 300),
        All = [brain:marks(maps:get(brain, C))
               || C <- maps:values(world:creatures(W))],
        ?assert(length(All) > 20),
        %% Within any one brain a mark appears at most once: a node is one node.
        lists:foreach(fun(M) -> ?assertEqual(lists:usort(M), lists:sort(M)) end,
                      All)
     end}.

%% ⚠ AND THE TWO LISTS STAY THE SAME LENGTH. `marks' runs parallel to `hidden'
%% rather than being fused into it, which is cheap and is exactly the shape of
%% bug this project keeps hitting. Only four operations change the node count and
%% this asserts all four kept step, over a whole live world.
%% ⚠ Wrapped: ticks a live world, and eunit's default timeout is five seconds.
a_brain_has_exactly_one_mark_per_node_test_() ->
    {timeout, 300,
     fun() ->
        W = world:tick(world:new(#{seed => 101, population => 40}), 400),
        ?assert(maps:size(world:creatures(W)) > 20),
        lists:foreach(
          fun(C) ->
                  Brain = maps:get(brain, C),
                  ?assertEqual(length(maps:get(hidden, Brain)),
                               length(brain:marks(Brain)))
          end, maps:values(world:creatures(W)))
     end}.

marked(Body, Hidden, Marks, Outputs) ->
    #{body => Body,
      brain => #{hidden => Hidden, marks => Marks, outputs => Outputs},
      scent => 1, uptake => 10, mouth => 10}.

index_of(X, List) -> length(lists:takewhile(fun(Y) -> Y =/= X end, List)) + 1.

%%==============================================================================

econ() -> world:defaults().

%% A creature with a random body and a brain that matches it, which is the only
%% kind the world ever holds.
a_creature(Rng0) ->
    {Body, Rng1} = body:founder(econ(), Rng0),
    {Brain, _Mark, Rng2} = brain:founder(length(Body), 1, econ(), Rng1),
    {#{body => Body, brain => Brain, scent => 7, uptake => 40, mouth => 20},
     Rng2}.

%% A BRAIN CARRIES A MARK PER NODE since historical marking, so a hand-built one
%% has to as well or it is not a brain this world could have produced. Marks are
%% handed out here in node order, which is what a founder's are.
creature(Body, Hidden, Outputs) ->
    #{body => Body,
      brain => #{hidden => Hidden, marks => lists:seq(1, length(Hidden)),
                 outputs => Outputs},
      scent => 1, uptake => 10, mouth => 10}.
