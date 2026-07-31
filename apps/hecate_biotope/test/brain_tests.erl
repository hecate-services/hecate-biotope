%% @doc The decider, asserted.
%%
%% The claim these defend is narrow and load bearing: a brain is a FUNCTION of
%% its weights and what its body measured, with no hidden state and no clock, so
%% two creatures with the same weights in the same place value it the same. Every
%% later statement about selection depends on that, because a decision that
%% varied for reasons outside the weights could not be inherited.
%%
%% AND: THE WEIGHTS MUST STAY IN STEP WITH THE SENSORS. That is the one bug here
%% that does not crash, so it is the one most heavily asserted.
-module(brain_tests).

-include_lib("eunit/include/eunit.hrl").

econ() -> world:defaults().

rng() -> rand:seed_s(exsss, {1, 2, 3}).

with(Overrides) -> maps:merge(econ(), Overrides).

%%==============================================================================
%% Shape
%%==============================================================================

%% One weight per sensor, and one more for staying put.
a_brain_has_a_weight_per_sensor_plus_one_test() ->
    ?assertEqual(1, brain:width(0)),
    ?assertEqual(4, brain:width(3)),
    {Brain, _} = brain:founder(3, econ(), rng()),
    ?assertEqual(4, length(Brain)).

%% A creature that measures nothing still has an opinion about whether to move,
%% and it must, because movement costs and staying does not.
a_body_that_measures_nothing_still_decides_test() ->
    {Brain, _} = brain:founder(0, econ(), rng()),
    ?assertEqual(1, length(Brain)),
    ?assert(is_integer(brain:value(Brain, [], true))).

founding_weights_are_within_range_test() ->
    Range = maps:get(brain_range, econ()),
    {Brain, _} = brain:founder(6, econ(), rng()),
    ?assert(lists:all(fun(W) -> W >= -Range andalso W =< Range end, Brain)).

%%==============================================================================
%% Valuing a place
%%==============================================================================

%% A WEIGHT IS WHAT A MEASUREMENT IS WORTH, AND ITS SIGN IS EVERYTHING. Positive
%% is attraction and negative is avoidance, through one mechanism. That is why
%% fleeing needs no rule of its own: it is predation's weight with a minus in
%% front, and neither word appears in the code.
a_weight_values_and_its_sign_reverses_test() ->
    Drawn = [3, 0],
    Repelled = [-3, 0],
    ?assertEqual(15, brain:value(Drawn, [5], false)),
    ?assertEqual(-15, brain:value(Repelled, [5], false)).

%% The staying weight applies to exactly one of the seven candidates: the cell
%% the creature is already standing on.
the_staying_weight_applies_only_where_it_stands_test() ->
    Brain = [0, 7],
    ?assertEqual(7, brain:value(Brain, [4], true)),
    ?assertEqual(0, brain:value(Brain, [4], false)).

%% NO BIAS TERM, because a constant added to every candidate alike cannot change
%% which is largest. The staying weight is not a bias: it is applied to one
%% candidate and not the others, which is the whole reason it can do anything.
several_measurements_all_count_test() ->
    Brain = [2, -1, 0, 5],
    ?assertEqual(2 * 10 - 1 * 3 + 0 * 15, brain:value(Brain, [10, 3, 15], false)),
    ?assertEqual(2 * 10 - 1 * 3 + 5, brain:value(Brain, [10, 3, 15], true)).

%% No hidden state, no clock. Asked twice, answers twice the same.
valuing_is_a_function_test() ->
    {Brain, _} = brain:founder(3, econ(), rng()),
    ?assertEqual(brain:value(Brain, [3, 2, 7], false),
                 brain:value(Brain, [3, 2, 7], false)).

%%==============================================================================
%% Inheriting
%%==============================================================================

%% A child is its parent plus a nudge. If a child could land anywhere in weight
%% space then lineages would not exist, selection would have nothing to
%% accumulate, and every generation would start over.
a_child_is_within_one_mutation_of_its_parent_test() ->
    E = with(#{brain_mutation => 1}),
    {Parent, R0} = brain:founder(4, E, rng()),
    {Child, _} = brain:inherit(Parent, none, E, R0),
    Drift = [abs(P - C) || {P, C} <- lists:zip(Parent, Child)],
    ?assert(lists:all(fun(D) -> D =< 1 end, Drift)).

zero_mutation_clones_test() ->
    E = with(#{brain_mutation => 0}),
    {Parent, R0} = brain:founder(4, E, rng()),
    {Child, _} = brain:inherit(Parent, none, E, R0),
    ?assertEqual(Parent, Child).

inheritance_respects_the_range_test() ->
    E = with(#{brain_range => 2, brain_mutation => 3}),
    Maxed = lists:duplicate(5, 2),
    {Child, _} = brain:inherit(Maxed, none, E, rng()),
    ?assert(lists:all(fun(W) -> W >= -2 andalso W =< 2 end, Child)).

mutation_moves_weights_both_ways_test() ->
    E = with(#{brain_mutation => 1}),
    {Children, _} = lists:mapfoldl(
                      fun(_I, R) -> brain:inherit([0, 0, 0], none, E, R) end,
                      rng(), lists:seq(1, 40)),
    Weights = lists:append(Children),
    ?assert(lists:member(-1, Weights)),
    ?assert(lists:member(1, Weights)).

%%==============================================================================
%% Following the body
%%==============================================================================

%% A GAINED SENSOR ADDS A WEIGHT AT ITS OWN POSITION, not at the end. Appending
%% would shift every weight after the insertion point onto a different
%% measurement, and nothing would crash: the creature would simply behave like a
%% scrambled version of its parent for reasons no test would name.
a_gained_sensor_inserts_its_weight_in_place_test() ->
    E = with(#{brain_mutation => 0}),
    {Child, _} = brain:inherit([5, 6, 9], {added, 2}, E, rng()),
    ?assertEqual([5, 0, 6, 9], Child).

%% NEW MEASUREMENTS ARRIVE IGNORED. A random weight would make growing a sensor a
%% large jump in a random direction, which is resampling rather than
%% inheritance. At zero the child starts by disregarding what it can now perceive
%% and drift decides over generations whether to attend to it. That is the
%% difference between an organ appearing and an organ being adopted.
a_gained_sensor_starts_unattended_test() ->
    E = with(#{brain_mutation => 0}),
    {Child, _} = brain:inherit([4, 4], {added, 1}, E, rng()),
    ?assertEqual([0, 4, 4], Child).

a_lost_sensor_removes_its_weight_test() ->
    E = with(#{brain_mutation => 0}),
    {Child, _} = brain:inherit([5, 6, 9], {dropped, 2}, E, rng()),
    ?assertEqual([5, 9], Child).

%% The invariant that matters, stated directly: after any change, the brain fits
%% the body it will steer. A mismatch is the only bug here that stays silent.
a_child_brain_always_fits_its_body_test() ->
    E = with(#{brain_mutation => 1}),
    Cases = [{[9, 9, 9], none, 3},
             {[9, 9, 9], {added, 1}, 4},
             {[9, 9, 9], {added, 3}, 4},
             {[9, 9, 9], {dropped, 1}, 2},
             {[9, 9, 9], {dropped, 3}, 2}],
    lists:foreach(
      fun({Parent, Change, Expected}) ->
              {Child, _} = brain:inherit(Parent, Change, E, rng()),
              ?assertEqual(Expected, length(Child))
      end, Cases).

%% And the same invariant through the world, where bodies and brains actually
%% mutate together. Reaching the end at all means no creature ever valued a cell
%% with a mismatched weight list, which would have crashed lists:zip.
bodies_and_brains_stay_in_step_through_a_run_test() ->
    W = world:tick(world:new(#{population => 30, seed => 17,
                               body_mutation => 1}), 400),
    #{population := Pop} = world:snapshot(W),
    ?assert(Pop >= 0).
