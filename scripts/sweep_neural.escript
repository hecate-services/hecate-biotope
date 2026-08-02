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
%% ⚠ RE-USED BY WORLD 19, AND ITS MEANING CHANGED UNDER IT. This measured world
%% 13's question: at what price does computation start paying for itself. World
%% 19 makes a weight cost only if it is non-zero, so `neural_cost` now prices
%% LIVE wiring rather than row length, and the same sweep asks a different
%% question with the same shape: at what price does computation pay for itself
%% ONCE A LINEAGE CAN ECONOMISE ON IT.
%%
%% `I.6`: an instrument is correct when written and is made wrong by a change to
%% the thing it measures. This one is not made wrong, it is made sharper, and the
%% `WIDTH` column below is what world 19 added because `H.11` said narrowness was
%% inexpressible and so nothing had ever needed to measure it.
%%
%% SEEDS ARE A PARAMETER NOW. Five was world 13's and world 17 established that
%% even 24 could not separate its candidates.
-define(DEFAULT_SEEDS, 48).
-define(STEPS, [330, 220, 165, 110, 66, 33, 11, 3, 1]).

main(Args) ->
    Seeds = seeds(Args),
    Ticks = ticks(Args),
    io:format("~nticks=~p seeds=~p at 100% efficiency. 330 is the control and is "
              "under review, `B.10`.~n~n", [Ticks, Seeds]),
    io:format("~s~n", [row(["neural", "dead", "pop", "sens", "brain", "WIDTH",
                            "reach", "life", "meat%", "frame", "lines",
                            "depth"])]),
    lists:foreach(fun(N) -> report(N, Seeds, Ticks) end, ?STEPS),
    io:format("~nsens and brain are per creature times a hundred. **WIDTH is live "
              "weights per~nhidden node, times a hundred, over the creatures that "
              "HAVE one**: the column~nworld 19 exists to move, and `H.11` says "
              "it could not move before. reach is~ntotal sensor reach carried by "
              "the population. dead = seeds extinct of ~p.~n", [Seeds]).

seeds([]) -> ?DEFAULT_SEEDS;
seeds([S | _]) -> list_to_integer(S).

%% THE HORIZON IS A PARAMETER BECAUSE 2,000 WAS WORLD 13's AND THE SWEEPS THIS IS
%% READ AGAINST USE 20,000. World 14 measured five of every seven seeds that
%% clear 700 dying shortly after it, so a short horizon reports a death rate that
%% is not the death rate. The ORDERING survives a short run; the counts do not.
ticks([_Seeds, T | _]) -> list_to_integer(T);
ticks(_Args) -> ?TICKS.

report(Neural, Seeds, Ticks) ->
    Rows = in_parallel(fun(Seed) -> run(Seed, Neural, Ticks) end,
                       lists:seq(1, Seeds)),
    Dead = length([R || #{population := 0} <- Rows, R <- [1]]),
    io:format("~s~n", [row([Neural, Dead | summarise([R || #{population := P} = R <- Rows, P > 0])])]).

summarise([]) -> lists:duplicate(10, "-");
summarise(Rows) ->
    Med = fun(K) -> median([maps:get(K, R) || R <- Rows]) end,
    [Med(population), Med(sensor_mean), Med(hidden_mean), Med(hidden_width),
     Med(reach), Med(lifespan), Med(from_creatures_pct), Med(structure_max),
     Med(lineages), Med(depth)].

run(Seed, Neural, Ticks) ->
    S = world:snapshot(advance(world:new(#{seed => Seed, population => 40,
                                           transfer_efficiency => 100,
                                           neural_cost => Neural}), Ticks)),
    S#{lifespan => lifespan(S, Ticks), reach => reach(S)}.

%% In chunks, so a world that ends at tick 600 is not ticked another 19,400 times
%% for nothing. At 20,000 ticks and 48 seeds that is most of the run.
advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(1000, Left),
    going(world:population(W) > 0, world:tick(W, Step), Left - Step).

going(false, W, _Left) -> W;
going(true, W, Left) -> advance(W, Left).

lifespan(#{population := 0}, _Ticks) -> 0;
lifespan(#{population := Pop, born := Born}, Ticks) ->
    scaled(Pop * Ticks * 100, Born + 40 - Pop).

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
