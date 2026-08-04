-module(record_discoveries_tests).

-include_lib("eunit/include/eunit.hrl").

%%==============================================================================
%% What a discovery is
%%==============================================================================

%% ⚠ BUSINESS VERBS, NOT CRUD. Nothing here is created, updated or deleted. In a
%% year the only thing left will be these names and the numbers beside them, so
%% a name that says nothing costs more here than anywhere else in the codebase.
the_events_are_named_for_what_happened_test() ->
    Snap = snapshot(),
    Names = [maps:get(event_type, E)
             || E <- [discovery:seeded(Snap), discovery:found(7, 40, Snap),
                      discovery:settled(900, Snap), discovery:stirred(950, Snap),
                      discovery:ended(Snap)]],
    ?assertEqual([<<"world_seeded">>, <<"way_of_living_found">>,
                  <<"world_settled">>, <<"world_stirred">>, <<"world_ended">>],
                 Names),
    ?assertEqual([], [N || N <- Names,
                           binary:match(N, [<<"creat">>, <<"updat">>,
                                            <<"delet">>]) =/= nomatch]).

%% ONE STREAM PER RUN, NOT PER ISLAND. An island outlives its worlds and hosts
%% many; a run is the thing with a beginning, an end and a seed. Two islands
%% drawing the same seed are two streams.
a_run_gets_its_own_stream_test() ->
    A = discovery:stream_for(<<"beam01">>, 4242),
    B = discovery:stream_for(<<"beam01">>, 99),
    C = discovery:stream_for(<<"beam03">>, 4242),
    ?assertNotEqual(A, B),
    ?assertNotEqual(A, C),
    ?assertEqual(<<"biotope/beam01/4242">>, A).

%% A DISCOVERY CARRIES ITS OWN MEANING IN WORDS. A reader in a year has the
%% event and not necessarily the code that would decode a cell index, and `I.6'
%% is precisely what happens when an instrument and the thing it reads drift
%% apart with a wire between them.
a_discovery_says_what_it_means_without_the_code_test() ->
    #{data := Data} = discovery:found(124, 3000, snapshot()),
    ?assertEqual(124, maps:get(cell, Data)),
    ?assertEqual(3000, maps:get(first_seen_at, Data)),
    ?assertEqual(<<"hunts, always moving, crosses the island">>,
                 maps:get(means, Data)).

%% A DISCOVERY ONLY MEANS SOMETHING UNDER THE RULES THAT PRODUCED IT, so the
%% opening event carries the whole economy. `econ_id' alone cannot say which
%% world it was: world 6 changed the rules and not one constant, so two runs a
%% world apart share an id exactly.
the_opening_event_carries_the_whole_economy_test() ->
    #{data := Data} = discovery:seeded(snapshot()),
    ?assert(is_map(maps:get(economy, Data))),
    ?assert(map_size(maps:get(economy, Data)) > 20),
    ?assertEqual(maps:get(number, world:ruleset()), maps:get(world, Data)),
    ?assert(byte_size(maps:get(rules, Data)) > 20).

%% ⚠ EVERY EVENT IS BUILT FROM A REAL SNAPSHOT, NOT FROM A MAP WRITTEN HERE.
%%
%% `stream_for/1' used to take the snapshot and match on an `island' key.
%% `world:snapshot/1' has never had one: an island's name comes from the
%% environment and a world knows nothing about what is running it. It crashed on
%% the first live look on every node, in a function_clause the supervisor
%% restarted every five seconds, while the store sat open and empty.
%%
%% **The test passed**, because it handed the function a map containing `island'.
%% A fixture that agrees with my own function rather than with the island is
%% `C.6' and `B.7' in this project's register, both filed for precisely this, and
%% `world_facts' carries a paragraph about the last time it happened.
%%
%% So this feeds every constructor the real thing.
every_event_is_built_from_a_real_snapshot_test() ->
    Snap = snapshot(),
    ?assertNot(maps:is_key(island, Snap)),
    lists:foreach(fun(E) -> ?assert(is_map(maps:get(data, E))) end,
                  [discovery:seeded(Snap), discovery:found(3, 9, Snap),
                   discovery:settled(10, Snap), discovery:stirred(11, Snap),
                   discovery:ended(Snap)]).

%% Everything carries the tick, so a stream reads without being joined to
%% anything.
every_event_says_when_test() ->
    Snap = snapshot(),
    lists:foreach(fun(E) -> ?assert(is_integer(maps:get(tick, E))) end,
                  [discovery:seeded(Snap), discovery:found(1, 1, Snap),
                   discovery:ended(Snap)]).

%%==============================================================================
%% What is NOT recorded, which is most of it
%%==============================================================================

%% ⚠ THE VOLUME ARGUMENT, ASSERTED RATHER THAN TRUSTED. Births run about ten a
%% tick and deaths not far behind: recording those would be three million events
%% a day per island and would be a recording of the world rather than a record of
%% what it found.
%%
%% Discoveries are bounded by the size of the space: 125 ways of living, each
%% found once, plus a beginning and an end. This asserts the bound holds on a
%% real world rather than in an argument.
a_whole_run_is_a_few_hundred_events_test_() ->
    {timeout, 300,
     fun() ->
             W = world:tick(world:new(#{seed => 77, population => 40}), 4000),
             #{archive := Flat, born := Born, behaviour_space := Space} =
                 world:snapshot(W),
             Discoveries = length(Flat) div 3,
             %% What we DO write: bounded by the space, whatever the world does.
             ?assert(Discoveries =< Space),
             %% What we do NOT: four thousand ticks of this world produced tens
             %% of thousands of births.
             ?assert(Born > 10000),
             ?assert(Discoveries * 100 < Born)
     end}.

%%==============================================================================
%% It watches, and it never plays
%%==============================================================================

%% The same property the narrator has and for the same reason. Deleting this
%% slice would cost the record and not one creature's history.
keeping_a_record_cannot_change_the_world_test() ->
    Watched = watched(world:new(#{seed => 77, population => 20, radius => 5}),
                      120),
    Ignored = world:tick(world:new(#{seed => 77, population => 20, radius => 5}),
                         120),
    ?assertEqual(world:creatures(Ignored), world:creatures(Watched)).

watched(W, 0) -> W;
watched(W, N) ->
    Snap = world:snapshot(W),
    _Seeded = discovery:seeded(Snap),
    _Ended = discovery:ended(Snap),
    watched(world:tick(W, 1), N - 1).

snapshot() ->
    world:snapshot(world:tick(world:new(#{seed => 77, population => 20,
                                          radius => 5}), 120)).
