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
-export([population/1, ground_energy/1, at_tick/1, alive/2]).

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
                      %% Everything heritable. `breed_at' is gone: deciding
                      %% reproduction by a hand-written rule with a heritable
                      %% threshold was exactly the shape `hunt' had, a verb we
                      %% wrote with a parameter bolted on. It is an OUTPUT now.
                      body := body:body(),
                      brain := brain:brain(),
                      scent := scent:tag(),
                      %% WHAT THIS CREATURE HAS ACTUALLY EATEN, by where the
                      %% energy came from. An observer's record, not a rule:
                      %% nothing in the physics reads these, and no creature is
                      %% ever treated differently for what they contain.
                      from_ground := non_neg_integer(),
                      from_creatures := non_neg_integer(),
                      %% Whether it stayed put this tick. The plant-ness of a
                      %% creature, observed rather than declared.
                      still := boolean()}.

-type econ() :: #{influx := pos_integer(),
                  ground_ceiling := pos_integer(),
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
                  brain_mutation_structural := pos_integer(),
                  founder_max_hidden := non_neg_integer(),
                  max_hidden := non_neg_integer(),
                  hidden_rent := non_neg_integer(),
                  body_mutation := pos_integer(),
                  start_energy := pos_integer(),
                  max_age := pos_integer(),
                  radius := non_neg_integer(),
                  max_creatures := pos_integer()}.

-record(world, {tick = 0 :: non_neg_integer(),
                econ :: econ(),
                ground :: ground:ground(),
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
                absorbed = 0 :: non_neg_integer(),
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
    #{%% WHERE ENERGY ENTERS THE WORLD. Every cell gathers `influx' per tick up
      %% to `ground_ceiling'; a corpse is added on top and is not capped, because
      %% the ceiling says how much the sun builds up and not how much ground can
      %% hold. There are no plants: staying put and living off this IS being one.
      %%
      %% `influx' IS THE ONE NUMBER THAT DECIDES WHETHER PLANTS CAN EXIST and is
      %% therefore the one most at risk of being chosen for its outcome. Derived
      %% from the economy alone by the criterion fixed in PREREGISTRATION.md
      %% before measuring: the SMALLEST influx at which a sensorless creature
      %% that never moves can double its starting energy within `max_age', which
      %% is the least generous value at which the sessile option exists at all.
      %% Anything smaller forbids plants outright.
      %%
      %%   surplus per tick  = influx - metabolism
      %%   to double 800 within 600 ticks needs surplus >= 2 (1.33 rounded up)
      %%   so influx = metabolism + 2 = 12
      influx            => 12,
      ground_ceiling    => 400,
      %% WHAT IT COSTS TO EXIST AND TO ACT, at ten times world 1's grain. Scaling
      %% every energy quantity by one factor changes nothing about the world and
      %% buys the resolution to set the ratio above to within a tenth, which
      %% integers at the old grain could not express.
      metabolism        => 10,
      move_cost         => 10,
      %% What it costs to measure, per sensor per tick, used or not, rising with
      %% reach. The only force that can remove a sensor from a lineage.
      sensor_rent       => 10,
      %% What it costs to think. A brain is a thing that must be run, and unlike
      %% reach there is no geometry to derive a shape from, so it is flat.
      hidden_rent       => 10,
      %% Safety valves against a runaway genome making one tick cost as much as
      %% the whole disc. Not model parameters: rent is what should bound a
      %% creature, and when one of these binds it is counted and reported.
      max_sensors       => 8,
      max_sensor_range  => 4,
      max_hidden        => 6,
      founder_max_hidden => 2,
      %% What a moving creature leaves behind, how fast it fades, how much one
      %% cell can hold, and how fast a signature drifts. Scent is not energy and
      %% is not rescaled.
      scent_per_tick    => 10,
      scent_decay       => 2,
      scent_ceiling     => 30,
      scent_mutation    => 3,
      %% How large a weight may grow, how far each moves per birth, and how often
      %% the SHAPE of a brain changes rather than its numbers.
      brain_range       => 8,
      brain_mutation    => 1,
      brain_mutation_structural => 20,
      %% One birth in this many changes the body: a sensor gained, lost or
      %% re-reached, the three equally likely so nothing pushes bodies to grow.
      body_mutation     => 20,
      start_energy      => 800,
      max_age           => 600,
      radius            => 20,
      %% WELL ABOVE THE CELL COUNT, because if sitting still pays then the board
      %% fills, and a covered board is a FOREST rather than a mistuning. A field
      %% of grass is a population at the carrying capacity of the ground.
      max_creatures     => 6000}.

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
    Rng = rand:seed_s(exsss, {Seed, Seed, Seed}),
    Radius = maps:get(radius, Econ),
    populate(maps:get(population, Opts, 40), Opts,
             #world{econ = Econ, ground = ground:new(Radius, Econ), rng = Rng}).

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
    {Body, Rng1} = given(founder_body, Opts, fun body:founder/2, Econ, Rng0),
    {Brain, Rng2} = founder_brain(maps:get(founder_brain, Opts, draw),
                                  Body, Econ, Rng1),
    {Tag, Rng3} = given(founder_scent, Opts, fun scent:founder/2, Econ, Rng2),
    {#{body => Body, brain => Brain, scent => Tag}, Rng3}.

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

add_creature(At, Energy, Parent, Traits, #world{next_id = Id, creatures = Cs,
                                                tick = T, born = B} = W) ->
    C = maps:merge(#{id => Id, at => At, energy => Energy, age => 0,
                     born => T, parent => Parent, still => true,
                     from_ground => 0, from_creatures => 0},
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
    W6 = W5#world{ground = ground:grow(W5#world.ground, W5#world.econ)},
    W7 = fade(W6),
    tick(W7#world{tick = W7#world.tick + 1}, N - 1).

%% Existing costs energy, and so does carrying the means to measure or the means
%% to think. THIS IS WHERE CAPABILITY IS PAID FOR: a sensor nothing acts on, or a
%% hidden node nothing listens to, makes its owner strictly poorer than a
%% neighbour without one.
charge(#world{creatures = Cs, econ = Econ} = W) ->
    W#world{creatures = maps:map(fun(_Id, C) -> live(C, Econ) end, Cs)}.

live(#{body := Body, brain := Brain} = C, Econ) ->
    Rent = body:upkeep(Body, Econ)
        + brain:hidden_count(Brain) * maps:get(hidden_rent, Econ),
    spend(C, maps:get(metabolism, Econ) + Rent).

spend(#{energy := E} = C, Cost) -> C#{energy => E - Cost}.

%%------------------------------------------------------------------------------
%% Moving: the only decision about WHERE
%%------------------------------------------------------------------------------

%% EVERY CREATURE VALUES THE SAME WORLD, the one at the start of the tick, and
%% they all move at once. Nobody sees anybody else's move before making their own,
%% which removes turn order as a source of advantage without needing a shuffle to
%% hide it.
move_all(#world{creatures = Cs} = W) ->
    Herd = herd(Cs),
    Ids = lists:sort(maps:keys(Cs)),
    {Moves, Rng} = lists:mapfoldl(fun(Id, R) -> choose(Id, Herd, W, R) end,
                                  W#world.rng, Ids),
    lists:foldl(fun step/2, W#world{rng = Rng}, Moves).

%% Creature energy indexed by cell, gathered once per tick, so a sensor reading is
%% a lookup rather than a scan of the population.
herd(Cs) -> maps:fold(fun gather_flesh/3, #{}, Cs).

gather_flesh(_Id, #{at := At, energy := E}, Acc) ->
    maps:update_with(At, fun(Total) -> Total + E end, E, Acc).

choose(Id, Herd, #world{creatures = Cs} = W, Rng0) ->
    #{at := At, brain := Brain} = C = maps:get(Id, Cs),
    where(brain:has(move, Brain), Id, C, At, Herd, W, Rng0).

%% AN ABSENT OUTPUT MEANS THE THING IS NOT DONE, and that has to be enforced here
%% rather than left to the arithmetic. Without this a creature with no `move'
%% scores every cell at zero, the tie is broken by drawing, and six times in seven
%% it wanders off and is charged the fare. Losing the output would then not be an
%% evolutionary event at all, merely a way to move at random while paying for it.
where(false, Id, _C, At, _Herd, _W, Rng) ->
    {{Id, At, At}, Rng};
where(true, Id, C, At, Herd, #world{econ = Econ} = W, Rng0) ->
    Options = [At | hex:neighbours_in(At, maps:get(radius, Econ))],
    Scored = [{value(C, Cell, At, Herd, W), Cell} || Cell <- Options],
    {To, Rng1} = pick_best(Scored, Rng0),
    {{Id, At, To}, Rng1}.

value(C, Cell, At, Herd, W) ->
    Outputs = brain:evaluate(maps:get(brain, C), inputs(C, Cell, At, Herd, W),
                             W#world.econ),
    maps:get(move, Outputs, 0).

%% What a creature perceives of one candidate cell, in sensor order, then `here'.
%% `here' is an ordinary input rather than a special case, and it is why staying
%% put is expressible: movement costs and standing still does not, so a creature
%% that cannot tell where it already is cannot be sedentary on purpose.
inputs(#{body := Body} = C, Cell, At, Herd, W) ->
    [read(Sensor, Cell, C, Herd, W) || Sensor <- Body] ++ [here(Cell, At)].

here(Cell, Cell) -> 1;
here(_Cell, _At) -> 0.

read({self, _Range}, _Cell, #{energy := E}, _Herd, #world{econ = Econ}) ->
    body:reading(self, E, Econ);
read({Field, Range}, Cell, C, Herd, #world{econ = Econ} = W) ->
    body:reading(Field, gather(Field, Cell, Range, C, Herd, W), Econ).

gather(ground, Cell, Range, _C, _Herd, #world{ground = G, econ = Econ}) ->
    ground:within(Cell, Range, maps:get(radius, Econ), G);
%% A CREATURE DOES NOT PERCEIVE ITSELF AS SOMETHING IN THE WORLD. Its own energy
%% is subtracted from its own cell, or every creature would read the largest
%% concentration of flesh as wherever it is standing.
gather(creatures, Cell, Range, #{at := At, energy := E}, Herd,
       #world{econ = Econ}) ->
    Field = hex:within(Cell, Range, maps:get(radius, Econ)),
    lists:sum([maps:get(H, Herd, 0) || H <- Field]) - own(lists:member(At, Field), E);
%% A mark reads by how UNLIKE the reader it smells, so a creature's own trail and
%% its children's are nearly invisible to it.
gather(scent, Cell, Range, #{scent := Mine}, _Herd,
       #world{scent = Scent, econ = Econ}) ->
    Field = hex:within(Cell, Range, maps:get(radius, Econ)),
    lists:sum([foreign(maps:get(H, Scent, none), Mine) || H <- Field]).

own(true, E) -> max(0, E);
own(false, _E) -> 0.

foreign(none, _Mine) -> 0;
foreign(Mark, Mine) -> scent:perceived(Mark, Mine).

%% Ties are broken by drawing, not by taking the first. Candidates are generated
%% in a fixed compass order, so taking the first would make every indifferent
%% creature drift the same way forever and call it a random walk.
pick_best(Scored, Rng0) ->
    Best = lists:max([S || {S, _Cell} <- Scored]),
    pick([Cell || {S, Cell} <- Scored, S =:= Best], Rng0).

%% Staying still is free and leaves no trail. Moving costs and marks the ground:
%% that asymmetry makes sitting tight a way to go unnoticed as well as a way to
%% save energy, and it is the only counter available to something being tracked.
step({Id, At, At}, #world{creatures = Cs} = W) ->
    W#world{creatures = Cs#{Id => (maps:get(Id, Cs))#{still => true}}};
step({Id, _From, To}, #world{creatures = Cs, econ = Econ} = W) ->
    C = maps:get(Id, Cs),
    Moved = spend(C#{at => To, still => false}, maps:get(move_cost, Econ)),
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

%% WHATEVER SHARES YOUR CELL AND CANNOT CONTEST YOU BECOMES YOURS, and then you
%% absorb whatever the ground there has gathered. Energy in the ground never
%% contests. A creature contests with its energy, and equals do not consume each
%% other.
%%
%% There is no separate path for eating a plant, because there are no plants. In
%% world 1 there were two functions with two names and two counters, which is
%% precisely why its claim to have deleted the herbivore/carnivore split was
%% false: the split survived as a structural fact about what exists.
consume(#world{creatures = Cs} = W) ->
    lists:foldl(fun resolve/2, W, maps:values(occupancy(Cs))).

occupancy(Cs) -> maps:fold(fun share_cell/3, #{}, Cs).

share_cell(Id, #{at := At}, Acc) ->
    maps:update_with(At, fun(Together) -> [Id | Together] end, [Id], Acc).

resolve(Ids, #world{creatures = Cs} = W) ->
    Ranked = lists:reverse(lists:sort([{maps:get(energy, maps:get(I, Cs)), I}
                                       || I <- Ids])),
    [{_Strongest, Winner} | Rest] = Ranked,
    absorb(Winner, devour(Winner, [I || {_E, I} <- Rest], W)).

devour(_Winner, [], W) -> W;
devour(Winner, Losers, #world{creatures = Cs} = W) ->
    #{energy := Mine} = maps:get(Winner, Cs),
    Weaker = [I || I <- Losers, maps:get(energy, maps:get(I, Cs)) < Mine],
    take_them(Weaker, Winner, W).

take_them([], _Winner, W) -> W;
take_them(Weaker, Winner, #world{creatures = Cs} = W) ->
    Gain = lists:sum([max(0, maps:get(energy, maps:get(I, Cs))) || I <- Weaker]),
    #{energy := E, from_creatures := F} = C = maps:get(Winner, Cs),
    Fed = C#{energy => E + Gain, from_creatures => F + Gain},
    W#world{creatures = maps:without(Weaker, Cs#{Winner => Fed}),
            consumed = W#world.consumed + length(Weaker)}.

absorb(Id, #world{creatures = Cs, ground = G} = W) ->
    #{at := At, energy := E, from_ground := P} = C = maps:get(Id, Cs),
    {Gain, G1} = ground:take(At, G),
    W#world{creatures = Cs#{Id => C#{energy => E + Gain,
                                     from_ground => P + Gain}},
            ground = G1,
            absorbed = W#world.absorbed + Gain}.

%%------------------------------------------------------------------------------
%% Breeding, dying, fading
%%------------------------------------------------------------------------------

%% A CHILD IS A DECISION NOW, not a threshold. The brain is asked, on its own
%% cell, and above zero it spends HALF its current energy on a child placed
%% alongside. Zero is the natural boundary for a signed value and needs no
%% constant of its own.
%%
%% No floor stops a creature breeding itself down to nothing: one that does
%% leaves children too small to survive, and that is a bad strategy rather than an
%% illegal one. Four constants left the economy here and no rule replaced them.
breed(#world{creatures = Cs} = W) ->
    lists:foldl(fun breed_one/2, W, lists:sort(maps:keys(Cs))).

breed_one(Id, #world{creatures = Cs, econ = Econ} = W) ->
    #{at := At, energy := E} = C = maps:get(Id, Cs),
    Outputs = brain:evaluate(maps:get(brain, C), inputs(C, At, At, herd(Cs), W),
                             Econ),
    willing(maps:get(breed, Outputs, 0) > 0 andalso E > 1, Id, W).

willing(false, _Id, W) -> W;
willing(true, Id, #world{creatures = Cs, econ = Econ} = W) ->
    room(map_size(Cs) < maps:get(max_creatures, Econ), Id, W).

room(false, _Id, #world{births_refused = R} = W) ->
    W#world{births_refused = R + 1};
room(true, Id, #world{creatures = Cs, econ = Econ, rng = Rng0} = W) ->
    #{at := At, energy := E} = C = maps:get(Id, Cs),
    Dowry = E div 2,
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

%% Three heritable things, mutated together. THE BODY AND THE BRAIN MUST STAY IN
%% STEP: a weight vector out of order with the sensor list is the one bug here
%% that does not crash, because every weight past the change point quietly starts
%% valuing a different measurement.
inherit_traits(Parent, Econ, Rng0) ->
    #{body := Body, brain := Brain, scent := Tag} = Parent,
    {ChildBody, Change, Rng1} = body:inherit(Body, Econ, Rng0),
    {ChildBrain, Rng2} = brain:inherit(Brain, Change, Econ, Rng1),
    {ChildTag, Rng3} = scent:inherit(Tag, Econ, Rng2),
    {#{body => ChildBody, brain => ChildBrain, scent => ChildTag}, Change, Rng3}.

%% DEATH RETURNS ENERGY TO THE GROUND IT DIED ON, and world 1 simply deleted it.
%% Not rounded away: a well-fed creature could be carrying hundreds and reaping it
%% destroyed every unit, which meant the energy books were never checkable at all.
%%
%% It is also where soil comes from. A deposit is not capped by `ground_ceiling',
%% so a cell where things have died is richer than any untouched cell can be, and
%% somewhere the population is dense the deaths keep coming and the ground stays
%% better than average. THE LANDSCAPE DIFFERENTIATES ITSELF AND LIFE IS WHAT
%% DIFFERENTIATES IT.
reap(#world{creatures = Cs, econ = Econ} = W) ->
    MaxAge = maps:get(max_age, Econ),
    Reaped = maps:fold(fun(Id, C, Acc) -> reap_one(Id, C, MaxAge, Acc) end,
                       W#world{creatures = #{}}, Cs),
    note_extinction(map_size(Reaped#world.creatures), Reaped).

note_extinction(0, #world{extinct_at = undefined, tick = T} = W) ->
    W#world{extinct_at = T};
note_extinction(_Alive, W) ->
    W.

reap_one(_Id, #{energy := E, at := At}, _MaxAge, #world{starved = S} = W)
  when E =< 0 ->
    bury(At, E, W#world{starved = S + 1});
reap_one(_Id, #{age := A, energy := E, at := At}, MaxAge,
         #world{aged_out = O} = W) when A > MaxAge ->
    bury(At, E, W#world{aged_out = O + 1});
reap_one(Id, #{age := A} = C, _MaxAge, #world{creatures = Cs} = W) ->
    W#world{creatures = Cs#{Id => C#{age => A + 1}}}.

bury(At, E, #world{ground = G} = W) ->
    W#world{ground = ground:deposit(At, max(0, E), G)}.

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
      %% One half of the world's books. The other is the creatures, and together
      %% they only change by influx in and by what living costs.
      ground_total => ground:total(W#world.ground),
      %% HOW UNEVENLY THE GROUND HOLDS ENERGY: the percentage lying in the
      %% richest tenth of cells. Ten means flat. Anything above says places have
      %% become different from each other, and since nothing installed terrain,
      %% whatever difference exists was made by things dying.
      ground_spread => ground:spread(W#world.ground),
      born => W#world.born,
      starved => W#world.starved,
      aged_out => W#world.aged_out,
      consumed => W#world.consumed,
      absorbed => W#world.absorbed,
      births_refused => W#world.births_refused,
      energy_total => total_energy(W),
      radius => maps:get(radius, W#world.econ),
      econ => W#world.econ,
      econ_id => econ_id(W#world.econ),
      extinct_at => W#world.extinct_at,
      %% THE PLANT-NESS OF THE POPULATION, observed and never declared: the
      %% percentage that did not move this tick. A creature that stays where it
      %% is and lives off what gathers there IS a plant, and nothing in the rules
      %% calls it one.
      still_pct => still_share(W),
      hidden_mean => mean_hidden(W),
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
      movers => outputs_with(move, W),
      breeders => outputs_with(breed, W),
      sensor_mean => mean_sensors(W),
      %% Whether the body plan is still moving at all.
      sensors_gained => W#world.sensors_gained,
      sensors_lost => W#world.sensors_lost,
      %% Properties of the signature, independent of anything evolved to use it.
      scent_cells => map_size(W#world.scent),
      scent_tags => length(lists:usort(tags(W))),
      scent_spread => scent:spread(tags(W))}.

%% Bodies paired with how much attention each of their inputs receives, because a
%% carried sensor and a used one are different things and only the brain knows
%% how many vectors read a given column.
sensor_census(#world{creatures = Cs}) ->
    body:census([{B, brain:attention(Br, length(B))}
                 || #{body := B, brain := Br} <- maps:values(Cs)]).

outputs_with(_Purpose, #world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
outputs_with(Purpose, #world{creatures = Cs}) ->
    length([x || #{brain := Br} <- maps:values(Cs), brain:has(Purpose, Br)]).

still_share(#world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
still_share(#world{creatures = Cs}) ->
    length([x || #{still := true} <- maps:values(Cs)]) * 100 div map_size(Cs).

mean_hidden(#world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
mean_hidden(#world{creatures = Cs}) ->
    Total = lists:sum([brain:hidden_count(B) || #{brain := B} <- maps:values(Cs)]),
    Total * 100 div map_size(Cs).

tags(#world{creatures = Cs}) -> [T || #{scent := T} <- maps:values(Cs)].

mean_sensors(#world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
mean_sensors(#world{creatures = Cs}) ->
    Total = lists:sum([length(B) || #{body := B} <- maps:values(Cs)]),
    Total * 100 div map_size(Cs).

%% Of all the energy the living have ever eaten, what share came from creatures.
%% Zero for a population that has eaten nothing, rather than a crash.
predation_share(#world{creatures = Cs}) ->
    Vals = maps:values(Cs),
    Plants = lists:sum([P || #{from_ground := P} <- Vals]),
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
                          signatures := [integer()], ground := [integer()],
                          scent := [integer()],
                          radius := non_neg_integer(), tick := non_neg_integer()}.
chart(#world{creatures = Cs, ground = G, scent = Scent,
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
      %% The ground as position and amount, at a stride of three. Only cells
      %% holding something are sent: an empty cell is one a spectator draws bare,
      %% and on a grazed board most of them are.
      ground => flatten_ground(G),
      scent => flatten_scent(Scent),
      radius => maps:get(radius, Econ),
      tick => Tick}.

flatten_hexes(Hexes) -> lists:append([[Q, R] || {Q, R} <- Hexes]).

flatten_ground(G) ->
    lists:append([[Q, R, E] || {{Q, R}, E} <- lists:sort(maps:to_list(G)),
                               E > 0]).

flatten_scent(Scent) ->
    lists:append([[Q, R, S] || {{Q, R}, {S, _Tag}} <- lists:sort(maps:to_list(Scent))]).

%% The single number that says whether the books balance. Energy enters only by
%% eating a plant and leaves only by metabolism, rent and movement, so a run
%% whose total climbs without plants being eaten has a leak.
total_energy(#world{creatures = Cs}) ->
    lists:sum([E || #{energy := E} <- maps:values(Cs)]).

-spec population(world()) -> non_neg_integer().
population(#world{creatures = Cs}) -> map_size(Cs).

-spec ground_energy(world()) -> non_neg_integer().
ground_energy(#world{ground = G}) -> ground:total(G).

-spec at_tick(world()) -> non_neg_integer().
at_tick(#world{tick = T}) -> T.

-spec alive(id(), world()) -> boolean().
alive(Id, #world{creatures = Cs}) -> maps:is_key(Id, Cs).

%%==============================================================================
%% Randomness, threaded explicitly
%%==============================================================================

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
