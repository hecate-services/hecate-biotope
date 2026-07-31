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

-export([new/2, grow/2, take/2, at/2, deposit/3]).
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

%% @doc One tick of ambient supply.
-spec grow(ground(), map()) -> ground().
grow(G, Econ) ->
    Influx = maps:get(influx, Econ),
    Ceiling = maps:get(ground_ceiling, Econ),
    maps:map(fun(_H, E) -> replenish(E, Influx, Ceiling) end, G).

%% A cell already at or above the ceiling is left alone. Below it, supply is
%% added and the ceiling is the limit. So a corpse can carry a cell far above what
%% the sun would ever build, and stays there until something grazes it.
replenish(E, _Influx, Ceiling) when E >= Ceiling -> E;
replenish(E, Influx, Ceiling) -> min(Ceiling, E + Influx).

%% @doc Absorb everything in a cell, and say how much that was.
-spec take(hex:hex(), ground()) -> {non_neg_integer(), ground()}.
take(H, G) -> {maps:get(H, G, 0), G#{H => 0}}.

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
