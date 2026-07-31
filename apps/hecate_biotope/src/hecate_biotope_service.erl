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

%% Green once the supervision tree is up. A dark mesh is deliberately NOT a
%% health failure: an island whose neighbours are unreachable is an island, and
%% its own population carries on living without them.
health() -> ok.

%% WHAT THIS SERVICE ANNOUNCES IT CAN DO. Nothing, yet. See the module doc.
capabilities() -> [].

%% THE AUTHORITY THIS SERVICE ASKS THE REALM FOR. None, yet, for the same reason.
%% The scope is claimed now because it is the namespace every later resource will
%% hang under, and because a scope costs nothing while a rename costs every
%% deployed peer.
identity_spec() ->
    #{scope => <<"biotope">>,
      actions => [],
      resources => [],
      ttl_days => 30}.
