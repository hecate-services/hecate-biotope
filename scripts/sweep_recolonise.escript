#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc World 14's experiment: how strongly a living neighbourhood reseeds a bare
%% patch, every value.
%%
%% Criteria frozen in PREREGISTRATION_WORLD14.md before this was run.
%%
%% CONTROL IS 3 AND IS WORLDS 2 TO 13 ON A FULL BOARD. Every neighbour at the
%% ceiling of 400 gives `400 * 3 / 100 = 12', the `ground_seed' those worlds
%% used, so the comparison lives inside the experiment rather than across it.
%% What differs at the control is only what happens once a neighbourhood is
%% grazed down, which is the whole change.
%%
%% THE PRICE OF PERCEPTION IS PINNED at world 13's control of 330 throughout.
%% World 13 moved sensors by making them cheaper and the ground floor sweep
%% showed they belong to a way of life. If they move here it has to be because
%% the ways of living changed.
%%
%% `ground_spread' IS THE MECHANISM CHECK and comes first in the report. It has
%% sat at 22 to 25 since world 12. If the board does not get patchier, nothing
%% below it can follow and the rest of the findings are void.
-mode(compile).

-define(TICKS, 4000).
-define(SEEDS, 24).
-define(NEURAL, 330).

-define(STEPS, [0, 1, 2, 3, 4, 6, 9, 12, 18]).

%% Frozen before the data: observed values are 99 to 100 and 2 to 50, so this
%% sits in a band where nothing has ever been measured.
-define(SESSILE, 90).

main(_) ->
    io:format("~nticks=~p seeds=~p neural_cost=~p pinned, 100% efficiency~n",
              [?TICKS, ?SEEDS, ?NEURAL]),
    io:format("control is 3, which is a floor of 12 on a full board. "
              "sessile means still_pct >= ~p.~n~n", [?SESSILE]),
    io:format("~s~n", [row(["rate", "floor", "dead", "spread", "sess", "mob",
                            "s_sess", "s_mob", "s_all", "b_sess", "b_mob",
                            "still", "lines", "depth", "uspread"])]),
    lists:foreach(fun report/1, ?STEPS),
    io:format("~nfloor is what a cell gets when every neighbour is full, for "
              "comparison with~nthe 12 of worlds 2 to 13. spread is "
              "`ground_spread', 22 to 25 since world 12.~ns_ = sensors per "
              "creature times a hundred, b_ = mean structure. still is the "
              "mean~n`still_pct' over every survivor, sessile and mobile "
              "together. lines, depth and~nuspread are the engine, reported "
              "beside the population as since world 9.~n").

report(Rate) ->
    Rows = in_parallel(fun(Seed) -> run(Seed, Rate) end, lists:seq(1, ?SEEDS)),
    Alive = [R || #{population := P} = R <- Rows, P > 0],
    {Sess, Mob} = lists:partition(fun sessile/1, Alive),
    io:format("~s~n", [row([Rate, 400 * Rate div 100, ?SEEDS - length(Alive),
                            avg_of(ground_spread, Alive),
                            length(Sess), length(Mob),
                            avg_of(sensor_mean, Sess), avg_of(sensor_mean, Mob),
                            avg_of(sensor_mean, Alive),
                            avg_of(body, Sess), avg_of(body, Mob),
                            avg_of(still_pct, Alive), avg_of(lineages, Alive),
                            avg_of(depth, Alive), avg_of(uspread, Alive)])]).

sessile(#{still_pct := Still}) -> Still >= ?SESSILE.

avg_of(_Key, []) -> 0;
avg_of(Key, Rows) -> lists:sum([maps:get(Key, R) || R <- Rows]) div length(Rows).

run(Seed, Rate) ->
    S = world:snapshot(world:tick(world:new(#{seed => Seed, population => 40,
                                              transfer_efficiency => 100,
                                              neural_cost => ?NEURAL,
                                              recolonise_pct => Rate}),
                                  ?TICKS)),
    S#{body => per_creature(structure_total, S),
      uspread => maps:get(uptake_max, S) - maps:get(uptake_min, S)}.

per_creature(_Key, #{population := 0}) -> 0;
per_creature(Key, #{population := Pop} = S) -> maps:get(Key, S) div Pop.

%%==============================================================================

in_parallel(F, Items) ->
    Parent = self(),
    Refs = [spawn_one(Parent, F, I) || I <- Items],
    [receive {Ref, Result} -> Result end || Ref <- Refs].

spawn_one(Parent, F, Item) ->
    Ref = make_ref(),
    spawn_link(fun() -> Parent ! {Ref, F(Item)} end),
    Ref.

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(C, 8, trailing).
