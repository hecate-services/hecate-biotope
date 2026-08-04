%% @doc The hecate_om service contract: what this service is and may do.
%%
%% SIX CALLBACKS, ALL REQUIRED. hecate_om calls every one of them during boot,
%% and a missing export fails at startup with `undef' against the live mesh
%% rather than at compile time. The sibling rumbler learned that the expensive
%% way, so hecate_biotope_service_tests asserts the six are exported.
%%
%% IT ANNOUNCES NOTHING, ON PURPOSE. An empty biotope has no capability to offer
%% and asks the realm for no authority. Advertising `biotope.receive_migrant'
%% before anything can receive a migrant would put a lie on the mesh, and another
%% service could find it and call it. Both lists grow when the thing they name
%% exists.
-module(hecate_biotope_service).

-behaviour(hecate_om_service).

-export([info/0, start/1, stop/1, health/0, capabilities/0, identity_spec/0]).
%% ==========================================================================
%% AND TWO OPTIONAL ONES, WHICH TURN THE STORE ON
%% ==========================================================================
%%
%% Exporting `store_id/0' and `data_dir/0' together makes `hecate_om:boot/1'
%% open a reckon-db store before this module's `start/1' fires.
%%
%% ⚠ THE APPLICATIONS WERE ALWAYS RUNNING. `reckon_db', `reckon_evoq',
%% `reckon_gater', `evoq', `khepri' and `ra' start with `hecate_om' whether these
%% callbacks exist or not: six of the thirty-one applications on a live island,
%% for months, doing nothing. What these two add is a STORE, and `rebar.config'
%% used to claim they suppressed the whole stack.
%%
%% ==========================================================================
%% WHY A LIVE SIMULATION WANTS A DURABLE LOG AT ALL
%% ==========================================================================
%%
%% The world itself stays where it is: in a `gen_server''s state, a pure function
%% of its seed, and it is NOT being event-sourced. Nothing here replays a world
%% from events and nothing writes a tick.
%%
%% What the store holds is what a world FOUND. A snapshot computes about forty
%% numbers a second and throws away everything nobody wrote an instrument for,
%% and when an island dies its whole history goes with it. **In an open-ended
%% search the interesting thing is by definition the thing nobody anticipated,
%% and an instrument you did not write cannot measure it.** A durable record of
%% discoveries can be re-read next month with a question that did not exist
%% today.
%%
%% BOUNDED BY CONSTRUCTION, WHICH IS WHY THIS IS AFFORDABLE. Births run about ten
%% a tick and deaths not far behind: writing those would be three million events
%% a day per island and is not what this is for. Discoveries are capped by the
%% size of the space: 125 ways of living, once each, ever. A whole run is a few
%% hundred events.
-export([store_id/0, data_dir/0]).

info() ->
    #{name => <<"hecate-biotope">>,
      version => <<"0.1.0">>,
      description => <<"One island: an open population of creatures, their "
                       "organs, and the energy economy that decides who breeds">>}.

start(_Opts) -> hecate_biotope_sup:start_link().

stop(_State) -> ok.

%% Green once the world is running. A dark mesh is deliberately NOT a health
%% failure: an island whose neighbours are unreachable is still an island, and
%% its population carries on living, eating and dying without them. The only
%% thing lost is that nobody hears about it.
health() -> ok.

%% WHAT THIS SERVICE ANNOUNCES IT CAN DO. Still nothing, and that is not an
%% oversight. A capability is a promise that something answers when another
%% service calls it, and a biotope currently only speaks: it publishes what
%% happened and takes no requests. When it accepts a migrant, that is a
%% capability and it goes here.
capabilities() -> [].

%% THE AUTHORITY THIS SERVICE ASKS THE REALM FOR: publish on its own world
%% topic, and nothing else. It subscribes to nothing, so it asks for no
%% subscribe. Popped, an attacker gains the ability to post population figures
%% for an island.
identity_spec() ->
    #{scope => <<"biotope">>,
      actions => [<<"publish">>],
      resources => [world_facts:topic(world), world_facts:topic(chart)],
      ttl_days => 30}.

%% ==========================================================================
%% The store
%% ==========================================================================

%% @doc The reckon-db store this island owns.
%%
%% One per island rather than one per run: a run is a STREAM inside it, so a
%% node that has hosted forty worlds can be asked what all forty found, which is
%% the question the whole thing exists to answer.
-spec store_id() -> atom().
store_id() -> biotope_store.

%% @doc Where it lives on disk.
%%
%% ⚠ DEFAULTS TO A PATH INSIDE THE CONTAINER AND SHOULD NOT STAY THERE ON A
%% NODE. The beam fleet keeps application data on its `/bulk' drives and the root
%% filesystem is the OS only, so the compose file mounts one and sets this. The
%% default is what a laptop wants, and a container without the mount loses its
%% record on every recreate, which is the same as not having one.
-spec data_dir() -> string().
data_dir() -> chosen(os:getenv("HECATE_BIOTOPE_DATA_DIR")).

chosen(false) -> "/tmp/hecate_biotope";
chosen("") -> "/tmp/hecate_biotope";
chosen(Path) -> Path.
