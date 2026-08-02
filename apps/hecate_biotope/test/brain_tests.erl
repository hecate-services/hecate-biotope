%% @doc The decider, asserted.
%%
%% Two claims. That a brain is a FUNCTION of its weights and what its body
%% measured, with no hidden state and no clock, because a decision varying for
%% reasons outside the weights could not be inherited or selected. And that the
%% weights stay in step with the sensors and the hidden nodes, which is the one
%% bug here that does not crash and is therefore the one most heavily asserted.
-module(brain_tests).

-include_lib("eunit/include/eunit.hrl").

econ() -> world:defaults().
rng() -> rand:seed_s(exsss, {1, 2, 3}).
with(Overrides) -> maps:merge(econ(), Overrides).

%% A brain with no hidden layer and one output, over one sensor plus `here'.
flat(Weights) ->
    #{hidden => [], outputs => #{move => #{inputs => Weights, hidden => []}}}.

%%==============================================================================
%% Valuing a place
%%==============================================================================

%% A WEIGHT IS WHAT A MEASUREMENT IS WORTH, AND ITS SIGN IS EVERYTHING. Positive
%% is attraction and negative avoidance, through one mechanism. That is why
%% fleeing needs no rule of its own: it is predation's weight with a minus in
%% front, and neither word appears in the code.
a_weight_values_and_its_sign_reverses_test() ->
    ?assertEqual(#{move => 15}, brain:evaluate(flat([3, 0]), [5, 0], econ())),
    ?assertEqual(#{move => -15}, brain:evaluate(flat([-3, 0]), [5, 0], econ())).

%% `here' is an ordinary input rather than a special case, and it is why staying
%% put is expressible: movement costs and standing still does not, so a creature
%% that cannot tell where it already is cannot be sedentary on purpose.
the_here_input_distinguishes_the_cell_it_stands_on_test() ->
    Brain = flat([0, 7]),
    ?assertEqual(#{move => 7}, brain:evaluate(Brain, [4, 1], econ())),
    ?assertEqual(#{move => 0}, brain:evaluate(Brain, [4, 0], econ())).

%% AN ABSENT OUTPUT IS ABSENT, not zero. A creature with no `move' never moves
%% and one with no `breed' leaves no descendants, and the world has to be able to
%% tell that from an output that merely evaluated to nothing.
an_absent_output_is_simply_not_there_test() ->
    ?assertEqual(#{}, brain:evaluate(#{hidden => [], outputs => #{}}, [1],
                                     econ())),
    ?assertEqual(false, brain:has(move, #{hidden => [], outputs => #{}})),
    ?assertEqual(true, brain:has(move, flat([0, 0]))).

%% No hidden state, no clock. Asked twice, answers twice the same.
valuing_is_a_function_test() ->
    {Brain, _} = brain:founder(3, econ(), rng()),
    ?assertEqual(brain:evaluate(Brain, [3, 2, 7, 1], econ()),
                 brain:evaluate(Brain, [3, 2, 7, 1], econ())).

%%==============================================================================
%% The hidden layer, and why there is one
%%==============================================================================

%% THE WHOLE ARGUMENT FOR A HIDDEN LAYER, IN ONE TEST. Own energy is the same
%% number for all seven cells a creature can reach, so in a flat brain it adds
%% equally to every option and CANCELS IN THE COMPARISON. A linear brain cannot
%% act on self-knowledge however much it has, which is why world 1 had no
%% proprioception and would have gained nothing from any.
%%
%% Here the same `self' reading of 4 against two different cells produces the
%% same DIFFERENCE between them, whatever weight is put on it.
a_constant_input_cannot_change_a_flat_brains_ranking_test() ->
    Rich = flat([1, 0, 0]),
    Careful = flat([1, 5, 0]),
    Gap = fun(B) ->
                  #{move := A} = brain:evaluate(B, [8, 4, 0], econ()),
                  #{move := C} = brain:evaluate(B, [2, 4, 0], econ()),
                  A - C
          end,
    ?assertEqual(Gap(Rich), Gap(Careful)).

%% AND A HIDDEN NODE BREAKS THAT, which is the point. Rectification is not
%% linear, so a node combining self with what is in a cell contributes
%% differently to different cells and the ranking can depend on self after all.
%% The node weighs the cell POSITIVELY and self NEGATIVELY, so a small creature
%% keeps it above zero and a large one drives it below, where rectification
%% flattens it to nothing. A weight that merely added self would not do: the
%% divisor is integer, so a constant shifts both cells almost equally and the gap
%% survives. It is the CLIPPING that makes the ranking conditional, which is why
%% the nonlinearity and not the extra input is what buys this.
a_hidden_node_lets_self_knowledge_change_the_ranking_test() ->
    Conditional = #{hidden => [[1, -1, 0]],
                    outputs => #{move => #{inputs => [0, 0, 0],
                                           hidden => [1]}}},
    Gap = fun(Self) ->
                  #{move := A} = brain:evaluate(Conditional, [8, Self, 0], econ()),
                  #{move := C} = brain:evaluate(Conditional, [2, Self, 0], econ()),
                  A - C
          end,
    %% Small, it can tell the two cells apart. Large, both are rectified away and
    %% it stops caring which cell it is looking at.
    ?assert(Gap(0) > 0),
    ?assertEqual(0, Gap(60)).

%% max(0, x). Integer, monotone but not linear, and needing no libm, which keeps
%% a run bit-identical from its seed and the world probeable offline.
a_hidden_node_is_rectified_test() ->
    Negative = #{hidden => [[-8, 0]],
                 outputs => #{move => #{inputs => [0, 0], hidden => [1]}}},
    ?assertEqual(#{move => 0}, brain:evaluate(Negative, [60, 0], econ())).

%%==============================================================================
%% Founding
%%==============================================================================

%% Founders are drawn with a random number of hidden nodes and a random SUBSET of
%% what they could do, so the first generation already contains creatures drawn
%% to ground, drawn to flesh, disinclined to move, and some that cannot reproduce
%% at all. Selection has something to sort from the first tick.
founding_brains_vary_in_shape_test() ->
    {Brains, _} = lists:mapfoldl(fun(_I, R) -> brain:founder(2, econ(), R) end,
                                 rng(), lists:seq(1, 60)),
    Shapes = [{brain:hidden_count(B), brain:has(move, B), brain:has(breed, B)}
              || B <- Brains],
    ?assert(length(lists:usort(Shapes)) > 2).

founding_weights_are_within_range_test() ->
    Range = maps:get(brain_range, econ()),
    {Brain, _} = brain:founder(3, with(#{founder_max_hidden => 3}), rng()),
    Weights = lists:append(maps:get(hidden, Brain))
        ++ lists:append([maps:get(inputs, O) ++ maps:get(hidden, O)
                         || O <- maps:values(maps:get(outputs, Brain))]),
    ?assert(lists:all(fun(W) -> W >= -Range andalso W =< Range end, Weights)).

%%==============================================================================
%% Following the body, and the bug that does not crash
%%==============================================================================

still() -> with(#{brain_mutation => 0, brain_mutation_structural => 1000000}).

%% A GAINED SENSOR INSERTS ITS WEIGHT AT ITS OWN POSITION IN EVERY VECTOR THAT
%% READS IT, not at the end. Appending would shift every weight past the
%% insertion point onto a different measurement, and nothing would crash: the
%% creature would simply behave like a scrambled version of its parent.
%%
%% AND IT ARRIVES AT ZERO. A random weight makes growing a sensor a large jump in
%% an arbitrary direction, which is resampling and not inheritance. At zero the
%% child begins by ignoring what it can newly perceive and drift decides whether
%% to attend to it, which is the difference between an organ appearing and an
%% organ being adopted.
a_gained_sensor_inserts_a_zero_in_every_vector_test() ->
    Parent = #{hidden => [[5, 6, 9]],
               outputs => #{move => #{inputs => [1, 2, 3], hidden => [4]}}},
    {Child, _} = brain:inherit(Parent, {added, 2}, still(), rng()),
    ?assertEqual([[5, 0, 6, 9]], maps:get(hidden, Child)),
    ?assertEqual(#{inputs => [1, 0, 2, 3], hidden => [4]},
                 maps:get(move, maps:get(outputs, Child))).

a_lost_sensor_removes_its_column_from_every_vector_test() ->
    Parent = #{hidden => [[5, 6, 9]],
               outputs => #{move => #{inputs => [1, 2, 3], hidden => [4]}}},
    {Child, _} = brain:inherit(Parent, {dropped, 2}, still(), rng()),
    ?assertEqual([[5, 9]], maps:get(hidden, Child)),
    ?assertEqual(#{inputs => [1, 3], hidden => [4]},
                 maps:get(move, maps:get(outputs, Child))).

%% A NEW HIDDEN NODE COMPUTES SOMETHING AND NOTHING LISTENS TO IT. Its own input
%% weights are drawn so it is not inert, but every output weighs it at zero, so
%% the creature behaves exactly as its parent did until drift connects it. Same
%% argument as a new sensor: capacity appears first and is adopted later, or
%% never.
a_gained_hidden_node_is_listened_to_by_nobody_test() ->
    Grows = with(#{brain_mutation => 0, brain_mutation_structural => 1,
                   max_hidden => 6}),
    Parent = #{hidden => [], outputs => #{move => #{inputs => [1, 2],
                                                    hidden => []}}},
    {Children, _} = lists:mapfoldl(
                      fun(_I, R) -> brain:inherit(Parent, none, Grows, R) end,
                      rng(), lists:seq(1, 60)),
    Grown = [C || C <- Children, brain:hidden_count(C) =:= 1],
    ?assert(length(Grown) > 0),
    ?assert(lists:all(fun(C) ->
                              maps:get(hidden, maps:get(move,
                                                        maps:get(outputs, C)))
                                  =:= [0]
                      end, Grown)).

%% THE INVARIANT THAT MATTERS, stated directly: after any change, every vector
%% fits what it reads. A mismatch is the only bug here that stays silent.
every_vector_fits_after_any_change_test() ->
    Parent = #{hidden => [[1, 2, 3], [4, 5, 6]],
               outputs => #{move => #{inputs => [7, 8, 9], hidden => [1, 2]},
                            breed => #{inputs => [1, 1, 1], hidden => [3, 4]}}},
    Churn = with(#{brain_mutation => 1, brain_mutation_structural => 1}),
    Changes = [none, {added, 1}, {added, 3}, {dropped, 1}, {dropped, 3}],
    lists:foreach(fun(Change) -> fits(Parent, Change, Churn) end, Changes).

fits(Parent, Change, Econ) ->
    {Children, _} = lists:mapfoldl(
                      fun(_I, R) -> brain:inherit(Parent, Change, Econ, R) end,
                      rng(), lists:seq(1, 40)),
    lists:foreach(fun consistent/1, Children).

consistent(#{hidden := Hidden, outputs := Outputs}) ->
    Widths = lists:usort([length(Row) || Row <- Hidden]
                         ++ [length(maps:get(inputs, O))
                             || O <- maps:values(Outputs)]),
    ?assert(length(Widths) =< 1),
    lists:foreach(fun(O) ->
                          ?assertEqual(length(Hidden),
                                       length(maps:get(hidden, O)))
                  end, maps:values(Outputs)).

%% LOSING AN OUTPUT IS SURVIVABLE AND USUALLY TERRIBLE, which is the point. No
%% `move' means it never moves, which in this world is a living rather than a
%% death sentence. No `breed' means the lineage ends there, which is very strong
%% selection rather than a rule against it.
outputs_are_gained_and_lost_test() ->
    Churn = with(#{brain_mutation => 0, brain_mutation_structural => 1}),
    Parent = #{hidden => [], outputs => #{move => #{inputs => [1],
                                                    hidden => []}}},
    {Children, _} = lists:mapfoldl(
                      fun(_I, R) -> brain:inherit(Parent, none, Churn, R) end,
                      rng(), lists:seq(1, 90)),
    ?assert(lists:any(fun(C) -> not brain:has(move, C) end, Children)),
    ?assert(lists:any(fun(C) -> brain:has(breed, C) end, Children)).

%%==============================================================================
%% Attention
%%==============================================================================

%% A sensor's input is read by every hidden node and by every output, so what it
%% is WORTH to a creature is the sum of what all of them put on it. Zero means the
%% measurement is taken, paid for, and acted on by nothing.
attention_sums_every_vector_that_reads_a_column_test() ->
    Brain = #{hidden => [[3, 0, 0], [-2, 0, 0]],
              outputs => #{move => #{inputs => [1, 0, 0], hidden => [0, 0]}}},
    ?assertEqual([6, 0], brain:attention(Brain, 2)).

a_brain_with_nothing_in_it_attends_to_nothing_test() ->
    ?assertEqual([0, 0], brain:attention(#{hidden => [], outputs => #{}}, 2)).

%%==============================================================================
%% World 16: a thought is charged by how much it reads
%%==============================================================================

%% `hidden_count/1' counts NODES and `hidden_weights/1' counts WIRE. Until world
%% 16 the cost used the first, so a node reading six inputs cost what one reading
%% a single input cost. B.3 objected to exactly that and world 13 marked it
%% corrected while changing only how the charge was levied.
a_wider_thought_is_more_apparatus_test() ->
    Narrow = #{hidden => [[1, 2]], outputs => #{}},
    Wide = #{hidden => [[1, 2, 3, 4, 5, 6]], outputs => #{}},
    ?assertEqual(1, brain:hidden_count(Narrow)),
    ?assertEqual(1, brain:hidden_count(Wide)),
    ?assert(brain:hidden_weights(Wide) > brain:hidden_weights(Narrow)),
    ?assertEqual(6, brain:hidden_weights(Wide)).

%% AND THE TWO NUMBERS MUST STAY SEPARATE, because a brain getting cheaper and a
%% brain getting simpler look identical if you only have one of them.
depth_and_width_are_different_measurements_test() ->
    Deep = #{hidden => [[1], [1], [1]], outputs => #{}},
    Wide = #{hidden => [[1, 1, 1]], outputs => #{}},
    ?assertEqual(brain:hidden_weights(Deep), brain:hidden_weights(Wide)),
    ?assertNotEqual(brain:hidden_count(Deep), brain:hidden_count(Wide)).

a_brain_with_no_hidden_layer_is_no_apparatus_test() ->
    ?assertEqual(0, brain:hidden_weights(#{hidden => [], outputs => #{}})).

