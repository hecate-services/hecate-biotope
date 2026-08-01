#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% Derive the ground's two constants from the criteria in PREREGISTRATION.md, by
%% measuring rather than by arithmetic.
%%
%% These are the numbers most at risk of being chosen for the result they give,
%% which is the mistake this project made once already when `scent_mutation' was
%% set to whatever produced the most carnivores. So both criteria were written
%% down before world 3 was built, both refer only to the economy or to the
%% resource, and neither mentions what evolves.
%%
%%   ground_seed        the smallest at which a sensorless creature that never
%%                      moves can raise one child within max_age. WORLD 2'S
%%                      CRITERION KEPT VERBATIM, so the two worlds differ in one
%%                      mechanism and not in how their constants were chosen.
%%
%%   ground_growth_pct  the smallest at which recovery is mostly COMPOUNDING
%%                      rather than mostly linear, meaning the proportional term
%%                      overtakes the seed floor below half the ceiling.
%%
%%                      AMENDED, BEFORE ANY RUN, and the original is recorded in
%%                      PREREGISTRATION.md rather than quietly replaced. It read
%%                      "recovers to half the ceiling within one max_age", and
%%                      this script showed it does not discriminate: at
%%                      ground_seed 12 the floor ALONE carries a bare cell to
%%                      half the ceiling in seventeen ticks, so every rate from
%%                      zero upward satisfied it and zero was the smallest.
%%                      Growth would have been linear at 12 forever, which is
%%                      world 2 exactly, and the one change world 3 exists to
%%                      make would have been inert.
%%
%%                      The replacement is still a property of the RESOURCE and
%%                      of no lifestyle, and it still does not guarantee movement
%%                      pays. It says only that the mechanism operates at all,
%%                      which is the same class of requirement as a sense having
%%                      something to discriminate.
%%
%% MEASURED, NOT CALCULATED. A number derived in somebody's head is exactly the
%% kind that is quietly wrong, and the last one nearly was: the arithmetic for
%% world 2's influx ignored the opening windfall, and only excluding it by hand
%% made the measurement agree.
main(_Args) ->
    Econ = world:defaults(),
    io:format("~nmetabolism=~p start_energy=~p max_age=~p ground_ceiling=~p~n~n",
              [maps:get(metabolism, Econ), maps:get(start_energy, Econ),
               maps:get(max_age, Econ), maps:get(ground_ceiling, Econ)]),
    sessile_table(Econ),
    verdict("ground_seed", smallest_viable(Econ), maps:get(ground_seed, Econ)),
    recovery_table(Econ),
    verdict("ground_growth_pct", fastest_enough(Econ),
            maps:get(ground_growth_pct, Econ)),
    yield_line(Econ),
    upkeep_table(Econ),
    verdict(largest, "upkeep_divisor", gentlest_binding(Econ),
            maps:get(upkeep_divisor, Econ)),
    endgame(Econ).

%%==============================================================================
%% What it costs to be large
%%==============================================================================

%% WORLD 5'S CONSTANT, and the free good it prices. Metabolism was flat, so a
%% creature carrying ten thousand paid what one carrying ten paid, and energy was
%% armour that cost nothing. That is why world 4's feeding tradeoff was
%% overridden: large creatures win contests and 97% of deaths are being eaten.
%%
%% The criterion, fixed before measuring: the LARGEST divisor at which a creature
%% feeding at the sustainable yield cannot grow beyond what one full cell holds.
%% Largest because that is the gentlest pricing that still binds, and a cap that
%% never bites is exactly how world 3 failed.
%%
%% MEASURED BY LETTING ONE ACTUALLY GROW, not by algebra. The settling point is
%% where income meets upkeep and the arithmetic for it is easy to get subtly
%% wrong, which is the whole reason this file exists.
upkeep_table(Econ) ->
    io:format("~s~n", [row(["divisor", "settles at", "one cell holds",
                            "within it"])]),
    lists:foreach(fun(D) -> print_upkeep(D, Econ) end,
                  [10, 20, 30, 33, 34, 40, 60, 100]).

print_upkeep(Divisor, Econ) ->
    Ceiling = maps:get(ground_ceiling, Econ),
    Settles = settled_size(Divisor, Econ),
    io:format("~s~n", [row([Divisor, Settles, Ceiling,
                            yesno(Settles =< Ceiling)])]).

%% One creature, feeding at exactly the sustainable yield on ground that can
%% supply it for ever, left alone until it stops growing.
settled_size(Divisor, Econ) ->
    Yield = ground:sustainable(Econ),
    W = world:new(#{population => 1, radius => 2, seed => 1,
                    ground_seed => Yield, ground_growth_pct => 0,
                    ground_ceiling => Yield, upkeep_divisor => Divisor,
                    founder_uptake => Yield, max_age => 100000000,
                    start_energy => 1, founder_body => [],
                    founder_brain => #{hidden => [], outputs => #{}}}),
    #{energy_max := Size} = world:snapshot(world:tick(W, 20000)),
    Size.

gentlest_binding(Econ) ->
    Ceiling = maps:get(ground_ceiling, Econ),
    Fitting = [D || D <- lists:seq(1, 200), settled_size(D, Econ) =< Ceiling],
    last_of(Fitting).

last_of([]) -> none;
last_of(L) -> lists:last(L).

%% THE LINE BETWEEN THE TWO LIVINGS, which world 4's pre-registration requires be
%% measured and reported before any run. It is derived from the growth curve
%% rather than chosen, and it is reported so that both sides are known to be
%% REACHABLE, never to arrange which side wins.
yield_line(Econ) ->
    Sustainable = ground:sustainable(Econ),
    Metabolism = maps:get(metabolism, Econ),
    Ceiling = maps:get(ground_ceiling, Econ),
    io:format("the most a cell yields every tick without being stripped: ~p~n",
              [Sustainable]),
    io:format("  a lineage feeding at or below it holds its cell for good~n"),
    io:format("  above it the cell is stripped and income falls to ~p, the floor~n",
              [maps:get(ground_seed, Econ)]),
    io:format("  founding rates are drawn across 0 to ~p, so both sides exist~n",
              [Ceiling]),
    io:format("~s~n~n", [reachable(Sustainable > Metabolism, Sustainable,
                                   Metabolism)]).

reachable(true, Sustainable, Metabolism) ->
    io_lib:format("BOTH LIVINGS ARE REACHABLE: a prudent lineage nets ~p a tick "
                  "against a~ncost of ~p, and a greedy one must move or starve. "
                  "Which wins is not~nsomething this script can say, and is the "
                  "question being asked.",
                  [Sustainable, Metabolism]);
reachable(false, Sustainable, Metabolism) ->
    io_lib:format("STAYING PUT IS NOT VIABLE AT ALL: the best a cell can sustain "
                  "is ~p against~na cost of ~p, so the world has decided in "
                  "advance that everything must move.",
                  [Sustainable, Metabolism]).

%%==============================================================================
%% Whether sitting still can support a lineage
%%==============================================================================

%% A creature with no sensors, no hidden layer and no outputs at all: it cannot
%% move, cannot breed, and pays nothing but metabolism. The cheapest thing the
%% rules allow, which is what the criterion is about.
still() ->
    #{founder_body => [], founder_brain => #{hidden => [], outputs => #{}}}.

%% A STRIPPER GETS THE SEED RATE AND NOTHING ELSE. It empties its cell every
%% tick, so there is never any stock left to compound from and the proportional
%% term contributes nothing at all. That is the whole point of world 3: to sit
%% still is to suppress your own supply.
sessile_table(Econ) ->
    io:format("~s~n", [row(["seed", "gain/tick", "over life", "needs",
                            "raises a child"])]),
    lists:foreach(fun(S) -> print_sessile(S, Econ) end, lists:seq(9, 16)).

print_sessile(Seed, Econ) ->
    {Gain, Over} = sessile_gain(Seed, Econ),
    Needs = maps:get(start_energy, Econ),
    io:format("~s~n", [row([Seed, Gain, Over, Needs, yesno(Over >= Needs)])]).

%% THE WINDFALL IS EXCLUDED. A world begins with every cell full, so the first
%% absorption hands a founder a whole ceiling at once. Real, but a one-off: the
%% criterion has to bind in STEADY STATE, which is the condition a lineage must
%% survive in for good. So a tick is run to drain the cell before reading.
sessile_gain(Seed, Econ) ->
    W0 = world:new(maps:merge(#{ground_seed => Seed, ground_growth_pct => 0,
                                population => 1, radius => 2, seed => 1},
                              still())),
    Settled = world:tick(W0, 1),
    Life = maps:get(max_age, Econ),
    {energy(world:tick(Settled, 1)) - energy(Settled),
     energy(world:tick(Settled, Life)) - energy(Settled)}.

energy(W) ->
    #{energy_total := E} = world:snapshot(W),
    E.

smallest_viable(Econ) ->
    Needs = maps:get(start_energy, Econ),
    first([S || S <- lists:seq(1, 40),
                element(2, sessile_gain(S, Econ)) >= Needs]).

%%==============================================================================
%% How fast bare ground comes back
%%==============================================================================

%% A PROPERTY OF THE RESOURCE AND OF NO LIFESTYLE. Nothing lives on this board:
%% one cell is stripped to nothing and left alone, and the only question is
%% whether it returns within the time a creature is alive. If it does not,
%% returning to a grazed cell can never be worth anything to anybody and the
%% whole change is inert. If it does, whether anything EXPLOITS that is the
%% question this world exists to ask, and is not to be arranged here.
recovery_table(Econ) ->
    io:format("~s~n", [row(["growth%", "compounds above", "half ceiling",
                            "mostly compounding"])]),
    lists:foreach(fun(P) -> print_recovery(P, Econ) end, lists:seq(0, 10)).

print_recovery(Pct, Econ) ->
    Half = maps:get(ground_ceiling, Econ) div 2,
    Over = crossover(Pct, Econ),
    io:format("~s~n", [row([Pct, stock(Over), Half, yesno(compounds(Over, Half))])]).

%% The stock at which the proportional term first beats the seed floor. Below it
%% the ground recovers at a flat rate and behaves exactly as world 2's did; above
%% it, leaving ground alone longer yields disproportionately more, which is the
%% only thing that can make returning to it worth a fare.
crossover(0, _Econ) -> never;
crossover(Pct, Econ) ->
    Seed = maps:get(ground_seed, Econ),
    beyond(100 * Seed div Pct, maps:get(ground_ceiling, Econ)).

beyond(At, Ceiling) when At >= Ceiling -> never;
beyond(At, _Ceiling) -> At.

compounds(never, _Half) -> false;
compounds(At, Half) -> At =< Half.

stock(never) -> "never";
stock(N) -> integer_to_list(N).

fastest_enough(Econ) ->
    Half = maps:get(ground_ceiling, Econ) div 2,
    first([P || P <- lists:seq(0, 100),
                compounds(crossover(P, Econ), Half)]).

%%==============================================================================
%% What the change was for
%%==============================================================================

%% WORLD 2'S PROOF, PUT AGAINST WORLD 3'S RULES. There a mover's income at
%% equilibrium was exactly metabolism, so it netted minus the fare for every
%% parameter choice and sessility won unconditionally. The number that made that
%% inevitable was a fixed influx, and it is gone.
%%
%% What replaces it cannot be reduced to one line, because total productivity is
%% now ENDOGENOUS: it depends on how hard the population grazes. So this reports
%% the two extremes and refuses to predict the middle, which is exactly what the
%% world is being run to find out.
endgame(Econ) ->
    Seed = maps:get(ground_seed, Econ),
    Metabolism = maps:get(metabolism, Econ),
    Fare = maps:get(move_cost, Econ),
    Ceiling = maps:get(ground_ceiling, Econ),
    io:format("per tick, at the two extremes:~n"),
    io:format("  stripping and staying    ~p - ~p       = ~p~n",
              [Seed, Metabolism, Seed - Metabolism]),
    io:format("  arriving at full ground  ~p - ~p - ~p  = ~p~n",
              [Ceiling, Metabolism, Fare, Ceiling - Metabolism - Fare]),
    io:format("~nA stayer now suppresses its own supply and gets the seed rate~n"
              "alone. What a mover finds depends on how long the ground has been~n"
              "left, which depends on how the population behaves, which is no~n"
              "longer fixed by the rules. That is the whole change, and whether~n"
              "anything exploits it is not something this script can say.~n").

%%==============================================================================

verdict(Name, Value, Configured) -> verdict(smallest, Name, Value, Configured).

%% WHICH END OF THE RANGE IS THE LEAST GENEROUS DEPENDS ON THE CONSTANT, and
%% saying "smallest" for one where the answer is the largest would mislead a
%% reader into thinking the criterion had been read backwards.
verdict(Which, Name, Value, Configured) ->
    io:format("~n~s ~s meeting its criterion: ~p~n", [Which, Name, Value]),
    io:format("configured in world:defaults/0:   ~p~n", [Configured]),
    io:format("~s~n~n", [agreement(Smallest =:= Configured)]).

agreement(true) ->
    "AGREES. The configured value is the least generous one meeting the\n"
    "criterion, so the option exists and nothing more than that was given.";
agreement(false) ->
    "DISAGREES. The configured value was not derived from the criterion after\n"
    "all, and must be changed to the measured one. See PREREGISTRATION.md: a\n"
    "number may never be kept because of what evolves in it.".

first([]) -> none;
first([X | _]) -> X.

row(Cells) -> [pad(C) || C <- Cells].

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(C, 16, trailing).

yesno(true) -> "yes";
yesno(false) -> "no".
