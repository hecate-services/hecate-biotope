#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc IS A WORLD A PURE FUNCTION OF ITS SEED?
%%
%% Everything in this project rests on it. A pre-registered criterion means
%% nothing if the same seed gives a different answer twice, published tables of
%% eleven efficiencies are worthless, and "seed 303 dies" is not a fact about the
%% world but about the afternoon.
%%
%% It has never been asserted. The rng is threaded explicitly and no call in
%% `advance_world' reads a clock or draws unthreaded randomness, so it OUGHT to
%% hold, but ought is not a test.
%%
%% THERE IS ALSO A DISCREPANCY TO EXPLAIN. Seed 303 ended at tick 601 offline and
%% the fleet reported the same seed on the same world ending at 630. Either the
%% island is founded differently from the way these scripts found a world, or
%% this property does not hold.
%%
%% Two things are checked and they are different claims:
%%
%%   REPEATABLE  the same seed run twice in one VM agrees
%%   PATH-FREE   2000 ticks in one call agrees with 2000 ticks taken one at a
%%               time, which is what an island does, one slot at a time
-mode(compile).

-define(TICKS, 2000).
-define(SEEDS, [101, 202, 303, 304, 7, 42]).

main(_) ->
    io:format("~n~s~n", [row(["seed", "repeatable", "path-free", "dead@", "pop",
                              "depth", "burnt"])]),
    lists:foreach(fun check/1, ?SEEDS),
    io:format("~nrepeatable = the same seed twice in one VM.~n"
              "path-free  = ~p ticks in one call against ~p taken one at a "
              "time, which is what~n             an island does.~n",
              [?TICKS, ?TICKS]).

check(Seed) ->
    A = snapshot_of(world:tick(new(Seed), ?TICKS)),
    B = snapshot_of(world:tick(new(Seed), ?TICKS)),
    C = snapshot_of(one_at_a_time(new(Seed), ?TICKS)),
    #{dead := Dead, pop := Pop, depth := Depth, burnt := Burnt} = A,
    io:format("~s~n", [row([Seed, yes_no(A =:= B), yes_no(A =:= C),
                            Dead, Pop, Depth, Burnt])]).

one_at_a_time(W, 0) -> W;
one_at_a_time(W, N) -> one_at_a_time(world:tick(W), N - 1).

new(Seed) ->
    world:new(#{seed => Seed, population => 40, transfer_efficiency => 100}).

%% COMPARED ON WHAT THE WORLD IS, not on the whole term. The record holds an rng
%% state and a brain per creature, and two runs could differ in ways no observer
%% could ever see; what has to agree is everything anybody reports.
snapshot_of(W) ->
    #{population := Pop, ground_total := Ground, energy_total := Energy,
      structure_total := Structure, dissipated := Burnt, born := Born,
      starved := Starved, consumed := Consumed, aged_out := Aged,
      depth := Depth, lineages := Lines, extinct_at := At,
      ground_spread := Spread, from_creatures_pct := Meat} = world:snapshot(W),
    #{pop => Pop, ground => Ground, energy => Energy, structure => Structure,
      burnt => Burnt, born => Born, starved => Starved, consumed => Consumed,
      aged => Aged, depth => Depth, lines => Lines, spread => Spread,
      meat => Meat, dead => dead(At)}.

dead(undefined) -> '-';
dead(At) -> At.

yes_no(true) -> "yes";
yes_no(false) -> "NO".

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) when is_atom(C) -> pad(atom_to_list(C));
pad(C) -> string:pad(C, 12, trailing).
