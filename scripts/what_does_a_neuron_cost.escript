#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc WHAT ONE NEURON COSTS, AS A SHARE OF WHAT A CREATURE EARNS.
%%
%% Usage:  ./scripts/what_does_a_neuron_cost.escript [seeds [ticks]]
%%
%% `H.10' asks whether a mutation is big enough for selection to SEE. This asks
%% the opposite question about the same organ: whether it is small enough for a
%% creature to AFFORD. World 18 added that roof to the gate after a price cleared
%% the floor twenty-eight times over and then cost 94.7% of income.
%%
%% Nobody has ever pointed it at the hidden node, which is the organ eighteen
%% worlds have been asking about.
%%
%% MARGINAL COSTS, NOT THE WHOLE BILL, and that is deliberate rather than lazy.
%% Reproducing `world:tissue/2' here would be a second copy of a rule, which is
%% `I.6' and is how an instrument comes to disagree with the thing it measures.
%% What the gate needs is what ONE MORE of something costs, and that is a
%% multiplication this script can do without knowing the rest of the bill:
%%
%%   a hidden node   `sensors + 1' weights, because `brain:width/2' says a row is
%%                   one weight per input and `H.11' says that width is the body
%%                   reported back rather than a trait
%%   a sensor        `1 + reach' units of body, from `body:mass/1'
%%
%% both at `neural_cost' per unit over `upkeep_divisor' ticks.
-mode(compile).

main(Args) ->
    Seeds = arg(Args, 1, 24),
    Ticks = arg(Args, 2, 2000),
    Econ = world:defaults(),
    Neural = maps:get(neural_cost, Econ),
    Divisor = maps:get(upkeep_divisor, Econ),
    io:format("~n~p seeds settled ~p ticks. neural_cost ~p over a divisor of "
              "~p,~nso one unit of neural tissue costs ~.2f a tick.~n~n",
              [Seeds, Ticks, Neural, Divisor, Neural / Divisor]),
    io:format("~s~n", [row(["seed", "alive", "income", "SENSOR", "as %",
                            "NEURON", "as %", "sensors", "nodes"])]),
    Rows = [R || R <- [look(S, Ticks, Neural, Divisor)
                       || S <- lists:seq(1, Seeds)], R =/= dead],
    verdict(Rows).

arg(Args, N, _Default) when length(Args) >= N ->
    list_to_integer(lists:nth(N, Args));
arg(_Args, _N, Default) -> Default.

look(Seed, Ticks, Neural, Divisor) ->
    W = advance(world:new(#{seed => Seed, population => 40,
                            transfer_efficiency => 100}), Ticks),
    scored(Seed, world:creatures(W), world:snapshot(W), Neural, Divisor).

scored(Seed, Cs, _Snap, _N, _D) when map_size(Cs) =:= 0 ->
    io:format("~s~n", [row([Seed, "dead", "-", "-", "-", "-", "-", "-", "-"])]),
    dead;
scored(Seed, Cs, Snap, Neural, Divisor) ->
    Vals = maps:values(Cs),
    Income = income(Snap, length(Vals)),
    %% One MORE hidden node, at the bodies these creatures actually carry.
    Node = mean([(length(maps:get(body, C)) + 1) || C <- Vals])
        * Neural / Divisor,
    %% One MORE sensor, at reach 0, which is what the fleet carries almost
    %% exclusively and is therefore the cheapest a sensor can be.
    Sensor = 1 * Neural / Divisor,
    io:format("~s~n", [row([Seed, map_size(Cs), round(Income),
                            round(Sensor), pct(Sensor, Income),
                            round(Node), pct(Node, Income),
                            hundredths(maps:get(sensor_mean, Snap)),
                            hundredths(maps:get(hidden_mean, Snap))])]),
    #{income => Income, node => Node, sensor => Sensor}.

%% From the world's own books rather than from a guess. The last estimate of
%% income in this project was out by a factor of ten, which turned a fifty
%% percent selection differential on paper into four percent in fact.
income(Snap, Alive) ->
    maps:get(absorbed, Snap) / max(1, maps:get(tick, Snap)) / max(1, Alive).

verdict([]) -> io:format("~nEvery seed died. No answer.~n");
verdict(Rows) ->
    Node = mean([maps:get(node, R) || R <- Rows]),
    Sensor = mean([maps:get(sensor, R) || R <- Rows]),
    Income = mean([maps:get(income, R) || R <- Rows]),
    io:format("~nONE SENSOR costs ~.1f a tick, which is ~.1f%% of income.~n"
              "ONE HIDDEN NODE costs ~.1f a tick, which is ~.1f%% of income, "
              "and ~.1f sensors.~n~n~s~n",
              [Sensor, Sensor / Income * 100, Node, Node / Income * 100,
               Node / Sensor, call(Node / Income * 100)]).

call(Share) when Share >= 25.0 ->
    "A SINGLE NEURON COSTS A QUARTER OF EVERYTHING A CREATURE EARNS OR MORE.\n"
    "World 13 settled a twelve-world null by finding that perception was not\n"
    "useless but UNAFFORDABLE, at one sensor for ten a tick against a cell\n"
    "yielding twenty-two. This is the same finding one organ further in, and it\n"
    "is not a question about what a brain is worth: nothing can buy one to find\n"
    "out.";
call(Share) when Share >= 10.0 ->
    "A neuron costs a tenth of income or more, which is the range in which world\n"
    "13 found sensors were being selected away for price rather than for use.";
call(_Share) ->
    "A neuron is affordable at this price, so its absence is about what it is\n"
    "worth rather than what it costs.".

pct(_Part, Income) when Income =< 0 -> 0;
pct(Part, Income) -> round(Part / Income * 100).

hundredths(V) -> V / 100.

mean([]) -> 0;
mean(L) -> lists:sum(L) / length(L).

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(1000, Left),
    keep_going(world:population(W) > 0, world:tick(W, Step), Left - Step).

keep_going(false, W, _Left) -> W;
keep_going(true, W, Left) -> advance(W, Left).

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) when is_float(C) -> pad(io_lib:format("~.2f", [C]));
pad(C) -> string:pad(C, 10, trailing).
