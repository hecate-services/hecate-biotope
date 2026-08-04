#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% WHICH SEED STILL MAKES A USABLE TEST FIXTURE.
%%
%% World 23 kills more creatures, so two fixtures chosen by running world 22 no
%% longer hold what their tests need:
%%
%%   watch_island_tests   needs a board where KINDS ARE SHARED, or colouring by
%%                        position and colouring by kind are indistinguishable
%%                        and every assertion passes vacuously.
%%   record_discoveries   needs a run where BIRTHS DWARF DISCOVERIES, which is
%%                        the volume argument the notebook rests on.
%%
%% This reports both for a range of seeds so the replacement is measured rather
%% than guessed at. `I.9': a fixture chosen because it made a test pass is the
%% same mistake as a constant chosen because it made a result look good, so the
%% criterion is stated here and every seed is printed.
%% ⚠ TAKES A RANGE, BECAUSE THIS HAS NOW RUN SIX TIMES. Every change to the
%% world invalidates every fixture chosen by running the world, and a hand-picked
%% list of ten seeds ran out of usable ones when the water budget moved: not one
%% of them met the kind-sharing ratio the colour test needs.
main(Args) ->
    Upto = case Args of [N | _] -> list_to_integer(N); _ -> 60 end,
    io:format("~-6s ~-6s ~-6s ~-8s ~-10s ~-8s ~-8s~n",
              ["seed", "pop", "kinds", "ratio", "born@4000", "disc", "born/disc"]),
    lists:foreach(fun report/1, lists:seq(1, Upto)).

report(Seed) ->
    Short = world:tick(world:new(#{seed => Seed, population => 40}), 600),
    #{kind_of := Kinds} = world:chart(Short),
    Pop = length(Kinds),
    Distinct = length(lists:usort(Kinds)),
    Long = world:tick(world:new(#{seed => Seed, population => 40}), 4000),
    #{archive := Flat, born := Born} = world:snapshot(Long),
    Disc = length(Flat) div 3,
    %% Only the usable ones are printed once a range is being scanned: a
    %% fixture needs a live board with SHARED kinds, and a dead seed says
    %% nothing except that it died.
    usable(Pop > 40 andalso Distinct > 8 andalso Pop > 4 * Distinct,
           Seed, Pop, Distinct, Born, Disc).

usable(false, _Seed, _Pop, _Distinct, _Born, _Disc) -> ok;
usable(true, Seed, Pop, Distinct, Born, Disc) ->
    io:format("~-6w ~-6w ~-6w ~-8s ~-10w ~-8w ~-8s~n",
              [Seed, Pop, Distinct, ratio(Pop, Distinct), Born, Disc,
               ratio(Born, Disc)]).

ratio(_A, 0) -> "-";
ratio(A, B) -> io_lib:format("~.2fx", [A / B]).
