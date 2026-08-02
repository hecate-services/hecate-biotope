%% @doc What a biotope says about itself, and where it says it. PURE.
%%
%% TWO FACTS, DELIBERATELY SEPARATE.
%%
%%   `world_advanced'  counts and totals, for statistics over time
%%   `world_charted'   where everything is, for a picture
%%
%% Folding the positions into the counts would make a statistics reader pay for
%% a hundred and seventy coordinates it will never draw, and would force both to
%% share one rate when they want different ones: a chart wants to keep up with
%% the eye, and a statistic wants to be small enough to keep forever.
%%
%% THE ISLAND ID IS IN THE PAYLOAD AND NEVER IN THE TOPIC. Putting it in the
%% topic is the mistake that scales worst: a thousand islands become a thousand
%% topics, subscription management collapses, and a reader who wants "all
%% islands" cannot ask for it. One topic, an `island' field, and a subscriber
%% filters. The namespace separates whole DEPLOYMENTS, not islands.
%%
%% TOTALS RATHER THAN RATES, because a rate is recoverable from two totals and a
%% total is not recoverable from rates. A reader that misses a fact can still
%% work out what happened across the gap.
%%
%% THE TICK IS ON EVERY FACT, and it is not decoration. Publishing runs on wall
%% clock and the world runs on its own pace, so two consecutive facts may be one
%% tick apart or a million. Without the tick a reader cannot tell a stalled world
%% from a slow one.
%%
%% WIRE RULES, each earned by something that broke elsewhere: atom keys only, no
%% tuples as values, integers rather than floats. A tuple does not survive the
%% encoder cleanly, and an atom key and a binary key of the same name collide
%% into one.
-module(world_facts).

-export([topic/1, namespace/0, island/0]).
-export([world_advanced/2, world_advanced/5, world_advanced/6,
         world_charted/2]).

-define(DEFAULT_NS, <<"biotope">>).
-define(FACT_VERSION, 10).

%% Topics are `<namespace>/<leaf>'. The namespace tells one deployment from
%% another, for instance a laptop from the fleet, and is NOT how islands are
%% distinguished.
-spec topic(atom()) -> binary().
topic(world) -> leaf(<<"world">>);
topic(chart) -> leaf(<<"chart">>).

leaf(Leaf) -> <<(namespace())/binary, "/", Leaf/binary>>.

-spec namespace() -> binary().
namespace() -> ns(os:getenv("HECATE_BIOTOPE_NS")).

ns(false) -> ?DEFAULT_NS;
ns("") -> ?DEFAULT_NS;
ns(Str) -> list_to_binary(string:trim(Str)).

%% @doc Which island this is. Defaults to the host's name, because a machine
%% already has an identity and inventing a second one that nobody configures
%% produces a fleet of islands all called "biotope".
-spec island() -> binary().
island() -> island_name(os:getenv("HECATE_BIOTOPE_ISLAND")).

island_name(false) -> hostname();
island_name("") -> hostname();
island_name(Str) -> list_to_binary(string:trim(Str)).

hostname() ->
    {ok, Host} = inet:gethostname(),
    list_to_binary(Host).

%%==============================================================================
%% The facts
%%==============================================================================

%% @doc Counts and totals. Small enough to keep forever.
-spec world_advanced(map(), world_pace:pace()) -> map().
world_advanced(Snapshot, Pace) -> world_advanced(Snapshot, Pace, 1, undefined, 0).

%% @doc As above, saying which RUN this is on this island.
%%
%% A world that ended stays ended; an island that has finished one begins
%% another, and a spectator watching the tick drop back to nothing deserves to be
%% told that rather than left to read it as a glitch. `previous_end' is the tick
%% the last world died on, so the ending survives the world that owned it.
-spec world_advanced(map(), world_pace:pace(), pos_integer(),
                     non_neg_integer() | undefined, non_neg_integer()) -> map().
world_advanced(Snapshot, Pace, Run, PreviousEnd, Rejected) ->
    world_advanced(Snapshot, Pace, Run, PreviousEnd, Rejected, undefined).

%% @doc As above, saying WHICH DOOR this island reaches the mesh through.
%%
%% IT TRAVELS ON EVERY FACT rather than in a roster published once, for the same
%% reason the economy does: a spectator that arrives late would otherwise be
%% looking at islands it cannot tell apart, and three short strings a second is
%% not a cost. It also means a link that drops is visible in the next fact rather
%% than in a caption nobody refreshes.
%%
%% `undefined' when the door could not be read, which is not the same as being
%% disconnected: one says the island cannot see its own link, the other says the
%% link is down. The fact distinguishes them.
-spec world_advanced(map(), world_pace:pace(), pos_integer(),
                     non_neg_integer() | undefined, non_neg_integer(),
                     map() | undefined) -> map().
world_advanced(Snapshot, Pace, Run, PreviousEnd, Rejected, Station) ->
    #{tick := Tick, population := Pop, born := Born,
      starved := Starved, aged_out := Aged, consumed := Consumed,
      absorbed := Absorbed, births_refused := Refused,
      energy_total := Energy, radius := Radius, econ := Econ, econ_id := EconId, seed := Seed,
      extinct_at := ExtinctAt, from_creatures_pct := FromCreatures,
      sensors := Sensors, sensor_mean := SensorMean,
      sensor_hist := SensorHist, hidden_hist := HiddenHist,
      uptake_hist := UptakeHist,
      sensors_gained := Gained, sensors_lost := Lost,
      ground_total := GroundTotal, ground_spread := GroundSpread,
      still_pct := Still, hidden_mean := HiddenMean,
      movers := Movers, breeders := Breeders,
      dissipated := Dissipated, structure_total := StructureTotal,
      structure_max := StructureMax, lineages := Lineages, depth := Depth,
      uptake_min := UptakeMin, uptake_max := UptakeMax,
      eaten_age_mean := EatenAge,
      scent_tags := Tags, scent_spread := Spread} = Snapshot,
    Fact = #{type => world_advanced,
      fact_version => ?FACT_VERSION,
      island => island(),
      tick => Tick,
      population => Pop,
      ground_total => GroundTotal,
      energy_total => Energy,
      radius => Radius,
      %% WHICH RULES THIS ISLAND RUNS. The id answers "are these two islands the
      %% same experiment", the values answer "how do they differ". Both travel on
      %% every fact rather than in a roster published once, because a spectator
      %% that arrives late would otherwise be comparing islands it cannot
      %% distinguish, and ten small integers a second is not a cost.
      econ_id => EconId,
      econ => Econ,
      %% WHICH NUMBER THIS WORLD UNFOLDED FROM. A world is a pure function of its
      %% seed, so publishing it makes any island anyone happens to be watching
      %% exactly reproducible offline, at whatever horizon they like.
      %%
      %% It is also what lets a live island draw a FRESH seed at boot instead of
      %% replaying the identical life after every restart. Reproducible science
      %% and an unrepeatable exhibit only ever conflicted while this was secret.
      seed => Seed,
      run => Run,
      %% HOW MANY CANDIDATE SEEDS WERE DRAWN AND FOUND DEAD before this one.
      %%
      %% A world is a pure function of its seed, so an island can run a
      %% candidate headless through its founding phase and keep it only if it is
      %% still alive. World 12 kills eight seeds in twelve, so a fleet drawing
      %% freely spends most of its time showing worlds in the act of failing.
      %%
      %% THE COUNT IS ON THE WIRE BECAUSE A SCREENED FLEET IS A BIASED SAMPLE.
      %% The offline sweeps stay the unbiased record; these islands show worlds
      %% that got past their founding, and every fact says how many did not. The
      %% criterion is viability and nothing else: never the population reached,
      %% never the depth, only being alive.
      seeds_rejected => Rejected,
      %% WHICH WORLD, and one sentence describing it. The econ id above says
      %% whether two islands are comparable and cannot say WHAT either of them
      %% is: two islands can share every constant and still be running different
      %% physics, because the rules live in code and the constants do not.
      %%
      %% A fleet is redeployed island by island, so during a rollout the cards
      %% genuinely disagree, and a reader with no way to see that is left
      %% comparing two experiments as though they were one.
      world => maps:get(number, world:ruleset()),
      world_line => maps:get(line, world:ruleset()),
      %% WHAT THE POPULATION TURNED OUT TO BE, all of it observational. Nothing
      %% here is read by the physics and no creature is treated differently for
      %% what any of it says, which is what makes it legitimate to publish at
      %% all: these are descriptions applied afterwards, not categories the world
      %% enforces.
      %%
      %% `from_creatures_pct' is the share of all energy the living have eaten
      %% that came from other creatures. Zero means nothing alive has ever eaten
      %% anything that could have eaten it back.
      from_creatures_pct => FromCreatures,
      %% THE PLANT-NESS OF THE POPULATION, observed and never declared: the
      %% percentage that did not move this tick. A creature that stays where it
      %% is and lives off what gathers there IS a plant, and nothing in the rules
      %% calls it one. There are no plants to count because there is no such
      %% kind of thing.
      still_pct => Still,
      %% HOW UNEVENLY THE GROUND HOLDS ENERGY: the percentage lying in the
      %% richest tenth of cells. Ten is flat. Above that, places have become
      %% different from each other, and since no terrain was installed, whatever
      %% difference exists was made by things dying.
      ground_spread => GroundSpread,
      %% How much brain a creature carries, and how many can move or reproduce
      %% at all. An absent output is not a weak one: it is a creature that never
      %% does that thing.
      hidden_mean => HiddenMean,
      movers => Movers,
      breeders => Breeders,
      %% Per field: how many creatures carry a sensor for it, and the total reach
      %% devoted to it. `sensor_mean' is sensors per creature, times a hundred,
      %% because everything on this wire is an integer.
      sensors => Sensors,
      sensor_mean => SensorMean,
      %% THE SHAPE OF THE POPULATION AND NOT ITS AVERAGE. How many creatures
      %% carry none, one, two and so on. A mean of 0.01 reads as "nearly none"
      %% without saying whether that is one creature in a hundred or something
      %% else; a distribution pinned wholly at zero cannot be skimmed past.
      %% Short fixed-length lists, a handful of integers a second.
      sensor_hist => SensorHist,
      hidden_hist => HiddenHist,
      %% Binned across the feeding range, which is the one that varies today.
      uptake_hist => UptakeHist,
      %% WHETHER THE BODY PLAN IS STILL MOVING. A census says what the population
      %% is built from now; these say whether that is settled or still churning,
      %% which a census alone cannot distinguish.
      sensors_gained => Gained,
      sensors_lost => Lost,
      %% Properties of the SIGNATURE, independent of whether anything evolved to
      %% use it. One distinct tag means the whole population is mutual kin.
      scent_tags => Tags,
      scent_spread => Spread,
      %% ==================================================================
      %% THE ENTROPY ACCOUNT, WHICH IS THE ONE NUMBER THAT CANNOT GO DOWN
      %% ==================================================================
      %%
      %% Every unit ever spent on living, in heat. At one temperature this IS the
      %% entropy of this world, so the Second Law is the statement that this line
      %% only ever rises, and a reader can watch it do so.
      %%
      %% IT IS ALSO THE THIRD TERM THAT CLOSES THE BOOKS. Energy is in the ground,
      %% in creatures, or already burnt. Ground plus creatures plus this changes
      %% only by what the sun adds, so a spectator can check the First Law
      %% arithmetic itself rather than taking the island's word for it. That was
      %% impossible to publish before because two of the three terms were on the
      %% wire and the third was not.
      dissipated => Dissipated,
      %% WHAT THE POPULATION IS BUILT OF, as against what it is carrying. Since
      %% world 6 these are different quantities with opposite physics, and since
      %% world 8 the frame is what a creature can feed through. A contest is
      %% decided on structure alone, so this is the quantity that says who wins
      %% one, and the store never was.
      structure_total => StructureTotal,
      structure_max => StructureMax,
      %% ==================================================================
      %% WHETHER THE POPULATION CAN STILL CHANGE, WHICH IS NOT WHAT IT IS
      %% ==================================================================
      %%
      %% World 8 ended with creatures carrying four hundred times what they were
      %% founded with, and it ended because nothing had been born since tick 15.
      %% Every number above describes a population and not one of them could tell
      %% those two apart. Fisher prices adaptation in the variance available to
      %% select on: no variance, no adaptation, at any wealth.
      %%
      %% `depth' is generations in the deepest living line, so ZERO MEANS EVERY
      %% CREATURE ALIVE IS A FOUNDER and the world has selected nothing at all.
      %% `lineages' is how many separate foundings still have descendants.
      lineages => Lineages,
      depth => Depth,
      %% The range of the one heritable quantity that visibly varies. Selection
      %% has nothing to act on when this closes to nothing.
      %% HOW MUCH MOUTH THE POPULATION CARRIES. A histogram and not a share,
      %% because whether one population holds two ways of living is a statement
      %% about the SHAPE of the distribution. And not called `carnivores_pct',
      %% because that named a type in a world that has none.
      mouth_mean => maps:get(mouth_mean, Snapshot),
      mouth_hist => maps:get(mouth_hist, Snapshot),
      uptake_min => UptakeMin,
      uptake_max => UptakeMax,
      %% HOW OLD THE EATEN WERE, in hundredths of a tick. A living made off other
      %% creatures and a living made off newborns are different findings, and
      %% neither the share nor the count can tell them apart.
      eaten_age_mean => EatenAge,
      %% Totals since the world began, never reset.
      born => Born,
      starved => Starved,
      aged_out => Aged,
      consumed => Consumed,
      absorbed => Absorbed,
      %% Non-zero means the safety valve bound and the population is NOT at a
      %% natural ceiling. Published so that never has to be guessed from shape.
      births_refused => Refused,
      ticks_per_second => world_pace:ticks_per_second(Pace)},
    through(previously(extinction(Fact, ExtinctAt), PreviousEnd), Station).

%% THE DOOR, MERGED WHOLE OR NOT AT ALL. Absent when the island could not read
%% its own link, which is a different thing from the link being down: one says it
%% cannot see, the other says nobody answered. A sentinel host of "none" would
%% collapse the two, and a reader plotting uptime would count blindness as an
%% outage.
through(Fact, undefined) -> Fact;
through(Fact, Station) when is_map(Station) -> maps:merge(Fact, Station).

%% PRESENT ONLY WHEN IT HAPPENED, rather than a sentinel value meaning "not
%% yet". A tick of -1 or 0 for a living world is the kind of number that gets
%% plotted by accident, and an atom like `undefined' would arrive as the STRING
%% "undefined" because CBOR has no atoms. A missing key is unambiguous in every
%% language that will ever read this.
%%
%% EXTINCTION IS PERMANENT AND THEREFORE WORTH NAMING. A dead island keeps
%% publishing: its plants regrow, its tick advances, and every fact after the
%% last death looks identical to the one before. Population zero says the world
%% is empty NOW; this says when it emptied, which is the part no later sample
%% carries.
extinction(Fact, undefined) -> Fact;
extinction(Fact, Tick) -> Fact#{extinct_at => Tick}.

%% OMITTED RATHER THAN NULL on a first run, for the same reason `extinct_at' is:
%% a key that is absent says "this has not happened", and a zero would say "it
%% ended at tick nought", which is a different and alarming claim.
previously(Fact, undefined) -> Fact;
previously(Fact, Tick) -> Fact#{previous_end => Tick}.

%% @doc Where everything is. Ephemeral by nature: nobody wants last Tuesday's
%% frame, so a reader is expected to hold the latest and drop the rest.
%%
%% `creatures' and `plants' are flat coordinate lists with a stride of two,
%% `[Q1, R1, Q2, R2 | ...]'. `radius' is carried so a viewer can size the board
%% from the fact alone rather than being configured to agree with the world.
-spec world_charted(map(), world_pace:pace()) -> map().
world_charted(Chart, Pace) ->
    #{creatures := Creatures, ids := Ids, energies := Energies,
      structures := Structures, signatures := Signatures,
      uptakes := Uptakes, ground := Ground, scent := Scent, radius := Radius,
      tick := Tick} = Chart,
    #{type => world_charted,
      fact_version => ?FACT_VERSION,
      island => island(),
      tick => Tick,
      radius => Radius,
      stride => 2,
      creatures => Creatures,
      %% WHO EACH MARK IS, parallel to `creatures'. A frame can be drawn without
      %% it; two frames cannot be animated between without it, because a mean
      %% lifespan of about two ticks means the list is reshuffled by births and
      %% deaths between every pair of frames.
      ids => Ids,
      %% THE GROUND AS POSITION AND AMOUNT, at a stride of three. Only cells
      %% holding something are sent: an empty one is drawn bare, and on a grazed
      %% board most of them are. This replaces the plant list, because a plant
      %% was never a kind of thing and there is nothing left to enumerate.
      ground => Ground,
      ground_stride => 3,
      %% ONE ENERGY PER CREATURE, IN THE SAME ORDER, as a parallel list rather
      %% than interleaved. Interleaving would make the creature stride 3 while
      %% plants stayed 2, and a reader that got that wrong would draw a
      %% plausible and completely wrong picture instead of failing.
      %%
      %% Worth its bytes because ENERGY IS ARMOUR here: the stronger consumes
      %% the weaker, so the size of a dot is the single most informative thing
      %% about it, and without this every creature is drawn identical.
      energies => Energies,
      %% WHAT EACH ONE IS BUILT OF, parallel to `creatures'.
      %%
      %% `chart/1' has computed this since world 6 and this function DROPPED IT,
      %% so a spectator asking for the body got nothing and fell back to the
      %% store. World 10 changed the renderer to size a creature by its body,
      %% because every contest is decided on structure alone, and that change has
      %% never once been in effect on a live island: the number it needs was
      %% never on the wire.
      %%
      %% The same shape as B.7 and C.6 in the register. Each function was right
      %% and the gap between them was not, and the test that should have caught
      %% it fed the renderer a chart by hand instead of the fact an island sends.
      structures => Structures,
      %% ONE SIGNATURE PER CREATURE, same order again. A creature reads a trail
      %% by how unlike itself it smells, so this is what kinship IS here, and
      %% comparing creatures against each other is the only way to see whether a
      %% population has become one family or several.
      signatures => Signatures,
      %% HOW FAST EACH ONE FEEDS, same order again. A quantity a viewer can put
      %% on a scale, unlike a signature: below what the ground sustains is a
      %% creature that can hold its cell indefinitely, above it one that strips
      %% the cell and must move or starve.
      uptakes => Uptakes,
      %% Position AND strength, interleaved at a stride of three, because a mark
      %% has no list to run parallel to. The signature is deliberately left out:
      %% it would double the payload and a spectator has nothing to compare it
      %% against.
      scent => Scent,
      scent_stride => 3,
      ticks_per_second => world_pace:ticks_per_second(Pace)}.
