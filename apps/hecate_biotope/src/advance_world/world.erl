%% @doc The biotope itself: plants, creatures, and the energy that moves between
%% them. PURE. No processes, no mesh, no clock, no ets.
%%
%% THE ENERGY ECONOMY IS BUILT FIRST, BEFORE A SINGLE ORGAN, and that ordering is
%% the whole design. Four numbers decide whether anything interesting can ever
%% happen here:
%%
%%   where energy ENTERS the world          plant_energy x regrowth_per_tick
%%   what it costs to EXIST                 metabolism, charged every tick
%%   what it costs to ACT                   move_cost
%%   what a SURPLUS buys                    breed_at, breed_cost
%%
%% `metabolism' is the seam everything later hangs on. When creatures have
%% organs, an organ's standing upkeep is added to it, and that is what makes a
%% generalist expensive. Without a standing cost per organ, every creature grows
%% every organ, the omnivore always wins, and dietary roles never appear however
%% long it runs. The number exists now, charged flat, so that the shape is
%% already right when there is something to charge for.
%%
%% TWO TROPHIC LEVELS, AND THE SECOND ONE IS A BET. Creatures may now eat each
%% other. The Flatland experiments found no coexistence regime for an open
%% predator-prey population with FIXED behaviours: it collapsed to mutual
%% extinction in about one predator generation, every time. Nothing here repeals
%% that. What is different is that predator and prey are not two populations,
%% they are one population in which every creature chooses, every tick, which it
%% is being. That makes the payoff frequency-dependent: hunting is lucrative
%% while hunters are rare and starves when they are common, which is the shape
%% that produces stable mixtures rather than spirals. Whether it actually does so
%% here is the open question, and it is measurable rather than arguable.
%%
%% NO ROLES ARE ASSIGNED. There is no herbivore field, no carnivore flag, no
%% species. Every creature has the same three intents available to it, and diet
%% is a MEASUREMENT taken over what a creature actually ate. A world that labels
%% its creatures cannot discover that the labels were wrong.
%%
%% THE RANDOM WALK SURVIVES AS A FLOOR, not as the default. A creature with no
%% eye that decides to graze steps at random, which is exactly what the whole
%% population used to do. That makes the old behaviour the null forager every
%% brain has to beat, still present, still paying its own way, rather than a
%% phase of the project that was deleted.
%%
%% STILL NO PROCESS PER CREATURE, and the reason has hardened rather than
%% weakened. Purity is what lets four thousand ticks across five seeds and three
%% economies run offline in under a minute, and that probe has already prevented
%% a fortnight of migration plumbing being built on a trait that turned out not
%% to move. A body of organ processes is a fine RUNTIME for these rules, and it
%% can host them later; it is a poor place to discover what the rules should be.
-module(world).

-export([new/0, new/1, tick/1, tick/2, snapshot/1, chart/1, defaults/0, econ_id/1]).
-export([population/1, plant_count/1, at_tick/1, alive/2]).

-type hex() :: hex:hex().
-type id() :: pos_integer().

%% HOW DIET IS READ OFF, and deliberately NOT part of the economy. These decide
%% what a run is CALLED, not how it behaves, so putting them in the economy would
%% make the fingerprint change when the labelling changed and two identical
%% worlds would stop looking comparable.
-define(DIET_MEALS, 4).
-define(CARNIVORE_PCT, 80).
-define(HERBIVORE_PCT, 20).

%% Position, energy, age and parentage. Parentage is carried from the first
%% version because a lineage that is not recorded as it happens cannot be
%% recovered afterwards, and it costs one integer.
-type creature() :: #{id := id(),
                      at := hex(),
                      energy := integer(),
                      age := non_neg_integer(),
                      born := non_neg_integer(),
                      parent := id() | none,
                      %% The energy at which this creature will spend half of
                      %% itself on a child. Heritable.
                      breed_at := pos_integer(),
                      %% WHAT IT IS BUILT FROM AND WHAT IT DECIDES WITH, both
                      %% heritable. The body says what can be perceived and
                      %% charges rent for the privilege; the brain turns that
                      %% into one of three intents. Between them they are the
                      %% only reason two creatures here behave differently.
                      body := body:body(),
                      brain := brain:brain(),
                      %% MEALS TAKEN, BY KIND, FOR THE LIFE OF THIS CREATURE.
                      %% This is where diet comes from, and it is deliberately a
                      %% record of what happened rather than a declaration of
                      %% what this creature is. A lineage that stops finding
                      %% prey stops being carnivorous, without anything having
                      %% to change its label.
                      grazed := non_neg_integer(),
                      hunted := non_neg_integer()}.

-type econ() :: #{plant_energy := pos_integer(),
                  regrowth_per_tick := non_neg_integer(),
                  metabolism := non_neg_integer(),
                  move_cost := non_neg_integer(),
                  organ_upkeep := non_neg_integer(),
                  attack_cost := non_neg_integer(),
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
                creatures = #{} :: #{id() => creature()},
                next_id = 1 :: id(),
                rng :: rand:state(),
                %% Counters since the world began. Rates are what a reader
                %% actually wants and they are recoverable from totals; the
                %% reverse is not true, so totals are what is kept.
                born = 0 :: non_neg_integer(),
                starved = 0 :: non_neg_integer(),
                aged_out = 0 :: non_neg_integer(),
                eaten = 0 :: non_neg_integer(),
                %% Deaths by predation, kept apart from starvation and old age
                %% for the same reason those two are kept apart: "the population
                %% crashed" is not a finding, and three causes that share one
                %% total cannot be told from each other afterwards.
                killed = 0 :: non_neg_integer(),
                births_refused = 0 :: non_neg_integer(),
                %% The tick the last creature died, and never unset afterwards.
                %% EXTINCTION IS PERMANENT HERE, and that is a property of the
                %% rules rather than an oversight: nothing external reseeds a
                %% world, and a population of zero has no way to produce a birth.
                %% Recording WHEN it happened is the part a reader cannot
                %% reconstruct from a later sample, because every sample after it
                %% looks identical.
                extinct_at = undefined :: non_neg_integer() | undefined}).

-opaque world() :: #world{}.
-export_type([world/0, creature/0, econ/0]).

%%==============================================================================
%% The economy
%%==============================================================================

%% NUMBERS CHOSEN TO BE TUNED, NOT TO BE RIGHT. They are a starting point with
%% one property argued for rather than guessed: a random walker on a disc of this
%% plant density meets food often enough to pay its metabolism, which is the
%% minimum for the world to be worth watching. Everything else is measured from
%% here by changing one number at a time.
-spec defaults() -> econ().
defaults() ->
    #{plant_energy      => 40,
      regrowth_per_tick => 4,
      metabolism        => 1,
      move_cost         => 1,
      %% WHAT AN ORGAN COSTS TO RUN, every tick, used or not. This is the number
      %% that makes a generalist expensive, and without it every lineage keeps
      %% every organ and no differentiation is possible. Charged flat per organ,
      %% so a three-organ creature burns four while an eyeless one burns two.
      organ_upkeep      => 1,
      %% WHAT A STRIKE COSTS, win or lose. Paid before the victim's energy is
      %% collected, so hunting something thinner than this is a net loss and the
      %% nose, which is what tells a creature who is fat, has something to earn.
      %% Roughly three quarters of a plant: enough that a bad strike hurts,
      %% little enough that a good one is clearly worth taking.
      attack_cost       => 30,
      %% How large a brain weight may grow. Bounded so a long lineage cannot
      %% drift to weights that swamp every sense and turn the brain back into a
      %% constant that ignores the world.
      brain_range       => 8,
      %% How far each weight may move per birth. One, so a child is recognisably
      %% its parent and selection can climb a gradient instead of resampling.
      brain_mutation    => 1,
      %% One birth in this many changes one organ. Rarer than brain mutation on
      %% purpose: morphology is a coarser thing than preference, and a body that
      %% changed every generation would never be around long enough for a brain
      %% to adapt to it.
      body_mutation     => 20,
      %% The FOUNDING mean. Every creature carries its own from here on, and
      %% the founders are spread around this rather than all starting equal:
      %% selection needs something to select between, and a population of
      %% identical creatures gives it nothing until mutation slowly supplies it.
      breed_at          => 160,
      %% How far a child's threshold may drift from its parent's. Zero turns
      %% inheritance into cloning and the whole trait into a constant.
      breed_mutation    => 8,
      breed_floor       => 40,
      breed_ceiling     => 400,
      start_energy      => 80,
      max_age           => 600,
      radius            => 20,
      %% A SAFETY VALVE, NOT A MODEL PARAMETER. The economy is what should bound
      %% the population; this only stops a mistuned run from allocating until the
      %% box dies. Refused births are counted so a run that hits it says so
      %% instead of looking like a stable ceiling.
      max_creatures     => 2000}.

%%==============================================================================
%% Making a world
%%==============================================================================

-spec new() -> world().
new() -> new(#{}).

%% Opts override the economy, plus `seed', `population' and `initial_plants'.
%% The seed is explicit so a run is reproducible from its parameters alone;
%% nothing here reads a clock or the process dictionary.
%%
%% `initial_plants' IS SEPARATELY SETTABLE, and it earned that the hard way: six
%% tests of the energy books passed a regrowth of zero, called the result barren,
%% and quietly measured a creature eating the world's opening greenery. A world
%% that cannot be started bare cannot be used to prove where energy comes from.
-spec new(map()) -> world().
new(Opts) ->
    Econ = maps:merge(defaults(), maps:with(maps:keys(defaults()), Opts)),
    Seed = maps:get(seed, Opts, 42),
    Rng0 = rand:seed_s(exsss, {Seed, Seed, Seed}),
    Radius = maps:get(radius, Econ),
    %% A third of the ground green by default, so the first generation is not
    %% deciding the world's fate before any plant has grown.
    PlantSeed = maps:get(initial_plants, Opts, hex:cells(Radius) div 3),
    {Plants, Rng1} = sow(PlantSeed, Radius, #{}, Rng0),
    W = #world{econ = Econ, plants = Plants, rng = Rng1},
    populate(maps:get(population, Opts, 40), Opts, W).

populate(0, _Opts, W) -> W;
populate(N, Opts, #world{econ = Econ, rng = Rng0} = W) ->
    Radius = maps:get(radius, Econ),
    {At, Rng1} = random_cell(Radius, Rng0),
    %% FOUNDERS ARE SPREAD, NOT IDENTICAL. Selection needs something to select
    %% between; a population of clones gives it nothing until mutation slowly
    %% supplies variation, which wastes the first several hundred ticks of every
    %% run and makes short runs look like the trait does not move.
    {Traits, Rng2} = founder_traits(Econ, Opts, Rng1),
    populate(N - 1, Opts, add_creature(At, maps:get(start_energy, Econ), none,
                                       Traits, W#world{rng = Rng2})).

%% Everything heritable, drawn fresh. Bodies and brains are spread for the same
%% reason thresholds are: the first generation should already contain grazers,
%% hunters, loafers and every body plan, so selection has something to sort on
%% tick one instead of waiting for mutation to invent variety.
%%
%% A BODY OR A BRAIN MAY BE GIVEN INSTEAD OF DRAWN, and that is not a testing
%% hook bolted on. It is how a world is founded with a KNOWN creature: a control
%% run against a specified strategy, and later the same seam a transplanted
%% migrant from another island arrives through. Drawing is the default because a
%% world founded from one specification is a world with no variation in it.
founder_traits(Econ, Opts, Rng0) ->
    {BreedAt, Rng1} = founder_threshold(Econ, Rng0),
    {Body, Rng2} = given_body(maps:get(founder_body, Opts, draw), Econ, Rng1),
    {Brain, Rng3} = given_brain(maps:get(founder_brain, Opts, draw), Econ, Rng2),
    {#{breed_at => BreedAt, body => Body, brain => Brain}, Rng3}.

given_body(draw, Econ, Rng) -> body:founder(Econ, Rng);
given_body(Body, _Econ, Rng) -> {Body, Rng}.

given_brain(draw, Econ, Rng) -> brain:founder(Econ, Rng);
given_brain(Brain, _Econ, Rng) -> {Brain, Rng}.

%% Uniform across half to one and a half times the founding mean.
founder_threshold(Econ, Rng0) ->
    Mean = maps:get(breed_at, Econ),
    {Draw, Rng1} = rand:uniform_s(Mean + 1, Rng0),
    {clamp(Mean div 2 + Draw - 1, Econ), Rng1}.

%% Traits arrive as a map rather than as three more positional arguments,
%% because the next heritable thing should not require touching every caller.
add_creature(At, Energy, Parent, Traits, #world{next_id = Id, creatures = Cs,
                                                tick = T, born = B} = W) ->
    C = maps:merge(#{id => Id, at => At, energy => Energy, age => 0,
                     born => T, parent => Parent, grazed => 0, hunted => 0},
                   Traits),
    W#world{next_id = Id + 1, creatures = Cs#{Id => C}, born = B + 1}.

%%==============================================================================
%% The tick
%%==============================================================================

-spec tick(world()) -> world().
tick(W) -> tick(W, 1).

%% FIVE PHASES IN A FIXED ORDER, because the order is a rule of the world and
%% not an implementation detail. Charging metabolism first means a creature that
%% cannot afford to exist does not get a free turn; acting before breeding means
%% this tick's meal can pay for this tick's child.
-spec tick(world(), non_neg_integer()) -> world().
tick(W, 0) -> W;
tick(W, N) ->
    W1 = charge_living(W),
    W2 = act_everyone(W1),
    W3 = breed_everyone(W2),
    W4 = reap(W3),
    W5 = regrow(W4),
    tick(W5#world{tick = W5#world.tick + 1}, N - 1).

%% Existing costs energy, every tick, unconditionally, and a body costs more than
%% a bare one. THIS IS WHERE CAPABILITY IS PAID FOR: an eye that is not earning
%% its upkeep makes its owner strictly poorer than an eyeless neighbour, which is
%% the only force in this world that can ever remove an organ.
charge_living(#world{creatures = Cs, econ = Econ} = W) ->
    Base = maps:get(metabolism, Econ),
    W#world{creatures = maps:map(fun(_Id, C) -> live(C, Base, Econ) end, Cs)}.

live(#{body := Body} = C, Base, Econ) ->
    spend(C, Base + body:upkeep(Body, Econ)).

spend(#{energy := E} = C, Cost) -> C#{energy => E - Cost}.

%%------------------------------------------------------------------------------
%% Acting: perceive, decide, do
%%------------------------------------------------------------------------------

%% ORDER IS SHUFFLED EVERY TICK, and that is a correctness matter now rather
%% than a taste one. Once creatures can eat each other, whoever acts first eats
%% first, so a fixed order by id would hand every ancient lineage a permanent
%% structural advantage and the result would be a measurement of the sort
%% function. The shuffle is drawn from the world's own generator, so a run is
%% still bit-identical from its seed.
%%
%% A CELL INDEX IS BUILT ONCE PER TICK and threaded through the fold. Without it
%% every creature would scan every other creature to find its neighbours, which
%% is quadratic and would cost the offline probe its speed, and speed is the
%% whole reason the world is pure. It is rebuilt each tick rather than kept in
%% the record, so it cannot silently drift out of agreement with the truth.
act_everyone(#world{creatures = Cs, rng = Rng0} = W) ->
    {Order, Rng1} = shuffle(lists:sort(maps:keys(Cs)), Rng0),
    {W1, _Index} = lists:foldl(fun act_one/2,
                               {W#world{rng = Rng1}, index(Cs)}, Order),
    W1.

index(Cs) ->
    maps:fold(fun(Id, #{at := At}, Acc) -> occupy(Id, At, Acc) end, #{}, Cs).

occupy(Id, At, Index) ->
    maps:update_with(At, fun(Ids) -> [Id | Ids] end, [Id], Index).

vacate(Id, At, Index) ->
    maps:update_with(At, fun(Ids) -> Ids -- [Id] end, [], Index).

%% A creature eaten earlier in this same tick does not get a turn. It is looked
%% up rather than assumed present, because the fold's order list was taken before
%% anything happened.
act_one(Id, {#world{creatures = Cs}, _Index} = Acc) ->
    act_if_alive(maps:get(Id, Cs, gone), Id, Acc).

act_if_alive(gone, _Id, Acc) -> Acc;
act_if_alive(#{body := Body, brain := Brain} = C, Id, Acc) ->
    Senses = body:senses(Body, perceive(Id, C, Acc)),
    do(brain:decide(Brain, Senses), Id, C, Acc).

%% What is measurably there, before the body decides how much of it can be
%% perceived. The field is the creature's own cell plus its six neighbours: what
%% it could reach this turn.
perceive(Id, #{at := At, energy := E}, {#world{} = W, Index}) ->
    Field = field(At, W),
    Others = [maps:get(N, W#world.creatures)
              || H <- Field, N <- maps:get(H, Index, []), N =/= Id],
    #{plants_near => length([H || H <- Field, maps:is_key(H, W#world.plants)]),
      creatures_near => length(Others),
      fattest_near => fattest(Others),
      own_energy => E}.

field(At, #world{econ = Econ}) ->
    [At | hex:neighbours_in(At, maps:get(radius, Econ))].

fattest([]) -> 0;
fattest(Creatures) -> lists:max([E || #{energy := E} <- Creatures]).

%% RESTING IS FREE AND THAT IS THE POINT. It is the only intent that does not pay
%% move_cost, so a creature that has learned there is nothing worth chasing can
%% wait out a bad patch instead of walking itself to death. Without a do-nothing
%% option the cheapest strategy in a barren world is unavailable and every brain
%% is forced to burn energy having opinions.
do(rest, _Id, _C, Acc) -> Acc;
do(graze, Id, C, Acc) -> graze(Id, C, Acc);
do(hunt, Id, C, Acc) -> hunt(Id, C, Acc).

%%------------------------------------------------------------------------------
%% Grazing
%%------------------------------------------------------------------------------

%% An eye turns foraging from a walk into a choice. Without one the creature
%% steps at random, which is exactly what the whole population did before brains
%% existed, so the old null forager is still here and still has to be beaten.
graze(Id, #{at := At, body := Body} = C, {W, Index}) ->
    {To, W1} = forage(body:has(eye, Body), At, W),
    eat_here(To, Id, moved(Id, C, At, To, W1, Index)).

forage(_Eye, At, #world{plants = Plants} = W) when is_map_key(At, Plants) ->
    {At, W};
forage(true, At, W) ->
    visible(in_reach(At, W), At, W);
forage(false, At, W) ->
    wander(At, W).

in_reach(At, #world{plants = Plants} = W) ->
    [H || H <- hex:neighbours_in(At, maps:get(radius, W#world.econ)),
          maps:is_key(H, Plants)].

visible([], At, W) -> wander(At, W);
visible(Seen, _At, #world{rng = Rng0} = W) ->
    {To, Rng1} = pick(Seen, Rng0),
    {To, W#world{rng = Rng1}}.

wander(At, #world{econ = Econ, rng = Rng0} = W) ->
    {To, Rng1} = pick(hex:neighbours_in(At, maps:get(radius, Econ)), Rng0),
    {To, W#world{rng = Rng1}}.

%% Standing still is free; a step costs. Staying put is what a creature already
%% on a plant does, so the meal it is standing on is not taxed.
moved(_Id, _C, At, At, W, Index) -> {W, Index};
moved(Id, C, From, To, #world{creatures = Cs, econ = Econ} = W, Index) ->
    Stepped = spend(C#{at => To}, maps:get(move_cost, Econ)),
    {W#world{creatures = Cs#{Id => Stepped}},
     occupy(Id, To, vacate(Id, From, Index))}.

%% A plant feeds exactly one creature and is gone. Whoever reaches it first in
%% this tick's shuffled order gets it.
eat_here(At, Id, {#world{plants = Plants} = W, Index}) when is_map_key(At, Plants) ->
    #{energy := E, grazed := G} = C = maps:get(Id, W#world.creatures),
    Fed = C#{energy => E + maps:get(plant_energy, W#world.econ), grazed => G + 1},
    {W#world{creatures = (W#world.creatures)#{Id => Fed},
             plants = maps:remove(At, Plants),
             eaten = W#world.eaten + 1},
     Index};
eat_here(_At, _Id, Acc) ->
    Acc.

%%------------------------------------------------------------------------------
%% Hunting
%%------------------------------------------------------------------------------

%% A STRIKE COSTS WHETHER OR NOT IT LANDS, and a creature with no nose cannot
%% choose whom it lands on. That is what the nose is for and what its upkeep buys:
%% the difference between taking the fattest neighbour and taking whoever is
%% nearest. A hunter with no prey in reach has simply wasted its turn, which is
%% the price of a bad decision and is exactly what selection needs to see.
hunt(Id, #{at := At, body := Body} = C, {W, Index}) ->
    Reachable = [N || H <- field(At, W), N <- maps:get(H, Index, []), N =/= Id],
    strike(Reachable, body:has(nose, Body), Id, C, {W, Index}).

strike([], _Nose, Id, C, {W, Index}) ->
    {To, W1} = wander(maps:get(at, C), W),
    moved(Id, C, maps:get(at, C), To, W1, Index);
strike(Prey, Nose, Id, C, {W, Index}) ->
    {Victim, W1} = choose_prey(Nose, Prey, W),
    kill(Victim, Id, C, {W1, Index}).

%% With a nose, the fattest. Without, whoever is nearest to hand, resolved by the
%% world's generator so it is a coin rather than an artefact of list order.
choose_prey(true, Prey, #world{creatures = Cs} = W) ->
    Fattest = lists:max([{maps:get(energy, maps:get(N, Cs)), N} || N <- Prey]),
    {element(2, Fattest), W};
choose_prey(false, Prey, #world{rng = Rng0} = W) ->
    {Victim, Rng1} = pick(Prey, Rng0),
    {Victim, W#world{rng = Rng1}}.

%% The attacker moves onto the kill, pays for the strike, and takes what the
%% victim was carrying. Energy is conserved apart from the strike and the step,
%% so the books stay readable: nothing is created here, it changes hands.
%%
%% A VICTIM ALREADY AT OR BELOW ZERO IS WORTH NOTHING rather than worth a debt.
%% It is about to be reaped anyway, and letting an attacker inherit a negative
%% balance would make killing the starving a way to destroy energy.
%%
%% THE STRIKE COST COVERS THE LUNGE, so move_cost is not charged on top. The
%% alternative charges a step for closing on a victim in a neighbouring cell and
%% nothing for one sharing your own, which is a distinction the rules have no
%% reason to make and which grazing already resolves the other way.
kill(Victim, Id, C, {#world{creatures = Cs, econ = Econ} = W, Index}) ->
    #{at := Where, energy := Loot} = maps:get(Victim, Cs),
    #{at := From, energy := E, hunted := H} = C,
    Fed = C#{at => Where,
             energy => E + max(0, Loot) - maps:get(attack_cost, Econ),
             hunted => H + 1},
    {W#world{creatures = maps:remove(Victim, Cs#{Id => Fed}),
             killed = W#world.killed + 1},
     occupy(Id, Where, vacate(Id, From, vacate(Victim, Where, Index)))}.

%% A surplus buys a child, placed on a neighbouring cell. The parent pays exactly
%% what the child receives, so energy is conserved at birth and the only sink in
%% the world is metabolism plus movement. That keeps the books readable.
%%
%% THE DOWRY IS HALF THE PARENT'S OWN THRESHOLD, and that is what makes the trait
%% a tradeoff rather than a ratchet. A creature that breeds at 80 produces many
%% children who each start with 40 and are one bad patch from starving. One that
%% breeds at 300 produces few, each starting with 150 and able to survive a
%% search. Early-and-many against late-and-fewer-but-sturdier is the classic r/K
%% axis, and which end wins is a property of the ENVIRONMENT, not of the trait.
%%
%% Without the dowry scaling, a lower threshold would simply be better
%% everywhere and the trait would collapse to its floor on every island, which
%% is a slower way of writing a constant.
breed_everyone(#world{creatures = Cs} = W) ->
    lists:foldl(fun breed_one/2, W, lists:sort(maps:keys(Cs))).

breed_one(Id, #world{creatures = Cs} = W) ->
    #{energy := E, breed_at := Threshold} = maps:get(Id, Cs),
    breed(E >= Threshold, Id, W).

breed(false, _Id, W) -> W;
breed(true, Id, #world{creatures = Cs, econ = Econ} = W) ->
    room(map_size(Cs) < maps:get(max_creatures, Econ), Id, W).

room(false, _Id, #world{births_refused = R} = W) ->
    W#world{births_refused = R + 1};
room(true, Id, #world{creatures = Cs, econ = Econ, rng = Rng0} = W) ->
    #{at := At, energy := E, breed_at := Threshold,
      body := Body, brain := Brain} = C = maps:get(Id, Cs),
    Dowry = Threshold div 2,
    {Where, Rng1} = pick(hex:neighbours_in(At, maps:get(radius, Econ)), Rng0),
    {Traits, Rng2} = inherit_traits(Threshold, Body, Brain, Econ, Rng1),
    W1 = W#world{creatures = Cs#{Id => C#{energy => E - Dowry}}, rng = Rng2},
    add_creature(Where, Dowry, Id, Traits, W1).

%% Three heritable things, mutated independently. A child is its parent in body,
%% brain and life history, each nudged a little, which is what makes a lineage a
%% lineage rather than a sequence of unrelated draws.
inherit_traits(Threshold, Body, Brain, Econ, Rng0) ->
    {BreedAt, Rng1} = inherit(Threshold, Econ, Rng0),
    {ChildBody, Rng2} = body:inherit(Body, Econ, Rng1),
    {ChildBrain, Rng3} = brain:inherit(Brain, Econ, Rng2),
    {#{breed_at => BreedAt, body => ChildBody, brain => ChildBrain}, Rng3}.

%% A child is its parent plus a nudge. Mutation is symmetric and small, so a
%% lineage drifts rather than jumping, and selection has something to act on
%% without the trait becoming noise.
inherit(Threshold, Econ, Rng0) ->
    Mut = maps:get(breed_mutation, Econ),
    {Step, Rng1} = rand:uniform_s(2 * Mut + 1, Rng0),
    {clamp(Threshold + Step - Mut - 1, Econ), Rng1}.

clamp(V, Econ) ->
    max(maps:get(breed_floor, Econ), min(maps:get(breed_ceiling, Econ), V)).

%% Death has two causes and they are counted separately, because "the population
%% crashed" and "the population aged out" are different findings and a single
%% total cannot tell them apart.
reap(#world{creatures = Cs, econ = Econ} = W) ->
    MaxAge = maps:get(max_age, Econ),
    Reaped = maps:fold(fun(Id, C, Acc) -> reap_one(Id, C, MaxAge, Acc) end,
                       W#world{creatures = #{}}, Cs),
    note_extinction(map_size(Reaped#world.creatures), Reaped).

%% Recorded once, on the transition, and never revised. A world that was already
%% extinct keeps its original tick rather than restamping it every tick, which
%% would turn the one interesting number into the current one.
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

%%==============================================================================
%% Reading a world
%%==============================================================================

-spec snapshot(world()) -> map().
snapshot(#world{} = W) ->
    #{tick => W#world.tick,
      population => map_size(W#world.creatures),
      plants => map_size(W#world.plants),
      born => W#world.born,
      starved => W#world.starved,
      aged_out => W#world.aged_out,
      eaten => W#world.eaten,
      killed => W#world.killed,
      births_refused => W#world.births_refused,
      %% WHAT THE POPULATION TURNED OUT TO BE, counted from what creatures
      %% actually ate. Nothing was assigned; if every count but `herbivores' is
      %% zero then predation was available and nobody took it, which is a result.
      diet => diet(W),
      %% WHETHER CAPABILITY IS PAYING FOR ITSELF. An organ whose prevalence falls
      %% costs more than it earns in this world, and that is a fact about the
      %% world rather than about the organ.
      organs => organs(W),
      energy_total => total_energy(W),
      radius => maps:get(radius, W#world.econ),
      econ => W#world.econ,
      econ_id => econ_id(W#world.econ),
      extinct_at => W#world.extinct_at,
      %% WHAT THE POPULATION HAS BECOME. The whole point of a heritable trait is
      %% that it moves, and a mean is the smallest thing that shows it moving.
      %% Reported as an integer because everything on the wire is.
      breed_at_mean => mean_breed_at(W)}.

%% DIET IS OBSERVED, NEVER DECLARED. A creature is whatever its last several
%% meals say it is, so a lineage that loses access to prey stops being
%% carnivorous without anything having to relabel it.
%%
%% THE UNDECIDED BUCKET IS LOAD-BEARING. A newborn has eaten nothing, and calling
%% it a herbivore on the strength of zero meals would fill a fast-breeding world
%% with imaginary vegetarians and hide whatever the adults are doing. Below four
%% meals a creature is counted as not yet having a diet, which is the truth.
diet(#world{creatures = Cs}) ->
    Empty = #{herbivores => 0, omnivores => 0, carnivores => 0, undecided => 0},
    lists:foldl(fun tally/2, Empty, maps:values(Cs)).

tally(#{grazed := G, hunted := H}, Acc) ->
    maps:update_with(classify(G + H, H), fun(N) -> N + 1 end, Acc).

classify(Meals, _Hunted) when Meals < ?DIET_MEALS -> undecided;
classify(Meals, Hunted) when Hunted * 100 >= ?CARNIVORE_PCT * Meals -> carnivores;
classify(Meals, Hunted) when Hunted * 100 =< ?HERBIVORE_PCT * Meals -> herbivores;
classify(_Meals, _Hunted) -> omnivores.

organs(#world{creatures = Cs}) ->
    body:prevalence([B || #{body := B} <- maps:values(Cs)]).

%% Zero for an empty world rather than a crash or a nonsense average.
mean_breed_at(#world{creatures = Cs}) when map_size(Cs) =:= 0 -> 0;
mean_breed_at(#world{creatures = Cs}) ->
    Total = maps:fold(fun(_Id, #{breed_at := B}, Acc) -> Acc + B end, 0, Cs),
    Total div map_size(Cs).

%% @doc A short, stable fingerprint of the rules this world runs under.
%%
%% TWO ISLANDS RUNNING DIFFERENT ECONOMIES ARE NOT COMPARABLE, and nothing else
%% on the wire would say so. Differentiated local pressure is the whole point of
%% having more than one island, so they will deliberately differ, and a reader
%% plotting two populations against each other would silently be comparing two
%% different games. This is the field that stops that, and it is the same idea as
%% the engine fingerprint the sibling rumbler carries.
%%
%% CANONICAL BYTES, HAND-BUILT, and term_to_binary is deliberately not used. Its
%% output is only stable WITHIN an OTP release: atom encoding has changed between
%% releases, so two honest islands on different releases would compute different
%% ids for identical rules, which destroys the only property a fingerprint has.
%% Sorted `key=value' pairs have no runtime freedom left in them.
%%
%% Eight bytes rather than thirty-two, because this is read by a human off a page
%% to answer "same rules or not", and sixteen hex characters is already far more
%% than the number of distinct economies that will ever exist.
-spec econ_id(econ()) -> binary().
econ_id(Econ) ->
    Pairs = [[atom_to_list(K), $=, integer_to_list(V)]
             || {K, V} <- lists:sort(maps:to_list(Econ))],
    Canonical = lists:join($,, Pairs),
    <<Short:8/binary, _/binary>> = crypto:hash(sha256, iolist_to_binary(Canonical)),
    string:lowercase(binary:encode_hex(Short)).

%% @doc Where everything is, as two flat lists of coordinates: `[Q1, R1, Q2, R2
%% | ...]'. This is what a spectator draws.
%%
%% FLAT INTEGERS RATHER THAN A LIST OF PAIRS, because a pair is a tuple and
%% tuples do not survive this mesh cleanly, and because a map per entity would
%% repeat the keys `q' and `r' a hundred and seventy times per frame for no
%% information. The stride is two and it never changes; a reader chunks by two.
%%
%% POSITIONS ONLY. Not energy, not age, not lineage. A view that wants to colour
%% a creature by how hungry it is can have that, and the honest way to give it is
%% a version bump rather than fields shipped now on the chance somebody uses
%% them.
%%
%% Sorted by creature id so two charts of the same world are the same bytes,
%% which makes a diff between frames mean something.
%% The radius travels with the chart so a viewer sizes its board from the fact
%% rather than from configuration that has to be kept in agreement with a world
%% it cannot see.
-spec chart(world()) -> #{creatures := [integer()], plants := [integer()],
                          radius := non_neg_integer(), tick := non_neg_integer()}.
chart(#world{creatures = Cs, plants = Plants, econ = Econ, tick = Tick}) ->
    Positions = [maps:get(at, maps:get(Id, Cs)) || Id <- lists:sort(maps:keys(Cs))],
    #{creatures => flatten_hexes(Positions),
      plants => flatten_hexes(lists:sort(maps:keys(Plants))),
      radius => maps:get(radius, Econ),
      tick => Tick}.

flatten_hexes(Hexes) -> lists:append([[Q, R] || {Q, R} <- Hexes]).

%% The single number that says whether the books balance. Energy enters only by
%% eating and leaves only by metabolism and movement, so a run whose total climbs
%% without plants being eaten has a leak somewhere.
total_energy(#world{creatures = Cs}) ->
    maps:fold(fun(_Id, #{energy := E}, Acc) -> Acc + E end, 0, Cs).

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

%% Rejection sampling: a bounding box on a hex disc is about 3/4 disc, so this
%% retries rarely and is uniform, which sampling the box and clamping would not
%% be. Clamping would pile every out-of-range draw onto the rim.
retry(true, H, _Radius, Rng) -> {H, Rng};
retry(false, _H, Radius, Rng) -> random_cell(Radius, Rng).

pick([], Rng) -> {{0, 0}, Rng};
pick(Options, Rng0) ->
    {N, Rng1} = rand:uniform_s(length(Options), Rng0),
    {lists:nth(N, Options), Rng1}.

%% Decorate, sort, undecorate. A Fisher-Yates would use fewer draws, but this is
%% a third of the code, is obviously unbiased, and the list being shuffled is
%% about to be folded over anyway. Ties fall back to id order, so the result is
%% still a function of the seed alone.
shuffle(Ids, Rng0) ->
    {Tagged, Rng1} = lists:mapfoldl(fun tag/2, Rng0, Ids),
    {[Id || {_Key, Id} <- lists:sort(Tagged)], Rng1}.

tag(Id, Rng0) ->
    {Key, Rng1} = rand:uniform_s(1 bsl 32, Rng0),
    {{Key, Id}, Rng1}.
