#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc WHO is alive during world 8's long flat stretch.
%%
%% `extinction_timing.escript' found that world 8 does not dwindle. The rungs at
%% 4, at 2 and at nothing are the same tick, and that tick is 602 at almost every
%% efficiency. A population lost to bad luck does not go out on a schedule, so
%% the flat stretch is a cohort and 602 is `max_age' of 600 arriving.
%%
%% THAT IS A HYPOTHESIS ABOUT IDENTITY AND IT IS DIRECTLY TESTABLE. Founders take
%% the first ids, so counting how many of the first forty are still alive at 595
%% says whether the plateau is the founding or a population that replaced it.
%%
%% IF THE PLATEAU IS THE FOUNDERS, world 8 never had a population. It had a
%% founding that survived, failed to replace itself, and aged out together. The
%% flat line is not stability, it is forty creatures waiting.
%%
%% The births column decides the other half. A world where reproduction merely
%% fails to keep pace looks nothing like one where it stops.
-mode(compile).

-define(SEEDS, 5).
-define(STEPS, [100, 70, 30]).
-define(CENSUS, 595).
-define(EARLY, 200).

main(_) ->
    io:format("~ncensus at t=~p, just before `max_age' of 600 arrives~n~n",
              [?CENSUS]),
    io:format("~s~n", [row(["eff%", "seed", "pop", "founders", "born",
                            "born>~p", "aged", "starved", "frame"])]),
    lists:foreach(fun census/1, ?STEPS),
    io:format("~nfounders = alive of the first 40 ids, which are the founding.~n"
              "born>~p = births after tick ~p, so after the bloom has burnt "
              "out.~n"
              "frame = the largest structure alive.~n", [?EARLY, ?EARLY]).

census(Eff) ->
    Rows = in_parallel(fun(Seed) -> run(Seed, Eff) end, lists:seq(1, ?SEEDS)),
    lists:foreach(fun({Seed, R}) ->
                          io:format("~s~n", [row([Eff, Seed | cells(R)])])
                  end,
                  lists:zip(lists:seq(1, ?SEEDS), Rows)).

cells(#{pop := P, founders := F, born := B, late := L, aged := A, starved := S,
        frame := Fr}) ->
    [P, F, B, L, A, S, Fr].

run(Seed, Eff) ->
    W0 = world:new(#{seed => Seed, population => 40, transfer_efficiency => Eff}),
    Early = world:tick(W0, ?EARLY),
    #{born := BornEarly} = world:snapshot(Early),
    W = world:tick(Early, ?CENSUS - ?EARLY),
    #{population := Pop, born := Born, aged_out := Aged, starved := Starved,
      structure_max := Frame} = world:snapshot(W),
    #{pop => Pop, founders => founders_alive(W), born => Born,
      late => Born - BornEarly, aged => Aged, starved => Starved,
      frame => Frame}.

%% THE FOUNDING TAKES THE FIRST IDS because `populate' runs before any birth can,
%% and `next_id' only ever counts up. So membership of the founding is decidable
%% from the id alone and needs nothing exposed that is not already.
founders_alive(W) ->
    length([Id || Id <- lists:seq(1, 40), world:alive(Id, W)]).

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
pad(C) -> string:pad(C, 10, trailing).
