#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc THE H.10 GATE FOR R.5, ANSWERED BEFORE ANYTHING IS BUILT.
%%
%% Usage:  ./scripts/can_an_act_be_priced.escript [seeds [ticks]]
%%
%% `H.7' says outputs pay nothing: a creature carrying all four purposes pays
%% exactly what one carrying none pays, and it is the largest unpriced thing left
%% in this world. `R.5' proposes to charge them, by wiring, the way world 16
%% charged a hidden node.
%%
%% `R.1' made this arithmetic MANDATORY before the build, because world 15 priced
%% a mouth, ran forty-eight seeds to twenty thousand ticks, and measured drift:
%% each mutation moved the bill by 0.24% of income, below the level at which
%% selection beats drift. THE EXPERIMENT COULD NOT HAVE WORKED AND ONE LINE OF
%% ARITHMETIC WOULD HAVE SAID SO.
%%
%% So this measures, rather than assumes, the three numbers the gate needs:
%%
%%   INCOME    what a creature actually earns per tick
%%   STEP      what gaining or losing ONE output would change the bill by, at the
%%             bodies creatures actually carry
%%   SHARE     the step as a share of income, against a drift threshold of about
%%             1% at these population sizes
%%
%% An output is gained and lost WHOLE, by `brain:toggle/4', so this is the same
%% shape as a sensor, which world 13 moved with a price, and not the shape of a
%% mouth, which drifts in steps of 8 and did not.
-mode(compile).

main(Args) ->
    Seeds = arg(Args, 1, 24),
    Ticks = arg(Args, 2, 2000),
    Econ = world:defaults(),
    Neural = maps:get(neural_cost, Econ),
    Divisor = maps:get(upkeep_divisor, Econ),
    io:format("~n~p seeds settled ~p ticks. neural_cost ~p, upkeep_divisor ~p.~n"
              "A weight of neural tissue therefore costs ~p/~p = ~.2f a tick.~n~n",
              [Seeds, Ticks, Neural, Divisor, Neural, Divisor, Neural / Divisor]),
    io:format("~s~n", [row(["seed", "alive", "outputs", "sensors", "weights/out",
                            "STEP/tick", "income", "SHARE%"])]),
    Rows = [report(S, Ticks, Neural, Divisor) || S <- lists:seq(1, Seeds)],
    verdict([R || R <- Rows, R =/= dead]).

arg(Args, N, _Default) when length(Args) >= N ->
    list_to_integer(lists:nth(N, Args));
arg(_Args, _N, Default) -> Default.

report(Seed, Ticks, Neural, Divisor) ->
    W = advance(world:new(#{seed => Seed, population => 40,
                            transfer_efficiency => 100}), Ticks),
    scored(Seed, world:creatures(W), world:snapshot(W), Neural, Divisor).

scored(Seed, Cs, _Snap, _Neural, _Divisor) when map_size(Cs) =:= 0 ->
    io:format("~s~n", [row([Seed, "dead", "-", "-", "-", "-", "-", "-"])]),
    dead;
scored(Seed, Cs, Snap, Neural, Divisor) ->
    Creatures = maps:values(Cs),
    Outputs = mean([outputs_of(C) || C <- Creatures]),
    Sensors = mean([length(maps:get(body, C)) || C <- Creatures]),
    %% An output vector is one weight per input, which is `sensors + 1' because
    %% of `here', plus one per hidden node. `H.11': width is not a trait.
    PerOut = mean([weights_per_output(C) || C <- Creatures]),
    Step = PerOut * Neural / Divisor,
    Income = income(Snap, length(Creatures)),
    io:format("~s~n", [row([Seed, map_size(Cs), pct100(Outputs),
                            pct100(Sensors), pct100(PerOut),
                            round(Step), round(Income),
                            share(Step, Income)])]),
    #{step => Step, income => Income, share => Step / max(1, Income) * 100,
      %% THE OTHER END, which H.10 never wrote down. A price has a FLOOR, below
      %% which drift swamps it, and it has a CEILING: if carrying the organs a
      %% creature actually carries costs most of what it earns, the price is not
      %% a tradeoff to be selected within, it is a prohibition. World 15's mouth
      %% failed the floor. This is the first candidate that might fail the roof.
      full => Outputs * PerOut * Neural / Divisor / max(1, Income) * 100}.

%% WHAT A CREATURE EARNS, from the world's own books rather than from a guess.
%% `absorbed' is every unit that entered a creature since the world began, so
%% dividing by ticks and by the population alive gives a per-creature rate. The
%% last estimate of income in this project was out by a factor of ten, which is
%% what turned a fifty-percent selection differential on paper into four percent.
income(Snap, Alive) ->
    maps:get(absorbed, Snap) / max(1, maps:get(tick, Snap)) / max(1, Alive).

outputs_of(#{brain := #{outputs := Os}}) -> map_size(Os).

weights_per_output(#{brain := #{outputs := Os, hidden := H}, body := Body}) ->
    wpo(map_size(Os), length(Body) + 1 + length(H)).

wpo(0, _Width) -> 0;
wpo(_N, Width) -> Width.

verdict([]) ->
    io:format("~nEvery seed died. No gate answer.~n");
verdict(Rows) ->
    Share = mean([maps:get(share, R) || R <- Rows]),
    Step = mean([maps:get(step, R) || R <- Rows]),
    Full = mean([maps:get(full, R) || R <- Rows]),
    io:format("~nFLOOR: losing one output changes the bill by ~.2f a tick, which "
              "is ~.2f%~nof what a creature earns. Drift swamps anything under "
              "about 1%.~n", [Step, Share]),
    io:format("ROOF:  the outputs a creature ACTUALLY carries would cost ~.1f% "
              "of its income.~n~n~s~n", [Full, call(Share, Full)]).

call(Share, _Full) when Share < 1.0 ->
    "FAILS THE FLOOR. It would measure DRIFT, exactly as world 15 measured drift\n"
    "on the mouth. The price rises or R.5 is not built.";
call(_Share, Full) when Full >= 50.0 ->
    "FAILS THE ROOF, AND THIS IS A NEW KIND OF FAILURE.\n"
    "It clears the floor by a wide margin and then keeps going. A creature would\n"
    "spend most or all of what it earns on the outputs it already has, so the\n"
    "price does not create a tradeoff to be selected within: it BANS having them.\n"
    "That is not a measurement of whether acts are worth their cost, it is a\n"
    "world where nothing acts, and it would read as a dramatic result.\n"
    "R.5 IS BUILDABLE ONLY WITH THE RATE SWEPT, and neural_cost is the wrong\n"
    "rate to reuse. Nothing derives a price for an act, so it is swept, and the\n"
    "sweep must reach well below neural_cost rather than around it.";
call(_Share, _Full) ->
    "CLEARS BOTH. A price on outputs is something selection can see and something\n"
    "a creature can afford to be selected on.".

share(_Step, Income) when Income =< 0 -> 0;
share(Step, Income) -> round(Step / Income * 100).

pct100(V) -> round(V * 100).

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
pad(C) when is_float(C) -> pad(io_lib:format("~.1f", [C]));
pad(C) -> string:pad(C, 13, trailing).
