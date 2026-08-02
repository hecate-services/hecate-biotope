#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc DOES AN EVOLVED CREATURE CHOOSE DIFFERENTLY HUNGRY THAN FULL?
%%
%% Usage:  ./scripts/does_hunger_change_the_choice.escript [seeds [ticks]]
%%
%% Criteria in PREREGISTRATION_BEHAVIOUR.md, frozen before this was written.
%%
%% THE FIRST MEASUREMENT HERE THAT ASKS WHAT A CREATURE DOES. Seventeen worlds of
%% census: how many sensors, how many nodes, how much reach. A census cannot tell
%% an organ that works from an organ that is carried, and `F.4' was refuted by
%% totals that all agreed with each other while the death rate did not.
%%
%% TWO QUESTIONS, AND THE SECOND CAN MAKE THE FIRST MOOT:
%%
%%   CAN IT     hold the world and the position fixed, vary ONLY the store, and
%%              see whether the creature's RANKING of the cells it could move to
%%              changes. Ranking and not chosen cell: `pick_best/2' breaks ties
%%              by drawing, so comparing choices would report the generator.
%%
%%   EVER       a `self' reading is `energy div unit', and the unit is 400 at the
%%              world 17 default. A creature whose store stays inside one 400-wide
%%              band reads the same number for its whole life, and NO BRAIN CAN
%%              CONDITION ON A CONSTANT. So this also tracks the range of readings
%%              each creature actually lives through.
%%
%% Reporting the first without the second would be a finding about brains that is
%% really a finding about the instrument they were given. That is the sixth
%% instrument failure in this project and it is the shape of all of them.
-mode(compile).

%% A ladder spanning what a creature can hold, from nearly dead to hoarding. The
%% top is well past anything seen alive, on purpose: the question "could it, at
%% any store" is different from "does it, at the stores it reaches", and both are
%% reported.
-define(LADDER, [0, 50, 100, 200, 399, 400, 800, 1600, 3200, 6400, 12800]).

main(Args) ->
    Seeds = arg(Args, 1, 8),
    Ticks = arg(Args, 2, 2000),
    Unit = body:unit(self, world:defaults()),
    io:format("~n~p seeds settled ~p ticks. sense_scale ~p, so a self reading is "
              "store div ~p.~n~n",
              [Seeds, Ticks, maps:get(sense_scale, world:defaults()), Unit]),
    io:format("~s~n", [row(["seed", "alive", "with self", "CHANGED", "reading "
                            "moves", "MOVE chg", "ACT chg", "same shift"])]),
    Totals = [report(S, Ticks, Unit) || S <- lists:seq(1, Seeds)],
    summary(lists:foldl(fun add/2, #{}, Totals), Unit).

arg(Args, N, _Default) when length(Args) >= N ->
    list_to_integer(lists:nth(N, Args));
arg(_Args, _N, Default) -> Default.

report(Seed, Ticks, Unit) ->
    {W, Lived} = settle(Seed, Ticks),
    Cs = world:creatures(W),
    Selves = [Id || {Id, C} <- maps:to_list(Cs), has_self(C)],
    Rows = [look(W, Id, maps:get(Id, Cs), Lived, Unit) || Id <- Selves],
    Changed = length([x || #{changed := true} <- Rows]),
    Moves = length([x || #{reading_moves := true} <- Rows]),
    Acted = length([x || #{act_changed := true} <- Rows]),
    Shift = length([x || #{same_shift := true} <- Rows]),
    io:format("~s~n", [row([Seed, map_size(Cs), length(Selves), Changed, Moves,
                            Changed, Acted, Shift])]),
    #{alive => map_size(Cs), selves => length(Selves), changed => Changed,
      moves => Moves, acted => Acted, shift => Shift}.

%% ==========================================================================
%% CAN IT, AND DOES IT EVER GET THE CHANCE
%% ==========================================================================
look(W, Id, C, Lived, Unit) ->
    Appraisals = [world:appraise(W, Id, E) || E <- ?LADDER],
    Rankings = [ranking(A) || A <- Appraisals],
    {Low, High} = maps:get(Id, Lived, {maps:get(energy, C), maps:get(energy, C)}),
    #{changed => length(lists:usort(Rankings)) > 1,
      hidden => brain:hidden_count(maps:get(brain, C)),
      %% THE MECHANISM, MEASURED RATHER THAN ASSERTED. `self' is not spatial, so
      %% it reads the same for every candidate cell and adds the SAME constant to
      %% each of their scores. A constant added to every alternative cannot move
      %% a ranking. If that is really why nothing changes, then between any two
      %% stores every cell's score shifts by an identical amount, and the only
      %% thing in this world that could break it is the rectifier inside a hidden
      %% node.
      same_shift => uniform(Appraisals),
      %% THE OTHER HALF OF THE DECISION. `breed', `grow' and `eat' are thresholds
      %% on one output at one place, so nothing cancels and hunger CAN decide
      %% them. Measured as whether any of the three crosses zero anywhere on the
      %% ladder: crossing zero is exactly what `breed_one/3' and `build_one/3'
      %% test. Reporting movement alone would have been a claim about creatures
      %% that was really a claim about which decision was looked at.
      act_changed => acts_flip(W, Id),
      %% Whether this creature's OWN store range ever spans a reading boundary.
      %% Not whether the ladder does: the ladder is deliberately wider than life.
      reading_moves => (High div Unit) > (Low div Unit),
      span => High - Low,
      weight => self_weight(C)}.

%% The ORDER of the cells by what the creature makes of them, which is what a
%% decision is. Ties are kept as ties by sorting on the score and the cell
%% together, so an unchanged appraisal always yields an identical ranking.
ranking(Scored) ->
    [Cell || {_Score, Cell}
                 <- lists:reverse(lists:sort([{S, Cell} || {Cell, S} <- Scored]))].

has_self(#{body := Body}) -> lists:keymember(self, 1, Body).

acts_flip(W, Id) ->
    Wants = [[sign(maps:get(P, world:consider(W, Id, E), 0))
              || P <- [breed, grow, eat]] || E <- ?LADDER],
    length(lists:usort(Wants)) > 1.

sign(V) when V > 0 -> yes;
sign(_V) -> no.

%% Every cell's score moves by the same amount between consecutive stores.
uniform([_Single]) -> true;
uniform([A, B | Rest]) ->
    Deltas = [S2 - S1 || {{_C, S1}, {_C2, S2}} <- lists:zip(A, B)],
    length(lists:usort(Deltas)) =:= 1 andalso uniform([B | Rest]).

%% How much total weight every vector in the brain puts on the `self' column.
%% Zero is a creature that takes the measurement, pays for it, and acts on it
%% with nothing. `brain:attention/2' already existed and nothing had asked it
%% about one column.
self_weight(#{body := Body, brain := Brain}) ->
    Attention = brain:attention(Brain, length(Body)),
    column(index_of_self(Body, 1), Attention).

index_of_self([{self, _} | _], N) -> N;
index_of_self([_Other | Rest], N) -> index_of_self(Rest, N + 1);
index_of_self([], _N) -> 0.

column(0, _Attention) -> 0;
column(N, Attention) when N =< length(Attention) -> lists:nth(N, Attention);
column(_N, _Attention) -> 0.

%% ==========================================================================
%% WHAT STORES A CREATURE ACTUALLY LIVES THROUGH
%% ==========================================================================
%%
%% Walked one tick at a time and folded per id, because the question is about an
%% INDIVIDUAL's range and a snapshot is a population. Ids are never reused, so a
%% dead creature's range simply stops growing.
settle(Seed, Ticks) ->
    W0 = world:new(#{seed => Seed, population => 40,
                     transfer_efficiency => 100}),
    walk(W0, Ticks, seen(W0, #{})).

walk(W, 0, Lived) -> {W, Lived};
walk(W, Left, Lived) ->
    W1 = world:tick(W, 1),
    keep(world:population(W1) > 0, W1, Left - 1, seen(W1, Lived)).

keep(false, W, _Left, Lived) -> {W, Lived};
keep(true, W, Left, Lived) -> walk(W, Left, Lived).

seen(W, Lived) ->
    maps:fold(fun(Id, #{energy := E}, Acc) -> stretch(Id, E, Acc) end,
              Lived, world:creatures(W)).

stretch(Id, E, Acc) ->
    maps:update_with(Id, fun({Lo, Hi}) -> {min(Lo, E), max(Hi, E)} end,
                     {E, E}, Acc).

add(Row, Acc) ->
    maps:from_list([{K, maps:get(K, Acc, 0) + V} || {K, V} <- maps:to_list(Row)]).

summary(#{alive := A, selves := S, changed := C, moves := M} = Sum, Unit) ->
    io:format("~n~p creatures alive across the seeds, ~p carrying a self "
              "sensor.~n", [A, S]),
    io:format("CHANGED: ~p of those ~p rank the cells differently somewhere on "
              "a store~nladder from 0 to 12,800.~n", [C, S]),
    io:format("READING MOVES: ~p of those ~p ever cross a multiple of ~p in "
              "their own life,~nwhich is what it takes for the hunger sense to "
              "say two different things.~n", [M, S, Unit]),
    io:format("ACT CHANGED: ~p of ~p change whether they want to breed, grow or "
              "eat.~nSAME SHIFT: ~p of ~p have every candidate cell's score move "
              "by an identical~namount, which is why moving cannot depend on "
              "hunger and acting can.~n",
              [maps:get(acted, Sum), S, maps:get(shift, Sum), S]),
    io:format("~nNeither number is publishable without the other. A creature "
              "that could rank~ndifferently at a store it never reaches has "
              "still never made a hunger decision.~n").

avg([]) -> 0;
avg(L) -> lists:sum(L) div length(L).

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(C, 13, trailing).
