%% @doc The two pieces the page re-fetches while you watch: the board and the
%% numbers. One handler, told which by its route options.
%%
%% ⚠ THE PAGE DOES NOT USE THESE. It receives both over the socket, pushed when
%% a frame exists rather than fetched on a guess. These stay because they are the
%% same two renderers behind a URL, which is what makes the island inspectable
%% with `curl' and what a page with no WebSocket could fall back to.
%%
%% The board is numbers and the vitals are markup, and both are decided HERE:
%% where every mark goes, how big it is, what colour it is. Those are statements
%% about the physics, and a browser that recomputed any of them would be `I.6'
%% with a second copy of a rule.
-module(island_fragment).

-export([init/2]).

init(Req, disc) ->
    Ceiling = maps:get(ground_ceiling, world:defaults()),
    {ok, reply(<<"application/json">>,
               island_json:encode(island_disc:packed(world_server:chart(), Ceiling)),
               Req), disc};
init(Req, vitals) ->
    {ok, reply(<<"text/html; charset=utf-8">>,
               island_vitals:html(world_server:snapshot(),
                                  world_server:pace(),
                                  world_server:status()), Req), vitals}.

reply(Type, Body, Req) ->
    cowboy_req:reply(200, #{<<"content-type">> => Type,
                            <<"cache-control">> => <<"no-store">>}, Body, Req).
