#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc Why the living come in lumps, and whether a lump is a PLACE or a FAMILY.
%%
%% Usage:  ./scripts/why_lumps.escript name:seed:ticks ...
%%
%% Take the arguments from `./scripts/ask_fleet_world.sh', which prints each
%% island's seed and tick. A world is a pure function of its seed, so this
%% reproduces the exact island anybody is looking at rather than a world of the
%% same kind. Never hard-code the seeds: an island that ends draws a new one.
%%
%% THE OBSERVATION. Under world 14 the creatures gather into a few persistent
%% blobs with hard edges instead of spreading over the board. Two explanations
%% produce that and they are not the same finding.
%%
%%   DEMOGRAPHY. A child is placed on a random NEIGHBOURING cell of its parent,
%%   so a reproducing population is spatially clumped by construction. This needs
%%   no ecology and has been true since world 1. Clumps of this kind drift and
%%   dissolve on the timescale of a generation.
%%
%%   THE GROUND. World 14 gave the board an absorbing state. A cell gets
%%   `mean(neighbours) * 3 div 100', exactly ZERO for any neighbourhood averaging
%%   under 34 of a ceiling of 400, and compounds by `E * 6 div 100', exactly ZERO
%%   under a stock of 17. A nearly empty cell in a nearly empty neighbourhood
%%   gains NOTHING, for ever, and can only be healed from outside. Clumps of this
%%   kind are pinned to the ground and outlive everything living in them.
%%
%% THE DISCRIMINATOR IS TIME, because both make blobs and only one makes blobs
%% that outlast their inhabitants. Clumping on its own would have been satisfied
%% by either and is reported only to show the lumps are real.
%%
%% TWO STATISTICS WERE THROWN AWAY BEFORE THIS VERSION. "Share of occupied cells
%% touching another" saturates: at the densities of a thriving world nearly every
%% cell touches an occupied neighbour whether clustered or not, and it read 97
%% against a random 98. Connected components do not saturate, and "how many
%% separate blobs, and how much of the population is in the biggest" is the
%% question anyway.
-mode(compile).

-define(LAGS, [10, 50, 200, 1000, 5000]).

main([]) ->
    io:format("usage: why_lumps.escript name:seed:ticks ...~n"
              "  take the values from ask_fleet_world.sh~n"),
    halt(1);
main(Args) ->
    io:format("~n~s~n", [row(["island", "pop", "cells", "blobs", "vs rnd",
                              "big%", "rnd big%", "on/off", "frozen", "gen"])]),
    Worlds = in_parallel(fun measure/1, [parse(A) || A <- Args]),
    lists:foreach(fun print/1, Worlds),
    io:format("~n~s~n", [row(["island" | ["keep" ++ integer_to_list(L)
                                          || L <- ?LAGS]])]),
    lists:foreach(fun print_keeps/1, Worlds),
    io:format("~n~s~n", [row(["island", "within", "total", "F_ST"])]),
    lists:foreach(fun print_kin/1, Worlds),
    io:format("~nblobs = connected groups of occupied cells, vs rnd = the same "
              "count scattered~nat random. big% = share of occupied cells in the "
              "largest group. on/off = mean~nstock under occupied cells over mean "
              "stock elsewhere, times a hundred.~nfrozen = share of the board "
              "gaining exactly nothing. gen = ticks per~ngeneration. keepN = "
              "occupied cells still occupied N ticks later, over what~nchance "
              "alone would leave, times a hundred. 100 means the lump has moved "
              "on.~n~nwithin = mean scent spread inside a lump, total = across the "
              "whole island,~nboth 0 for clonal and 50 for unrelated. F_ST is how "
              "much of the variation~nsits BETWEEN lumps rather than inside them: "
              "0 means a lump is a random~nsample of the island, high means the "
              "lumps are families.~n").

parse(Arg) ->
    [Name, Seed, Ticks] = string:split(Arg, ":", all),
    {Name, list_to_integer(Seed), list_to_integer(Ticks)}.

print(#{name := N, pop := P, cells := C, blobs := B, random_blobs := RB,
        big := Big, random_big := RBig, on_off := OnOff, frozen := F,
        gen := G}) ->
    io:format("~s~n", [row([N, P, C, B, RB, Big, RBig, OnOff, F, G])]).

print_keeps(#{name := N, keeps := Keeps}) ->
    io:format("~s~n", [row([N | Keeps])]).

print_kin(#{name := N, within := W, total := T, fst := F}) ->
    io:format("~s~n", [row([N, W, T, F])]).

measure({Name, Seed, Ticks}) ->
    W = world:tick(world:new(#{seed => Seed, population => 40,
                               transfer_efficiency => 100}),
                   Ticks),
    Snap = world:snapshot(W),
    Chart = world:chart(W),
    Cells = hex:disc(maps:get(radius, Chart)),
    Ground = ground_map(maps:get(ground, Chart)),
    Occupied = occupied(maps:get(creatures, Chart)),
    K = sets:size(Occupied),
    {Blobs, Big} = shape(Occupied),
    {RBlobs, RBig} = scattered(K, Cells),
    #{name => Name, pop => maps:get(population, Snap), cells => K,
      blobs => Blobs, random_blobs => RBlobs, big => Big, random_big => RBig,
      on_off => on_off(Occupied, Ground, Cells),
      frozen => frozen(Cells, Ground),
      gen => generation(Snap, Ticks),
      fst => fst(Chart, components(Occupied)),
      within => within(Chart, components(Occupied)),
      total => scent:spread(maps:get(signatures, Chart)),
      keeps => [kept(Occupied, W, Lag) || Lag <- ?LAGS]}.

%%==============================================================================
%% Is a lump a family?
%%==============================================================================

%% HOW MUCH OF THE VARIATION SITS BETWEEN LUMPS RATHER THAN INSIDE THEM, which is
%% Wright's F_ST written with the tools this world already has. `scent:spread/1'
%% IS a mean pairwise difference, normalised, so the standard ratio applies
%% directly: `(total - within) / total'. Zero means a lump is a random sample of
%% the island and there is no population structure. High means the lumps are
%% differentiated, which with local birth and a hundred-generation persistence is
%% Hamilton's condition arriving without anybody installing it.
%%
%% THE MARKER IS NEUTRAL AND THAT CUTS BOTH WAYS. `scent' is inherited with a
%% mutation rate and nothing reads it for fitness, so this measures ancestry and
%% not adaptation. It is the right instrument for relatedness and the wrong one
%% for anything else.
fst(Chart, Groups) ->
    apportioned(scent:spread(maps:get(signatures, Chart)),
                within(Chart, Groups)).

apportioned(0, _Within) -> 0;
apportioned(Total, Within) -> (Total - Within) * 100 div Total.

%% Averaged over the lumps big enough to have a pair, because `spread' of one
%% creature is zero and a board of singletons would otherwise read as perfectly
%% related.
within(Chart, Groups) ->
    Tagged = tagged(maps:get(creatures, Chart), maps:get(signatures, Chart)),
    Spreads = [scent:spread(Tags) || G <- Groups,
                                     Tags <- [[T || {H, T} <- Tagged,
                                                    sets:is_element(H, G)]],
                                     length(Tags) > 1],
    avg(Spreads).

tagged(Flat, Signatures) -> lists:zip(pairs(Flat), Signatures).

%%==============================================================================
%% What shape the living are in
%%==============================================================================

%% HOW MANY SEPARATE GROUPS, and how much of the population is in the biggest.
%% Two hundred creatures in one blob and two hundred scattered over the board
%% give the same density and the same mean distance to a neighbour; they do not
%% give the same component count.
shape(Occupied) ->
    biggest([sets:size(G) || G <- components(Occupied)], sets:size(Occupied)).

biggest([], _K) -> {0, 0};
biggest(Sizes, K) -> {length(Sizes), lists:max(Sizes) * 100 div K}.

components(Occupied) -> grouped(sets:to_list(Occupied), Occupied, []).

grouped([], _All, Groups) -> Groups;
grouped([H | Rest], All, Groups) ->
    Group = flood([H], All, sets:new()),
    grouped([C || C <- Rest, not sets:is_element(C, Group)],
            sets:subtract(All, Group), [Group | Groups]).

flood([], _All, Seen) -> Seen;
flood([H | Rest], All, Seen) ->
    spread(sets:is_element(H, Seen) orelse not sets:is_element(H, All),
           H, Rest, All, Seen).

spread(true, _H, Rest, All, Seen) -> flood(Rest, All, Seen);
spread(false, H, Rest, All, Seen) ->
    flood(hex:neighbours(H) ++ Rest, All, sets:add_element(H, Seen)).

%% THE SAME COUNT SCATTERED AT RANDOM, measured rather than derived, because the
%% component-count distribution of random points on a bounded hex disc has no
%% closed form worth trusting and an edge correction besides.
scattered(K, Cells) ->
    Runs = [shape(sets:from_list(lists:sublist(shuffle(Cells, T), K)))
            || T <- lists:seq(1, 7)],
    {avg([B || {B, _} <- Runs]), avg([G || {_, G} <- Runs])}.

shuffle(L, Salt) ->
    [X || {_K, X} <- lists:sort([{erlang:phash2({X, Salt}), X} || X <- L])].

%%==============================================================================
%% Rich ground or a hole they ate
%%==============================================================================

on_off(Occupied, Ground, Cells) ->
    {On, Off} = lists:partition(fun(H) -> sets:is_element(H, Occupied) end,
                                Cells),
    ratio(mean_stock(On, Ground), mean_stock(Off, Ground)).

mean_stock(Hs, Ground) -> avg([maps:get(H, Ground, 0) || H <- Hs]).

ratio(_On, 0) -> 0;
ratio(On, Off) -> On * 100 div Off.

%%==============================================================================
%% How much of the board is stranded
%%==============================================================================

%% A CELL GAINING EXACTLY NOTHING. Both recovery terms are integer divisions, so
%% each has a threshold below which it contributes zero rather than a little:
%% under 34 mean in the neighbourhood, under 17 in the cell itself.
frozen(Cells, Ground) ->
    Rate = maps:get(recolonise_pct, world:defaults()),
    Pct = maps:get(ground_growth_pct, world:defaults()),
    pct(length([H || H <- Cells, gain(H, Ground, Rate, Pct) =:= 0]),
        length(Cells)).

%% Neighbours outside the disc are left out, exactly as `ground:colonise/3'
%% leaves them out, or the rim would read as permanently stranded and the number
%% would be an edge artefact rather than a fact about the board.
gain(H, Ground, Rate, Pct) ->
    Around = [maps:get(N, Ground, 0) || N <- hex:neighbours(H),
                                        maps:is_key(N, Ground)],
    max(avg(Around) * Rate div 100, maps:get(H, Ground, 0) * Pct div 100).

%%==============================================================================
%% Whether the lumps outlive the creatures in them
%%==============================================================================

%% THE ONE THAT SETTLES IT. Run on and ask how many of the cells that were
%% occupied still are, against how many chance alone would leave. A ratio near
%% 100 means the lump has moved on; far above it, at a lag of many generations,
%% means the lump is a property of the PLACE and not of the family in it.
kept(Before, W, Lag) ->
    Chart = world:chart(world:tick(W, Lag)),
    After = occupied(maps:get(creatures, Chart)),
    Cells = length(hex:disc(maps:get(radius, Chart))),
    overlap(sets:size(sets:intersection(Before, After)),
            sets:size(Before), sets:size(After), Cells).

overlap(_Both, 0, _After, _Cells) -> 0;
overlap(_Both, _Before, 0, _Cells) -> 0;
overlap(Both, Before, After, Cells) ->
    round(Both * 100 / (Before * After / Cells)).

generation(#{depth := 0}, _Ticks) -> 0;
generation(#{depth := Depth}, Ticks) -> Ticks div Depth;
generation(_Snap, _Ticks) -> 0.

%%==============================================================================

occupied(Flat) -> sets:from_list(pairs(Flat)).

pairs([]) -> [];
pairs([Q, R | Rest]) -> [{Q, R} | pairs(Rest)].

ground_map(Flat) -> maps:from_list(triples(Flat)).

triples([]) -> [];
triples([Q, R, E | Rest]) -> [{{Q, R}, E} | triples(Rest)].

pct(_N, 0) -> 0;
pct(N, D) -> N * 100 div D.

avg([]) -> 0;
avg(L) -> lists:sum(L) div length(L).

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
