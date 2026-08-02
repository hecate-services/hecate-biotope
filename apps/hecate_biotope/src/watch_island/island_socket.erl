%% @doc The live connection: one frame pushed per frame the world makes.
%%
%% PUSHED AND NOT POLLED. `world_server' already keeps its ticks and its output
%% on separate clocks, because tying one to the other "reads as obvious and
%% breaks at both ends of the range". A fixed poll on the browser side has the
%% same defect from the other direction: at `chart_ms' of 100 a one-second poll
%% throws away nine frames in ten, and at 5000 it makes five requests per frame
%% and four of them return a picture the viewer already has.
%%
%% So the island tells the page when a frame exists, because it is the thing that
%% made it. It costs no dependency: cowboy is already here for `/health'.
%%
%% TWO TEXT FRAMES PER TICK, TAGGED BY THEIR FIRST BYTE. The board is JSON and
%% the vitals are HTML, and both are already rendered by something that is
%% tested. Wrapping the HTML inside the JSON would mean escaping it, which is a
%% string encoder this service does not have and does not need: a one-character
%% tag costs nothing and cannot be got wrong.
%%
%% `d' the board, packed integers for the painter
%% `v' the numbers, an HTML fragment the page swaps in whole
-module(island_socket).

-behaviour(cowboy_websocket).

-export([init/2, websocket_init/1, websocket_handle/2, websocket_info/2]).

init(Req, _Opts) ->
    %% A SHORT IDLE TIMEOUT WOULD CLOSE A HEALTHY SOCKET. A world can legitimately
    %% go a long time between frames: `chart_ms' is settable from the page itself
    %% and a paused picture is a supported state, so silence is not evidence of
    %% anything. Cowboy's default of sixty seconds would drop a viewer watching a
    %% deliberately slow island.
    {cowboy_websocket, Req, none, #{idle_timeout => 600000}}.

websocket_init(State) ->
    %% Registering here rather than in `init/2' because THAT RUNS IN THE REQUEST
    %% PROCESS AND THIS RUNS IN THE SOCKET PROCESS. Registering from the wrong one
    %% would monitor a pid that exits the moment the upgrade completes, so the
    %% island would drop every watcher immediately and push to nobody.
    {reply, opening(world_server:watch()), State}.

%% A world with its picture turned off can never send a frame, and a page waiting
%% politely for one would look exactly like a wedged island. Say so and close.
opening(no_frames) ->
    [{text, <<"vThis island has its picture turned off: chart_ms is 0, which is "
              "what a headless run wants. Set a frame interval to watch it.">>},
     close];
opening(ok) ->
    {text, <<"vconnected">>}.

%% The page sends nothing. Anything arriving is either a browser being clever or
%% somebody else's traffic, and neither is this socket's business.
websocket_handle(_Frame, State) -> {ok, State}.

websocket_info({biotope_frame, Chart, Snapshot, Pace, Status}, State) ->
    Ceiling = maps:get(ground_ceiling, maps:get(econ, Snapshot)),
    {[{text, [$d, island_json:encode(island_disc:packed(Chart, Ceiling))]},
      {text, [$v, island_vitals:html(Snapshot, Pace, Status)]}], State};
websocket_info(_Info, State) -> {ok, State}.
