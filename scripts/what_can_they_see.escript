#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc What the senses in this world are actually reading.
%%
%% Usage:  ./scripts/what_can_they_see.escript [ticks]
%%
%% THE PREMISE OF WORLD 17, MEASURED BEFORE IT IS BUILT. A reading is the raw
%% quantity divided by its natural unit, and for all three energy fields that
%% unit is `ground_ceiling', which is what ONE FULL CELL holds. The suspicion is
%% that typical quantities are a fraction of a cell, so the readings are almost
%% always zero and the instruments are blind at the bottom of their range.
%%
%% That is a claim and it has never been measured. This session has three times
%% explained a null with something that turned out false, and once killed a whole
%% world by testing its premise first for the price of one script. This is the
%% second kind.
%%
%% WHAT A SENSOR COULD SEE, not what the sensors that exist happen to see. The
%% question is whether the instrument can resolve anything, which is a property
%% of the world and not of who is carrying one today.
-mode(compile).

-define(SEEDS, [5, 12, 14, 39, 46, 8]).

main(Args) ->
    Ticks = ticks(Args),
    io:format("~nsettled ~p ticks. a reading is raw div ~p, capped at ~p.~n~n",
              [Ticks, maps:get(ground_ceiling, world:defaults()),
               body:reading_ceiling()]),
    io:format("~s~n", [row(["seed", "pop", "SELF=0", "self max", "GROUND r0=0",
                            "r0 max", "r1=0", "r1 max"])]),
    lists:foreach(fun(S) -> report(S, Ticks) end, ?SEEDS),
    io:format("~nSELF=0 is the share of living creatures whose hunger sense reads "
              "ZERO, and~nGROUND rN=0 the share of occupied cells where a sensor "
              "of reach N reads zero.~nA sense stuck at zero cannot distinguish "
              "anything, however much is really there.~n").

ticks([]) -> 20000;
ticks([A | _]) -> list_to_integer(A).

report(Seed, Ticks) ->
    W = advance(world:new(#{seed => Seed, population => 40,
                            transfer_efficiency => 100}), Ticks),
    seen(Seed, world:snapshot(W), world:chart(W), W).

seen(Seed, #{population := 0}, _Chart, _W) ->
    io:format("~s~n", [row([Seed, "dead", "-", "-", "-", "-", "-", "-"])]);
seen(Seed, Snap, Chart, _W) ->
    Econ = maps:get(econ, Snap),
    Selves = [body:reading(self, E, Econ) || E <- maps:get(energies, Chart)],
    Cells = pairs(maps:get(creatures, Chart)),
    Radius = maps:get(radius, Chart),
    G = ground_of(Chart),
    Ground = fun(R) ->
                     [body:reading(ground,
                                   ground:within(C, R, Radius, G),
                                   Econ)
                      || C <- Cells]
             end,
    R0 = Ground(0),
    R1 = Ground(1),
    io:format("~s~n", [row([Seed, maps:get(population, Snap),
                            pct_zero(Selves), lists:max([0 | Selves]),
                            pct_zero(R0), lists:max([0 | R0]),
                            pct_zero(R1), lists:max([0 | R1])])]).

%% The ground map lives inside the world record, so it is rebuilt from the chart
%% rather than reaching in. `chart/1' omits empty cells, which is right: a cell
%% absent from the map reads as nothing, exactly as `ground:at/2' would say.
ground_of(Chart) ->
    maps:from_list(triples(maps:get(ground, Chart))).

pct_zero([]) -> 0;
pct_zero(L) -> length([V || V <- L, V =:= 0]) * 100 div length(L).

pairs([]) -> [];
pairs([Q, R | Rest]) -> [{Q, R} | pairs(Rest)].

triples([]) -> [];
triples([Q, R, E | Rest]) -> [{{Q, R}, E} | triples(Rest)].

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(1000, Left),
    keep_going(world:population(W) > 0, world:tick(W, Step), Left - Step).

keep_going(false, W, _Left) -> W;
keep_going(true, W, Left) -> advance(W, Left).

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(C, 13, trailing).
