%% @doc EVERYTHING A NARRATOR IS ALLOWED TO KNOW. PURE.
%%
%% ==========================================================================
%% IT SEES NUMBERS, SO IT CAN ONLY SAY WHAT THE NUMBERS SAY
%% ==========================================================================
%%
%% A brief is integers and a handful of short phrases this module wrote itself.
%% No prose from anywhere else, nothing an island's owner chose, and nothing off
%% the mesh. That is not tidiness: **a narrator can only make things up about
%% things it was told about**, and the surest way to stop it explaining WHY
%% something happened is to hand it no material to build a why out of.
%%
%% The same brief is attached to every remark as `derived_from', so any sentence
%% can be checked against exactly what its author saw. A reader never has to take
%% a narrator's word for what the world was doing.
%%
%% ⚠ NO RATES, NO DELTAS, NO TRENDS. It gets this moment and the moment it last
%% spoke about, and nothing in between. A trend is halfway to a cause, and this
%% is the file that decides what can be said at all.
-module(world_brief).

-export([of_world/1, lines/1, changed_enough/2]).

%% How much has to move before the narrator has anything worth saying. All of
%% these are about the WORLD being different, never about the narrator being due
%% a turn: a world that sits still is a world with nothing to report, and saying
%% so every few minutes would be filler.
-define(POPULATION_SHIFT_PCT, 40).
-define(KINDS_SHIFT, 4).
-define(NEW_WAYS_FOUND, 6).

%% @doc The brief, as a flat map of integers and short phrases.
%% ⚠ ONE FIELD HERE IS WORDS AND EVERYTHING ELSE IS INTEGERS, and it is the only
%% exception this module allows. `commonest_way' is adjectives derived
%% mechanically from measured bins by `behaviour:portrait/3': reproducible,
%% testable, and not a sentence anybody wrote. It is here because a narrator that
%% can only quote counts writes "the commonest kind holds 21%", and one that can
%% say "most of them graze, never move and have not yet bred" is describing the
%% same island to somebody who might care.
%%
%% It is still not a licence to invent. A NOUN would assert a kind of thing and
%% there are none; the prompt says so and this map contains no nouns to borrow.
-spec of_world(map()) -> map().
of_world(Snap) ->
    #{%% FROM THE RULESET AND NOT FROM THE SNAPSHOT, which has never carried it:
      %% `world_facts' adds the number when it builds a fact, so reading it here
      %% quietly reported every island as world 0.
      world => maps:get(number, world:ruleset()),
      tick => get(tick, Snap),
      creatures => get(population, Snap),
      %% What they ARE.
      kinds => get(kinds, Snap),
      commonest_kind_pct => get(kind_max_pct, Snap),
      sensors_each_x100 => get(sensor_mean, Snap),
      hidden_nodes_each_x100 => get(hidden_mean, Snap),
      founding_lines_left => get(lineages, Snap),
      generations_deep => get(depth, Snap),
      %% What they DO.
      ways_of_living_found => get(explored, Snap),
      ways_of_living_possible => get(behaviour_space, Snap),
      new_ways_last_1000_ticks => get(frontier, Snap),
      standing_still_pct => get(still_pct, Snap),
      mean_age_in_ticks => get(age_mean, Snap),
      food_from_creatures_pct => get(from_creatures_pct, Snap),
      %% What happened to them.
      commonest_way => maps:get(commonest_way, Snap, <<>>),
      commonest_way_pct => get(commonest_way_pct, Snap),
      born => get(born, Snap),
      starved => get(starved, Snap),
      eaten => get(consumed, Snap),
      died_of_old_age => get(aged_out, Snap),
      energy_in_the_ground => get(ground_total, Snap),
      energy_in_creatures => get(energy_total, Snap)}.

get(Key, Snap) -> maps:get(Key, Snap, 0).

%% @doc The brief as one line per number, which is what a model reads best.
%%
%% Written here rather than in the module that talks to a model, because what a
%% narrator may see is a decision about this project and not about an API.
%%
%% ⚠ THE HUNDREDTHS ARE SPELLED OUT HERE AND KEPT AS INTEGERS ON THE WIRE.
%%
%% This world's census reports means times a hundred, because everything on the
%% mesh is an integer. Handing a model `sensors_each_x100: 242` and expecting it
%% to divide is asking it to do arithmetic it is bad at, on the one kind of
%% number a reader is least able to sanity-check.
%%
%% Measured: a 7B model read that field and wrote "each creature has 16 hidden
%% nodes and 242 sensors", which is a hundred times the truth and was stated
%% flatly. **A hosted 70B got it right, so it looked like a question of model
%% quality and was in fact a question of how the number was presented.** The fact
%% still carries the integers; only what the model READS is scaled.
-spec lines(map()) -> iodata().
lines(Brief) ->
    [shown(atom_to_list(K), V) || {K, V} <- lists:sort(maps:to_list(Brief)),
                                  is_integer(V)]
        ++ words(maps:get(commonest_way, Brief, <<>>)).

words(<<>>) -> [];
words(Way) -> ["commonest_way: ", Way, "\n"].

shown(Name, Value) ->
    hundredths(lists:suffix("_x100", Name), Name, Value).

hundredths(false, Name, Value) ->
    [Name, ": ", integer_to_list(Value), "\n"];
hundredths(true, Name, Value) ->
    [lists:sublist(Name, length(Name) - 5), ": ",
     integer_to_list(Value div 100), ".", pad(Value rem 100), "\n"].

pad(N) when N < 10 -> ["0", integer_to_list(N)];
pad(N) -> integer_to_list(N).

%% @doc Has the world done anything since the last time we spoke about it?
%%
%% ⚠ THE TRIGGER IS THE COST CONTROL AND ALSO THE EDITOR. An island runs at two
%% ticks a second for ever; narrating on a timer would produce a paragraph a
%% minute about a world that had not moved, which costs money and teaches a
%% reader to stop reading. Speaking only when something changed means every
%% remark is ABOUT something.
%%
%% FOUR THINGS COUNT AS SOMETHING HAPPENING, and each is a thing a person
%% watching would actually notice:
%%
%%   the population collapsed or exploded
%%   the number of kinds of creature moved
%%   the world found several new ways to live
%%   the world stopped finding any, or started again
%%
%% The last is the one that matters most and is the reason for the whole archive:
%% `new_ways_last_1000_ticks' reaching zero is a world that has settled, and
%% leaving zero is a world that has started moving again. Neither is visible in
%% any other number here.
-spec changed_enough(map() | none, map()) -> boolean().
changed_enough(none, _Now) -> true;
changed_enough(Was, Now) ->
    extinct(Was, Now) orelse settled(Was, Now) orelse moved(Was, Now).

%% An island that has just died is always worth a sentence, and it is the single
%% most common thing that happens here.
extinct(#{creatures := Before}, #{creatures := 0}) when Before > 0 -> true;
extinct(_Was, _Now) -> false.

settled(#{new_ways_last_1000_ticks := A}, #{new_ways_last_1000_ticks := B}) ->
    (A > 0) =/= (B > 0).

moved(Was, Now) ->
    shifted(seen(creatures, Was), seen(creatures, Now)) orelse
        abs(seen(kinds, Was) - seen(kinds, Now)) >= ?KINDS_SHIFT orelse
        seen(ways_of_living_found, Now) - seen(ways_of_living_found, Was)
            >= ?NEW_WAYS_FOUND.

seen(Key, Map) -> maps:get(Key, Map, 0).

%% A proportional test, so a world of six creatures losing two is news and a
%% world of two hundred losing two is not.
shifted(0, 0) -> false;
shifted(Before, After) ->
    abs(After - Before) * 100 div max(1, Before) >= ?POPULATION_SHIFT_PCT.
