%% @doc Applying what an owner changed. Cowboy handler for `POST /settings'.
%%
%% ⚠ THE PHYSICS ARE NOT REACHABLE FROM HERE AND THAT IS ENFORCED, not merely
%% left out of the form. `accepted/0' is a fixed list, anything else in the body
%% is dropped, and a browser or a script posting `metabolism=0' changes nothing.
%% A settings endpoint that trusted its form to be the only caller would be one
%% `curl' away from an island running rules nobody can read against any other.
%%
%% The reason is not safety, it is comparability: the fleet is a set of
%% REPLICATES, and three islands running three economies give no replicate of
%% anything. See `I.9', which is the same rule learned from the other side, where
%% a deployment config named a physics constant and cost two hours of a dead
%% island.
-module(island_settings).

-export([init/2, accepted/0, pace_from/2]).

%% @doc What may be set. The name of the island and how fast it is watched.
%% NEITHER IS PHYSICS: no world's arithmetic reads any of them, and two islands
%% differing only in these are the same experiment run at different speeds.
-spec accepted() -> [binary()].
accepted() ->
    [<<"ticks_per_slot">>, <<"slot_ms">>, <<"publish_ms">>, <<"chart_ms">>].

init(Req0, State) ->
    {ok, Body, Req} = cowboy_req:read_urlencoded_body(Req0),
    ok = rename(lists:keyfind(<<"island">>, 1, Body)),
    ok = world_server:set_pace(pace_from(Body, world_server:pace())),
    {ok, cowboy_req:reply(303, #{<<"location">> => <<"/">>}, <<>>, Req), State}.

%% An empty name is ignored rather than accepted. The island name is its identity
%% on the mesh and a blank one would publish facts nobody can attribute; the old
%% name is a better answer than none.
rename({_Key, <<>>}) -> ok;
rename({_Key, Name}) -> world_facts:set_island(Name);
rename(false) -> ok.

%% @doc The new pace, built from the old one and whatever of the accepted keys
%% arrived and parsed. Exported to be tested, because the interesting cases are
%% the ones a form never sends: a missing key, a key that is not a number, and a
%% key nobody is allowed to set.
%%
%% AN UNPARSEABLE VALUE FALLS BACK RATHER THAN CRASHING, which is the opposite of
%% what `world_pace:from_env/1' does with the environment and is right for the
%% opposite reason. A typo in a config file is a deployment that must fail loudly.
%% A typo in a text box is a person, and taking down their island over it would
%% be absurd.
-spec pace_from([{binary(), binary()}], map()) -> map().
pace_from(Body, Pace) ->
    lists:foldl(fun(Key, Acc) -> apply_one(Key, Body, Acc) end, Pace,
                accepted()).

apply_one(Key, Body, Pace) ->
    set(lists:keyfind(Key, 1, Body), binary_to_atom(Key), Pace).

set(false, _Field, Pace) -> Pace;
set({_Key, Value}, Field, Pace) -> maybe_set(number(Value), Field, Pace).

maybe_set(error, _Field, Pace) -> Pace;
%% A slot of zero means "yield and come straight back", which is a legitimate
%% headless setting, and a chart of zero turns the picture off. Both are floors
%% rather than errors. `ticks_per_slot' of zero would stop the world, so it is
%% the one that has to be at least one.
maybe_set({ok, N}, ticks_per_slot, Pace) -> Pace#{ticks_per_slot => max(1, N)};
maybe_set({ok, N}, Field, Pace) -> Pace#{Field => max(0, N)}.

number(Bin) -> parsed(string:to_integer(string:trim(Bin))).

parsed({N, <<>>}) when is_integer(N) -> {ok, N};
parsed(_Anything) -> error.
