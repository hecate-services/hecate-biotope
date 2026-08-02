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

-export([publish/2, available/0, publish_realm/1, station/0]).

-spec publish(binary(), map()) -> ok | {error, term()}.
publish(Topic, Fact) when is_map(Fact) ->
    send(Topic, Fact, endpoint()).

%% @doc WHICH DOOR THIS ISLAND REACHES THE MESH THROUGH, read from the live
%% connection rather than from configuration.
%%
%% THE SEED IS NOT THE STATION. `host' is the name this island DIALLED, which is
%% configuration echoed back and can be a DNS name over any box; `node_id' is the
%% station's Ed25519 public key, verified during the signed HELLO, and is the only
%% trustworthy answer to which station actually answered. Both go out, because
%% they are different claims and a reader is entitled to see them disagree.
%%
%% A NAME IS NOT A PLACE. `station-de-frankfurt' was for a long time physically
%% the Nuremberg box, left misnamed because renaming breaks seeds, and it has
%% since moved to another network again. Stations are virtual and there are
%% hundreds of names over a handful of machines, so nothing downstream may render
%% a city from this. The name is an identity on the mesh and that is all.
%%
%% INSULATED LIKE `publish/2'. The mesh is an output and not a dependency, so a
%% door that cannot be read is an error a caller shrugs at rather than something
%% that takes the world down.
-spec station() -> {ok, map()} | {error, term()}.
station() -> door(endpoint()).

door({error, _} = E) -> E;
door({ok, Pool}) ->
    try chosen(macula:links(Pool))
    catch Class:Reason -> {error, {links_failed, Class, Reason}}
    end.

chosen({error, _} = E) -> E;
chosen({ok, []}) -> {error, no_links};
chosen({ok, Links}) -> {ok, described(prefer_connected(Links))}.

%% An island dials one seed, so there is normally one link. If a deployment ever
%% gives it several, the one that is actually up is the one it is speaking
%% through, and a down link is still worth reporting when nothing is up.
prefer_connected(Links) ->
    hd([L || L <- Links, maps:get(connected, L, false) =:= true] ++ Links).

described(#{host := Host, connected := Connected} = Link) ->
    #{station_host => host_or_unknown(Host),
      station_connected => Connected,
      station_id => key(maps:get(node_id, Link, undefined))}.

host_or_unknown(Host) when is_binary(Host) -> Host;
host_or_unknown(_) -> <<"unknown">>.

%% Lowercase hex, whole. A reader that wants a short form can take a prefix; one
%% that wants to verify the key against the mesh needs all of it.
key(Key) when is_binary(Key) -> string:lowercase(binary:encode_hex(Key));
key(_) -> <<>>.

send(_Topic, _Fact, {error, _} = E) -> E;
send(Topic, Fact, {ok, Pool}) ->
    send_on(Topic, Fact, Pool, realm_for(os:getenv("HECATE_BIOTOPE_REALM"))).

%% ==========================================================================
%% A STRANGER NEEDS NO SECRET, AND UNTIL NOW THE CODE DEMANDED ONE IT NEVER USED
%% ==========================================================================
%%
%% `endpoint/0' required a pool AND the fleet realm, and then `resolve_realm/1'
%% threw the fleet realm away and published on `HECATE_BIOTOPE_REALM' instead.
%% So an island run by somebody outside this fleet, with the public realm set and
%% no fleet tag to its name, could not publish at all: it failed a check on a
%% value the next line discards.
%%
%% The public realm is the sha256 of a public name and needs no provisioning,
%% which is the whole point of it, and the macula SDK generates an ephemeral
%% identity for a client that brings none. So there was nothing else in the way.
realm_for(false) -> fleet_realm();
realm_for("") -> fleet_realm();
realm_for(Hex) -> from_hex(Hex, undefined).

fleet_realm() ->
    try hecate_om_identity:realm()
    catch Class:Reason -> {error, {no_realm, Class, Reason}}
    end.

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
    try pool(hecate_om_identity:macula_client())
    catch Class:Reason -> {error, {no_hecate_om, Class, Reason}}
    end.

pool({ok, Pool}) -> {ok, Pool};
pool(Other) -> {error, {no_macula_client, Other}}.
