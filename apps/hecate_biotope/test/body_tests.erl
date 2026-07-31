%% @doc What a creature is built from, asserted.
%%
%% The claim these defend: a sensor is `{Field, Range}' and nothing more. There
%% is no eye and no nose, because those were biological conclusions written into
%% the physics, and a world whose rules contain "eye" cannot discover that seeing
%% was worth doing.
%%
%% NOTHING HERE ASSERTS THAT ANY PARTICULAR SENSOR IS GOOD. What is asserted is
%% that a body costs what the rules say it costs and mutates the way the rules say
%% it mutates. Whether measuring plants beats measuring creatures is the question
%% the world exists to answer. See PREREGISTRATION.md.
-module(body_tests).

-include_lib("eunit/include/eunit.hrl").

econ() -> world:defaults().

rng() -> rand:seed_s(exsss, {4, 5, 6}).

with(Overrides) -> maps:merge(econ(), Overrides).

always() -> with(#{body_mutation => 1}).

%%==============================================================================
%% What there is to measure
%%==============================================================================

%% WHICH FIELDS EXIST IS PHYSICS: plants, creatures, and the marks creatures
%% leave. Those are the three kinds of thing in this world, so those are the three
%% quantities that can be measured. Which one a lineage measures is biology.
the_fields_are_the_kinds_of_thing_that_exist_test() ->
    ?assertEqual([creatures, plants, scent], lists:sort(body:fields())).

%%==============================================================================
%% Paying for it
%%==============================================================================

%% THE ONLY FORCE THAT CAN REMOVE A SENSOR. If measuring were free every lineage
%% would accumulate every measurement and the fully equipped generalist would
%% never be at a disadvantage.
rent_is_charged_per_sensor_test() ->
    E = with(#{sensor_rent => 2}),
    ?assertEqual(0, body:upkeep([], E)),
    ?assertEqual(2, body:upkeep([{plants, 0}], E)),
    ?assertEqual(4, body:upkeep([{plants, 0}, {scent, 0}], E)).

%% REACH COSTS, and that much is physical. Whether it should cost with the radius
%% or with the area covered is not settled by anything in this world; the linear
%% form is a modelling choice named in PREREGISTRATION.md rather than defended
%% here.
rent_rises_with_reach_test() ->
    E = with(#{sensor_rent => 1}),
    ?assertEqual(1, body:upkeep([{plants, 0}], E)),
    ?assertEqual(2, body:upkeep([{plants, 1}], E)),
    ?assertEqual(5, body:upkeep([{plants, 4}], E)).

%% Two of the same field at different reaches are two sensors and are billed
%% twice. A body is a list, not a set: there is nothing in the physics that says
%% a creature may only measure a thing once.
duplicate_fields_are_separate_sensors_test() ->
    E = with(#{sensor_rent => 1}),
    ?assertEqual(4, body:upkeep([{plants, 0}, {plants, 2}], E)),
    ?assertEqual(2, body:sensor_count([{plants, 0}, {plants, 2}])).

%%==============================================================================
%% Reading
%%==============================================================================

%% Field totals run to hundreds and a brain weight runs to single digits, so
%% without scaling every weight would have to sit near zero and a mutation of one
%% would swamp the signal.
readings_are_scaled_and_clamped_test() ->
    ?assertEqual(0, body:scale(0)),
    ?assertEqual(2, body:scale(40)),
    ?assertEqual(15, body:scale(100000)).

%% A cell can hold a creature about to be reaped, and a negative reading would
%% flip the meaning of every weight applied to it.
a_negative_total_reads_as_nothing_test() ->
    ?assertEqual(0, body:scale(-500)).

%%==============================================================================
%% Founding
%%==============================================================================

%% Founders are spread for the same reason they always have been: a population
%% that starts as one shape hands selection nothing until mutation invents
%% variety, and the early ticks are spent watching a monoculture drift.
founding_bodies_vary_test() ->
    {Bodies, _} = lists:mapfoldl(fun(_I, R) -> body:founder(econ(), R) end,
                                 rng(), lists:seq(1, 60)),
    ?assert(length(lists:usort(Bodies)) > 3).

%% Including empty ones. A creature that measures nothing is a legitimate
%% creature: it pays no rent, values every cell alike, and wanders. That is the
%% null forager everything else has to beat, and excluding it from the founding
%% draw would quietly assume perception is worth having.
some_founders_perceive_nothing_test() ->
    {Bodies, _} = lists:mapfoldl(fun(_I, R) -> body:founder(econ(), R) end,
                                 rng(), lists:seq(1, 60)),
    ?assert(lists:member([], Bodies)).

founding_sensors_are_well_formed_test() ->
    {Bodies, _} = lists:mapfoldl(fun(_I, R) -> body:founder(econ(), R) end,
                                 rng(), lists:seq(1, 60)),
    Sensors = lists:append(Bodies),
    ?assert(lists:all(fun({F, R}) ->
                              lists:member(F, body:fields())
                                  andalso R >= 0
                      end, Sensors)).

%%==============================================================================
%% Inheriting
%%==============================================================================

%% THE STRUCTURAL CHANGE IS REPORTED RATHER THAN INFERRED. A brain carries one
%% weight per sensor, so a body that gains or loses one leaves the brain a column
%% out of step and every weight after the change point silently starts valuing a
%% different measurement. Nothing crashes, which is what makes it the worst bug
%% available here.
a_change_reports_where_it_happened_test() ->
    {Bodies, _} = lists:mapfoldl(
                    fun(_I, R) ->
                            {B, C, R1} = body:inherit([{plants, 1}], always(), R),
                            {{B, C}, R1}
                    end, rng(), lists:seq(1, 60)),
    ?assert(lists:all(fun({B, none}) -> length(B) =:= 1;
                         ({B, {added, P}}) -> length(B) =:= 2 andalso P =< 2;
                         ({B, {dropped, P}}) -> length(B) =:= 0 andalso P =:= 1
                      end, Bodies)).

%% GAINING, LOSING AND RE-REACHING ARE EQUALLY LIKELY, so nothing pushes bodies
%% to become more elaborate on their own. A mutation that only ever added would
%% produce steadily fatter creatures and let us call the drift adaptation.
mutation_both_grows_and_prunes_test() ->
    {Results, _} = lists:mapfoldl(
                     fun(_I, R) ->
                             {B, C, R1} = body:inherit([{scent, 1}], always(), R),
                             {{B, C}, R1}
                     end, rng(), lists:seq(1, 90)),
    Kinds = [C || {_B, C} <- Results],
    ?assert(lists:any(fun(K) -> element(1, {K, x}) =/= none end, Kinds)),
    ?assert(lists:member(none, Kinds)),
    ?assert(lists:any(fun({added, _}) -> true; (_) -> false end, Kinds)),
    ?assert(lists:any(fun({dropped, _}) -> true; (_) -> false end, Kinds)).

%% Reach moves by one step either way and never below nothing. A negative reach
%% is not a smaller sensor, it is a meaningless one.
reach_never_goes_below_nothing_test() ->
    {Bodies, _} = lists:mapfoldl(
                    fun(_I, R) ->
                            {B, _C, R1} = body:inherit([{plants, 0}], always(), R),
                            {B, R1}
                    end, rng(), lists:seq(1, 60)),
    Ranges = [Range || B <- Bodies, {_F, Range} <- B],
    ?assert(lists:all(fun(Range) -> Range >= 0 end, Ranges)).

%% Bounded above, because an unbounded reach makes one tick cost as much as the
%% whole disc. A SAFETY VALVE AND NOT A MODEL PARAMETER: rent is what should
%% bound a body.
reach_is_capped_test() ->
    E = with(#{body_mutation => 1, max_sensor_range => 2}),
    Grow = fun(_I, {B, R0}) ->
                   {B1, _C, R1} = body:inherit(B, E, R0),
                   {B1, R1}
           end,
    {Body, _} = lists:foldl(Grow, {[{plants, 2}], rng()}, lists:seq(1, 200)),
    ?assert(lists:all(fun({_F, Range}) -> Range =< 2 end, Body)).

sensor_count_is_capped_test() ->
    E = with(#{body_mutation => 1, max_sensors => 3}),
    Grow = fun(_I, {B, R0}) ->
                   {B1, _C, R1} = body:inherit(B, E, R0),
                   {B1, R1}
           end,
    {Body, _} = lists:foldl(Grow, {[], rng()}, lists:seq(1, 400)),
    ?assert(length(Body) =< 3).

a_rare_mutation_usually_clones_test() ->
    E = with(#{body_mutation => 1000000}),
    {Results, _} = lists:mapfoldl(
                     fun(_I, R) ->
                             {B, C, R1} = body:inherit([{plants, 1}], E, R),
                             {{B, C}, R1}
                     end, rng(), lists:seq(1, 40)),
    ?assert(lists:all(fun({B, C}) ->
                              B =:= [{plants, 1}] andalso C =:= none
                      end, Results)).

%%==============================================================================
%% Reading a population
%%==============================================================================

%% A CENSUS AND NOT A VERDICT. It says what survived, not what was useful, and
%% those are only the same thing after enough generations that drift has been
%% outvoted.
the_census_counts_carriers_and_reach_test() ->
    Bodies = [[{plants, 0}], [{plants, 2}, {scent, 1}], [], [{plants, 1}]],
    Census = body:census(Bodies),
    ?assertEqual(#{carriers => 3, reach => 3}, maps:get(plants, Census)),
    ?assertEqual(#{carriers => 1, reach => 1}, maps:get(scent, Census)),
    ?assertEqual(#{carriers => 0, reach => 0}, maps:get(creatures, Census)).

%% Zeroes rather than missing keys, so a reader plotting a field over time gets a
%% line at zero instead of a gap it has to interpret.
the_census_of_nothing_is_zeroes_test() ->
    Census = body:census([]),
    ?assertEqual(lists:sort(body:fields()), lists:sort(maps:keys(Census))),
    ?assert(lists:all(fun(F) -> maps:get(carriers, F) =:= 0 end,
                      maps:values(Census))).

%% A creature carrying the same field twice is ONE carrier with the reach of
%% both, or a population of hoarders would look like a population of many.
duplicate_fields_count_once_per_carrier_test() ->
    Census = body:census([[{plants, 1}, {plants, 3}]]),
    ?assertEqual(#{carriers => 1, reach => 4}, maps:get(plants, Census)).
