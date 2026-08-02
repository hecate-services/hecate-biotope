#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc IF EVERYTHING HAD TO COME TO THE SAME FEW CELLS, WHAT WOULD IT BUY?
%%
%% Usage:  ./scripts/what_would_a_waterhole_buy.escript [ticks [seeds [draws]]]
%%
%% THE PREMISE OF THE WATERING HOLE, MEASURED BEFORE IT IS BUILT.
%%
%% `D.7`: predation is suppressed by opportunity, not economics. A bite is the
%% same size as a graze, 299 against 277, and a creature gets 0 to 1 chances in
%% its whole life because 54 to 84 creatures on 1,261 cells almost never meet.
%%
%% Raf's proposal is a second requirement in a few fixed places, so everything
%% has to come to the same handful of cells. The load-bearing assumption is NOT
%% the water. It is that CONCENTRATION PRODUCES MEALS.
%%
%% ⚠ AND THAT IS NOT OBVIOUS, because a meal needs something STRICTLY SMALLER.
%% `resolve/3` gives a cell's carcass to the largest creature standing on it, so
%% a crowd of equals is company and not food. If world 18's populations are
%% size-uniform, herding them together produces a queue rather than a food chain.
%% **The size distribution decides this, not the crowding**, and that is why this
%% uses the REAL structures of a settled population rather than a model of them.
%%
%% RADIUS IS NOT A LEVER, which is why this exists. `does_crowding_make_meals`
%% swept the board from 61 cells to 1,261 and density came out 3.5 to 4.0% at
%% every size: the world settles to the same occupancy whatever room it is given.
%% So the only way to raise local density is to make the distribution UNEVEN,
%% which is precisely what a waterhole does and what this measures.
%%
%% WHAT IT IS NOT. This does not simulate water, thirst, travel or the cost of
%% getting there. It answers one question: given the creatures a world actually
%% produces, how many meals appear if they are gathered into K cells instead of
%% spread over the board. If the answer is "none", the world is not worth
%% building and the reason is the size distribution rather than the idea.
-mode(compile).

%% The board, and then what fraction of it the population is squeezed into. 1261
%% is the disc at radius 20, which is where they are now.
-define(CELLS, [1261, 400, 120, 40, 12, 4, 1]).

main(Args) ->
    Ticks = arg(Args, 1, 2000),
    Seeds = arg(Args, 2, 16),
    Draws = arg(Args, 3, 200),
    io:format("~nsettled ~p ticks, ~p seeds, ~p random arrangements each.~n~n",
              [Ticks, Seeds, Draws]),
    Pops = [P || P <- [settle(S, Ticks) || S <- lists:seq(1, Seeds)], P =/= dead],
    report(Pops, Draws).

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.

settle(Seed, Ticks) ->
    W = advance(world:new(#{seed => Seed, population => 40,
                            transfer_efficiency => 100}), Ticks),
    alive(world:population(W) > 0, W).

alive(false, _W) -> dead;
alive(true, W) ->
    [maps:get(structure, C) || C <- maps:values(world:creatures(W))].

report([], _Draws) ->
    io:format("Every seed died. No population to arrange.~n");
report(Pops, Draws) ->
    io:format("~p worlds survived, populations ~w.~n",
              [length(Pops), [length(P) || P <- Pops]]),
    io:format("Size spread within a world, largest over smallest: ~s~n~n",
              [spreads(Pops)]),
    io:format("~s~n", [row(["cells", "crowding", "SHARED%", "PREY%",
                            "vs board"])]),
    Base = measure(Pops, hd(?CELLS), Draws),
    lists:foreach(fun(C) -> line(C, measure(Pops, C, Draws), Base) end, ?CELLS),
    io:format("~nSHARED%% is the share of creatures standing with another. "
              "PREY%% is the share~nstanding on something STRICTLY SMALLER, "
              "which is the only thing a mouth can use.~n\"vs board\" is PREY%% "
              "against the same population spread over the whole disc.~n").

line(Cells, {Shared, Prey}, {_BS, BasePrey}) ->
    io:format("~s~n", [row([Cells, times(1261, Cells), one(Shared), one(Prey),
                            times_f(Prey, BasePrey)])]).

%% RANDOM ARRANGEMENTS, AVERAGED. A single placement of fifty creatures into four
%% cells is mostly luck, and the question is what the arrangement is WORTH rather
%% than what one draw of it looked like.
measure(Pops, Cells, Draws) ->
    Rows = [draw(Pop, Cells, D) || Pop <- Pops, D <- lists:seq(1, Draws)],
    {mean([S || {S, _P} <- Rows]), mean([P || {_S, P} <- Rows])}.

%% Seeded from the draw number so the whole script is a pure function of its
%% arguments. `G.6` was a day spent on exactly this.
draw(Structures, Cells, D) ->
    Rng = rand:seed_s(exsss, {Cells, D, length(Structures)}),
    {ByCell, _} = lists:foldl(fun(S, {Acc, R}) ->
                                      {N, R1} = rand:uniform_s(Cells, R),
                                      {maps:update_with(N, fun(L) -> [S | L] end,
                                                        [S], Acc), R1}
                              end, {#{}, Rng}, Structures),
    Groups = maps:values(ByCell),
    Heads = length(Structures),
    {pct(lists:sum([length(G) || G <- Groups, length(G) > 1]), Heads),
     pct(lists:sum([predators(G) || G <- Groups]), Heads)}.

%% How many in this cell have something strictly smaller under them. A crowd of
%% equals yields nobody.
predators(Group) ->
    Smallest = lists:min(Group),
    length([S || S <- Group, S > Smallest]).

spreads(Pops) ->
    lists:join(", ", [io_lib:format("~.1fx", [lists:max(P) / max(1, lists:min(P))])
                      || P <- Pops]).

pct(_Part, 0) -> 0.0;
pct(Part, Whole) -> Part * 100 / Whole.

times(Board, Cells) -> io_lib:format("~wx", [Board div max(1, Cells)]).
times_f(_Prey, Base) when Base =< 0.0 -> "-";
times_f(Prey, Base) -> io_lib:format("~.1fx", [Prey / Base]).
one(V) -> io_lib:format("~.1f", [V]).

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(500, Left),
    going(world:population(W) > 0, world:tick(W, Step), Left - Step).

going(false, W, _Left) -> W;
going(true, W, Left) -> advance(W, Left).

mean([]) -> 0.0;
mean(L) -> lists:sum(L) / length(L).

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(C, 12, trailing).
