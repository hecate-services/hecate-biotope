%% @doc The process that keeps a world moving, and the one property that matters
%% most about it: the mesh is an output, not a dependency.
-module(world_server_tests).

-include_lib("eunit/include/eunit.hrl").

%% SCREENING OFF BY DEFAULT IN HERE. An unseeded island runs up to twenty-four
%% candidate worlds through their founding phase inside `init/1' before it
%% answers anything, which is seconds. Only the test that is about screening
%% wants to pay that, and it says so.
with_env(Vars, Fun) ->
    quietly([{"HECATE_BIOTOPE_SCREEN_TRIES", "0"} | Vars], Fun).

quietly(Vars, Fun) ->
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

%% AN ISLAND LOOKS BEFORE IT COMMITS. World 12 splits by tick 40 and eight seeds
%% in twelve die, so a fleet drawing freely shows three worlds in the act of
%% failing most of the time. A world is a pure function of its seed and headless
%% ticking is fast, so a candidate can be run through its founding phase and kept
%% only if it survives.
%%
%% Asserted as the world being alive well past the founding phase, which an
%% unscreened draw fails two times in three.
%% GIVEN ROOM, because screening is real work: up to twenty-four candidates run
%% seven hundred ticks each, in `init/1', before the server answers anything.
%% Eunit's default five seconds is not enough and the failure it produces is a
%% timeout on the first call, which reads as a broken server rather than a slow
%% start.
%%
%% SMALL SLOTS AND A POLL, because a `gen_server:call' queues behind a whole slot
%% and carries its own five second limit that eunit's `timeout' does not touch. A
%% slot of eight hundred ticks over a thriving world can exceed it, and then the
%% test fails on a call timeout, leaves the server registered, and the next test
%% fails with `already_started' for a reason that has nothing to do with it.
%%
%% ASSERTED AS THE PROMISE AND NOT MORE. Screening keeps a seed that is alive AT
%% the horizon; it says nothing about the tick after. World 9's survey found
%% extinctions at 601, 630 and 725, so a screened world dying at 725 is the
%% documented failure mode arriving just past the fence rather than a broken
%% screen. `population > 0' at whatever tick the poll happens to catch asserts
%% something the mechanism never offered, and failed about one run in three.
%%
%% A PROBABILISTIC GUARD, AND SAYING SO. Turning screening off in here goes red
%% in two runs of six measured, not in six of six, because roughly a third of raw
%% draws are dead by the horizon and the rest die later or not at all. It catches
%% a screen that has stopped working within a few CI runs rather than on the
%% first, and there is no deterministic version of it while the seed comes from
%% the clock.
a_drawn_seed_is_screened_for_viability_test_() ->
    {timeout, 120,
     fun() ->
         quietly([{"HECATE_BIOTOPE_SCREEN_TRIES", "24"},
                  {"HECATE_BIOTOPE_SLOT_MS", "1"},
                  {"HECATE_BIOTOPE_TICKS_PER_SLOT", "50"}],
                  fun() ->
                      Pid = start(),
                      #{extinct_at := Ended, tick := Tick} = past(700, 600),
                      stop(Pid),
                      ?assert(Tick > 700),
                      ?assert(Ended =:= undefined orelse Ended > 700)
                  end)
     end}.

%% Wait for the world to reach a tick, and give up rather than hang.
past(_Tick, 0) -> error(too_slow);
past(Tick, Tries) ->
    timer:sleep(50),
    reached(world_server:snapshot(), Tick, Tries).

reached(#{tick := At} = Snap, Tick, _Tries) when At > Tick -> Snap;
reached(_Snap, Tick, Tries) -> past(Tick, Tries - 1).

%% A PINNED SEED IS NEVER SCREENED. Pinning means run exactly this world, and
%% quietly running a different one because the pinned one dies is the opposite of
%% what pinning asks for. Seed 303 dies, and it must be allowed to.
a_pinned_seed_is_run_even_when_it_dies_test() ->
    with_env([{"HECATE_BIOTOPE_SEED", "303"},
              {"HECATE_BIOTOPE_SLOT_MS", "1"},
              {"HECATE_BIOTOPE_TICKS_PER_SLOT", "50"}],
             fun() ->
                 Pid = start(),
                 timer:sleep(200),
                 #{seed := Seed} = world_server:snapshot(),
                 stop(Pid),
                 ?assertEqual(303, Seed)
             end).
