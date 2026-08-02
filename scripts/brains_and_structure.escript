#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc Does structure make computation worth paying for?
%%
%% Criteria frozen in PREREGISTRATION_BRAINS_AND_STRUCTURE.md before this ran.
%%
%% A linear brain scores a cell as a weighted sum of what it reads there, which
%% climbs a gradient and is what these creatures do. On a patchy board the value
%% of a cell is not monotone in any single reading: a rich cell shared with six
%% others is worth less than a poorer empty one. A linear brain can add and
%% cannot divide, and a hidden node is the organ that lets one input modulate
%% another. On a flat board there is nothing to modulate.
%%
%% PATCHINESS IS NOT A KNOB. `ground_spread' came out 24, 83 and 89 on three
%% islands running identical rules at the same price, so it is an outcome of the
%% seed. The comparison is therefore ACROSS SEEDS WITHIN ONE WORLD, pooled, and
%% the price sweep is what tests the causal arrow rather than what varies the
%% structure.
%%
%% A DEAD WORLD IS NOT TICKED TO THE HORIZON. Nothing reseeds a world, so once
%% the population is nought the rest is ground arithmetic over 1,261 cells for
%% however many thousand ticks remain, and it changes nothing this reports. Two
%% seeds in three die at the expensive end, so the saving is most of the run.
-mode(compile).

%% THE HORIZON IS AN ARGUMENT, because the first run of this could not be told
%% apart from having run it longer. World 13's sweep stopped at 2,000 and this
%% one stopped at 20,000, so "computation is higher under world 14" and
%% "computation is higher after ten times as long" made identical predictions.
%% Same code, one parameter, both numbers.
-define(TICKS, 20000).
-define(SEEDS, 48).
-define(CHUNK, 1000).
-define(STEPS, [330, 220, 165, 110, 66, 33, 11, 3, 1]).

%% Ten times the 0.01 floor of worlds 2 to 13, fixed before any number was seen.
-define(APPEARS, 10).

main(Args) ->
    Ticks = horizon(Args),
    io:format("~nticks=~p seeds=~p, world 14, 100% efficiency. control is 330.~n",
              [Ticks, ?SEEDS]),
    io:format("\"appears\" is hidden per creature above ~p, fixed in advance.~n~n",
              [?APPEARS]),
    io:format("~s~n", [row(["price", "dead", "alive", "spread", "HIDDEN",
                            "sensors", "pop", "still", "lines", "depth",
                            "uspread"])]),
    All = lists:append([report(N, Ticks) || N <- ?STEPS]),
    tertiles(All),
    io:format("~nHIDDEN and sensors are per creature times a hundred. spread is "
              "`ground_spread'.~nuspread is the range of feeding rates in the "
              "living population.~n").

horizon([]) -> ?TICKS;
horizon([Arg | _]) -> list_to_integer(Arg).

%% THREADED AND NOT IN THE PROCESS DICTIONARY. `in_parallel/2' spawns a worker
%% per seed and a process dictionary does not cross that boundary, so the first
%% version read `undefined' in every worker and died on the arithmetic.
report(Price, Ticks) ->
    Rows = [R || R <- in_parallel(fun(S) -> run(S, Price, Ticks) end,
                                  lists:seq(1, ?SEEDS)), R =/= dead],
    io:format("~s~n", [row([Price, ?SEEDS - length(Rows), length(Rows)
                            | summarise(Rows)])]),
    Rows.

summarise([]) -> lists:duplicate(8, "-");
summarise(Rows) ->
    Avg = fun(K) -> avg([maps:get(K, R) || R <- Rows]) end,
    [Avg(ground_spread), Avg(hidden_mean), Avg(sensor_mean), Avg(population),
     Avg(still_pct), Avg(lineages), Avg(depth), Avg(uspread)].

run(Seed, Price, Ticks) ->
    W = advance(world:new(#{seed => Seed, population => 40,
                            transfer_efficiency => 100,
                            neural_cost => Price}),
                Ticks),
    finished(world:snapshot(W), Price).

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(?CHUNK, Left),
    still_living(world:tick(W, Step), Left - Step).

still_living(W, Left) ->
    keep_going(world:population(W) > 0, W, Left).

keep_going(false, W, _Left) -> W;
keep_going(true, W, Left) -> advance(W, Left).

finished(#{population := 0}, _Price) -> dead;
finished(Snap, Price) ->
    Snap#{price => Price,
          uspread => maps:get(uptake_max, Snap) - maps:get(uptake_min, Snap)}.

%%==============================================================================
%% The pooled analysis, which is the primary one
%%==============================================================================

%% BY TERTILE AND NOT BY A CORRELATION COEFFICIENT, because the distribution of
%% `ground_spread' is skewed and one number would hide the shape. Sensors are
%% carried alongside for the discriminator: a sensor pays on a flat board too, so
%% if sensors move as much as hidden nodes then what is being measured is
%% creatures rich enough to afford every organ rather than computation.
tertiles([]) ->
    io:format("~nNothing survived anywhere. No pooled analysis.~n");
tertiles(Rows) ->
    Sorted = lists:sort(fun(A, B) ->
                                maps:get(ground_spread, A) =<
                                    maps:get(ground_spread, B)
                        end, Rows),
    N = length(Sorted),
    io:format("~npooled over every surviving world, ~p of them, "
              "by how patchy its board is~n~n", [N]),
    io:format("~s~n", [row(["third", "worlds", "spread", "HIDDEN", "sensors",
                            "appears", "pop"])]),
    Cut = N div 3,
    tier("flattest", lists:sublist(Sorted, Cut)),
    tier("middle", lists:sublist(Sorted, Cut + 1, Cut)),
    tier("patchiest", lists:nthtail(2 * Cut, Sorted)).

tier(_Name, []) -> ok;
tier(Name, Rows) ->
    Avg = fun(K) -> avg([maps:get(K, R) || R <- Rows]) end,
    Appears = length([R || R <- Rows,
                           maps:get(hidden_mean, R) > ?APPEARS]),
    io:format("~s~n", [row([Name, length(Rows), Avg(ground_spread),
                            Avg(hidden_mean), Avg(sensor_mean),
                            pct(Appears, length(Rows)), Avg(population)])]).

%%==============================================================================

pct(_N, 0) -> 0;
pct(N, D) -> N * 100 div D.

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
