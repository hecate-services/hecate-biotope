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
-export([world_advanced/2, world_charted/2]).

-define(DEFAULT_NS, <<"biotope">>).
-define(FACT_VERSION, 4).

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
world_advanced(Snapshot, Pace) ->
    #{tick := Tick, population := Pop, born := Born,
      starved := Starved, aged_out := Aged, consumed := Consumed,
      absorbed := Absorbed, births_refused := Refused,
      energy_total := Energy, radius := Radius, econ := Econ, econ_id := EconId,
      extinct_at := ExtinctAt, from_creatures_pct := FromCreatures,
      sensors := Sensors, sensor_mean := SensorMean,
      sensor_hist := SensorHist, hidden_hist := HiddenHist,
      uptake_hist := UptakeHist,
      sensors_gained := Gained, sensors_lost := Lost,
      ground_total := GroundTotal, ground_spread := GroundSpread,
      still_pct := Still, hidden_mean := HiddenMean,
      movers := Movers, breeders := Breeders,
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
    extinction(Fact, ExtinctAt).

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

%% @doc Where everything is. Ephemeral by nature: nobody wants last Tuesday's
%% frame, so a reader is expected to hold the latest and drop the rest.
%%
%% `creatures' and `plants' are flat coordinate lists with a stride of two,
%% `[Q1, R1, Q2, R2 | ...]'. `radius' is carried so a viewer can size the board
%% from the fact alone rather than being configured to agree with the world.
-spec world_charted(map(), world_pace:pace()) -> map().
world_charted(Chart, Pace) ->
    #{creatures := Creatures, energies := Energies, signatures := Signatures,
      uptakes := Uptakes, ground := Ground, scent := Scent, radius := Radius,
      tick := Tick} = Chart,
    #{type => world_charted,
      fact_version => ?FACT_VERSION,
      island => island(),
      tick => Tick,
      radius => Radius,
      stride => 2,
      creatures => Creatures,
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
