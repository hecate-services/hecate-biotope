#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc WHEN world 8 dies, which decides what its extinction means.
%%
%% The sweep reported 5 seeds of 5 extinct at every efficiency and stopped there,
%% because `summarise' only describes the seeds still alive and a dead one
%% contributes a tally mark. So the world was known to end and not known when.
%%
%% THE TWO READINGS ARE DIFFERENT FINDINGS. A population that falls to about 16,
%% holds, and then goes out is a viable world losing a small population to bad
%% luck, and 16 is small enough for that to be ordinary. A population that keeps
%% grinding down until nothing is left is a world that cannot support life at
%% all, and the holding is just the slow part of the fall. The first says the
%% capacity rule left too little room. The second says it took something the
%% world needed.
%%
%% THE DESCENT LADDER SEPARATES THEM. Record the first tick the population falls
%% below each of 16, 8, 4, 2 and 1. Spread those rungs evenly over hundreds of
%% ticks and it is a ratchet. Bunch them at the end after a long flat stretch and
%% it is a plateau that finally lost a coin toss.
%%
%% `extinct_at' IS ALREADY IN THE SNAPSHOT and always was. Nothing here is new
%% instrumentation, it is reading a number the world has been keeping since the
%% capacity rule went in.
%%
%% The founding matches sweep_efficiency.escript exactly, so these rows describe
%% the runs that produced the sweep table rather than a neighbouring world.
-mode(compile).

-define(TICKS, 2000).
-define(SEEDS, 5).
-define(STEPS, [100, 95, 90, 80, 70, 60, 50, 40, 30, 20, 10]).
-define(RUNGS, [16, 8, 4, 2, 1]).
-define(TRACED, 100).
-define(SAMPLE, 20).

main(_) ->
    io:format("~nticks=~p seeds=~p~n", [?TICKS, ?SEEDS]),
    ladder(),
    trajectory().

%%==============================================================================
%% Every efficiency, every seed, when it ended and how it got there
%%==============================================================================

ladder() ->
    io:format("~nDESCENT: the tick population first falls below each rung.~n~n"),
    io:format("~s~n", [row(["eff%", "seed", "peak", "peak@", "plateau",
                            "<16", "<8", "<4", "<2", "dead@"])]),
    lists:foreach(fun ladder_row/1, ?STEPS),
    io:format("~nplateau = median population over the middle half of the run, "
              "which is the level it~nheld at rather than any level it passed "
              "through. dead@ = `extinct_at', a - means it~nreached ~p alive.~n",
              [?TICKS]).

ladder_row(Eff) ->
    Runs = in_parallel(fun(Seed) -> trace(Seed, Eff) end, lists:seq(1, ?SEEDS)),
    lists:foreach(fun({Seed, Pops}) ->
                          io:format("~s~n", [row([Eff, Seed | describe(Pops)])])
                  end,
                  lists:zip(lists:seq(1, ?SEEDS), Runs)).

describe(Pops) ->
    {Peak, PeakAt} = peak(Pops),
    [Peak, PeakAt, plateau(Pops)] ++
        [rung(N, Pops) || N <- ?RUNGS, N > 1] ++ [ended(Pops)].

%% THE PEAK IS THE BLOOM and is not the world, so it is reported apart from the
%% level that follows it. Founding at 40 into an untouched ground buys one
%% generation of plenty that nothing afterwards can repeat.
peak(Pops) ->
    Best = lists:max(Pops),
    {Best, index_of(Best, Pops)}.

%% MEDIAN OVER THE MIDDLE HALF, so the bloom at the front and the collapse at the
%% back both fall outside it. A mean would let either end move the number.
plateau(Pops) ->
    Len = length(Pops),
    median(lists:sublist(Pops, Len div 4 + 1, Len div 2)).

rung(N, Pops) ->
    below(N, Pops, 0).

below(_N, [], _T) -> '-';
below(N, [P | _], T) when P < N -> T;
below(N, [_ | Rest], T) -> below(N, Rest, T + 1).

ended(Pops) ->
    below(1, Pops, 0).

%%==============================================================================
%% One efficiency in full, because a ladder is a summary of a shape
%%==============================================================================

trajectory() ->
    io:format("~nSHAPE at ~p% efficiency, sampled every ~p ticks. 100 is the "
              "control and is world 6~nexactly apart from the capacity rule, so "
              "nothing here is lost to a lossy transfer.~n~n",
              [?TRACED, ?SAMPLE]),
    Runs = in_parallel(fun(Seed) -> sample(Seed, ?TRACED) end,
                       lists:seq(1, ?SEEDS)),
    io:format("~s~n", [row(["tick" | ["s" ++ integer_to_list(S) ++ "pop"
                                      || S <- lists:seq(1, ?SEEDS)]])]),
    lists:foreach(fun(I) ->
                          io:format("~s~n", [row([I * ?SAMPLE | column(I, Runs)])])
                  end,
                  lists:seq(0, longest(Runs) - 1)),
    io:format("~nA blank is a seed already extinct at that tick.~n").

column(I, Runs) ->
    [at(I, R) || R <- Runs].

at(I, Samples) when I < length(Samples) -> lists:nth(I + 1, Samples);
at(_I, _Samples) -> ''.

longest(Runs) -> lists:max([length(R) || R <- Runs]).

%%==============================================================================
%% Running the world
%%==============================================================================

%% ONE TICK AT A TIME AND ONLY `population' READ, which is a `map_size' rather
%% than a snapshot. The trajectory costs what the run costs.
trace(Seed, Eff) ->
    collect(found(Seed, Eff), ?TICKS, []).

collect(_W, 0, Acc) -> lists:reverse(Acc);
collect(W, N, Acc) ->
    case world:population(W) of
        0 -> lists:reverse([0 | Acc]);
        P -> collect(world:tick(W), N - 1, [P | Acc])
    end.

sample(Seed, Eff) ->
    every(found(Seed, Eff), ?TICKS div ?SAMPLE, []).

every(_W, 0, Acc) -> lists:reverse(Acc);
every(W, N, Acc) ->
    case world:population(W) of
        0 -> lists:reverse(Acc);
        P -> every(world:tick(W, ?SAMPLE), N - 1, [P | Acc])
    end.

found(Seed, Eff) ->
    world:new(#{seed => Seed, population => 40, transfer_efficiency => Eff}).

%%==============================================================================

in_parallel(F, Items) ->
    Parent = self(),
    Refs = [spawn_one(Parent, F, I) || I <- Items],
    [receive {Ref, Result} -> Result end || Ref <- Refs].

spawn_one(Parent, F, Item) ->
    Ref = make_ref(),
    spawn_link(fun() -> Parent ! {Ref, F(Item)} end),
    Ref.

index_of(V, L) -> index_of(V, L, 0).

index_of(V, [V | _], I) -> I;
index_of(V, [_ | Rest], I) -> index_of(V, Rest, I + 1).

median([]) -> 0;
median(L) -> lists:nth(length(L) div 2 + 1, lists:sort(L)).

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) when is_atom(C) -> pad(atom_to_list(C));
pad(C) -> string:pad(C, 9, trailing).
