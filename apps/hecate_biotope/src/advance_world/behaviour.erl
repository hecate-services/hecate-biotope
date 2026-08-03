%% @doc WHAT A CREATURE DID, as against what it is. PURE.
%%
%% ==========================================================================
%% WHY THIS EXISTS: THE CENSUS HAS ONLY EVER MEASURED STRUCTURE
%% ==========================================================================
%%
%% `world:kind_of/1' describes a creature's ARCHITECTURE: which fields it has
%% sensors for, how many hidden nodes, which acts it can perform. That is what a
%% creature IS, and it is not what it DOES.
%%
%% Two creatures of one architecture can make a living in completely different
%% ways, one holding a rich cell for its whole life and one wandering; two
%% different architectures can end up doing the same thing. **Every census this
%% project has run measured the genotype and called it a kind.**
%%
%% This is the idea borrowed from novelty search, and the borrowing is the IDEA
%% and not the code: characterise an individual by its behaviour, so the space
%% you are exploring is the space of ways of living rather than the space of
%% wiring diagrams. `faber-neuroevolution' uses such descriptors to SELECT.
%% Nothing here selects on them. They are an instrument.
%%
%% ==========================================================================
%% THREE AXES, AND WHY THESE THREE
%% ==========================================================================
%%
%%   TROPHIC    what share of everything it ever ate came from other creatures
%%              rather than from the ground. Zero is a pure grazer and a hundred
%%              is a pure predator, and NOTHING IN THE PHYSICS NAMES EITHER: this
%%              is counted afterwards from where the energy actually came from,
%%              which is the same discipline `from_creatures_pct' already uses.
%%
%%   MOBILITY   what share of its life it spent moving. Standing still costs
%%              nothing and moving costs the fare, so this is the sessile-to-
%%              roaming axis and it is the oldest open question in this world:
%%              a creature that never moves IS a plant, and nothing declares one.
%%
%%   DISPERSAL  how far it got from the cell it was born in. Distinct from
%%              mobility: a creature can move every tick and go nowhere, which is
%%              foraging within a patch, or move rarely and travel, which is
%%              dispersal. The two come apart and the pair says which.
%%
%% All three are ratios or distances, so a creature that has lived one tick and a
%% creature that has lived a thousand are comparable, and none of them is a trait
%% the creature inherited. `uptake' is a trait and is deliberately NOT here: what
%% a gut can absorb is structure, what it did absorb is behaviour.
-module(behaviour).

-export([of_creature/2, cell/2, axes/0, bins/0, describe/1]).

%% How many buckets each axis is cut into. Five is enough to tell a grazer from a
%% predator from something in between, and small enough that the whole space is
%% 125 cells, which a world of seventy creatures can actually explore.
-define(BINS, 5).

-type descriptor() :: {0..4, 0..4, 0..4}.
-export_type([descriptor/0]).

-spec bins() -> pos_integer().
bins() -> ?BINS.

-spec axes() -> [atom()].
axes() -> [trophic, mobility, dispersal].

%% @doc A creature's descriptor, as three bin indexes.
%%
%% A NEWBORN HAS DONE NOTHING AND SAYS SO. Age zero divides nothing by nothing,
%% and the honest answer is the origin cell of the space rather than a guess: it
%% has eaten nothing, moved nowhere and travelled no distance, which is exactly
%% bin zero on all three axes and is true rather than merely convenient.
-spec of_creature(map(), non_neg_integer()) -> descriptor().
of_creature(C, Radius) ->
    {bin(trophic(C)), bin(mobility(C)), bin(dispersal(C, Radius))}.

%% Share of intake taken from other creatures, as a percentage.
trophic(#{from_ground := G, from_creatures := F}) -> share(F, G + F).

%% Share of ticks alive spent moving.
mobility(#{moved := M, age := Age}) -> share(M, Age).

%% Distance from birthplace as a share of how far it COULD have got, which is the
%% board's own radius. Scaled that way so the axis means the same thing on a
%% small island and a large one.
dispersal(#{at := At, origin := From}, Radius) ->
    share(hex:distance(At, From), Radius).

share(_Part, 0) -> 0;
share(Part, Whole) -> min(100, Part * 100 div Whole).

%% Bin boundaries are even: 0-19, 20-39, 40-59, 60-79, 80-100. Even because
%% nothing is known about where the interesting values are, and a bin scheme
%% chosen to make a result look tidy is the shape of `I.3'.
bin(Pct) -> min(?BINS - 1, Pct * ?BINS div 101).

%% @doc A descriptor as one integer, so an archive can key on it and a fact can
%% carry it. `T * 25 + M * 5 + D', which is the base-5 reading of the triple.
-spec cell(map(), non_neg_integer()) -> non_neg_integer().
cell(C, Radius) ->
    {T, M, D} = of_creature(C, Radius),
    T * ?BINS * ?BINS + M * ?BINS + D.

%% @doc A cell index back to words, for a page that has to say what a corner of
%% the space means. Exported to be tested: an index that decodes to the wrong
%% description is `I.6' with a legend attached.
-spec describe(non_neg_integer()) -> binary().
describe(Cell) ->
    T = Cell div (?BINS * ?BINS),
    M = (Cell div ?BINS) rem ?BINS,
    D = Cell rem ?BINS,
    <<(eats(T))/binary, ", ", (moves(M))/binary, ", ", (travels(D))/binary>>.

eats(0) -> <<"grazes">>;
eats(1) -> <<"mostly grazes">>;
eats(2) -> <<"eats both">>;
eats(3) -> <<"mostly hunts">>;
eats(_4) -> <<"hunts">>.

moves(0) -> <<"sessile">>;
moves(1) -> <<"seldom moves">>;
moves(2) -> <<"moves half the time">>;
moves(3) -> <<"usually moving">>;
moves(_4) -> <<"always moving">>.

travels(0) -> <<"stays where it was born">>;
travels(1) -> <<"drifts">>;
travels(2) -> <<"ranges">>;
travels(3) -> <<"travels far">>;
travels(_4) -> <<"crosses the island">>.
