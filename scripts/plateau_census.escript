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
-define(SWEEP, [100, 95, 90, 80, 70, 60, 50, 40, 30, 20, 10]).
-define(CENSUS, 595).
-define(EARLY, 200).
-define(YOUNG, 20).

main(_) ->
    ghosts(),
    plateau().

%%==============================================================================
%% The pre-registered question, asked while the world is still populated
%%==============================================================================

%% WORLD 8 WAS PRE-REGISTERED ON `structure_max' ACROSS THE SWEEP, and the sweep
%% reports at tick 2000 where every seed is dead and every column reads "-". A
%% measurement taken after the last death answers nothing, so it is taken here at
%% tick ~p instead, which is before the earliest extinction in any seed at any
%% efficiency.
ghosts() ->
    io:format("~nLARGEST FRAME ALIVE at t=~p, across the whole sweep. World 7 had "
              "this at ZERO~nfrom 70% down, which is the measurement world 8 "
              "exists to repeat.~n~n", [?YOUNG]),
    io:format("~s~n", [row(["eff%", "frame", "pop", "born", "still%"])]),
    lists:foreach(fun young/1, ?SWEEP),
    io:format("~nMedian of ~p seeds. still% was pre-registered as the one that "
              "would NOT move.~n", [?SEEDS]).

young(Eff) ->
    Rows = in_parallel(fun(Seed) -> at_young(Seed, Eff) end,
                       lists:seq(1, ?SEEDS)),
    io:format("~s~n", [row([Eff,
                            median([F || #{frame := F} <- Rows]),
                            median([P || #{pop := P} <- Rows]),
                            median([B || #{born := B} <- Rows]),
                            median([S || #{still := S} <- Rows])])]).

at_young(Seed, Eff) ->
    #{structure_max := F, population := P, born := B, still_pct := St} =
        world:snapshot(world:tick(founded(Seed, Eff), ?YOUNG)),
    #{frame => F, pop => P, born => B, still => St}.

founded(Seed, Eff) ->
    world:new(#{seed => Seed, population => 40, transfer_efficiency => Eff}).

%%==============================================================================

plateau() ->
    io:format("~n~ncensus at t=~p, just before `max_age' of 600 arrives~n~n",
              [?CENSUS]),
    io:format("~s~n", [row(["eff%", "seed", "pop", "founders", "born",
                            "born>~p", "starved", "frame", "store",
                            "refused", "life"])]),
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

cells(#{pop := P, founders := F, born := B, late := L, starved := S,
        frame := Fr, store := St, refused := R}) ->
    [P, F, B, L, S, Fr, St, R, life(P, B)].

%% MEAN LIFESPAN BY LITTLE'S LAW, in hundredths, with the deaths counted by
%% conservation of individuals rather than by summing the world's three death
%% counters: everything ever born or founded is either alive now or dead.
%%
%% World 6 and world 7 both came out at 2.2 ticks and this is the number world 8
%% was pre-registered to move. It moves, and the results file argues that the
%% movement means the opposite of what was wanted.
life(Pop, Born) -> scaled(Pop * ?CENSUS * 100, Born + 40 - Pop).

scaled(_Num, 0) -> 0;
scaled(Num, Deaths) -> Num div Deaths.

run(Seed, Eff) ->
    Early = world:tick(founded(Seed, Eff), ?EARLY),
    #{born := BornEarly} = world:snapshot(Early),
    W = world:tick(Early, ?CENSUS - ?EARLY),
    #{population := Pop, born := Born, starved := Starved, energy_max := Store,
      births_refused := Refused, structure_max := Frame} = world:snapshot(W),
    #{pop => Pop, founders => founders_alive(W), born => Born,
      late => Born - BornEarly, starved => Starved, frame => Frame,
      store => Store, refused => Refused}.

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

median([]) -> 0;
median(L) -> lists:nth(length(L) div 2 + 1, lists:sort(L)).

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(C, 10, trailing).
