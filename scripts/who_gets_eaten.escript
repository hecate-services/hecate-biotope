#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc WHETHER WORLD 9'S PREDATION IS A NICHE OR IS INFANTICIDE.
%%
%% World 9 is the first world in this register where anything makes a living off
%% other creatures. `from_creatures_pct' is 26 to 31 and 6 to 14 individuals draw
%% more from creatures than from ground, against ZERO in every world since 4.
%%
%% THAT NUMBER HAS TWO READINGS AND THEY ARE DIFFERENT FINDINGS. World 9 also
%% made a parent keep its whole frame while the child is founded from the store,
%% so a newborn is the lightest thing on the board and loses every contest it
%% enters. That was declared in PREREGISTRATION.md before the run. If the eaten
%% are one tick old then the living being made is off newborns, and calling it a
%% predator niche would be the same mistake as world 6's bimodal histogram: a
%% shape read as a story.
%%
%% The mean age of the eaten separates them, against the population's own mean
%% lifespan as the yardstick. Prey older than the average creature cannot be
%% newborns.
-mode(compile).

-define(SEEDS, 5).
-define(TICKS, 2000).
-define(STEPS, [100, 95, 80]).

main(_) ->
    io:format("~nWHO GETS EATEN, ~p ticks, ~p seeds~n~n", [?TICKS, ?SEEDS]),
    io:format("~s~n", [row(["eff%", "seed", "pop", "meat%", "meat#", "eatenage",
                            "lifespan", "eaten", "born"])]),
    lists:foreach(fun report/1, ?STEPS),
    io:format("~neatenage = mean age of everything ever eaten, in hundredths of "
              "a tick.~nlifespan = mean ticks alive by Little's law, same units. "
              "A dash is an extinct seed.~n~nIF eatenage SITS AT ABOUT 100 THE "
              "PREY IS NEWBORNS. If it runs well above lifespan,~nsomething is "
              "hunting something that had a life.~n").

report(Eff) ->
    Rows = in_parallel(fun(Seed) -> run(Seed, Eff) end, lists:seq(1, ?SEEDS)),
    lists:foreach(fun({Seed, R}) ->
                          io:format("~s~n", [row([Eff, Seed | cells(R)])])
                  end,
                  lists:zip(lists:seq(1, ?SEEDS), Rows)).

cells(#{population := 0}) ->
    ['-', '-', '-', '-', '-', '-', '-'];
cells(#{population := P, from_creatures_pct := Pct, fed_by_creatures := N,
        eaten_age_mean := Age, consumed := Eaten, born := Born} = S) ->
    [P, Pct, N, Age, lifespan(S), Eaten, Born].

%% Deaths counted by conservation of individuals: everything founded or born is
%% either alive now or dead.
lifespan(#{population := Pop, born := Born}) ->
    scaled(Pop * ?TICKS * 100, Born + 40 - Pop).

scaled(_Num, 0) -> 0;
scaled(Num, Deaths) -> Num div Deaths.

run(Seed, Eff) ->
    world:snapshot(world:tick(world:new(#{seed => Seed, population => 40,
                                          transfer_efficiency => Eff}),
                              ?TICKS)).

%%==============================================================================

in_parallel(F, Items) ->
    Parent = self(),
    Refs = [spawn_one(Parent, F, I) || I <- Items],
    [receive {Ref, Result} -> Result end || Ref <- Refs].

spawn_one(Parent, F, Item) ->
    Ref = make_ref(),
    spawn_link(fun() -> Parent ! {Ref, F(Item)} end),
    Ref.

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) when is_atom(C) -> pad(atom_to_list(C));
pad(C) -> string:pad(C, 10, trailing).
