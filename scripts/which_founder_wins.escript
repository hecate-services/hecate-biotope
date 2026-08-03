#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc IS THE SURVIVING FOUNDER CHOSEN, OR IS IT DECIDED?
%%
%% Usage:  ./scripts/which_founder_wins.escript [seeds [ticks]]
%%
%% `lineages` reads 1 in every world, at every price, in every sweep this project
%% has run. `G.1` says that is the null expectation, because all lineages in a
%% finite asexual population coalesce to one ancestor eventually (Kingman 1982),
%% and it notes ours arrive faster than drift alone predicts.
%%
%% RAF'S SUSPICION IS DIFFERENT AND SHARPER: that it is not drift and not
%% selection but a DETERMINISTIC DIMENSION. **Every phase of the tick folds over
%% `lists:sort(maps:keys(Cs))`**, so creatures are processed in id order, and the
%% forty founders hold ids 1 to 40. If low ids are systematically advantaged then
%% the winner is decided by the fold and not by the world, and every result about
%% lineages, depth and `F_ST` is reading an artefact.
%%
%% ⚠ THE TEST IS THE DISTRIBUTION OF THE WINNER, NOT ITS EXISTENCE. That one
%% founder survives says nothing: coalescence guarantees it. What says everything
%% is WHICH one. Uniform over 1 to 40 means drift or selection. Piled on the low
%% ids means the fold.
%%
%% It also reports `births_refused`, because a binding `max_creatures` would
%% grant births in id order and be a second such dimension. At 6,000 against
%% populations near 100 it should be exactly zero, and a number that should be
%% zero is worth printing rather than assuming.
-mode(compile).

main(Args) ->
    Seeds = arg(Args, 1, 60),
    Ticks = arg(Args, 2, 20000),
    io:format("~n~p seeds to ~p ticks. Founders are ids 1 to 40 and the tick "
              "folds over sorted ids,~nso a low-id bias would mean the winner is "
              "decided by the fold rather than the world.~n~n", [Seeds, Ticks]),
    Rows = [run(S, Ticks) || S <- lists:seq(1, Seeds)],
    Won = [L || {alive, L, _R} <- Rows],
    Refused = [R || {alive, _L, R} <- Rows],
    report(Won, Refused, length(Rows)).

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.

run(Seed, Ticks) ->
    W = advance(world:new(#{seed => Seed, population => 40,
                            transfer_efficiency => 100}), Ticks),
    survivor(world:creatures(W), world:snapshot(W)).

survivor(Cs, _Snap) when map_size(Cs) =:= 0 -> dead;
survivor(Cs, Snap) ->
    Lines = lists:usort([maps:get(lineage, C) || C <- maps:values(Cs)]),
    {alive, Lines, maps:get(births_refused, Snap)}.

report([], _Refused, Total) ->
    io:format("All ~p seeds died. No survivor to attribute.~n", [Total]);
report(Won, Refused, Total) ->
    Single = [L || [L] <- Won],
    io:format("~p of ~p seeds survived. ~p of those are down to ONE founding "
              "line.~n", [length(Won), Total, length(Single)]),
    io:format("births refused across all survivors: ~p~n~n",
              [lists:sum(Refused)]),
    io:format("~s~n", [row(["founder", "won", "bar"])]),
    Tally = tally(Single),
    [io:format("~s~n", [row([F, C, bar(C)])])
     || {F, C} <- lists:sort(maps:to_list(Tally))],
    verdict(Single).

%% THE ARITHMETIC, PLAINLY. Under "the winner is a fair draw from the forty
%% founders", the expected mean founder id is 20.5 and the expected share landing
%% in the bottom quarter, ids 1 to 10, is 25%.
verdict(Single) ->
    N = length(Single),
    Mean = lists:sum(Single) / max(1, N),
    Low = length([F || F <- Single, F =< 10]) * 100 / max(1, N),
    Top = length([F || F <- Single, F > 30]) * 100 / max(1, N),
    %% `~.0f' is not a format Erlang accepts and this is the third script today
    %% to crash on it AFTER printing its table. Rounded to an integer instead.
    io:format("~nmean winning founder ~.1f, against 20.5 if it were a fair "
              "draw.~nids 1 to 10 took ~w% of wins and ids 31 to 40 took "
              "~w%, against 25% each.~n~n~s~n",
              [Mean, round(Low), round(Top), call(Mean, N)]).

call(_Mean, N) when N < 8 ->
    "TOO FEW SURVIVORS TO SAY. Run more seeds before reading the shape above:\n"
    "this world kills most of what it is given and the winners are the sample.";
call(Mean, _N) when Mean < 14.0 ->
    "PILED ON THE LOW IDS. The fold is deciding the winner, not the world, and\n"
    "every result about lineages, depth and F_ST is reading an artefact of\n"
    "processing creatures in sorted id order.";
call(Mean, _N) when Mean > 27.0 ->
    "PILED ON THE HIGH IDS, which is the same fault with the opposite sign and\n"
    "just as disqualifying.";
call(_Mean, _N) ->
    "NO ID BIAS VISIBLE. The winner looks like a fair draw from the founders, so\n"
    "coalescence here is drift or selection rather than the fold. That does not\n"
    "make it interesting, it makes it Kingman.".

tally(Ls) ->
    lists:foldl(fun(L, Acc) -> maps:update_with(L, fun(C) -> C + 1 end, 1, Acc) end,
                #{}, Ls).

bar(N) -> lists:duplicate(N, $#).

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(1000, Left),
    going(world:population(W) > 0, world:tick(W, Step), Left - Step).

going(false, W, _Left) -> W;
going(true, W, Left) -> advance(W, Left).

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(C, 10, trailing).
