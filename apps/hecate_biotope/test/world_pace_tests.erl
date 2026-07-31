%% @doc Pacing: two numbers that cover both a world you watch and one you search.
-module(world_pace_tests).

-include_lib("eunit/include/eunit.hrl").

defaults_are_watchable_test() ->
    P = world_pace:from_map(#{}),
    ?assertEqual(10, world_pace:ticks_per_second(P)),
    ?assertEqual(1000, maps:get(publish_ms, P)).

%% An unset key falls back; a set key wins. `undefined' means unset rather than
%% zero, because a slot of zero is a legitimate setting meaning "yield and come
%% straight back", and collapsing the two would make the fastest pace
%% unreachable.
unset_keys_fall_back_test() ->
    P = world_pace:from_map(#{ticks_per_slot => undefined, slot_ms => 50}),
    ?assertEqual(1, maps:get(ticks_per_slot, P)),
    ?assertEqual(50, maps:get(slot_ms, P)).

%% The same two numbers reach both ends of the range, which is the whole reason
%% there is no mode switch.
one_mechanism_spans_watch_and_search_test() ->
    Watch  = world_pace:from_map(#{ticks_per_slot => 1, slot_ms => 100}),
    Search = world_pace:from_map(#{ticks_per_slot => 1000, slot_ms => 1}),
    ?assertEqual(10, world_pace:ticks_per_second(Watch)),
    ?assertEqual(1000000, world_pace:ticks_per_second(Search)).

a_zero_slot_still_reports_a_rate_test() ->
    P = world_pace:from_map(#{ticks_per_slot => 500, slot_ms => 0}),
    ?assertEqual(500000, world_pace:ticks_per_second(P)).

%% A typo in a pacing variable must not run at the default and report success.
%% The env is read at boot, so an error here is a service that refuses to start
%% rather than one that quietly ignores its configuration.
an_unparseable_env_value_is_an_error_test() ->
    Var = "HECATE_BIOTOPE_SLOT_MS",
    true = os:putenv(Var, "quickly"),
    try
        ?assertError({not_an_integer, Var, "quickly"}, world_pace:from_env())
    after
        os:unsetenv(Var)
    end.
