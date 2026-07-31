%% @doc The thing that decides. PURE, INTEGER, and deliberately small.
%%
%% A brain reads what the body perceives and returns one of three intents:
%% `graze', `hunt' or `rest'. It is a single layer of integer weights, one row
%% per intent, scored and compared. The largest score wins.
%%
%% NO FLOATS, NO ACTIVATION FUNCTION, AND THAT IS NOT A SHORTCUT. Comparing
%% scores only needs their order, and every activation function worth using is
%% monotonic, so a sigmoid or a tanh here would change the numbers and not the
%% decision. Dropping it removes the dependency on libm, which is the exact thing
%% that forced a whole native module to exist in the sibling rumbler, and it
%% keeps the world integer-only so a run is bit-identical from its seed on any
%% machine. That reproducibility is what lets the economy be probed offline in
%% seconds, and that probe has already paid for itself once.
%%
%% ONE LAYER IS ENOUGH FOR THE QUESTION BEING ASKED. The question is whether
%% diet differentiates, and a single layer over four senses can already express
%% every strategy worth naming here: graze always, hunt always, hunt when
%% starving, hunt when a fat neighbour is close, rest when nothing is near. Those
%% are linear boundaries. A hidden layer buys combinations like "hunt only if fat
%% prey AND I am weak", which is worth having later, and can be added without
%% changing this interface. Building it now would mean tuning a bigger thing
%% before knowing the smaller one moves at all.
%%
%% THE BRAIN IS NOT TOLD WHAT IT IS. There is no herbivore flag, no carnivore
%% flag, no role. There are three intents available to every creature alike, and
%% whatever a lineage becomes is what its weights make it do. Diet here is a
%% MEASUREMENT taken afterwards, never a parameter set beforehand.
-module(brain).

-export([founder/2, inherit/3, decide/2, actions/0, size/0]).

-type action() :: graze | hunt | rest.
-type brain() :: [integer()].
-export_type([action/0, brain/0]).

%% Fixed order, and it is the order of the weight rows. Also the tie-break order.
-define(ACTIONS, [graze, hunt, rest]).

%% @doc The intents every creature has, in canonical order.
-spec actions() -> [action()].
actions() -> ?ACTIONS.

%% @doc How many weights a brain holds: one row per action, one weight per sense
%% plus a bias.
-spec size() -> pos_integer().
size() -> length(?ACTIONS) * (body:sense_width() + 1).

%% @doc A founding brain: uniform random weights.
%%
%% RANDOM RATHER THAN ZERO. A population of zeroed brains is a population that
%% all takes the same action forever until mutation breaks the tie, which wastes
%% the early ticks and makes a short run look like nothing is happening. Random
%% founders also mean the first generation already contains grazers, hunters and
%% loafers, so selection has something to sort on tick one.
-spec founder(map(), rand:state()) -> {brain(), rand:state()}.
founder(Econ, Rng0) ->
    Range = maps:get(brain_range, Econ),
    lists:mapfoldl(fun(_I, R0) -> draw(Range, R0) end, Rng0,
                   lists:seq(1, size())).

draw(Range, Rng0) ->
    {N, Rng1} = rand:uniform_s(2 * Range + 1, Rng0),
    {N - Range - 1, Rng1}.

%% @doc A child's brain: its parent's, every weight nudged.
%%
%% EVERY WEIGHT, BY A SMALL SYMMETRIC STEP, rather than one weight by a large
%% one. Small and everywhere makes a lineage DRIFT through strategy space, so
%% intermediate forms exist and selection can climb; large and rare makes
%% children who are unrelated to their parents, which is not inheritance, it is
%% resampling. The steps are symmetric so nothing here pushes weights in any
%% direction on its own.
-spec inherit(brain(), map(), rand:state()) -> {brain(), rand:state()}.
inherit(Brain, Econ, Rng0) ->
    Mut = maps:get(brain_mutation, Econ),
    Range = maps:get(brain_range, Econ),
    lists:mapfoldl(fun(W, R0) -> nudge(W, Mut, Range, R0) end, Rng0, Brain).

nudge(W, 0, _Range, Rng) -> {W, Rng};
nudge(W, Mut, Range, Rng0) ->
    {Step, Rng1} = rand:uniform_s(2 * Mut + 1, Rng0),
    {clamp(W + Step - Mut - 1, Range), Rng1}.

%% Bounded so that a long-lived lineage cannot drift to weights that swamp every
%% sense and turn the brain back into a constant.
clamp(W, Range) -> max(-Range, min(Range, W)).

%% @doc Read the senses, return the intent.
%%
%% Ties go to the earlier action in ?ACTIONS, which puts grazing ahead of hunting
%% ahead of resting. Arbitrary, but fixed and stated: a tie broken by whatever
%% the comparison happens to do is a coin nobody can inspect.
-spec decide(brain(), [integer()]) -> action().
decide(Brain, Senses) ->
    Scores = [score(Row, Senses) || Row <- rows(Brain)],
    best(lists:zip(Scores, ?ACTIONS)).

%% Rows of `sense_width + 1': the weights, then the bias.
rows([]) -> [];
rows(Brain) ->
    {Row, Rest} = lists:split(body:sense_width() + 1, Brain),
    [Row | rows(Rest)].

score(Row, Senses) ->
    {Weights, [Bias]} = lists:split(body:sense_width(), Row),
    lists:sum([W * S || {W, S} <- lists:zip(Weights, Senses)]) + Bias.

best(Scored) ->
    {_Score, Action} = lists:foldl(fun higher/2, hd(Scored), tl(Scored)),
    Action.

higher({S, A}, {Best, _}) when S > Best -> {S, A};
higher(_Candidate, Winner) -> Winner.
