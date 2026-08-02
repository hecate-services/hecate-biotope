%% @doc The two pieces the page re-fetches while you watch: the board and the
%% numbers. One handler, told which by its route options.
%%
%% FRAGMENTS AND NOT JSON, deliberately. The island already knows how to render
%% both, and shipping JSON would mean a second renderer in the browser that can
%% disagree with this one. `I.6' is what a second copy of a truth does: it is
%% correct when written and silently stops agreeing when the rule changes.
%%
%% It also means the page works without reimplementing hexagonal geometry in
%% JavaScript, and that the whole UI is one language.
-module(island_fragment).

-export([init/2]).

init(Req, disc) ->
    Ceiling = maps:get(ground_ceiling, world:defaults()),
    {ok, reply(<<"application/json">>,
               json(island_disc:packed(world_server:chart(), Ceiling)),
               Req), disc};
init(Req, vitals) ->
    {ok, reply(<<"text/html; charset=utf-8">>,
               island_vitals:html(world_server:snapshot(),
                                  world_server:pace(),
                                  world_server:status()), Req), vitals}.

reply(Type, Body, Req) ->
    cowboy_req:reply(200, #{<<"content-type">> => Type,
                            <<"cache-control">> => <<"no-store">>}, Body, Req).

%% A JSON WRITER OF EXACTLY ONE SHAPE, and no dependency for it. Everything
%% `island_disc:packed/2' produces is an integer or a flat list of integers, by
%% construction, so this is a fold and a comma. Pulling in an encoder to serialise
%% four arrays of numbers would be the larger of the two mistakes available.
json(Map) ->
    [${, lists:join($,, [pair(K, V) || {K, V} <- lists:sort(maps:to_list(Map))]),
     $}].

pair(Key, Value) -> [$", atom_to_binary(Key), $", $:, value(Value)].

value(N) when is_integer(N) -> integer_to_binary(N);
value(F) when is_float(F) -> float_to_binary(F, [{decimals, 2}, compact]);
value(L) when is_list(L) ->
    [$[, lists:join($,, [value(V) || V <- L]), $]].
