#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc What a creature earns and what it spends, per tick, measured.
%%
%% Usage:  ./scripts/where_does_it_go.escript [ticks-to-settle]
%%
%% THE QUESTION THIS EXISTS FOR. World 15's mouth costs about six energy a tick
%% and is not shed over four to six hundred generations. Estimating a lifetime
%% intake at 500 to 900 made that a selection differential of a quarter to a
%% half, which should be lethal within ten generations. Either the estimate is
%% wrong or something else is.
%%
%% SO NOTHING HERE IS ESTIMATED. Intake is read as the difference between two
%% snapshots, which is the only number that cannot be argued with, and the bill
%% is computed from the same expression `charge_one/2' uses.
%%
%% THREE EXPLANATIONS HAVE ALREADY FAILED ON THIS NULL: the absorbing state, the
%% patchiness, the truncation. Each was arithmetic that was true somewhere and
%% not where it mattered. This measures the ratio the argument actually turns on
%% rather than reasoning about it.
-mode(compile).

-define(WINDOW, 500).

main(Args) ->
    Settle = settle(Args),
    io:format("~nsettled ~p ticks, then measured over ~p~n~n", [Settle, ?WINDOW]),
    io:format("~s~n", [row(["seed", "pop", "mouth", "body", "EARNS", "SPENDS",
                            "mouth of it", "as % earned", "life"])]),
    lists:foreach(fun(S) -> report(S, Settle) end, [5, 12, 14, 39, 46, 8]),
    io:format("~nEARNS and SPENDS are per creature per tick. mouth of it is what "
              "the mouth~nadds to SPENDS, and the next column is that as a "
              "percentage of what the~ncreature earns: THE SELECTION DIFFERENTIAL "
              "THE ARGUMENT TURNS ON. life is~nthe mean lifespan in ticks, so a "
              "lifetime cost is that times the mouth column.~n").

settle([]) -> 20000;
settle([A | _]) -> list_to_integer(A).

report(Seed, Settle) ->
    W = advance(world:new(#{seed => Seed, population => 40,
                            transfer_efficiency => 100}), Settle),
    measured(Seed, world:snapshot(W), W).

measured(Seed, #{population := 0}, _W) ->
    io:format("~s~n", [row([Seed, "dead", "-", "-", "-", "-", "-", "-", "-"])]);
measured(Seed, Before, W) ->
    After = world:snapshot(world:tick(W, ?WINDOW)),
    Pop = maps:get(population, Before),
    %% INTAKE IS A DIFFERENCE OF TOTALS, not a rate anyone reports, because a
    %% rate would be somebody's arithmetic and these are the world's own books.
    Earned = took(After) - took(Before),
    Body = maps:get(structure_total, Before) div Pop,
    Mouth = maps:get(mouth_mean, Before),
    Econ = maps:get(econ, Before),
    Div = maps:get(upkeep_divisor, Econ),
    PerTick = Earned div (Pop * ?WINDOW),
    Spends = maps:get(metabolism, Econ) + (Body + Mouth) div Div,
    Costs = (Body + Mouth) div Div - Body div Div,
    io:format("~s~n", [row([Seed, Pop, Mouth, Body, PerTick, Spends, Costs,
                            pct(Costs, PerTick), lifespan(Before, After)])]).

took(Snap) -> maps:get(absorbed, Snap) + maps:get(fed_by_creatures, Snap).

%% Ticks per death over the window, which is the mean lifespan a population at
%% equilibrium is turning over at.
lifespan(Before, After) ->
    Died = deaths(After) - deaths(Before),
    ratio(maps:get(population, Before) * ?WINDOW, Died).

deaths(Snap) ->
    maps:get(starved, Snap) + maps:get(aged_out, Snap) + maps:get(consumed, Snap).

ratio(_N, 0) -> 0;
ratio(N, D) -> N div D.

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(1000, Left),
    keep_going(world:population(W) > 0, world:tick(W, Step), Left - Step).

keep_going(false, W, _Left) -> W;
keep_going(true, W, Left) -> advance(W, Left).

pct(_N, 0) -> 0;
pct(N, D) -> N * 100 div D.

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(C, 13, trailing).
