#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc THE GATE FOR OUTCROSSING: WHEN A CREATURE BREEDS, IS ANYONE THERE?
%%
%% Usage:  ./scripts/is_anyone_in_reach.escript [seeds [ticks]]
%%
%% Recombination needs two parents and this world has no notion of a pair. A
%% creature breeds alone, on its own cell, whenever its brain says so. So before
%% any of it is built the question is whether a second creature is ever WITHIN
%% REACH at the moment one breeds.
%%
%% ⚠ THERE IS ALREADY A REASON TO THINK NOT. `D.7` found predation suppressed by
%% OPPORTUNITY rather than by economics: a creature gets **nought to one chances
%% in an entire life** to eat another, because the board is large and the
%% population is sparse. Mating and eating need exactly the same thing to happen
%% first, which is two creatures in one place, so `D.7` is a prediction about
%% this and it predicts failure.
%%
%% THE GATE, FIXED BEFORE THE NUMBERS:
%%
%%   If fewer than 5% of births have a partner in reach, OUTCROSSING IS NOT WORTH
%%   BUILDING at this population density, because a rule that fires one birth in
%%   twenty cannot be measured against drift and the experiment would be a null
%%   with an expensive implementation attached.
%%
%% TWO RADII ARE REPORTED because the choice is not obvious and should be made on
%% the numbers rather than on taste:
%%
%%   same cell  the world's own notion of an encounter, and what `consume/1' uses
%%              to decide who eats whom.
%%   in reach   the creature's own cell and its six neighbours: the seven cells it
%%              can step into and senses over, which is the world's existing
%%              notion of what a creature can get to.
-mode(compile).

-define(GATE_PCT, 5).

main(Args) ->
    Seeds = arg(Args, 1, 12),
    Ticks = arg(Args, 2, 4000),
    io:format("~n~p seeds to ~p ticks. Gate fixed in advance: under ~p% of births "
              "with a~npartner in reach means outcrossing is not worth building "
              "at this density.~n~n", [Seeds, Ticks, ?GATE_PCT]),
    io:format("~s~n", [row(["seed", "births", "SAME CELL", "IN REACH", "pop"])]),
    Rows = in_parallel(fun(S) -> walk(S, Ticks) end, lists:seq(1, Seeds)),
    lists:foreach(fun print/1, Rows),
    verdict(Rows).

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.

%% ONE TICK AT A TIME, because the question is about the moment of a birth and a
%% thousand-tick jump would only show where everyone ended up.
walk(Seed, Ticks) ->
    step(world:new(#{seed => Seed, population => 40}), Ticks, {0, 0, 0}).

step(W, 0, Tally) -> {Tally, world:population(W)};
step(W, Left, Tally) ->
    carry_on(world:population(W), W, Left, Tally).

carry_on(0, _W, _Left, Tally) -> {Tally, 0};
carry_on(_Pop, W, Left, Tally) ->
    step(world:tick(W, 1), Left - 1, count(W, Tally)).

%% Every creature ALIVE this tick is a candidate: the instrument does not ask the
%% brain whether it intends to breed, because that would make the answer depend
%% on the brains that happen to have evolved, and the gate is about the BOARD.
%% It is therefore an upper bound on how often a birth could be outcrossed, which
%% is the right side to be wrong on for a gate that can only refuse.
count(W, {Births, Same, Reach}) ->
    Cs = world:creatures(W),
    Places = [maps:get(at, C) || C <- maps:values(Cs)],
    Occupied = tally(Places),
    R = maps:get(radius, world:defaults()),
    {Births + map_size(Cs),
     Same + length([P || P <- Places, maps:get(P, Occupied, 0) > 1]),
     Reach + length([P || P <- Places, neighbours(P, Occupied, R) > 1])}.

%% The creature's own cell plus the six it can step into: the world's existing
%% notion of what is within reach, taken from `hex' rather than invented here.
neighbours(At, Occupied, Radius) ->
    lists:sum([maps:get(C, Occupied, 0)
               || C <- [At | hex:neighbours_in(At, Radius)]]).

tally(Places) ->
    lists:foldl(fun(P, Acc) -> maps:update_with(P, fun bump/1, 1, Acc) end,
                #{}, Places).

bump(N) -> N + 1.

print({{0, _S, _R}, Pop}) ->
    io:format("~s~n", [row(["-", 0, "-", "-", Pop])]);
print({{Births, Same, Reach}, Pop}) ->
    io:format("~s~n", [row(["", Births, pc(Same, Births), pc(Reach, Births),
                            Pop])]).

pc(Part, Whole) -> integer_to_list(Part * 100 div max(1, Whole)) ++ "%".

verdict(Rows) ->
    Live = [T || {{B, _S, _R} = T, _P} <- Rows, B > 0],
    Births = lists:sum([B || {B, _S, _R} <- Live]),
    Same = lists:sum([S || {_B, S, _R} <- Live]),
    Reach = lists:sum([R || {_B, _S, R} <- Live]),
    SamePct = Same * 100 div max(1, Births),
    ReachPct = Reach * 100 div max(1, Births),
    io:format("~n~p creature-ticks across all seeds.~n"
              "SAME CELL ~p%, IN REACH ~p%.~n~n~s~n",
              [Births, SamePct, ReachPct, call(SamePct, ReachPct)]).

call(_Same, Reach) when Reach < ?GATE_PCT ->
    "GATE REFUSES. A partner is in reach for fewer than one birth in twenty, so\n"
    "outcrossing would fire too rarely to be told from drift. `D.7` predicted\n"
    "exactly this and was right: mating and eating need the same thing to happen\n"
    "first. Build density before building sex, or do not build sex.";
call(Same, Reach) when Same < ?GATE_PCT ->
    "GATE PASSES ON THE SEVEN CELLS AND REFUSES ON THE ONE. Two creatures are\n"
    "almost never on one cell, which is `D.7` confirmed, but the neighbourhood a\n"
    "creature can step into is populated often enough to breed across. **The\n"
    "radius is therefore not a taste and must be the seven cells**, and a version\n"
    "of this that required co-location would have measured nothing while looking\n"
    "like a fair test.";
call(_Same, _Reach) ->
    "GATE PASSES ON BOTH. Co-location alone is common enough to outcross on,\n"
    "which is the narrower and more defensible rule: it uses the world's own\n"
    "notion of an encounter, the one `consume/1' already decides predation with.".

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
pad(C) -> string:pad(lists:flatten(C), 12, trailing).
