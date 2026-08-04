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

-export([seeded/2, found/4, settled/3, stirred/3, ended/2, stream_for/2]).

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
%% ⚠⚠ AND THE ID IT BUILT WAS NOT A LEGAL STREAM ID. It was
%% `biotope/beam01/101516166', and reckon-db's contract is
%% `[a-z]{1,32}-[a-f0-9]{32}': a lowercase prefix, one hyphen, and exactly
%% thirty-two hex digits. Every append came back `invalid_stream_id' after
%% exhausting its retries, which took long enough to block the keeper's own
%% mailbox.
%%
%% Written now as a prefix and a digest of island and seed together, so the same
%% island replaying the same seed writes to the same stream and two islands that
%% happen to draw one seed do not. **The id is therefore opaque**, which is a real
%% cost for a notebook meant to be read in a year, and is paid for by every event
%% carrying its island and tick in the clear.
%%
%% The alternative was a `$biotope:beam01-101516166' system stream, which is
%% legal and human-readable, and which the same contract calls a STRUCTURALLY
%% RESERVED namespace. Squatting in it to get prettier ids is not a trade worth
%% making.
-spec stream_for(binary(), integer()) -> binary().
stream_for(Island, Seed) ->
    Digest = crypto:hash(md5, <<Island/binary, ":", (integer_to_binary(Seed))/binary>>),
    <<"world-", (binary:encode_hex(Digest, lowercase))/binary>>.

%% @doc A world began.
%%
%% CARRIES THE WHOLE ECONOMY, because a discovery only means something under the
%% rules that produced it. Two runs that found the same way of living under
%% different physics found different things, and `econ_id' alone cannot say so:
%% world 6 changed the rules and not one constant.
-spec seeded(binary(), map()) -> map().
seeded(Island, #{seed := Seed, econ := Econ} = Snap) ->
    event(world_seeded, Island, Snap,
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
-spec found(binary(), non_neg_integer(), non_neg_integer(), map()) -> map().
found(Island, Cell, At, Snap) ->
    event(way_of_living_found, Island, Snap,
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
-spec settled(binary(), non_neg_integer(), map()) -> map().
settled(Island, At, Snap) ->
    event(world_settled, Island, Snap,
          #{settled_at => At,
            ways_found => maps:get(explored, Snap, 0),
            of_possible => maps:get(behaviour_space, Snap, 0),
            kinds_alive => maps:get(kinds, Snap, 0)}).

%% @doc And started again, which is rarer and more interesting.
-spec stirred(binary(), non_neg_integer(), map()) -> map().
stirred(Island, At, Snap) ->
    event(world_stirred, Island, Snap,
          #{stirred_at => At,
            new_ways => maps:get(frontier, Snap, 0),
            ways_found => maps:get(explored, Snap, 0)}).

%% @doc It died, which is what most seeds do.
-spec ended(binary(), map()) -> map().
ended(Island, Snap) ->
    event(world_ended, Island, Snap,
          #{ended_at => maps:get(extinct_at, Snap, maps:get(tick, Snap, 0)),
            ways_found => maps:get(explored, Snap, 0),
            deepest_line => maps:get(depth, Snap, 0),
            deepest_elite => maps:get(deepest_elite, Snap, 0),
            born => maps:get(born, Snap, 0),
            starved => maps:get(starved, Snap, 0),
            eaten => maps:get(consumed, Snap, 0)}).

%% ⚠ EVERY EVENT CARRIES ITS ISLAND AND ITS TICK IN THE CLEAR, and the comment
%% here used to CLAIM that while the code carried only the tick. It matters more
%% now than it did: the stream id is a digest and says nothing a human can read,
%% so if these two are not in the event then nothing anywhere connects a
%% discovery to the island that made it.
event(Type, Island, Snap, Data) ->
    #{event_type => atom_to_binary(Type),
      schema_version => ?VERSION,
      island => Island,
      tick => maps:get(tick, Snap, 0),
      data => Data}.
