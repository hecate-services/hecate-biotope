%% @doc How fast a biotope runs, and how often it says so. PURE.
%%
%% ONE MECHANISM COVERS BOTH MODES, which is why this is two numbers rather than
%% a mode switch. The world advances `ticks_per_slot' times, then yields for
%% `slot_ms' milliseconds. A world you WATCH is one tick every hundred
%% milliseconds. A world you SEARCH is a thousand ticks every millisecond. The
%% code is identical; only the arithmetic differs, and yielding between slots is
%% what keeps even the fast setting a citizen on a shared box rather than a
%% process that never lets go of a scheduler.
%%
%% PUBLISHING IS ON ITS OWN CLOCK, DELIBERATELY. Tying a fact to a tick reads as
%% the obvious thing and breaks immediately at speed: at a thousand ticks per
%% millisecond a fact per tick is a flood nobody can read, and at one tick per
%% second a fact per tick is a service that looks dead between beats. A fact
%% every `publish_ms' of WALL CLOCK is legible at any pace, and it carries the
%% tick number so a reader can see how far the world moved between two of them.
%%
%% NOTHING HERE IS ABOUT SEARCH YET, and that is worth saying plainly rather than
%% implying otherwise: there is no brain and no selection, so a fast biotope
%% currently computes a random walk very quickly. The pacing is parameterised now
%% because it costs two numbers and settles the question, not because the fast
%% setting has a consumer.
-module(world_pace).

-export([from_env/0, from_map/1, ticks_per_second/1]).

-type pace() :: #{ticks_per_slot := pos_integer(),
                  slot_ms := non_neg_integer(),
                  publish_ms := pos_integer()}.
-export_type([pace/0]).

%% Watchable by default. An island nobody can see is hard to care about, and the
%% headless speed stays available to any experiment through the pure `world'
%% module without a service in the way.
-define(DEFAULTS, #{ticks_per_slot => 1,
                    slot_ms => 100,
                    publish_ms => 1000}).

-spec from_env() -> pace().
from_env() ->
    from_map(#{ticks_per_slot => env_int("HECATE_BIOTOPE_TICKS_PER_SLOT"),
               slot_ms        => env_int("HECATE_BIOTOPE_SLOT_MS"),
               publish_ms     => env_int("HECATE_BIOTOPE_PUBLISH_MS")}).

%% Unset keys fall back; a set-but-unparseable key is an error rather than a
%% fallback, because a typo that silently runs at the default pace is a service
%% that ignores its own configuration and reports success.
-spec from_map(map()) -> pace().
from_map(Given) ->
    Present = maps:filter(fun(_K, V) -> V =/= undefined end, Given),
    maps:merge(?DEFAULTS, Present).

%% What the two numbers actually mean, for a log line or a fact. A zero slot is
%% "yield and come straight back", which the scheduler still honours.
-spec ticks_per_second(pace()) -> integer().
ticks_per_second(#{ticks_per_slot := N, slot_ms := 0}) -> N * 1000;
ticks_per_second(#{ticks_per_slot := N, slot_ms := Ms}) -> (N * 1000) div Ms.

env_int(Name) -> parse_int(Name, os:getenv(Name)).

parse_int(_Name, false) -> undefined;
parse_int(_Name, "") -> undefined;
parse_int(Name, Str) ->
    try list_to_integer(string:trim(Str))
    catch error:badarg -> error({not_an_integer, Name, Str})
    end.
