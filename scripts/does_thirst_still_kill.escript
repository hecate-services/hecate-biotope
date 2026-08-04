#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% DOES ANYTHING STILL DIE OF THIRST, ON THE WORLD THE FLEET ACTUALLY RUNS.
%%
%% World 23 made thirst 16-25% of all deaths. That was measured on CONCENTRIC
%% RINGS, where the outermost water sat at half the radius and 73% of the island
%% had no water anywhere further out. Much of that killing was creatures born on
%% a dry rim they could never leave.
%%
%% World 24 replaced the rings with lakes and rivers, and a river runs to the
%% shore, so the dry rim is 0%. **That should reduce thirst deaths and might
%% remove them**, which would mean the rule has quietly stopped doing anything
%% while still being described as the point of the world.
%%
%% Four causes and they are exhaustive: starved, eaten, aged out, parched.
-mode(compile).

main(Args) ->
    Seeds = arg(Args, 1, 24),
    Ticks = arg(Args, 2, 4000),
    io:format("~n~p seeds to ~p ticks, world ~p, at the DEFAULT econ the fleet "
              "runs.~n~n", [Seeds, Ticks, maps:get(number, world:ruleset())]),
    Rows = in_parallel(fun(S) -> run(S, Ticks) end, lists:seq(1, Seeds)),
    Live = [R || #{population := P} = R <- Rows, P > 0],
    io:format("seeds alive           : ~w of ~w~n", [length(Live), Seeds]),
    report(Live, Rows).

report([], _All) ->
    io:format("~nEvery seed died. Nothing to read.~n");
report(Live, All) ->
    io:format("~ndeaths, summed over every seed INCLUDING the dead, because a~n"
              "world that died of thirst is the strongest evidence there is:~n~n"),
    Totals = [{K, lists:sum([maps:get(K, R) || R <- All])}
              || K <- [starved, consumed, aged_out, parched]],
    Deaths = lists:sum([V || {_K, V} <- Totals]),
    [io:format("  ~-10s ~-12w ~s~n", [K, V, pct(V, Deaths)])
     || {K, V} <- Totals],
    io:format("~nliving worlds only, median share of deaths from thirst: ~s~n",
              [pct(median([maps:get(parched, R) || R <- Live]),
                   median([deaths(R) || R <- Live]))]),
    io:format("median wet cells      : ~w~n",
              [median([maps:get(water_holes, R) || R <- Live])]),
    io:format("median cells to water : ~s~n",
              [hundredths(median([maps:get(to_water_mean, R) || R <- Live]))]),
    verdict(lists:keyfind(parched, 1, Totals), Deaths).

verdict({parched, 0}, _Deaths) ->
    io:format("~nNOTHING DIES OF THIRST. The rule is inert and the world is~n"
              "world 22 with a blue decoration on it.~n");
verdict({parched, N}, Deaths) when N * 100 div max(1, Deaths) < 1 ->
    io:format("~nTHIRST KILLS UNDER 1% OF DEATHS. Present, and too small to be~n"
              "a selection pressure at this world's drift floor.~n");
verdict({parched, N}, Deaths) ->
    io:format("~nTHIRST KILLS ~s OF EVERYTHING THAT DIES.~n", [pct(N, Deaths)]).

deaths(R) ->
    lists:sum([maps:get(K, R) || K <- [starved, consumed, aged_out, parched]]).

run(Seed, Ticks) ->
    world:snapshot(advance(world:new(#{seed => Seed, population => 40}), Ticks)).

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(500, Left),
    going(world:population(W) > 0, world:tick(W, Step), Left - Step).

going(false, W, _Left) -> W;
going(true, W, Left) -> advance(W, Left).

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.

in_parallel(F, Items) ->
    Parent = self(),
    Refs = [begin R = make_ref(),
                  spawn_link(fun() -> Parent ! {R, F(I)} end), R
            end || I <- Items],
    [receive {Ref, Result} -> Result end || Ref <- Refs].

median([]) -> 0;
median(L) -> lists:nth(length(L) div 2 + 1, lists:sort(L)).

pct(_Part, 0) -> "-";
pct(Part, Whole) -> io_lib:format("~w%", [Part * 100 div Whole]).

hundredths(V) -> io_lib:format("~w.~2..0w", [V div 100, V rem 100]).
