#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% Derive `influx' from the criterion fixed in PREREGISTRATION.md, by measuring.
%%
%% ==========================================================================
%% WHY THIS EXISTS AS A SEPARATE INSTRUMENT
%% ==========================================================================
%%
%% `influx' alone decides whether plants can exist. Set it generously and
%% everything sits still; set it meanly and sessility is fatal and world 1
%% returns. It is therefore the number most at risk of being chosen for the
%% result it produces, which is exactly the mistake this project made once
%% already when `scent_mutation' was set to whatever gave the most carnivores.
%%
%% So the criterion was written down BEFORE any of this was built, refers only to
%% the economy, and mentions nothing about what evolves:
%%
%%   THE SMALLEST INFLUX AT WHICH A SENSORLESS CREATURE THAT NEVER MOVES CAN
%%   ACCUMULATE ENOUGH TO RAISE ONE CHILD WITHIN max_age.
%%
%% That is the least generous value at which the sessile option exists at all.
%% Anything smaller forbids plants outright, so it cannot be accused of
%% installing them.
%%
%% AND IT IS MEASURED RATHER THAN CALCULATED, which is the point of the file. The
%% arithmetic in world.erl says 12: surplus per tick is influx minus metabolism,
%% doubling 800 within 600 ticks needs a surplus of 1.33, so 2, so 12. That
%% reasoning ignores at least one thing the world actually does, and a number
%% derived in somebody's head is exactly the kind that is quietly wrong.
%%
%% THE WINDFALL IS EXCLUDED DELIBERATELY. A world begins with every cell full, so
%% the first absorption hands a founder a whole ceiling at once. That is real, but
%% it is a one-off: the criterion has to bind in STEADY STATE, because steady
%% state is the condition a sessile lineage must survive in for good. So the
%% measurement runs a tick to drain the cell first and reads the trajectory after.
main(_Args) ->
    Econ = world:defaults(),
    io:format("~nmetabolism=~p start_energy=~p max_age=~p ground_ceiling=~p~n~n",
              [maps:get(metabolism, Econ), maps:get(start_energy, Econ),
               maps:get(max_age, Econ), maps:get(ground_ceiling, Econ)]),
    sessile_table(Econ),
    Smallest = smallest_viable(Econ),
    verdict(Smallest, maps:get(influx, Econ)),
    mobile_check(Econ, Smallest).

%%==============================================================================
%% The sessile lifestyle
%%==============================================================================

%% A creature with no sensors, no hidden layer and no outputs at all: it cannot
%% move, cannot breed, and pays nothing but metabolism. The cheapest thing the
%% rules allow, which is what the criterion is about.
still() ->
    #{founder_body => [], founder_brain => #{hidden => [], outputs => #{}}}.

sessile_table(Econ) ->
    io:format("~s~n", [row(["influx", "gain/tick", "over life", "needs",
                            "raises a child"])]),
    lists:foreach(fun(I) -> print_sessile(I, Econ) end, lists:seq(9, 16)).

print_sessile(Influx, Econ) ->
    {Gain, Over} = sessile_gain(Influx, Econ),
    Needs = maps:get(start_energy, Econ),
    io:format("~s~n", [row([Influx, Gain, Over, Needs, yesno(Over >= Needs)])]).

%% Energy gained per tick in steady state, and over a whole lifetime, with the
%% opening windfall excluded.
sessile_gain(Influx, Econ) ->
    W0 = world:new(maps:merge(#{influx => Influx, population => 1, radius => 2,
                                seed => 1}, still())),
    Settled = world:tick(W0, 1),
    Life = maps:get(max_age, Econ),
    {energy(world:tick(Settled, 1)) - energy(Settled),
     energy(world:tick(Settled, Life)) - energy(Settled)}.

energy(W) ->
    #{energy_total := E} = world:snapshot(W),
    E.

smallest_viable(Econ) ->
    Needs = maps:get(start_energy, Econ),
    Viable = [I || I <- lists:seq(1, 40),
                   element(2, sessile_gain(I, Econ)) >= Needs],
    first(Viable).

first([]) -> none;
first([I | _]) -> I.

verdict(Smallest, Configured) ->
    io:format("~nsmallest influx meeting the criterion: ~p~n", [Smallest]),
    io:format("configured in world:defaults/0:            ~p~n", [Configured]),
    io:format("~s~n", [agreement(Smallest =:= Configured)]).

agreement(true) ->
    "AGREES. The configured value is the least generous one at which a sessile\n"
    "lineage can sustain itself, so the option exists and nothing more was given.";
agreement(false) ->
    "DISAGREES. The configured value was not derived from the criterion after\n"
    "all, and must be changed to the measured one. See PREREGISTRATION.md: a\n"
    "number may never be kept because of what evolves in it.".

%%==============================================================================
%% The other direction
%%==============================================================================

%% BOTH WAYS OF MAKING A LIVING MUST BE REACHABLE, or the world has decided in
%% advance which one wins. The sessile criterion sets a floor; this checks the
%% ceiling has not been set below it, by asking whether a creature that walks
%% every tick also comes out ahead.
%%
%% Measured alone on an empty board, so it always finds unvisited ground. That
%% establishes only that foraging is VIABLE, not that it beats sitting still at
%% density, which is the question the population itself is left to answer.
mobile_check(Econ, Influx) ->
    Roamer = #{founder_body => [],
               founder_brain => #{hidden => [],
                                  outputs => #{move => #{inputs => [-1],
                                                         hidden => []}}}},
    W0 = world:new(maps:merge(#{influx => Influx, population => 1, radius => 12,
                                seed => 1}, Roamer)),
    Settled = world:tick(W0, 1),
    Life = maps:get(max_age, Econ),
    Over = energy(world:tick(Settled, Life)) - energy(Settled),
    io:format("~na wanderer on open ground gains ~p over a lifetime, "
              "against a floor of ~p~n", [Over, maps:get(start_energy, Econ)]),
    io:format("~s~n", [reachable(Over >= maps:get(start_energy, Econ))]),
    saturated(Econ, Influx).

%% AND THE SAME SUM ONCE THE BOARD IS FULL, which the criterion never asked about
%% and which turns out to decide everything.
%%
%% A grazed cell holds exactly one tick of influx by the time anyone returns to
%% it, so a creature that walks every tick earns `influx' and pays metabolism AND
%% the fare. Sitting still earns the same and pays only metabolism. The mover is
%% therefore behind by exactly the cost of moving, at every density, once the
%% ground has been picked over.
%%
%% That makes sessility an UNCONDITIONAL winner rather than a competitor: it pays
%% at any density, while moving pays only while there is unvisited ground, which
%% is a condition that ends. It is reported rather than fixed. Changing move_cost
%% to rescue movement would be choosing a rule for the phenotype it produces,
%% which is the one thing PREREGISTRATION.md forbids outright.
saturated(Econ, Influx) ->
    Metabolism = maps:get(metabolism, Econ),
    Fare = maps:get(move_cost, Econ),
    io:format("~non a fully grazed board, per tick:~n"),
    io:format("  staying  ~p - ~p        = ~p~n",
              [Influx, Metabolism, Influx - Metabolism]),
    io:format("  moving   ~p - ~p - ~p   = ~p~n",
              [Influx, Metabolism, Fare, Influx - Metabolism - Fare]),
    io:format("~s~n", [endgame(Influx - Metabolism - Fare > 0)]).

endgame(true) ->
    "Both still pay once the ground is picked over.";
endgame(false) ->
    "MOVING CANNOT PAY once the ground is picked over, at any density, so\n"
    "sessility wins the endgame unconditionally and every sensory organ is dead\n"
    "weight in it. Not a defect to be tuned away: it is what these numbers mean,\n"
    "and it is the sharpest question to put to a world 3.".

reachable(true) ->
    "Both livings are reachable, so neither is priced out before selection sees\n"
    "it, which is all this check claims.";
reachable(false) ->
    "MOVING IS NOT VIABLE at this influx even on open ground. The world has\n"
    "decided in advance that everything must sit still.".

%%==============================================================================

row(Cells) -> [pad(C) || C <- Cells].

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(C, 16, trailing).

yesno(true) -> "yes";
yesno(false) -> "no".
