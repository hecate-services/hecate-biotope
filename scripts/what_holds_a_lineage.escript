#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc WHAT WOULD KEEP MORE THAN ONE FOUNDING LINE?
%%
%% Usage:  ./scripts/what_holds_a_lineage.escript [seeds [ticks]]
%%
%% `G.7`: the founding boom overshoots tenfold and the crash that follows leaves
%% about twenty creatures and eight lines, and in nine cases of twenty-four every
%% survivor is the last of its line. So the question `G.1` has carried since world
%% 8, what could ever hold more than one lineage, is really a question about the
%% first ninety ticks.
%%
%% TWO LEVERS, AND ONLY ONE OF THEM IS A NEW RULE.
%%
%%   HOW MANY FOUNDERS   more of them is more breeding stock, so a bigger boom
%%                       and a deeper crash. Fewer may hold more.
%%   WHAT A FOUNDER OWNS `start_energy` is 800, TWICE what a full cell holds, so
%%                       a founder can breed the moment it exists and nothing
%%                       damps the first generation. This is the endowment, and
%%                       it is a founding condition rather than a rule of the
%%                       world.
%%
%% Neither is a world. Both are parameters that have never been swept, and `G.7`
%% says they decide the thing eighteen worlds have been asking about.
-mode(compile).

-define(FOUNDERS, [10, 20, 40, 80]).
-define(ENDOWMENTS, [200, 400, 800, 1600]).

main(Args) ->
    Seeds = arg(Args, 1, 12),
    Ticks = arg(Args, 2, 2000),
    io:format("~n~p seeds to ~p ticks. peak and trough are the founding boom and "
              "the crash after it.~nLINES@end counts founding lines still alive "
              "at the horizon.~n~n", [Seeds, Ticks]),
    io:format("~s~n", [row(["founders", "endow", "dead", "peak", "trough",
                            "lines@tr", "LINES@end", "pop@end"])]),
    [report(F, E, Seeds, Ticks) || F <- ?FOUNDERS, E <- ?ENDOWMENTS].

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.

report(Founders, Endow, Seeds, Ticks) ->
    Rows = [run(S, Founders, Endow, Ticks) || S <- lists:seq(1, Seeds)],
    Live = [R || R <- Rows, R =/= dead],
    io:format("~s~n", [row([Founders, Endow, Seeds - length(Live)
                            | summarise(Live)])]).

summarise([]) -> ["-", "-", "-", "-", "-"];
summarise(Rows) ->
    Avg = fun(K) -> round(mean([maps:get(K, R) || R <- Rows])) end,
    [Avg(peak), Avg(trough), Avg(linest), Avg(lines), Avg(pop)].

run(Seed, Founders, Endow, Ticks) ->
    W0 = world:new(#{seed => Seed, population => Founders,
                     start_energy => Endow, transfer_efficiency => 100}),
    {Peak, Trough, LinesT} = arc(W0, 0, 400, 0, 99999, 0),
    S = world:snapshot(advance(W0, Ticks)),
    ended(maps:get(population, S), Peak, Trough, LinesT, S).

ended(0, _P, _T, _L, _S) -> dead;
ended(Pop, Peak, Trough, LinesT, S) ->
    #{peak => Peak, trough => Trough, linest => LinesT,
      lines => maps:get(lineages, S), pop => Pop}.

%% The trough is looked for AFTER tick 20, because the founding population is
%% itself a minimum before anything has been born and would otherwise be reported
%% as the crash.
arc(_W, T, U, Peak, Trough, L) when T > U -> {Peak, Trough, L};
arc(W, T, U, Peak, Trough, L) ->
    S = world:snapshot(W),
    P = maps:get(population, S),
    Peak1 = max(Peak, P),
    {Trough1, L1} = dip(P > 0 andalso P < Trough andalso T > 20, P,
                        maps:get(lineages, S), Trough, L),
    on(P > 0, W, T, U, Peak1, Trough1, L1).

dip(true, P, Lines, _Trough, _L) -> {P, Lines};
dip(false, _P, _Lines, Trough, L) -> {Trough, L}.

on(false, _W, _T, _U, Peak, Trough, L) -> {Peak, Trough, L};
on(true, W, T, U, Peak, Trough, L) -> arc(world:tick(W, 5), T + 5, U, Peak, Trough, L).

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(500, Left),
    going(world:population(W) > 0, world:tick(W, Step), Left - Step).

going(false, W, _Left) -> W;
going(true, W, Left) -> advance(W, Left).

mean([]) -> 0.0;
mean(L) -> lists:sum(L) / length(L).

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(C, 11, trailing).
