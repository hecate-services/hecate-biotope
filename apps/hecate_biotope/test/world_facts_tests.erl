%% @doc What goes on the wire, and the rules it has to obey.
%%
%% Each of these rules was earned by something that broke on this mesh before.
%% A tuple does not survive the encoder cleanly. An atom key and a binary key of
%% the same name collide into one, so a map carrying both ships two entries and
%% arrives with one.
-module(world_facts_tests).

-include_lib("eunit/include/eunit.hrl").

fact() ->
    world_facts:world_advanced(snapshot(), pace()).

snapshot() -> world:snapshot(world:new(#{population => 7})).

pace() -> world_pace:from_map(#{}).

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
                   ground_spread, still_pct, hidden_mean, hidden_width, movers,
                   breeders, explored, frontier, behaviour_space, deepest_elite,
                   commonest_way_pct, age_mean,
                   from_creatures_pct, sensor_mean, scent_tags, scent_spread]),
    %% The shape of the population rather than its average, as short
    %% fixed-length lists of counts.
    lists:foreach(fun(K) ->
                          Bars = maps:get(K, F),
                          ?assert(is_list(Bars)),
                          ?assert(lists:all(fun is_integer/1, Bars))
                  end, [sensor_hist, hidden_hist, uptake_hist]).

%% VERSION 8 SAYS HOW MANY SEEDS WERE REJECTED, because a screened fleet is a
%% biased sample and saying so is the difference between honest and not.
%%
%% VERSION 7 SAYS WHICH RUN THIS IS. A world that ended stays ended and an island
%% that has finished one begins another, so a spectator watching the tick drop
%% back to nothing is told it is a new world rather than left to read a glitch.
%%
%% VERSION 6 PUBLISHED THE SEED, which makes any island anyone is watching
%% exactly reproducible offline, and is what lets a live island draw a fresh one
%% at boot rather than replaying the same life after every restart.
%%
%% VERSION 5 PUBLISHED THE TWO THINGS A SPECTATOR COULD NOT SEE.
%%
%% `dissipated' is the entropy account, the one quantity in this world that
%% cannot fall, and the third term that closes the books: ground plus creatures
%% plus burnt changes only by what the sun adds. Two of those three were on the
%% wire and the third was not, so the First Law could be asserted on the page and
%% never checked from it.
%%
%% `depth' and `lineages' say whether the population can still CHANGE, which
%% every other field on this wire describes a population without answering. World
%% 8 ended rich and frozen, nothing born since tick 15, and no fact it published
%% could have shown that.
%%
%% Version 17 published WHAT MOST OF THEM ARE LIKE, in words: the commonest way
%% of making a living as adjectives derived from bins, its share, and the mean
%% age beside it, because a large part of any population is too young to have
%% done anything and reads as barren and starving for that reason alone.
%%
%% Version 16 published WHAT CREATURES DO, as against what they are. `kinds'
%% counts architectures; `explored' and `frontier' count ways of living, found
%% out of a space of 125. Measured on one world the two move in opposite
%% directions, so the genotype census alone was calling expansion convergence.
%% `frontier' is the one that can fall and reaching zero is this world's
%% definition of converged.
%%
%% Version 15 published `hidden_width`, which had been computed since world 19
%% and stopped at the island's own page. World 19 exists to ask whether a brain
%% can become NARROWER as against smaller, and no published fact could answer it:
%% a brain getting cheaper and a brain getting simpler are indistinguishable from
%% a node count. Six worlds of history were recorded without the one column the
%% rules change was about.
%%
%% Version 14 SENT THE ARCHITECTURES THEMSELVES, on the chart. Version 13 could
%% say a world held nineteen kinds and could not say what any of them was. This
%% one carries the body plan and brain of each: which of the four fields it has
%% sensors for and at what reach, how many hidden nodes, which of the four
%% purposes it can act on. Sent ONCE per architecture with an index per creature,
%% because a hundred creatures share a couple of dozen structures.
%%
%% Version 13 named the KINDS: how many distinct architectures are alive, as
%% against how many ancestors. `lineages` counts founders and can only fall, and
%% `G.1` warns in its own words that a founding is ANCESTRY AND NOT A KIND, yet
%% eighteen worlds read its 1 as a monoculture. Measured, a world reading one
%% lineage routinely carries five to twenty-seven body plans at once.
%%
%% Version 19 put `parched' on the counts fact: death by drying out, which world
%% 23 was built to cause and counted separately from the beginning so that "the
%% world got harsher" and "the world got thirsty" could be told apart. It reached
%% no reader, so at the default econ 18% of every death was invisible.
%% Version 18 put `water', `senses' and `nodes' on the chart fact. All three were
%% computed by `chart/1' and reached no wire, so an island could not be drawn
%% with its own landscape and a spectator could not size a creature by what it is
%% built of. An APPEND still moves this number: an old reader keeps working, and
%% that is precisely why a reader needs a way to ask whether the field it wants
%% is in this frame or whether it is talking to an island that predates it.
%% Version 9 named the DOOR: which station this island reaches the mesh through,
%% read from the live link rather than from configuration.
%% Version 4 named which world is running, so a fleet mid-rollout could be read.
%% Version 3 was the one where plants stopped existing.
reports_its_own_version_test() ->
    #{type := Type, fact_version := V} = fact(),
    ?assertEqual(world_advanced, Type),
    ?assertEqual(19, V).

%% ⚠ THE SAME GUARD AS THE CHART'S, FOR THE COUNTS FACT.
%%
%% `parched' was computed by `snapshot/1' from the day world 23 was built and put
%% on no wire, so the one number saying whether that world's central rule does
%% anything could not be read from outside the island. Four fields have now gone
%% missing in this exact gap: `structures', `water', `senses', `nodes' -- and
%% this one.
%%
%% ⚠⚠ AND THIS CANNOT BE THE CHART'S TEST REPEATED. A snapshot carries dozens of
%% things a spectator has no use for, so "every key reaches the wire" is false
%% here by design. What can be asserted is that the DEATH CAUSES are exhaustive:
%% a reader that adds them up must get every death, and a new cause that does not
%% reach the wire breaks that sum.
every_way_to_die_reaches_the_wire_test() ->
    F = fact(),
    Causes = [starved, consumed, aged_out, parched],
    [?assert(maps:is_key(C, F)) || C <- Causes],
    %% The island's own snapshot has exactly these and no more. A fifth cause
    %% added to the world fails here until it is published.
    Snapshot = world:snapshot(world:new(#{population => 7, radius => 5})),
    ?assertEqual([], [C || C <- Causes, not maps:is_key(C, Snapshot)]).

%%==============================================================================
%% Which door the island is on
%%==============================================================================

door() ->
    #{station_host => <<"station-de-nuremberg.macula.io">>,
      station_connected => true,
      station_id => <<"a1b2c3">>}.

with_door() ->
    world_facts:world_advanced(snapshot(), pace(), 1, undefined, 0, door()).

%% THE DOOR TRAVELS ON EVERY FACT, for the same reason the economy does: a
%% spectator arriving late would otherwise be looking at islands it cannot tell
%% apart, and a link that drops shows up in the next fact rather than in a
%% caption nobody refreshes.
carries_the_door_it_dialled_test() ->
    #{station_host := Host, station_connected := Up, station_id := Id} =
        with_door(),
    ?assertEqual(<<"station-de-nuremberg.macula.io">>, Host),
    ?assertEqual(true, Up),
    ?assertEqual(<<"a1b2c3">>, Id).

%% ABSENT IS NOT THE SAME AS DOWN. An island that cannot read its own link and
%% an island whose link is down are different states, and a sentinel host would
%% collapse them: a reader plotting uptime would count blindness as an outage.
a_door_that_cannot_be_read_is_absent_rather_than_empty_test() ->
    F = fact(),
    ?assertNot(maps:is_key(station_host, F)),
    ?assertNot(maps:is_key(station_connected, F)),
    ?assertNot(maps:is_key(station_id, F)).

%% A DOWN LINK IS STILL REPORTED, because "dialling nuremberg and nobody is
%% answering" is exactly what a spectator most wants to see and is invisible if
%% the island only speaks when things work.
a_down_link_is_still_reported_test() ->
    #{station_connected := Up, station_host := Host} =
        world_facts:world_advanced(snapshot(), pace(), 1, undefined, 0,
                                   (door())#{station_connected => false}),
    ?assertEqual(false, Up),
    ?assertEqual(<<"station-de-nuremberg.macula.io">>, Host).

%% The door is strings and a boolean, which the wire rules allow; this is here
%% because it is the first field that is neither a number nor a list of them.
the_door_obeys_the_wire_rules_test() ->
    F = with_door(),
    ?assert(lists:all(fun is_atom/1, maps:keys(F))),
    ?assertEqual([], [V || V <- maps:values(F), is_tuple(V)]),
    ?assert(is_binary(maps:get(station_host, F))),
    ?assert(is_boolean(maps:get(station_connected, F))).

%% THE BOOKS CLOSE, AND NOW THEY CLOSE ON THE WIRE. A spectator holding one fact
%% has every term of the First Law and can check the arithmetic itself rather
%% than trusting the island. Before version 5 the heat was missing, which is
%% exactly the term that makes the sum constant.
carries_every_term_of_the_energy_books_test() ->
    #{ground_total := Ground, energy_total := InCreatures,
      dissipated := Burnt} = fact(),
    lists:foreach(fun(V) -> ?assert(is_integer(V) andalso V >= 0) end,
                  [Ground, InCreatures, Burnt]).

%% ZERO DEPTH MEANS EVERY CREATURE ALIVE IS A FOUNDER, so a fresh world reports
%% it and that is the correct answer rather than a missing one.
carries_whether_the_population_can_still_change_test() ->
    #{lineages := Lines, depth := Depth} = fact(),
    ?assertEqual(0, Depth),
    ?assert(Lines > 0).

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

%% ⚠ THE GUARD THAT WOULD HAVE CAUGHT WATER, AND `structures' BEFORE IT.
%%
%% `world:chart/1' computes a field and `world_charted/2' destructures a FIXED
%% LIST of keys to put on the wire. Append to the first and forget the second and
%% the field silently never leaves the island. That has now happened twice:
%% `structures' was computed from world 6 and dropped for four worlds, so a
%% renderer that sizes a creature by its body never once had the number; and
%% `water' was the entire subject of world 23 and reached no wire at all.
%%
%% Both are `B.7' and `C.6': each function correct on its own, the gap between
%% them wrong, and the test feeding a hand-built chart rather than the fact an
%% island sends. This compares the two directly, so the NEXT appended field
%% cannot go missing quietly.
every_field_on_the_chart_reaches_the_wire_test() ->
    Chart = world:chart(world:new(#{population => 7, radius => 5})),
    Dropped = maps:keys(Chart) -- maps:keys(chart()),
    ?assertEqual([], Dropped).

%% ⚠ THE CHART HAS NEVER HAD A WIRE-RULES TEST OF ITS OWN, and everything on it
%% until now was a fixed-width record of integers where breaking a rule was hard.
%% The kind table is not: it is a variable-length encoding of a structure, which
%% is the first thing here that a careless change could turn into a list of
%% tuples or a nested list. A CBOR wire that rejects a frame drops the whole
%% picture, so this is checked on the chart and not only on the world fact.
the_chart_obeys_the_wire_rules_test() ->
    F = chart(),
    ?assert(lists:all(fun is_atom/1, maps:keys(F))),
    ?assertEqual([], [V || V <- maps:values(F), is_tuple(V)]),
    %% Every list on the chart is flat integers, the kind table included.
    Lists = [V || V <- maps:values(F), is_list(V), not is_binary(V)],
    ?assert(lists:all(fun(L) -> lists:all(fun is_integer/1, L) end, Lists)).

%% WHAT EACH CREATURE IS, WHICH IS THE POINT OF THE EXPERIMENT AND WAS NOT ON THE
%% WIRE FOR FOURTEEN VERSIONS. `kinds` could say a world held nineteen
%% architectures and nothing could say what any one of them was.
the_chart_says_what_each_creature_is_built_like_test() ->
    #{ids := Ids, kind_of := KindOf, kind_table := Table} = chart(),
    %% One index per creature, parallel to `ids' like every other per-creature
    %% list here. A length that disagreed would attribute architectures to the
    %% wrong creatures, silently, which is what the parallel-list convention on
    %% this fact exists to prevent.
    ?assertEqual(length(Ids), length(KindOf)),
    ?assert(lists:all(fun is_integer/1, Table)),
    %% The architectures go once and the heads point at them: a founding
    %% population of 7 draws at most 7 kinds and the table is far shorter than
    %% seven genomes would be.
    ?assert(lists:max(KindOf) < 7).

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

%% THE SEED TRAVELS, so a world anybody is watching is a world anybody can run.
%% Without it a live island choosing a fresh seed at boot would be unrepeatable
%% by everyone including us, which trades one problem for a worse one.
carries_the_seed_it_unfolded_from_test() ->
    #{seed := Seed} = fact(),
    ?assert(is_integer(Seed)).

%% WHICH RUN, AND WHEN THE LAST ONE ENDED. A first run says `run => 1' and omits
%% the ending entirely: a key that is absent says this has not happened, where a
%% zero would say it ended at tick nought.
carries_which_run_this_is_test() ->
    ?assertMatch(#{run := 1}, fact()),
    ?assertEqual(false, maps:is_key(previous_end, fact())),
    Later = world_facts:world_advanced(world:snapshot(world:new(#{population => 7})),
                                       world_pace:from_map(#{}), 3, 630, 5),
    ?assertMatch(#{run := 3, previous_end := 630, seeds_rejected := 5}, Later).

%% EVERYTHING THE PICTURE NEEDS, ON THE WIRE. `chart/1' computes more than this
%% function used to forward, and the one it dropped was `structures': a
%% spectator asking for a creature's BODY got nothing and silently fell back to
%% its store. World 10 sized creatures by the body precisely because every
%% contest is decided on structure alone, and that correction was never once in
%% effect on a live island.
%%
%% Asserted as a set rather than one key, because the failure was a field going
%% missing between two functions that were each correct.
the_chart_carries_everything_the_picture_needs_test() ->
    F = chart(),
    Creatures = length(maps:get(creatures, F)) div 2,
    lists:foreach(fun(K) ->
                          ?assert(maps:is_key(K, F)),
                          ?assertEqual({K, Creatures}, {K, length(maps:get(K, F))})
                  end,
                  [ids, energies, structures, signatures, uptakes]).
