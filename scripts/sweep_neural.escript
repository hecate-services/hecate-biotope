#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc World 13's experiment: what a gram of neural tissue costs, every value.
%%
%% AN ORGAN IS TISSUE AND IS CHARGED BY THE RATE TISSUE IS CHARGED AT. What
%% physics does not settle is how much DEARER neural tissue is than structural
%% tissue, and biology says it genuinely is: a human brain is about 2% of the
%% mass and 20% of the energy. There is no way to derive the number, so it is
%% SWEPT and every value published, exactly as world 7 swept the efficiency.
%%
%% 330 IS THE CONTROL AND IS WORLDS 2 TO 12 EXACTLY. At the divisor of 33 it
%% reproduces the flat rent of 10 a tick those worlds charged, so the comparison
%% lives inside the experiment rather than across it.
%%
%% THE QUESTION IS ONE NUMBER: at what price does computation start paying for
%% itself? Perception has measured 0.10 sensors and 0.01 hidden nodes per
%% creature for twelve worlds, and the claim under test is that it was never
%% useless, only unaffordable. If that is right there is a price below which it
%% appears. If it is wrong the columns stay at zero all the way down, and THAT
%% IS THE MORE IMPORTANT RESULT: it would say this world's economy cannot
%% support a brain at any price.
-mode(compile).

-define(TICKS, 2000).
-define(SEEDS, 5).
-define(STEPS, [330, 220, 165, 110, 66, 33, 11, 3, 1]).

main(_) ->
    io:format("~nticks=~p seeds=~p at 100% efficiency. 330 is worlds 2 to 12.~n~n",
              [?TICKS, ?SEEDS]),
    io:format("~s~n", [row(["neural", "dead", "pop", "sens", "brain", "reach",
                            "life", "meat%", "frame", "lines", "depth"])]),
    lists:foreach(fun report/1, ?STEPS),
    io:format("~nsens and brain are per creature, times a hundred. reach is total "
              "sensor reach~ncarried by the population. dead = seeds extinct of "
              "~p.~n", [?SEEDS]).

report(Neural) ->
    Rows = in_parallel(fun(Seed) -> run(Seed, Neural) end, lists:seq(1, ?SEEDS)),
    Dead = length([R || #{population := 0} <- Rows, R <- [1]]),
    io:format("~s~n", [row([Neural, Dead | summarise([R || #{population := P} = R <- Rows, P > 0])])]).

summarise([]) -> ["-", "-", "-", "-", "-", "-", "-", "-", "-"];
summarise(Rows) ->
    Med = fun(K) -> median([maps:get(K, R) || R <- Rows]) end,
    [Med(population), Med(sensor_mean), Med(hidden_mean), Med(reach),
     Med(lifespan), Med(from_creatures_pct), Med(structure_max),
     Med(lineages), Med(depth)].

run(Seed, Neural) ->
    S = world:snapshot(world:tick(world:new(#{seed => Seed, population => 40,
                                              transfer_efficiency => 100,
                                              neural_cost => Neural}),
                                  ?TICKS)),
    S#{lifespan => lifespan(S), reach => reach(S)}.

lifespan(#{population := 0}) -> 0;
lifespan(#{population := Pop, born := Born}) ->
    scaled(Pop * ?TICKS * 100, Born + 40 - Pop).

scaled(_Num, 0) -> 0;
scaled(Num, Deaths) -> Num div Deaths.

reach(#{sensors := Sensors}) ->
    lists:sum([maps:get(reach, F, 0) || F <- maps:values(Sensors)]).

%%==============================================================================

in_parallel(F, Items) ->
    Parent = self(),
    Refs = [spawn_one(Parent, F, I) || I <- Items],
    [receive {Ref, Result} -> Result end || Ref <- Refs].

spawn_one(Parent, F, Item) ->
    Ref = make_ref(),
    spawn_link(fun() -> Parent ! {Ref, F(Item)} end),
    Ref.

median([]) -> 0;
median(L) -> lists:nth(length(L) div 2 + 1, lists:sort(L)).

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(C, 8, trailing).
