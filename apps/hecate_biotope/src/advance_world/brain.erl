%% @doc The thing that decides. PURE, INTEGER, and now much smaller than it was.
%%
%% A BRAIN PUTS A VALUE ON A PLACE. It does not choose between named actions,
%% because there are no longer any named actions to choose between. It reads what
%% the body measured about a candidate cell and returns a number, the creature
%% goes to whichever of the seven reachable cells scores highest, and everything
%% else in this world is a consequence of where things ended up.
%%
%% THE VERBS ARE GONE AND THAT IS THE WHOLE POINT. There used to be `graze',
%% `hunt' and `rest', which meant the categories herbivore and carnivore were
%% written into the physics and the diet statistic merely counted which of two
%% words fired. Now:
%%
%%   valuing cells with plant energy         IS grazing
%%   valuing cells with creature energy      IS predation
%%   valuing cells with LITTLE creature energy IS fleeing
%%   valuing your own cell where trails run  IS ambush
%%
%% None of those words appear anywhere in this code. They are descriptions an
%% observer may apply afterwards, which is what they should always have been, and
%% strategies nobody thought of are reachable by the same machinery.
%%
%% ONE WEIGHT PER SENSOR PLUS ONE FOR STAYING. A weight is what that measurement
%% is worth to this creature, and its SIGN is what makes attraction and avoidance
%% the same mechanism. There is no bias term, because a constant added to every
%% candidate alike cannot change which is largest.
%%
%% THE STAYING WEIGHT IS NOT A HIDDEN VERB. Movement costs energy and standing
%% still does not, so a creature that cannot tell where it already is cannot
%% express sitting tight, and every sedentary strategy would be unreachable
%% through no decision of its own. Knowing your own position is about as
%% elementary as perception gets.
%%
%% NO FLOATS AND NO ACTIVATION FUNCTION. Only the ORDER of the scores matters,
%% and every activation worth using is monotonic, so one would change the numbers
%% and not the outcome. Staying integer keeps a run bit-identical from its seed,
%% which is what lets the whole world be probed offline in seconds.
-module(brain).

-export([founder/3, inherit/4, value/3, width/1]).

-type brain() :: [integer()].
-export_type([brain/0]).

%% @doc How many weights a body of this many sensors needs: one each, and one
%% for staying put.
-spec width(non_neg_integer()) -> pos_integer().
width(Sensors) -> Sensors + 1.

%% @doc A founding brain: uniform random weights, one per sensor plus staying.
%%
%% RANDOM RATHER THAN ZERO. A population of zeroed brains values every cell
%% alike and wanders until mutation breaks the tie, wasting the early ticks.
%% Random founders already contain creatures drawn to plants, drawn to other
%% creatures, repelled by both, and disinclined to move at all, so selection has
%% something to sort from the first tick.
-spec founder(non_neg_integer(), map(), rand:state()) -> {brain(), rand:state()}.
founder(Sensors, Econ, Rng0) ->
    Range = maps:get(brain_range, Econ),
    lists:mapfoldl(fun(_I, R0) -> draw(Range, R0) end, Rng0,
                   lists:seq(1, width(Sensors))).

draw(Range, Rng0) ->
    {N, Rng1} = rand:uniform_s(2 * Range + 1, Rng0),
    {N - Range - 1, Rng1}.

%% @doc A child's brain: its parent's, restructured to match its body, then every
%% weight nudged.
%%
%% THE STRUCTURAL CHANGE COMES FIRST AND IT MUST MATCH THE BODY EXACTLY. A weight
%% list out of step with the sensor list is the worst kind of bug available here,
%% because nothing crashes: every weight after the change point quietly starts
%% valuing a different measurement, and the creature behaves like a garbled
%% version of its parent for reasons no test would name.
%%
%% A NEW SENSOR ARRIVES WEIGHTED AT ZERO rather than randomly. A random weight
%% would make growing a sensor a large behavioural jump in a random direction,
%% which is resampling rather than inheritance; at zero the child starts by
%% ignoring its new measurement and drift decides over generations whether to
%% attend to it. That is the difference between an organ appearing and an organ
%% being adopted.
-spec inherit(brain(), none | {added, pos_integer()} | {dropped, pos_integer()},
              map(), rand:state()) -> {brain(), rand:state()}.
inherit(Brain, Change, Econ, Rng0) ->
    Mut = maps:get(brain_mutation, Econ),
    Range = maps:get(brain_range, Econ),
    lists:mapfoldl(fun(W, R0) -> nudge(W, Mut, Range, R0) end, Rng0,
                   restructure(Change, Brain)).

restructure(none, Brain) -> Brain;
restructure({added, Pos}, Brain) ->
    {Before, After} = lists:split(Pos - 1, Brain),
    Before ++ [0 | After];
restructure({dropped, Pos}, Brain) ->
    {Before, [_Gone | After]} = lists:split(Pos - 1, Brain),
    Before ++ After.

%% Every weight, by a small symmetric step. Small and everywhere makes a lineage
%% drift through strategy space so intermediate forms exist and selection has a
%% gradient to climb. Symmetric so nothing here pushes weights anywhere on its
%% own.
nudge(W, 0, _Range, Rng) -> {W, Rng};
nudge(W, Mut, Range, Rng0) ->
    {Step, Rng1} = rand:uniform_s(2 * Mut + 1, Rng0),
    {clamp(W + Step - Mut - 1, Range), Rng1}.

%% Bounded, so a long-lived lineage cannot drift to weights that swamp every
%% measurement and turn the brain back into a constant that ignores the world.
clamp(W, Range) -> max(-Range, min(Range, W)).

%% @doc What this creature makes of a place.
%%
%% Readings arrive in sensor order and the weights follow it. `Staying' says
%% whether the cell being valued is the one the creature is already standing on.
-spec value(brain(), [integer()], boolean()) -> integer().
value(Brain, Readings, Staying) ->
    {Weights, [Stay]} = lists:split(length(Readings), Brain),
    lists:sum([W * R || {W, R} <- lists:zip(Weights, Readings)])
        + settled(Staying, Stay).

settled(true, Stay) -> Stay;
settled(false, _Stay) -> 0.
