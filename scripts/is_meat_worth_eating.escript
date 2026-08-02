#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc IS THE ARITHMETIC NUDGING TOWARD STARVATION OVER PREDATION?
%%
%% Usage:  ./scripts/is_meat_worth_eating.escript [seeds [ticks]]
%%
%% On the live fleet: 145 to 510 creatures eaten, meat contributing 0 to 2% of
%% what the living have eaten, and **97% of everything ever born starved**. Raf's
%% question: is something in the rules making a living off meat structurally
%% worse than starving, rather than creatures simply choosing not to?
%%
%% FOUR CANDIDATE ASYMMETRIES, ALL IN THE RULES, none of them measured:
%%
%%   THE BITE BOUND    `Eaten = min(Carcass, Mouth, Want, Body)'. The mouth caps
%%                     a bite. Grazing is capped by `uptake' instead. If the two
%%                     caps differ, one meal is structurally smaller than the
%%                     other and no behaviour is involved.
%%   THE SHARED CAP    `B.8': feeding is bounded ONCE, counting meat and ground
%%                     TOGETHER. A creature already full from the ground gains
%%                     nothing from a kill, so the value of meat depends on how
%%                     much room the ground left.
%%   THE MOUTH DRIFTS  `H.10': a mouth mutation moves the bill by 0.24% of
%%                     income, far under the ~1% drift threshold, so mouth size
%%                     is a random walk and whatever it bounds walks with it.
%%   THE ENCOUNTER     you must share a cell with something weaker.
%%                     `how_often_do_they_meet.escript' measures that one and
%%                     this does not.
%%
%% ⚠ EVERY SEED IS REPORTED, ALIVE OR DEAD, AND THE FIRST VERSION OF THIS FILE
%% DROPPED THE DEAD ONES. That is `I.2' exactly, and there is a comment warning
%% against it in `why_resolution_kills.escript' written the same afternoon: a
%% census of survivors is the one population guaranteed not to have starved, and
%% this asks about starvation. All eight seeds died on the first run and the
%% script printed nothing at all, which is the honest version of the failure.
%%
%% ⚠ LIFETIME FLOWS, NOT A CENSUS OF SURVIVORS. `from_ground' and
%% `from_creatures' die with their owner, which is why the fleet reads 0% meat
%% while 510 creatures have been eaten. Walking tick by tick and summing the
%% per-creature DELTAS counts what the dead ate too, which is the only way to ask
%% where a world's energy actually came from.
-mode(compile).

main(Args) ->
    Seeds = arg(Args, 1, 8),
    Ticks = arg(Args, 2, 2000),
    io:format("~n~p seeds, ~p ticks, lifetime flows including the dead.~n~n",
              [Seeds, Ticks]),
    io:format("~s~n", [row(["seed", "alive", "GROUND", "MEAT", "meat/1000",
                            "uptake", "mouth", "graze:bite", "starved", "eaten"])]),
    verdict([look(S, Ticks) || S <- lists:seq(1, Seeds)]).

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.

look(Seed, Ticks) ->
    W0 = world:new(#{seed => Seed, population => 40,
                     transfer_efficiency => 100}),
    {W, Flows, Caps} = walk(W0, Ticks, seen(W0, #{}), caps(W0, none)),
    tally(Seed, W, Flows, Caps).

tally(Seed, W, Flows, {Uptake, Mouth}) ->
    Snap = world:snapshot(W),
    Ground = lists:sum([G || {G, _M} <- maps:values(Flows)]),
    Meat = lists:sum([M || {_G, M} <- maps:values(Flows)]),
    Alive = world:population(W),
    io:format("~s~n", [row([Seed, alive_or_dead(Alive, Snap), Ground, Meat,
                            per(Ground + Meat, Meat, 1000),
                            round(Uptake), round(Mouth),
                            ratio(Uptake, Mouth),
                            maps:get(starved, Snap),
                            maps:get(consumed, Snap)])]),
    #{ground => Ground, meat => Meat, uptake => Uptake, mouth => Mouth,
      starved => maps:get(starved, Snap), consumed => maps:get(consumed, Snap)}.

alive_or_dead(0, Snap) -> "d@" ++ integer_to_list(maps:get(extinct_at, Snap));
alive_or_dead(N, _Snap) -> N.

%% The caps as they last STOOD, taken from the final tick that had anybody on it.
%% A dead world has no creatures to average, and its caps are exactly what the
%% question is about.
caps(W, Was) -> held(world:population(W) > 0, W, Was).

held(false, _W, none) -> {0.0, 0.0};
held(false, _W, Was) -> Was;
held(true, W, _Was) ->
    Vals = maps:values(world:creatures(W)),
    {mean([maps:get(uptake, C) || C <- Vals]),
     mean([maps:get(mouth, C) || C <- Vals])}.

verdict([]) -> io:format("~nEvery seed died.~n");
verdict(Rows) ->
    G = lists:sum([maps:get(ground, R) || R <- Rows]),
    M = lists:sum([maps:get(meat, R) || R <- Rows]),
    Uptake = mean([maps:get(uptake, R) || R <- Rows]),
    Mouth = mean([maps:get(mouth, R) || R <- Rows]),
    io:format("~nOF EVERY UNIT THAT EVER ENTERED A CREATURE, INCLUDING THE DEAD:~n"
              "  ground ~p, meat ~p, so meat is ~.2f%% of all energy taken.~n~n"
              "THE TWO CAPS, which is the arithmetic Raf asked about:~n"
              "  a graze is bounded by uptake, mean ~w~n"
              "  a bite  is bounded by the mouth, mean ~w~n"
              "  so one meal is ~.1fx the other.~n~n~s~n",
              [G, M, M * 100 / max(1, G + M), round(Uptake), round(Mouth),
               Uptake / max(1.0, Mouth), call(Uptake / max(1.0, Mouth))]).

call(Ratio) when Ratio >= 2.0 ->
    "STRUCTURALLY, YES: A BITE IS A FRACTION OF A GRAZE.\n"
    "The two feeding routes are bounded by different traits and the bounds are\n"
    "not comparable. Nothing chose that. `uptake' and `mouth' both drift, both\n"
    "sit under the H.10 threshold, and there is no rule anywhere saying the two\n"
    "caps should be of a similar size. A creature that eats another gets a\n"
    "smaller meal than one that grazes, for reasons that live in the difference\n"
    "between two expressions rather than in any statement about predation.";
call(Ratio) when Ratio =< 0.5 ->
    "REVERSED: a bite is LARGER than a graze, so the caps are not what is\n"
    "suppressing predation and the encounter rate or the shared cap must be.";
call(_Ratio) ->
    "The two caps are comparable, so the bounds are NOT what suppresses meat and\n"
    "the encounter rate or B.8's shared cap must be. Measure those next.".

%% Per creature and per tick, so a creature that dies still counts what it ate.
walk(W, 0, Flows, Caps) -> {W, Flows, Caps};
walk(W, Left, Flows, Caps) ->
    W1 = world:tick(W, 1),
    keep(world:population(W1) > 0, W1, Left - 1, seen(W1, Flows),
         caps(W1, Caps)).

keep(false, W, _Left, Flows, Caps) -> {W, Flows, Caps};
keep(true, W, Left, Flows, Caps) -> walk(W, Left, Flows, Caps).

%% The MAXIMUM each id has ever reported, which is its lifetime total, because
%% both counters only ever climb while a creature lives.
seen(W, Flows) ->
    maps:fold(fun(Id, #{from_ground := G, from_creatures := M}, Acc) ->
                      maps:put(Id, {G, M}, Acc)
              end, Flows, world:creatures(W)).

per(0, _Part, _Scale) -> 0;
per(Total, Part, Scale) -> Part * Scale div Total.

ratio(_U, M) when M =< 0 -> "inf";
ratio(U, M) -> io_lib:format("~.1f", [U / M]).

mean([]) -> 0.0;
mean(L) -> lists:sum(L) / length(L).

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) when is_float(C) -> pad(io_lib:format("~.1f", [C]));
pad(C) -> string:pad(C, 11, trailing).
