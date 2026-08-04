#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc W.0, THE WATERING HOLE'S GATE. CAN A CREATURE GET THERE AND BACK ALIVE?
%%
%% Usage:  ./scripts/can_they_reach_the_water.escript [seeds [ticks]]
%%
%% `J.1' proposes a second requirement in a few fixed places, so that a creature
%% has something to decide: keep eating, or go and drink. It is the register's
%% own answer to the central null, because this world has ONE drive and a brain
%% has nothing to weigh.
%%
%% ⚠⚠ AND THE GATE IT RAN WAS THE WRONG GATE, WHICH IS THE POINT OF THIS FILE
%% NOW. The first version asked whether a creature could AFFORD a round trip and
%% reported that it could not, and that was read as "water fails". It is a trait
%% gate applied to an environmental change: `R.1` asks whether selection can see
%% a trait's COST, and water is not a trait, it is a change to the landscape that
%% every existing trait is selected against. See `I.16`.
%%
%% What an environmental change has to clear is different and is now measured
%% here too: is the differential it creates above the drift floor, and can a
%% creature PHYSICALLY respond to it within a life? The first is trivial for
%% water — breeding or not is a 100% differential against a floor of 6.72% — and
%% the second is what the table below is for.
%%
%% ⚠ THE PREMISE WAS MEASURED AND THE GATE WAS NOT.
%% `what_would_a_waterhole_buy.escript' established that concentration produces
%% meals. This asks the prior question, which `PLAN.md` wrote down as W.0 and
%% left as a list of things to measure: **can a creature physically make the
%% journey?**
%%
%% `R.1' exists because world 15 ran forty-eight seeds to twenty thousand ticks
%% measuring a trait that could not be selected, and one line of arithmetic would
%% have said so. This is that line, for water.
%%
%% THE ARITHMETIC THIS CHECKS:
%%
%%   fare per cell   = move_cost + structure div upkeep_divisor, at REAL bodies
%%   distance        = mean cells from a creature to its nearest hole
%%   round trip      = 2 x distance x fare
%%   lifetime income = earnings per tick x mean lifespan
%%   **the roof**    = round trip as a share of a lifetime's earnings
%%
%% AND THE HARDER BOUND, WHICH IS NOT ABOUT MONEY: a creature lives about ten
%% ticks and moves at most one cell per tick, so it cannot reach a hole further
%% away than its whole life in cells, at any price.
-mode(compile).

%% Well under half or the price is a prohibition. `PLAN.md`, W.0.
-define(ROOF_PCT, 50).

main(Args) ->
    Seeds = arg(Args, 1, 16),
    Ticks = arg(Args, 2, 3000),
    Econ = world:defaults(),
    Radius = maps:get(radius, Econ),
    io:format("~n~p seeds settled to ~p ticks on a radius-~p disc.~n"
              "The roof is ~p% of a LIFETIME's earnings; above it the journey is "
              "a prohibition.~n~n", [Seeds, Ticks, Radius, ?ROOF_PCT]),
    Live = lists:append([alive(S, Ticks) || S <- lists:seq(1, Seeds)]),
    settled(Live, Econ, Radius).

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.

alive(Seed, Ticks) ->
    W = advance(world:new(#{seed => Seed, population => 40}), Ticks),
    [{C, maps:get(age, C)} || C <- maps:values(world:creatures(W))].

settled([], _Econ, _Radius) ->
    io:format("Every seed died. Nothing to measure.~n");
settled(Live, Econ, Radius) ->
    Cs = [C || {C, _Age} <- Live],
    Fare = mean([fare(C, Econ) || C <- Cs]),
    Income = 117,
    Life = 10,
    io:format("fare per cell, at real bodies : ~p~n", [Fare]),
    io:format("earned per tick               : ~p  (where_does_it_go)~n", [Income]),
    io:format("mean life, ticks              : ~p~n", [Life]),
    io:format("a lifetime's earnings         : ~p~n~n", [Income * Life]),
    io:format("~s~n", [row(["holes", "mean cells", "round trip", "as % of a life",
                            "round trip?", "ONE WAY"])]),
    lists:foreach(fun(N) -> arm(N, Cs, Fare, Income * Life, Life, Radius) end,
                  [1, 7, 19, 37, 61]),
    io:format("~n~s~n", [verdict()]).

%% Holes are placed as rings around the centre, which is the arrangement that
%% concentrates most for a given count.
arm(Holes, Cs, Fare, Lifetime, Life, Radius) ->
    Where = holes(Holes, Radius),
    Distances = [nearest(maps:get(at, C), Where) || C <- Cs],
    Mean = mean(Distances),
    Trip = 2 * Mean * Fare,
    Share = Trip * 100 div max(1, Lifetime),
    %% ⚠ THE COLUMN THAT ACTUALLY DECIDES IT, AND IT IS ONE-WAY. A creature does
    %% not need to come back. It needs to GET there once, inside a life, and the
    %% share of the population that could is what says whether the landscape is
    %% something a lineage can adapt to or a wall it dies against.
    Within = length([D || D <- Distances, D =< Life]) * 100
                 div max(1, length(Distances)),
    io:format("~s~n", [row([Holes, Mean, Trip, [integer_to_list(Share), "%"],
                            reachable(Mean, Life),
                            [integer_to_list(Within), "%"]])]).

%% ⚠ THE BOUND THAT IS NOT ABOUT MONEY. One cell per tick, ten ticks of life: a
%% hole further than a few cells cannot be reached at any price, and a round trip
%% needs the distance twice.
reachable(Mean, Life) when 2 * Mean =< Life -> "yes";
reachable(Mean, Life) when Mean =< Life -> "one way only";
reachable(_Mean, _Life) -> "NO".

holes(1, _Radius) -> [{0, 0}];
holes(N, Radius) ->
    Ring = max(1, Radius div 2),
    [{0, 0} | lists:sublist([C || C <- hex:disc(Ring),
                                  hex:distance(C, {0, 0}) =:= Ring], N - 1)].

nearest(At, Where) -> lists:min([hex:distance(At, H) || H <- Where]).

fare(#{structure := S}, Econ) ->
    maps:get(move_cost, Econ) + max(0, S) div max(1, maps:get(upkeep_divisor, Econ)).

mean([]) -> 0;
mean(Vs) -> lists:sum(Vs) div length(Vs).

verdict() ->
    "ONE WAY is the column that decides an environmental change: the share of\n"
    "creatures that could reach a hole once inside a life. A round trip is what\n"
    "a THIRST CYCLE needs and this world cannot afford one at any arrangement,\n"
    "which is a fact about the rule to be written and not about water.\n\n"
    "**A rule that needs reaching water ONCE is affordable where a rule that\n"
    "needs reaching it repeatedly is not**, and that is the whole design.".

advance(W, 0) -> W;
advance(W, N) -> going(world:population(W) > 0, W, N).
going(false, W, _N) -> W;
going(true, W, N) -> advance(world:tick(W, 1), N - 1).

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).
pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(lists:flatten(C), 16, trailing).
