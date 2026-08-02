#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc World 16's experiment: what happens when a thought costs what it reads.
%%
%% Usage:  ./scripts/sweep_wiring.escript [ticks]
%%
%% Criteria frozen in PREREGISTRATION_WORLD16.md, which is the first world to
%% pass the selectability gate before being built.
%%
%% A hidden node used to cost the same whatever it was wired to, so this world
%% could not tell a cheap reflex from an expensive integrator. Now it is charged
%% by its weights, which also COUPLES perception to computation: gaining a sensor
%% raises the price of every node a creature carries.
%%
%% WIDTH IS REPORTED BESIDE DEPTH, and that is a commitment rather than a
%% convenience. A brain getting cheaper and a brain getting simpler look
%% identical from the node count alone, and no world before this one measured the
%% shape of these brains at all.
-mode(compile).

-define(TICKS, 20000).
-define(SEEDS, 24).
-define(CHUNK, 1000).
-define(STEPS, [330, 220, 165, 110, 66, 33, 11, 3, 1]).

main(Args) ->
    Ticks = horizon(Args),
    io:format("~nticks=~p seeds=~p, world 16, 100% efficiency. 330 is the control.~n~n",
              [Ticks, ?SEEDS]),
    io:format("~s~n", [row(["price", "dead", "alive", "NODES", "WIDTH", "sensors",
                            "pop", "meat%", "lines", "F_ST", "depth"])]),
    All = lists:append([report(P, Ticks) || P <- ?STEPS]),
    trade(All),
    io:format("~nNODES is hidden nodes per creature times a hundred and WIDTH is "
              "inputs per~nhidden node, also times a hundred: the first says how "
              "deep a brain is and the~nsecond how wide, and only both together "
              "distinguish cheaper from simpler.~nF_ST is how much of the scent "
              "variation sits between lumps rather than inside~nthem, 0 meaning "
              "no spatial structure.~n").

horizon([]) -> ?TICKS;
horizon([A | _]) -> list_to_integer(A).

report(Price, Ticks) ->
    Rows = [R || R <- in_parallel(fun(S) -> run(S, Price, Ticks) end,
                                  lists:seq(1, ?SEEDS)), R =/= dead],
    io:format("~s~n", [row([Price, ?SEEDS - length(Rows), length(Rows)
                            | summarise(Rows)])]),
    Rows.

summarise([]) -> lists:duplicate(8, "-");
summarise(Rows) ->
    Avg = fun(K) -> avg([maps:get(K, R) || R <- Rows]) end,
    [Avg(hidden_mean), Avg(hidden_inputs_mean), Avg(sensor_mean),
     Avg(population), Avg(from_creatures_pct), Avg(lineages), Avg(fst),
     Avg(depth)].

%% FINDING 3: do perception and computation trade? Split the surviving worlds by
%% how many sensors they carry and read the node count either side. If the
%% coupling bites, the worlds carrying the most sensors carry the fewest nodes.
trade(Rows) when length(Rows) < 4 ->
    io:format("~nToo few survivors to split.~n");
trade(Rows) ->
    Sorted = lists:sort(fun(A, B) ->
                                maps:get(sensor_mean, A) =< maps:get(sensor_mean, B)
                        end, Rows),
    Cut = length(Sorted) div 2,
    io:format("~npooled over every surviving world, ~p of them~n~n", [length(Rows)]),
    io:format("~s~n", [row(["sensors", "worlds", "sensors", "NODES", "WIDTH",
                            "pop"])]),
    half("fewest", lists:sublist(Sorted, Cut)),
    half("most", lists:nthtail(Cut, Sorted)).

half(_Name, []) -> ok;
half(Name, Rows) ->
    Avg = fun(K) -> avg([maps:get(K, R) || R <- Rows]) end,
    io:format("~s~n", [row([Name, length(Rows), Avg(sensor_mean),
                            Avg(hidden_mean), Avg(hidden_inputs_mean),
                            Avg(population)])]).

run(Seed, Price, Ticks) ->
    W = advance(world:new(#{seed => Seed, population => 40,
                            transfer_efficiency => 100,
                            neural_cost => Price}), Ticks),
    finished(world:snapshot(W), W).

finished(#{population := 0}, _W) -> dead;
finished(Snap, W) -> Snap#{fst => fst(world:chart(W))}.

%%==============================================================================
%% How much of the variation sits between lumps
%%==============================================================================

%% Wright's F_ST with the tools this world already has: `scent:spread/1' IS a
%% normalised mean pairwise difference, so `(total - within) / total' applies
%% directly. Committed to in the pre-registration because `lineages' counts
%% founders and can only fall, while this measures how the variation that exists
%% is apportioned in space, and a monoculture can be strongly structured.
fst(Chart) ->
    Tags = maps:get(signatures, Chart),
    apportioned(scent:spread(Tags), within(Chart, Tags)).

apportioned(0, _Within) -> 0;
apportioned(Total, Within) -> (Total - Within) * 100 div Total.

within(Chart, Tags) ->
    Tagged = lists:zip(pairs(maps:get(creatures, Chart)), Tags),
    Occupied = sets:from_list([H || {H, _T} <- Tagged]),
    avg([scent:spread(Ts) || G <- groups(Occupied),
                             Ts <- [[T || {H, T} <- Tagged,
                                          sets:is_element(H, G)]],
                             length(Ts) > 1]).

groups(Occupied) -> grouped(sets:to_list(Occupied), Occupied, []).

grouped([], _All, Acc) -> Acc;
grouped([H | Rest], All, Acc) ->
    G = flood([H], All, sets:new()),
    grouped([C || C <- Rest, not sets:is_element(C, G)],
            sets:subtract(All, G), [G | Acc]).

flood([], _All, Seen) -> Seen;
flood([H | Rest], All, Seen) ->
    spread(sets:is_element(H, Seen) orelse not sets:is_element(H, All),
           H, Rest, All, Seen).

spread(true, _H, Rest, All, Seen) -> flood(Rest, All, Seen);
spread(false, H, Rest, All, Seen) ->
    flood(hex:neighbours(H) ++ Rest, All, sets:add_element(H, Seen)).

pairs([]) -> [];
pairs([Q, R | Rest]) -> [{Q, R} | pairs(Rest)].

%%==============================================================================

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(?CHUNK, Left),
    keep_going(world:population(W) > 0, world:tick(W, Step), Left - Step).

keep_going(false, W, _Left) -> W;
keep_going(true, W, Left) -> advance(W, Left).

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
pad(C) -> string:pad(C, 9, trailing).
