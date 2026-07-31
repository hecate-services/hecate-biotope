%% @doc The decider, asserted rather than assumed.
%%
%% The claim these defend is narrow and load bearing: a brain is a FUNCTION of
%% its weights and its senses, with no hidden state and no clock, so two
%% creatures with the same weights in the same situation do the same thing. Every
%% later statement about selection depends on that, because a decision that
%% varied for reasons outside the weights could not be inherited and could not be
%% selected for.
-module(brain_tests).

-include_lib("eunit/include/eunit.hrl").

econ() -> world:defaults().

rng() -> rand:seed_s(exsss, {1, 2, 3}).

%% Rows are graze, hunt, rest, each of four sense weights then a bias.
only(graze) -> [0,0,0,0,1,  0,0,0,0,0,  0,0,0,0,0];
only(hunt)  -> [0,0,0,0,0,  0,0,0,0,1,  0,0,0,0,0];
only(rest)  -> [0,0,0,0,0,  0,0,0,0,0,  0,0,0,0,1].

blind() -> [0, 0, 0, 0].

%%==============================================================================
%% Shape
%%==============================================================================

%% One row per action, one weight per sense plus a bias. Asserted against the
%% two modules that define those counts rather than against 15, so that widening
%% either one fails here instead of silently misaligning the rows.
a_brain_has_a_row_per_action_test() ->
    ?assertEqual(length(brain:actions()) * (body:sense_width() + 1),
                 brain:size()),
    {Brain, _} = brain:founder(econ(), rng()),
    ?assertEqual(brain:size(), length(Brain)).

founding_weights_are_within_range_test() ->
    Range = maps:get(brain_range, econ()),
    {Brain, _} = brain:founder(econ(), rng()),
    ?assert(lists:all(fun(W) -> W >= -Range andalso W =< Range end, Brain)).

%%==============================================================================
%% Deciding
%%==============================================================================

the_bias_decides_when_nothing_is_perceived_test() ->
    ?assertEqual(graze, brain:decide(only(graze), blind())),
    ?assertEqual(hunt, brain:decide(only(hunt), blind())),
    ?assertEqual(rest, brain:decide(only(rest), blind())).

%% THE POINT OF HAVING SENSES AT ALL. The same brain must be able to reach two
%% different decisions, or it is a constant with extra steps and no organ could
%% ever be worth its upkeep.
%%
%% This brain rests by default and hunts when the fattest neighbour is fat: the
%% hunt row weights the third sense, and it takes a big enough neighbour to beat
%% the resting bias.
the_same_brain_decides_differently_on_different_senses_test() ->
    Opportunist = [0,0,0,0,0,   0,0,1,0,0,   0,0,0,0,3],
    ?assertEqual(rest, brain:decide(Opportunist, [0, 0, 0, 0])),
    ?assertEqual(rest, brain:decide(Opportunist, [0, 1, 2, 0])),
    ?assertEqual(hunt, brain:decide(Opportunist, [0, 1, 9, 0])).

%% Every decision is one of the three, whatever the weights and senses. A brain
%% that could return something else would be an action the world cannot perform.
every_decision_is_an_action_test() ->
    {Brains, _} = lists:mapfoldl(fun(_I, R) -> brain:founder(econ(), R) end,
                                 rng(), lists:seq(1, 50)),
    Senses = [[P, C, F, O] || P <- [0, 7], C <- [0, 6], F <- [0, 15], O <- [0, 15]],
    Decisions = [brain:decide(B, S) || B <- Brains, S <- Senses],
    ?assert(lists:all(fun(D) -> lists:member(D, brain:actions()) end, Decisions)).

%% No hidden state, no clock. Asked twice, answers twice the same.
deciding_is_a_function_test() ->
    {Brain, _} = brain:founder(econ(), rng()),
    Senses = [3, 2, 7, 4],
    ?assertEqual(brain:decide(Brain, Senses), brain:decide(Brain, Senses)).

%%==============================================================================
%% Inheritance
%%==============================================================================

%% A CHILD IS ITS PARENT PLUS A NUDGE, and the size of the nudge is the whole
%% difference between inheritance and resampling. If a child could land anywhere
%% in weight space then lineages would not exist, selection would have nothing to
%% accumulate, and every generation would start over.
a_child_brain_is_within_one_mutation_of_its_parent_test() ->
    Econ = maps:merge(econ(), #{brain_mutation => 1}),
    {Parent, R0} = brain:founder(Econ, rng()),
    {Child, _} = brain:inherit(Parent, Econ, R0),
    Drift = [abs(P - C) || {P, C} <- lists:zip(Parent, Child)],
    ?assert(lists:all(fun(D) -> D =< 1 end, Drift)).

%% Zero mutation is cloning, which makes the trait a constant. Worth asserting
%% because it is the control condition for any claim that weights moved.
zero_mutation_clones_test() ->
    Econ = maps:merge(econ(), #{brain_mutation => 0}),
    {Parent, R0} = brain:founder(Econ, rng()),
    {Child, _} = brain:inherit(Parent, Econ, R0),
    ?assertEqual(Parent, Child).

%% Bounded, so a long lineage cannot drift to weights that swamp every sense and
%% turn the brain back into a constant that ignores the world.
inheritance_respects_the_range_test() ->
    Econ = maps:merge(econ(), #{brain_range => 2, brain_mutation => 3}),
    Maxed = lists:duplicate(brain:size(), 2),
    {Child, _} = brain:inherit(Maxed, Econ, rng()),
    ?assert(lists:all(fun(W) -> W >= -2 andalso W =< 2 end, Child)).

%% Over many births the nudges must go both ways. A mutation that only ever
%% added would push every lineage to the ceiling and call the drift evolution.
mutation_moves_weights_in_both_directions_test() ->
    Econ = maps:merge(econ(), #{brain_mutation => 1}),
    Parent = lists:duplicate(brain:size(), 0),
    {Children, _} = lists:mapfoldl(fun(_I, R) -> brain:inherit(Parent, Econ, R) end,
                                   rng(), lists:seq(1, 40)),
    Weights = lists:append(Children),
    ?assert(lists:member(-1, Weights)),
    ?assert(lists:member(1, Weights)).
