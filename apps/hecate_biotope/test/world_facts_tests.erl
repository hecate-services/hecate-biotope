%% @doc What goes on the wire, and the rules it has to obey.
%%
%% Each of these rules was earned by something that broke on this mesh before.
%% A tuple does not survive the encoder cleanly. An atom key and a binary key of
%% the same name collide into one, so a map carrying both ships two entries and
%% arrives with one.
-module(world_facts_tests).

-include_lib("eunit/include/eunit.hrl").

fact() ->
    world_facts:world_advanced(world:snapshot(world:new(#{population => 7})),
                               world_pace:from_map(#{})).

topic_is_namespaced_test() ->
    ?assertEqual(<<"biotope/world">>, world_facts:topic(world)).

namespace_is_settable_test() ->
    true = os:putenv("HECATE_BIOTOPE_NS", "island-3"),
    try
        ?assertEqual(<<"island-3/world">>, world_facts:topic(world))
    after
        os:unsetenv("HECATE_BIOTOPE_NS")
    end.

%% Atom keys only, and no tuple anywhere in the values.
obeys_the_wire_rules_test() ->
    F = fact(),
    ?assert(lists:all(fun is_atom/1, maps:keys(F))),
    ?assertEqual([], [V || V <- maps:values(F), is_tuple(V)]).

%% THE TICK IS NOT DECORATION. Publishing runs on wall clock and the world runs
%% on its own pace, so two consecutive facts may be one tick apart or a million.
%% Without it a reader cannot tell a stalled world from a slow one.
carries_the_tick_and_the_pace_test() ->
    #{tick := Tick, ticks_per_second := Rate} = fact(),
    ?assert(is_integer(Tick)),
    ?assertEqual(10, Rate).

%% Totals, not rates: a rate is recoverable from two totals and a total is not
%% recoverable from rates, so a reader that misses a fact can still catch up.
carries_totals_rather_than_rates_test() ->
    F = fact(),
    lists:foreach(fun(K) -> ?assert(is_integer(maps:get(K, F))) end,
                  [born, starved, aged_out, eaten, births_refused,
                   population, plants, energy_total]).

reports_its_own_version_test() ->
    #{type := Type, fact_version := V} = fact(),
    ?assertEqual(world_advanced, Type),
    ?assertEqual(1, V).
