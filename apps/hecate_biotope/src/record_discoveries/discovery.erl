%% @doc What a world found, kept after the world has died. PURE.
%%
%% ==========================================================================
%% AN ISLAND FORGETS EVERYTHING, AND THAT IS THE PROBLEM
%% ==========================================================================
%%
%% A world lives in a `gen_server''s state. It computes about forty numbers a
%% second, publishes them, and throws away everything nobody wrote an instrument
%% for. When it dies, and most seeds die, its entire history goes with it: the
%% board is wiped, a new seed is drawn, and nothing anywhere records that the
%% previous world ever found a way to live that this one has not.
%%
%% **In an open-ended search the interesting thing is by definition the thing
%% nobody anticipated, and an instrument you did not write cannot measure it.**
%% Every finding this project has made came from someone noticing a number in a
%% table. A durable record is the only way a question invented next month can be
%% asked of a world that ran last night.
%%
%% ==========================================================================
%% WHAT IS WORTH KEEPING, AND WHAT IS EMPHATICALLY NOT
%% ==========================================================================
%%
%% NOT TICKS AND NOT BIRTHS. Births run about ten a tick and deaths not far
%% behind, which at two ticks a second is three million events a day per island.
%% That is a recording of the world rather than a record of what it found, and it
%% would cost more than it could ever be worth.
%%
%% DISCOVERIES, WHICH ARE BOUNDED BY CONSTRUCTION. There are 125 ways of living
%% and each can be found once. A world begins once and ends once. A whole run is
%% a few hundred events, and a node that has hosted forty worlds can be asked
%% what all forty found.
%%
%% ==========================================================================
%% THE WORLD IS NOT BEING EVENT-SOURCED
%% ==========================================================================
%%
%% Nothing here replays a world from events and nothing needs to: a world is a
%% pure function of its seed and the seed is already published. These are not the
%% state of anything. They are a laboratory notebook, append-only, and deleting
%% the store would cost the record and not a single creature.
-module(discovery).

-export([seeded/1, found/3, settled/2, stirred/2, ended/1, stream_for/2]).

%% ⚠ BUSINESS VERBS, NOT CRUD. Nothing here is created, updated or deleted: a
%% world is SEEDED and ENDS, a way of living is FOUND, a world SETTLES and
%% STIRS. The names are the whole point of writing them down, because in a year
%% the only thing left will be the names and the numbers beside them.
-define(VERSION, 1).

%% @doc The stream a run's discoveries belong to.
%%
%% ONE STREAM PER RUN, NOT PER ISLAND. An island outlives its worlds and hosts
%% many; a run is the thing with a beginning, an end and a seed. Keyed by island
%% and seed together, so two islands that happen to draw the same seed are two
%% streams and one island replaying a seed is one.
%% ⚠ THE ISLAND NAME IS PASSED IN, BECAUSE A SNAPSHOT DOES NOT CARRY ONE. This
%% took the map and matched on `island', which `world:snapshot/1' has never had:
%% an island's name comes from `world_facts:island()', from the environment, and
%% a world knows nothing about what the thing running it is called.
%%
%% It crashed on the first live look, on every node, in a `function_clause' that
%% the supervisor restarted every five seconds. **And a test passed**, because
%% the test handed it a map with an `island' key in it: a fixture that agrees
%% with my own function rather than with the island, which is `C.6' and `B.7' in
%% this project's own register, both filed for exactly this.
-spec stream_for(binary(), integer()) -> binary().
stream_for(Island, Seed) ->
    <<"biotope/", Island/binary, "/", (integer_to_binary(Seed))/binary>>.

%% @doc A world began.
%%
%% CARRIES THE WHOLE ECONOMY, because a discovery only means something under the
%% rules that produced it. Two runs that found the same way of living under
%% different physics found different things, and `econ_id' alone cannot say so:
%% world 6 changed the rules and not one constant.
-spec seeded(map()) -> map().
seeded(#{seed := Seed, econ := Econ} = Snap) ->
    event(world_seeded, Snap,
          #{seed => Seed,
            world => maps:get(number, world:ruleset()),
            rules => maps:get(line, world:ruleset()),
            econ_id => maps:get(econ_id, Snap, <<>>),
            economy => Econ}).

%% @doc A way of living nothing on this island had ever done before.
%%
%% The cell, what it means in words, and the tick it first happened. **The words
%% are stored rather than derived**, because a reader in a year has the event and
%% not necessarily the code that would decode a cell index, and `I.6' is what
%% happens when an instrument and the thing it reads drift apart.
-spec found(non_neg_integer(), non_neg_integer(), map()) -> map().
found(Cell, At, Snap) ->
    event(way_of_living_found, Snap,
          #{cell => Cell,
            means => behaviour:describe(Cell),
            first_seen_at => At,
            of_possible => maps:get(behaviour_space, Snap, 0),
            found_so_far => maps:get(explored, Snap, 0)}).

%% @doc The world stopped finding anything new.
%%
%% THE MOST IMPORTANT EVENT HERE AND THE ONE NOTHING ELSE RECORDS. A settled
%% world looks exactly like a healthy one in every other number: the population
%% carries on, energy flows, creatures are born and eaten. Over 32 seeds the
%% median island reaches this by tick 6,000.
-spec settled(non_neg_integer(), map()) -> map().
settled(At, Snap) ->
    event(world_settled, Snap,
          #{settled_at => At,
            ways_found => maps:get(explored, Snap, 0),
            of_possible => maps:get(behaviour_space, Snap, 0),
            kinds_alive => maps:get(kinds, Snap, 0)}).

%% @doc And started again, which is rarer and more interesting.
-spec stirred(non_neg_integer(), map()) -> map().
stirred(At, Snap) ->
    event(world_stirred, Snap,
          #{stirred_at => At,
            new_ways => maps:get(frontier, Snap, 0),
            ways_found => maps:get(explored, Snap, 0)}).

%% @doc It died, which is what most seeds do.
-spec ended(map()) -> map().
ended(Snap) ->
    event(world_ended, Snap,
          #{ended_at => maps:get(extinct_at, Snap, maps:get(tick, Snap, 0)),
            ways_found => maps:get(explored, Snap, 0),
            deepest_line => maps:get(depth, Snap, 0),
            deepest_elite => maps:get(deepest_elite, Snap, 0),
            born => maps:get(born, Snap, 0),
            starved => maps:get(starved, Snap, 0),
            eaten => maps:get(consumed, Snap, 0)}).

%% Every event carries the tick and the island, so a stream can be read without
%% joining it to anything.
event(Type, Snap, Data) ->
    #{event_type => atom_to_binary(Type),
      schema_version => ?VERSION,
      tick => maps:get(tick, Snap, 0),
      data => Data}.
