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
-define(FACT_VERSION, 1).

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
    #{tick := Tick, population := Pop, plants := Plants, born := Born,
      starved := Starved, aged_out := Aged, eaten := Eaten,
      births_refused := Refused, energy_total := Energy,
      radius := Radius, econ := Econ, econ_id := EconId,
      extinct_at := ExtinctAt} = Snapshot,
    Fact = #{type => world_advanced,
      fact_version => ?FACT_VERSION,
      island => island(),
      tick => Tick,
      population => Pop,
      plants => Plants,
      energy_total => Energy,
      radius => Radius,
      %% WHICH RULES THIS ISLAND RUNS. The id answers "are these two islands the
      %% same experiment", the values answer "how do they differ". Both travel on
      %% every fact rather than in a roster published once, because a spectator
      %% that arrives late would otherwise be comparing islands it cannot
      %% distinguish, and ten small integers a second is not a cost.
      econ_id => EconId,
      econ => Econ,
      %% Totals since the world began, never reset.
      born => Born,
      starved => Starved,
      aged_out => Aged,
      eaten => Eaten,
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
    #{creatures := Creatures, plants := Plants,
      radius := Radius, tick := Tick} = Chart,
    #{type => world_charted,
      fact_version => ?FACT_VERSION,
      island => island(),
      tick => Tick,
      radius => Radius,
      stride => 2,
      creatures => Creatures,
      plants => Plants,
      ticks_per_second => world_pace:ticks_per_second(Pace)}.
