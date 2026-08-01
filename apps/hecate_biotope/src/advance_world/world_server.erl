%% @doc The process that owns this node's world and keeps it moving.
%%
%% IT DOES NO ARITHMETIC. Every rule of the world lives in the pure `world'
%% module; this holds one of them, advances it on a timer, and says so on
%% another. That split is what lets the same rules run headless at whatever speed
%% an experiment wants, with no service in the way.
%%
%% TWO TIMERS, NOT ONE, and they are independent on purpose. The world advances
%% `ticks_per_slot' times every `slot_ms'; a fact goes out every `publish_ms' of
%% wall clock. Tying the fact to the tick reads as obvious and breaks at both
%% ends of the range: a fact per tick is a flood at speed and looks like a dead
%% service when slow. See `world_pace'.
%%
%% THE ECONOMY IS OVERRIDABLE FROM THE ENVIRONMENT, in the same `key=value'
%% syntax the probe script takes, so tuning learned on a laptop transfers to a
%% node without a rebuild. An unknown key is a startup failure rather than a
%% silent no-op, because a service that ignores its own configuration and reports
%% healthy is the worst of the available outcomes.
-module(world_server).

-behaviour(gen_server).

-export([start_link/0, snapshot/0, pace/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).

-record(state, {world :: world:world(),
                pace :: world_pace:pace(),
                published = 0 :: non_neg_integer(),
                publish_errors = 0 :: non_neg_integer()}).

-define(SERVER, ?MODULE).

start_link() -> gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%% @doc The world as it stands. A read, so it answers during a slot rather than
%% queueing behind one.
-spec snapshot() -> map().
snapshot() -> gen_server:call(?SERVER, snapshot).

-spec pace() -> world_pace:pace().
pace() -> gen_server:call(?SERVER, pace).

%%==============================================================================
%% gen_server
%%==============================================================================

init([]) ->
    Pace = world_pace:from_env(),
    Opts = world_opts(),
    World = world:new(Opts),
    logger:info("biotope: ~p creatures, radius ~p, ~p ticks/s, fact every ~pms",
                [world:population(World), maps:get(radius, world:defaults()),
                 world_pace:ticks_per_second(Pace),
                 maps:get(publish_ms, Pace)]),
    schedule(slot, maps:get(slot_ms, Pace)),
    schedule(publish, maps:get(publish_ms, Pace)),
    schedule_chart(maps:get(chart_ms, Pace)),
    {ok, #state{world = World, pace = Pace}}.

handle_call(snapshot, _From, #state{world = W} = S) ->
    {reply, world:snapshot(W), S};
handle_call(pace, _From, #state{pace = P} = S) ->
    {reply, P, S};
handle_call(_Msg, _From, S) ->
    {reply, {error, unknown_call}, S}.

handle_cast(_Msg, S) -> {noreply, S}.

%% Advance, then yield. The yield is what keeps even the fastest setting a
%% citizen: without it a tight loop holds a scheduler and the health endpoint
%% stops answering, which is a service that looks dead while working hardest.
handle_info(slot, #state{world = W, pace = P} = S) ->
    W1 = world:tick(W, maps:get(ticks_per_slot, P)),
    schedule(slot, maps:get(slot_ms, P)),
    {noreply, S#state{world = W1}};

handle_info(publish, #state{world = W, pace = P} = S) ->
    Fact = world_facts:world_advanced(world:snapshot(W), P),
    S1 = record(biotope_mesh:publish(world_facts:topic(world), Fact), S),
    schedule(publish, maps:get(publish_ms, P)),
    {noreply, S1};

handle_info(chart, #state{world = W, pace = P} = S) ->
    Fact = world_facts:world_charted(world:chart(W), P),
    S1 = record(biotope_mesh:publish(world_facts:topic(chart), Fact), S),
    schedule_chart(maps:get(chart_ms, P)),
    {noreply, S1};

handle_info(_Msg, S) -> {noreply, S}.

%%==============================================================================
%% Internals
%%==============================================================================

schedule(Msg, Ms) -> erlang:send_after(Ms, self(), Msg).

%% Zero means the picture is off: no timer at all rather than one that fires and
%% decides not to publish, so a headless run pays nothing for a feature it is not
%% using.
schedule_chart(0) -> no_chart;
schedule_chart(Ms) -> schedule(chart, Ms).

%% A dark mesh is counted, not fatal, and not logged per failure: a biotope that
%% cannot reach a station would otherwise fill a disk with one line per second
%% while its creatures carry on perfectly well.
record(ok, #state{published = N} = S) -> S#state{published = N + 1};
record({error, _Why}, #state{publish_errors = N} = S) ->
    S#state{publish_errors = N + 1}.

%% `HECATE_BIOTOPE_SEED' and `HECATE_BIOTOPE_ECON="metabolism=2,radius=25"'.
world_opts() ->
    Econ = econ_overrides(os:getenv("HECATE_BIOTOPE_ECON")),
    maps:merge(Econ, seed(os:getenv("HECATE_BIOTOPE_SEED"))).

%% ==========================================================================
%% AN UNSET SEED MEANS A FRESH WORLD, NOT THE SAME ONE AGAIN
%% ==========================================================================
%%
%% A world is a pure function of its seed, which is what makes a pre-registered
%% criterion mean anything and is asserted by
%% scripts/same_seed_same_world.escript. It also meant that a live island
%% REPLAYED THE IDENTICAL LIFE after every restart: beam03 died at the same tick
%% every time it came back, because it was the same world each time. A public
%% exhibit that is really a recording is not a living world.
%%
%% So an island with no seed configured draws one at boot and PUBLISHES it. The
%% two goals only ever conflicted while the seed was a secret: an island that
%% says which number it unfolded from is one anybody can replay exactly, offline,
%% at whatever horizon they like.
%%
%% THE CLOCK IS READ HERE AND NOT IN `world'. The physics stays a pure function
%% of its seed and contains no clock and no unthreaded randomness; choosing the
%% seed is the runtime's job. That separation is the whole reason the purity
%% survives this change.
seed(false) -> #{seed => fresh_seed()};
seed("") -> #{seed => fresh_seed()};
seed(Str) -> #{seed => list_to_integer(string:trim(Str))}.

fresh_seed() ->
    erlang:phash2({erlang:system_time(microsecond), erlang:unique_integer()}).

econ_overrides(false) -> #{};
econ_overrides("") -> #{};
econ_overrides(Str) ->
    Pairs = [pair(P) || P <- string:lexemes(Str, ","), P =/= ""],
    Given = maps:from_list(Pairs),
    reject_unknown(maps:keys(Given) -- maps:keys(world:defaults()), Given).

pair(Str) ->
    [K, V] = string:split(string:trim(Str), "="),
    {list_to_atom(K), list_to_integer(string:trim(V))}.

reject_unknown([], Given) -> Given;
reject_unknown(Unknown, _Given) ->
    error({unknown_economy_keys, Unknown, lists:sort(maps:keys(world:defaults()))}).
