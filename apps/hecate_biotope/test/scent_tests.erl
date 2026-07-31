%% @doc Signatures, asserted.
%%
%% The claim these defend: a creature reads a trail by how UNLIKE itself it is,
%% and that single rule has to do two jobs. It must make a creature's own mark
%% invisible, which is what stops a hunter pacing its own footprints, and it must
%% make its children's marks nearly invisible too, which is the kin blindness the
%% whole increment exists to test.
-module(scent_tests).

-include_lib("eunit/include/eunit.hrl").

econ() -> world:defaults().

rng() -> rand:seed_s(exsss, {7, 8, 9}).

always() -> maps:merge(econ(), #{scent_mutation => 1}).
never() -> maps:merge(econ(), #{scent_mutation => 1000000}).

%%==============================================================================
%% Comparing
%%==============================================================================

nothing_is_stranger_to_itself_test() ->
    ?assertEqual(0, scent:strangeness(0, 0)),
    ?assertEqual(0, scent:strangeness(2#10110011, 2#10110011)).

%% Every component differs. Eight bits, so eight is the ceiling and the scale
%% every reading is divided by.
opposites_are_maximally_strange_test() ->
    ?assertEqual(scent:bits(), scent:strangeness(0, 255)),
    ?assertEqual(scent:bits(), scent:strangeness(2#10101010, 2#01010101)).

one_flipped_component_is_one_step_test() ->
    ?assertEqual(1, scent:strangeness(2#00000000, 2#00000001)),
    ?assertEqual(3, scent:strangeness(2#00000000, 2#00001011)).

%% Smelling is mutual: if you are a stranger to me I am a stranger to you. A
%% one-way version would let a lineage hunt another without ever being hunted
%% back, which is a rule nothing in this world should be able to buy.
strangeness_is_mutual_test() ->
    Pairs = [{A, B} || A <- [0, 7, 90, 255], B <- [0, 7, 90, 255]],
    ?assert(lists:all(fun({A, B}) ->
                              scent:strangeness(A, B) =:= scent:strangeness(B, A)
                      end, Pairs)).

%%==============================================================================
%% Reading a mark
%%==============================================================================

%% THE SELF-CHECK, NOW A CONSEQUENCE RATHER THAN A SPECIAL CASE. Before the
%% signature existed this needed its own branch, and without it a hunter followed
%% its own trail backward and killed less than one that wandered blind.
your_own_mark_reads_as_nothing_test() ->
    ?assertEqual(0, scent:perceived({30, 2#11001100}, 2#11001100)).

a_strangers_mark_reads_at_full_strength_test() ->
    ?assertEqual(30, scent:perceived({30, 255}, 0)).

%% KIN ARE NEARLY INVISIBLE, and that is the whole hypothesis. A child differs
%% from its parent by at most one component, so a parent tracking its own
%% offspring perceives an eighth of what it would perceive of a stranger.
a_childs_mark_reads_faint_test() ->
    ?assertEqual(1, scent:perceived({8, 2#00000001}, 2#00000000)),
    ?assertEqual(4, scent:perceived({8, 2#00001111}, 2#00000000)).

%% Strength still matters: a faint stranger and a strong cousin can read alike,
%% so a nose reports one number and cannot tell recency from kinship.
strength_and_strangeness_both_count_test() ->
    Faint = scent:perceived({8, 255}, 0),
    Stale = scent:perceived({64, 2#00000001}, 0),
    ?assertEqual(Faint, Stale).

%%==============================================================================
%% Inheriting
%%==============================================================================

founding_signatures_vary_test() ->
    {Tags, _} = lists:mapfoldl(fun(_I, R) -> scent:founder(econ(), R) end,
                               rng(), lists:seq(1, 40)),
    ?assert(length(lists:usort(Tags)) > 1).

founding_signatures_fit_in_their_bits_test() ->
    {Tags, _} = lists:mapfoldl(fun(_I, R) -> scent:founder(econ(), R) end,
                               rng(), lists:seq(1, 60)),
    Ceiling = 1 bsl scent:bits(),
    ?assert(lists:all(fun(T) -> T >= 0 andalso T < Ceiling end, Tags)).

%% ONE COMPONENT AT A TIME, so a lineage drifts and intermediate degrees of
%% kinship exist. A signature redrawn at random each generation would make every
%% creature a stranger to its own parent, which is not heredity.
a_child_differs_by_at_most_one_component_test() ->
    {Children, _} = lists:mapfoldl(
                      fun(_I, R) -> scent:inherit(2#01101001, always(), R) end,
                      rng(), lists:seq(1, 40)),
    Steps = [scent:strangeness(2#01101001, C) || C <- Children],
    ?assert(lists:all(fun(S) -> S =:= 1 end, Steps)).

a_rare_mutation_usually_clones_test() ->
    {Children, _} = lists:mapfoldl(
                      fun(_I, R) -> scent:inherit(2#01101001, never(), R) end,
                      rng(), lists:seq(1, 40)),
    ?assert(lists:all(fun(C) -> C =:= 2#01101001 end, Children)).

%% Mutation reaches every component rather than worrying at one, or a lineage
%% could only ever drift along a single axis of the signature space.
mutation_reaches_every_component_test() ->
    {Children, _} = lists:mapfoldl(
                      fun(_I, R) -> scent:inherit(0, always(), R) end,
                      rng(), lists:seq(1, 200)),
    ?assertEqual(scent:bits(), length(lists:usort(Children))).

%% Drift accumulates: enough generations and a descendant is a stranger to its
%% own ancestor, which is what makes two separated lineages trackable at all.
drift_accumulates_over_generations_test() ->
    Descend = fun(_G, {Tag, R0}) -> scent:inherit(Tag, always(), R0) end,
    {Far, _} = lists:foldl(Descend, {0, rng()}, lists:seq(1, 40)),
    ?assert(scent:strangeness(0, Far) > 1).

%%==============================================================================
%% Information content
%%==============================================================================

%% A PROPERTY OF THE SIGNAL, NOT OF WHAT EVOLVED. This is the measure the
%% mutation rate is chosen by, and it exists because the rate was once chosen by
%% which value produced the diet we hoped for, which installs the result.
a_population_of_one_smell_carries_nothing_test() ->
    ?assertEqual(0, scent:spread([9, 9, 9, 9, 9])).

%% Every component differs between the two halves, so every pair is maximally
%% strange and the spread is the whole range.
two_opposite_camps_carry_everything_test() ->
    ?assertEqual(100, scent:spread([0, 255])),
    ?assertEqual(100, scent:spread([2#11110000, 2#00001111])).

%% Independent signatures differ in half their components, which is why 50 is the
%% baseline the mutation rate is measured against rather than 100.
unrelated_signatures_sit_near_the_halfway_baseline_test() ->
    {Tags, _} = lists:mapfoldl(fun(_I, R) -> scent:founder(econ(), R) end,
                               rand:seed_s(exsss, {11, 12, 13}),
                               lists:seq(1, 400)),
    Spread = scent:spread(Tags),
    ?assert(Spread > 45),
    ?assert(Spread < 55).

%% Too small to have a pair: zero rather than a crash or a nonsense average, so a
%% dying world reports a dead signal instead of failing to report.
a_population_too_small_to_compare_carries_nothing_test() ->
    ?assertEqual(0, scent:spread([])),
    ?assertEqual(0, scent:spread([42])).

%% Counted per component rather than per pair, so the two must agree. This is the
%% only assertion that the O(N) trick computes the O(N^2) answer.
spread_agrees_with_comparing_every_pair_test() ->
    Tags = [3, 200, 17, 17, 96, 255, 8, 129],
    Pairs = [scent:strangeness(A, B)
             || {A, I} <- lists:zip(Tags, lists:seq(1, length(Tags))),
                {B, J} <- lists:zip(Tags, lists:seq(1, length(Tags))), I < J],
    Expected = lists:sum(Pairs) * 100 div (scent:bits() * length(Pairs)),
    ?assertEqual(Expected, scent:spread(Tags)).
