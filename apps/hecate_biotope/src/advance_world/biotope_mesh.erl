%% @doc The only module in this service that knows macula exists.
%%
%% Everything else takes and returns terms. When the transport changes, or when
%% these facts eventually move to a realm of their own, this is the file that
%% changes and nothing else does.
%%
%% A DARK MESH IS NOT A FAILURE OF THE BIOTOPE. An island whose neighbours are
%% unreachable is still an island: its creatures go on living, eating and dying,
%% and the only thing lost is that nobody hears about it. So a publish that
%% cannot happen returns an error to a caller that shrugs, rather than taking the
%% world down with it. What must never happen is silence that looks like success,
%% which is why the error is a return value rather than a swallowed exception.
%%
%% FACTS GO OUT ON THEIR OWN REALM, AND THAT ASYMMETRY IS THE ACCESS CONTROL.
%% These facts are meant to be read by a public website, and handing a public web
%% container the fleet realm tag would let anything in that container read
%% sentinel sightings and warden facts too. The service keeps its fleet identity
%% for everything hecate_om does, because it is a fleet service; only its output
%% moves.
%%
%%     net.beamcampus.biotope
%%     7f73d3d9361bb16d4bed2812428ea6e6257a6f50c9de7ac8c581665dc0d01171
%%
%% It costs nothing to draw this line: macula is realm-per-call, so one pool
%% publishes to any realm and this is a second realm rather than a second
%% connection, and a realm id is the sha256 of its name, so a public realm needs
%% no provisioning and its name being public is the point.
%%
%% HONEST LIMIT: stations are realm-agnostic infrastructure, so a realm is a
%% routing namespace and not an enforced permission. What this buys is that a
%% public web box never holds the fleet tag, not that the fleet tag would be
%% refused if it did.
-module(biotope_mesh).

-export([publish/2, available/0, publish_realm/1]).

-spec publish(binary(), map()) -> ok | {error, term()}.
publish(Topic, Fact) when is_map(Fact) ->
    send(Topic, Fact, endpoint()).

send(_Topic, _Fact, {error, _} = E) -> E;
send(Topic, Fact, {ok, Pool, FleetRealm}) ->
    send_on(Topic, Fact, Pool, resolve_realm(FleetRealm)).

send_on(_Topic, _Fact, _Pool, {error, _} = E) -> E;
send_on(Topic, Fact, Pool, {ok, Realm}) ->
    try macula:publish(Pool, Realm, Topic, Fact)
    catch Class:Reason -> {error, {publish_failed, Class, Reason}}
    end.

%% @doc Which realm facts go out on, given the fleet realm to fall back to.
%%
%% Unset falls back, so a deployment that has not been told about the public
%% realm keeps behaving as it did rather than going silent.
%%
%% A MALFORMED TAG IS AN ERROR RATHER THAN A FALLBACK. Falling back on a typo
%% would publish public facts onto the operational realm and report success,
%% which is the one outcome nobody would notice.
-spec publish_realm(binary()) -> {ok, binary()} | {error, term()}.
publish_realm(FleetRealm) -> resolve_realm(FleetRealm).

resolve_realm(FleetRealm) -> from_hex(os:getenv("HECATE_BIOTOPE_REALM"), FleetRealm).

from_hex(false, FleetRealm) -> {ok, FleetRealm};
from_hex("", FleetRealm) -> {ok, FleetRealm};
from_hex(Hex, FleetRealm) -> decode(string:trim(Hex), FleetRealm).

decode(Hex, _FleetRealm) when length(Hex) =:= 64 ->
    try {ok, binary:decode_hex(list_to_binary(Hex))}
    catch _:_ -> {error, biotope_realm_not_hex}
    end;
decode(_Hex, _FleetRealm) -> {error, biotope_realm_not_64_hex}.

-spec available() -> boolean().
available() -> element(1, endpoint()) =:= ok.

%% The pool and the realm both come from hecate_om, which owns the connection and
%% the identity. This service holds neither.
%%
%% WRAPPED, AND THE DEVIATION IS DELIBERATE. Both of those are gen_server calls,
%% so before hecate_om is up, or while it is restarting, they do not return an
%% error: they EXIT with noproc. Unwrapped, that exit travels up through the
%% publish timer and kills the world, which restarts, seeds a fresh population,
%% and loses the one that was living. A biotope must outlive its transport, so
%% the failure becomes a return value the caller can count.
%%
%% What would be lost without this is precisely the distinction between "the
%% mesh is not there yet" and "the world crashed", which a supervisor exit
%% collapses into one opaque line.
endpoint() ->
    try pool_and_realm(hecate_om_identity:macula_client(),
                       hecate_om_identity:realm())
    catch Class:Reason -> {error, {no_hecate_om, Class, Reason}}
    end.

pool_and_realm({ok, Pool}, {ok, Realm}) -> {ok, Pool, Realm};
pool_and_realm({ok, _Pool}, Other) -> {error, {no_realm, Other}};
pool_and_realm(Other, _Realm) -> {error, {no_macula_client, Other}}.
