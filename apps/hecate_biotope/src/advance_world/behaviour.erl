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
-export([portrait/3, vocabulary/0]).

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

%% ==========================================================================
%% A PORTRAIT: THE SAME CREATURE IN WORDS, AND ON MORE AXES
%% ==========================================================================
%%
%% ⚠ THIS IS NOT THE ARCHIVE AND MUST NEVER BECOME IT.
%%
%% `cell/2' is three axes and 125 cells, and that 125 is in every measurement
%% this project has made: "explored 76 of 125", "the frontier reaches zero by
%% tick 6,000". Five axes at five bins is 3,125 cells. Exploration would look
%% tiny, the frontier would never reach zero because there would always be more
%% space left, and **every comparison already recorded would become
%% incomparable**.
%%
%% So the archive keeps its three axes and a portrait may have as many as it
%% likes, because a portrait is prose and an archive is an instrument with a
%% history. Nothing bins a portrait and nothing counts them.
%%
%% ==========================================================================
%% ADJECTIVES ARE DERIVED; NOUNS ARE NOT PERMITTED
%% ==========================================================================
%%
%% Every word here comes out of a bin, so it is reproducible, testable, and
%% checkable against the figures. What a narrator may NOT do is turn them into a
%% species: "fast, greedy breeders" describes measurements and "pigs" asserts a
%% kind of thing.
%%
%% That is not fussiness. `body.erl' records why world 1 was deleted: "a world
%% whose rules contain `eye' cannot discover that seeing was worth doing." The
%% physics stayed clean. The risk now is second-order and just as real: once a
%% page says pigs, the next question anybody asks is whether the pigs are beating
%% the wolves, and there are no pigs and no wolves, there is a continuum with bins
%% drawn through it.
%%
%% ==========================================================================
%% TWO AXES A PORTRAIT HAS THAT THE ARCHIVE DOES NOT
%% ==========================================================================
%%
%%   BREEDING   what share of its ticks it spent making a child. Nothing
%%              measured this before: `born' is a world total and says nothing
%%              about who did it.
%%
%%   FEEDING    what it ACTUALLY took in per tick. The island already charts
%%              "how fast they feed" and that is `uptake', which is a heritable
%%              trait and a CAPACITY: `absorb/2' takes `min(uptake, structure)'
%%              and then only what the cell actually holds. **A creature with a
%%              large gut standing on bare ground charts as fast and eats
%%              nothing.** This is the realised rate, which is a different
%%              quantity and has never been on a page.
%% ⚠ A YOUNG CREATURE READS AS "barren, starving" AND THAT IS ITS AGE TALKING.
%%
%% A creature needs ticks to move, eat or breed, and the mean life in this world
%% is about nine. So a large share of any living population has simply not had
%% time to do anything, and describes as barren and starving because it is
%% newborn rather than because it is failing. The first live run showed exactly
%% that portrait at 36% of the island.
%%
%% No age threshold is applied here. A cutoff would be a constant nobody could
%% justify, and it would hide a true fact about a world where most creatures die
%% young. `world:snapshot/1' publishes `age_mean' beside the portrait instead, so
%% a reader can see the confound rather than have it quietly removed.
-spec portrait(map(), non_neg_integer(), pos_integer()) -> binary().
portrait(C, Radius, Ceiling) ->
    {T, M, D} = of_creature(C, Radius),
    Words = [eats(T), moves(M), travels(D), breeds(bin(breeding(C))),
             feeds(bin(feeding(C, Ceiling)))],
    join(Words).

%% A creature can start at most one child a tick, so this is the share of its
%% life spent breeding rather than a rate needing a scale.
%% No fallback clause: every creature carries `bred' and `age' from the moment it
%% is added, and a defensive clause here would be unreachable code claiming
%% otherwise. Dialyzer says so, and a creature that lacked them should crash
%% loudly rather than describe as barren.
breeding(#{bred := B, age := Age}) -> share(B, Age).

%% Against what a full cell holds, so "fast" means fast relative to the richest
%% mouthful the world offers rather than to whatever this island happens to
%% average.
feeding(#{from_ground := G, from_creatures := F, age := Age}, Ceiling) ->
    share((G + F) div max(1, Age), Ceiling).

breeds(0) -> <<"barren">>;
breeds(1) -> <<"breeds seldom">>;
breeds(2) -> <<"breeds steadily">>;
breeds(3) -> <<"breeds hard">>;
breeds(_4) -> <<"breeds constantly">>.

feeds(0) -> <<"starving">>;
feeds(1) -> <<"feeds poorly">>;
feeds(2) -> <<"feeds steadily">>;
feeds(3) -> <<"feeds well">>;
feeds(_4) -> <<"gorges">>.

join([First | Rest]) ->
    lists:foldl(fun(W, Acc) -> <<Acc/binary, ", ", W/binary>> end, First, Rest).

%% @doc Every phrase a portrait can be built from.
%%
%% EXPORTED SO THE GUARANTEE CAN BE TESTED RATHER THAN ASSERTED. The brief handed
%% to a language model is otherwise integers only, deliberately, so that there is
%% nothing in it to build an explanation out of. A portrait is the one exception,
%% and it is safe exactly because every word in it came out of a bin.
%%
%% A test checks that the phrase in a brief decomposes entirely into this list.
%% Without that, "derived adjectives" is a claim about how the code is written
%% rather than a property anything enforces.
-spec vocabulary() -> [binary()].
vocabulary() ->
    [F(N) || F <- [fun eats/1, fun moves/1, fun travels/1, fun breeds/1,
                   fun feeds/1],
             N <- lists:seq(0, ?BINS - 1)].
