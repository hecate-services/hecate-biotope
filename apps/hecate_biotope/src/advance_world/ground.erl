%% @doc The ground, and the energy that gathers in it. PURE.
%%
%% THERE ARE NO PLANTS. A plant is not a kind of thing, it is a way of living:
%% stay where you are and take energy from the environment around you. World 1
%% hard-coded an entity type, two constants and the permanent floor of the food
%% chain, then congratulated itself that the trophic structure fell out of one
%% rule. It fell out of a rule whose foundation had been installed by hand.
%%
%% So energy simply gathers in the ground, everywhere, and a creature absorbs
%% whatever has gathered where it stands. Whether it stays put and lives off that
%% or roams and takes what accumulated in its absence is a strategy, and nothing
%% here has an opinion about which.
%%
%% THE CEILING IS WHAT THE SUN BUILDS UP TO, NOT WHAT GROUND CAN HOLD. Ambient
%% supply stops at `ground_ceiling'. A corpse is added on top and is not pushed
%% back down, so a cell where things have died is richer than any untouched cell
%% can ever be. That one asymmetry is the whole of soil here: places become
%% different from one another BECAUSE THINGS DIED THERE, and life is what
%% differentiates the landscape rather than a terrain map somebody drew.
%%
%% NO TERRAIN IS INSTALLED, deliberately. Fixed per-cell fertility is perfectly
%% good physics and real ground does vary. The objection is that a terrain
%% GENERATOR has free parameters, and the honest criterion for setting them would
%% be something like "correlated over the distances a sensor can evolve to reach",
%% which is choosing the world's structure so that sensors pay. Emergent
%% enrichment has no such knob: its correlation length is whatever the
%% population's own spatial structure produces, which nobody picked.
%%
%% EVERY CELL IS HELD EXPLICITLY rather than derived from a last-drained tick.
%% The lazy form is tempting and about four times cheaper, but a deposit landing
%% on an untouched cell has to invent a drain time to sit on top of, and the
%% arithmetic that follows is the kind nobody checks. A map of a few thousand
%% integers rebuilt once a tick is not what makes this world expensive; the
%% creatures are.
-module(ground).

-export([new/2, grow/2, draw/3, at/2, deposit/3, sustainable/1]).
-export([total/1, within/4, spread/1]).

-type ground() :: #{hex:hex() => non_neg_integer()}.
-export_type([ground/0]).

%% @doc A virgin world: every cell full.
%%
%% Full rather than empty because nothing has drained it yet, which makes the
%% opening of a run a COLONISATION of a standing larder rather than an
%% equilibrium. That transient is real and must not be read as the answer.
-spec new(non_neg_integer(), map()) -> ground().
new(Radius, Econ) ->
    Ceiling = maps:get(ground_ceiling, Econ),
    maps:from_keys(hex:disc(Radius), Ceiling).

%% @doc One tick of recovery.
%%
%% ==========================================================================
%% RECOVERY DEPENDS ON WHAT IS LEFT, AND THAT IS THE WHOLE OF WORLD 3
%% ==========================================================================
%%
%% World 2 added a fixed amount to every cell every tick, so a cell stripped a
%% thousand times refilled exactly as fast as one never touched. A resource with
%% no memory, and it made movement arithmetically impossible for EVERY parameter
%% choice:
%%
%%   sessility is viable exactly when income exceeds metabolism
%%   equilibrium density is then income over metabolism, which is above one
%%   so every cell is grazed more than once a tick
%%   so a mover never finds more than a stayer already has, and nets minus the fare
%%
%% Every seed of world 2 ended one hundred percent sessile, with no sensors and
%% no hidden nodes. Not a tuning failure: a uniform resource that renews in place
%% IS the resource that selects for sitting still, which is why plants do not
%% move.
%%
%% Stored energy is biomass and biomass regrows in proportion to itself. A rate
%% independent of stock is the unphysical special case, and it is the one world 2
%% used. Every standard renewable-resource model, in fisheries and forestry
%% alike, makes recovery depend on the standing stock.
%%
%% WHAT THIS BREAKS is step two. Total productivity is no longer fixed by the
%% rules: a population that strips everything holds the board near nothing and
%% gets only the seed rate, while one that grazes lightly holds stock where the
%% curve is steepest. THE POPULATION'S OWN BEHAVIOUR NOW SETS HOW MUCH THERE IS
%% TO GO ROUND, which is what the previous world could not express.
%%
%% It also gives the Marginal Value Theorem something to bite on for the first
%% time. World 2 had no diminishing returns within a cell, so there was no
%% leaving rule for anything to discover.
%%
%% WORLD 14 FIXED THE OTHER HALF. World 3 made recovery depend on the cell's own
%% stock and left the FLOOR a global constant, while saying two paragraphs below
%% that the floor is recolonisation from what is around a patch. It was not. It
%% was the same number everywhere, so a desert cell in the middle of a grazed-out
%% region refilled exactly as fast as one beside untouched ground, and the
%% resource stayed uniform in the one term that matters once a board is grazed
%% down. That is the term the sessile regime lives on.
%%
%% EVERY CELL GROWS FROM THE SAME PRIOR STATE, so the order they are visited in
%% cannot matter. `maps:map/2' hands the fun the original values and the closure
%% reads the original map, which is what makes this simultaneous rather than a
%% sweep across the board.
-spec grow(ground(), map()) -> ground().
grow(G, Econ) ->
    Pct = maps:get(ground_growth_pct, Econ),
    Rate = maps:get(recolonise_pct, Econ),
    Ceiling = maps:get(ground_ceiling, Econ),
    maps:map(fun(H, E) -> recover(E, colonise(H, G, Rate), Pct, Ceiling) end, G).

%% WHAT A BARE PATCH GETS FROM WHAT IS AROUND IT, which is what the floor was
%% always described as. A share of the mean stock of the neighbours, so a patch
%% beside untouched ground comes back and one in the middle of a desert does not.
%%
%% THE NEIGHBOURS ARE THE ONES THAT EXIST. The disc is the whole world and beyond
%% its rim is nothing rather than bare ground, so counting absent cells as zero
%% would make the rim permanently poor: an edge artefact wearing the costume of a
%% gradient, and one a sensor could evolve to read.
colonise(H, G, Rate) ->
    Around = [maps:get(N, G) || N <- hex:neighbours(H), is_map_key(N, G)],
    mean(Around) * Rate div 100.

mean([]) -> 0;
mean(L) -> lists:sum(L) div length(L).

%% A cell at or above the ceiling is left alone, so a corpse can carry one far
%% above anything sunlight builds and it stays there until something grazes it.
%%
%% THE FLOOR IS A FLOOR AND NOT AN ADDITION. Bare ground has nothing to compound
%% from, so pure proportional growth would leave a stripped cell dead forever and
%% the board would go sterile one cell at a time. Since world 14 a stripped cell
%% CAN stay dead, if everything around it is stripped too, and that is the point:
%% being common now costs something.
recover(E, _Floor, _Pct, Ceiling) when E >= Ceiling -> E;
recover(E, Floor, Pct, Ceiling) ->
    min(Ceiling, E + max(Floor, E * Pct div 100)).

%% @doc Draw up to `Rate' from a cell, and say how much that was.
%%
%% WHAT IS NOT TAKEN STAYS, which is world 4's whole change. World 3 took
%% everything, so every grazed cell sat at zero and stock-dependent recovery
%% collapsed to its floor everywhere: the mechanism never fired in a populated
%% world at all.
-spec draw(hex:hex(), non_neg_integer(), ground()) ->
          {non_neg_integer(), ground()}.
draw(H, Rate, G) ->
    Stock = maps:get(H, G, 0),
    Taken = min(Rate, Stock),
    {Taken, G#{H => Stock - Taken}}.

%% @doc The most that can be taken from a cell every tick without driving its
%% standing stock to nothing.
%%
%% THE LINE BETWEEN THE TWO LIVINGS, and it is derived from the growth curve
%% rather than chosen. A lineage feeding below it holds its cell indefinitely and
%% can stay; one feeding above it strips the cell, watches its income collapse to
%% the bare floor, and must move or starve. Reported so that both sides of the
%% line are known to be reachable, never to arrange which side wins.
-spec sustainable(map()) -> non_neg_integer().
sustainable(Econ) ->
    Ceiling = maps:get(ground_ceiling, Econ),
    lists:max([yield(Stock, Econ) || Stock <- lists:seq(0, Ceiling)]).

%% THE BEST CASE A CELL CAN BE IN, which is what a peak of the curve has always
%% meant here. Since world 14 the floor is a share of what the neighbours hold,
%% so the most a cell can get is the share of a full neighbourhood: the line this
%% derives is the one that is reachable SOMEWHERE, not everywhere, and a cell in
%% the middle of a desert is now below it.
yield(Stock, Econ) ->
    Ceiling = maps:get(ground_ceiling, Econ),
    Best = Ceiling * maps:get(recolonise_pct, Econ) div 100,
    min(Ceiling - Stock,
        max(Best, Stock * maps:get(ground_growth_pct, Econ) div 100)).

%% @doc Return energy to a cell. What a corpse does.
-spec deposit(hex:hex(), non_neg_integer(), ground()) -> ground().
deposit(_H, 0, G) -> G;
deposit(H, Amount, G) -> G#{H => maps:get(H, G, 0) + Amount}.

-spec at(hex:hex(), ground()) -> non_neg_integer().
at(H, G) -> maps:get(H, G, 0).

%% @doc Everything gathered within Range of a cell. What a sensor reads.
-spec within(hex:hex(), non_neg_integer(), non_neg_integer(), ground()) ->
          non_neg_integer().
within(At, Range, Radius, G) ->
    lists:sum([maps:get(H, G, 0) || H <- hex:within(At, Range, Radius)]).

%% @doc Every unit of energy lying in the ground. One half of the world's books.
-spec total(ground()) -> non_neg_integer().
total(G) -> lists:sum(maps:values(G)).

%% @doc How unevenly the ground holds energy: the percentage of it lying in the
%% richest tenth of cells.
%%
%% TEN MEANS FLAT and anything above it means the landscape has structure. This
%% is the number that answers whether places have become different from each
%% other, and a flat answer is as reportable as any other: it would say the
%% deposit rule conserves energy without structuring anything.
-spec spread(ground()) -> non_neg_integer().
spread(G) -> concentration(lists:reverse(lists:sort(maps:values(G)))).

concentration([]) -> 0;
concentration(Sorted) ->
    Richest = lists:sublist(Sorted, max(1, length(Sorted) div 10)),
    share(lists:sum(Sorted), lists:sum(Richest)).

share(0, _Top) -> 0;
share(Total, Top) -> Top * 100 div Total.
