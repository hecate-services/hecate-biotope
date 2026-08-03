-module(behaviour_tests).

-include_lib("eunit/include/eunit.hrl").

%%==============================================================================
%% What a creature did, as against what it is
%%==============================================================================

%% ⚠ THE WHOLE POINT: TWO CREATURES OF ONE ARCHITECTURE CAN LIVE DIFFERENTLY.
%% `world:kind_of/1' would call these identical, because they are: same body,
%% same brain. One grazed where it was born and one hunted its way across the
%% island, and until now nothing this project measured could tell them apart.
one_architecture_two_ways_of_living_test() ->
    Grazer = did(#{from_ground => 900, from_creatures => 0, moved => 0,
                   age => 100, at => {0, 0}, origin => {0, 0}}),
    Hunter = did(#{from_ground => 0, from_creatures => 900, moved => 100,
                   age => 100, at => {0, 18}, origin => {0, 0}}),
    ?assertNotEqual(Grazer, Hunter),
    ?assertEqual({0, 0, 0}, Grazer),
    ?assertEqual({4, 4, 4}, Hunter).

%% NOTHING IN THE PHYSICS NAMES A PREDATOR and this does not either. The trophic
%% axis is counted afterwards from where the energy actually came from, which is
%% the same discipline `from_creatures_pct' has used since world 3.
the_trophic_axis_is_counted_and_not_declared_test() ->
    Half = did(#{from_ground => 500, from_creatures => 500, moved => 0,
                 age => 10, at => {0, 0}, origin => {0, 0}}),
    ?assertMatch({2, _, _}, Half).

%% MOVING AND TRAVELLING ARE DIFFERENT THINGS and the pair is what says which. A
%% creature can move every single tick and end up where it started, which is
%% foraging inside a patch, or move rarely and cross the island, which is
%% dispersal. One axis could not tell those apart.
moving_and_travelling_come_apart_test() ->
    Busy = did(#{from_ground => 1, from_creatures => 0, moved => 100,
                 age => 100, at => {0, 0}, origin => {0, 0}}),
    Wanderer = did(#{from_ground => 1, from_creatures => 0, moved => 10,
                     age => 100, at => {0, 20}, origin => {0, 0}}),
    ?assertMatch({_, 4, 0}, Busy),
    ?assertMatch({_, 0, 4}, Wanderer).

%% A NEWBORN HAS DONE NOTHING AND SAYS SO, rather than dividing by a zero age and
%% landing somewhere arbitrary. It has eaten nothing, moved nowhere and travelled
%% no distance, and the origin of the space is the true answer rather than a
%% convenient one.
a_newborn_has_done_nothing_test() ->
    ?assertEqual({0, 0, 0},
                 did(#{from_ground => 0, from_creatures => 0, moved => 0,
                       age => 0, at => {3, 3}, origin => {3, 3}})).

%% The cell index and the triple are the same statement, and a page that shows
%% words has to decode the index the way it was encoded. `I.6' with a legend
%% attached is a reader drawing a grazer where a hunter is.
the_index_and_the_triple_agree_test() ->
    lists:foreach(
      fun(Cell) ->
              Words = behaviour:describe(Cell),
              ?assert(byte_size(Words) > 0)
      end, lists:seq(0, 124)),
    Hunter = #{from_ground => 0, from_creatures => 900, moved => 100,
               age => 100, at => {0, 18}, origin => {0, 0}},
    ?assertEqual(124, behaviour:cell(Hunter, 20)),
    ?assertEqual(<<"hunts, always moving, crosses the island">>,
                 behaviour:describe(124)),
    ?assertEqual(<<"grazes, sessile, stays where it was born">>,
                 behaviour:describe(0)).

%% Bins are even and cover the range without a gap or an overlap, because a bin
%% scheme chosen to make a result look tidy is the shape of `I.3'.
the_bins_cover_the_range_test() ->
    Trophic = fun(Pct) ->
                      {T, _M, _D} =
                          did(#{from_ground => 100 - Pct, from_creatures => Pct,
                                moved => 0, age => 1, at => {0, 0},
                                origin => {0, 0}}),
                      T
              end,
    Seen = [Trophic(P) || P <- lists:seq(0, 100)],
    ?assertEqual(lists:seq(0, behaviour:bins() - 1), lists:usort(Seen)),
    ?assertEqual(0, Trophic(0)),
    ?assertEqual(behaviour:bins() - 1, Trophic(100)).

%%==============================================================================
%% The archive
%%==============================================================================

%% AN ARCHIVE IS THE REPLACEMENT FOR A FITNESS CURVE. A world with no objective
%% cannot say a run improved, only what changed, so what it CAN say is how much
%% of the space of ways-of-living it has found.
a_world_records_the_ways_of_living_it_finds_test() ->
    W = world:tick(world:new(#{seed => 55, population => 40}), 400),
    #{explored := Explored, behaviour_space := Space, frontier := Frontier,
      archive := Flat, archive_stride := Stride} = world:snapshot(W),
    ?assertEqual(125, Space),
    ?assert(Explored > 0),
    ?assert(Explored =< Space),
    ?assertEqual(3, Stride),
    ?assertEqual(Explored * 3, length(Flat)),
    ?assert(lists:all(fun is_integer/1, Flat)),
    %% Early in a world every cell found is newly found.
    ?assertEqual(Explored, Frontier).

%% ⚠ THE ARCHIVE ONLY GROWS AND THE FRONTIER DOES NOT, which is the whole reason
%% both are reported. A total can only rise, so a world that stopped discovering
%% last night would still report a large `explored' and look healthy. The
%% frontier is what goes to zero.
%% A GENERATOR WITH ITS OWN BUDGET, because this has to run past the thousand
%% ticks the frontier window is measured over and eunit allows five seconds.
the_frontier_is_a_window_and_the_archive_is_not_test_() ->
    {timeout, 300,
     fun() ->
             Early = world:tick(world:new(#{seed => 55, population => 40}), 400),
             Late = world:tick(Early, 2000),
             #{explored := E1} = world:snapshot(Early),
             #{explored := E2, frontier := F2} = world:snapshot(Late),
             ?assert(E2 >= E1),
             ?assert(F2 =< E2)
     end}.

%% NOTHING SELECTS ON IT. MAP-Elites keeps the best per cell and BREEDS from it;
%% this records the best per cell and breeds from nothing. A creature still
%% reproduces when its own brain says so, so an archive that were deleted
%% entirely would change no creature's behaviour and no world's outcome.
the_archive_changes_nothing_test() ->
    A = world:tick(world:new(#{seed => 7, population => 20, radius => 5}), 150),
    B = world:tick(world:new(#{seed => 7, population => 20, radius => 5}), 150),
    ?assertEqual(world:creatures(A), world:creatures(B)).

%% ⚠ THE ELITE IS A HISTORICAL MAXIMUM AND `depth' IS A LIVING ONE, and the first
%% version of this test asserted the elite could never exceed the depth. It can,
%% routinely: a lineage reaches generation fifty and dies out, and the deepest
%% creature alive afterwards is at forty. **That gap is the archive doing its
%% job** — recording something the live census structurally cannot, because the
%% census only ever describes what is currently breathing.
%%
%% So the property is that the elite never falls while depth may.
the_elite_remembers_what_the_census_forgets_test_() ->
    {timeout, 300,
     fun() ->
             Early = world:tick(world:new(#{seed => 55, population => 40}), 600),
             Late = world:tick(Early, 1200),
             #{deepest_elite := E1} = world:snapshot(Early),
             #{deepest_elite := E2} = world:snapshot(Late),
             ?assert(E2 >= E1)
     end}.

did(C) -> behaviour:of_creature(C, 20).
