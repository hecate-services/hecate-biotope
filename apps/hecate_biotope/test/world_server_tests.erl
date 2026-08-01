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

%%==============================================================================
%% A world that ended stays ended. The island begins another one.
%%==============================================================================

%% THE DISTINCTION MATTERS AND IS NOT A WORD GAME. No creature comes back, the
%% dead world's `extinct_at' stands, and its history is not continued. What
%% happens is that the SERVICE, having finished one experiment, starts a fresh
%% one, because the alternative is a public island sitting dead forever or a
%% pinned seed replaying the identical life after every restart.
%%
%% `metabolism' far above anything a creature can earn kills the founding in the
%% first tick, which is the cheapest extinction available and does not need six
%% hundred ticks of ageing to arrive at.
an_island_begins_a_new_world_after_the_old_one_ends_test() ->
    with_env([{"HECATE_BIOTOPE_SLOT_MS", "1"},
              {"HECATE_BIOTOPE_LINGER_MS", "0"},
              {"HECATE_BIOTOPE_ECON", "metabolism=100000"}],
             fun() ->
                 Pid = start(),
                 #{seed := First} = world_server:snapshot(),
                 timer:sleep(120),
                 #{seed := Later, tick := Tick} = world_server:snapshot(),
                 stop(Pid),
                 ?assertNotEqual(First, Later),
                 ?assert(Tick < 50)
             end).

%% AND IT WAITS FIRST, which is not politeness. Extinction is a RESULT: three
%% seeds in twelve end and world 8 ended every seed it had. An island that began
%% again the instant it died would make that finding invisible, which is the one
%% thing a spectator page must never do to a result.
a_finished_world_is_left_on_show_before_the_next_begins_test() ->
    with_env([{"HECATE_BIOTOPE_SLOT_MS", "1"},
              {"HECATE_BIOTOPE_LINGER_MS", "60000"},
              {"HECATE_BIOTOPE_ECON", "metabolism=100000"}],
             fun() ->
                 Pid = start(),
                 #{seed := First} = world_server:snapshot(),
                 timer:sleep(120),
                 #{seed := Later, population := Pop} = world_server:snapshot(),
                 stop(Pid),
                 ?assertEqual(First, Later),
                 ?assertEqual(0, Pop)
             end).

%% A PINNED SEED MEANS RUN EXACTLY THIS WORLD, so the island does not quietly
%% start a different one. It would in any case replay the same death.
a_pinned_seed_never_begins_again_test() ->
    with_env([{"HECATE_BIOTOPE_SLOT_MS", "1"},
              {"HECATE_BIOTOPE_LINGER_MS", "0"},
              {"HECATE_BIOTOPE_SEED", "4242"},
              {"HECATE_BIOTOPE_ECON", "metabolism=100000"}],
             fun() ->
                 Pid = start(),
                 timer:sleep(120),
                 #{seed := Seed, population := Pop} = world_server:snapshot(),
                 stop(Pid),
                 ?assertEqual(4242, Seed),
                 ?assertEqual(0, Pop)
             end).
