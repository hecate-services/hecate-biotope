%% @doc A creature crossing between islands, and the first law across a sea.
-module(migrant_tests).

-include_lib("eunit/include/eunit.hrl").

%%==============================================================================
%% The crossing conserves
%%==============================================================================

%% ⚠ THE TEST THIS WHOLE SLICE EXISTS FOR.
%%
%% For twenty-four worlds every joule was in the ground, in a store, or in a
%% structure, and that was asserted on one island. A migrant is the first thing
%% that can carry energy somewhere its island cannot see.
%%
%% **Each island's own books would keep balancing whether the creature arrived,
%% arrived twice, or never arrived at all.** The sender simply has less; the
%% receiver simply has more. Nothing is inconsistent anywhere and the archipelago
%% has quietly gained or lost a creature's worth of energy.
%%
%% So the sum is taken across BOTH, with the receipts included.
a_crossing_neither_creates_nor_destroys_energy_test() ->
    {From, To} = two_islands(),
    Before = archipelago([From, To]),

    [Id | _] = lists:sort(maps:keys(world:creatures(From))),
    {ok, Packed, From1} = world:depart(Id, From),
    %% ⚠ IN FLIGHT: the sender has already let go and the receiver has not taken
    %% it. The books must balance HERE too, or a crossing that fails midway
    %% destroys whatever was in the air.
    ?assertEqual(Before, archipelago([From1, To])),

    {ok, To1} = world:arrive(Packed, To),
    ?assertEqual(Before, archipelago([From1, To1])).

%% AND THE ISLANDS REALLY DID CHANGE, or the test above passes on a world where
%% nothing happened.
a_crossing_moves_a_creature_and_its_energy_test() ->
    {From, To} = two_islands(),
    [Id | _] = lists:sort(maps:keys(world:creatures(From))),
    Was = maps:get(Id, world:creatures(From)),

    {ok, Packed, From1} = world:depart(Id, From),
    {ok, To1} = world:arrive(Packed, To),

    ?assertEqual(world:population(From) - 1, world:population(From1)),
    ?assertEqual(world:population(To) + 1, world:population(To1)),

    Carried = maps:get(energy, Was) + maps:get(structure, Was),
    #{departed := Out} = world:snapshot(From1),
    #{arrived := In} = world:snapshot(To1),
    ?assertEqual(Carried, Out),
    ?assertEqual(Carried, In).

%% ⚠ DELIVERED TWICE IS FREE ENERGY, AND THE ANSWER IS TO REFUSE IT.
%%
%% A retry is a NORMAL event on a mesh: an acknowledgement can be lost after the
%% creature has already landed, and the sender is then obliged to try again. So
%% at-most-once cannot be a hope about the transport, it has to be enforced at
%% the destination, and it is: a crossing this island has already accepted is
%% declined.
%%
%% ⚠⚠ THE FIRST VERSION OF THIS TEST TRIED TO DETECT THE DAMAGE INSTEAD, and
%% could not. The receipts rise by exactly what the stores rise by, so the books
%% balance just as neatly for a creature admitted twice as for one admitted once.
%% A guard that cannot fail is not a guard, and the fix was to make the second
%% delivery impossible rather than visible.
a_migrant_delivered_twice_is_refused_test() ->
    {From, To} = two_islands(),
    Before = archipelago([From, To]),
    [Id | _] = lists:sort(maps:keys(world:creatures(From))),

    {ok, Packed, From1} = world:depart(Id, From),
    {ok, To1} = world:arrive(Packed, To),

    ?assertEqual({error, already_arrived}, world:arrive(Packed, To1)),
    ?assertEqual(Before, archipelago([From1, To1])),
    ?assertEqual(world:population(To) + 1, world:population(To1)).

%% AND A RETRY IS THE SAME BYTES, which is the whole reason the crossing id
%% belongs to the departure. A sender that packed the creature afresh on each
%% attempt would mint a new id, defeat the guard, and look perfectly correct.
two_departures_are_two_crossings_test() ->
    {From, _To} = two_islands(),
    [A, B | _] = lists:sort(maps:keys(world:creatures(From))),

    {ok, One, From1} = world:depart(A, From),
    {ok, Two, _From2} = world:depart(B, From1),

    ?assertNotEqual(maps:get(crossing, One), maps:get(crossing, Two)).

%% AND A DEPARTURE IS NOT A DEATH. An island that exports well and one that dies
%% well are opposite findings, and folding one into the other would make them
%% indistinguishable in every column.
leaving_is_not_dying_test() ->
    {From, _To} = two_islands(),
    #{starved := S0, consumed := C0, aged_out := A0, parched := P0} =
        world:snapshot(From),

    [Id | _] = lists:sort(maps:keys(world:creatures(From))),
    {ok, _Packed, From1} = world:depart(Id, From),

    #{starved := S1, consumed := C1, aged_out := A1, parched := P1,
      ground_total := Ground} = world:snapshot(From1),
    #{ground_total := Was} = world:snapshot(From),

    ?assertEqual({S0, C0, A0, P0}, {S1, C1, A1, P1}),
    %% Nor does it leave a body behind: it took itself with it.
    ?assertEqual(Was, Ground).

departing_a_creature_that_is_not_there_is_refused_test() ->
    {From, _To} = two_islands(),
    ?assertEqual({error, no_such_creature}, world:depart(999999, From)).

%%==============================================================================
%% What travels
%%==============================================================================

%% A creature is its body, its brain and what it is carrying. It is NOT its id or
%% its cell: an id is a local counter that two islands both hand out, and a cell
%% is a coordinate in one island's own disc.
a_creature_survives_the_round_trip_test() ->
    {From, To} = two_islands(),
    [Id | _] = lists:sort(maps:keys(world:creatures(From))),
    Was = maps:get(Id, world:creatures(From)),

    {ok, Packed, _From1} = world:depart(Id, From),
    {ok, To1} = world:arrive(Packed, To),
    Now = newest(To1),

    lists:foreach(fun(K) -> ?assertEqual(maps:get(K, Was), maps:get(K, Now)) end,
                  [body, brain, scent, uptake, mouth, energy, structure, water,
                   owed, memory, age, lineage, generation, moved, bred,
                   from_ground, from_creatures]).

%% AND IT ARRIVES AN ORPHAN, which is true. `parent' is a local id and on the far
%% shore it would name a stranger; `lineage' and `generation' are what descent
%% actually is and they cross intact, asserted above.
a_migrant_arrives_without_a_parent_test() ->
    {From, To} = two_islands(),
    [Id | _] = lists:sort(maps:keys(world:creatures(From))),
    {ok, Packed, _} = world:depart(Id, From),
    {ok, To1} = world:arrive(Packed, To),

    ?assertEqual(none, maps:get(parent, newest(To1))).

%% The wire rules, on the one message another node's CODE will act on.
a_packed_migrant_obeys_the_wire_rules_test() ->
    {From, _To} = two_islands(),
    [Id | _] = lists:sort(maps:keys(world:creatures(From))),
    {ok, P, _} = world:depart(Id, From),

    ?assert(lists:all(fun is_atom/1, maps:keys(P))),
    ?assertEqual([], [V || V <- maps:values(P), is_tuple(V)]),
    ?assertEqual([], [V || V <- maps:values(P), is_float(V)]),
    ?assertEqual([], [L || L <- maps:values(P), is_list(L),
                           not lists:all(fun is_integer/1, L)]).

%%==============================================================================
%% Validated, never trusted
%%==============================================================================

%% ⚠ THIS ARRIVES FROM A NODE ANYBODY MAY BE RUNNING.
%%
%% `brain:fire/3' zips a weight row against an input vector, so a body and a
%% brain that disagree on width do not draw oddly, they CRASH THE RECEIVING
%% ISLAND'S TICK. Every one of these is refused rather than admitted and left to
%% detonate on the next tick.
a_migrant_that_does_not_fit_is_refused_test() ->
    {From, To} = two_islands(),
    [Id | _] = lists:sort(maps:keys(world:creatures(From))),
    {ok, Good, _} = world:depart(Id, From),

    %% A sensor added without widening any row it is read by.
    Wider = Good#{body => maps:get(body, Good) ++ [0, 1]},
    ?assertEqual({error, does_not_fit}, world:arrive(Wider, To)),

    %% A field code that indexes past `body:fields/0'.
    ?assertEqual({error, bad_body}, world:arrive(Good#{body => [99, 1]}, To)),

    %% A row that claims to be longer than what follows it.
    ?assertEqual({error, bad_hidden}, world:arrive(Good#{hidden => [7, 1]}, To)),

    %% A body of one number: a field with no range.
    ?assertEqual({error, bad_body}, world:arrive(Good#{body => [0]}, To)).

a_migrant_with_impossible_numbers_is_refused_test() ->
    {From, To} = two_islands(),
    [Id | _] = lists:sort(maps:keys(world:creatures(From))),
    {ok, Good, _} = world:depart(Id, From),

    %% Negative store, which would be energy from nowhere on arrival.
    ?assertEqual({error, does_not_fit}, world:arrive(Good#{energy => -500}, To)),
    %% A body of nothing is not a creature.
    ?assertEqual({error, does_not_fit}, world:arrive(Good#{structure => 0}, To)).

a_migrant_from_another_version_is_refused_test() ->
    {From, To} = two_islands(),
    [Id | _] = lists:sort(maps:keys(world:creatures(From))),
    {ok, Good, _} = world:depart(Id, From),

    ?assertEqual({error, wrong_version},
                 world:arrive(Good#{version => migrant:version() + 1}, To)),
    ?assertEqual({error, not_a_migrant}, world:arrive(#{}, To)),
    ?assertEqual({error, missing_keys},
                 world:arrive(maps:remove(marks, Good), To)).

%% ⚠ AND A REFUSED MIGRANT CHANGES NOTHING AT ALL. An island that half-admits a
%% creature it then rejects has taken its energy onto the books without taking
%% the animal, which is the same leak in a politer form.
a_refused_migrant_leaves_the_island_untouched_test() ->
    {_From, To} = two_islands(),
    Before = world:snapshot(To),

    ?assertMatch({error, _}, world:arrive(#{version => migrant:version()}, To)),
    ?assertEqual(Before, world:snapshot(To)).

%%==============================================================================
%% Helpers
%%==============================================================================

%% Two islands with different seeds, so a creature really is crossing between
%% worlds rather than being handed back to the one it came from.
two_islands() ->
    {world:new(#{seed => 11, population => 12, radius => 4}),
     world:new(#{seed => 23, population => 12, radius => 4})}.

%% THE WHOLE ARCHIPELAGO'S ENERGY. Per island: what is in the ground, in stores
%% and in structures, plus what has been dissipated, plus what left, minus what
%% came. Summed over every island, this cannot move unless a creature was
%% duplicated or lost between them.
archipelago(Worlds) -> lists:sum([ledger(W) || W <- Worlds]).

ledger(W) ->
    #{energy_total := Stores, structure_total := Structures,
      ground_total := Ground, dissipated := Gone,
      departed := Out, arrived := In} = world:snapshot(W),
    Stores + Structures + Ground + Gone + Out - In.

newest(W) ->
    Cs = world:creatures(W),
    maps:get(lists:max(maps:keys(Cs)), Cs).
