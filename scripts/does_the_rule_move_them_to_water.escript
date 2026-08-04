#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% DOES THE RULE MOVE THEM, AND AGAINST WHICH NULL. `I.17'.
%%
%% The distance from a creature to its nearest hole has THREE different values
%% and I conflated them, which produced an absurd rule:
%%
%%   FOUNDERS          tick 0. Placed at random, so this is the distance a
%%                     uniform scatter gives and has nothing to do with water.
%%   SETTLED, NO RULE  a world run with water present and `thirst' at zero.
%%                     Creatures have settled where the FOOD is. This is the
%%                     honest null: everything else about the world is the same
%%                     and only the pressure is missing.
%%   SETTLED, RULE ON  the same world with the drain running.
%%
%% ⚠ THE MIDDLE ONE IS THE NULL, not the first. Comparing the rule against
%% founders credits it with every bit of clustering the world does anyway.
%%
%% ⚠⚠ `to_water_mean' IS IN HUNDREDTHS OF A CELL. The first version of this
%% script printed it as cells and reported creatures standing 1,184 cells from
%% water on a disc whose widest span is 40. That is `I.6' again: an instrument
%% whose units are only in a comment on the other side of the snapshot.
-mode(compile).

main(Args) ->
    Seeds = arg(Args, 1, 12),
    Ticks = arg(Args, 2, 3000),
    io:format("~n~p seeds, ~p ticks. Mean cells from a creature to its nearest "
              "hole.~n~n", [Seeds, Ticks]),
    io:format("~-8s ~-12s ~-18s ~-18s ~-8s~n",
              ["holes", "founders", "settled, no rule", "settled, rule on",
               "alive on/off"]),
    [arm(H, Seeds, Ticks) || H <- [7, 19, 37, 61]],
    ok.

arm(Holes, Seeds, Ticks) ->
    {F, _} = measure(Holes, Seeds, 0, 0),
    {Null, NullLive} = measure(Holes, Seeds, Ticks, 0),
    {On, Live} = measure(Holes, Seeds, Ticks, 10),
    io:format("~-8w ~-12s ~-18s ~-18s ~-8s~n",
              [Holes, two(F), two(Null), two(On),
               io_lib:format("~w/~w", [Live, NullLive])]).

measure(Holes, Seeds, Ticks, Thirst) ->
    Runs = [run(S, Holes, Ticks, Thirst) || S <- lists:seq(1, Seeds)],
    Ds = lists:append([D || {D, _} <- Runs]),
    {mean(Ds), length([1 || {D, _} <- Runs, D =/= []])}.

run(Seed, Holes, Ticks, Thirst) ->
    W = advance(world:new(#{seed => Seed, population => 40,
                            water_holes => Holes, thirst => Thirst}), Ticks),
    #{to_water_mean := M, population := P} = world:snapshot(W),
    {[M || P > 0], P}.

advance(W, 0) -> W;
advance(W, N) -> advance(world:tick(W), N - 1).

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.

mean([]) -> 0.0;
mean(L) -> lists:sum(L) / length(L).

%% Hundredths of a cell to cells.
two(F) -> io_lib:format("~.2f", [F / 100]).
