#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc HOW FAST THE FOUNDING LINES DISAPPEAR, over time rather than at the end.
%%
%% Everything published about this so far is a number at one horizon: nine seeds
%% of twelve reach 20,000 ticks and every one of them is down to ONE founding
%% line of forty. That says where it ends and nothing about the road.
%%
%% The road is what a spectator sees. A live island at a few hundred ticks
%% sitting at two or five lines looks like it has stopped falling, and there is
%% no published curve to say whether that is early, late or unusual. This is the
%% curve.
%%
%% WHAT TO EXPECT, so the measurement can disagree with it. Lineage loss in an
%% asexual population is the coalescent (Kingman 1982): under drift alone the
%% expected time for N lines to fall to one is of order the population size in
%% GENERATIONS, and generations here are short. Selective sweeps make it faster,
%% and with no recombination every beneficial mutation drags its whole line to
%% fixation, so faster is what the 20,000-tick numbers already imply.
%%
%% A steep early drop and a long tail is therefore the shape to expect: most
%% lines are lost almost immediately because most foundings leave no descendants
%% at all, and the last few take much longer because each survivor is by then a
%% large share of the population.
-mode(compile).

-define(SEEDS, 6).
-define(TICKS, 4000).
-define(STRIDE, 100).

main(_) ->
    io:format("~n~p seeds, sampled every ~p ticks. Founding lines of 40 still "
              "represented.~n~n", [?SEEDS, ?STRIDE]),
    Runs = in_parallel(fun trace/1, lists:seq(1, ?SEEDS)),
    io:format("~s~n", [row(["tick" | ["s" ++ integer_to_list(S)
                                      || S <- lists:seq(1, ?SEEDS)]])]),
    lists:foreach(fun(I) ->
                          io:format("~s~n", [row([I * ?STRIDE | column(I, Runs)])])
                  end,
                  lists:seq(0, ?TICKS div ?STRIDE)),
    io:format("~nA dash is a world that had already ended.~n").

trace(Seed) ->
    W = world:new(#{seed => Seed, population => 40,
                    transfer_efficiency => 100}),
    sample(W, ?TICKS div ?STRIDE, [lines(W)]).

sample(_W, 0, Acc) -> lists:reverse(Acc);
sample(W, N, Acc) ->
    Next = world:tick(W, ?STRIDE),
    sample(Next, N - 1, [lines(Next) | Acc]).

lines(W) ->
    #{lineages := L, population := P} = world:snapshot(W),
    at_least_one(P, L).

at_least_one(0, _L) -> '-';
at_least_one(_P, L) -> L.

column(I, Runs) -> [at(I, R) || R <- Runs].

at(I, Samples) when I < length(Samples) -> lists:nth(I + 1, Samples);
at(_I, _Samples) -> '-'.

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
pad(C) when is_atom(C) -> pad(atom_to_list(C));
pad(C) -> string:pad(C, 8, trailing).
