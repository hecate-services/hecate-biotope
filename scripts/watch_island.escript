#!/usr/bin/env escript
%% Watch an island from outside it.
%%
%% THE CHEAPEST POSSIBLE SPECTATOR, and it exists to prove the contract before
%% anything expensive is built against it. A viewer in another repository is a
%% lot of work to discover that a field is missing or that the facts are landing
%% on a realm nobody is listening to. This subscribes exactly as that viewer will
%% and prints what actually arrives.
%%
%% It also stays useful afterwards: when an island goes quiet, this says whether
%% the world stopped or only the transport did.
%%
%% TWO REALMS. hecate_om needs the FLEET realm to establish an identity, because
%% that is what the service principal is for. The facts arrive on the PUBLIC one.
%% Subscribing on the fleet realm here would wait forever while the facts sailed
%% past on the other, which is the whole point of the split and an easy hour to
%% lose.
%%
%% Usage, from the repository root:
%%
%%   HECATE_REALM=<64-hex-fleet> \
%%   MACULA_STATION_SEEDS=https://station-de-frankfurt.macula.io:4433 \
%%   scripts/watch_island.escript [seconds]

main(Args) ->
    ok = load_beams(),
    Seconds = seconds(Args),
    ok = boot(),
    {ok, Realm} = biotope_mesh:publish_realm(fleet_realm()),
    lists:foreach(fun(Leaf) -> listen(Realm, world_facts:topic(Leaf)) end,
                  [world, chart]),
    io:format("~nwatching for ~ps. Ctrl-C to stop.~n~n", [Seconds]),
    await(erlang:monotonic_time(millisecond) + Seconds * 1000),
    halt(0).

seconds([]) -> 60;
seconds([S]) -> list_to_integer(S).

%% Every dependency's ebin, discovered rather than listed, so this does not need
%% editing every time the dependency tree changes.
load_beams() ->
    Ebins = filelib:wildcard("_build/default/lib/*/ebin"),
    [] =:= Ebins andalso begin
        io:format("no beams: run rebar3 compile from the repository root~n"),
        halt(1)
    end,
    code:add_pathsz(Ebins),
    ok.

%% A POOL EXISTING IS NOT A STATION BEING READY. The client attaches before any
%% station link is healthy, so a single subscribe dies on no_healthy_station.
%% The sibling rumbler learned this twice, once in the server and once here.
listen(Realm, Topic) ->
    ok = retry(fun() -> macula:subscribe(pool(), Realm, Topic, self()) end,
               Topic, 60),
    io:format("listening: ~s on realm ~s~n",
              [Topic, binary:encode_hex(Realm, lowercase)]).

retry(_F, What, 0) -> io:format("gave up on ~s~n", [What]), error({gave_up, What});
retry(F, What, N) -> retried(F, What, N, catch F()).

retried(_F, _What, _N, ok) -> ok;
retried(_F, _What, _N, {ok, _}) -> ok;
retried(F, What, N, _NotYet) -> timer:sleep(1000), retry(F, What, N - 1).

await(Until) ->
    Left = Until - erlang:monotonic_time(millisecond),
    wait(Left).

wait(Left) when Left =< 0 -> io:format("~ndone.~n");
wait(Left) ->
    receive
        {macula_event, _Ref, _Topic, Fact, _Meta} ->
            show(Fact),
            await_again(Left)
    after Left ->
        io:format("~nnothing arrived. The island may be dark, on another realm, "
                  "or not publishing.~n")
    end.

await_again(Left) -> await(erlang:monotonic_time(millisecond) + Left).

%% Charts are printed as shapes rather than coordinates: a hundred and seventy
%% integers a second scrolls the useful line off the screen.
show(#{type := world_advanced, island := I, tick := T, population := P,
       plants := Pl, starved := S, econ_id := Econ}) ->
    %% econ_id rather than the birth count, because with more than one island the
    %% first question is not "how is it doing" but "am I even looking at the same
    %% experiment". Two islands sharing a fingerprint are comparable; two that do
    %% not are different games and their populations must not be read against
    %% each other.
    io:format("~-10s ~-18s tick ~-8w pop ~-5w plants ~-5w starved ~w~n",
              [I, Econ, T, P, Pl, S]);
show(#{type := world_charted, island := I, tick := T, radius := R,
       creatures := Cs, plants := Ps, stride := Stride}) ->
    io:format("~-10s tick ~-8w chart r~-4w ~w creatures, ~w plants~n",
              [I, T, R, length(Cs) div Stride, length(Ps) div Stride]);
%% A fact that does not match is almost always a version gap during a rollout,
%% not a corrupt frame, so say which field is missing rather than dumping the map
%% and leaving the reader to diff it by eye. This exact case appeared the first
%% time this script ran: the deployed island predated the `island' field.
show(#{type := Type} = Other) ->
    Missing = [K || K <- [island, tick, fact_version], not maps:is_key(K, Other)],
    io:format("~w with no ~p: an island running an older image?~n  ~p~n",
              [Type, Missing, Other]);
show(Other) ->
    io:format("not a biotope fact at all: ~p~n", [Other]).

boot() ->
    application:load(hecate_om),
    application:set_env(hecate_om, health_port, undefined),
    application:set_env(hecate_om, realm, fleet_realm_hex()),
    {ok, _} = application:ensure_all_started(hecate_om),
    wait_for_mesh(60).

wait_for_mesh(0) -> error(mesh_never_came_up);
wait_for_mesh(N) ->
    ready(catch hecate_om:macula_client(), N).

ready({ok, _}, _N) -> ok;
ready(_NotYet, N) -> timer:sleep(500), wait_for_mesh(N - 1).

pool() -> element(2, hecate_om:macula_client()).

fleet_realm() -> element(2, hecate_om_identity:realm()).

fleet_realm_hex() -> require("HECATE_REALM", os:getenv("HECATE_REALM")).

require(Name, false) -> io:format("~s is not set~n", [Name]), halt(64);
require(Name, "") -> io:format("~s is empty~n", [Name]), halt(64);
require(_Name, S) -> list_to_binary(S).
