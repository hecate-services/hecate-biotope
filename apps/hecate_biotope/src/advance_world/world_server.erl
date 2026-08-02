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

-export([start_link/0, snapshot/0, pace/0, chart/0, status/0, set_pace/1]).
-export([station_due/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         handle_continue/2]).

-record(state, {world :: world:world(),
                pace :: world_pace:pace(),
                published = 0 :: non_neg_integer(),
                publish_errors = 0 :: non_neg_integer(),
                %% WHETHER THIS ISLAND MAY BEGIN AGAIN. True only when no seed
                %% was configured. Pinning a seed means "run exactly this world",
                %% and silently starting a different one would be the opposite of
                %% what pinning it asks for.
                reseeds = false :: boolean(),
                run = 1 :: pos_integer(),
                %% Wall clock at which the current world was noticed to be over,
                %% so the corpse can be shown for a while before the next begins.
                ended_at :: integer() | undefined,
                %% The tick the PREVIOUS world ended on. Published, because a
                %% spectator watching the tick reset to nothing deserves to be
                %% told it is a new world and not a glitch.
                previous_end :: non_neg_integer() | undefined,
                %% How many candidate seeds were drawn and found dead before
                %% this one. Published, because a screened fleet is a BIASED
                %% sample and saying so is the difference between honest and not.
                rejected = 0 :: non_neg_integer(),
                %% WHICH DOOR THIS ISLAND IS ON, and when it was last read.
                %% Cached rather than read per fact: `macula:links/1' is a call
                %% on the same pool `publish' calls, so reading it every second
                %% would double the time a wedged pool can stall the world, and
                %% the world stalling on its own output is the one thing this
                %% service is built not to do. A door changes about never.
                station :: map() | undefined,
                %% `undefined' MEANS NEVER READ, and zero would not.
                %% `erlang:monotonic_time/1' starts at an arbitrary point which
                %% on this VM is about minus five hundred and seventy six
                %% billion, so `Now - 0' is hugely negative and "not stale yet"
                %% was true for ever. The door was never read once and every
                %% fact went out without it, on a fleet that was publishing it
                %% correctly when asked directly.
                station_at :: integer() | undefined}).

%% How stale the cached door may get. A dropped link shows on the card within
%% this, which is soon enough for something that changes about never and rare
%% enough that the extra pool call is not on the per-second path.
-define(STATION_MS, 15000).

-define(SERVER, ?MODULE).

start_link() -> gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%% @doc The world as it stands. A read, so it answers during a slot rather than
%% queueing behind one.
-spec snapshot() -> map().
snapshot() -> gen_server:call(?SERVER, snapshot).

-spec pace() -> world_pace:pace().
pace() -> gen_server:call(?SERVER, pace).

%% @doc The picture, for anything drawing this world. The same term the mesh
%% carries, so a page rendered here and a spectator's rendering of a published
%% fact cannot disagree about what the board looks like.
-spec chart() -> map().
chart() -> gen_server:call(?SERVER, chart).

%% @doc What this island is DOING, as against what its world IS. Which run,
%% how many seeds were rejected getting here, how many facts have gone out and
%% how many failed, and which door it is on. None of it is in `world:snapshot/1'
%% because none of it is a property of a world: a world does not know it is the
%% third one this service has run.
-spec status() -> map().
status() -> gen_server:call(?SERVER, status).

%% @doc Watch it faster or slower. NOT PHYSICS: no rule reads the pace, so two
%% islands differing only in this are the same experiment at different speeds,
%% and nothing measured is affected by it.
%%
%% It does not persist, and the page that calls this says so. There is no disk
%% here, so the environment wins at the next boot.
-spec set_pace(world_pace:pace()) -> ok.
set_pace(Pace) -> gen_server:call(?SERVER, {set_pace, Pace}).

%%==============================================================================
%% gen_server
%%==============================================================================

%% SCREENING DOES NOT HAPPEN IN `init/1' AND THAT IS DELIBERATE. A blocking init
%% blocks `supervisor:start_link', which blocks the application, which blocks the
%% whole release boot. At world 14's survival rate the screen expects about a
%% dozen candidates of two thousand ticks each, which is tens of seconds, and a
%% release that takes a minute to come up is a release a container healthcheck
%% restarts in a loop.
%%
%% `handle_continue' runs before any other message, so the unscreened world built
%% here is replaced before a single tick or fact goes out. What it costs is that
%% `snapshot' blocks for the duration, which nothing in the deployment calls: the
%% spectator reads facts off the mesh.
init([]) ->
    Pace = world_pace:from_env(),
    Reseeds = os:getenv("HECATE_BIOTOPE_SEED") =:= false
        orelse os:getenv("HECATE_BIOTOPE_SEED") =:= "",
    {ok, #state{world = world:new(world_opts()), pace = Pace,
                reseeds = Reseeds}, {continue, screen}}.

handle_continue(screen, #state{pace = Pace, reseeds = Reseeds} = S) ->
    {Opts, Rejected} = screened(world_opts(), Reseeds),
    World = world:new(Opts),
    logger:info("biotope: ~p creatures, radius ~p, ~p ticks/s, fact every ~pms, "
                "~p seeds rejected",
                [world:population(World), maps:get(radius, world:defaults()),
                 world_pace:ticks_per_second(Pace),
                 maps:get(publish_ms, Pace), Rejected]),
    schedule(slot, maps:get(slot_ms, Pace)),
    schedule(publish, maps:get(publish_ms, Pace)),
    schedule_chart(maps:get(chart_ms, Pace)),
    {noreply, S#state{world = World, rejected = Rejected}}.

handle_call(snapshot, _From, #state{world = W} = S) ->
    {reply, world:snapshot(W), S};
handle_call(pace, _From, #state{pace = P} = S) ->
    {reply, P, S};
handle_call(chart, _From, #state{world = W} = S) ->
    {reply, world:chart(W), S};
handle_call(status, _From, S) ->
    {reply, status_of(S), S};
%% A CHART TURNED BACK ON NEEDS A KICK AND THE OTHER TWO DO NOT. Every timer
%% re-arms itself from the pace held in state, so a changed `slot_ms' takes
%% effect on the next fire without help. `chart_ms' of zero schedules NO timer at
%% all, on purpose, so there is nothing left alive to notice it changed: going
%% from off to on has to start one.
handle_call({set_pace, New}, _From, #state{pace = Old} = S) ->
    resume_chart(maps:get(chart_ms, Old), maps:get(chart_ms, New)),
    {reply, ok, S#state{pace = New}};
handle_call(_Msg, _From, S) ->
    {reply, {error, unknown_call}, S}.

resume_chart(0, New) when New > 0 -> schedule_chart(New);
resume_chart(_Was, _New) -> no_kick.

status_of(#state{run = Run, rejected = Rejected, published = Sent,
                 publish_errors = Failed, station = Door,
                 previous_end = Was}) ->
    #{run => Run, rejected => Rejected, published => Sent,
      publish_errors => Failed, station => Door, previous_end => Was}.

handle_cast(_Msg, S) -> {noreply, S}.

%% Advance, then yield. The yield is what keeps even the fastest setting a
%% citizen: without it a tight loop holds a scheduler and the health endpoint
%% stops answering, which is a service that looks dead while working hardest.
handle_info(slot, #state{world = W, pace = P} = S) ->
    W1 = world:tick(W, maps:get(ticks_per_slot, P)),
    schedule(slot, maps:get(slot_ms, P)),
    {noreply, still_going(world:population(W1), S#state{world = W1})};

handle_info(publish, #state{world = W, pace = P, run = Run,
                            previous_end = Was, rejected = Rejected} = S) ->
    #state{station = Door} = S1 = refresh_station(S),
    Fact = world_facts:world_advanced(world:snapshot(W), P, Run, Was, Rejected,
                                      Door),
    S2 = record(biotope_mesh:publish(world_facts:topic(world), Fact), S1),
    schedule(publish, maps:get(publish_ms, P)),
    {noreply, S2};

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

%% A DOOR THAT CANNOT BE READ IS FORGOTTEN RATHER THAN REMEMBERED. Keeping the
%% last good reading would publish a station this island may no longer be on,
%% which is worse than saying nothing: the fact would assert a live link that is
%% gone. Absent means "cannot see"; present with `station_connected => false'
%% means "nobody answered". They are different and the fact keeps them apart.
refresh_station(#state{station_at = At} = S) ->
    reread(station_due(erlang:monotonic_time(millisecond), At), S).

reread(false, S) -> S;
reread(true, S) ->
    S#state{station = read_station(biotope_mesh:station()),
            station_at = erlang:monotonic_time(millisecond)}.

%% @doc Whether the door is due to be read again.
%%
%% EXPORTED TO BE TESTED, because the bug it encodes is invisible where it is
%% called. Monotonic time starts wherever the VM decides and is NEGATIVE here, so
%% any arithmetic against a zero default silently means "never".
-spec station_due(integer(), integer() | undefined) -> boolean().
station_due(_Now, undefined) -> true;
station_due(Now, At) -> Now - At >= ?STATION_MS.

read_station({ok, Door}) -> Door;
read_station({error, _}) -> undefined.

%% ==========================================================================
%% NOTHING RESEEDS A WORLD. THE ISLAND BEGINS ANOTHER ONE.
%% ==========================================================================
%%
%% The distinction is the whole of it and it is not a word game. A world that
%% ended stays ended: no creature comes back, its `extinct_at' stands, and its
%% history is not continued. What happens here is that the SERVICE, having
%% finished one experiment, starts a fresh one. The alternative was a public
%% island sitting dead forever, or a fixed seed replaying the identical life
%% after every restart, and both are worse than saying plainly that this is run
%% number three.
%%
%% IT LINGERS FIRST, and that is not politeness. Extinction is a RESULT: three
%% seeds in twelve end, always in the founding phase, and world 8 ended every
%% seed it had. An island that restarted the instant it died would make that
%% result invisible, which is the one thing a spectator page must not do to a
%% finding. So the corpse is published for a while, with its ending tick, before
%% anything new begins.
%%
%% ONLY WHEN NO SEED WAS CONFIGURED. Pinning a seed means "run exactly this
%% world"; quietly starting a different one is the opposite of what pinning asks
%% for, and a pinned seed would in any case replay the same death.
still_going(0, #state{ended_at = undefined} = S) ->
    S#state{ended_at = erlang:monotonic_time(millisecond)};
still_going(0, #state{reseeds = true, ended_at = At} = S) ->
    begin_again(erlang:monotonic_time(millisecond) - At >= linger_ms(), S);
still_going(_Alive, S) ->
    S.

begin_again(false, S) ->
    S;
begin_again(true, #state{world = Old, run = Run} = S) ->
    #{extinct_at := Ended} = world:snapshot(Old),
    {Opts, Rejected} = screened(world_opts(), true),
    Fresh = world:new(Opts),
    logger:info("biotope: world ~p ended at tick ~p, beginning run ~p on seed ~p",
                [Run, Ended, Run + 1, maps:get(seed, world:snapshot(Fresh))]),
    S#state{world = Fresh, run = Run + 1, ended_at = undefined,
            previous_end = Ended, rejected = Rejected}.

%% How long a finished world is left on show. A SERVICE setting and not a
%% physical constant: it changes nothing inside any world and belongs with the
%% publishing rates, not with the economy.
linger_ms() -> ms(os:getenv("HECATE_BIOTOPE_LINGER_MS"), 120000).

ms(false, Default) -> Default;
ms("", Default) -> Default;
ms(Str, _Default) -> list_to_integer(string:trim(Str)).

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

%% ==========================================================================
%% A DRAWN SEED IS SCREENED FOR VIABILITY, AND THE SCREENING IS PUBLISHED
%% ==========================================================================
%%
%% World 12 splits by tick 40 and never reverses. Two seeds in six climb past a
%% thousand creatures; the rest collapse to single digits by tick 60, sit flat
%% for five hundred ticks, and end when the founders age out at 601. Eight of
%% twelve seeds die. A fleet drawing freely therefore spends most of its time
%% showing three worlds in the act of failing, which is a true picture of the
%% distribution and a poor picture of the world.
%%
%% SO THE ISLAND LOOKS BEFORE IT COMMITS. A world is a pure function of its seed
%% and headless ticking is fast, so a candidate can simply be run for its
%% founding phase and kept only if it is still alive at the end. That is the one
%% thing this determinism is unambiguously good for.
%%
%% THE CRITERION IS VIABILITY AND NOTHING ELSE, which is the single exception the
%% standing rule allows: a seed is never chosen for the population it reaches,
%% the depth it gets to or how the chart looks, only for being alive. The first
%% candidate that survives is taken.
%%
%% AND THE COUNT IS PUBLISHED, because a screened fleet is a BIASED sample and
%% saying so is the whole difference between honest and not. The offline sweeps
%% remain the unbiased record; the fleet shows worlds that got past the founding
%% phase, and every fact says how many did not.
%% SCREENING IS REAL WORK AND IT HAPPENS IN `init/1', so it is bounded and the
%% bound is configurable. Each candidate is a world run to the horizon below, so
%% the worst case is `HECATE_BIOTOPE_SCREEN_TRIES' of those before the server
%% answers anything. Setting it to 0 turns screening off, which is what a test
%% that is not about screening wants and what a deployment that wants raw draws
%% would set.
%%
%% ==========================================================================
%% THE HORIZON IS 2000 SINCE WORLD 14, AND IT IS DERIVED
%% ==========================================================================
%%
%% It was 700, from world 9's survey finding every extinction early: 601, 630,
%% 725, and nothing between 725 and 20,000. A fence just past the last observed
%% death was the right fence for that world.
%%
%% WORLD 14 MOVED THE DEATHS. Measured over 24 seeds at the control:
%%
%%   alive at   700    7 of 24
%%   alive at  2000    2 of 24
%%   alive at  4000    2 of 24
%%   alive at  8000    2 of 24
%%
%% Five of the seven that clear 700 die shortly after it, so the old fence has a
%% seventy-one percent false pass rate and an island would show a doomed world
%% five times in seven. Nothing dies after 2000, so that is where the fence goes:
%% **the horizon past which the observed death rate is zero**, which is the same
%% criterion 700 was chosen by rather than a new one.
%%
%% STILL VIABILITY AND NOTHING ELSE. A longer horizon rejects more worlds; it
%% does not prefer a bigger population, a deeper descent or a better chart. And
%% it makes the fleet a MORE biased sample of the seed space, not less, which is
%% why every fact carries the count of what was rejected.
screen_ticks() -> horizon(os:getenv("HECATE_BIOTOPE_SCREEN_TICKS")).

horizon(false) -> 2000;
horizon("") -> 2000;
horizon(Str) -> list_to_integer(string:trim(Str)).

screen_tries() -> tries(os:getenv("HECATE_BIOTOPE_SCREEN_TRIES")).

tries(false) -> 24;
tries("") -> 24;
tries(Str) -> list_to_integer(string:trim(Str)).

screened(#{seed := _Pinned} = Opts, false) -> {Opts, 0};
screened(Opts, true) -> try_seed(Opts, 0, screen_tries()).

try_seed(Opts, Rejected, Limit) when Rejected >= Limit -> {Opts, Rejected};
try_seed(Opts, Rejected, Limit) ->
    keep(survives(Opts), Opts, Rejected, Limit).

keep(true, Opts, Rejected, _Limit) -> {Opts, Rejected};
keep(false, Opts, Rejected, Limit) ->
    try_seed(Opts#{seed => fresh_seed()}, Rejected + 1, Limit).

survives(Opts) ->
    world:population(world:tick(world:new(Opts), screen_ticks())) > 0.

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
