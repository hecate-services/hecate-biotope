%% @doc What a creature is built from. PURE.
%%
%% A BODY IS A LIST OF SENSORS AND A SENSOR IS `{Field, Range}'. Nothing is
%% named. There is no eye, no nose, no gut: those were biological conclusions
%% written into the physics, and a world whose rules contain "eye" cannot
%% discover that seeing was worth doing.
%%
%% WHICH FIELDS EXIST IS PHYSICS. There is energy in the ground, energy in other
%% creatures, the marks creatures leave behind, and the creature's own state.
%% Those are the four things there are to measure. WHICH ONE A LINEAGE MEASURES
%% IS BIOLOGY, and therefore not ours to write.
%%
%% READINGS ARE IN NATURAL UNITS, one per field, and world 1 got this badly
%% wrong. It divided everything by twenty, so a plant read 2, a full-strength
%% scent mark read 1, and two well-fed creatures saturated the ceiling: one
%% resolution for quantities spanning thirty to nine hundred. Scent was quantised
%% to a single bit, which is very likely why scent sensors went extinct in every
%% seed. Not because trails are useless. Because the instrument could barely
%% register them.
%%
%% So each field is read against its own scale, and energy against the same scale
%% wherever it is found, since energy is the only currency here and the exchange
%% rate already exists:
%%
%%   ground     a reading of 3 is three full cells' worth in reach
%%   creatures  a reading of 3 is creature flesh worth three full cells
%%   self       a reading of 3 is I am worth three full cells
%%   scent      a reading of 3 is as much trace as three fresh marks
%%
%% `self' IS THE ONE WORLD 1 DID NOT HAVE, and its absence was fatal to a whole
%% class of strategy. The central rule is that the stronger consumes the weaker,
%% so whether you are currently the eater or the eaten is the most
%% decision-relevant fact there is, and no creature could perceive it. Every
%% strategy of the form BEHAVE DIFFERENTLY WHEN WEAK was unreachable.
%%
%% It reads the same for every candidate cell, which is exactly why it is useless
%% on its own: a constant added to all seven options cancels in the comparison.
%% It only becomes worth anything through a hidden node that combines it with
%% something that does vary. Proprioception and nonlinearity are worth nothing
%% apart and something together, which is why world 2 has both or neither.
-module(body).

-export([founder/2, inherit/3, upkeep/2, fields/0, unit/2, reading/3]).
-export([census/1, sensor_count/1, reading_ceiling/0, spatial/1]).

-type field() :: creatures | ground | scent | self.
-type sensor() :: {field(), non_neg_integer()}.
-type body() :: [sensor()].
-export_type([field/0, sensor/0, body/0]).

-define(FIELDS, [creatures, ground, scent, self]).

%% How large a reading may be. Generous, because in natural units a wide sensor
%% over full ground legitimately reaches sixty-odd and clipping that would hide
%% exactly the gradient a wide sensor exists to find.
-define(READING_CEILING, 63).

%% A starting distribution, not a limit: mutation adds and removes without
%% reference to either, and rent is what actually bounds a body.
-define(FOUNDER_MAX_SENSORS, 3).
-define(FOUNDER_MAX_RANGE, 2).

-spec fields() -> [field()].
fields() -> ?FIELDS.

-spec reading_ceiling() -> pos_integer().
reading_ceiling() -> ?READING_CEILING.

-spec sensor_count(body()) -> non_neg_integer().
sensor_count(Body) -> length(Body).

%% @doc Whether a field is something measured over CELLS, or about the creature
%% itself. The caller has to gather the first kind and simply knows the second.
-spec spatial(field()) -> boolean().
spatial(self) -> false;
spatial(_Field) -> true.

%% @doc The natural unit a field is read in.
%%
%% Every energy quantity shares one unit because they are the same substance and
%% freely exchanged: a creature carrying four hundred is worth exactly as much as
%% a full cell holding four hundred, and a brain should not need different weights
%% to say so.
-spec unit(field(), map()) -> pos_integer().
unit(scent, Econ) -> maps:get(scent_per_tick, Econ);
unit(_Energy, Econ) -> maps:get(ground_ceiling, Econ).

%% @doc Scale a raw total into its natural unit, floored and capped.
%%
%% Floored because a cell can hold a creature about to be reaped and a negative
%% reading would flip the meaning of every weight applied to it.
-spec reading(field(), integer(), map()) -> non_neg_integer().
reading(Field, Raw, Econ) ->
    max(0, min(?READING_CEILING, Raw div unit(Field, Econ))).

%% @doc What a body costs to run, per tick, on top of base metabolism.
%%
%% CHARGED WHETHER USED OR NOT, which is the only force in this world that can
%% remove a sensor. Without it every lineage accumulates every measurement, the
%% fully equipped generalist is never at a disadvantage, and nothing can ever
%% specialise in anything.
%%
%% Rising with reach because reach costs, which is physical. Whether it should
%% rise with the radius or with the AREA covered is settled by nothing in this
%% world and is named in PREREGISTRATION.md rather than defended here.
-spec upkeep(body(), map()) -> non_neg_integer().
upkeep(Body, Econ) ->
    Rent = maps:get(sensor_rent, Econ),
    lists:sum([Rent * (Range + 1) || {_Field, Range} <- Body]).

%% @doc A founding body: a random number of random sensors, possibly none.
%%
%% A creature that measures nothing is a legitimate creature. It pays no rent,
%% values every cell alike and wanders, and that is the null forager everything
%% else has to beat. Excluding it from the draw would quietly assume perception
%% is worth having, which is one of the things being asked.
-spec founder(map(), rand:state()) -> {body(), rand:state()}.
founder(_Econ, Rng0) ->
    {N, Rng1} = rand:uniform_s(?FOUNDER_MAX_SENSORS + 1, Rng0),
    draw_sensors(N - 1, [], Rng1).

draw_sensors(0, Acc, Rng) -> {lists:sort(Acc), Rng};
draw_sensors(N, Acc, Rng0) ->
    {Sensor, Rng1} = draw_sensor(Rng0),
    draw_sensors(N - 1, [Sensor | Acc], Rng1).

draw_sensor(Rng0) ->
    {F, Rng1} = rand:uniform_s(length(?FIELDS), Rng0),
    {R, Rng2} = rand:uniform_s(?FOUNDER_MAX_RANGE + 1, Rng1),
    {{lists:nth(F, ?FIELDS), R - 1}, Rng2}.

%% @doc A child's body, and what structurally changed so a brain can follow.
%%
%% THE CHANGE IS REPORTED RATHER THAN INFERRED, and in world 2 that matters more
%% than it did. A brain now carries one weight per input in EVERY hidden node and
%% EVERY output, so a body that gains or loses a sensor leaves several vectors a
%% column out of step at once. Nothing crashes; every weight after the change
%% point simply starts reading a different measurement, and the creature behaves
%% like a garbled version of its parent for reasons no test would name.
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

%% Grow, prune, or re-reach, equally likely, so nothing pushes bodies to become
%% more elaborate on their own. A mutation that only ever added would produce
%% steadily fatter creatures and let us call the drift adaptation.
apply_change(1, Body, Econ, Rng0) ->
    grow(length(Body) < maps:get(max_sensors, Econ), Body, Rng0);
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

%% Appended, so a gained sensor takes the last sensor position and every
%% dependent vector inserts its new weight there rather than at the end, where
%% the `here' input lives.
grow(false, Body, Rng) ->
    {Body, none, Rng};
grow(true, Body, Rng0) ->
    {Sensor, Rng1} = draw_sensor(Rng0),
    {Body ++ [Sensor], {added, length(Body) + 1}, Rng1}.

drop_at(N, Body) ->
    {Before, [_Gone | After]} = lists:split(N - 1, Body),
    Before ++ After.

%% Reach moves one step either way, never below nothing and never past the cap.
%% Bounded above because an unbounded reach makes one tick cost as much as the
%% whole disc, which is a safety valve rather than a model parameter.
reach(N, Step, Body, Econ) ->
    {Before, [{Field, Range} | After]} = lists:split(N - 1, Body),
    Moved = min(maps:get(max_sensor_range, Econ), max(0, Range + Step)),
    Before ++ [{Field, Moved} | After].

%% @doc What a population is built from: how many carry each field, how much
%% reach is devoted to it, and how hard it is acted on.
%%
%% A CENSUS AND NOT A VERDICT. It says what survived, not what was useful, and
%% the two are the same thing only after enough generations that drift has been
%% outvoted.
%%
%% ATTENTION IS THE PART THAT ANSWERS WHETHER AN ORGAN HAS DEVELOPED, because
%% carrying a sensor and using one are different things. A creature can pay rent
%% every tick for a measurement nothing in its brain weights, so the organ exists,
%% is charged for, and changes nothing it does. Carriers alone overstate
%% perception and a population can look equipped while being effectively blind.
-spec census([{body(), [integer()]}]) ->
          #{field() => #{carriers := non_neg_integer(),
                         reach := non_neg_integer(),
                         attention := non_neg_integer()}}.
census(Creatures) ->
    Attributed = lists:append([attribute(B, A) || {B, A} <- Creatures]),
    maps:from_list([{F, tally(F, Creatures, Attributed)} || F <- ?FIELDS]).

%% Each sensor beside the total attention its input receives, which the brain
%% supplies because only the brain knows how many vectors read that column.
attribute(Body, Attention) ->
    lists:zip(Body, lists:sublist(Attention, length(Body))).

tally(Field, Creatures, Attributed) ->
    Mine = [{R, A} || {{F, R}, A} <- Attributed, F =:= Field],
    #{carriers => length([B || {B, _A} <- Creatures,
                               lists:keymember(Field, 1, B)]),
      reach => lists:sum([R || {R, _A} <- Mine]),
      attention => attention(Mine)}.

attention([]) -> 0;
attention(Mine) -> lists:sum([A || {_R, A} <- Mine]) div length(Mine).
