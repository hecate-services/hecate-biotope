#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc World 17's experiment: how finely a sense should read.
%%
%% Usage:  ./scripts/sweep_senses.escript [ticks [seeds]]
%%
%% THE SEED COUNT IS A PARAMETER BECAUSE 24 WAS NOT ENOUGH. Re-run against fixed
%% physics on 2026-08-02, scales 1, 2 and 4 all killed 21 of 24, so the criterion
%% this world chooses its constant by, fewest extinctions, had a three-way tie
%% and could not choose at all. A criterion that cannot separate the candidates
%% is not a criterion, and raising n is the only honest way to find out whether
%% the tie is real or is the sample.
%%
%% Criteria in PREREGISTRATION_WORLD17.md, amended to sweep this constant before
%% any result was claimed from it. `sense_scale` is how many steps of the reading
%% range a full cell spans: 1 is worlds 2 to 16, where anything less than a full
%% cell read zero, and 63 is what world 17 first picked, where the measurement
%% found every maximum pinned at the ceiling.
%%
%% BOTH ENDS ARE BLIND IN DIFFERENT WAYS and the question is whether anything in
%% between is informative at both. Nothing derives this number, which is exactly
%% why picking the tidy expression was the mistake.
-mode(compile).

-define(STEPS, [1, 2, 4, 8, 16, 32, 63]).

main(Args) ->
    Ticks = ticks(Args),
    Seeds = seeds(Args),
    io:format("~nticks=~p seeds=~p. every scale takes the MEAN; no value here is "
              "worlds 2-16,~nwhich SUMMED and coincides only at reach 0.~n~n",
              [Ticks, Seeds]),
    io:format("~s~n", [row(["scale", "dead", "alive", "SENSORS", "reach",
                            "nodes", "pop", "spread", "lines", "depth"])]),
    lists:foreach(fun(S) -> report(S, Ticks, Seeds) end, ?STEPS),
    io:format("~nSENSORS is per creature times a hundred and reach is total "
              "sensor reach carried~nby the population, which is what "
              "differentiates only if reach buys information.~n").

ticks([]) -> 20000;
ticks([A | _]) -> list_to_integer(A).

seeds([]) -> 24;
seeds([_Ticks]) -> 24;
seeds([_Ticks, S | _]) -> list_to_integer(S).

report(Scale, Ticks, Seeds) ->
    Rows = [R || R <- in_parallel(fun(S) -> run(S, Scale, Ticks) end,
                                  lists:seq(1, Seeds)), R =/= dead],
    io:format("~s~n", [row([Scale, Seeds - length(Rows), length(Rows)
                            | summarise(Rows)])]).

summarise([]) -> lists:duplicate(7, "-");
summarise(Rows) ->
    Avg = fun(K) -> avg([maps:get(K, R) || R <- Rows]) end,
    [Avg(sensor_mean), Avg(reach), Avg(hidden_mean), Avg(population),
     Avg(ground_spread), Avg(lineages), Avg(depth)].

run(Seed, Scale, Ticks) ->
    W = advance(world:new(#{seed => Seed, population => 40,
                            transfer_efficiency => 100,
                            sense_scale => Scale}), Ticks),
    finished(world:snapshot(W)).

finished(#{population := 0}) -> dead;
finished(Snap) ->
    Snap#{reach => lists:sum([maps:get(reach, F, 0)
                              || F <- maps:values(maps:get(sensors, Snap))])}.

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(1000, Left),
    keep_going(world:population(W) > 0, world:tick(W, Step), Left - Step).

keep_going(false, W, _Left) -> W;
keep_going(true, W, Left) -> advance(W, Left).

avg([]) -> 0;
avg(L) -> lists:sum(L) div length(L).

in_parallel(F, Items) ->
    Parent = self(),
    Refs = [spawn_one(Parent, F, I) || I <- Items],
    [receive {Ref, R} -> R end || Ref <- Refs].

spawn_one(Parent, F, Item) ->
    Ref = make_ref(),
    spawn_link(fun() -> Parent ! {Ref, F(Item)} end),
    Ref.

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(C, 10, trailing).
