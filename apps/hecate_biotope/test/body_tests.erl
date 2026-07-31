%% @doc What a creature is built from, asserted.
%%
%% The claim these defend: an organ is the ONLY thing standing between a brain
%% and a fact about the world, and it charges rent for standing there. Both
%% halves matter. Without the gating an organ is decoration; without the rent
%% every lineage keeps every organ and the population is uniform forever.
-module(body_tests).

-include_lib("eunit/include/eunit.hrl").

econ() -> world:defaults().

rng() -> rand:seed_s(exsss, {4, 5, 6}).

%% A neighbourhood with something for every sense to find, so a zero in the
%% output can only be a missing organ.
busy() ->
    #{plants_near => 5, creatures_near => 3, fattest_near => 200,
      own_energy => 120}.

%%==============================================================================
%% Perceiving
%%==============================================================================

%% Order is the brain's input order and is a contract between the two modules.
%% If it ever changed silently, every evolved brain in every running world would
%% keep its weights and start reading the wrong columns.
a_full_body_perceives_everything_test() ->
    ?assertEqual([5, 3, 10, 6], body:senses([eye, gut, nose], busy())).

%% A MISSING ORGAN READS AS ZERO, NOT AS A SHORTER VECTOR. Fixed width means a
%% brain never has to be resized when a body mutates, which is what makes it
%% possible for a child with a different body to inherit its parent's brain.
a_bare_body_perceives_nothing_test() ->
    ?assertEqual([0, 0, 0, 0], body:senses([], busy())),
    ?assertEqual(body:sense_width(), length(body:senses([], busy()))).

the_eye_gates_plants_test() ->
    ?assertEqual([5, 0, 0, 0], body:senses([eye], busy())).

%% One organ, two senses: how many are near and how fat the fattest is. They are
%% the same faculty, and splitting them would let a lineage smell prey without
%% being able to tell a meal from a corpse.
the_nose_gates_both_creature_senses_test() ->
    ?assertEqual([0, 3, 10, 0], body:senses([nose], busy())).

%% PROPRIOCEPTION IS THE SUBTLE ONE. Without it a brain cannot condition on its
%% own hunger, so "graze while comfortable, take the risk when desperate" is
%% unavailable, and that is the simplest strategy here that is not a fixed role.
the_gut_gates_own_energy_test() ->
    ?assertEqual([0, 0, 0, 6], body:senses([gut], busy())).

%% Scaled down and clamped, so brain weights can stay in a range a human can read
%% and a mutation of one is a nudge rather than a rounding error. A creature
%% carrying four hundred and one carrying six hundred are the same situation.
energies_are_scaled_and_clamped_test() ->
    Rich = #{plants_near => 0, creatures_near => 0, fattest_near => 100000,
             own_energy => 100000},
    ?assertEqual([0, 0, 15, 15], body:senses([eye, gut, nose], Rich)).

%% Energy can be negative for a creature about to be reaped, and a negative sense
%% would flip the meaning of every weight reading it.
a_starving_creature_perceives_no_negative_energy_test() ->
    Broke = #{plants_near => 0, creatures_near => 0, fattest_near => -50,
              own_energy => -30},
    ?assertEqual([0, 0, 0, 0], body:senses([eye, gut, nose], Broke)).

%%==============================================================================
%% Paying for it
%%==============================================================================

upkeep_is_charged_per_organ_test() ->
    Econ = maps:merge(econ(), #{organ_upkeep => 3}),
    ?assertEqual(0, body:upkeep([], Econ)),
    ?assertEqual(3, body:upkeep([eye], Econ)),
    ?assertEqual(9, body:upkeep([eye, gut, nose], Econ)).

%%==============================================================================
%% Inheritance
%%==============================================================================

%% Founders are spread for the same reason breeding thresholds are: a population
%% that starts as one body plan hands selection nothing until mutation slowly
%% invents variety, and the early ticks are spent watching a monoculture drift.
founding_bodies_vary_test() ->
    {Bodies, _} = lists:mapfoldl(fun(_I, R) -> body:founder(econ(), R) end,
                                 rng(), lists:seq(1, 40)),
    ?assert(length(lists:usort(Bodies)) > 1).

founding_bodies_only_contain_real_organs_test() ->
    {Bodies, _} = lists:mapfoldl(fun(_I, R) -> body:founder(econ(), R) end,
                                 rng(), lists:seq(1, 40)),
    Seen = lists:usort(lists:append(Bodies)),
    ?assertEqual([], Seen -- body:organs()).

%% ONE ORGAN AT A TIME. Morphology is coarser than preference, and a body that
%% changed wholesale every generation would never be around long enough for a
%% brain to adapt to it.
a_child_body_differs_by_at_most_one_organ_test() ->
    Econ = maps:merge(econ(), #{body_mutation => 1}),
    {Children, _} = lists:mapfoldl(
                      fun(_I, R) -> body:inherit([eye, gut], Econ, R) end,
                      rng(), lists:seq(1, 40)),
    Diffs = [length(([eye, gut] -- C) ++ (C -- [eye, gut])) || C <- Children],
    ?assert(lists:all(fun(D) -> D =< 1 end, Diffs)).

%% GAINING AND LOSING SHARE ONE PROBABILITY, so nothing here pushes bodies to
%% grow more complex on their own. A mutation that only added organs would
%% produce ever fatter creatures and let us call the drift adaptation.
mutation_both_adds_and_removes_test() ->
    Econ = maps:merge(econ(), #{body_mutation => 1}),
    {Children, _} = lists:mapfoldl(
                      fun(_I, R) -> body:inherit([gut], Econ, R) end,
                      rng(), lists:seq(1, 60)),
    ?assert(lists:member([], Children)),
    ?assert(lists:any(fun(C) -> length(C) =:= 2 end, Children)).

%% A body is compared, counted and fingerprinted, so two spellings of the same
%% creature must not be two creatures.
bodies_stay_sorted_test() ->
    Econ = maps:merge(econ(), #{body_mutation => 1}),
    {Children, _} = lists:mapfoldl(
                      fun(_I, R) -> body:inherit([nose], Econ, R) end,
                      rng(), lists:seq(1, 40)),
    ?assert(lists:all(fun(C) -> C =:= lists:sort(C) end, Children)).

%%==============================================================================
%% Reading a population
%%==============================================================================

%% THE ANSWER TO "DOES THIS ORGAN PAY". Prevalence falling means upkeep exceeds
%% what the organ earns in this world, which is a finding about the world.
prevalence_counts_each_organ_test() ->
    Bodies = [[eye], [eye, nose], [], [eye, gut, nose]],
    ?assertEqual(#{eye => 3, gut => 1, nose => 2}, body:prevalence(Bodies)).

%% Zeroes rather than missing keys, so a reader plotting prevalence over time
%% gets a line at zero instead of a gap it has to interpret.
prevalence_of_nothing_is_zeroes_test() ->
    ?assertEqual(#{eye => 0, gut => 0, nose => 0}, body:prevalence([])).
