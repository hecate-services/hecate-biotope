#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% Watch the energy economy over time, across several seeds.
%%
%% THIS IS THE INSTRUMENT FOR TUNING THE FOUR NUMBERS, and it exists because
%% "the population survived 500 ticks" is a test and not an answer. A run can
%% survive by sitting at the creature cap, by oscillating violently, or by
%% drifting slowly to nothing, and those want three different responses.
%%
%% Several seeds because one run of a stochastic world tells you about that run.
%% If the seeds disagree about whether anything lives, the economy is on a knife
%% edge and any later result measured in it would be measuring the knife.
%%
%%   scripts/probe_economy.escript                 # defaults, 5 seeds, 2000 ticks
%%   scripts/probe_economy.escript 3000 8          # ticks, seeds
%%   scripts/probe_economy.escript 3000 8 metabolism=2 regrowth_per_tick=6
%%
%% Overrides are `key=integer' and are applied to the economy verbatim, so a
%% typo names a key the world does not have rather than silently doing nothing.

main(Args) ->
    {Ticks, Seeds, Overrides} = parse(Args),
    Econ = maps:merge(world:defaults(), Overrides),
    ok = check_keys(Overrides),
    io:format("~nticks=~p seeds=~p~n", [Ticks, Seeds]),
    io:format("economy: ~p~n~n", [maps:with(maps:keys(Overrides), Econ)]),
    Rows = [run(Seed, Ticks, Overrides) || Seed <- lists:seq(1, Seeds)],
    report(Rows, Ticks).

parse([]) -> {2000, 5, #{}};
parse([T]) -> {list_to_integer(T), 5, #{}};
parse([T, S | Rest]) ->
    {list_to_integer(T), list_to_integer(S), overrides(Rest, #{})}.

overrides([], Acc) -> Acc;
overrides([KV | Rest], Acc) ->
    [K, V] = string:split(KV, "="),
    overrides(Rest, Acc#{list_to_atom(K) => list_to_integer(V)}).

%% A key the economy does not have is a typo, and a typo that silently does
%% nothing turns a tuning session into a ghost hunt.
check_keys(Overrides) ->
    Known = maps:keys(world:defaults()),
    case maps:keys(Overrides) -- Known of
        []      -> ok;
        Unknown -> io:format("unknown economy keys: ~p~nknown: ~p~n",
                             [Unknown, lists:sort(Known)]),
                   halt(64)
    end.

%% Sample the trajectory rather than only its end, because a population that
%% ends at 40 having peaked at 900 is not the same animal as one that sat at 40.
run(Seed, Ticks, Overrides) ->
    W0 = world:new(Overrides#{seed => Seed, population => 40}),
    Every = max(1, Ticks div 20),
    {WN, Samples} = sample(W0, Ticks, Every, []),
    Pops = [P || #{population := P} <- Samples],
    #{seed => Seed,
      final => world:snapshot(WN),
      peak => lists:max(Pops),
      trough => lists:min(Pops),
      samples => Samples}.

sample(W, 0, _Every, Acc) -> {W, lists:reverse([world:snapshot(W) | Acc])};
sample(W, Left, Every, Acc) ->
    Step = min(Every, Left),
    sample(world:tick(W, Step), Left - Step, Every,
           [world:snapshot(W) | Acc]).

report(Rows, Ticks) ->
    io:format("~s~n", [row(["seed", "final", "peak", "trough", "plants",
                            "born", "starved", "aged"])]),
    lists:foreach(fun print_row/1, Rows),
    Finals = [P || #{final := #{population := P}} <- Rows],
    Extinct = length([P || P <- Finals, P =:= 0]),
    io:format("~n~p/~p seeds extinct after ~p ticks~n",
              [Extinct, length(Rows), Ticks]),
    io:format("final population: min ~p median ~p max ~p~n",
              [lists:min(Finals), median(Finals), lists:max(Finals)]),
    trajectory(hd(Rows)).

print_row(#{seed := S, peak := Pk, trough := Tr,
            final := #{population := P, plants := Pl, born := B,
                       starved := St, aged_out := Ag}}) ->
    io:format("~s~n", [row([S, P, Pk, Tr, Pl, B, St, Ag])]).

%% Columns padded by hand. A negative field width on ~p is not accepted, and the
%% failure is a bare "failed to format string" that names no column.
row(Cells) -> [pad(C) || C <- Cells].

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(C, 9, trailing).

%% One seed's shape in full, because the summary above can hide an oscillation.
trajectory(#{seed := S, samples := Samples}) ->
    io:format("~nseed ~p trajectory (tick: population/plants)~n", [S]),
    Line = [io_lib:format("~p:~p/~p  ", [T, P, Pl])
            || #{tick := T, population := P, plants := Pl} <- Samples],
    io:format("~s~n", [Line]).

median(L) ->
    Sorted = lists:sort(L),
    lists:nth(max(1, length(Sorted) div 2), Sorted).
