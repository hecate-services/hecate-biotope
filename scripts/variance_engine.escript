#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc WHEN THIS WORLD STOPS BEING ABLE TO CHANGE, which is not when it dies.
%%
%% Fisher's fundamental theorem prices adaptation in the variance available to
%% select on. No variance, no adaptation, and no rule anywhere else in the world
%% can substitute for it. Every world from 1 to 8 has reported what the
%% population was and none has reported whether it could still become anything
%% else.
%%
%% World 8 is the case that forces the distinction. It ends at tick 602 with four
%% to sixteen creatures carrying two hundred times the energy they were born
%% with. Nothing about that is a shortage. What it has run out of is variation:
%% the only operator that produces any is birth, selection during the bloom
%% favoured the founders that never bred, and after that the population cannot
%% change no matter what it is worth.
%%
%% THE NUMBER THAT MATTERS IS THE LAST BIRTH, because everything after it is a
%% world running with the engine off. Set beside the tick it finally dies, it
%% says how much of a run was already decided.
%%
%% `depth' IS THE ONE TO WATCH. It counts generations in the deepest surviving
%% line. Zero means every creature alive is a founder, so the world has selected
%% nothing at all: it filtered its founding once and stopped. A world that cannot
%% get past zero is not doing evolution, whatever else it is doing.
-mode(compile).

-define(SEEDS, 5).
-define(TICKS, 700).
-define(STRIDE, 5).
-define(STEPS, [100, 70, 30]).
-define(TRACED, 100).
-define(SAMPLE, 20).

main(_) ->
    frozen(),
    trajectory().

%%==============================================================================
%% How long the engine ran, against how long the world did
%%==============================================================================

frozen() ->
    io:format("~nTHE ENGINE, over ~p ticks~n~n", [?TICKS]),
    io:format("~s~n", [row(["eff%", "seed", "lastbirth", "deepever", "deepend",
                            "lines", "spread", "dead@", "frozen"])]),
    lists:foreach(fun frozen_rows/1, ?STEPS),
    io:format("~nlastbirth = last tick a birth happened, to within ~p.~n"
              "deepever = deepest generation ever ALIVE. deepend = deepest still "
              "alive at the end,~nwhere 0 means nothing but founders. lines = "
              "foundings still represented of 40.~nspread = uptake max minus min "
              "among the living. frozen = ticks between the last~nbirth and the "
              "end, which is how much of the run was already decided.~n",
              [?STRIDE]).

frozen_rows(Eff) ->
    Runs = in_parallel(fun(Seed) -> engine(Seed, Eff) end, lists:seq(1, ?SEEDS)),
    lists:foreach(fun({Seed, R}) ->
                          io:format("~s~n", [row([Eff, Seed | cells(R)])])
                  end,
                  lists:zip(lists:seq(1, ?SEEDS), Runs)).

cells(#{last := L, ever := E, ended := D, lines := N, spread := S, dead := Dead}) ->
    [L, E, D, N, S, Dead, Dead - L].

engine(Seed, Eff) ->
    W = world:new(#{seed => Seed, population => 40, transfer_efficiency => Eff}),
    Empty = #{last => 0, ever => 0, ended => 0, lines => 0, spread => 0},
    walk(W, ?TICKS div ?STRIDE, seen(world:snapshot(W), Empty)).

walk(W, 0, Acc) -> close(world:snapshot(W), Acc);
walk(W, N, Acc) ->
    S = world:snapshot(world:tick(W, ?STRIDE)),
    step(maps:get(population, S), W, N, S, Acc).

step(0, _W, _N, S, Acc) -> close(S, seen(S, Acc));
step(_Pop, W, N, S, Acc) ->
    walk(world:tick(W, ?STRIDE), N - 1, seen(S, Acc)).

%% THE LAST BIRTH IS FOUND BY WATCHING `born' MOVE, not by asking the world,
%% because the world does not record when reproduction stopped. It has never had
%% a reason to: nothing in the rules cares, and until now nothing measured it.
seen(#{born := B, tick := T, depth := D, population := P} = S,
     #{last := L, ever := E} = Acc) ->
    living(P, S, Acc#{born => B, last => moved(B, maps:get(born, Acc, 0), T, L),
                      ever => max(E, D)}).

%% MEASURED WHILE SOMETHING IS STILL ALIVE. Read after the last death these are
%% all trivially nothing, and the first run of this script reported a depth of
%% zero everywhere for exactly that reason while the trajectory beside it showed
%% six. A census of an empty world is not a census.
living(0, _S, Acc) -> Acc;
living(_P, #{depth := D, lineages := N, uptake_min := Lo, uptake_max := Hi},
       Acc) ->
    Acc#{ended => D, lines => N, spread => Hi - Lo}.

moved(B, Was, T, _L) when B > Was -> T;
moved(_B, _Was, _T, L) -> L.

close(#{extinct_at := At, tick := T}, Acc) ->
    Acc#{dead => ended(At, T)}.

ended(undefined, T) -> T;
ended(At, _T) -> At.

%%==============================================================================
%% One run in full, because a summary hides the shape of a collapse
%%==============================================================================

trajectory() ->
    io:format("~n~nSHAPE at ~p%, sampled every ~p ticks, seed 1.~n~n",
              [?TRACED, ?SAMPLE]),
    io:format("~s~n", [row(["tick", "pop", "lines", "depth", "uplo", "uphi",
                            "spread"])]),
    watch(world:new(#{seed => 1, population => 40,
                      transfer_efficiency => ?TRACED}),
          ?TICKS div ?SAMPLE),
    io:format("~nlines = foundings still represented. depth = generations in the "
              "deepest living line.~n").

watch(_W, 0) -> ok;
watch(W, N) ->
    #{population := P, lineages := L, depth := D, uptake_min := Lo,
      uptake_max := Hi, tick := T} = world:snapshot(W),
    io:format("~s~n", [row([T, P, L, D, Lo, Hi, Hi - Lo])]),
    keep_watching(P, W, N).

keep_watching(0, _W, _N) -> ok;
keep_watching(_P, W, N) -> watch(world:tick(W, ?SAMPLE), N - 1).

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
pad(C) -> string:pad(C, 11, trailing).
