#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc What the floor under bare ground is holding up.
%%
%% Criteria frozen in PREREGISTRATION_GROUND_FLOOR.md before this was run.
%%
%% THIS IS A WORLD 13 EXPERIMENT AND NO LONGER RUNS. World 14 deleted
%% `ground_seed', so `world:new/1' refuses the option and says which keys it
%% takes. Kept as the record of what was measured, since the result it produced
%% is what world 14 was built out of. Its findings are in
%% RESULTS_GROUND_FLOOR.md and its entry is A.5.
%%
%% `ground_seed' is what a stripped cell gains for nothing, and it was set in
%% world 4 by asking whether a creature that sits still and sees nothing could
%% fund a child on it. That criterion presupposes the answer to the question this
%% project keeps asking, and it has never been tested. Nothing here changes the
%% physics: `ground_seed' is already configurable, so every row is world 13.
%%
%% THE PRICE OF PERCEPTION IS HELD FIXED THROUGHOUT, at world 13's control of
%% 330. World 13 moved sensors by making them cheaper. If they move here it has
%% to be for another reason, and pinning the price is what makes that claim mean
%% anything.
%%
%% TWENTY-FOUR SEEDS AND NO MEDIANS. World 13 swept five and reported the middle
%% one, and the middle of a bimodal distribution is not a summary of it. That
%% error is why this experiment exists, so it is not repeated here: every value
%% is a mean over worlds within a regime, and the regime counts are printed
%% beside them so a reader can see what the mean is over.
-mode(compile).

-define(TICKS, 4000).
-define(SEEDS, 24).
-define(NEURAL, 330).

%% Control is 12. 24 is what world 4's criterion would demand today, per A.5.
%% 0 is the anchor: a stripped cell never recovers and the board should go
%% sterile one cell at a time, which world 3's own comment predicts.
-define(STEPS, [0, 3, 6, 9, 12, 18, 24, 36, 48]).

%% Frozen before the data: observed values are 99 to 100 and 2 to 50, so this
%% sits in a band where nothing has ever been measured.
-define(SESSILE, 90).

main(_) ->
    io:format("~nticks=~p seeds=~p neural_cost=~p held fixed, 100% efficiency~n",
              [?TICKS, ?SEEDS, ?NEURAL]),
    io:format("control is 12. sessile means still_pct >= ~p.~n~n", [?SESSILE]),
    io:format("~s~n", [row(["floor", "cross", "dead", "sess", "mob", "s_sess",
                            "s_mob", "s_all", "b_sess", "b_mob", "g_sess",
                            "g_mob"])]),
    lists:foreach(fun report/1, ?STEPS),
    io:format("~ns_ = sensors per creature times a hundred, b_ = mean structure, "
              "g_ = mean~nstanding stock per cell. cross is the stock below which "
              "a cell lives on the~nfloor and above which it compounds, "
              "floor * 100 / ground_growth_pct.~n").

report(Floor) ->
    Rows = in_parallel(fun(Seed) -> run(Seed, Floor) end, lists:seq(1, ?SEEDS)),
    Alive = [R || #{population := P} = R <- Rows, P > 0],
    {Sess, Mob} = lists:partition(fun sessile/1, Alive),
    io:format("~s~n", [row([Floor, Floor * 100 div 6, ?SEEDS - length(Alive),
                            length(Sess), length(Mob),
                            avg_of(sensor_mean, Sess), avg_of(sensor_mean, Mob),
                            avg_of(sensor_mean, Alive),
                            avg_of(body, Sess), avg_of(body, Mob),
                            avg_of(ground, Sess), avg_of(ground, Mob)])]).

sessile(#{still_pct := Still}) -> Still >= ?SESSILE.

avg_of(_Key, []) -> 0;
avg_of(Key, Rows) -> lists:sum([maps:get(Key, R) || R <- Rows]) div length(Rows).

run(Seed, Floor) ->
    S = world:snapshot(world:tick(world:new(#{seed => Seed, population => 40,
                                              transfer_efficiency => 100,
                                              neural_cost => ?NEURAL,
                                              ground_seed => Floor}),
                                  ?TICKS)),
    S#{body => per_creature(structure_total, S), ground => per_cell(S)}.

per_creature(_Key, #{population := 0}) -> 0;
per_creature(Key, #{population := Pop} = S) -> maps:get(Key, S) div Pop.

per_cell(#{ground_total := G, radius := R}) -> G div (1 + 3 * R * (R + 1)).

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
