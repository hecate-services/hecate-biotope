%% @doc What a creature is built from, and therefore what it can know and do.
%% PURE. No processes, no state, no clock.
%%
%% AN ORGAN GRANTS A CAPABILITY AND CHARGES RENT FOR IT. That second half is the
%% entire reason dietary roles can ever appear. If senses were free, every
%% lineage would accumulate every organ, every creature would be a fully
%% equipped omnivore, and the population would be uniform however long it ran.
%% The upkeep is charged every tick whether the organ is used or not, so an eye
%% that is not earning its keep is selected against rather than merely ignored.
%%
%% THREE ORGANS, EACH WITH A JOB:
%%
%%   eye    sees plants, and makes grazing DIRECTED rather than a random step
%%   nose   smells other creatures, both how many and how fat the fattest is,
%%          and makes hunting pick a target rather than lash out
%%   gut    reports the creature's own energy back to its brain
%%
%% The eye and the nose gate an ACTION as well as supplying a sense, and that
%% matters: an organ that only fed the brain a number could be dropped with no
%% loss but the information, and the cheapest body would always win. A blind
%% creature can still choose to graze, it simply wanders into food or does not.
%%
%% THE GUT IS PROPRIOCEPTION AND IT IS THE SUBTLE ONE. Without it a brain cannot
%% condition on its own hunger, so it cannot express "graze while comfortable,
%% take the risk when desperate". That sentence is the simplest strategy in this
%% world that is not a fixed role, and it is unavailable to a creature that
%% cannot feel its own stomach.
%%
%% A MISSING ORGAN READS AS ZERO rather than as a shorter input vector. Fixed
%% width means the brain never has to be resized when a body changes, which
%% removes the whole question of how to inherit a brain from a parent shaped
%% differently. Zero is also the honest value: an eyeless creature perceives no
%% plants, which is precisely what it should tell its brain.
-module(body).

-export([organs/0, founder/2, inherit/3, upkeep/2, has/2]).
-export([senses/2, sense_width/0, prevalence/1]).

-type organ() :: eye | nose | gut.
-type body() :: [organ()].
-export_type([organ/0, body/0]).

%% Sorted, because a body is compared and fingerprinted and two spellings of the
%% same creature would be two creatures.
-define(ORGANS, [eye, gut, nose]).

%% @doc Every organ that can exist. The order here is the canonical order.
-spec organs() -> [organ()].
organs() -> ?ORGANS.

%% @doc How many numbers a brain reads. Fixed, and independent of any body.
-spec sense_width() -> pos_integer().
sense_width() -> 4.

%% @doc Whether this body has that organ.
-spec has(organ(), body()) -> boolean().
has(Organ, Body) -> lists:member(Organ, Body).

%% @doc What a body costs to run, per tick, on top of base metabolism.
-spec upkeep(body(), map()) -> non_neg_integer().
upkeep(Body, Econ) -> length(Body) * maps:get(organ_upkeep, Econ).

%% @doc A founding body: each organ present on a coin flip.
%%
%% NOT EVERY ORGAN, AND NOT NONE. Founders that all share one body plan hand
%% selection nothing to work with until mutation slowly supplies variation, and
%% the first few hundred ticks of every run are then spent watching a monoculture
%% drift. Starting mixed is the same argument that spread the founding breeding
%% thresholds, applied to morphology.
-spec founder(map(), rand:state()) -> {body(), rand:state()}.
founder(_Econ, Rng0) ->
    {Kept, Rng1} =
        lists:foldl(fun(Organ, {Acc, R0}) ->
                            {Coin, R1} = rand:uniform_s(2, R0),
                            {keep(Coin, Organ, Acc), R1}
                    end,
                    {[], Rng0}, ?ORGANS),
    {lists:sort(Kept), Rng1}.

keep(1, Organ, Acc) -> [Organ | Acc];
keep(2, _Organ, Acc) -> Acc.

%% @doc A child's body: its parent's, occasionally one organ different.
%%
%% ONE ORGAN AT A TIME, AND A FLIP RATHER THAN AN ADD. Gaining and losing share
%% a single probability, so morphology has no built-in direction: nothing here
%% pushes bodies to grow more complex, and if they do grow it is because the
%% upkeep was worth paying. A mutation rate that only added organs would produce
%% ever fatter creatures and call it evolution.
-spec inherit(body(), map(), rand:state()) -> {body(), rand:state()}.
inherit(Body, Econ, Rng0) ->
    Rate = maps:get(body_mutation, Econ),
    {Roll, Rng1} = rand:uniform_s(max(1, Rate), Rng0),
    mutate(Roll, Body, Rng1).

mutate(1, Body, Rng0) ->
    {N, Rng1} = rand:uniform_s(length(?ORGANS), Rng0),
    Organ = lists:nth(N, ?ORGANS),
    {flip(has(Organ, Body), Organ, Body), Rng1};
mutate(_NoMutation, Body, Rng) ->
    {Body, Rng}.

flip(true, Organ, Body) -> lists:sort(Body -- [Organ]);
flip(false, Organ, Body) -> lists:sort([Organ | Body]).

%% @doc What this body perceives of a neighbourhood, as a fixed-width vector.
%%
%% The caller measures the world; this decides how much of that measurement the
%% creature is equipped to receive. Order is fixed and is the brain's input
%% order: plants, creatures, fattest neighbour, own energy.
%%
%% VALUES ARE SMALL INTEGERS, scaled and clamped, so that brain weights can stay
%% in a range a human can read and a mutation of one is a meaningful nudge rather
%% than a rounding error. Energies are divided down because a creature carrying
%% four hundred and one carrying four hundred and one are the same situation.
-spec senses(body(), map()) -> [non_neg_integer()].
senses(Body, Raw) ->
    #{plants_near := Plants, creatures_near := Creatures,
      fattest_near := Fattest, own_energy := Own} = Raw,
    [gated(has(eye, Body), Plants),
     gated(has(nose, Body), Creatures),
     gated(has(nose, Body), scale(Fattest)),
     gated(has(gut, Body), scale(Own))].

gated(true, Value) -> clamp(Value);
gated(false, _Value) -> 0.

scale(Energy) -> max(0, Energy) div 20.

clamp(V) -> max(0, min(15, V)).

%% @doc How common each organ is, over a list of bodies.
%%
%% THE ANSWER TO "DOES THIS ORGAN PAY". An organ whose prevalence falls is one
%% whose upkeep exceeds what it earns in this world, and that is a finding about
%% the world rather than about the organ. Reported as plain counts because a
%% percentage of a population that is changing size hides the population change.
-spec prevalence([body()]) -> #{organ() => non_neg_integer()}.
prevalence(Bodies) ->
    maps:from_list([{Organ, length([B || B <- Bodies, has(Organ, B)])}
                    || Organ <- ?ORGANS]).
