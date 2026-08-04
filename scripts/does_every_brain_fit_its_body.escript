#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% THE INVARIANT `brain:fire/3' ASSUMES AND NOTHING CHECKS.
%%
%% `dot/2' zips a weight row against a value list, so an output's `inputs' row
%% must be exactly as wide as the input vector, which is ONE PER SENSOR PLUS
%% `here' -- see `world:inputs/5', where `here' is an ordinary input and not a
%% special case. Its `hidden' row must be exactly as long as the brain has nodes,
%% and a hidden row is `sensors + 1 + nodes' wide because it also reads the
%% previous tick's activations, which is world 21. A mismatch would crash inside
%% `lists:zip/3'.
%%
%% ⚠ THIS WAS WRITTEN TO CHASE A BUG THAT DOES NOT EXIST, and it is kept because
%% it is the evidence of that. CI reported `*timed out*' and then printed the
%% stack the process happened to be executing when eunit killed it: `brain:dot/2'
%% on one run and `hex:neighbours/1' on the next. I read the first as a crash and
%% went looking for a width bug. **The fault was eunit's five-second default
%% against a test that ticks a live world**, and the elapsed time was exactly
%% 5.000 seconds every time.
%%
%% 120 seeds x 800 ticks find no violation. That is the ANSWER, not a failure to
%% reproduce. A timeout's stack names WHERE, never WHY. `I.20'.
-mode(compile).

main(Args) ->
    Seeds = arg(Args, 1, 40),
    Ticks = arg(Args, 2, 800),
    io:format("~nOTP ~s. ~p seeds x ~p ticks, checking every brain every tick.~n~n",
              [erlang:system_info(otp_release), Seeds, Ticks]),
    Bad = lists:append([check(S, Ticks) || S <- lists:seq(1, Seeds)]),
    report(Bad).

report([]) ->
    io:format("No mismatch found.~n");
report(Bad) ->
    io:format("~p MISMATCHES. First few:~n", [length(Bad)]),
    [io:format("  ~p~n", [B]) || B <- lists:sublist(Bad, 5)].

check(Seed, Ticks) ->
    walk(world:new(#{seed => Seed, population => 40}), Ticks, Seed, []).

walk(_W, 0, _Seed, Acc) -> Acc;
walk(W, Left, Seed, Acc) ->
    Bad = [B || C <- maps:values(world:creatures(W)),
                B <- widths(C, Seed, world:snapshot(W))],
    keep_going(world:population(W), world:tick(W), Left, Seed, Acc ++ Bad).

keep_going(0, _W, _Left, _Seed, Acc) -> Acc;
keep_going(_P, W, Left, Seed, Acc) -> walk(W, Left - 1, Seed, Acc).

widths(#{body := Body, brain := #{hidden := Hidden, outputs := Outs}}, Seed,
       #{tick := Tick}) ->
    Sensors = length(Body),
    Nodes = length(Hidden),
    lists:append(
      [[{Seed, Tick, output_inputs, length(WI), expected, Sensors + 1}
        || #{inputs := WI} <- maps:values(Outs), length(WI) =/= Sensors + 1],
       [{Seed, Tick, output_hidden, length(WH), expected, Nodes}
        || #{hidden := WH} <- maps:values(Outs), length(WH) =/= Nodes],
       [{Seed, Tick, hidden_row, length(Row), expected, Sensors + 1 + Nodes}
        || Row <- Hidden, length(Row) =/= Sensors + 1 + Nodes]]).

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.
