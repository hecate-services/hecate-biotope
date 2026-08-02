#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc World 18's experiment: what it costs to be able to act.
%%
%% Usage:  ./scripts/sweep_acts.escript [ticks [seeds]]
%%
%% Criteria in PREREGISTRATION_WORLD18.md, frozen before this was written.
%%
%% `H.7': every organ in this world is priced and every act is free, so a creature
%% carrying `move', `breed', `eat' and `grow' pays exactly what one carrying none
%% pays. `act_cost' charges an output by its wiring, the way world 16 charges a
%% hidden node.
%%
%% THE SWEEP SPANS BOTH WALLS RATHER THAN SITTING BETWEEN THEM. The gate measured
%% a drift floor near 10, below which a mutation moves the bill by under one
%% percent of what a creature earns and selection cannot see it, and a roof near
%% 200, above which the purposes a creature actually carries cost most of its
%% income and the price bans acting rather than pricing it. **0 is world 17
%% exactly**, so the old behaviour is inside the comparison.
%%
%% ⚠ IT SELECTS ON COUNT AND NOT ON WIDTH. An output is `sensors + 1 + hidden'
%% wide, which is the body reported back and not a trait, exactly as `H.11' found
%% for hidden nodes. `purposes' is the column this world is about.
%%
%% AND THE FOUR PURPOSES ARE NOT EQUIVALENT, which `H.12' established before this
%% ran: losing `breed' ends a lineage in one generation, so a uniform price has a
%% non-uniform consequence. The per-purpose columns are what tell a price acting
%% on all four apart from one acting on two.
-mode(compile).

-define(STEPS, [0, 8, 16, 33, 66, 132, 330]).

main(Args) ->
    Ticks = arg(Args, 1, 20000),
    Seeds = arg(Args, 2, 48),
    io:format("~nticks=~p seeds=~p. act_cost 0 is world 17 exactly.~n"
              "The gate put the drift floor near 10 and the roof near 200.~n~n",
              [Ticks, Seeds]),
    io:format("~s~n", [row(["act_cost", "dead", "alive", "PURPOSES", "move",
                            "breed", "eat", "grow", "sensors", "nodes", "pop",
                            "depth"])]),
    lists:foreach(fun(C) -> report(C, Ticks, Seeds) end, ?STEPS),
    io:format("~nPURPOSES is per creature times a hundred. move/breed/eat/grow "
              "are the SHARE of~nliving creatures carrying each, so a uniform "
              "price with a non-uniform effect is~nvisible as the four "
              "diverging. sensors and nodes are per creature times a hundred.~n").

arg(Args, N, _Default) when length(Args) >= N ->
    list_to_integer(lists:nth(N, Args));
arg(_Args, _N, Default) -> Default.

report(Cost, Ticks, Seeds) ->
    Rows = [R || R <- in_parallel(fun(S) -> run(S, Cost, Ticks) end,
                                  lists:seq(1, Seeds)), R =/= dead],
    io:format("~s~n", [row([Cost, Seeds - length(Rows), length(Rows)
                            | summarise(Rows)])]).

summarise([]) -> lists:duplicate(10, "-");
summarise(Rows) ->
    Avg = fun(K) -> avg([maps:get(K, R) || R <- Rows]) end,
    [Avg(purposes_mean) | [Avg(P) || P <- [move, breed, eat, grow]]] ++
        [Avg(sensor_mean), Avg(hidden_mean), Avg(population), Avg(depth)].

run(Seed, Cost, Ticks) ->
    W = advance(world:new(#{seed => Seed, population => 40,
                            transfer_efficiency => 100,
                            act_cost => Cost}), Ticks),
    finished(world:snapshot(W)).

finished(#{population := 0}) -> dead;
finished(#{population := Pop, purposes_hist := Hist} = Snap) ->
    %% As a SHARE of the living rather than a count, because the populations
    %% differ several-fold across the sweep and a raw count would report that
    %% difference as a change in what creatures carry.
    Shares = [{P, C * 100 div max(1, Pop)}
              || {P, C} <- lists:zip(brain:purposes(), Hist)],
    maps:merge(Snap, maps:from_list(Shares)).

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(1000, Left),
    keep_going(world:population(W) > 0, world:tick(W, Step), Left - Step).

keep_going(false, W, _Left) -> W;
keep_going(true, W, Left) -> advance(W, Left).

avg([]) -> 0;
avg(L) -> lists:sum(L) div length(L).

in_parallel(F, Items) ->
    Parent = self(),
    Refs = [spawn_one(Parent, F, I) || I <- Items],
    [receive {Ref, R} -> R end || Ref <- Refs].

spawn_one(Parent, F, Item) ->
    Ref = make_ref(),
    spawn_link(fun() -> Parent ! {Ref, F(Item)} end),
    Ref.

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(C, 10, trailing).
