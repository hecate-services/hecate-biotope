#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc DOES CONCENTRATING CREATURES ACTUALLY PRODUCE MEETINGS?
%%
%% Usage:  ./scripts/does_crowding_make_meals.escript [ticks [seeds]]
%%
%% THE PREMISE OF THE WATERING HOLE, MEASURED BEFORE IT IS BUILT. `D.7` found
%% that predation is suppressed by opportunity and not by economics: a bite is
%% the same size as a graze (299 against 277) and a creature gets 0 to 1 chances
%% in its entire life, because 54 to 84 creatures on a 1,261-cell board almost
%% never meet.
%%
%% Raf's proposal is a second requirement, water, in a few fixed places, so that
%% everything has to come to the same handful of cells. The argument is that this
%% raises the ENCOUNTER RATE at unchanged population, which is far cheaper than
%% raising the population.
%%
%% THAT ARGUMENT HAS ONE LOAD-BEARING ASSUMPTION AND IT IS NOT THE WATER. It is
%% that meetings scale with local density at all. If a board twice as crowded
%% does not give more than twice the meals, then herding everything to a
%% waterhole will not either, and the world is not worth building.
%%
%% RADIUS IS THE LEVER, because it varies density without inventing anything. A
%% smaller disc holds the same kind of world in less space. It is not a clean
%% lever: a smaller board also holds less ground and therefore fewer creatures,
%% which pushes density back down, so the sweep reports the density it ACHIEVED
%% rather than the one it asked for and reads the relationship off that.
%%
%% ⚠ EVERY SEED REPORTED, ALIVE OR DEAD. `I.2`, and the version of this file's
%% sibling that dropped the dead printed nothing at all when every seed died.
-mode(compile).

-define(SAMPLES, 100).
-define(RADII, [4, 6, 8, 11, 14, 17, 20]).

main(Args) ->
    Ticks = arg(Args, 1, 2000),
    Seeds = arg(Args, 2, 12),
    io:format("~nsettled ~p ticks then ~p sampled, ~p seeds per radius.~n"
              "density is creatures per cell. Random collision predicts the "
              "share of creatures~nsharing a cell rises roughly IN PROPORTION "
              "to density at these numbers.~n~n", [Ticks, ?SAMPLES, Seeds]),
    io:format("~s~n", [row(["radius", "cells", "alive", "pop", "DENSITY%",
                            "shared%", "PREY%", "meals/1000"])]),
    lists:foreach(fun(R) -> report(R, Ticks, Seeds) end, ?RADII),
    io:format("~nshared%% is the share of LIVING CREATURES standing on a cell "
              "with another.~nPREY%% is the share standing on one with something "
              "STRICTLY SMALLER, which is~nthe only thing a mouth can use. "
              "meals/1000 is prey encounters per thousand~ncreature-ticks, which "
              "is the rate a mouth would actually be selected on.~n").

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.

report(Radius, Ticks, Seeds) ->
    Cells = hex:cells(Radius),
    Rows = [look(S, Radius, Ticks) || S <- lists:seq(1, Seeds)],
    Alive = [R || R <- Rows, R =/= dead],
    io:format("~s~n", [row([Radius, Cells, length(Alive) | summarise(Alive, Cells)])]).

summarise([], _Cells) -> ["-", "-", "-", "-", "-"];
summarise(Rows, Cells) ->
    Pop = mean([maps:get(pop, R) || R <- Rows]),
    [round(Pop),
     tenths(round(Pop * 1000 / Cells)),
     tenths(round(mean([maps:get(shared, R) || R <- Rows]) * 10)),
     tenths(round(mean([maps:get(prey, R) || R <- Rows]) * 10)),
     round(mean([maps:get(meals, R) || R <- Rows]) * 1000)].

look(Seed, Radius, Ticks) ->
    W = advance(world:new(#{seed => Seed, population => 40, radius => Radius,
                            transfer_efficiency => 100}), Ticks),
    sampled(world:population(W) > 0, W).

sampled(false, _W) -> dead;
sampled(true, W) -> sample(W, ?SAMPLES, {0, 0, 0}).

%% Sampled over many ticks rather than read off one, because a single frame of a
%% board this sparse is mostly noise: at 5% occupancy the count of shared cells
%% on one tick is a handful either way.
sample(_W, 0, {Heads, Shared, Prey}) ->
    #{pop => Heads / ?SAMPLES,
      shared => share(Shared, Heads), prey => share(Prey, Heads),
      meals => Prey / max(1, Heads)};
sample(W, Left, {Heads, Shared, Prey}) ->
    W1 = world:tick(W, 1),
    keep(world:population(W1) > 0, W1, Left,
         count(world:creatures(W1), {Heads, Shared, Prey})).

keep(false, _W, _Left, Acc) -> sample_end(Acc);
keep(true, W, Left, Acc) -> sample(W, Left - 1, Acc).

sample_end({Heads, Shared, Prey}) ->
    #{pop => Heads / ?SAMPLES, shared => share(Shared, Heads),
      prey => share(Prey, Heads), meals => Prey / max(1, Heads)}.

%% WHAT COUNTS AS AN OPPORTUNITY is exactly what `resolve/3' needs: two creatures
%% in one cell, one strictly larger than the other by STRUCTURE. Anything else is
%% company rather than a meal.
count(Cs, {Heads, Shared, Prey}) ->
    ByCell = maps:fold(fun(_Id, #{at := At, structure := S}, Acc) ->
                               maps:update_with(At, fun(L) -> [S | L] end,
                                                [S], Acc)
                       end, #{}, Cs),
    Groups = maps:values(ByCell),
    {Heads + map_size(Cs),
     Shared + lists:sum([length(G) || G <- Groups, length(G) > 1]),
     Prey + lists:sum([predators(G) || G <- Groups])}.

%% How many creatures in this cell have something strictly smaller under them.
predators(Group) ->
    Smallest = lists:min(Group),
    length([S || S <- Group, S > Smallest]).

share(_Part, 0) -> 0.0;
share(Part, Whole) -> Part * 100 / Whole.

tenths(N) -> io_lib:format("~w.~w", [N div 10, N rem 10]).

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(500, Left),
    going(world:population(W) > 0, world:tick(W, Step), Left - Step).

going(false, W, _Left) -> W;
going(true, W, Left) -> advance(W, Left).

mean([]) -> 0.0;
mean(L) -> lists:sum(L) / length(L).

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) when is_float(C) -> pad(io_lib:format("~.1f", [C]));
pad(C) -> string:pad(C, 11, trailing).
