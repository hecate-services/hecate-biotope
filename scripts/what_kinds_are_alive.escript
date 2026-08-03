#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc HOW MANY KINDS OF CREATURE ARE ALIVE, as against how many ancestors.
%%
%% Usage:  ./scripts/what_kinds_are_alive.escript [seeds [ticks]]
%%
%% `G.1` says it plainly and nothing ever acted on it: **"A founding is ANCESTRY
%% AND NOT A KIND, and nothing here should be read as a count of species: the tag
%% is inherited unchanged, can never split."**
%%
%% So `lineages` counts founders with surviving descendants and can only fall,
%% and it has read 1 since world 9, and eighteen worlds have called that a
%% monoculture. **Nothing has ever counted what a creature IS.**
%%
%% Raf, 2026-08-03: brain diversity, the sensors and actuators and hidden layers,
%% is what defines a creature and would define a species. That is the thing this
%% project is about and it is not on any page or in any sweep.
-mode(compile).
%% A KIND is what a creature IS: its sorted body, how many hidden nodes it
%% carries, and which purposes it has. Weights and scalars are variation WITHIN
%% a kind, the way allele frequencies are within a species. Topology is the kind.
main(Args) ->
    N = case Args of [] -> 12; [A|_] -> list_to_integer(A) end,
    T = case Args of [_,B|_] -> list_to_integer(B); _ -> 5000 end,
    io:format("~n~p seeds to ~p ticks. KINDS counts distinct architectures alive;~n"
              "lineages counts founders with descendants and can only fall.~n~n", [N, T]),
    io:format(" seed  pop   lines  KINDS  biggest%%  sensors  nodes  top architecture~n"),
    [row(S, T) || S <- lists:seq(1, N)].
row(Seed, T) ->
    W = adv(world:new(#{seed => Seed}), T),
    Cs = maps:values(world:creatures(W)),
    out(Seed, Cs, world:snapshot(W)).
out(Seed, [], _S) -> io:format(" ~-5w dead~n", [Seed]);
out(Seed, Cs, S) ->
    Kinds = [kind(C) || C <- Cs],
    Tally = lists:foldl(fun(K, A) -> maps:update_with(K, fun(C) -> C+1 end, 1, A) end,
                        #{}, Kinds),
    {Top, Big} = hd(lists:reverse(lists:keysort(2, maps:to_list(Tally)))),
    io:format(" ~-5w ~-5w ~-6w ~-6w ~-9w ~-8.2f ~-6.2f ~s~n",
              [Seed, length(Cs), maps:get(lineages, S), map_size(Tally),
               round(Big * 100 / length(Cs)),
               maps:get(sensor_mean, S)/100, maps:get(hidden_mean, S)/100,
               show(Top)]).
kind(#{body := B, brain := Br}) ->
    {lists:sort(B), length(maps:get(hidden, Br)),
     lists:sort(maps:keys(maps:get(outputs, Br)))}.
show({Body, Hidden, Purposes}) ->
    io_lib:format("~s | ~wh | ~s",
                  [[io_lib:format("~c~w ", [hd(atom_to_list(F)), R]) || {F,R} <- Body],
                   Hidden,
                   lists:join(",", [atom_to_list(P) || P <- Purposes])]).
adv(W, 0) -> W;
adv(W, N) -> a(world:population(W) > 0, W, N).
a(false, W, _N) -> W;
a(true, W, N) -> adv(world:tick(W, min(500, N)), N - min(500, N)).
