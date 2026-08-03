%% @doc Two parents into one child. PURE.
%%
%% ==========================================================================
%% WHY THIS EXISTS: A DISCOVERY IN ONE LINE COULD NEVER REACH ANOTHER
%% ==========================================================================
%%
%% Every birth in worlds 1 to 19 was a clone with small mutations. One parent,
%% one child. That has a consequence nothing in the economy could fix: **a good
%% sensor invented in one family and a good brain invented in another can never
%% meet.** Each family has to reinvent the other's discovery from scratch, and
%% since every line in a finite asexual population coalesces to one ancestor
%% (`G.1', Kingman 1982), whichever line wins takes its own accidents with it and
%% every other line's discoveries are simply lost.
%%
%% That is Hill-Robertson interference, and it is the standard answer to why sex
%% is worth its cost. This world had the interference and no answer to it.
%%
%% ==========================================================================
%% WHAT A SENSOR IS FOR THE PURPOSES OF INHERITANCE
%% ==========================================================================
%%
%% THE UNIT THAT TRAVELS IS A SENSOR TOGETHER WITH THE WEIGHTS THAT READ IT, and
%% getting that wrong is the one bug in this file that would not crash. A body is
%% a list and every weight vector in the brain is indexed by position in that
%% list, so taking a sensor from one parent and a weight column from the other
%% produces a creature that pays for measuring the ground and values the reading
%% as though it were a scent. It would forage badly for reasons no test would
%% name. `brain.erl' says the same thing about mutation and calls it the main
%% engineering risk of world 2; recombination is that risk with two genomes.
%%
%% So sensors are aligned by `{Field, Rank}': the second `ground' sensor in one
%% parent is the same organ as the second `ground' sensor in the other. Rank
%% rather than position, because position is an accident of the order mutations
%% happened to arrive in. Nothing here needs innovation numbers, which is what
%% NEAT uses to solve this problem, because a field is a name the physics already
%% supplies and there are only four of them.
%%
%% ==========================================================================
%% A WEIGHT FOR AN ORGAN YOU DO NOT HAVE IS ZERO, NOT RANDOM
%% ==========================================================================
%%
%% When the child takes a sensor from one parent and a weight vector from the
%% other, the second parent has no weight for an organ it never carried. It
%% contributes ZERO, which is exactly the rule `brain:follow_body/2' already uses
%% when mutation grows a new sensor, and for the reason stated there: a random
%% weight makes the new organ a large behavioural jump in an arbitrary direction,
%% which is resampling rather than inheritance. At zero the child begins by
%% ignoring what it can newly perceive and drift decides whether to attend to it.
%%
%% ==========================================================================
%% WHAT IS NOT HERE
%% ==========================================================================
%%
%% NO COST, AND THEREFORE NO NEW CONSTANT. The partner gives genes and no energy;
%% the breeding parent still pays half its store exactly as before. That makes
%% this an experiment about whether RECOMBINATION helps, and not about whether
%% sex is worth a price somebody chose.
%%
%% NO PAIR BOND, NO CONSENT, NO SEXES. A partner is whoever is in reach. Adding
%% mate choice would be adding a second experiment to this one.
-module(outcross).

-export([traits/4, ranked/1]).

%% @doc One child's heritable traits from two parents.
%%
%% Everything is drawn in a FIXED ORDER off the given RNG state: fields in
%% `body:fields/0' order, ranks ascending, hidden nodes by index, purposes in
%% `brain:purposes/0' order. No map is ever iterated. `G.6' is what happens when
%% one is: the world stopped being a pure function of its seed for nineteen
%% worlds because two folds took their order from a map.
-spec traits(map(), map(), map(), rand:state()) -> {map(), rand:state()}.
traits(Mother, Father, Econ, Rng0) ->
    A = ranked(maps:get(body, Mother)),
    B = ranked(maps:get(body, Father)),
    {Slots0, Rng1} = pick_sensors(keys(A, B), A, B, [], Rng0),
    Slots = lists:sublist(Slots0, maps:get(max_sensors, Econ)),
    {Brain, Rng2} = brains(Mother, Father, Slots, A, B, Econ, Rng1),
    {Tag, Rng3} = either(maps:get(scent, Mother), maps:get(scent, Father), Rng2),
    {Rate, Rng4} = either(maps:get(uptake, Mother), maps:get(uptake, Father), Rng3),
    {Mouth, Rng5} = either(maps:get(mouth, Mother), maps:get(mouth, Father), Rng4),
    {#{body => [{F, R} || {F, _Rank, R} <- Slots], brain => Brain,
       scent => Tag, uptake => Rate, mouth => Mouth}, Rng5}.

%% @doc A body as `#{{Field, Rank} => {Position, Reach}}'.
%%
%% Exported to be tested, because every alignment in this file is done through it
%% and "the second ground sensor in one parent is the second ground sensor in the
%% other" is the whole claim recombination rests on.
-spec ranked(body:body()) -> #{{body:field(), non_neg_integer()} =>
                                   {pos_integer(), non_neg_integer()}}.
ranked(Body) -> ranked(Body, 1, #{}, #{}).

ranked([], _Pos, Map, _Ranks) -> Map;
ranked([{F, R} | Rest], Pos, Map, Ranks) ->
    Rank = maps:get(F, Ranks, 0),
    ranked(Rest, Pos + 1, Map#{{F, Rank} => {Pos, R}}, Ranks#{F => Rank + 1}).

%% Every organ either parent carries, in one canonical order. Sorted rather than
%% taken from a map's keys, for `G.6'.
keys(A, B) -> lists:usort(maps:keys(A) ++ maps:keys(B)).

%% ==========================================================================
%% Which sensors the child gets
%% ==========================================================================
%%
%% CARRIED BY BOTH: take one at random, which is the reach that travels since the
%% organ itself is agreed on.
%%
%% CARRIED BY ONE: a coin. Not always kept, because always keeping would make
%% every child the union of its parents and bodies would only ever grow; not
%% always dropped, because then nothing new could ever spread. A coin is the only
%% choice here that adds no constant and no direction.
pick_sensors([], _A, _B, Acc, Rng) -> {lists:reverse(Acc), Rng};
pick_sensors([Key | Rest], A, B, Acc, Rng0) ->
    {Kept, Rng1} = one_sensor(Key, maps:get(Key, A, absent),
                              maps:get(Key, B, absent), Rng0),
    pick_sensors(Rest, A, B, keep(Kept, Acc), Rng1).

one_sensor({F, Rank}, {_PosA, Ra}, {_PosB, Rb}, Rng0) ->
    {Which, Rng1} = coin(Rng0),
    {{F, Rank, reach(Which, Ra, Rb)}, Rng1};
one_sensor({F, Rank}, {_Pos, R}, absent, Rng0) ->
    maybe_keep({F, Rank, R}, Rng0);
one_sensor({F, Rank}, absent, {_Pos, R}, Rng0) ->
    maybe_keep({F, Rank, R}, Rng0).

reach(mother, Ra, _Rb) -> Ra;
reach(father, _Ra, Rb) -> Rb.

maybe_keep(Slot, Rng0) -> kept(coin(Rng0), Slot).

kept({mother, Rng}, Slot) -> {Slot, Rng};
kept({father, Rng}, _Slot) -> {dropped, Rng}.

keep(dropped, Acc) -> Acc;
keep(Slot, Acc) -> [Slot | Acc].

%% ==========================================================================
%% The brain, which has to follow the body exactly
%% ==========================================================================
brains(Mother, Father, Slots, A, B, Econ, Rng0) ->
    Ma = maps:get(brain, Mother),
    Fa = maps:get(brain, Father),
    Ha = maps:get(hidden, Ma),
    Hb = maps:get(hidden, Fa),
    Wanted = min(max(length(Ha), length(Hb)), maps:get(max_hidden, Econ)),
    {Nodes, Rng1} = pick_nodes(1, Wanted, Ha, Hb, [], Rng0),
    Hidden = [remap(Row, Slots, side(Side, A, B)) || {Row, Side, _I} <- Nodes],
    %% ⚠ THE ORIGINAL INDEX TRAVELS WITH THE NODE. A node may be dropped, so the
    %% child's third node can be a parent's fourth, and an output's weight for it
    %% lives at the parent's index and not at the child's. Reading the output
    %% vector at the child's position would silently pair every weight after a
    %% drop with the wrong node: the same off-by-one family as `follow_body', and
    %% the same absence of a crash.
    Sides = [{Side, I} || {_Row, Side, I} <- Nodes],
    {Outputs, Rng2} = pick_outputs(brain:purposes(), Ma, Fa, Slots, A, B, Sides,
                                   #{}, Rng1),
    {#{hidden => Hidden, outputs => Outputs}, Rng2}.

side(mother, A, _B) -> A;
side(father, _A, B) -> B.

%% A HIDDEN NODE HAS NO NAME, so it is aligned by index and nothing else. Unlike a
%% sensor there is no field to match on: node 2 in one brain computes whatever
%% that lineage's drift made it compute, and node 2 in the other computes
%% something unrelated. **That is a real limit on how much this can recombine**
%% and it is worth stating rather than papering over: perception recombines by
%% organ, computation only by position.
pick_nodes(I, Wanted, _Ha, _Hb, Acc, Rng) when I > Wanted ->
    {lists:reverse(Acc), Rng};
pick_nodes(I, Wanted, Ha, Hb, Acc, Rng0) ->
    {Node, Rng1} = one_node(I, nth(I, Ha), nth(I, Hb), Rng0),
    pick_nodes(I + 1, Wanted, Ha, Hb, keep(Node, Acc), Rng1).

one_node(_I, absent, absent, Rng) -> {dropped, Rng};
one_node(I, RowA, absent, Rng0) -> kept(coin(Rng0), {RowA, mother, I});
one_node(I, absent, RowB, Rng0) -> kept(coin(Rng0), {RowB, father, I});
one_node(I, RowA, RowB, Rng0) -> chosen(coin(Rng0), RowA, RowB, I).

chosen({mother, Rng}, RowA, _RowB, I) -> {{RowA, mother, I}, Rng};
chosen({father, Rng}, _RowA, RowB, I) -> {{RowB, father, I}, Rng}.

%% ==========================================================================
%% What the child can do
%% ==========================================================================
%%
%% AN ABSENT OUTPUT IS A CREATURE THAT NEVER DOES THAT THING, which `world.erl'
%% enforces and is not the same as a weak one. So a purpose only one parent
%% carries is a coin, exactly like a sensor only one parent carries: the ability
%% to eat can spread from the parent that has it, and can also fail to.
pick_outputs([], _Ma, _Fa, _Slots, _A, _B, _Sides, Acc, Rng) -> {Acc, Rng};
pick_outputs([P | Rest], Ma, Fa, Slots, A, B, Sides, Acc, Rng0) ->
    {Side, Rng1} = one_output(maps:get(P, outputs_of(Ma), absent),
                              maps:get(P, outputs_of(Fa), absent), Rng0),
    pick_outputs(Rest, Ma, Fa, Slots, A, B, Sides,
                 attach(Side, P, Ma, Fa, Slots, A, B, Sides, Acc), Rng1).

one_output(absent, absent, Rng) -> {dropped, Rng};
one_output(_O, absent, Rng0) -> sided(coin(Rng0), mother);
one_output(absent, _O, Rng0) -> sided(coin(Rng0), father);
one_output(_Oa, _Ob, Rng0) -> coin(Rng0).

sided({mother, Rng}, Side) -> {Side, Rng};
sided({father, Rng}, _Side) -> {dropped, Rng}.

attach(dropped, _P, _Ma, _Fa, _Slots, _A, _B, _Sides, Acc) -> Acc;
attach(Side, P, Ma, Fa, Slots, A, B, Sides, Acc) ->
    #{inputs := Ins} = maps:get(P, outputs_of(side(Side, Ma, Fa))),
    Acc#{P => #{inputs => remap(Ins, Slots, side(Side, A, B)),
                hidden => follow_nodes(P, Ma, Fa, Sides)}}.

outputs_of(#{outputs := Os}) -> Os.

%% ⚠ A HIDDEN NODE BRINGS ITS OUTGOING WIRING WITH IT, exactly as a sensor brings
%% its incoming wiring. This is the same principle as the whole file and it took
%% two wrong attempts to see it.
%%
%% The weight an output places on the child's node i is taken from THE PARENT
%% THAT SUPPLIED NODE i, at that parent's own index for it, and not from the
%% parent the output came from. A node and the weights that read it are one unit,
%% because a node's value is entirely defined by what reads it: a node nobody
%% weights is a node that does nothing.
%%
%% THE TWO REJECTED RULES AND WHY, because both look reasonable:
%%
%%   Keep the output's own weight positionally. Node 2 in one brain computes
%%   whatever that lineage's drift made it compute and node 2 in the other
%%   computes something unrelated, so this applies a weight fitted to one
%%   quantity to a different quantity. Silent, and exactly the misalignment this
%%   module exists to avoid.
%%
%%   Zero the weight when node and output came from different parents. Defensible
%%   on the "a foreign organ arrives unattended" rule, and it fails a test with
%%   two IDENTICAL parents, where a foreign node is literally the same node. It
%%   would have zeroed about half of every outcrossed brain's output wiring, and
%%   since hidden nodes are already carried by well under one creature in two,
%%   world 20 would have measured recombination destroying computation when what
%%   was destroying it was this function.
%%
%% Zero only when the supplying parent had no such output at all, which is the
%% genuine "it never had a weight for this" case.
follow_nodes(Purpose, Ma, Fa, Sides) ->
    [outgoing(Purpose, side(Side, Ma, Fa), I) || {Side, I} <- Sides].

outgoing(Purpose, Brain, I) ->
    weight_at(maps:get(Purpose, outputs_of(Brain), absent), I).

weight_at(absent, _I) -> 0;
weight_at(#{hidden := Hids}, I) -> zeroed(nth(I, Hids)).

zeroed(absent) -> 0;
zeroed(W) -> W.

%% ==========================================================================
%% Remapping a weight vector onto the child's body
%% ==========================================================================
%%
%% A vector belonging to one parent, indexed by that parent's sensor list, read
%% out in the child's order. The last element is the `here' weight, which every
%% vector has and no sensor owns, so it travels untouched.
remap(Vector, Slots, Owner) ->
    [weight(maps:get({F, Rank}, Owner, absent), Vector)
     || {F, Rank, _R} <- Slots] ++ [lists:last(Vector)].

weight(absent, _Vector) -> 0;
weight({Pos, _Reach}, Vector) -> lists:nth(Pos, Vector).

%% ==========================================================================
%% Bits
%% ==========================================================================
either(FromMother, FromFather, Rng0) -> taken(coin(Rng0), FromMother, FromFather).

taken({mother, Rng}, V, _W) -> {V, Rng};
taken({father, Rng}, _V, W) -> {W, Rng}.

coin(Rng0) -> tossed(rand:uniform_s(2, Rng0)).

tossed({1, Rng}) -> {mother, Rng};
tossed({2, Rng}) -> {father, Rng}.

nth(I, List) when I =< length(List) -> lists:nth(I, List);
nth(_I, _List) -> absent.
