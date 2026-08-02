%% @doc Which realm the facts leave on, and what happens when that is misspelt.
-module(biotope_mesh_tests).

-include_lib("eunit/include/eunit.hrl").

-define(FLEET, <<"the-fleet-realm-tag">>).
-define(PUBLIC_NAME, <<"net.beamcampus.biotope">>).
-define(PUBLIC_HEX,
        "7f73d3d9361bb16d4bed2812428ea6e6257a6f50c9de7ac8c581665dc0d01171").

with_realm(Value, Fun) ->
    true = os:putenv("HECATE_BIOTOPE_REALM", Value),
    try Fun() after os:unsetenv("HECATE_BIOTOPE_REALM") end.

%% A deployment that has not been told about the public realm keeps behaving as
%% it did, rather than going silent because a variable is missing.
unset_falls_back_to_the_fleet_realm_test() ->
    os:unsetenv("HECATE_BIOTOPE_REALM"),
    ?assertEqual({ok, ?FLEET}, biotope_mesh:publish_realm(?FLEET)).

a_64_hex_tag_is_decoded_test() ->
    with_realm(?PUBLIC_HEX, fun() ->
        {ok, Realm} = biotope_mesh:publish_realm(?FLEET),
        ?assertEqual(32, byte_size(Realm)),
        ?assertNotEqual(?FLEET, Realm)
    end).

%% FALLING BACK ON A TYPO WOULD PUBLISH PUBLIC FACTS ONTO THE OPERATIONAL REALM
%% and report success, which is the one failure nobody would notice. Both shapes
%% of mistake are refused: the wrong length, and the right length of the wrong
%% alphabet.
a_short_tag_is_an_error_not_a_fallback_test() ->
    with_realm("7f73d3d9", fun() ->
        ?assertEqual({error, biotope_realm_not_64_hex},
                     biotope_mesh:publish_realm(?FLEET))
    end).

a_non_hex_tag_of_the_right_length_is_an_error_test() ->
    Zed = lists:duplicate(64, $z),
    with_realm(Zed, fun() ->
        ?assertEqual({error, biotope_realm_not_hex},
                     biotope_mesh:publish_realm(?FLEET))
    end).

%% THE TAG IS DERIVED, NOT ISSUED: a realm id is the sha256 of its name, so a
%% public realm needs no provisioning and its name being public is the point.
%% Frozen here so the constant in the compose file and the comment in the source
%% cannot drift from the name they claim to be.
the_public_realm_is_the_hash_of_its_name_test() ->
    Expected = binary:encode_hex(crypto:hash(sha256, ?PUBLIC_NAME), lowercase),
    ?assertEqual(list_to_binary(?PUBLIC_HEX), Expected).

%% A STRANGER CAN PUBLISH WITH NO FLEET SECRET, which is the join blocker.
%% `endpoint/0' used to demand the fleet realm and `resolve_realm/1' then threw
%% it away, so an island outside this fleet failed a check on a value the next
%% line discards. With the public realm set, nothing about the fleet is needed.
a_public_realm_needs_no_fleet_realm_test() ->
    Public = string:copies("ab", 32),
    true = os:putenv("HECATE_BIOTOPE_REALM", Public),
    try
        ?assertMatch({ok, _}, biotope_mesh:publish_realm(undefined))
    after os:unsetenv("HECATE_BIOTOPE_REALM")
    end.

