#!/usr/bin/env escript
%% @doc Run an island on this machine and watch it in a browser.
%%
%% Usage, from the repository root:
%%
%%   rebar3 compile
%%   scripts/watch_locally.escript [port]
%%
%% NO MESH, NO REALM, NO SECRET, NO CONTAINER. This starts the world and the
%% page and nothing else, which is the whole point: the first thing a stranger
%% should be able to do is watch a world, and requiring a realm tag to see one
%% would put a registration desk in front of the only interesting part.
%%
%% `scripts/watch_island.escript' is the opposite instrument and the names are
%% close enough to be worth separating here. That one SUBSCRIBES to an island
%% over the mesh and prints the facts arriving, to prove the published contract.
%% This one RUNS an island with no mesh at all.
%%
%% The world begins again by itself whenever one ends, which at world 17's
%% survival rate is often. That is not a fault and the page says so: extinction
%% is the most common thing that happens here, and an island that restarted
%% invisibly would hide the most common result in the project.
-mode(compile).

-define(DEFAULT_PORT, "8610").

main(Args) ->
    ok = paths(),
    Port = port(Args),
    os:putenv("HECATE_BIOTOPE_UI_PORT", Port),
    %% A watchable pace rather than the image's headless default. Ten ticks a
    %% second against one frame a second runs well and watches badly.
    default("HECATE_BIOTOPE_TICKS_PER_SLOT", "1"),
    default("HECATE_BIOTOPE_SLOT_MS", "500"),
    default("HECATE_BIOTOPE_CHART_MS", "500"),
    default("HECATE_BIOTOPE_ISLAND", "local"),
    %% Screening costs a candidate world per rejected seed and most seeds die,
    %% so a laptop waits a noticeable moment before the first frame. Lower than
    %% the fleet's sixty on purpose: someone trying this out would rather see a
    %% world that may not last than a blank page for a minute.
    default("HECATE_BIOTOPE_SCREEN_TRIES", "12"),
    {ok, _} = application:ensure_all_started(ranch),
    {ok, _} = application:ensure_all_started(cowboy),
    %% THE LINK IS PRINTED BEFORE THE WAIT, not after it. Screening takes a
    %% noticeable moment on a laptop and a script that prints nothing until it
    %% finishes is a script that looks hung. The page is already listening; it
    %% simply has nothing to draw yet.
    invite(Port),
    {ok, _} = world_server:start_link(),
    [{ok, _} = supervisor:start_child(kernel_sup, Spec)
     || Spec <- island_ui:child_specs()],
    announce(),
    forever().

%% Every dep, because the page needs ranch and cowboy as well as the world, and
%% a shebang `-pa' cannot glob.
paths() ->
    Libs = filelib:wildcard("_build/default/lib/*/ebin"),
    ok = code:add_pathsz(Libs),
    built(code:which(world)).

built(non_existing) ->
    io:format("~nNothing is built. Run `rebar3 compile` first.~n"),
    halt(1);
built(_Beam) -> ok.

port([]) -> ?DEFAULT_PORT;
port([P | _Rest]) -> P.

%% The environment wins if it is already set, so this script configures a
%% default rather than overriding a choice somebody made deliberately.
default(Var, Value) -> set(os:getenv(Var), Var, Value).

set(false, Var, Value) -> os:putenv(Var, Value);
set("", Var, Value) -> os:putenv(Var, Value);
set(_Already, _Var, _Value) -> ok.

%% `snapshot/0' BLOCKS UNTIL SCREENING FINISHES, which is what makes this land at
%% the right moment rather than announcing a world that does not exist yet.
%% Screening happens in `handle_continue', so it runs before any other message
%% and this call queues behind it. It needs no timeout of its own: `world_server'
%% gives every read a generous one for exactly this reason.
invite(Port) ->
    #{number := N, line := Line} = world:ruleset(),
    io:format("~nworld ~p: ~s~n~n  http://localhost:~s~n~n"
              "screening for a viable seed, which takes a moment on a laptop.~n"
              "Most seeds in this world die, so the island tries several.~n",
              [N, Line, Port]).

announce() ->
    #{population := Pop, seed := Seed} = world_server:snapshot(),
    #{rejected := Rejected} = world_server:status(),
    io:format("~n~p creatures from seed ~p, after rejecting ~p.~n"
              "Space pauses the picture. Ctrl-C twice to stop.~n~n",
              [Pop, Seed, Rejected]).

forever() -> receive stop -> ok end.
