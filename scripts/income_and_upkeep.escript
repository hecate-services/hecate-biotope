#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc WHAT A CREATURE CAN EARN AGAINST WHAT IT MUST PAY, measured.
%%
%% The claim under test was arrived at by subtraction on paper and it was wrong
%% once already. The first pass used 12 a cell a tick, which is the realised
%% average in a populated world, where the number that governs whether a creature
%% can pay for itself is the MOST a cell yields without being stripped, and
%% `ground:sustainable/1' has computed that all along.
%%
%% So this measures rather than derives, and it measures three things.
%%
%% ONE CELL'S LEDGER. What a cell yields at its best, which bounds the income of
%% anything that stays put and feeds gently.
%%
%% WHAT A BODY COSTS, by putting ONE creature alone in the world at a range of
%% sizes and seeing which sizes last. Alone removes the two things that confound
%% this in a populated world: nobody eats it, and nobody dies nearby to enrich the
%% ground it stands on. If a size cannot pay for itself against untouched ground
%% with no competition, it cannot pay for itself anywhere.
%%
%% WHAT THE APPARATUS COSTS, by running the same ladder with founders that carry
%% no hidden nodes. The difference between the two tables is the price of
%% thinking, and the question underneath five worlds of zero perception is whether
%% any body size can afford it.
%%
%% Efficiency is 100 throughout, so nothing here is a loss to a lossy transfer and
%% every shortfall is a real one.
-mode(compile).

-define(SEEDS, 5).
-define(TICKS, 300).
-define(LADDER, [22, 44, 100, 132, 200, 400, 800, 1600]).
-define(WINDOW, 100).

main(_) ->
    cell_ledger(),
    solo(default, #{}),
    solo(bare, #{founder_max_hidden => 0}),
    flow().

%%==============================================================================
%% What one cell pays
%%==============================================================================

cell_ledger() ->
    Econ = world:defaults(),
    Sustainable = ground:sustainable(Econ),
    io:format("~nONE CELL~n~n"),
    io:format("  ceiling                ~p~n", [maps:get(ground_ceiling, Econ)]),
    io:format("  floor added when bare  ~p~n", [best_floor(Econ)]),
    io:format("  MOST IT YIELDS A TICK  ~p   <- the ceiling on sessile income~n",
              [Sustainable]),
    io:format("~n  against that, per tick:~n"),
    io:format("    existing             ~p~n", [maps:get(metabolism, Econ)]),
    io:format("    one step             ~p~n", [maps:get(move_cost, Econ)]),
    io:format("    one hidden node      ~p~n", [maps:get(hidden_rent, Econ)]),
    io:format("    one sensor           ~p~n", [maps:get(sensor_rent, Econ)]),
    io:format("    carrying a frame     frame / ~p~n",
              [maps:get(upkeep_divisor, Econ)]),
    io:format("~n  A FOUNDER IS BORN WITH A FRAME OF ~p.~n",
              [maps:get(start_energy, Econ) - maps:get(start_energy, Econ) div 2]).

%%==============================================================================
%% One creature, alone, at a range of sizes
%%==============================================================================

solo(Label, Extra) ->
    io:format("~n~nALONE FOR ~p TICKS (~p founders): nobody eats it and nothing "
              "dies near it.~n~n", [?TICKS, Label]),
    io:format("~s~n", [row(["start", "frame", "lived", "alive", "endframe",
                            "endpop"])]),
    lists:foreach(fun(S) -> solo_row(S, Extra) end, ?LADDER),
    io:format("~nlived = median ticks before the founder's line ended, ~p means "
              "it never did.~nendframe = median largest frame at the end. endpop "
              "= median population at the end.~n", [?TICKS]).

solo_row(Start, Extra) ->
    Rows = in_parallel(fun(Seed) -> alone(Seed, Start, Extra) end,
                       lists:seq(1, ?SEEDS)),
    Lived = [L || #{lived := L} <- Rows],
    io:format("~s~n", [row([Start, Start - Start div 2,
                            median(Lived),
                            length([L || L <- Lived, L =:= ?TICKS]),
                            median([F || #{frame := F} <- Rows]),
                            median([P || #{pop := P} <- Rows])])]).

alone(Seed, Start, Extra) ->
    W0 = world:new(maps:merge(#{seed => Seed, population => 1,
                                start_energy => Start,
                                transfer_efficiency => 100}, Extra)),
    live(W0, ?TICKS, 0).

live(W, 0, Lived) -> ended(W, Lived);
live(W, N, Lived) ->
    case world:population(W) of
        0 -> ended(W, Lived);
        _ -> live(world:tick(W), N - 1, Lived + 1)
    end.

ended(W, Lived) ->
    #{structure_max := F, population := P} = world:snapshot(W),
    #{lived => Lived, frame => F, pop => P}.

%%==============================================================================
%% The standing population's books, per creature per tick
%%==============================================================================

%% AT 100% NOTHING IS LOST IN TRANSIT, so every unit dissipated was spent on
%% living: upkeep paid, plus what decays out of a corpse. Setting income beside it
%% says whether the standing population is paying its way out of the ground or
%% out of its own dead.
flow() ->
    io:format("~n~nTHE POPULATION'S BOOKS, per creature per tick, over ticks ~p "
              "to ~p at 100%.~n~n", [?WINDOW, ?WINDOW * 2]),
    Rows = in_parallel(fun books/1, lists:seq(1, ?SEEDS)),
    io:format("~s~n", [row(["seed", "pop", "ground", "spent", "meat%"])]),
    lists:foreach(fun({Seed, #{pop := P, ground := G, spent := S, meat := M}}) ->
                          io:format("~s~n", [row([Seed, P, G, S, M])])
                  end,
                  lists:zip(lists:seq(1, ?SEEDS), Rows)),
    io:format("~nground and spent are in HUNDREDTHS of a unit per creature per "
              "tick. ground = drawn from~nthe soil. spent = dissipated, which at "
              "100% is upkeep paid plus what decays out of~ncorpses, so it is an "
              "upper bound on upkeep rather than upkeep itself. meat% = the "
              "share~nof the living population's intake that came from other "
              "creatures.~n").

books(Seed) ->
    W0 = world:tick(world:new(#{seed => Seed, population => 40,
                                transfer_efficiency => 100}), ?WINDOW),
    Before = world:snapshot(W0),
    {W1, TickPops} = run_window(W0, ?WINDOW, []),
    #{from_creatures_pct := Meat} = After = world:snapshot(W1),
    Creature_ticks = lists:sum(TickPops),
    #{pop => median(TickPops),
      ground => per(delta(absorbed, Before, After), Creature_ticks),
      spent => per(delta(dissipated, Before, After), Creature_ticks),
      meat => Meat}.

run_window(W, 0, Pops) -> {W, lists:reverse(Pops)};
run_window(W, N, Pops) ->
    run_window(world:tick(W), N - 1, [world:population(W) | Pops]).

delta(Key, Before, After) -> maps:get(Key, After, 0) - maps:get(Key, Before, 0).

per(_Amount, 0) -> 0;
per(Amount, Creature_ticks) -> Amount * 100 div Creature_ticks.

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
pad(C) -> string:pad(C, 10, trailing).
