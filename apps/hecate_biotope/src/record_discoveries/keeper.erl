%% @doc Writes the notebook. Watches a world and appends what it finds.
%%
%% ==========================================================================
%% IT WATCHES AND IT WRITES. IT NEVER PLAYS.
%% ==========================================================================
%%
%% The same arrangement as the narrator, for the same reason: this reads
%% snapshots and appends events, and nothing it does can reach a creature, a tick
%% or an outcome. A world remains a pure function of its seed, and **deleting
%% this slice would cost the record and not one creature's history**.
%%
%% ==========================================================================
%% IT DIFFS RATHER THAN BEING TOLD
%% ==========================================================================
%%
%% `world.erl' stays pure and knows nothing about a store. This process holds the
%% last snapshot it wrote about and works out what is new: which behaviour cells
%% appeared, whether the frontier crossed zero, whether the world ended, whether
%% the run changed underneath it.
%%
%% ⚠ A RUN CHANGING IS THE CASE THAT MATTERS AND IS EASY TO MISS. Most seeds die
%% and the island immediately begins another. Without noticing the seed change
%% this would append the new world's discoveries to the old world's stream, and a
%% year later two worlds would be one indistinguishable notebook.
-module(keeper).

-behaviour(gen_server).

-export([start_link/0, child_specs/0, written/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).

%% Often enough that a discovery is recorded near the tick it happened, cheap
%% enough to be free: a snapshot and a map comparison.
-define(WATCH_MS, 5000).

-record(state, {seed = none :: none | integer(),
                stream = none :: none | binary(),
                seen = #{} :: map(),
                settled = false :: boolean(),
                ended = false :: boolean(),
                written = 0 :: non_neg_integer(),
                failed = 0 :: non_neg_integer()}).

%% @doc Started only when a store is open. A service without `store_id/0' has
%% nowhere to write and this keeps no notebook, exactly as an island without a
%% key keeps no narrator.
-spec child_specs() -> [supervisor:child_spec()].
child_specs() -> wanted(erlang:function_exported(hecate_biotope_service, store_id, 0)).

wanted(false) -> [];
wanted(true) ->
    [#{id => keeper, start => {?MODULE, start_link, []},
       restart => permanent, shutdown => 5000, type => worker}].

start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%% @doc How much has been written, and how much failed to be. Exported because
%% an append that quietly fails leaves a notebook with holes in it and no way to
%% know, which is the shape of every bug in the narrator slice.
-spec written() -> map().
written() -> asked(erlang:whereis(?MODULE)).

asked(undefined) -> #{written => 0, failed => 0};
asked(Pid) -> gen_server:call(Pid, written, 5000).

init([]) ->
    erlang:send_after(?WATCH_MS, self(), look),
    {ok, #state{}}.

handle_call(written, _From, S) ->
    {reply, #{written => S#state.written, failed => S#state.failed,
              stream => S#state.stream}, S};
handle_call(_Msg, _From, S) -> {reply, {error, unknown}, S}.

handle_cast(_Msg, S) -> {noreply, S}.

handle_info(look, S) ->
    erlang:send_after(?WATCH_MS, self(), look),
    {noreply, inspect(world_server:snapshot(), S)}.

%% A run is identified by its seed. A different seed is a different world, gets
%% its own stream, and is opened with a `world_seeded'.
inspect(#{seed := Seed} = Snap, #state{seed = Seed} = S) ->
    carry_on(Snap, S);
inspect(#{seed := Seed} = Snap, S) ->
    Fresh = #state{seed = Seed,
                   stream = discovery:stream_for(world_facts:island(), Seed),
                   written = S#state.written, failed = S#state.failed},
    carry_on(Snap, append(discovery:seeded(Snap), Fresh)).

carry_on(Snap, S) ->
    lists:foldl(fun(Step, Acc) -> Step(Snap, Acc) end, S,
                [fun discoveries/2, fun stillness/2, fun death/2]).

%% ==========================================================================
%% WHAT IS NEW SINCE LAST TIME
%% ==========================================================================
%%
%% The archive arrives flat, three integers per cell: which cell, the tick it was
%% first seen, and the deepest lineage that ever lived that way. A cell this
%% process has not written about yet is a discovery.
%%
%% ⚠ THE FIRST LOOK OF A RUN WRITES EVERY CELL ALREADY FOUND, and that is
%% correct rather than a flood: five seconds into a world there are a handful,
%% and each really was found. Restarting this process mid-run would rewrite them,
%% which is a duplicate in the notebook and not a wrong entry; the alternative is
%% losing discoveries to a restart, and a duplicate is the cheaper mistake.
discoveries(Snap, #state{seen = Seen} = S) ->
    Cells = pairs(maps:get(archive, Snap, [])),
    lists:foldl(fun({Cell, At}, Acc) -> note(maps:is_key(Cell, Seen), Cell, At,
                                             Snap, Acc)
                end, S, Cells).

note(true, _Cell, _At, _Snap, S) -> S;
note(false, Cell, At, Snap, #state{seen = Seen} = S) ->
    append(discovery:found(Cell, At, Snap), S#state{seen = Seen#{Cell => At}}).

%% Stride three: cell, first seen, best depth. The depth is not kept here; it is
%% a live number and this file records events rather than state.
pairs([Cell, At, _Best | Rest]) -> [{Cell, At} | pairs(Rest)];
pairs(_Short) -> [].

%% ==========================================================================
%% WHETHER IT IS STILL FINDING ANYTHING
%% ==========================================================================
%%
%% Written on the CROSSING, not on the state, so a settled world produces one
%% event and not one every five seconds for as long as it stays settled.
stillness(Snap, #state{settled = Was} = S) ->
    crossed(maps:get(frontier, Snap, 1) =:= 0, Was, Snap, S).

crossed(Same, Same, _Snap, S) -> S;
crossed(true, false, Snap, S) ->
    append(discovery:settled(maps:get(tick, Snap, 0), Snap),
           S#state{settled = true});
crossed(false, true, Snap, S) ->
    append(discovery:stirred(maps:get(tick, Snap, 0), Snap),
           S#state{settled = false}).

%% ==========================================================================
%% AND WHETHER IT IS OVER
%% ==========================================================================
%%
%% Once per run. A dead island keeps publishing: its ground regrows and its tick
%% advances, so without the flag this would write an ending every five seconds
%% until the next seed is drawn.
death(#{population := 0} = Snap, #state{ended = false} = S) ->
    append(discovery:ended(Snap), S#state{ended = true});
death(_Snap, S) -> S.

%% ==========================================================================
%% The append
%% ==========================================================================
%%
%% ⚠ A FAILED APPEND IS COUNTED AND LOGGED, NEVER SWALLOWED. The narrator treats
%% every failure as silence because a missing sentence costs nothing; a missing
%% discovery is a hole in the record that nothing later can tell from a world
%% that never made one. Three bugs in that slice hid inside its own error
%% handling and this one is not repeating it.
append(Event, #state{stream = Stream} = S) ->
    Store = hecate_biotope_service:store_id(),
    recorded(reckon_gater_api:append_events(Store, Stream, [Event]), Event, S).

recorded({ok, _Version}, Event, #state{written = N} = S) ->
    logger:debug("biotope: recorded ~s at tick ~p",
                 [maps:get(event_type, Event), maps:get(tick, Event, 0)]),
    S#state{written = N + 1};
recorded({error, Why}, Event, #state{failed = N} = S) ->
    logger:warning("biotope: could NOT record ~s at tick ~p: ~p",
                   [maps:get(event_type, Event), maps:get(tick, Event, 0), Why]),
    S#state{failed = N + 1}.
