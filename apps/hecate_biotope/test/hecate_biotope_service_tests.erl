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

%% An empty list is the correct answer for a biotope that holds no world. The
%% assertion is here so that adding a capability is a deliberate act that breaks
%% a test and makes someone write down what the service can now actually do.
announces_no_capability_yet_test() ->
    ?assertEqual([], ?SERVICE:capabilities()).

identity_spec_has_the_shape_hecate_om_expects_test() ->
    Spec = ?SERVICE:identity_spec(),
    #{scope := Scope, actions := Actions,
      resources := Resources, ttl_days := Ttl} = Spec,
    ?assert(is_binary(Scope)),
    ?assert(is_list(Actions)),
    ?assert(is_list(Resources)),
    ?assert(is_integer(Ttl) andalso Ttl > 0).

%% A resource this service is not authorised for is a publish that the realm
%% would refuse once UCAN delegation lands. Asking for nothing and claiming
%% nothing must stay in step, so the two lists are asserted together.
authority_matches_what_is_announced_test() ->
    #{actions := Actions, resources := Resources} = ?SERVICE:identity_spec(),
    ?assertEqual([], ?SERVICE:capabilities()),
    ?assertEqual([], Actions),
    ?assertEqual([], Resources).

%% The supervisor starts and stops cleanly on its own, without hecate_om. It has
%% no children today; this asserts the tree is startable, not that it does work.
supervisor_starts_and_stops_test() ->
    {ok, Pid} = hecate_biotope_sup:start_link(),
    ?assert(is_process_alive(Pid)),
    ?assertEqual([], supervisor:which_children(Pid)),
    unlink(Pid),
    exit(Pid, shutdown).
