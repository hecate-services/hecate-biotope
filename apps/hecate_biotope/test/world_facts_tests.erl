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
                  [born, starved, aged_out, consumed, plants_eaten,
                   births_refused, population, plants, energy_total,
                   from_creatures_pct, sensor_mean, scent_tags, scent_spread]).

%% VERSION 2 BECAUSE THE CONTRACT CHANGED MATERIALLY. The world was rebuilt to
%% remove biology from its physics, so `eaten' became `plants_eaten', `killed'
%% became `consumed', and the herbivore and carnivore buckets were replaced by
%% `from_creatures_pct' and a sensor census. A spectator pinned to version 1
%% would silently read fields that no longer mean what they did.
reports_its_own_version_test() ->
    #{type := Type, fact_version := V} = fact(),
    ?assertEqual(world_advanced, Type),
    ?assertEqual(2, V).

%%==============================================================================
%% The chart
%%==============================================================================

chart() ->
    world_facts:world_charted(world:chart(world:new(#{population => 7,
                                                     radius => 5})),
                              world_pace:from_map(#{})).

chart_topic_is_its_own_test() ->
    ?assertEqual(<<"biotope/chart">>, world_facts:topic(chart)),
    ?assertNotEqual(world_facts:topic(world), world_facts:topic(chart)).

%% Flat integers with a stride of two. A pair would be a tuple, and tuples do not
%% survive this encoder; a map per entity would repeat two keys a hundred and
%% seventy times a frame for no information.
positions_are_flat_integer_pairs_test() ->
    #{creatures := Cs, plants := Ps, stride := Stride} = chart(),
    ?assertEqual(2, Stride),
    ?assert(lists:all(fun is_integer/1, Cs ++ Ps)),
    ?assertEqual(0, length(Cs) rem 2),
    ?assertEqual(0, length(Ps) rem 2),
    ?assertEqual(7 * 2, length(Cs)).

%% A viewer sizes its board from the fact rather than from configuration it would
%% have to keep in agreement with a world it cannot see.
chart_carries_the_radius_test() ->
    ?assertMatch(#{radius := 5}, chart()).

chart_obeys_the_wire_rules_test() ->
    F = chart(),
    ?assert(lists:all(fun is_atom/1, maps:keys(F))),
    ?assertEqual([], [V || V <- maps:values(F), is_tuple(V)]).

%%==============================================================================
%% Island identity
%%==============================================================================

%% THE ISLAND IS IN THE PAYLOAD AND NEVER IN THE TOPIC. A thousand islands must
%% not become a thousand topics, and a reader who wants "all islands" has to be
%% able to ask for it.
both_facts_name_their_island_test() ->
    true = os:putenv("HECATE_BIOTOPE_ISLAND", "beam01"),
    try
        ?assertMatch(#{island := <<"beam01">>}, fact()),
        ?assertMatch(#{island := <<"beam01">>}, chart()),
        ?assertEqual(<<"biotope/world">>, world_facts:topic(world))
    after
        os:unsetenv("HECATE_BIOTOPE_ISLAND")
    end.

%% A machine already has an identity; inventing a second one that nobody
%% configures produces a fleet of islands all called the same thing.
island_defaults_to_the_hostname_test() ->
    os:unsetenv("HECATE_BIOTOPE_ISLAND"),
    {ok, Host} = inet:gethostname(),
    ?assertEqual(list_to_binary(Host), world_facts:island()).
