#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc World 7's experiment: every value of the efficiency, none of them chosen.
%%
%% THE SECOND LAW FIXES THE SIGN AND SAYS NOTHING ABOUT THE SIZE. Carnot bounds a
%% heat engine by its temperatures and this world has none, so there is no way to
%% derive the number. Inventing a criterion to manufacture one would be tuning
%% for outcome. Publishing all of them is the only honest treatment, and it is
%% the strongest defence against steering there is: a value cannot be picked for
%% the result it gives when every value is in the table.
%%
%% 100 IS THE CONTROL AND IS WORLD 6 EXACTLY, so the comparison lives inside the
%% experiment rather than across worlds.
%%
%% Seeds run in parallel. Each is a pure function of its number and shares no
%% state, so the rows are identical to running them one at a time.
-mode(compile).

-define(TICKS, 2000).
-define(SEEDS, 5).
-define(STEPS, [100, 95, 90, 80, 70, 60, 50, 40, 30, 20, 10]).

main(_) ->
    io:format("~nticks=~p seeds=~p~n~n", [?TICKS, ?SEEDS]),
    io:format("~s~n", [row(["eff%", "dead", "pop", "life", "gspr", "meat%",
                            "meat#", "store", "frame", "eats", "sens", "brain",
                            "burnt"])]),
    lists:foreach(fun report/1, ?STEPS),
    io:format("~ndead = seeds extinct of ~p. life = mean ticks alive, which was "
              "2.2 in world 6.~n", [?SEEDS]),
    io:format("gspr = ground energy in the richest tenth of cells, 10 is flat.~n"
              "burnt = energy dissipated, which at one temperature IS the "
              "entropy account.~n").

report(Eff) ->
    Rows = in_parallel(fun(Seed) -> run(Seed, Eff) end,
                       lists:seq(1, ?SEEDS)),
    Dead = length([R || #{population := 0} <- Rows, R <- [1]]),
    Alive = [R || #{population := P} = R <- Rows, P > 0],
    io:format("~s~n", [row([Eff, Dead | summarise(Alive)])]).

summarise([]) ->
    ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"];
summarise(Rows) ->
    Med = fun(K) -> median([maps:get(K, R) || R <- Rows]) end,
    [Med(population), Med(lifespan), Med(ground_spread),
     Med(from_creatures_pct), Med(fed_by_creatures), Med(energy_max),
     Med(structure_max), Med(uptake_mean), Med(sensors_held),
     Med(hidden_mean), Med(dissipated)].

%% `population => 40' MATCHES probe_economy.escript EXACTLY, and it has to. The
%% control at 100% is meant to BE world 6, and a first run of this sweep founded
%% the world differently, so two columns disagreed with world 6's published
%% numbers and the control compared against nothing.
run(Seed, Eff) ->
    W = world:tick(world:new(#{seed => Seed, population => 40,
                               transfer_efficiency => Eff}),
                   ?TICKS),
    S = world:snapshot(W),
    S#{lifespan => lifespan(S), sensors_held => held(S)}.

%% MEAN LIFESPAN, by Little's law: in a steady state the average time a creature
%% is alive is the standing population divided by the rate it is replaced. World
%% 6 came out at 2.2 ticks against a `max_age' of 600, which is the reason this
%% column exists at all: no apparatus priced per tick can repay over two of them.
%% REPORTED IN HUNDREDTHS, because whole ticks cannot tell 1.0 from 1.9 and the
%% whole question is whether this number moves off 2.2 at all.
lifespan(#{population := 0}) -> 0;
lifespan(#{population := Pop, starved := St, consumed := C, aged_out := A}) ->
    Deaths = St + C + A,
    scaled(Pop * ?TICKS * 100, Deaths).

scaled(_Num, 0) -> 0;
scaled(Num, Deaths) -> Num div Deaths.

held(#{sensors := Sensors}) ->
    lists:sum([maps:get(carriers, F, 0) || F <- maps:values(Sensors)]).

%%==============================================================================

in_parallel(F, Items) ->
    Parent = self(),
    Refs = [spawn_one(Parent, F, I) || I <- Items],
    [receive {Ref, Result} -> Result end || Ref <- Refs].

spawn_one(Parent, F, Item) ->
    Ref = make_ref(),
    spawn_link(fun() -> Parent ! {Ref, F(Item)} end),
    Ref.

median([]) -> 0;
median(L) -> lists:nth(length(L) div 2 + 1, lists:sort(L)).

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(C, 8, trailing).
