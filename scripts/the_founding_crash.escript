#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc WHY DOES ONLY ONE FOUNDING LINE SURVIVE?
%%
%% Usage:  ./scripts/the_founding_crash.escript [seeds]
%%
%% `lineages` has read 1 in every world since world 9 and `G.1` has carried the
%% question ever since. Its amendment answers with Kingman: all lineages in a
%% finite asexual population coalesce eventually, and ours arrive faster than
%% drift, which is the signature of selective sweeps.
%%
%% **THAT IS AN ANSWER ABOUT THE WRONG PHASE.** Every sweep in this project reads
%% `lineages` at 20,000 ticks. Coalescence completes by about 1,500, and 80% of
%% it happens in the first NINETY, during a founding boom-and-bust nobody has
%% looked at because nothing samples there.
%%
%% Forty founders start with `start_energy` of 800, twice what a full cell holds,
%% and breed at once. Measured on one live island's seed: 945 born in ten ticks,
%% the population reaching 252 on a 1,261-cell board, and 1,562 starved by tick
%% fifty. Lineages track it exactly: 40, 39, 37, 30, 21, 8.
%%
%% This measures whether that generalises, and the test is sharp: **if the crash
%% is what destroys the lineages, the count at the trough equals the number of
%% creatures at the trough**, because every survivor is then the last of its line.
-mode(compile).
main(Args) ->
    N = case Args of [] -> 24; [A|_] -> list_to_integer(A) end,
    io:format("~n~p seeds. PEAK is the founding boom, TROUGH the crash after it.~n"
              "If the crash is what destroys the lineages, LINES@500 tracks the "
              "TROUGH~nand not the peak.~n~n", [N]),
    io:format(" seed  peak  @t   TROUGH  @t   lines@trough  lines@500  pop@500~n"),
    Rows = [row(S) || S <- lists:seq(1, N)],
    Live = [R || R <- Rows, R =/= dead],
    summary(Live).
row(Seed) ->
    W0 = world:new(#{seed => Seed}),
    {Peak, PeakT, Trough, TroughT, LinesAt} = arc(W0, 0, 400, {0,0}, {99999,0}, 0),
    W500 = adv(W0, 500),
    S = world:snapshot(W500),
    out(Seed, Peak, PeakT, Trough, TroughT, LinesAt, S, maps:get(population, S)).
out(Seed, _P, _Pt, _Tr, _Tt, _L, _S, 0) ->
    io:format(" ~-5w dead by 500~n", [Seed]), dead;
out(Seed, P, Pt, Tr, Tt, L, S, Pop) ->
    io:format(" ~-5w ~-5w ~-4w ~-7w ~-4w ~-13w ~-10w ~w~n",
              [Seed, P, Pt, Tr, Tt, L, maps:get(lineages, S), Pop]),
    #{trough => Tr, lines => maps:get(lineages, S), linest => L, peak => P}.
arc(_W, T, U, Pk, Tr, L) when T > U -> {element(1,Pk), element(2,Pk), element(1,Tr), element(2,Tr), L};
arc(W, T, U, Pk, Tr, L) ->
    S = world:snapshot(W),
    P = maps:get(population, S),
    Pk1 = case P > element(1, Pk) of true -> {P, T}; false -> Pk end,
    {Tr1, L1} = case P < element(1, Tr) andalso T > 20 andalso P > 0 of
                    true -> {{P, T}, maps:get(lineages, S)}; false -> {Tr, L} end,
    cont(P > 0, W, T, U, Pk1, Tr1, L1).
cont(false, _W, T, _U, Pk, Tr, L) -> {element(1,Pk), element(2,Pk), element(1,Tr), T, L};
cont(true, W, T, U, Pk, Tr, L) -> arc(world:tick(W, 5), T + 5, U, Pk, Tr, L).
adv(W, 0) -> W;
adv(W, N) -> a(world:population(W) > 0, W, N).
a(false, W, _N) -> W;
a(true, W, N) -> adv(world:tick(W, min(50, N)), N - min(50, N)).
summary([]) -> io:format("~nall dead~n");
summary(Rows) ->
    io:format("~n~p survived to 500.~n", [length(Rows)]),
    io:format("mean trough ~.1f, mean lines at the trough ~.1f, mean lines at 500 ~.1f~n",
              [mean([maps:get(trough,R)||R<-Rows]), mean([maps:get(linest,R)||R<-Rows]),
               mean([maps:get(lines,R)||R<-Rows])]),
    io:format("mean PEAK ~.1f, so the boom is ~.1fx the trough.~n",
              [mean([maps:get(peak,R)||R<-Rows]),
               mean([maps:get(peak,R)||R<-Rows]) / max(1.0, mean([maps:get(trough,R)||R<-Rows]))]).
mean([]) -> 0.0;
mean(L) -> lists:sum(L) / length(L).
