%% @doc What a biotope says about itself, and where it says it. PURE.
%%
%% ONE FACT SO FAR: `world_advanced'. A periodic snapshot of the population, the
%% standing crop, and the totals since the world began.
%%
%% TOTALS RATHER THAN RATES, because a rate is recoverable from two totals and a
%% total is not recoverable from rates. A reader that misses a fact can still
%% work out what happened across the gap; a reader given only rates cannot.
%%
%% THE TICK NUMBER IS ON EVERY FACT, and it is not decoration. Publishing runs on
%% wall clock and the world runs on its own pace, so two consecutive facts may be
%% one tick apart or a million. Without the tick a reader cannot tell a stalled
%% world from a slow one, and cannot turn totals into rates at all.
%%
%% WIRE RULES, each earned by something that broke elsewhere: atom keys only, no
%% tuples as values, and numbers as integers. A tuple does not survive the mesh
%% cleanly, and an atom and a binary of the same name collide into one key.
-module(world_facts).

-export([topic/1, namespace/0, world_advanced/2]).

-define(DEFAULT_NS, <<"biotope">>).
-define(FACT_VERSION, 1).

%% Topics are `<namespace>/<leaf>'. The namespace is settable so two biotopes on
%% one mesh can be told apart before there is any notion of an island identity.
-spec topic(atom()) -> binary().
topic(world) -> leaf(<<"world">>).

leaf(Leaf) -> <<(namespace())/binary, "/", Leaf/binary>>.

-spec namespace() -> binary().
namespace() -> ns(os:getenv("HECATE_BIOTOPE_NS")).

ns(false) -> ?DEFAULT_NS;
ns("") -> ?DEFAULT_NS;
ns(Str) -> list_to_binary(string:trim(Str)).

%% @doc The periodic snapshot. Takes the world's own snapshot map and the pace,
%% so a reader can see how fast this biotope is running without inferring it.
-spec world_advanced(map(), world_pace:pace()) -> map().
world_advanced(Snapshot, Pace) ->
    #{tick := Tick, population := Pop, plants := Plants, born := Born,
      starved := Starved, aged_out := Aged, eaten := Eaten,
      births_refused := Refused, energy_total := Energy,
      radius := Radius} = Snapshot,
    #{type => world_advanced,
      fact_version => ?FACT_VERSION,
      tick => Tick,
      population => Pop,
      plants => Plants,
      energy_total => Energy,
      radius => Radius,
      %% Totals since the world began, never reset.
      born => Born,
      starved => Starved,
      aged_out => Aged,
      eaten => Eaten,
      %% Non-zero means the safety valve bound and the population is NOT at a
      %% natural ceiling. Published so that never has to be guessed from shape.
      births_refused => Refused,
      ticks_per_second => world_pace:ticks_per_second(Pace)}.
