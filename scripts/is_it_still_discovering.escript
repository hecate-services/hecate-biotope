#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc DOES THIS WORLD KEEP FINDING NEW WAYS TO LIVE, OR DOES IT SETTLE?
%%
%% Usage:  ./scripts/is_it_still_discovering.escript [seeds [ticks]]
%%
%% Every sweep this project has run measures a PRICE and reports survival. This
%% one measures nothing about price and reports whether the world is still
%% moving: how many architectures are alive, how much of the space of ways-of-
%% living has been found, and how much of it was found RECENTLY.
%%
%% ⚠ `frontier' IS THE COLUMN. `explored' can only rise, so a world that stopped
%% discovering last night still reports a large number and looks healthy. The
%% frontier counts cells first seen in the last thousand ticks, and zero is this
%% world's definition of converged.
%%
%% MEDIANS OVER SURVIVING SEEDS, and the count of dead ones beside them, because
%% a world that died at tick 600 has a frontier of whatever it had reached and
%% averaging that in would report a graveyard as a quiet suburb.
-mode(compile).

main(Args) ->
    Seeds = arg(Args, 1, 32),
    Ticks = arg(Args, 2, 6000),
    io:format("~n~p seeds to ~p ticks. World ~p.~n~n",
              [Seeds, Ticks, maps:get(number, world:ruleset())]),
    io:format("~s~n", [row(["tick", "dead", "pop", "kinds", "explored",
                            "FRONTIER", "elite", "depth"])]),
    lists:foldl(fun(T, Ws) -> report(T, advance_all(Ws, 1000), Seeds) end,
                [world:new(#{seed => S, population => 40})
                 || S <- lists:seq(1, Seeds)],
                lists:seq(1000, Ticks, 1000)),
    io:format("~nA frontier that reaches zero and stays there is a world that "
              "has stopped~nfinding new ways to make a living, whatever its "
              "population is doing.~n").

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.

advance_all(Ws, Step) -> in_parallel(fun(W) -> advance(W, Step) end, Ws).

advance(W, 0) -> W;
advance(W, Left) -> going(world:population(W) > 0, W, Left).

going(false, W, _Left) -> W;
going(true, W, Left) -> advance(world:tick(W, 1), Left - 1).

report(T, Ws, Seeds) ->
    Live = [world:snapshot(W) || W <- Ws, world:population(W) > 0],
    io:format("~s~n", [row([T, Seeds - length(Live) | summarise(Live)])]),
    Ws.

summarise([]) -> lists:duplicate(6, "-");
summarise(Snaps) ->
    Med = fun(K) -> median([maps:get(K, S) || S <- Snaps]) end,
    [Med(population), Med(kinds), Med(explored), Med(frontier),
     Med(deepest_elite), Med(depth)].

median([]) -> 0;
median(L) -> lists:nth(length(L) div 2 + 1, lists:sort(L)).

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
pad(C) -> string:pad(lists:flatten(C), 10, trailing).
