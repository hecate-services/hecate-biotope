%% @doc The service contract, asserted locally.
%%
%% hecate_om resolves its six callbacks BY NAME at startup, on a live node, so a
%% service that forgets one dies with `undef' where nobody is watching. The
%% sibling rumbler recorded exactly that failure. The primary defence against it
%% is the `-behaviour(hecate_om_service)' attribute on the service module, which
%% turns a missing callback into a compile error under warnings_as_errors.
%%
%% What this suite adds is everything the compiler cannot see: that the attribute
%% has not been quietly dropped, that the values inside those callbacks are the
%% shapes hecate_om will destructure, and that the version this service reports
%% is the version it actually is. Nothing local boots hecate_om, so asserting the
%% shape by hand is the closest available thing to a rehearsal.
-module(hecate_biotope_service_tests).

-include_lib("eunit/include/eunit.hrl").

-define(SERVICE, hecate_biotope_service).

%% Belt and braces with the behaviour attribute, and it survives the attribute
%% being removed. If hecate_om ever adds a SEVENTH required callback this test
%% keeps passing and the deploy still breaks, which is the honest limit of a
%% local assertion about a remote contract.
exports_every_required_callback_test() ->
    _ = code:ensure_loaded(?SERVICE),
    Required = [{info, 0}, {start, 1}, {stop, 1},
                {health, 0}, {capabilities, 0}, {identity_spec, 0}],
    Missing = [F || {N, A} = F <- Required,
                    not erlang:function_exported(?SERVICE, N, A)],
    ?assertEqual([], Missing).

info_carries_the_three_keys_test() ->
    #{name := Name, version := Vsn, description := Desc} = ?SERVICE:info(),
    ?assert(is_binary(Name)),
    ?assert(is_binary(Vsn)),
    ?assert(is_binary(Desc)),
    ?assertEqual(<<"hecate-biotope">>, Name).

%% The version in info/0 is what a peer reads off /health, so it disagreeing with
%% the application it describes is a lie that nothing else would catch.
info_version_matches_the_application_test() ->
    _ = application:load(hecate_biotope),
    {ok, Vsn} = application:get_key(hecate_biotope, vsn),
    #{version := Reported} = ?SERVICE:info(),
    ?assertEqual(list_to_binary(Vsn), Reported).

health_is_green_test() ->
    ?assertEqual(ok, ?SERVICE:health()).

identity_spec_has_the_shape_hecate_om_expects_test() ->
    Spec = ?SERVICE:identity_spec(),
    #{scope := Scope, actions := Actions,
      resources := Resources, ttl_days := Ttl} = Spec,
    ?assert(is_binary(Scope)),
    ?assert(is_list(Actions)),
    ?assert(is_list(Resources)),
    ?assert(is_integer(Ttl) andalso Ttl > 0).

%% THE AUTHORITY MUST MATCH WHAT THE CODE ACTUALLY DOES, in both directions.
%% Asking for a topic it never publishes to is authority handed over for nothing;
%% publishing to a topic it never asked for is a call the realm would refuse once
%% UCAN delegation lands. The sibling rumbler drifted exactly this way, quietly
%% publishing on two topics its spec did not name.
authority_covers_every_topic_published_and_no_more_test() ->
    #{actions := Actions, resources := Resources} = ?SERVICE:identity_spec(),
    ?assertEqual([<<"publish">>], Actions),
    ?assertEqual(lists:sort([world_facts:topic(world), world_facts:topic(chart)]),
                 lists:sort(Resources)).

%% It speaks and takes no requests, so it promises nothing another service could
%% call. Accepting a migrant would be a capability, and this fails when that
%% happens, which is the point.
announces_nothing_callable_test() ->
    ?assertEqual([], ?SERVICE:capabilities()).

%% The tree starts and runs a world WITHOUT hecate_om, which is the property that
%% matters: the mesh is an output, not a dependency. A biotope that could not
%% boot without a station would be an island that needs a boat to exist.
supervisor_starts_a_running_world_test() ->
    {ok, Pid} = hecate_biotope_sup:start_link(),
    ?assert(is_process_alive(Pid)),
    ?assertMatch([{world_server, _, worker, _}], supervisor:which_children(Pid)),
    #{population := Pop, tick := Tick} = world_server:snapshot(),
    ?assert(Pop > 0),
    ?assert(Tick >= 0),
    unlink(Pid),
    exit(Pid, shutdown).
