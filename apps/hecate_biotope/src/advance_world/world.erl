%% @doc The biotope: plants, creatures, and the energy that moves between them.
%% PURE. No processes, no mesh, no clock, no ets.
%%
%% ==========================================================================
%% PHYSICS IS OURS TO WRITE. BIOLOGY NEVER IS.
%% ==========================================================================
%%
%% This module was rebuilt from the previous one for a single reason: it used to
%% contain biology. There were actions called `graze' and `hunt', organs called
%% `eye' and `nose', and a diet statistic that counted which of two verbs had
%% fired. A world whose rules already say "hunt" cannot discover predation, and
%% calling the result emergent is close to circular. Raf caught it and was right.
%%
%% So the rules below concern energy, space, cost, persistence and inheritance,
%% and nothing else. What eats what, what is worth measuring, and whether there
%% are roles at all are consequences to be observed, never rules to be written.
%%
%% THE ONLY DECISION A CREATURE MAKES IS WHERE TO BE. It values the seven cells
%% it can reach, its own included, and goes to the best. Everything an observer
%% might call a behaviour falls out of that one choice:
%%
%%   going where plant energy is          is grazing
%%   going where creature energy is       is predation
%%   avoiding creature energy             is fleeing
%%   staying where trails run             is ambush
%%
%% None of those words appear in this file.
%%
%% CONSUMPTION IS ONE RULE THAT DOES NOT KNOW WHAT IT IS EATING. Whatever shares
%% your cell and cannot contest you is consumed and its energy becomes yours. A
%% plant never contests. A creature contests with its energy. That single line
%% generates the whole trophic structure, and it names no trophic level.
%%
%% NOBODY MOVES FIRST. Every creature values the world as it stands at the start
%% of the tick and they all move together, so there is no turn order to confer an
%% advantage and no shuffle needed to hide one. The previous version resolved
%% creature by creature and had to randomise the order to stop old lineages
%% eating first forever; simultaneity removes the problem rather than papering
%% over it, and it removed a good deal of code with it.
%%
%% STILL NO PROCESS PER CREATURE. Purity is what lets thousands of ticks across
%% many seeds run offline in seconds, and that has already stopped a fortnight of
%% work being built on a trait that turned out not to move. A body of processes
%% is a fine RUNTIME for these rules and a poor place to discover them.
-module(world).

-export([new/0, new/1, tick/1, tick/2, snapshot/1, chart/1, defaults/0, econ_id/1]).
-export([population/1, plant_count/1, at_tick/1, alive/2]).

-type hex() :: hex:hex().
-type id() :: pos_integer().

%% Where a creature may go: its own cell and the six around it. Not a rule about
%% behaviour, a statement about how far a thing can travel in one tick.
-define(REACH, 1).

-type creature() :: #{id := id(),
                      at := hex(),
                      energy := integer(),
                      age := non_neg_integer(),
                      born := non_neg_integer(),
                      parent := id() | none,
                      %% Everything heritable.
                      breed_at := pos_integer(),
                      body := body:body(),
                      brain := brain:brain(),
                      scent := scent:tag(),
                      %% WHAT THIS CREATURE HAS ACTUALLY EATEN, by where the
                      %% energy came from. An observer's record, not a rule:
                      %% nothing in the physics reads these, and no creature is
                      %% ever treated differently for what they contain.
                      from_plants := non_neg_integer(),
                      from_creatures := non_neg_integer()}.

-type econ() :: #{plant_energy := pos_integer(),
                  regrowth_per_tick := non_neg_integer(),
                  metabolism := non_neg_integer(),
                  move_cost := non_neg_integer(),
                  sensor_rent := non_neg_integer(),
                  max_sensors := pos_integer(),
                  max_sensor_range := non_neg_integer(),
                  scent_per_tick := non_neg_integer(),
                  scent_decay := pos_integer(),
                  scent_ceiling := pos_integer(),
                  scent_mutation := pos_integer(),
                  brain_range := pos_integer(),
                  brain_mutation := non_neg_integer(),
                  body_mutation := pos_integer(),
                  breed_at := pos_integer(),
                  breed_mutation := non_neg_integer(),
                  breed_floor := pos_integer(),
                  breed_ceiling := pos_integer(),
                  start_energy := pos_integer(),
                  max_age := pos_integer(),
                  radius := non_neg_integer(),
                  max_creatures := pos_integer()}.

-record(world, {tick = 0 :: non_neg_integer(),
                econ :: econ(),
                plants = #{} :: #{hex() => true},
                %% Where something has walked and how recently, each mark
                %% carrying the signature of what left it.
                scent = #{} :: #{hex() => scent:mark()},
                creatures = #{} :: #{id() => creature()},
                next_id = 1 :: id(),
                rng :: rand:state(),
                %% Totals since the world began, never reset. A rate is
                %% recoverable from two totals and the reverse is not true.
                born = 0 :: non_neg_integer(),
                starved = 0 :: non_neg_integer(),
                aged_out = 0 :: non_neg_integer(),
                %% Deaths by being eaten, kept apart from the other two because
                %% "the population crashed" is not a finding and three causes
                %% sharing one total cannot be told apart afterwards.
                consumed = 0 :: non_neg_integer(),
                plants_eaten = 0 :: non_neg_integer(),
                births_refused = 0 :: non_neg_integer(),
                %% SENSORS GAINED AND LOST AT BIRTH, cumulatively. A census says
                %% what the population is built from NOW; these say whether that
                %% is still moving. Both climbing together is a lineage churning
                %% through body plans; both flat is a settled one, and a census
                %% alone cannot tell those apart.
                sensors_gained = 0 :: non_neg_integer(),
                sensors_lost = 0 :: non_neg_integer(),
                extinct_at = undefined :: non_neg_integer() | undefined}).

-opaque world() :: #world{}.
-export_type([world/0, creature/0, econ/0]).

%%==============================================================================
%% The economy
%%==============================================================================

%% EVERY NUMBER HERE IS SET FOR VIABILITY OR FOR SCALE, NEVER FOR AN OUTCOME.
%% See PREREGISTRATION.md for the criteria, written down before the first run.
-spec defaults() -> econ().
defaults() ->
    #{%% Where energy enters the world.
      plant_energy      => 40,
      regrowth_per_tick => 4,
      %% What it costs to exist and to act.
      metabolism        => 1,
      move_cost         => 1,
      %% What it costs to measure something. Charged per sensor per tick whether
      %% used or not, and rising with reach. This is the only force that can
      %% remove a sensor from a lineage.
      sensor_rent       => 1,
      %% Safety valves against a runaway body, not model parameters. Rent is what
      %% should bound a body; these only stop a mistuned economy making a tick
      %% cost proportional to the whole disc.
      max_sensors       => 8,
      max_sensor_range  => 4,
      %% What a moving creature leaves behind, how fast it fades, and how much
      %% one cell can hold. Scent is the only thing here that outlives the moment
      %% it was made.
      scent_per_tick    => 10,
      scent_decay       => 2,
      scent_ceiling     => 30,
      %% How fast a signature drifts. Derived from a property of the SIGNAL, with
      %% the threshold stated before looking and diet never consulted: a
      %% population must reach half the unrelated baseline of 50 in every seed,
      %% at the coarsest drift that clears it. See PREREGISTRATION.md.
      scent_mutation    => 3,
      %% How large a weight may grow, and how far it moves per birth.
      brain_range       => 8,
      brain_mutation    => 1,
      %% One birth in this many changes the body: a sensor gained, lost, or
      %% moved in reach, with the three equally likely so nothing pushes bodies
      %% to become more elaborate on their own.
      body_mutation     => 20,
      %% The founding mean breeding threshold, spread across founders.
      breed_at          => 160,
      breed_mutation    => 8,
      breed_floor       => 40,
      breed_ceiling     => 400,
      start_energy      => 80,
      max_age           => 600,
      radius            => 20,
      max_creatures     => 2000}.

%%==============================================================================
%% Making a world
%%==============================================================================

-spec new() -> world().
new() -> new(#{}).

%% Opts override the economy, plus `seed', `population', `initial_plants' and the
%% `founder_*' overrides.
-spec new(map()) -> world().
new(Opts) ->
    Econ = maps:merge(defaults(), maps:with(maps:keys(defaults()), Opts)),
    Seed = maps:get(seed, Opts, 42),
    Rng0 = rand:seed_s(exsss, {Seed, Seed, Seed}),
    Radius = maps:get(radius, Econ),
    PlantSeed = maps:get(initial_plants, Opts, hex:cells(Radius) div 3),
    {Plants, Rng1} = sow(PlantSeed, Radius, #{}, Rng0),
    populate(maps:get(population, Opts, 40), Opts,
             #world{econ = Econ, plants = Plants, rng = Rng1}).

populate(0, _Opts, W) -> W;
populate(N, Opts, #world{econ = Econ, rng = Rng0} = W) ->
    {At, Rng1} = random_cell(maps:get(radius, Econ), Rng0),
    {Traits, Rng2} = founder_traits(Econ, Opts, Rng1),
    populate(N - 1, Opts, add_creature(At, maps:get(start_energy, Econ), none,
                                       Traits, W#world{rng = Rng2})).

%% Everything heritable, drawn fresh and SPREAD. The first generation should
%% already contain every shape of creature the rules allow, so selection has
%% something to sort on tick one rather than waiting for mutation to invent it.
%%
%% Any of it may be GIVEN instead of drawn. That is not a testing hook: it is how
%% a world is founded with a known creature, which is what a control run needs
%% and what a transplanted migrant would arrive through.
founder_traits(Econ, Opts, Rng0) ->
    {BreedAt, Rng1} = founder_threshold(Econ, Rng0),
    {Body, Rng2} = given(founder_body, Opts, fun body:founder/2, Econ, Rng1),
    {Brain, Rng3} = founder_brain(maps:get(founder_brain, Opts, draw),
                                  Body, Econ, Rng2),
    {Tag, Rng4} = given(founder_scent, Opts, fun scent:founder/2, Econ, Rng3),
    {#{breed_at => BreedAt, body => Body, brain => Brain, scent => Tag}, Rng4}.

given(Key, Opts, Draw, Econ, Rng) ->
    specified(maps:get(Key, Opts, draw), Draw, Econ, Rng).

specified(draw, Draw, Econ, Rng) -> Draw(Econ, Rng);
specified(Given, _Draw, _Econ, Rng) -> {Given, Rng}.

%% A brain is sized from the body it will steer, so this one cannot be drawn
%% without knowing the body first.
founder_brain(draw, Body, Econ, Rng) ->
    brain:founder(body:sensor_count(Body), Econ, Rng);
founder_brain(Given, _Body, _Econ, Rng) ->
    {Given, Rng}.

founder_threshold(Econ, Rng0) ->
    Mean = maps:get(breed_at, Econ),
    {Draw, Rng1} = rand:uniform_s(Mean + 1, Rng0),
    {clamp(Mean div 2 + Draw - 1, Econ), Rng1}.

add_creature(At, Energy, Parent, Traits, #world{next_id = Id, creatures = Cs,
                                                tick = T, born = B} = W) ->
    C = maps:merge(#{id => Id, at => At, energy => Energy, age => 0,
                     born => T, parent => Parent,
                     from_plants => 0, from_creatures => 0},
                   Traits),
    W#world{next_id = Id + 1, creatures = Cs#{Id => C}, born = B + 1}.

%%==============================================================================
%% The tick
%%==============================================================================

-spec tick(world()) -> world().
tick(W) -> tick(W, 1).

%% EIGHT PHASES IN A FIXED ORDER, each one a rule of the world. Charging before
%% moving means a creature that cannot afford to exist does not get a free step.
%% Moving before consuming means arriving somewhere feeds you this tick. Fading
%% last means a trail laid this tick is at full strength when the next begins.
-spec tick(world(), non_neg_integer()) -> world().
tick(W, 0) -> W;
tick(W, N) ->
    W1 = charge(W),
    W2 = move_all(W1),
    W3 = consume(W2),
    W4 = breed(W3),
    W5 = reap(W4),
    W6 = regrow(W5),
    W7 = fade(W6),
    tick(W7#world{tick = W7#world.tick + 1}, N - 1).

%% Existing costs energy, and so does carrying the means to measure anything.
%% THIS IS WHERE CAPABILITY IS PAID FOR: a sensor that is not earning its rent
%% makes its owner strictly poorer than a neighbour without one.
charge(#world{creatures = Cs, econ = Econ} = W) ->
    Base = maps:get(metabolism, Econ),
    W#world{creatures = maps:map(fun(_Id, C) -> live(C, Base, Econ) end, Cs)}.

live(#{body := Body} = C, Base, Econ) ->
    spend(C, Base + body:upkeep(Body, Econ)).

spend(#{energy := E} = C, Cost) -> C#{energy => E - Cost}.

%%------------------------------------------------------------------------------
%% Moving: the only decision there is
%%------------------------------------------------------------------------------

%% EVERY CREATURE VALUES THE SAME WORLD, the one at the start of the tick, and
%% they all move at once. Nobody sees anybody else's move before making their
%% own, which is what removes turn order as a source of advantage.
move_all(#world{creatures = Cs} = W) ->
    Fields = fields(W),
    Ids = lists:sort(maps:keys(Cs)),
    {Moves, Rng} = lists:mapfoldl(fun(Id, R) -> choose(Id, Fields, W, R) end,
                                  W#world.rng, Ids),
    lists:foldl(fun step/2, W#world{rng = Rng}, Moves).

%% The measurable state of the world, gathered once per tick rather than per
%% creature. Creature energy is indexed by cell so that a sensor reading is a
%% lookup rather than a scan of the population.
fields(#world{plants = Plants, creatures = Cs, scent = Scent}) ->
    #{plants => Plants,
      scent => Scent,
      creatures => maps:fold(fun(_Id, #{at := At, energy := E}, Acc) ->
                                     maps:update_with(At, fun(T) -> T + E end,
                                                      E, Acc)
                             end, #{}, Cs)}.

choose(Id, Fields, #world{creatures = Cs, econ = Econ} = W, Rng0) ->
    #{at := At} = C = maps:get(Id, Cs),
    Options = [At | hex:neighbours_in(At, maps:get(radius, Econ))],
    Scored = [{value(C, Cell, At, Fields, W), Cell} || Cell <- Options],
    {To, Rng1} = pick_best(Scored, Rng0),
    {{Id, At, To}, Rng1}.

value(#{body := Body, brain := Brain} = C, Cell, At, Fields, W) ->
    Readings = [read(Sensor, Cell, C, Fields, W) || Sensor <- Body],
    brain:value(Brain, Readings, Cell =:= At).

%% What one sensor makes of one candidate cell: its field, summed over everything
%% within its reach of that cell, then scaled to a range a weight can be read
%% against.
read({Field, Range}, Cell, C, Fields, #world{econ = Econ}) ->
    Covered = hex:within(Cell, Range, maps:get(radius, Econ)),
    body:scale(lists:sum([at_cell(Field, H, C, Fields, Econ) || H <- Covered])).

at_cell(plants, H, _C, #{plants := Plants}, Econ) ->
    present(maps:is_key(H, Plants), maps:get(plant_energy, Econ));
%% A CREATURE DOES NOT PERCEIVE ITSELF AS SOMETHING IN THE WORLD. Its own energy
%% is subtracted from its own cell, or every creature would read the largest
%% concentration of creature energy as wherever it is standing.
at_cell(creatures, H, #{at := At, energy := E}, #{creatures := Herd}, _Econ) ->
    maps:get(H, Herd, 0) - own(H =:= At, E);
%% A mark reads by how UNLIKE the reader it smells, so a creature's own trail and
%% its children's are nearly invisible to it. See scent.
at_cell(scent, H, #{scent := Mine}, #{scent := Scent}, _Econ) ->
    foreign(maps:get(H, Scent, none), Mine).

present(true, Energy) -> Energy;
present(false, _Energy) -> 0.

own(true, E) -> E;
own(false, _E) -> 0.

foreign(none, _Mine) -> 0;
foreign(Mark, Mine) -> scent:perceived(Mark, Mine).

%% Ties are broken by drawing, not by taking the first. Candidate cells are
%% generated in a fixed compass order, so taking the first would make every
%% indifferent creature drift the same way forever and call it a random walk.
pick_best(Scored, Rng0) ->
    Best = lists:max([S || {S, _Cell} <- Scored]),
    pick([Cell || {S, Cell} <- Scored, S =:= Best], Rng0).

%% Staying still is free and leaves no trail. Moving costs and marks the ground:
%% that asymmetry makes sitting tight a way to go unnoticed as well as a way to
%% save energy, which is the only counter available to something being tracked.
step({_Id, At, At}, W) -> W;
step({Id, _From, To}, #world{creatures = Cs, econ = Econ} = W) ->
    C = maps:get(Id, Cs),
    Moved = spend(C#{at => To}, maps:get(move_cost, Econ)),
    mark(To, maps:get(scent, C), W#world{creatures = Cs#{Id => Moved}}).

mark(At, Tag, #world{scent = Scent, econ = Econ} = W) ->
    Fresh = strength(maps:get(At, Scent, none)) + maps:get(scent_per_tick, Econ),
    Capped = min(maps:get(scent_ceiling, Econ), Fresh),
    W#world{scent = Scent#{At => {Capped, Tag}}}.

strength(none) -> 0;
strength({S, _Tag}) -> S.

%%------------------------------------------------------------------------------
%% Consuming: one rule that does not know what it is eating
%%------------------------------------------------------------------------------

%% WHATEVER SHARES YOUR CELL AND CANNOT CONTEST YOU BECOMES YOURS. A plant never
%% contests. A creature contests with its energy, and equals do not consume each
%% other. Energy changes hands and none is created, so the books stay readable.
%%
%% This is the entire trophic structure, in one rule that mentions no trophic
%% level. Whether anything ever makes a living from the second clause is the
%% question the world exists to answer, and nothing here leans on the answer.
consume(#world{creatures = Cs} = W) ->
    lists:foldl(fun resolve/2, W, maps:values(occupancy(Cs))).

occupancy(Cs) ->
    maps:fold(fun share_cell/3, #{}, Cs).

share_cell(Id, #{at := At}, Acc) ->
    maps:update_with(At, fun(Together) -> [Id | Together] end, [Id], Acc).

resolve(Ids, #world{creatures = Cs} = W) ->
    %% Sorted by energy then id, so the outcome is a function of the world and
    %% not of map iteration order.
    Ranked = lists:reverse(lists:sort([{maps:get(energy, maps:get(I, Cs)), I}
                                       || I <- Ids])),
    [{_Strongest, Winner} | Rest] = Ranked,
    eat_creatures(Winner, [I || {_Energy, I} <- Rest], eat_plants(Winner, W)).

eat_plants(Id, #world{creatures = Cs, plants = Plants, econ = Econ} = W) ->
    #{at := At} = C = maps:get(Id, Cs),
    harvest(maps:is_key(At, Plants), Id, C, At, W, Econ).

harvest(false, _Id, _C, _At, W, _Econ) -> W;
harvest(true, Id, #{energy := E, from_plants := P} = C, At,
        #world{creatures = Cs, plants = Plants} = W, Econ) ->
    Gain = maps:get(plant_energy, Econ),
    W#world{creatures = Cs#{Id => C#{energy => E + Gain,
                                     from_plants => P + Gain}},
            plants = maps:remove(At, Plants),
            plants_eaten = W#world.plants_eaten + 1}.

eat_creatures(_Winner, [], W) -> W;
eat_creatures(Winner, Losers, #world{creatures = Cs} = W) ->
    #{energy := Mine} = maps:get(Winner, Cs),
    Weaker = [I || I <- Losers, maps:get(energy, maps:get(I, Cs)) < Mine],
    devour(Weaker, Winner, W).

devour([], _Winner, W) -> W;
devour(Weaker, Winner, #world{creatures = Cs} = W) ->
    Gain = lists:sum([max(0, maps:get(energy, maps:get(I, Cs))) || I <- Weaker]),
    #{energy := E, from_creatures := F} = C = maps:get(Winner, Cs),
    Fed = C#{energy => E + Gain, from_creatures => F + Gain},
    W#world{creatures = maps:without(Weaker, Cs#{Winner => Fed}),
            consumed = W#world.consumed + length(Weaker)}.

%%------------------------------------------------------------------------------
%% Breeding, dying, growing back
%%------------------------------------------------------------------------------

%% A surplus buys a child, placed on a neighbouring cell. The parent pays exactly
%% what the child receives, so energy is conserved at birth.
%%
%% THE DOWRY IS HALF THE PARENT'S OWN THRESHOLD, which makes the threshold a
%% tradeoff rather than a ratchet: breeding early makes many children who each
%% start poor, breeding late makes few who each start able to survive a search.
%% Without the scaling a lower threshold would simply be better everywhere and
%% the trait would collapse to its floor, which is a slow way of writing a
%% constant.
breed(#world{creatures = Cs} = W) ->
    lists:foldl(fun breed_one/2, W, lists:sort(maps:keys(Cs))).

breed_one(Id, #world{creatures = Cs} = W) ->
    #{energy := E, breed_at := Threshold} = maps:get(Id, Cs),
    ready(E >= Threshold, Id, W).

ready(false, _Id, W) -> W;
ready(true, Id, #world{creatures = Cs, econ = Econ} = W) ->
    room(map_size(Cs) < maps:get(max_creatures, Econ), Id, W).

room(false, _Id, #world{births_refused = R} = W) ->
    W#world{births_refused = R + 1};
room(true, Id, #world{creatures = Cs, econ = Econ, rng = Rng0} = W) ->
    #{at := At, energy := E, breed_at := Threshold} = C = maps:get(Id, Cs),
    Dowry = Threshold div 2,
    {Where, Rng1} = pick(hex:neighbours_in(At, maps:get(radius, Econ)), Rng0),
    {Traits, Change, Rng2} = inherit_traits(C, Econ, Rng1),
    W1 = note_change(Change,
                     W#world{creatures = Cs#{Id => C#{energy => E - Dowry}},
                             rng = Rng2}),
    add_creature(Where, Dowry, Id, Traits, W1).

note_change({added, _Pos}, #world{sensors_gained = G} = W) ->
    W#world{sensors_gained = G + 1};
note_change({dropped, _Pos}, #world{sensors_lost = L} = W) ->
    W#world{sensors_lost = L + 1};
note_change(none, W) ->
    W.

%% Four heritable things, mutated together. THE BODY AND THE BRAIN MUST STAY IN
%% STEP: a weight list out of order with the sensor list is the worst bug
%% available here, because nothing crashes and every weight after the change
%% quietly starts valuing a different measurement.
inherit_traits(Parent, Econ, Rng0) ->
    #{breed_at := Threshold, body := Body, brain := Brain,
      scent := Tag} = Parent,
    {BreedAt, Rng1} = inherit_threshold(Threshold, Econ, Rng0),
    {ChildBody, Change, Rng2} = body:inherit(Body, Econ, Rng1),
    {ChildBrain, Rng3} = brain:inherit(Brain, Change, Econ, Rng2),
    {ChildTag, Rng4} = scent:inherit(Tag, Econ, Rng3),
    {#{breed_at => BreedAt, body => ChildBody, brain => ChildBrain,
       scent => ChildTag}, Change, Rng4}.

inherit_threshold(Threshold, Econ, Rng0) ->
    Mut = maps:get(breed_mutation, Econ),
    {Step, Rng1} = rand:uniform_s(2 * Mut + 1, Rng0),
    {clamp(Threshold + Step - Mut - 1, Econ), Rng1}.

clamp(V, Econ) ->
    max(maps:get(breed_floor, Econ), min(maps:get(breed_ceiling, Econ), V)).

%% Death has three causes and they are counted separately, because "the
%% population crashed" is not a finding and one total cannot tell them apart.
%% Being eaten is counted where it happens, above.
reap(#world{creatures = Cs, econ = Econ} = W) ->
    MaxAge = maps:get(max_age, Econ),
    Reaped = maps:fold(fun(Id, C, Acc) -> reap_one(Id, C, MaxAge, Acc) end,
                       W#world{creatures = #{}}, Cs),
    note_extinction(map_size(Reaped#world.creatures), Reaped).

%% Recorded once, on the transition, and never revised. EXTINCTION IS PERMANENT
%% here and that is a property of the rules: nothing reseeds a world and a
%% population of zero cannot produce a birth. A dead island goes on publishing
%% perfectly, so the tick it emptied is the one thing no later sample carries.
note_extinction(0, #world{extinct_at = undefined, tick = T} = W) ->
    W#world{extinct_at = T};
note_extinction(_Alive, W) ->
    W.

reap_one(_Id, #{energy := E}, _MaxAge, #world{starved = S} = W) when E =< 0 ->
    W#world{starved = S + 1};
reap_one(_Id, #{age := A}, MaxAge, #world{aged_out = O} = W) when A > MaxAge ->
    W#world{aged_out = O + 1};
reap_one(Id, #{age := A} = C, _MaxAge, #world{creatures = Cs} = W) ->
    W#world{creatures = Cs#{Id => C#{age => A + 1}}}.

regrow(#world{econ = Econ, plants = Plants, rng = Rng0} = W) ->
    {Plants1, Rng1} = sow(maps:get(regrowth_per_tick, Econ),
                          maps:get(radius, Econ), Plants, Rng0),
    W#world{plants = Plants1, rng = Rng1}.

%% Every mark weakens and one that has weakened to nothing is dropped, so the map
%% holds only ground that still smells. Without the fade a busy cell becomes a
%% permanent road, and a board where everywhere smells alike carries exactly as
%% much information as one where nowhere does.
fade(#world{scent = Scent, econ = Econ} = W) ->
    Decay = maps:get(scent_decay, Econ),
    Weaken = fun(H, {S, Who}, Acc) -> linger(S - Decay, Who, H, Acc) end,
    W#world{scent = maps:fold(Weaken, #{}, Scent)}.

linger(S, _Who, _H, Acc) when S =< 0 -> Acc;
linger(S, Who, H, Acc) -> Acc#{H => {S, Who}}.

%%==============================================================================
%% Reading a world: statistics only, never rules
%%==============================================================================

%% NOTHING BELOW IS READ BY THE PHYSICS. These are an observer's numbers, and no
%% creature is ever treated differently for what any of them say. That separation
%% is what makes it legitimate to count diet at all: it is a description applied
%% afterwards, not a category the world enforces.
-spec snapshot(world()) -> map().
snapshot(#world{} = W) ->
    #{tick => W#world.tick,
      population => map_size(W#world.creatures),
      plants => map_size(W#world.plants),
      born => W#world.born,
      starved => W#world.starved,
      aged_out => W#world.aged_out,
      consumed => W#world.consumed,
      plants_eaten => W#world.plants_eaten,
      births_refused => W#world.births_refused,
      energy_total => total_energy(W),
      radius => maps:get(radius, W#world.econ),
      econ => W#world.econ,
      econ_id => econ_id(W#world.econ),
      extinct_at => W#world.extinct_at,
      breed_at_mean => mean(breed_at, W),
      %% WHERE THE LIVING GOT THEIR ENERGY, as a percentage that came from other
      %% creatures. Zero means nothing alive has ever eaten anything that could
      %% have eaten it back. This replaces the herbivore and carnivore buckets,
      %% which needed thresholds nobody could justify and named two roles the
      %% world had no opinion about.
      from_creatures_pct => predation_share(W),
      %% WHAT THE POPULATION IS BUILT FROM, per field: how many carry a sensor
      %% for it and how much total reach is devoted to it. A census, not a
      %% verdict: it says what survived, not what was useful.
      sensors => sensor_census(W),
      sensor_mean => mean_sensors(W),
      %% Whether the body plan is still moving at all.
      sensors_gained => W#world.sensors_gained,
      sensors_lost => W#world.sensors_lost,
      %% Properties of the signature, independent of anything evolved to use it.
      scent_cells => map_size(W#world.scent),
      scent_tags => length(lists:usort(tags(W))),
      scent_spread => scent:spread(tags(W))}.

%% Bodies paired with their brains, because a carried sensor and a used one are
%% different things and only the pair can tell them apart.
sensor_census(#world{creatures = Cs}) ->
    body:census([{B, Br} || #{body := B, brain := Br} <- maps:values(Cs)]).

tags(#world{creatures = Cs}) -> [T || #{scent := T} <- maps:values(Cs)].

mean(_Key, #world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
mean(Key, #world{creatures = Cs}) ->
    lists:sum([maps:get(Key, C) || C <- maps:values(Cs)]) div map_size(Cs).

mean_sensors(#world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
mean_sensors(#world{creatures = Cs}) ->
    Total = lists:sum([length(B) || #{body := B} <- maps:values(Cs)]),
    Total * 100 div map_size(Cs).

%% Of all the energy the living have ever eaten, what share came from creatures.
%% Zero for a population that has eaten nothing, rather than a crash.
predation_share(#world{creatures = Cs}) ->
    Vals = maps:values(Cs),
    Plants = lists:sum([P || #{from_plants := P} <- Vals]),
    Meat = lists:sum([M || #{from_creatures := M} <- Vals]),
    share(Plants + Meat, Meat).

share(0, _Meat) -> 0;
share(Total, Meat) -> Meat * 100 div Total.

%% @doc A short, stable fingerprint of the rules this world runs under.
%%
%% Two islands running different economies are not comparable and nothing else on
%% the wire would say so. Canonical bytes are built by hand rather than with
%% term_to_binary, whose output is only stable WITHIN an OTP release: two honest
%% islands on different releases would otherwise compute different ids for
%% identical rules, which destroys the only property a fingerprint has.
-spec econ_id(econ()) -> binary().
econ_id(Econ) ->
    Pairs = [[atom_to_list(K), $=, integer_to_list(V)]
             || {K, V} <- lists:sort(maps:to_list(Econ))],
    Canonical = lists:join($,, Pairs),
    <<Short:8/binary, _/binary>> = crypto:hash(sha256, iolist_to_binary(Canonical)),
    string:lowercase(binary:encode_hex(Short)).

%% @doc Where everything is, as flat coordinate lists `[Q1, R1, Q2, R2 | ...]'.
%%
%% Flat integers rather than pairs, because a pair is a tuple and tuples do not
%% survive this mesh cleanly, and because a map per entity would repeat the keys
%% `q' and `r' for every creature for no information. Sorted, so two charts of
%% the same world are the same bytes and a diff between frames means something.
%% ENERGY AND SCENT TRAVEL TOO, because they are the two things about this world
%% that are SPATIAL and were invisible. Positions alone draw a world where every
%% creature is identical and nothing has happened anywhere, which is a picture of
%% neither of the two results this world actually produced: that energy is armour
%% and that the ground remembers who walked on it.
%%
%% `energies' runs parallel to `creatures', one per creature in the same order,
%% rather than being interleaved. Interleaving would make the creature stride 3
%% while plants stayed 2, and a reader that got that wrong would draw a plausible
%% and completely wrong picture rather than failing.
%%
%% `scent' IS interleaved, at a stride of 3, because a mark is a position AND a
%% strength and there is no list it runs parallel to. The signature is left out:
%% it would double the payload and a spectator has nothing to compare it against.
-spec chart(world()) -> #{creatures := [integer()], energies := [integer()],
                          signatures := [integer()], plants := [integer()],
                          scent := [integer()],
                          radius := non_neg_integer(), tick := non_neg_integer()}.
chart(#world{creatures = Cs, plants = Plants, scent = Scent,
             econ = Econ, tick = Tick}) ->
    Ids = lists:sort(maps:keys(Cs)),
    #{creatures => flatten_hexes([maps:get(at, maps:get(Id, Cs)) || Id <- Ids]),
      %% Floored at zero: a creature awaiting the reaper carries a negative
      %% balance, and a viewer sizing a dot by it would be asked to draw a
      %% negative radius.
      energies => [max(0, maps:get(energy, maps:get(Id, Cs))) || Id <- Ids],
      %% WHO IS RELATED TO WHOM, one signature per creature in the same order.
      %% The scent MARKS deliberately leave this out, because there are hundreds
      %% of them and a viewer has nothing to compare one against. Creatures are a
      %% different case on both counts: there are tens, and they can be compared
      %% against EACH OTHER, which is the only way to see whether a population is
      %% one family or several without reading a number off a table.
      signatures => [maps:get(scent, maps:get(Id, Cs)) || Id <- Ids],
      plants => flatten_hexes(lists:sort(maps:keys(Plants))),
      scent => flatten_scent(Scent),
      radius => maps:get(radius, Econ),
      tick => Tick}.

flatten_hexes(Hexes) -> lists:append([[Q, R] || {Q, R} <- Hexes]).

flatten_scent(Scent) ->
    lists:append([[Q, R, S] || {{Q, R}, {S, _Tag}} <- lists:sort(maps:to_list(Scent))]).

%% The single number that says whether the books balance. Energy enters only by
%% eating a plant and leaves only by metabolism, rent and movement, so a run
%% whose total climbs without plants being eaten has a leak.
total_energy(#world{creatures = Cs}) ->
    lists:sum([E || #{energy := E} <- maps:values(Cs)]).

-spec population(world()) -> non_neg_integer().
population(#world{creatures = Cs}) -> map_size(Cs).

-spec plant_count(world()) -> non_neg_integer().
plant_count(#world{plants = P}) -> map_size(P).

-spec at_tick(world()) -> non_neg_integer().
at_tick(#world{tick = T}) -> T.

-spec alive(id(), world()) -> boolean().
alive(Id, #world{creatures = Cs}) -> maps:is_key(Id, Cs).

%%==============================================================================
%% Randomness, threaded explicitly
%%==============================================================================

sow(0, _Radius, Plants, Rng) -> {Plants, Rng};
sow(N, Radius, Plants, Rng0) ->
    {At, Rng1} = random_cell(Radius, Rng0),
    sow(N - 1, Radius, Plants#{At => true}, Rng1).

random_cell(Radius, Rng0) ->
    {Q, Rng1} = rand:uniform_s(2 * Radius + 1, Rng0),
    {R, Rng2} = rand:uniform_s(2 * Radius + 1, Rng1),
    H = {Q - Radius - 1, R - Radius - 1},
    retry(hex:in_disc(H, Radius), H, Radius, Rng2).

%% Rejection sampling: a bounding box on a hex disc is about three quarters disc,
%% so this retries rarely and is uniform, which sampling the box and clamping
%% would not be. Clamping piles every out-of-range draw onto the rim.
retry(true, H, _Radius, Rng) -> {H, Rng};
retry(false, _H, Radius, Rng) -> random_cell(Radius, Rng).

pick([], Rng) -> {{0, 0}, Rng};
pick(Options, Rng0) ->
    {N, Rng1} = rand:uniform_s(length(Options), Rng0),
    {lists:nth(N, Options), Rng1}.
