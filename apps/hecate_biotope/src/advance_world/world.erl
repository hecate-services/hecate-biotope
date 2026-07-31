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
%% ONE TROPHIC LEVEL SO FAR: plants and the things that eat them. No predators
%% yet, deliberately. The Flatland experiments found no coexistence regime for an
%% open predator-prey population with fixed behaviours, collapsing to mutual
%% extinction in about one predator generation. A consumer and its resource is a
%% much older and far better behaved system, and it is the floor the rest stands
%% on. Predation arrives when creatures can be different from one another, which
%% is what organs are for.
%%
%% CREATURES RANDOM-WALK, AND THAT IS A CHOICE RATHER THAN A PLACEHOLDER. A
%% random walker has no perception, so it cannot prejudge what senses should
%% exist. It is also permanently useful: it is the null forager every later brain
%% has to beat, and a population of them tells you what the economy gives away
%% for free. A brain that cannot beat a coin is not a brain.
%%
%% NO PROCESS PER CREATURE YET. A creature with no brain has nothing to decide,
%% and a process that ticks without deciding anything is the exact shape swai
%% carried for a year. When creatures have organs and a brain, the world will ask
%% them for an intent instead of drawing one.
-module(world).

-export([new/0, new/1, tick/1, tick/2, snapshot/1, chart/1, defaults/0, econ_id/1]).
-export([population/1, plant_count/1, at_tick/1, alive/2]).

-type hex() :: hex:hex().
-type id() :: pos_integer().

%% Position, energy, age and parentage. Parentage is carried from the first
%% version because a lineage that is not recorded as it happens cannot be
%% recovered afterwards, and it costs one integer.
-type creature() :: #{id := id(),
                      at := hex(),
                      energy := integer(),
                      age := non_neg_integer(),
                      born := non_neg_integer(),
                      parent := id() | none}.

-type econ() :: #{plant_energy := pos_integer(),
                  regrowth_per_tick := non_neg_integer(),
                  metabolism := non_neg_integer(),
                  move_cost := non_neg_integer(),
                  breed_at := pos_integer(),
                  breed_cost := pos_integer(),
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
      breed_at          => 160,
      breed_cost        => 80,
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
    populate(maps:get(population, Opts, 40), W).

populate(0, W) -> W;
populate(N, #world{econ = Econ, rng = Rng0} = W) ->
    Radius = maps:get(radius, Econ),
    {At, Rng1} = random_cell(Radius, Rng0),
    populate(N - 1, add_creature(At, maps:get(start_energy, Econ), none,
                                 W#world{rng = Rng1})).

add_creature(At, Energy, Parent, #world{next_id = Id, creatures = Cs,
                                        tick = T, born = B} = W) ->
    C = #{id => Id, at => At, energy => Energy, age => 0,
          born => T, parent => Parent},
    W#world{next_id = Id + 1, creatures = Cs#{Id => C}, born = B + 1}.

%%==============================================================================
%% The tick
%%==============================================================================

-spec tick(world()) -> world().
tick(W) -> tick(W, 1).

%% SIX PHASES IN A FIXED ORDER, because the order is a rule of the world and not
%% an implementation detail. Charging metabolism before movement means a creature
%% that cannot afford to exist does not get a free step first; resolving eating
%% after movement means arriving on a plant feeds you this tick rather than next.
-spec tick(world(), non_neg_integer()) -> world().
tick(W, 0) -> W;
tick(W, N) ->
    W1 = charge_living(W),
    W2 = move_everyone(W1),
    W3 = feed_everyone(W2),
    W4 = breed_everyone(W3),
    W5 = reap(W4),
    W6 = regrow(W5),
    tick(W6#world{tick = W6#world.tick + 1}, N - 1).

%% Existing costs energy, every tick, unconditionally. This is the line that
%% organ upkeep is added to.
charge_living(#world{creatures = Cs, econ = Econ} = W) ->
    Cost = maps:get(metabolism, Econ),
    W#world{creatures = maps:map(fun(_Id, C) -> spend(C, Cost) end, Cs)}.

spend(#{energy := E} = C, Cost) -> C#{energy => E - Cost}.

%% Everyone steps to a random neighbour and pays for it. Ordered by id so a tick
%% is a function of the world and not of map iteration order.
move_everyone(#world{creatures = Cs} = W) ->
    lists:foldl(fun move_one/2, W, lists:sort(maps:keys(Cs))).

move_one(Id, #world{creatures = Cs, econ = Econ, rng = Rng0} = W) ->
    #{at := At} = C = maps:get(Id, Cs),
    Options = hex:neighbours_in(At, maps:get(radius, Econ)),
    {To, Rng1} = pick(Options, Rng0),
    Moved = spend(C#{at => To}, maps:get(move_cost, Econ)),
    W#world{creatures = Cs#{Id => Moved}, rng = Rng1}.

%% A plant feeds exactly one creature. Contested cells go to the lowest id, which
%% is arbitrary but fixed: an arbitrary rule applied consistently is a rule,
%% while resolving by whoever the map yields first is a coin nobody can inspect.
feed_everyone(#world{creatures = Cs} = W) ->
    lists:foldl(fun feed_one/2, W, lists:sort(maps:keys(Cs))).

feed_one(Id, #world{creatures = Cs, plants = Plants, econ = Econ,
                    eaten = Eaten} = W) ->
    #{at := At} = C = maps:get(Id, Cs),
    feed(maps:is_key(At, Plants), Id, C, At, W, Plants, Econ, Eaten).

feed(false, _Id, _C, _At, W, _Plants, _Econ, _Eaten) -> W;
feed(true, Id, #{energy := E} = C, At, #world{creatures = Cs} = W,
     Plants, Econ, Eaten) ->
    Fed = C#{energy => E + maps:get(plant_energy, Econ)},
    W#world{creatures = Cs#{Id => Fed},
            plants = maps:remove(At, Plants),
            eaten = Eaten + 1}.

%% A surplus buys a child, placed on a neighbouring cell. The parent pays more
%% than the child receives is NOT the rule here: it pays exactly what the child
%% gets, so energy is conserved at birth and the only sink is metabolism. That
%% keeps the books readable while the economy is being tuned.
breed_everyone(#world{creatures = Cs} = W) ->
    lists:foldl(fun breed_one/2, W, lists:sort(maps:keys(Cs))).

breed_one(Id, #world{creatures = Cs, econ = Econ} = W) ->
    #{energy := E} = maps:get(Id, Cs),
    breed(E >= maps:get(breed_at, Econ), Id, W).

breed(false, _Id, W) -> W;
breed(true, Id, #world{creatures = Cs, econ = Econ} = W) ->
    room(map_size(Cs) < maps:get(max_creatures, Econ), Id, W).

room(false, _Id, #world{births_refused = R} = W) ->
    W#world{births_refused = R + 1};
room(true, Id, #world{creatures = Cs, econ = Econ, rng = Rng0} = W) ->
    #{at := At, energy := E} = C = maps:get(Id, Cs),
    Cost = maps:get(breed_cost, Econ),
    {Where, Rng1} = pick(hex:neighbours_in(At, maps:get(radius, Econ)), Rng0),
    W1 = W#world{creatures = Cs#{Id => C#{energy => E - Cost}}, rng = Rng1},
    add_creature(Where, Cost, Id, W1).

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
      births_refused => W#world.births_refused,
      energy_total => total_energy(W),
      radius => maps:get(radius, W#world.econ),
      econ => W#world.econ,
      econ_id => econ_id(W#world.econ),
      extinct_at => W#world.extinct_at}.

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
