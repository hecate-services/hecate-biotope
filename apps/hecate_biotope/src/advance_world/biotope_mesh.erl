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
-module(biotope_mesh).

-export([publish/2, available/0]).

-spec publish(binary(), map()) -> ok | {error, term()}.
publish(Topic, Fact) when is_map(Fact) ->
    send(Topic, Fact, endpoint()).

send(_Topic, _Fact, {error, _} = E) -> E;
send(Topic, Fact, {ok, Pool, Realm}) ->
    try macula:publish(Pool, Realm, Topic, Fact)
    catch Class:Reason -> {error, {publish_failed, Class, Reason}}
    end.

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
