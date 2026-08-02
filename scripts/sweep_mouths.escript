#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc World 15's experiment: does a trophic split appear, and do both sides last?
%%
%% Usage:  ./scripts/sweep_mouths.escript [ticks]
%%
%% Criteria frozen in PREREGISTRATION_WORLD15.md before this ran.
%%
%% Every creature used to occupy both trophic levels at once for free: it absorbs
%% from the ground AND consumes anything smaller, with no organ and no decision.
%% World 15 charges the organ as tissue and makes the consumption a choice, and
%% the question is whether the population separates.
%%
%% THE TARGET IS ONE POPULATION HOLDING TWO WAYS OF LIVING. Either extreme is the
%% null and both are plausible: every creature grows a mouth, which would mean a
%% free good with extra steps, or none does, because prey is never dense enough.
%%
%% MEASURED AS THE SHAPE OF THE DISTRIBUTION, not as a share of carriers. The
%% first version of this counted `mouth > 0', which a mouth of ONE satisfies, and
%% read 94 to 100 percent across worlds ranging from functionally toothless to a
%% quarter carnivorous. A share cannot see a split; only the histogram can.
%%
%% AND NOTHING HERE IS CALLED A CARNIVORE. This world has no types, only
%% investments, and the spectator page has said for two worlds that nothing in
%% the rules names a predator and there is no carnivore flag to set.
%%
%% EVERY SURVIVING SEED IS PRINTED, which is a commitment in the pre-registration
%% rather than a preference. A share that averages 50 across worlds could be
%% every world at 50, or half of them at 0 and half at 100, and those are
%% opposite findings.
-mode(compile).

-define(TICKS, 20000).
-define(SEEDS, 48).
-define(CHUNK, 1000).

main(Args) ->
    Ticks = horizon(Args),
    io:format("~nticks=~p seeds=~p, world 15, 100% efficiency, default price~n~n",
              [Ticks, ?SEEDS]),
    Rows = [R || R <- in_parallel(fun(S) -> run(S, Ticks) end,
                                  lists:seq(1, ?SEEDS)), R =/= dead],
    io:format("~s~n", [row(["seed", "pop", "m_bins", "mouth", "hidden", "s_creat",
                            "s_ground", "meat%", "spread", "lines", "depth"])]),
    lists:foreach(fun print/1, lists:sort(fun by_mouth/2, Rows)),
    io:format("~n~p of ~p seeds dead, left out above.~n",
              [?SEEDS - length(Rows), ?SEEDS]),
    split(Rows),
    density(Rows),
    io:format("~nm_bins is how many bins of the mouth histogram are occupied: ONE "
              "is one way~nof living however many creatures are in it, more than "
              "one is the shape the~nquestion was about. mouth is the mean size. "
              "hidden and s_ are per creature~ntimes a hundred; s_creat and "
              "s_ground are sensors on those fields, which is~nwhere a decision "
              "about eating would show if it shows anywhere.~n").

horizon([]) -> ?TICKS;
horizon([Arg | _]) -> list_to_integer(Arg).

by_mouth(A, B) ->
    maps:get(mouth_mean, A) =< maps:get(mouth_mean, B).

print(S) ->
    io:format("~s~n", [row([maps:get(seed, S), maps:get(population, S),
                            spread_of(maps:get(mouth_hist, S)), maps:get(mouth_mean, S),
                            maps:get(hidden_mean, S), field(creatures, S),
                            field(ground, S), maps:get(from_creatures_pct, S),
                            maps:get(ground_spread, S), maps:get(lineages, S),
                            maps:get(depth, S)])]).

%% Carriers of a field per hundred creatures, so it reads on the same scale as
%% `sensor_mean' and the fields can be compared with each other.
field(Which, #{sensors := Sensors, population := Pop}) ->
    maps:get(carriers, maps:get(Which, Sensors, #{}), 0) * 100 div max(1, Pop).

%%==============================================================================
%% Finding 1: is there a split at all
%%==============================================================================

%% A WORLD IS SPLIT WHEN BOTH WAYS OF LIVING ARE PRESENT IN IT. Averaging the
%% share across worlds cannot answer this and would actively hide it: half the
%% worlds at nought and half at a hundred averages to the same fifty as every
%% world genuinely holding both, and those are opposite findings.
split(Rows) ->
    Splits = [R || R <- Rows, spread_of(maps:get(mouth_hist, R)) > 1],
    None = [R || R <- Rows, maps:get(mouth_mean, R) =:= 0],
    All = [R || R <- Rows, spread_of(maps:get(mouth_hist, R)) =:= 1],
    io:format("~nworlds whose mouths span MORE THAN ONE bin: ~p of ~p~n",
              [length(Splits), length(Rows)]),
    io:format("worlds with no mouth at all:                ~p~n", [length(None)]),
    io:format("worlds with every mouth in one bin:         ~p~n", [length(All)]).

%% HOW MANY BINS THE POPULATION'S MOUTHS OCCUPY. One bin is one way of living,
%% however many creatures are in it; more than one is the shape the question was
%% about. A share of carriers could not see this and read 94 to 100 across worlds
%% that ranged from toothless to a quarter carnivorous.
spread_of(Hist) -> length([N || N <- Hist, N > 0]).

%%==============================================================================
%% Finding 2: do mouths track density
%%==============================================================================

%% A MOUTH PAYS ONLY WHERE THERE IS PREY ENOUGH TO COVER ITS UPKEEP, so being
%% common is what should make mouths pay. Split by population rather than
%% correlated, for the same reason the tertiles were used before: one coefficient
%% over a skewed distribution hides the shape.
density(Rows) when length(Rows) < 3 ->
    io:format("~nToo few survivors to split by density.~n");
density(Rows) ->
    Sorted = lists:sort(fun(A, B) ->
                                maps:get(population, A) =< maps:get(population, B)
                        end, Rows),
    Cut = length(Sorted) div 3,
    io:format("~n~s~n", [row(["density", "worlds", "pop", "m_bins", "mouth",
                              "meat%", "hidden"])]),
    tier("sparsest", lists:sublist(Sorted, Cut)),
    tier("middle", lists:sublist(Sorted, Cut + 1, Cut)),
    tier("densest", lists:nthtail(2 * Cut, Sorted)).

tier(_Name, []) -> ok;
tier(Name, Rows) ->
    Avg = fun(K) -> avg([maps:get(K, R) || R <- Rows]) end,
    io:format("~s~n", [row([Name, length(Rows), Avg(population),
                            Avg(mouth_mean),
                            Avg(from_creatures_pct), Avg(hidden_mean)])]).

%%==============================================================================

run(Seed, Ticks) ->
    W = advance(world:new(#{seed => Seed, population => 40,
                            transfer_efficiency => 100}),
                Ticks),
    finished(world:snapshot(W), Seed).

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(?CHUNK, Left),
    still_living(world:tick(W, Step), Left - Step).

still_living(W, Left) -> keep_going(world:population(W) > 0, W, Left).

keep_going(false, W, _Left) -> W;
keep_going(true, W, Left) -> advance(W, Left).

finished(#{population := 0}, _Seed) -> dead;
finished(Snap, Seed) -> Snap#{seed => Seed}.

avg([]) -> 0;
avg(L) -> lists:sum(L) div length(L).

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
