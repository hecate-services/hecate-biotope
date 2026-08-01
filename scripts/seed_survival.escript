#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc WHICH SEEDS SURVIVE, over a horizon the fleet actually reaches.
%%
%% beam03 went extinct at tick 630 on the world 9 rollout. That is not a fault:
%% RESULTS_WORLD9.md measured 3 seeds of 5 surviving at 100% efficiency, so about
%% two in five ending is the world working as measured. It is still a third of a
%% three-island fleet sitting dead on a public page, so beam03 gets a seed that
%% lives.
%%
%% THE CRITERION IS VIABILITY AND NOTHING ELSE, which is the one exception the
%% standing rule allows. No seed is chosen for the population it reaches, the
%% depth it gets to or how the chart looks. It is chosen for being alive, every
%% candidate is run, and the whole table is published so the choice can be
%% checked rather than trusted.
%%
%% THE HORIZON IS THE POINT OF RUNNING THIS AT ALL. Every world so far was scored
%% at 2000 ticks. The fleet runs at two ticks a second, so it passes 2000 in under
%% twenty minutes and reaches 170,000 in a day. Nothing has ever been measured out
%% there, and "survives 2000" is not the same claim as "survives a weekend".
-mode(compile).

-define(TICKS, 20000).
-define(FLEET, [101, 202, 303]).
-define(CANDIDATES, [304, 305, 306, 307, 308, 309, 310, 311, 312]).

main(_) ->
    io:format("~n~p ticks at 100% efficiency, which is ~p hours of fleet time.~n~n",
              [?TICKS, ?TICKS div 7200]),
    io:format("~s~n", [row(["seed", "alive", "dead@", "pop", "depth", "lines",
                            "meat%", "frame"])]),
    io:format("~s~n", [row(["-- the fleet today", "", "", "", "", "", "", ""])]),
    survey(?FLEET),
    io:format("~s~n", [row(["-- candidates", "", "", "", "", "", "", ""])]),
    survey(?CANDIDATES),
    io:format("~nalive = reached ~p ticks. dead@ = the tick it ended, - if it "
              "did not.~ndepth = generations in the deepest living line; 0 would "
              "mean nothing but founders.~n", [?TICKS]).

survey(Seeds) ->
    Rows = in_parallel(fun run/1, Seeds),
    lists:foreach(fun({Seed, R}) ->
                          io:format("~s~n", [row([Seed | cells(R)])])
                  end,
                  lists:zip(Seeds, Rows)).

cells(#{extinct_at := undefined, population := P, depth := D, lineages := L,
        from_creatures_pct := M, structure_max := F}) ->
    ["yes", "-", P, D, L, M, F];
cells(#{extinct_at := At}) ->
    ["no", At, 0, 0, 0, 0, 0].

run(Seed) ->
    world:snapshot(world:tick(world:new(#{seed => Seed, population => 40,
                                          transfer_efficiency => 100}),
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
pad(C) -> string:pad(C, 10, trailing).
