#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc F.4: IS A RESOLVING SENSE FATAL, OR MERELY USELESS?
%%
%% Usage:  ./scripts/why_resolution_kills.escript [seeds [early [horizon]]]
%%
%% World 17 measured deaths rising monotonically with sense resolution: 80, 87,
%% 89, 91, 94, 94, 93 of 96 seeds across `sense_scale' 1 to 63. THAT IS A
%% CORRELATION AND THE MECHANISM IS A GUESS. The guess, written down as `F.4'
%% before this was run, is that a sense which resolves the ground lets creatures
%% FIND AND STRIP THE BEST CELLS FASTER, so a population grazes its own
%% neighbourhood flat, loses the world 14 subsidy that bare ground draws from its
%% neighbours, and starves.
%%
%% MEASURE THE PREMISE FIRST. This project has explained four nulls with a
%% mechanism and been wrong about three of them, and the one time a premise was
%% tested first it cost six minutes and killed a week of building. Nothing here
%% builds a world. It reads fields the snapshot already carries.
%%
%% If the guess is right, three things move TOGETHER as resolution rises:
%%
%%   STARVED%  the share of deaths that are starvation rather than age or being
%%             eaten. Overgrazing kills by starvation and by nothing else.
%%   GROUND    the standing stock of energy in the ground. Stripping it faster
%%             leaves less of it.
%%   MOVING    the share of creatures that moved this tick. Chasing better cells
%%             is movement; a blind creature has no reason to go anywhere.
%%
%% If the death rate rises and NONE of the three moves, the mechanism is
%% something else and `F.4' is refuted rather than merely unconfirmed.
%%
%% MEASURED EARLY AND AT A FIXED TICK, ACROSS EVERY SEED INCLUDING THE DOOMED.
%% Reading a state at the horizon would be a census of SURVIVORS, which is the
%% one population guaranteed not to have starved, and would answer the opposite
%% of the question asked. `I.2': a summary over the wrong set is the same fault
%% as a summary of the wrong shape.
-mode(compile).

-define(STEPS, [1, 2, 4, 8, 16, 32, 63]).

main(Args) ->
    Seeds = arg(Args, 1, 48),
    Early = arg(Args, 2, 500),
    Horizon = arg(Args, 3, 20000),
    io:format("~nseeds=~p. state read at tick ~p across EVERY seed; deaths "
              "counted to ~p.~n~n", [Seeds, Early, Horizon]),
    io:format("~s~n", [row(["scale", "dead", "STARVED%", "GROUND", "MOVING%",
                            "pop", "eaten%", "aged%", "born"])]),
    lists:foreach(fun(S) -> report(S, Seeds, Early, Horizon) end, ?STEPS),
    io:format("~nSTARVED%, eaten% and aged% are shares of all deaths so far at "
              "tick ~p.~nGROUND is standing stock, MOVING% is 100 minus the "
              "still share, and `dead'~nis how many of the ~p seeds are extinct "
              "by tick ~p. Every column but `dead'~nis measured at tick ~p over "
              "ALL seeds, the doomed included.~n",
              [Early, Seeds, Horizon, Early]).

arg(Args, N, _Default) when length(Args) >= N ->
    list_to_integer(lists:nth(N, Args));
arg(_Args, _N, Default) -> Default.

report(Scale, Seeds, Early, Horizon) ->
    Rows = in_parallel(fun(S) -> run(S, Scale, Early, Horizon) end,
                       lists:seq(1, Seeds)),
    Dead = length([x || #{dead := true} <- Rows]),
    Avg = fun(K) -> avg([maps:get(K, R) || R <- Rows]) end,
    io:format("~s~n", [row([Scale, Dead, Avg(starved_pct), Avg(ground),
                            Avg(moving_pct), Avg(pop), Avg(eaten_pct),
                            Avg(aged_pct), Avg(born)])]).

run(Seed, Scale, Early, Horizon) ->
    W0 = world:new(#{seed => Seed, population => 40,
                     transfer_efficiency => 100, sense_scale => Scale}),
    Snap = world:snapshot(advance(W0, Early)),
    #{starved := Starved, aged_out := Aged, consumed := Eaten} = Snap,
    Deaths = Starved + Aged + Eaten,
    #{starved_pct => pct(Starved, Deaths),
      eaten_pct => pct(Eaten, Deaths),
      aged_pct => pct(Aged, Deaths),
      ground => maps:get(ground_total, Snap),
      moving_pct => 100 - maps:get(still_pct, Snap),
      pop => maps:get(population, Snap),
      born => maps:get(born, Snap),
      dead => extinct(W0, Horizon)}.

%% A SEPARATE RUN TO THE HORIZON, not the same one continued, because the early
%% state has to be read at the same tick for every seed and the horizon is where
%% the death rate this exists to explain was measured.
extinct(W0, Horizon) -> world:population(advance(W0, Horizon)) =:= 0.

pct(_Part, 0) -> 0;
pct(Part, Whole) -> Part * 100 div Whole.

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(1000, Left),
    keep_going(world:population(W) > 0, world:tick(W, Step), Left - Step).

keep_going(false, W, _Left) -> W;
keep_going(true, W, Left) -> advance(W, Left).

avg([]) -> 0;
avg(L) -> lists:sum(L) div length(L).

in_parallel(F, Items) ->
    Parent = self(),
    Refs = [spawn_one(Parent, F, I) || I <- Items],
    [receive {Ref, R} -> R end || Ref <- Refs].

spawn_one(Parent, F, Item) ->
    Ref = make_ref(),
    spawn_link(fun() -> Parent ! {Ref, F(Item)} end),
    Ref.

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(C, 10, trailing).
