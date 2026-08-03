#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc HOW HIGH DOES `max_sensors' HAVE TO GO BEFORE IT STOPS DECIDING THINGS?
%%
%% Usage:  ./scripts/how_high_before_it_stops_binding.escript [seeds [ticks]]
%%
%% `are_the_caps_binding.escript' found 22% of the population sitting AT
%% `max_sensors' at 20,000 ticks, which means world 19's sensor column measured a
%% ceiling and not a response to price. This asks what the cap has to be for that
%% to stop being true.
%%
%% ══════════════════════════════════════════════════════════════════════
%% THE RULE, FIXED BEFORE THE NUMBERS ARE SEEN
%% ══════════════════════════════════════════════════════════════════════
%%
%%   **Take the SMALLEST cap at which fewer than 5% of the population sits at
%%   it.**
%%
%% Smallest, because the valve has a real job: `world.erl' calls these "safety
%% valves against a runaway genome making one tick cost as much as the whole
%% disc", and a cap set to infinity is not a braver experiment, it is an
%% unbounded one. So this reports WALL CLOCK per thousand ticks beside every
%% candidate, and a cap that triples the cost of running a world has stopped
%% being free even where it no longer binds.
%%
%% ⚠ THE RULE IS ABOUT CENSORING AND SAYS NOTHING ABOUT OUTCOME. It does not
%% prefer creatures with more sensors or fewer. It says only that a distribution
%% piled against its own edge cannot be read, which is true whichever direction
%% the pile would have gone. Choosing a cap by which one gave a nicer-looking
%% sensor mean would be tuning for outcome, and every number in this project
%% would be worth less for it.
%%
%% REACH IS CHECKED TOO, and has never been checked once. A sensor's price is its
%% reach plus one, so `max_sensor_range' is the other half of what a body costs
%% and the same argument applies to it. Nothing has ever reported whether it
%% binds.
-mode(compile).

%% The share at a ceiling above which a measurement is censored rather than
%% merely pressing. Stated here so it is one number in one place and cannot be
%% adjusted per run.
-define(CENSORED_PCT, 5).

main(Args) ->
    Seeds = arg(Args, 1, 16),
    Ticks = arg(Args, 2, 20000),
    Caps = [8, 12, 16, 24],
    io:format("~n~p seeds to ~p ticks at neural_cost 11.~nRule fixed in advance: "
              "take the SMALLEST cap leaving under ~p% of the population at it.~n~n",
              [Seeds, Ticks, ?CENSORED_PCT]),
    io:format("~s~n", [row(["max_sens", "sensors", "AT CAP", "reach", "REACH@4",
                            "pop", "dead", "ms/1000t"])]),
    Rows = [measure(Cap, Seeds, Ticks) || Cap <- Caps],
    verdict(Rows).

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.

measure(Cap, Seeds, Ticks) ->
    T0 = erlang:monotonic_time(millisecond),
    %% ⚠ IN PARALLEL, LIKE `sweep_neural' AND FOR THE SAME REASON. The first
    %% version of this ran its seeds one after another and would have taken an
    %% hour to answer a question the sweep it serves answers in minutes. Worlds
    %% are independent and pure; nothing about them needs a shared process.
    Runs = in_parallel(fun(S) -> run(S, Cap, Ticks) end, lists:seq(1, Seeds)),
    Elapsed = erlang:monotonic_time(millisecond) - T0,
    Live = lists:append([L || {alive, L} <- Runs]),
    Dead = length([x || dead <- Runs]),
    report(Cap, Live, Dead, Elapsed, Seeds, Ticks).

run(Seed, Cap, Ticks) ->
    W = advance(world:new(#{seed => Seed, population => 40, max_sensors => Cap}),
                Ticks),
    living(maps:values(world:creatures(W))).

living([]) -> dead;
living(Cs) -> {alive, Cs}.

report(Cap, [], Dead, Elapsed, Seeds, Ticks) ->
    Row = #{cap => Cap, at_cap => 0, mean => 0, reach_at => 0, pop => 0,
            dead => Dead, ms => per_thousand(Elapsed, Seeds, Ticks)},
    io:format("~s~n", [row([Cap, "-", "-", "-", "-", 0, Dead,
                            maps:get(ms, Row)])]),
    Row;
report(Cap, Live, Dead, Elapsed, Seeds, Ticks) ->
    N = length(Live),
    Counts = [length(maps:get(body, C)) || C <- Live],
    Reaches = lists:append([[R || {_F, R} <- maps:get(body, C)] || C <- Live]),
    AtCap = pct(length([V || V <- Counts, V >= Cap]), N),
    ReachAt = pct(length([R || R <- Reaches, R >= 4]), max(1, length(Reaches))),
    Ms = per_thousand(Elapsed, Seeds, Ticks),
    io:format("~s~n", [row([Cap, hundredths(mean(Counts)), [pc(AtCap)],
                            hundredths(mean(Reaches)), [pc(ReachAt)],
                            N div max(1, Seeds - Dead), Dead, Ms])]),
    #{cap => Cap, at_cap => AtCap, mean => mean(Counts), reach_at => ReachAt,
      pop => N, dead => Dead, ms => Ms}.

mean(Vs) -> lists:sum(Vs) * 100 div max(1, length(Vs)).

pct(Part, Whole) -> Part * 100 div max(1, Whole).

pc(N) -> integer_to_list(N) ++ "%".

per_thousand(Elapsed, Seeds, Ticks) ->
    Elapsed * 1000 div max(1, Seeds * Ticks).

%% THE RULE APPLIED, MECHANICALLY, so the choice is the rule's and not mine.
verdict(Rows) ->
    Clear = [R || R <- Rows, maps:get(at_cap, R) < ?CENSORED_PCT],
    io:format("~n"),
    announce(Clear, Rows).

announce([], Rows) ->
    io:format("NO CAP TESTED CLEARS THE RULE. The largest, ~p, still holds ~p% of~n"
              "the population at it, so a body is bounded by the valve and not by~n"
              "rent at every value tried. That is a finding about the economy~n"
              "rather than about the valve: sensors are worth carrying faster than~n"
              "they cost, and the interesting question is why.~n",
              [maps:get(cap, lists:last(Rows)), maps:get(at_cap, lists:last(Rows))]);
announce([Chosen | _Rest], Rows) ->
    Base = hd(Rows),
    io:format("TAKE max_sensors = ~p. It is the smallest tested leaving under ~p%~n"
              "at the ceiling (~p%), against ~p% at the current ~p.~n~n",
              [maps:get(cap, Chosen), ?CENSORED_PCT, maps:get(at_cap, Chosen),
               maps:get(at_cap, Base), maps:get(cap, Base)]),
    io:format("Cost of the change: ~p ms per thousand ticks against ~p at the~n"
              "current cap. The valve exists to stop one tick costing as much as~n"
              "the whole disc, so this is the number that says whether it still~n"
              "does its job.~n",
              [maps:get(ms, Chosen), maps:get(ms, Base)]),
    reach_note(maps:get(reach_at, Chosen)).

reach_note(Pct) when Pct >= ?CENSORED_PCT ->
    io:format("~n⚠ AND REACH IS BINDING TOO: ~p% of all sensors carried sit at~n"
              "`max_sensor_range' 4. A sensor's price is its reach plus one, so~n"
              "this is the other half of what a body costs and it has never been~n"
              "checked. Raising one cap and not the other measures a body that is~n"
              "free to grow in count and pinned in reach.~n", [Pct]);
reach_note(Pct) ->
    io:format("~nReach is clear of its own cap at ~p%, so `max_sensor_range' 4 is~n"
              "not deciding anything and only `max_sensors' needs to move.~n", [Pct]).

in_parallel(F, Items) ->
    Parent = self(),
    Refs = [spawn_one(Parent, F, I) || I <- Items],
    [receive {Ref, Result} -> Result end || Ref <- Refs].

spawn_one(Parent, F, Item) ->
    Ref = make_ref(),
    spawn_link(fun() -> Parent ! {Ref, F(Item)} end),
    Ref.

%% ⚠ WALL CLOCK MEANS SOMETHING DIFFERENT NOW AND THE COLUMN SAYS SO. With the
%% seeds running at once this is elapsed time over total world-ticks across all
%% of them, so it measures THROUGHPUT on this machine and not the cost of one
%% tick. It is still the right comparison between caps, because every cap is
%% measured the same way, and it is no longer a number anyone should read as "a
%% tick costs this much".
advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(1000, Left),
    going(world:population(W) > 0, world:tick(W, Step), Left - Step).

going(false, W, _Left) -> W;
going(true, W, Left) -> advance(W, Left).

hundredths(V) -> io_lib:format("~w.~2..0w", [V div 100, V rem 100]).

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).
pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(lists:flatten(C), 10, trailing).
