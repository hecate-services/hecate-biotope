#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc DO THE STRUCTURAL CEILINGS BIND?
%%
%% Usage:  ./scripts/are_the_caps_binding.escript [seeds [ticks [neural_cost]]]
%%
%% Three numbers about a creature have a ceiling and THE THREE CEILINGS ARE NOT
%% THE SAME KIND OF THING:
%%
%%   sensors    `max_sensors' 8, a SAFETY VALVE. body.erl calls the founder
%%              distribution "a starting distribution, not a limit: mutation adds
%%              and removes without reference to either, and rent is what
%%              actually bounds a body". That sentence is only true while the
%%              valve is shut.
%%   hidden     `max_hidden' 6, the same kind of valve.
%%   actuators  4, and NOT a valve at all: `?PURPOSES' is move, breed, grow, eat,
%%              which is the list of things there are to do in this world. A
%%              creature at 4 has not hit a limit, it has hit the physics.
%%
%% ⚠ A BINDING VALVE INVALIDATES A SWEEP RATHER THAN LIMITING IT. World 19 read
%% sensors rising 2.03 to 5.90 as `neural_cost' fell 330 to 1 and called it a
%% response to price. If the 5.90 end is a population piled against 8, the
%% response was censored at the cheap end and the true slope is unknown. So this
%% reports the SHARE AT THE CEILING, not the mean, because a mean well under a
%% cap is exactly what a piled-up distribution looks like when the pile is a
%% third of the population.
-mode(compile).

main(Args) ->
    Seeds = arg(Args, 1, 24),
    Ticks = arg(Args, 2, 20000),
    Cost = arg(Args, 3, 11),
    Econ = maps:merge(world:defaults(), #{neural_cost => Cost}),
    io:format("~n~p seeds, ~p ticks, neural_cost ~p. Ceilings: sensors ~p, "
              "hidden ~p, purposes ~p.~n~n",
              [Seeds, Ticks, Cost, maps:get(max_sensors, Econ),
               maps:get(max_hidden, Econ), length(brain:purposes())]),
    Live = lists:append([alive(S, Ticks, Cost) || S <- lists:seq(1, Seeds)]),
    report(Live, Econ).

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.

alive(Seed, Ticks, Cost) ->
    W = advance(world:new(#{seed => Seed, population => 40,
                            neural_cost => Cost}), Ticks),
    maps:values(world:creatures(W)).

report([], _Econ) ->
    io:format("Every seed died. Nothing to census.~n");
report(Live, Econ) ->
    N = length(Live),
    Sensors = [length(maps:get(body, C)) || C <- Live],
    Hidden = [brain:hidden_count(maps:get(brain, C)) || C <- Live],
    Acts = [length(brain:carried(maps:get(brain, C))) || C <- Live],
    io:format("~s~n", [row(["trait", "ceiling", "mean", "AT CEILING", "share"])]),
    line("sensors", Sensors, maps:get(max_sensors, Econ), N),
    line("hidden", Hidden, maps:get(max_hidden, Econ), N),
    line("actuators", Acts, length(brain:purposes()), N),
    io:format("~n~p creatures censused across all surviving seeds.~n~n~s~n",
              [N, verdict(share(Sensors, maps:get(max_sensors, Econ), N),
                          share(Hidden, maps:get(max_hidden, Econ), N))]).

line(Name, Vs, Cap, N) ->
    Mean = lists:sum(Vs) * 100 div max(1, N),
    io:format("~s~n", [row([Name, Cap, hundredths(Mean),
                            length([V || V <- Vs, V >= Cap]),
                            [integer_to_list(share(Vs, Cap, N)), "%"]])]).

share(Vs, Cap, N) -> length([V || V <- Vs, V >= Cap]) * 100 div max(1, N).

%% The threshold is stated rather than felt. A cap that a twentieth of the
%% population reaches is a valve doing its job; one that a fifth reaches is a
%% censored measurement, because the distribution above it cannot be observed and
%% every one of those creatures would have been somewhere else.
verdict(Sensors, Hidden) when Sensors >= 20 ->
    "SENSORS ARE CENSORED. A fifth or more of the population sits AT\n"
    "`max_sensors', so the sweep's cheap end measured a ceiling and not a\n"
    "response. Raise the cap and re-run before reading any slope in sensors."
        ++ also(Hidden);
verdict(Sensors, Hidden) when Sensors >= 5 ->
    "SENSORS ARE PRESSING ON THE VALVE but not piled against it. Worth raising\n"
    "the cap to check the slope survives, and worth saying so in any result\n"
    "that quotes a sensor mean." ++ also(Hidden);
verdict(_Sensors, Hidden) ->
    "SENSORS ARE FREE OF THE CEILING. Rent bounds the body, as body.erl claims."
        ++ also(Hidden).

also(Hidden) when Hidden >= 5 ->
    "\n\nAND HIDDEN NODES ARE AT THEIR OWN CEILING, which would be the first time\n"
    "computation has been limited by anything but its price.";
also(_Hidden) ->
    "\n\nHidden nodes are nowhere near their ceiling: what limits them is price\n"
    "and drift, which is what world 19 found.".

hundredths(V) -> io_lib:format("~w.~2..0w", [V div 100, V rem 100]).

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(1000, Left),
    going(world:population(W) > 0, world:tick(W, Step), Left - Step).

going(false, W, _Left) -> W;
going(true, W, Left) -> advance(W, Left).

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).
pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(lists:flatten(C), 12, trailing).
