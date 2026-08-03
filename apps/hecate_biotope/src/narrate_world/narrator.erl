%% @doc The commentator. Watches, and speaks when the world does something.
%%
%% ==========================================================================
%% IT WATCHES AND IT TALKS. IT NEVER PLAYS.
%% ==========================================================================
%%
%% This process reads snapshots and emits sentences. It cannot reach the world:
%% `world_server' is asked for a snapshot and is told nothing back, so no remark
%% can change a creature, a tick or an outcome, and a world remains a pure
%% function of its seed however talkative its narrator is. **The one thing that
%% must stay true of this file is that deleting it entirely would change no
%% world's history**, and a test asserts exactly that.
%%
%% ==========================================================================
%% IT SPEAKS WHEN SOMETHING HAPPENS, NOT WHEN A TIMER FIRES
%% ==========================================================================
%%
%% An island runs at two ticks a second for ever. Narrating on a schedule would
%% produce a paragraph a minute about a world that had not moved, cost real money
%% for every one of them, and teach a reader that the remarks are wallpaper.
%%
%% So it looks often and speaks rarely: `world_brief:changed_enough/2' decides,
%% and it answers yes only when the population has swung, the kinds have moved,
%% several new ways of living have turned up, or the world has stopped or
%% restarted finding them. Every remark is therefore ABOUT something.
%%
%% ==========================================================================
%% THE SENTENCE GOES ON THE MESH, AND THE PAGE READS IT FROM THERE
%% ==========================================================================
%%
%% Written once, published as a fact, and the island's own page renders that same
%% fact. Not two copies and not two narrators: a spectator anywhere and the owner
%% looking at their own machine read the identical sentence, which is the same
%% argument the chart already makes for being computed once.
-module(narrator).

-behaviour(gen_server).

-export([start_link/0, child_specs/0, latest/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).

%% How often it LOOKS, which is not how often it speaks. Cheap: a snapshot and a
%% comparison of two flat maps.
-define(WATCH_MS, 30000).

%% ⚠ A FLOOR ON HOW OFTEN IT MAY SPEAK, on top of the change test. A world can
%% thrash across a threshold repeatedly, and a narrator that remarked on every
%% crossing would be both expensive and tedious. Five minutes is long enough that
%% a reader who looks away and comes back has missed nothing.
-define(QUIET_MS, 300000).

-record(state, {said = none :: none | map(),
                spoke_at = 0 :: integer(),
                text = none :: none | binary(),
                model = none :: none | binary(),
                brief = none :: none | map(),
                remarks = 0 :: non_neg_integer()}).

%% @doc Started only if this island has been given a model to ask. An island
%% without one runs identically and publishes nothing, exactly as it does without
%% a local page.
-spec child_specs() -> [supervisor:child_spec()].
child_specs() -> wanted(ask_a_model:configured()).

wanted(false) -> [];
wanted(true) ->
    [#{id => narrator, start => {?MODULE, start_link, []},
       restart => permanent, shutdown => 5000, type => worker}].

start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%% @doc The last thing said, for the island's own page. `none' before the first
%% remark, which a page renders as nothing rather than as an error.
-spec latest() -> none | map().
latest() -> called(erlang:whereis(?MODULE)).

called(undefined) -> none;
called(Pid) -> gen_server:call(Pid, latest, 5000).

init([]) ->
    erlang:send_after(?WATCH_MS, self(), look),
    {ok, #state{}}.

handle_call(latest, _From, #state{text = none} = S) -> {reply, none, S};
handle_call(latest, _From, #state{} = S) ->
    {reply, #{text => S#state.text, model => S#state.model,
              derived_from => S#state.brief, remarks => S#state.remarks}, S};
handle_call(_Msg, _From, S) -> {reply, {error, unknown}, S}.

handle_cast(_Msg, S) -> {noreply, S}.

handle_info(look, S) ->
    erlang:send_after(?WATCH_MS, self(), look),
    {noreply, consider(world_brief:of_world(world_server:snapshot()), S)};
handle_info({said, _Brief, silent}, S) ->
    {noreply, S};
handle_info({said, Brief, {ok, Text, Model}}, #state{remarks = N} = S) ->
    Fact = world_facts:world_narrated(Text, Model, Brief),
    biotope_mesh:publish(world_facts:topic(narration), Fact),
    {noreply, S#state{text = Text, model = Model, brief = Brief,
                      remarks = N + 1}};
handle_info(_Msg, S) ->
    {noreply, S}.

%% ⚠ THE MODEL IS ASKED IN A SEPARATE PROCESS AND THE ANSWER COMES BACK AS A
%% MESSAGE. A twenty-second HTTP call inside `handle_info' would block this
%% process, and a narrator that is busy is a narrator that stops looking. It
%% cannot block the WORLD either way, since the world runs in `world_server' and
%% this only ever reads from it.
consider(Brief, #state{said = Said, spoke_at = At} = S) ->
    Now = erlang:monotonic_time(millisecond),
    asked(world_brief:changed_enough(Said, Brief) andalso Now - At > ?QUIET_MS,
          Brief, Now, S).

asked(false, _Brief, _Now, S) -> S;
asked(true, Brief, Now, S) ->
    Me = self(),
    spawn(fun() -> Me ! {said, Brief, ask_a_model:describe(Brief, island())} end),
    %% Marked as spoken BEFORE the answer arrives, so a model that is slow or
    %% unreachable cannot be asked again every thirty seconds while the first
    %% call is still outstanding.
    S#state{said = Brief, spoke_at = Now}.

island() -> world_facts:island().

