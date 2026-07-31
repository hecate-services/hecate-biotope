#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% Watch the energy economy over time, across several seeds.
%%
%% THIS IS THE INSTRUMENT FOR TUNING THE ECONOMY, and it exists because "the
%% population survived 500 ticks" is a test and not an answer. A run can survive
%% by sitting at the creature cap, by oscillating violently, or by drifting
%% slowly to nothing, and those want three different responses.
%%
%% ==========================================================================
%% TUNE FOR VIABILITY. NEVER FOR AN OUTCOME.
%% ==========================================================================
%%
%% A number in this world may be set by whether the world WORKS:
%%
%%   nothing goes extinct, or extinction is the finding rather than the noise
%%   the population is not pinned against max_creatures
%%   the energy books balance
%%   a sense has something to discriminate, or its organ pays rent for nothing
%%
%% A number may NEVER be set by what EVOLVES in it. "Carnivores appear at this
%% value" is not a reason to choose that value, because the carnivores are the
%% thing being claimed as a discovery. Choosing the rules by the phenotype
%% installs the result and then reports finding it.
%%
%% This rule is written here because this is the file where the mistake gets
%% made. It has been made once already: scent_mutation was set to the value that
%% produced the most carnivores, across five sweeps that all shared that same
%% success criterion, and the number had to be re-derived from a property of the
%% SIGNAL instead. Nothing below privileges one outcome over another, and the
%% summary deliberately reports no headline phenotype at all.
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
                            "born", "starved", "killed", "aged"])]),
    lists:foreach(fun print_row/1, Rows),
    diet_table(Rows),
    Finals = [P || #{final := #{population := P}} <- Rows],
    Extinct = length([P || P <- Finals, P =:= 0]),
    io:format("~n~p/~p seeds extinct after ~p ticks~n",
              [Extinct, length(Rows), Ticks]),
    io:format("final population: min ~p median ~p max ~p~n",
              [lists:min(Finals), median(Finals), lists:max(Finals)]),
    trajectory(hd(Rows)).

print_row(#{seed := S, peak := Pk, trough := Tr,
            final := #{population := P, plants := Pl, born := B,
                       starved := St, killed := K, aged_out := Ag}}) ->
    io:format("~s~n", [row([S, P, Pk, Tr, Pl, B, St, K, Ag])]).

%% WHAT THE POPULATION TURNED OUT TO BE. Everything that varies, side by side,
%% with NONE OF IT PRIVILEGED: no headline metric, no summary line that picks a
%% winner. A probe that reports one number at the top is a probe that will be run
%% until that number moves, and the last round of sweeps here did exactly that.
%%
%% Per seed rather than averaged, because an earlier measurement was wrecked by
%% between-seed spread that a median would have hidden.
diet_table(Rows) ->
    io:format("~n~s~n", [row(["seed", "breed_at", "herb", "omni", "carn",
                              "undec", "eye", "gut", "nose", "scent", "tags",
                              "spread"])]),
    lists:foreach(fun print_diet/1, Rows).

print_diet(#{seed := S, final := #{diet := D, organs := O, scent_cells := Sc,
                                   scent_tags := Tg, scent_spread := Sp,
                                   breed_at_mean := Br}}) ->
    Get = fun(Map, K) -> maps:get(K, Map, 0) end,
    io:format("~s~n", [row([S, Br,
                            Get(D, herbivores), Get(D, omnivores),
                            Get(D, carnivores), Get(D, undecided),
                            Get(O, eye), Get(O, gut), Get(O, nose),
                            Sc, Tg, Sp])]).

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
