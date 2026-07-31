%% @doc The process that keeps a world moving, and the one property that matters
%% most about it: the mesh is an output, not a dependency.
-module(world_server_tests).

-include_lib("eunit/include/eunit.hrl").

with_env(Vars, Fun) ->
    lists:foreach(fun({K, V}) -> true = os:putenv(K, V) end, Vars),
    try Fun()
    after lists:foreach(fun({K, _}) -> os:unsetenv(K) end, Vars)
    end.

start() ->
    {ok, Pid} = world_server:start_link(),
    Pid.

stop(Pid) ->
    unlink(Pid),
    exit(Pid, shutdown).

%%==============================================================================
%% It advances
%%==============================================================================

a_world_advances_on_its_own_test() ->
    with_env([{"HECATE_BIOTOPE_SLOT_MS", "1"},
              {"HECATE_BIOTOPE_TICKS_PER_SLOT", "20"}],
             fun() ->
                 Pid = start(),
                 #{tick := T0} = world_server:snapshot(),
                 timer:sleep(120),
                 #{tick := T1} = world_server:snapshot(),
                 stop(Pid),
                 ?assertEqual(0, T0),
                 ?assert(T1 > T0)
             end).

%% THE PROPERTY THE WHOLE SERVICE RESTS ON. hecate_om is not running in this
%% suite, and hecate_om_identity:macula_client/0 is a gen_server call, so a
%% publish attempt does not return an error, it EXITS with noproc. Unwrapped,
%% that exit travels up the publish timer, kills the world, and the supervisor
%% restarts it with a fresh population: the island quietly loses everything
%% living on it because nobody could hear it.
%%
%% publish_ms is 1 here so the failure fires immediately rather than being missed
%% by a test that finishes first, which is how this would otherwise reach a node.
%%
%% TRAP_EXIT AND A MONITOR, BECAUSE THE FIRST VERSION OF THIS TEST DID NOT FAIL.
%% start_link/0 links the server to the test process, so when the world died the
%% test died with it: eunit reported zero failures and silently dropped four
%% cases. A guard whose test cannot go red is not a guard. Trapping keeps this
%% process alive to notice, and the monitor turns "it crashed" into a value to
%% assert on rather than a signal that removes the assertion.
a_dark_mesh_does_not_kill_the_world_test() ->
    with_env([{"HECATE_BIOTOPE_PUBLISH_MS", "1"},
              {"HECATE_BIOTOPE_SLOT_MS", "1"}],
             fun() ->
                 Old = process_flag(trap_exit, true),
                 Pid = start(),
                 Ref = monitor(process, Pid),
                 timer:sleep(80),
                 Fate = fate(Ref, Pid),
                 stop(Pid),
                 process_flag(trap_exit, Old),
                 ?assertEqual(alive, Fate)
             end).

fate(Ref, Pid) ->
    receive {'DOWN', Ref, process, Pid, Why} -> {died, Why}
    after 0 -> alive
    end.

%% Separate from the fate check so a crash and a stalled world are different
%% failures rather than one.
a_world_keeps_advancing_while_the_mesh_is_dark_test() ->
    with_env([{"HECATE_BIOTOPE_PUBLISH_MS", "1"},
              {"HECATE_BIOTOPE_SLOT_MS", "1"}],
             fun() ->
                 Old = process_flag(trap_exit, true),
                 Pid = start(),
                 timer:sleep(80),
                 #{tick := Tick, population := Pop} = world_server:snapshot(),
                 stop(Pid),
                 process_flag(trap_exit, Old),
                 ?assert(Tick > 0),
                 ?assert(Pop > 0)
             end).

%%==============================================================================
%% It is configurable
%%==============================================================================

the_economy_can_be_overridden_from_the_environment_test() ->
    with_env([{"HECATE_BIOTOPE_ECON", "radius=4"},
              {"HECATE_BIOTOPE_SEED", "5"}],
             fun() ->
                 Pid = start(),
                 #{radius := R} = world_server:snapshot(),
                 stop(Pid),
                 ?assertEqual(4, R)
             end).

%% A key the economy does not have is a typo, and a typo that silently does
%% nothing is a service that ignores its own configuration and reports healthy.
%% Refusing to start is the loud alternative.
an_unknown_economy_key_refuses_to_start_test() ->
    with_env([{"HECATE_BIOTOPE_ECON", "metabolizm=2"}],
             fun() ->
                 process_flag(trap_exit, true),
                 ?assertMatch({error, {{unknown_economy_keys, [metabolizm], _}, _}},
                              world_server:start_link()),
                 process_flag(trap_exit, false)
             end).

%% Two numbers, and the same code path reaches both ends of the range.
the_pace_is_reported_as_configured_test() ->
    with_env([{"HECATE_BIOTOPE_TICKS_PER_SLOT", "500"},
              {"HECATE_BIOTOPE_SLOT_MS", "1"}],
             fun() ->
                 Pid = start(),
                 Pace = world_server:pace(),
                 stop(Pid),
                 ?assertEqual(500000, world_pace:ticks_per_second(Pace))
             end).
