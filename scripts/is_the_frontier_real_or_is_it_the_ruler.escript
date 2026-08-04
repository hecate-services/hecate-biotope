#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc IS THE WORLD CONVERGING, OR HAS MY DESCRIPTOR JUST RUN OUT OF BOXES?
%%
%% Usage:  ./scripts/is_the_frontier_real_or_is_it_the_ruler.escript [seeds [ticks]]
%%
%% ==========================================================================
%% THE CLAIM UNDER TEST IS MY OWN, AND IT IS THE ONE EVERYTHING RESTS ON
%% ==========================================================================
%%
%% `explored 76 of 125` and `frontier 0 by tick 6,000` have been reported as the
%% central result of this week: the world stops finding new ways to live. Two
%% worlds were argued for on that basis and one was gated out.
%%
%% ⚠ BUT SOME OF THOSE 125 CELLS MAY BE PHYSICALLY IMPOSSIBLE. Dispersal is
%% distance from birthplace and mobility is the share of ticks spent moving, and
%% a creature moves at most one cell per tick. **A sessile creature cannot have
%% crossed the island.** If most of the 49 unfilled cells are contradictions like
%% that, then `explored 76` is not a world that stopped exploring, it is a ruler
%% that ran out of marks.
%%
%% THE TEST: pool every cell ever occupied across many seeds and long runs. If
%% the union across all of them plateaus near the same 76, that is the reachable
%% space and the frontier reaching zero means the DESCRIPTOR saturated. If the
%% union keeps climbing toward 125 while any single world stalls at 76, then
%% individual worlds really do converge and the finding stands.
%%
%% `I.2` and `I.3` are both this shape: a summary that answers a different
%% question than the one asked. This is the same test applied to my own.
-mode(compile).

main(Args) ->
    Seeds = arg(Args, 1, 24),
    Ticks = arg(Args, 2, 8000),
    Space = behaviour:bins() * behaviour:bins() * behaviour:bins(),
    io:format("~n~p seeds to ~p ticks. The space has ~p cells.~n~n",
              [Seeds, Ticks, Space]),
    Sets = in_parallel(fun(S) -> cells(S, Ticks) end, lists:seq(1, Seeds)),
    %% ⚠ THE COMPARISON MUST BE MADE ON WORLDS THAT ARE STILL ALIVE, and the
    %% first version of this took a median over ALL seeds. Half of them are dead,
    %% frozen with a handful of cells, and they dragged the median to 21 while
    %% the best living world had reached 95. **The claim under test was about
    %% healthy worlds** — populations of seventy-odd carrying on while the
    %% frontier sat at zero — so a statistic dominated by graveyards answers a
    %% different question. Both are printed.
    Alive = [Cells || {Pop, Cells} <- Sets, Pop > 0, Cells =/= []],
    All = [Cells || {_Pop, Cells} <- Sets, Cells =/= []],
    io:format("~p of ~p seeds still alive at the end.~n~n",
              [length(Alive), length(All)]),
    report(All, Alive, Space),
    verdict(Alive, All, Space).

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.

%% Every cell this seed ever occupied, from its own archive.
cells(Seed, Ticks) ->
    W = advance(world:new(#{seed => Seed, population => 40}), Ticks),
    #{archive := Flat, population := Pop} = world:snapshot(W),
    {Pop, lists:usort(occupied(Flat))}.

occupied([Cell, _First, _Best | Rest]) -> [Cell | occupied(Rest)];
occupied(_Short) -> [].

report(All, Alive, Space) ->
    Union = lists:usort(lists:append(All)),
    io:format("~s~n", [row(["seeds", "median", "best", "UNION", "of space"])]),
    io:format("~s~n", [row(["all", median([length(S) || S <- All]),
                            lists:max([0 | [length(S) || S <- All]]),
                            length(Union),
                            [integer_to_list(length(Union) * 100 div Space),
                             "%"]])]),
    io:format("~s~n~n", [row(["ALIVE", median([length(S) || S <- Alive]),
                              lists:max([0 | [length(S) || S <- Alive]]),
                              length(lists:usort(lists:append(Alive))), ""])]),
    Live = All,
    io:format("~s~n", [row(["cells", "found by", "", "", ""])]),
    lists:foreach(fun({N, Cell}) -> shown(N, Cell, length(Live)) end,
                  rarest(Live, Union)).

%% The cells only one or two seeds ever reached: if they exist, the space is
%% bigger than any single world explores and convergence is real.
rarest(Live, Union) ->
    Counted = [{length([S || S <- Live, lists:member(C, S)]), C} || C <- Union],
    lists:sublist(lists:sort(Counted), 6).

shown(N, Cell, Of) ->
    io:format("~s~n", [row([Cell, [integer_to_list(N), " of ",
                                   integer_to_list(Of)],
                            behaviour:describe(Cell), "", ""])]).

%% ==========================================================================
%% THE READING, STATED BEFORE THE NUMBERS
%% ==========================================================================
%%
%% If the union over all seeds is close to what a single world reaches, the
%% descriptor saturated and "the frontier reaches zero" is a fact about the
%% ruler. If the union is much larger, single worlds genuinely stall short of
%% what is reachable and the finding survives.
%%
%% A fifth again is the line, stated now: the union must exceed the median world
%% by more than 20% for the convergence claim to mean anything.
verdict([], _All, _Space) ->
    io:format("~nNo seed survived. The comparison cannot be made.~n");
verdict(Alive, All, Space) ->
    Union = length(lists:usort(lists:append(All))),
    %% A LIVING world, not the median over graveyards. The claim was that a
    %% healthy population stops discovering; the test is whether a healthy
    %% population has anywhere left to discover.
    One = median([length(S) || S <- Alive]),
    io:format("~n~ts~n", [call(Union * 100 > One * 120, One, Union, Space)]).

call(true, One, Union, _Space) ->
    io_lib:format("THE FINDING SURVIVES. A single world reaches ~p cells and the "
                  "union over~nall seeds reaches ~p, so worlds really do stall "
                  "short of what this world~ncan produce. The frontier reaching "
                  "zero is convergence and not quantisation.", [One, Union]);
call(false, One, Union, Space) ->
    io_lib:format("⚠ THE RULER RAN OUT, AND THE CONVERGENCE FINDING IS WITHDRAWN "
                  "AS STATED.~n~nA single world reaches ~p cells of ~p and the "
                  "union over every seed reaches~nonly ~p. The unfilled cells are "
                  "not places this world fails to go: they are~ncombinations it "
                  "cannot produce, like a sessile creature that has crossed the~n"
                  "island. **A frontier of zero means the descriptor saturated.**~n~n"
                  "Everything argued from 'the world stops discovering' needs "
                  "re-reading,~nincluding J.2 and the case for world 23.",
                  [One, Space, Union]).

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(500, Left),
    going(world:population(W) > 0, world:tick(W, Step), Left - Step).

going(false, W, _Left) -> W;
going(true, W, Left) -> advance(W, Left).

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
pad(C) when is_binary(C) -> pad(binary_to_list(C));
pad(C) -> string:pad(lists:flatten(C), 14, trailing).
