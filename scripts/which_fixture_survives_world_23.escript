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
main(_) ->
    io:format("~-6s ~-6s ~-6s ~-8s ~-10s ~-8s ~-8s~n",
              ["seed", "pop", "kinds", "ratio", "born@4000", "disc", "born/disc"]),
    lists:foreach(fun report/1, [3, 7, 11, 23, 42, 55, 77, 91, 101, 137]).

report(Seed) ->
    Short = world:tick(world:new(#{seed => Seed, population => 40}), 600),
    #{kind_of := Kinds} = world:chart(Short),
    Pop = length(Kinds),
    Distinct = length(lists:usort(Kinds)),
    Long = world:tick(world:new(#{seed => Seed, population => 40}), 4000),
    #{archive := Flat, born := Born} = world:snapshot(Long),
    Disc = length(Flat) div 3,
    io:format("~-6w ~-6w ~-6w ~-8s ~-10w ~-8w ~-8s~n",
              [Seed, Pop, Distinct, ratio(Pop, Distinct), Born, Disc,
               ratio(Born, Disc)]).

ratio(_A, 0) -> "-";
ratio(A, B) -> io_lib:format("~.2fx", [A / B]).
