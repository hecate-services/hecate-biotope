#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc How often does a creature meet something it could eat?
%%
%% Usage:  ./scripts/how_often_do_they_meet.escript [ticks-to-settle]
%%
%% THE PREMISE OF THE NEXT WORLD, MEASURED BEFORE IT IS BUILT. World 15 gave a
%% mouth a price and a decision and the trait drifted. The explanation left
%% standing is the dullest one: **there is nothing to eat.** Populations run 32 to
%% 135 on 1,261 cells, so two creatures sharing a cell should be rare, and an
%% organ cannot be selected for by an opportunity that does not arrive.
%%
%% That is a claim and it has never been measured. It is also cheap to measure,
%% and this session has now three times explained a null with something that
%% turned out to be false: the absorbing state that contributed 1% of the board,
%% the patchiness that reversed, and the truncation that survived its own test.
%% The ground floor sweep is the counter-example worth copying: it tested a
%% premise in six minutes and killed a week of building.
%%
%% WHAT COUNTS AS AN OPPORTUNITY is exactly what `resolve/2' needs: two creatures
%% in one cell, one strictly larger than the other by structure. Anything else is
%% company, not a meal.
-mode(compile).

-define(SAMPLES, 200).

main(Args) ->
    Settle = settle(Args),
    io:format("~nsettled ~p ticks, then ~p ticks sampled~n~n", [Settle, ?SAMPLES]),
    io:format("~s~n", [row(["seed", "pop", "occupied", "shared", "PREY%",
                            "meals/tick", "per life"])]),
    lists:foreach(fun(S) -> report(S, Settle) end, [5, 12, 14, 39, 46, 8]),
    io:format("~nshared = cells holding more than one creature, as a share of "
              "occupied cells.~nPREY% = share of the living that, on an average "
              "tick, stand on a cell with~nsomething STRICTLY SMALLER on it, "
              "which is the only thing a mouth can use.~nmeals/tick is that count "
              "per tick; per life multiplies by the generation time,~nso it is "
              "roughly how many chances a creature gets in its whole existence.~n").

settle([]) -> 20000;
settle([A | _]) -> list_to_integer(A).

report(Seed, Settle) ->
    W = advance(world:new(#{seed => Seed, population => 40,
                            transfer_efficiency => 100}), Settle),
    print(Seed, world:snapshot(W), sample(W, ?SAMPLES, {0, 0, 0, 0}), Settle).

print(Seed, #{population := 0}, _Counts, _Settle) ->
    io:format("~s~n", [row([Seed, "dead", "-", "-", "-", "-", "-"])]);
print(Seed, Snap, {Occ, Shared, Prey, Pop}, Settle) ->
    Gen = generation(Snap, Settle),
    io:format("~s~n", [row([Seed, maps:get(population, Snap),
                            Occ div ?SAMPLES, pct(Shared, Occ), pct(Prey, Pop),
                            Prey div ?SAMPLES, Prey * Gen div max(1, Pop)])]).

%% One tick at a time, because an opportunity is a thing that happens ON a tick
%% and a snapshot taken every thousand would miss all of them.
sample(_W, 0, Acc) -> Acc;
sample(W, N, {Occ, Shared, Prey, Pop}) ->
    Chart = world:chart(world:tick(W, 1)),
    Cells = grouped(pairs(maps:get(creatures, Chart)),
                    maps:get(structures, Chart)),
    sample(world:tick(W, 1), N - 1,
           {Occ + map_size(Cells),
            Shared + length([1 || {_H, Sizes} <- maps:to_list(Cells),
                                  length(Sizes) > 1]),
            Prey + lists:sum([edible(Sizes) || {_H, Sizes} <- maps:to_list(Cells)]),
            Pop + length(maps:get(structures, Chart))}).

%% HOW MANY CREATURES IN THIS CELL HAVE SOMETHING SMALLER BESIDE THEM. Not how
%% many are edible: how many are in a position to EAT, which is what a mouth is
%% selected on.
edible(Sizes) ->
    Smallest = lists:min(Sizes),
    length([S || S <- Sizes, S > Smallest]).

grouped(Hexes, Sizes) ->
    lists:foldl(fun({H, S}, Acc) -> maps:update_with(H, fun(L) -> [S | L] end,
                                                     [S], Acc)
                end, #{}, lists:zip(Hexes, Sizes)).

generation(#{depth := 0}, _Settle) -> 1;
generation(#{depth := D}, Settle) -> max(1, Settle div D).

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(1000, Left),
    keep_going(world:population(W) > 0, world:tick(W, Step), Left - Step).

keep_going(false, W, _Left) -> W;
keep_going(true, W, Left) -> advance(W, Left).

pairs([]) -> [];
pairs([Q, R | Rest]) -> [{Q, R} | pairs(Rest)].

pct(_N, 0) -> 0;
pct(N, D) -> N * 100 div D.

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(C, 12, trailing).
