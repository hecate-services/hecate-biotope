%% @doc What a creature is built from, asserted.
%%
%% The claim these defend: a sensor is `{Field, Range}' and nothing more. There
%% is no eye and no nose, because those were biological conclusions written into
%% the physics, and a world whose rules contain "eye" cannot discover that seeing
%% was worth doing.
%%
%% NOTHING HERE ASSERTS THAT ANY PARTICULAR SENSOR IS GOOD. What is asserted is
%% that a body costs what the rules say and mutates how the rules say. Whether
%% measuring the ground beats measuring other creatures is the question the world
%% exists to answer. See PREREGISTRATION.md.
-module(body_tests).

-include_lib("eunit/include/eunit.hrl").

econ() -> world:defaults().
rng() -> rand:seed_s(exsss, {4, 5, 6}).
with(Overrides) -> maps:merge(econ(), Overrides).
always() -> with(#{body_mutation => 1}).

%%==============================================================================
%% What there is to measure
%%==============================================================================

%% WHICH FIELDS EXIST IS PHYSICS: energy in the ground, energy in other
%% creatures, the marks creatures leave, and the creature's own state. Those are
%% the four things there are to measure. Which one a lineage measures is biology.
%%
%% `plants' is gone, because a plant was never a kind of thing. It is a way of
%% living, and a creature that stays put taking what the ground offers IS one.
the_fields_are_the_kinds_of_thing_that_exist_test() ->
    ?assertEqual([creatures, ground, scent, self], lists:sort(body:fields())).

%% `self' is the one world 1 did not have, and its absence was fatal to a whole
%% class of strategy: the central rule is that the stronger consumes the weaker,
%% so whether you are the eater or the eaten was unknowable.
%%
%% It is not measured over cells, which is why the world has to know the
%% difference: everything else is gathered from the ground around a candidate,
%% and this is simply looked up.
only_self_is_not_measured_over_cells_test() ->
    ?assertEqual(false, body:spatial(self)),
    ?assert(lists:all(fun body:spatial/1, [creatures, ground, scent])).

%%==============================================================================
%% Natural units
%%==============================================================================

%% EVERY ENERGY QUANTITY SHARES ONE UNIT, because they are the same substance and
%% freely exchanged: a creature carrying four hundred is worth exactly as much as
%% a full cell holding four hundred, and a brain should not need different weights
%% to say so. Scent is not energy and has its own.
energy_shares_one_unit_and_scent_has_its_own_test() ->
    E = with(#{ground_ceiling => 400, scent_per_tick => 10}),
    ?assertEqual(400, body:unit(ground, E)),
    ?assertEqual(400, body:unit(creatures, E)),
    ?assertEqual(400, body:unit(self, E)),
    ?assertEqual(10, body:unit(scent, E)).

%% WORLD 1 GOT THIS BADLY WRONG and it is very likely why scent sensors went
%% extinct in every seed. One divisor of twenty for quantities spanning thirty to
%% nine hundred: a plant read 2, a full-strength mark read 1, and two well-fed
%% creatures saturated the ceiling. Not because trails are useless. Because the
%% instrument could barely register them.
a_reading_is_in_its_own_unit_test() ->
    E = with(#{ground_ceiling => 400, scent_per_tick => 10}),
    ?assertEqual(3, body:reading(ground, 1200, E)),
    ?assertEqual(3, body:reading(creatures, 1200, E)),
    ?assertEqual(3, body:reading(scent, 30, E)).

%% Capped generously, because in natural units a wide sensor over full ground
%% legitimately reaches sixty-odd, and clipping that would hide exactly the
%% gradient a wide sensor exists to find.
a_reading_is_capped_and_floored_test() ->
    E = with(#{ground_ceiling => 400}),
    ?assertEqual(body:reading_ceiling(), body:reading(ground, 10000000, E)),
    ?assert(body:reading_ceiling() >= 60),
    %% A cell can hold a creature about to be reaped, and a negative reading
    %% would flip the meaning of every weight applied to it.
    ?assertEqual(0, body:reading(creatures, -5000, E)).

%%==============================================================================
%% Paying for it
%%==============================================================================

%% THE ONLY FORCE THAT CAN REMOVE A SENSOR. If measuring were free every lineage
%% would accumulate every measurement and the fully equipped generalist would
%% never be at a disadvantage.
rent_is_charged_per_sensor_and_rises_with_reach_test() ->
    E = with(#{sensor_rent => 2}),
    ?assertEqual(0, body:upkeep([], E)),
    ?assertEqual(2, body:upkeep([{ground, 0}], E)),
    ?assertEqual(6, body:upkeep([{ground, 2}], E)),
    ?assertEqual(4, body:upkeep([{ground, 0}, {scent, 0}], E)).

%% Two of the same field at different reaches are two sensors and are billed
%% twice. A body is a list, not a set: nothing in the physics says a creature may
%% only measure a thing once.
duplicate_fields_are_separate_sensors_test() ->
    E = with(#{sensor_rent => 1}),
    ?assertEqual(4, body:upkeep([{ground, 0}, {ground, 2}], E)),
    ?assertEqual(2, body:sensor_count([{ground, 0}, {ground, 2}])).

%%==============================================================================
%% Founding
%%==============================================================================

founding_bodies_vary_test() ->
    {Bodies, _} = lists:mapfoldl(fun(_I, R) -> body:founder(econ(), R) end,
                                 rng(), lists:seq(1, 60)),
    ?assert(length(lists:usort(Bodies)) > 3).

%% A creature that measures nothing is a legitimate creature: it pays no rent,
%% values every cell alike and wanders, and that is the null forager everything
%% else has to beat. Excluding it would quietly assume perception is worth having,
%% which is one of the things being asked.
some_founders_perceive_nothing_test() ->
    {Bodies, _} = lists:mapfoldl(fun(_I, R) -> body:founder(econ(), R) end,
                                 rng(), lists:seq(1, 60)),
    ?assert(lists:member([], Bodies)).

founding_sensors_are_well_formed_test() ->
    {Bodies, _} = lists:mapfoldl(fun(_I, R) -> body:founder(econ(), R) end,
                                 rng(), lists:seq(1, 60)),
    ?assert(lists:all(fun({F, R}) ->
                              lists:member(F, body:fields()) andalso R >= 0
                      end, lists:append(Bodies))).

%%==============================================================================
%% Inheriting
%%==============================================================================

%% THE STRUCTURAL CHANGE IS REPORTED RATHER THAN INFERRED, and in world 2 that
%% matters more than it did. A brain now carries one weight per input in EVERY
%% hidden node and EVERY output, so a gained sensor leaves several vectors a
%% column out of step at once, and nothing crashes when it does.
a_change_reports_where_it_happened_test() ->
    {Results, _} = lists:mapfoldl(
                     fun(_I, R) ->
                             {B, C, R1} = body:inherit([{ground, 1}], always(), R),
                             {{B, C}, R1}
                     end, rng(), lists:seq(1, 60)),
    ?assert(lists:all(fun({B, none}) -> length(B) =:= 1;
                         ({B, {added, P}}) -> length(B) =:= 2 andalso P =:= 2;
                         ({B, {dropped, P}}) -> B =:= [] andalso P =:= 1
                      end, Results)).

%% GAINING, LOSING AND RE-REACHING ARE EQUALLY LIKELY, so nothing pushes bodies
%% to become more elaborate on their own. A mutation that only ever added would
%% produce steadily fatter creatures and let us call the drift adaptation.
mutation_both_grows_and_prunes_test() ->
    {Kinds, _} = lists:mapfoldl(
                   fun(_I, R) ->
                           {_B, C, R1} = body:inherit([{scent, 1}], always(), R),
                           {C, R1}
                   end, rng(), lists:seq(1, 90)),
    ?assert(lists:any(fun({added, _}) -> true; (_) -> false end, Kinds)),
    ?assert(lists:any(fun({dropped, _}) -> true; (_) -> false end, Kinds)),
    ?assert(lists:member(none, Kinds)).

reach_stays_within_bounds_test() ->
    E = with(#{body_mutation => 1, max_sensor_range => 2}),
    Grow = fun(_I, {B, R0}) ->
                   {B1, _C, R1} = body:inherit(B, E, R0),
                   {B1, R1}
           end,
    {Body, _} = lists:foldl(Grow, {[{ground, 2}], rng()}, lists:seq(1, 200)),
    ?assert(lists:all(fun({_F, R}) -> R >= 0 andalso R =< 2 end, Body)).

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
                             {B, C, R1} = body:inherit([{ground, 1}], E, R),
                             {{B, C}, R1}
                     end, rng(), lists:seq(1, 40)),
    ?assert(lists:all(fun({B, C}) ->
                              B =:= [{ground, 1}] andalso C =:= none
                      end, Results)).

%%==============================================================================
%% Reading a population
%%==============================================================================

%% A CENSUS AND NOT A VERDICT. It says what survived, not what was useful, and
%% those are the same thing only after enough generations that drift is outvoted.
%%
%% ATTENTION IS THE PART THAT ANSWERS WHETHER AN ORGAN HAS DEVELOPED, because
%% carrying a sensor and using one are different things: a creature can pay rent
%% every tick for a measurement nothing in its brain weights.
the_census_counts_carriers_reach_and_attention_test() ->
    Creatures = [{[{ground, 0}], [4]},
                 {[{ground, 2}, {scent, 1}], [2, 6]},
                 {[], []},
                 {[{ground, 1}], [0]}],
    Census = body:census(Creatures),
    ?assertEqual(#{carriers => 3, reach => 3, attention => 2},
                 maps:get(ground, Census)),
    ?assertEqual(#{carriers => 1, reach => 1, attention => 6},
                 maps:get(scent, Census)),
    ?assertEqual(#{carriers => 0, reach => 0, attention => 0},
                 maps:get(creatures, Census)).

%% THE DIFFERENCE BETWEEN AN ORGAN APPEARING AND AN ORGAN BEING ADOPTED. Two
%% creatures carry the sensor, are billed for it every tick, and nothing in
%% either brain acts on what it says.
a_carried_sensor_nobody_acts_on_has_no_attention_test() ->
    Census = body:census([{[{creatures, 2}], [0]}, {[{creatures, 1}], [0]}]),
    ?assertEqual(2, maps:get(carriers, maps:get(creatures, Census))),
    ?assertEqual(0, maps:get(attention, maps:get(creatures, Census))).

%% Zeroes rather than missing keys, so a reader plotting a field over time gets a
%% line at zero instead of a gap it has to interpret.
the_census_of_nothing_is_zeroes_test() ->
    Census = body:census([]),
    ?assertEqual(lists:sort(body:fields()), lists:sort(maps:keys(Census))),
    ?assert(lists:all(fun(F) -> maps:get(carriers, F) =:= 0 end,
                      maps:values(Census))).
