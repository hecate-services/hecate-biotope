%% @doc What a creature is built from. PURE.
%%
%% A BODY IS A LIST OF SENSORS AND A SENSOR IS `{Field, Range}'. Nothing is
%% named. There is no eye, no nose, no gut, and that absence is the point of this
%% rewrite: those names were biological conclusions written into the physics, and
%% a world whose rules already contain "eye" cannot discover that seeing was
%% worth doing.
%%
%% WHICH FIELDS EXIST IS PHYSICS. There are plants, there are creatures, and
%% there are the marks creatures leave behind. Those are the three kinds of thing
%% in this world, so those are the three quantities that can be measured. WHICH
%% ONE A LINEAGE MEASURES IS BIOLOGY, and therefore not ours to write. A body
%% may carry none of them, several of the same, or all three at different ranges.
%%
%% RANGE IS OPEN AND COSTS. A sensor reads its field summed over every cell
%% within Range of the cell being valued, so range 0 reports what is underfoot
%% and larger ranges report which direction is richer. There is no list of
%% allowed ranges to pick from; mutation moves the number and rent decides
%% whether it was worth it.
%%
%% THE RENT SCALES WITH RANGE AND THE FORM IS A MODELLING CHOICE, stated plainly
%% because we have just spent a session cleaning up constants that were chosen
%% for the results they produced. Reach costs: that much is physical. Whether it
%% costs proportionally to the radius, as here, or to the AREA covered, which
%% grows as 3r^2+3r+1, is not settled by anything in this world. Area scaling was
%% rejected only because at rent 1 a range-two sensor would cost nineteen a tick
%% against a metabolism of one, which prices reach out of existence before
%% selection gets a look. That is a judgement about the ECONOMY being able to
%% express the option, not about what should evolve.
-module(body).

-export([founder/2, inherit/3, upkeep/2, fields/0, scale/1]).
-export([census/1, sensor_count/1]).

-type field() :: plants | creatures | scent.
-type sensor() :: {field(), non_neg_integer()}.
-type body() :: [sensor()].
-export_type([field/0, sensor/0, body/0]).

%% The three kinds of thing that exist. Not a menu of senses: a list of what
%% there is to measure.
-define(FIELDS, [plants, creatures, scent]).

%% How wide a founding body may be. A STARTING DISTRIBUTION, NOT A LIMIT:
%% mutation adds and removes without reference to either number, and rent is what
%% actually bounds a body. Founders are spread for the same reason they always
%% have been, so that selection has something to sort on the first tick.
-define(FOUNDER_MAX_SENSORS, 3).
-define(FOUNDER_MAX_RANGE, 2).

-spec fields() -> [field()].
fields() -> ?FIELDS.

-spec sensor_count(body()) -> non_neg_integer().
sensor_count(Body) -> length(Body).

%% @doc What a body costs to run, per tick, on top of base metabolism.
%%
%% CHARGED WHETHER USED OR NOT, which is the only force in this world that can
%% remove a sensor. Without it every lineage accumulates every measurement, the
%% fully equipped generalist is never at a disadvantage, and nothing can ever
%% specialise in anything.
-spec upkeep(body(), map()) -> non_neg_integer().
upkeep(Body, Econ) ->
    Rent = maps:get(sensor_rent, Econ),
    lists:sum([Rent * (Range + 1) || {_Field, Range} <- Body]).

%% @doc A founding body: a random number of random sensors.
-spec founder(map(), rand:state()) -> {body(), rand:state()}.
founder(Econ, Rng0) ->
    {N, Rng1} = rand:uniform_s(?FOUNDER_MAX_SENSORS + 1, Rng0),
    draw_sensors(N - 1, Econ, [], Rng1).

draw_sensors(0, _Econ, Acc, Rng) -> {lists:sort(Acc), Rng};
draw_sensors(N, Econ, Acc, Rng0) ->
    {Sensor, Rng1} = draw_sensor(?FOUNDER_MAX_RANGE, Rng0),
    draw_sensors(N - 1, Econ, [Sensor | Acc], Rng1).

draw_sensor(MaxRange, Rng0) ->
    {F, Rng1} = rand:uniform_s(length(?FIELDS), Rng0),
    {R, Rng2} = rand:uniform_s(MaxRange + 1, Rng1),
    {{lists:nth(F, ?FIELDS), R - 1}, Rng2}.

%% @doc A child's body, and what structurally changed so a brain can follow.
%%
%% THE CHANGE IS REPORTED RATHER THAN INFERRED. A brain carries one weight per
%% sensor, so a body that gains or loses one leaves the brain a column out of
%% step, and every weight after the change point would silently start reading a
%% different measurement. Returning the position makes the two mutate together.
%%
%% ONE CHANGE AT A TIME, and the three kinds are equally likely: grow a sensor,
%% lose one, or alter the reach of one. Nothing here pushes bodies to become more
%% elaborate on their own. A mutation that only ever added would produce steadily
%% fatter creatures and let us call the drift adaptation.
-spec inherit(body(), map(), rand:state()) ->
          {body(), none | {added, pos_integer()} | {dropped, pos_integer()},
           rand:state()}.
inherit(Body, Econ, Rng0) ->
    {Roll, Rng1} = rand:uniform_s(max(1, maps:get(body_mutation, Econ)), Rng0),
    mutate(Roll, Body, Econ, Rng1).

mutate(1, Body, Econ, Rng0) ->
    {Kind, Rng1} = rand:uniform_s(3, Rng0),
    apply_change(Kind, Body, Econ, Rng1);
mutate(_NoMutation, Body, _Econ, Rng) ->
    {Body, none, Rng}.

%% Grow one. Refused at the cap, which is a safety valve against a runaway body
%% rather than a model parameter: rent is what should bound a body, and this only
%% stops a mistuned economy allocating until the run stops being measurable.
apply_change(1, Body, Econ, Rng0) ->
    grow(length(Body) < maps:get(max_sensors, Econ), Body, Econ, Rng0);
apply_change(2, [], _Econ, Rng) ->
    {[], none, Rng};
apply_change(2, Body, _Econ, Rng0) ->
    {N, Rng1} = rand:uniform_s(length(Body), Rng0),
    {drop_at(N, Body), {dropped, N}, Rng1};
apply_change(3, [], _Econ, Rng) ->
    {[], none, Rng};
apply_change(3, Body, Econ, Rng0) ->
    {N, Rng1} = rand:uniform_s(length(Body), Rng0),
    {Step, Rng2} = rand:uniform_s(3, Rng1),
    {reach(N, Step - 2, Body, Econ), none, Rng2}.

grow(false, Body, _Econ, Rng) ->
    {Body, none, Rng};
grow(true, Body, _Econ, Rng0) ->
    {Sensor, Rng1} = draw_sensor(?FOUNDER_MAX_RANGE, Rng0),
    {Body ++ [Sensor], {added, length(Body) + 1}, Rng1}.

drop_at(N, Body) ->
    {Before, [_Gone | After]} = lists:split(N - 1, Body),
    Before ++ After.

%% Reach moves by one step either way, never below nothing and never past the
%% cap. Bounded above for the same reason bodies are: an unbounded reach makes a
%% tick cost proportional to the whole disc.
reach(N, Step, Body, Econ) ->
    {Before, [{Field, Range} | After]} = lists:split(N - 1, Body),
    Moved = min(maps:get(max_sensor_range, Econ), max(0, Range + Step)),
    Before ++ [{Field, Moved} | After].

%% @doc Scale a raw field total down to something a weight can be read against.
%%
%% Energies here run to hundreds and a brain weight runs to single digits, so
%% without this the weights would all have to be near zero and a mutation of one
%% would swamp the signal. Clamped as well as divided, because a creature facing
%% four hundred of something and one facing four thousand are in the same
%% situation and should not need different weights to say so.
-spec scale(integer()) -> non_neg_integer().
scale(Total) -> max(0, min(15, Total div 20)).

%% @doc What a population is built from: how many carry each field, and the
%% total reach devoted to it.
%%
%% A CENSUS AND NOT A VERDICT. It says what survived, not what was useful, and
%% the two are only the same thing after enough generations that drift has been
%% outvoted.
-spec census([body()]) -> #{field() => #{carriers := non_neg_integer(),
                                         reach := non_neg_integer()}}.
census(Bodies) ->
    Sensors = lists:append(Bodies),
    maps:from_list([{F, tally(F, Bodies, Sensors)} || F <- ?FIELDS]).

tally(Field, Bodies, Sensors) ->
    #{carriers => length([B || B <- Bodies, lists:keymember(Field, 1, B)]),
      reach => lists:sum([R || {F, R} <- Sensors, F =:= Field])}.
