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
                  [born, starved, aged_out, consumed, absorbed,
                   births_refused, population, energy_total, ground_total,
                   ground_spread, still_pct, hidden_mean, movers, breeders,
                   from_creatures_pct, sensor_mean, scent_tags, scent_spread]),
    %% The shape of the population rather than its average, as short
    %% fixed-length lists of counts.
    lists:foreach(fun(K) ->
                          Bars = maps:get(K, F),
                          ?assert(is_list(Bars)),
                          ?assert(lists:all(fun is_integer/1, Bars))
                  end, [sensor_hist, hidden_hist, uptake_hist]).

%% VERSION 4, WHICH NAMES WHICH WORLD IS RUNNING. Before it, a spectator watching
%% a fleet mid-rollout had no way to tell that two cards were showing different
%% physics, because the econ id it would reach for is identical across the
%% change.
%%
%% Version 3 was the one where plants stopped existing. A plant was never a kind
%% of thing, it is a way of living, and world 2 deleted the entity, the list of
%% them on the chart and the counter of them eaten.
reports_its_own_version_test() ->
    #{type := Type, fact_version := V} = fact(),
    ?assertEqual(world_advanced, Type),
    ?assertEqual(4, V).

%% WHICH WORLD, IN THE PAYLOAD. The econ id beside it says whether two islands
%% are comparable and cannot say what either of them IS: world 6 changed the
%% rules and not one constant, so an island a whole world apart carries an
%% identical econ id. A fleet is redeployed one node at a time, so during a
%% rollout that difference is real and a reader must be able to see it.
carries_which_world_it_is_and_a_sentence_saying_what_that_means_test() ->
    #{world := N, world_line := Line} = fact(),
    #{number := Expected} = world:ruleset(),
    ?assertEqual(Expected, N),
    ?assert(byte_size(Line) > 0).

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
%% survive this mesh cleanly.
the_chart_carries_flat_coordinates_test() ->
    #{creatures := Cs, stride := Stride} = chart(),
    ?assertEqual(2, Stride),
    ?assertEqual(0, length(Cs) rem 2),
    ?assert(lists:all(fun is_integer/1, Cs)).

%% The ground is position AND amount, so it interleaves at its own stride, which
%% travels with it rather than being assumed. Only cells holding something are
%% sent: an empty one is drawn bare, and on a grazed board most of them are.
the_ground_carries_its_own_stride_test() ->
    #{ground := G, ground_stride := Stride} = chart(),
    ?assertEqual(3, Stride),
    ?assertEqual(0, length(G) rem 3),
    ?assert(lists:all(fun is_integer/1, G)).

%% ONE ENERGY PER CREATURE, IN THE SAME ORDER, as a parallel list. Interleaving
%% would make the creature stride 3 while plants stayed 2, and a reader that got
%% that wrong would draw a plausible and completely wrong picture rather than
%% failing. Carried because energy is armour here: how big a creature is is the
%% most informative thing about it.
energies_run_parallel_to_creatures_test() ->
    #{creatures := Cs, energies := Es} = chart(),
    ?assertEqual(length(Cs) div 2, length(Es)),
    ?assert(lists:all(fun(E) -> is_integer(E) andalso E >= 0 end, Es)).

%% Marks are position AND strength, so they interleave at their own stride, which
%% travels with them rather than being assumed.
scent_carries_its_own_stride_test() ->
    #{scent := Marks, scent_stride := Stride} = chart(),
    ?assertEqual(3, Stride),
    ?assertEqual(0, length(Marks) rem 3),
    ?assert(lists:all(fun is_integer/1, Marks)).

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
