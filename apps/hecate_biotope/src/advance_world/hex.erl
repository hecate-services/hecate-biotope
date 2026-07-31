%% @doc The shape of the ground: a hexagonal disc in axial coordinates.
%%
%% HEXES RATHER THAN SQUARES, because every neighbour of a hex is the same
%% distance away. On a square grid a diagonal step is 1.41 times a straight one,
%% so anything that later spends energy to move, or senses at a radius, has to
%% carry a correction or quietly lie about distance. Six neighbours and one
%% distance removes a whole class of that.
%%
%% AXIAL COORDINATES, `{Q, R}'. The third cube coordinate is always `-Q-R', so
%% storing it would be storing a derived value. Distance is the cube distance,
%% recovered from the two we keep.
%%
%% A DISC RATHER THAN A RECTANGLE, so that no creature has a corner to hide in.
%% A rectangular world gives its four corners fewer neighbours than anywhere
%% else, which is a gradient nobody chose and which selection would find.
-module(hex).

-export([disc/1, in_disc/2, neighbours/1, neighbours_in/2, distance/2, cells/1]).

-type hex() :: {integer(), integer()}.
-export_type([hex/0]).

%% The six axial steps, in a fixed order. Fixed because a caller that picks the
%% Nth neighbour must get the same direction every time, or a "random walk"
%% becomes a random walk over a shuffling coordinate system.
-define(STEPS, [{1, 0}, {1, -1}, {0, -1}, {-1, 0}, {-1, 1}, {0, 1}]).

%% @doc Every cell of a disc of the given radius, radius 0 being one cell.
-spec disc(non_neg_integer()) -> [hex()].
disc(Radius) ->
    [{Q, R} || Q <- lists:seq(-Radius, Radius),
               R <- lists:seq(max(-Radius, -Q - Radius),
                              min(Radius, -Q + Radius))].

%% @doc How many cells a disc of the given radius holds: 3r^2 + 3r + 1.
-spec cells(non_neg_integer()) -> pos_integer().
cells(Radius) -> 3 * Radius * Radius + 3 * Radius + 1.

-spec in_disc(hex(), non_neg_integer()) -> boolean().
in_disc(H, Radius) -> distance(H, {0, 0}) =< Radius.

-spec neighbours(hex()) -> [hex()].
neighbours({Q, R}) -> [{Q + DQ, R + DR} || {DQ, DR} <- ?STEPS].

%% @doc Neighbours that are still inside the disc. Movement uses this rather
%% than filtering afterwards, so a creature at the rim never spends a turn
%% choosing a step it cannot take, which would make the rim a slow trap.
-spec neighbours_in(hex(), non_neg_integer()) -> [hex()].
neighbours_in(H, Radius) -> [N || N <- neighbours(H), in_disc(N, Radius)].

%% @doc Cube distance. Half the sum of the three cube deltas.
-spec distance(hex(), hex()) -> non_neg_integer().
distance({Q1, R1}, {Q2, R2}) ->
    DQ = Q1 - Q2,
    DR = R1 - R2,
    (abs(DQ) + abs(DR) + abs(DQ + DR)) div 2.
