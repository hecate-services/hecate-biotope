#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% TWO LIFESPANS, AND EVERY GATE IN THIS PROJECT USED THE SMALLER ONE.
%%
%% `does_a_longer_life_buy_a_brain.escript' computes LIFE as
%% `population x ticks / deaths', which is the mean residence time over
%% EVERYTHING EVER BORN. It reads about ten ticks, and ten ticks at one cell per
%% tick is the number behind every "can a creature physically respond within one
%% life" gate this project has run, including the one that concluded thirst was
%% unbuildable (`I.17').
%%
%% `age_mean' in the snapshot is the mean age of the creatures ALIVE RIGHT NOW.
%% It reads about eighty.
%%
%% ⚠ BOTH ARE CORRECT AND THEY ANSWER DIFFERENT QUESTIONS. The gap is infant
%% mortality: most births die at once, so the birth-weighted mean describes a
%% NEWBORN'S prospects, while the living population is made of the ones that got
%% through. A gate asking whether a creature can cross five cells to reach water
%% is asking about a creature that is going to live, and that is the second
%% number.
%%
%% This measures both, on the same worlds, so a gate can say which it means.
-mode(compile).

main(Args) ->
    Seeds = arg(Args, 1, 24),
    Ticks = arg(Args, 2, 8000),
    io:format("~n~p seeds to ~p ticks.~n~n", [Seeds, Ticks]),
    io:format("~-16s ~-8s ~-16s ~-16s ~-8s~n",
              ["world", "alive", "LIFE per birth", "AGE of the living",
               "ratio"]),
    [arm(A, Seeds, Ticks) || A <- [{world_22, 0}, {world_23, dflt}]],
    io:format("~nLIFE per birth is population x ticks / deaths, over everything "
              "ever born.~nAGE of the living is the mean age of the creatures "
              "standing on the board.~n").

arm({Name, Thirst}, Seeds, Ticks) ->
    Rows = in_parallel(fun(S) -> run(S, Thirst, Ticks) end, lists:seq(1, Seeds)),
    Live = [N || #{population := P} = N <- Rows, P > 0],
    Life = median([life(N, Ticks) || N <- Live]),
    Age = median([maps:get(age_mean, N) || N <- Live]),
    io:format("~-16w ~-8w ~-16s ~-16w ~-8s~n",
              [Name, length(Live), hundredths(Life), Age, ratio(Age, Life)]).

%% The same formula `does_a_longer_life_buy_a_brain.escript' uses, so the two
%% tables are comparable. 40 founders are added back because they were never
%% born here.
life(#{population := Pop, born := Born}, Ticks) ->
    scaled(Pop * Ticks * 100, Born + 40 - Pop).

scaled(_Num, D) when D =< 0 -> 0;
scaled(Num, D) -> Num div D.

run(Seed, Thirst, Ticks) ->
    W = world:new(econ(Thirst, #{seed => Seed, population => 40})),
    world:snapshot(advance(W, Ticks)).

econ(dflt, Base) -> Base;
econ(Thirst, Base) -> Base#{thirst => Thirst}.

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(500, Left),
    going(world:population(W) > 0, world:tick(W, Step), Left - Step).

going(false, W, _Left) -> W;
going(true, W, Left) -> advance(W, Left).

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.

in_parallel(F, Items) ->
    Parent = self(),
    Refs = [spawn_one(Parent, F, I) || I <- Items],
    [receive {Ref, Result} -> Result end || Ref <- Refs].

spawn_one(Parent, F, Item) ->
    Ref = make_ref(),
    spawn_link(fun() -> Parent ! {Ref, F(Item)} end),
    Ref.

median([]) -> 0;
median(L) -> lists:nth(length(L) div 2 + 1, lists:sort(L)).

ratio(_Age, 0) -> "-";
ratio(Age, Life) -> io_lib:format("~.1fx", [Age * 100 / Life]).

hundredths(V) -> io_lib:format("~w.~2..0w", [V div 100, V rem 100]).
