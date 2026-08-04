#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc WORLD 23: HOW MANY HOLES, AND IS IT A PRESSURE OR A SIEVE?
%%
%% Usage:  ./scripts/sweep_water.escript [seeds [ticks]]
%%
%% Breeding requires standing on water. Few big holes concentrate hardest and are
%% furthest away; many small ones are reachable and concentrate least. **That
%% tension is the experiment**, named in `PLAN.md` before any of it was measured,
%% and every value is published.
%%
%% ==========================================================================
%% THE COLUMN THAT DECIDES IT IS `APPROACH`, AND A FILTER IS PREDICTED
%% ==========================================================================
%%
%% Creatures are scattered at random when a world is founded, so the mean
%% distance to the nearest hole AT TICK ZERO is the null. `APPROACH` is how far
%% that distance has fallen by the end, as a percentage.
%%
%%   FALLS   creatures evolved to sense water and go to it. Adaptation.
%%   FLAT    the rule killed whatever was born too far out and selected on
%%           birthplace. **A cull, which would look like a result.**
%%
%% The pre-registration predicts FLAT. At seven holes half the population cannot
%% reach water inside a life at all.
%%
%% ⚠ MEDIANS ARE OVER LIVING WORLDS AND THE DEAD ARE COUNTED SEPARATELY.
%% Commitment 10, added after a median over all seeds read 21 cells where living
%% worlds had reached 76 and nearly confirmed a finding by a factor of five.
-mode(compile).

main(Args) ->
    Seeds = arg(Args, 1, 24),
    Ticks = arg(Args, 2, 8000),
    io:format("~n~p seeds to ~p ticks. World ~p.~n"
              "APPROACH is how much nearer to water the population got than it "
              "was scattered.~nFlat means a cull.~n~n",
              [Seeds, Ticks, maps:get(number, world:ruleset())]),
    io:format("~s~n", [row(["holes", "dead", "pop", "born", "dry/born",
                            "at birth", "at end", "APPROACH", "water sens",
                            "nodes", "meat%", "depth", "explored", "front"])]),
    lists:foreach(fun(H) -> arm(H, Seeds, Ticks) end, [0, 1, 7, 19, 37, 61]),
    io:format("~nwater sens is the share of creatures carrying a sensor for the "
              "water field.~nA cull leaves it at chance; a pressure raises it.~n").

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.

arm(Holes, Seeds, Ticks) ->
    Rows = in_parallel(fun(S) -> run(S, Holes, Ticks) end, lists:seq(1, Seeds)),
    Live = [R || #{now := #{population := P}} = R <- Rows, P > 0],
    io:format("~s~n", [row([Holes, Seeds - length(Live) | summarise(Live)])]).

run(Seed, Holes, Ticks) ->
    W = world:new(#{seed => Seed, population => 40, water_holes => Holes}),
    #{was => world:snapshot(W), now => world:snapshot(advance(W, Ticks))}.

summarise([]) -> lists:duplicate(12, "-");
summarise(Live) ->
    Med = fun(K) -> median([maps:get(K, N) || #{now := N} <- Live]) end,
    Born = Med(born),
    io:format("", []),
    [Med(population), Born, times(Med(births_dry), Born),
     hundredths(median([maps:get(to_water_mean, S) || #{was := S} <- Live])),
     hundredths(Med(to_water_mean)),
     [integer_to_list(approach(Live)), "%"],
     [integer_to_list(sensing(Live)), "%"],
     hundredths(Med(hidden_mean)), [integer_to_list(Med(from_creatures_pct)), "%"],
     Med(depth), Med(explored), Med(frontier)].

%% How much nearer the population ended up than it was scattered. Per seed, then
%% the median, so one seed that happened to found itself on a hole cannot carry
%% the arm.
approach(Live) ->
    median([closer(maps:get(to_water_mean, Was), maps:get(to_water_mean, Now))
            || #{was := Was, now := Now} <- Live]).

closer(0, _Now) -> 0;
closer(Was, Now) -> (Was - Now) * 100 div Was.

%% Carriers of a water sensor, out of the population. `body:census/1` reports
%% carriers per field and already existed.
sensing(Live) ->
    median([share(maps:get(water, maps:get(sensors, N), #{}),
                  maps:get(population, N)) || #{now := N} <- Live]).

share(#{carriers := C}, Pop) when Pop > 0 -> C * 100 div Pop;
share(_Absent, _Pop) -> 0.

times(_Dry, 0) -> "-";
times(Dry, Born) -> [integer_to_list(Dry div max(1, Born)), "x"].

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(500, Left),
    going(world:population(W) > 0, world:tick(W, Step), Left - Step).

going(false, W, _Left) -> W;
going(true, W, Left) -> advance(W, Left).

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

hundredths(V) -> io_lib:format("~w.~2..0w", [V div 100, V rem 100]).

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).
pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(lists:flatten(C), 11, trailing).
