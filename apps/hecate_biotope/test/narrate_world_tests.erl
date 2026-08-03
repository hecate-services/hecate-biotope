-module(narrate_world_tests).

-include_lib("eunit/include/eunit.hrl").

%%==============================================================================
%% What a narrator is allowed to know
%%==============================================================================

%% ⚠ NUMBERS ONLY. A narrator can only invent things about things it was told
%% about, so the surest way to stop it explaining WHY something happened is to
%% hand it nothing to build a why out of. Anything that is not an integer here is
%% something a model could take as licence.
a_brief_is_numbers_and_nothing_else_test() ->
    Brief = world_brief:of_world(snapshot()),
    ?assert(map_size(Brief) > 10),
    ?assert(lists:all(fun is_atom/1, maps:keys(Brief))),
    ?assert(lists:all(fun is_integer/1, maps:values(Brief))).

%% It carries the two censuses that disagree, because they are the whole reason
%% there is anything interesting to say: what creatures ARE and what they DO.
a_brief_carries_both_censuses_test() ->
    Brief = world_brief:of_world(snapshot()),
    lists:foreach(fun(K) -> ?assert(maps:is_key(K, Brief)) end,
                  [kinds, ways_of_living_found, new_ways_last_1000_ticks,
                   ways_of_living_possible, creatures, tick]).

%% NOTHING AN OUTSIDER WROTE REACHES IT. An island's name comes from whoever
%% started the container and is the only text in this slice that was not written
%% in this repository. It is carried as a label and truncated, so an owner who
%% names their island a paragraph of instructions gets a short label rather than
%% a narrator that obeys them.
the_brief_contains_no_text_at_all_test() ->
    Brief = world_brief:of_world(snapshot()),
    ?assertEqual([], [V || V <- maps:values(Brief), is_binary(V)]),
    ?assertEqual([], [V || V <- maps:values(Brief), is_list(V)]).

%%==============================================================================
%% When it speaks
%%==============================================================================

%% The first look always has something to say, because nothing has been said.
the_first_thing_it_sees_is_worth_a_sentence_test() ->
    ?assert(world_brief:changed_enough(none, brief(#{}))).

%% ⚠ A WORLD THAT HAS NOT MOVED GETS NO SENTENCE. This is the cost control and
%% also the editor: an island runs at two ticks a second for ever, and a narrator
%% on a timer would produce a paragraph a minute about nothing, cost money for
%% each one, and teach a reader that the remarks are wallpaper.
a_world_that_sits_still_is_not_worth_remarking_on_test() ->
    Was = brief(#{creatures => 80, kinds => 12, ways_of_living_found => 60,
                  new_ways_last_1000_ticks => 4}),
    Same = brief(#{creatures => 82, kinds => 13, ways_of_living_found => 62,
                   new_ways_last_1000_ticks => 3}),
    ?assertNot(world_brief:changed_enough(Was, Same)).

%% THE ONE THAT MATTERS AND IS THE REASON FOR THE ARCHIVE. A world reaching zero
%% new ways has settled, and leaving zero has started moving again. Neither shows
%% up in the population, the kinds or the energy, so without this test the most
%% interesting moment an island has would pass unremarked.
settling_and_starting_again_are_both_news_test() ->
    Busy = brief(#{new_ways_last_1000_ticks => 5}),
    Settled = brief(#{new_ways_last_1000_ticks => 0}),
    ?assert(world_brief:changed_enough(Busy, Settled)),
    ?assert(world_brief:changed_enough(Settled, Busy)),
    %% Still settled is not news a second time.
    ?assertNot(world_brief:changed_enough(Settled, Settled)).

%% Dying is always worth a sentence and is the commonest thing that happens here.
an_island_dying_is_always_news_test() ->
    ?assert(world_brief:changed_enough(brief(#{creatures => 40}),
                                       brief(#{creatures => 0}))).

%% A proportional test, so six creatures losing two is news and two hundred
%% losing two is not.
a_swing_is_judged_against_the_size_of_the_world_test() ->
    ?assert(world_brief:changed_enough(brief(#{creatures => 6}),
                                       brief(#{creatures => 3}))),
    ?assertNot(world_brief:changed_enough(brief(#{creatures => 200}),
                                          brief(#{creatures => 197}))).

%%==============================================================================
%% It watches, and it never plays
%%==============================================================================

%% ⚠ THE ONE PROPERTY THIS SLICE MUST NEVER LOSE. A narrator reads snapshots and
%% emits sentences, and nothing it does can reach a creature, a tick or an
%% outcome. **Deleting the entire slice would change no world's history**, and a
%% world stays a pure function of its seed however talkative its narrator is.
%%
%% Asserted by running one world while asking for briefs at every step, and
%% another without, and requiring the two to be identical creature for creature.
narrating_a_world_cannot_change_it_test() ->
    Watched = watched(world:new(#{seed => 77, population => 20, radius => 5}),
                      150),
    Ignored = world:tick(world:new(#{seed => 77, population => 20, radius => 5}),
                         150),
    ?assertEqual(world:creatures(Ignored), world:creatures(Watched)),
    ?assertEqual(world:snapshot(Ignored), world:snapshot(Watched)).

watched(W, 0) -> W;
watched(W, N) ->
    _Brief = world_brief:of_world(world:snapshot(W)),
    watched(world:tick(W, 1), N - 1).

%%==============================================================================
%% What goes on the wire
%%==============================================================================

%% A REMARK CARRIES ITS OWN EVIDENCE. `derived_from' is the entire brief the
%% model saw, so any sentence can be checked against the figures it was written
%% from and a reader never has to take a narrator's word for it.
a_remark_ships_the_numbers_it_was_written_from_test() ->
    Brief = world_brief:of_world(snapshot()),
    Fact = world_facts:world_narrated(<<"Eighty creatures, mostly grazing.">>,
                                      <<"a-model">>, Brief),
    ?assertEqual(world_narrated, maps:get(type, Fact)),
    ?assertEqual(Brief, maps:get(derived_from, Fact)),
    ?assertEqual(<<"a-model">>, maps:get(said_by, Fact)),
    %% ⚠ MARKED AS SPEECH, NOT AS MEASUREMENT, and on its own topic, so nothing
    %% downstream can mistake a sentence for something the island counted.
    ?assertNotEqual(world_facts:topic(world), world_facts:topic(narration)),
    ?assertNotEqual(world_facts:topic(chart), world_facts:topic(narration)).

%% The wire rules, which a narration breaks more easily than a census does
%% because it carries a nested map and a piece of free text.
a_remark_obeys_the_wire_rules_test() ->
    Fact = world_facts:world_narrated(<<"A sentence.">>, <<"m">>,
                                      world_brief:of_world(snapshot())),
    ?assert(lists:all(fun is_atom/1, maps:keys(Fact))),
    ?assertEqual([], [V || V <- maps:values(Fact), is_tuple(V)]),
    ?assert(is_binary(maps:get(text, Fact))).

%%==============================================================================
%% Off unless asked
%%==============================================================================

%% NO KEY, NO NARRATOR, AND NO DIFFERENCE. An island is one container on a
%% stranger's machine and the join page promises no registration desk. A feature
%% that made an API key REQUIRED would break that, so an island without one runs
%% identically and starts no narrator at all.
an_island_with_no_model_starts_no_narrator_test() ->
    Was = os:getenv("HECATE_BIOTOPE_NARRATOR_KEY"),
    os:unsetenv("HECATE_BIOTOPE_NARRATOR_KEY"),
    os:unsetenv("HECATE_BIOTOPE_NARRATOR_KEY_FILE"),
    try
        ?assertNot(ask_a_model:configured()),
        ?assertEqual([], narrator:child_specs()),
        %% And asking anyway is silence rather than a crash.
        ?assertEqual(silent, ask_a_model:describe(#{tick => 1}, <<"an-island">>))
    after restore("HECATE_BIOTOPE_NARRATOR_KEY", Was)
    end.

restore(_Name, false) -> ok;
restore(Name, Value) -> os:putenv(Name, Value).

%%==============================================================================
%% Fixtures
%%==============================================================================

snapshot() ->
    world:snapshot(world:tick(world:new(#{seed => 77, population => 20,
                                          radius => 5}), 100)).

%% A brief with everything at zero except what a test names, so each test states
%% exactly the one thing it is about.
brief(Overrides) ->
    maps:merge(#{creatures => 50, kinds => 10, ways_of_living_found => 40,
                 new_ways_last_1000_ticks => 5}, Overrides).
