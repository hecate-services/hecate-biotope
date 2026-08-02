#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc What the senses in this world are actually reading.
%%
%% Usage:  ./scripts/what_can_they_see.escript [ticks [sense_scale]]
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
%%
%% ==========================================================================
%% IT WENT STALE THE MOMENT WORLD 17 SHIPPED, AND SAID NOTHING
%% ==========================================================================
%%
%% Written in the commit BEFORE world 17's rules, to justify them. World 17 then
%% made a reading a MEAN rather than a sum, which added a cell count to
%% `body:reading', and this file went on calling the three-argument form. That
%% form passes one cell. So a reach-1 sensor had seven cells of energy divided by
%% one, and the number reported was a SUM measured by an instrument whose whole
%% purpose was to check that sums had been replaced by means.
%%
%% It was not wrong at reach 0, where one cell is one cell, which is exactly why
%% it survived: the column anyone would sanity-check was the column that still
%% agreed. THE SIXTH INSTRUMENT FAILURE OF THIS SHAPE, a selector that matches
%% something and not the thing, and the first one to be caught by asking what a
%% script was compiled against rather than by reading its output.
%%
%% THE SCALE IS A PARAMETER NOW because world 17's answer is a swept constant and
%% a measurement at one point cannot report a sweep. Default is whatever the
%% rules currently say, so a bare run always measures the live world.
-mode(compile).

-define(SEEDS, [5, 12, 14, 39, 46, 8]).

main(Args) ->
    Ticks = ticks(Args),
    Econ = econ(Args),
    io:format("~nsettled ~p ticks. sense_scale ~p, so a full cell of ~p reads in "
              "units of ~p,~ncapped at ~p.~n~n",
              [Ticks, maps:get(sense_scale, Econ),
               maps:get(ground_ceiling, Econ), body:unit(ground, Econ),
               body:reading_ceiling()]),
    io:format("~s~n", [row(["seed", "pop", "SELF=0", "self max", "GROUND r0=0",
                            "r0 max", "r1=0", "r1 max"])]),
    lists:foreach(fun(S) -> report(S, Ticks, Econ) end, ?SEEDS),
    io:format("~nSELF=0 is the share of living creatures whose hunger sense reads "
              "ZERO, and~nGROUND rN=0 the share of occupied cells where a sensor "
              "of reach N reads zero.~nA sense stuck at zero cannot distinguish "
              "anything, however much is really there.~n").

ticks([]) -> 20000;
ticks([A | _]) -> list_to_integer(A).

%% The scale is applied to `world:new' as well as to the readings, because the
%% two must be the same world: measuring one world's ground with another world's
%% unit is the failure this file was just repaired for.
econ([]) -> world:defaults();
econ([_Ticks]) -> world:defaults();
econ([_Ticks, S | _]) ->
    maps:put(sense_scale, list_to_integer(S), world:defaults()).

report(Seed, Ticks, Econ) ->
    W = advance(world:new(#{seed => Seed, population => 40,
                            transfer_efficiency => 100,
                            sense_scale => maps:get(sense_scale, Econ)}), Ticks),
    seen(Seed, world:snapshot(W), world:chart(W), W).

seen(Seed, #{population := 0}, _Chart, _W) ->
    io:format("~s~n", [row([Seed, "dead", "-", "-", "-", "-", "-", "-"])]);
seen(Seed, Snap, Chart, _W) ->
    Econ = maps:get(econ, Snap),
    Selves = [body:reading(self, E, Econ) || E <- maps:get(energies, Chart)],
    Cells = pairs(maps:get(creatures, Chart)),
    Radius = maps:get(radius, Chart),
    G = ground_of(Chart),
    %% FOUR ARGUMENTS, AND THE COUNT IS THE SAME `hex:within' THE GATHER USED.
    %% `world:sense/N' divides by exactly this, so recomputing it here rather
    %% than assuming one cell is what makes this a measurement of the live rule
    %% instead of of the rule it replaced. `self' keeps one cell because it is
    %% not spatial: `body:spatial/1' says so and no cells are ever gathered.
    Ground = fun(R) ->
                     [body:reading(ground,
                                   ground:within(C, R, Radius, G),
                                   length(hex:within(C, R, Radius)),
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
