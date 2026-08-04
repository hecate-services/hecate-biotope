#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% THE CONTROL THE NODE FINDING NEEDS, AND IT DECIDES THE WHOLE WORLD.
%%
%% World 23's one positive reading is that hidden nodes RISE: a median of 0.33 in
%% the control against 0.48 to 1.16 with thirst on, at 64 seeds. `J.1' says that
%% is what a SECOND REQUIREMENT buys - a brain with two things to weigh.
%%
%% ⚠ BUT THIRST ALSO KILLS 84-89% OF SEEDS WHERE THE CONTROL KILLS 56%, and world
%% 22 already showed nodes reaching 0.80 on mortality alone, by shrinking the
%% island until 96% of seeds died. **So "two requirements buy computation" and
%% "dying a lot buys computation" both predict this table**, and nothing so far
%% separates them.
%%
%% This runs world 22's physics - `thirst' at zero, ONE requirement - and drives
%% extinction up the only other way there is, by shrinking the island. If nodes
%% reach the thirst arms' figures at matched mortality, the finding is about
%% dying and `J.1' gets no support. If they stay low while seeds die just as
%% often, the second requirement is doing the work.
%%
%% ⚠ RADIUS IS NOT A CLEAN LEVER EITHER and this says so rather than hiding it:
%% a smaller island also means fewer creatures, so `Ne' falls and drift rises.
%% That pushes nodes DOWN, not up, so it biases against the control and in favour
%% of my own finding. Read the population column beside every row.
-mode(compile).

main(Args) ->
    Seeds = arg(Args, 1, 64),
    Ticks = arg(Args, 2, 8000),
    io:format("~n~p seeds to ~p ticks. `thirst' ZERO throughout: this is world "
              "22's physics.~nThirst arms to beat, at 84-89% dead: nodes 0.48 "
              "to 1.16, median of medians ~~0.97.~n~n", [Seeds, Ticks]),
    io:format("~-10s ~-8s ~-8s ~-8s ~-22s ~-8s~n",
              ["radius", "dead", "dead%", "pop", "NODES min-med-max", "depth"]),
    [arm(R, Seeds, Ticks) || R <- [20, 16, 14, 12, 10, 8]],
    io:format("~nA row whose dead%% matches the thirst arms is the comparison. "
              "Nodes there~nare what mortality alone buys.~n").

arm(Radius, Seeds, Ticks) ->
    Rows = [run(S, Radius, Ticks) || S <- lists:seq(1, Seeds)],
    Live = [N || #{population := P} = N <- Rows, P > 0],
    Dead = Seeds - length(Live),
    io:format("~-10w ~-8w ~-8s ~-8s ~-22s ~-8s~n",
              [Radius, Dead, pct(Dead, Seeds), med([maps:get(population, N) || N <- Live]),
               spread([maps:get(hidden_mean, N) || N <- Live]),
               med([maps:get(depth, N) || N <- Live])]).

run(Seed, Radius, Ticks) ->
    W = world:new(#{seed => Seed, population => 40, radius => Radius,
                    thirst => 0}),
    world:snapshot(advance(W, Ticks)).

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(500, Left),
    going(world:population(W) > 0, world:tick(W, Step), Left - Step).

going(false, W, _Left) -> W;
going(true, W, Left) -> advance(W, Left).

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.

spread([]) -> "-";
spread(Vs) ->
    S = lists:sort(Vs),
    [hundredths(hd(S)), "-", hundredths(median(Vs)), "-", hundredths(lists:last(S))].

med([]) -> "-";
med(Vs) -> integer_to_list(median(Vs)).

median([]) -> 0;
median(Vs) -> lists:nth(max(1, length(Vs) div 2), lists:sort(Vs)).

pct(Part, Whole) -> [integer_to_list(Part * 100 div max(1, Whole)), "%"].

hundredths(V) -> io_lib:format("~.2f", [V / 100]).
