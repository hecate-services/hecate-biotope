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
      resources => [world_facts:topic(world)],
      ttl_days => 30}.
