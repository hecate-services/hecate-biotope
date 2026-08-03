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
      food_from_creatures_pct => get(from_creatures_pct, Snap),
      %% What happened to them.
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
-spec lines(map()) -> iodata().
lines(Brief) ->
    [[atom_to_list(K), ": ", integer_to_list(V), "\n"]
     || {K, V} <- lists:sort(maps:to_list(Brief)), is_integer(V)].

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
