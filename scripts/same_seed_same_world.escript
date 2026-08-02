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
%% ==========================================================================
%% AND THE DISCREPANCY ABOVE WAS THIS PROPERTY FAILING. RESOLVED 2026-08-02.
%% ==========================================================================
%%
%% Seed 303 really did end at 601 here and at 630 on the fleet, and the reason is
%% that the first two columns CANNOT SEE THE FAILURE. Both compare runs inside
%% ONE VM, where the atom table is already whatever it is, so both said yes for
%% seventeen worlds while the property was false.
%%
%% `brain:nudge_all/3' drew a random number per weight walking `maps:to_list' of
%% a map keyed by purpose ATOMS, and `world:consume/1' resolved cells in
%% `maps:values' order and fed a cell's occupants in `maps:fold' order. None of
%% those orders is promised, and the one you get depends on VM-global state.
%% Measured: running `brain_tests' before the same computation moved a world's
%% energy at TICK ONE, 14,588 to 14,590, same seed, same beams, same economy. A
%% release and a script load modules in different orders, so THE FLEET AND THE
%% LABORATORY WERE RUNNING DIFFERENT PHYSICS, which is exactly what seed 303 said
%% and nobody believed. See register `G.6'.
%%
%% Three things are checked now and they are different claims:
%%
%%   REPEATABLE  the same seed run twice in one VM agrees
%%   PATH-FREE   2000 ticks in one call agrees with 2000 ticks taken one at a
%%               time, which is what an island does, one slot at a time
%%   CROSS-VM    two SEPARATE operating-system processes agree, one of which
%%               loads the world's modules in the opposite order. This is the
%%               only column that could ever have caught the real fault, and it
%%               costs two subprocesses per seed.
-mode(compile).

-define(TICKS, 2000).
-define(SEEDS, [101, 202, 303, 304, 7, 42]).
-define(MODULES, [world, ground, body, brain, scent, hex]).

main(["--fingerprint", SeedStr, Order]) ->
    preload(Order),
    Seed = list_to_integer(SeedStr),
    io:format("~p~n", [erlang:phash2(snapshot_of(world:tick(new(Seed), ?TICKS)))]);
main(_) ->
    io:format("~n~s~n", [row(["seed", "repeatable", "path-free", "cross-vm",
                              "dead@", "pop", "depth", "burnt"])]),
    lists:foreach(fun check/1, ?SEEDS),
    io:format("~nrepeatable = the same seed twice in one VM.~n"
              "path-free  = ~p ticks in one call against ~p taken one at a "
              "time, which is what~n             an island does.~n"
              "cross-vm   = two separate OS processes, one loading the world's "
              "modules in~n             reverse order. The only column that "
              "sees an ordering fault.~n",
              [?TICKS, ?TICKS]).

%% Loading in a different order is what makes the two subprocesses different
%% VMs rather than two copies of one. It is the cheapest available proxy for
%% "a release and a script", which is where the fault actually showed.
preload("reverse") -> [code:ensure_loaded(M) || M <- lists:reverse(?MODULES)];
preload(_Forward) -> [code:ensure_loaded(M) || M <- ?MODULES].

check(Seed) ->
    A = snapshot_of(world:tick(new(Seed), ?TICKS)),
    B = snapshot_of(world:tick(new(Seed), ?TICKS)),
    C = snapshot_of(one_at_a_time(new(Seed), ?TICKS)),
    #{dead := Dead, pop := Pop, depth := Depth, burnt := Burnt} = A,
    io:format("~s~n", [row([Seed, yes_no(A =:= B), yes_no(A =:= C),
                            yes_no(cross_vm(Seed)), Dead, Pop, Depth, Burnt])]).

cross_vm(Seed) ->
    fingerprint(Seed, "forward") =:= fingerprint(Seed, "reverse").

fingerprint(Seed, Order) ->
    string:trim(os:cmd(io_lib:format("~s --fingerprint ~p ~s",
                                     [escript:script_name(), Seed, Order]))).

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
