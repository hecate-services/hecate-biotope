%% @doc A CREATURE, PACKED FOR A JOURNEY BETWEEN ISLANDS. PURE.
%%
%% ==========================================================================
%% THIS IS THE FIRST THING IN THIS PROJECT THAT CAN BREAK THE FIRST LAW
%% ==========================================================================
%%
%% For twenty-four worlds every joule was in the ground, in a creature's store,
%% or built into its structure, and `world_tests' asserts it on every path. All
%% of that arithmetic happens inside ONE `world()' on ONE node.
%%
%% A migrant leaves. If it is delivered twice, the world gains a creature out of
%% nothing and its energy with it: **free energy**. If it is lost in flight, the
%% same amount is destroyed. Neither shows up as a crash, both look like ordinary
%% population noise, and the conservation tests would keep passing on both sides
%% because each world's own books would still balance.
%%
%% So a departure is recorded and an arrival is recorded, and the invariant that
%% replaces the old one is `books + departed - arrived', which is conserved
%% across the whole archipelago and not merely on one island.
%%
%% ==========================================================================
%% WHAT TRAVELS, AND WHAT DOES NOT
%% ==========================================================================
%%
%% ⚠ `id' AND `at' ARE NOT THE CREATURE, THEY ARE WHERE IT WAS FILED. An id is
%% local to a world's counter and two islands hand out the same numbers; a cell
%% is a coordinate in one island's own hex disc and means nothing in another.
%% The receiver assigns both. Everything else is the animal.
%%
%% `parent' does not travel either, for the same reason: it is a local id, and on
%% the far shore it would point at a stranger. A migrant arrives an orphan, which
%% is true, and keeps its `lineage' and `generation', which is what descent
%% actually is.
%%
%% ==========================================================================
%% VALIDATED, NEVER TRUSTED
%% ==========================================================================
%%
%% This is the first input to the world that did not come from the world. A
%% malformed migrant is not a display problem: `brain:fire/3' zips a weight row
%% against an input vector, so a body and a brain that disagree on width crash
%% the RECEIVING island's tick, and every island on the mesh is reachable by
%% anyone who can publish.
%%
%% `unpack/1' therefore checks the shape it needs rather than pattern-matching
%% hopefully: the row widths against the sensor count, the field and purpose
%% codes against the lists they index, and every number for being a non-negative
%% integer. It returns `{error, Why}' and the island declines the animal.
-module(migrant).

-export([pack/2, unpack/1, version/0]).
-export([energy_of/1]).

%% ⚠ APPENDED TO, NEVER REORDERED, and bumped when the shape changes. A migrant
%% is the only message in this system that another node's CODE will act on, so a
%% reader that guesses wrong builds a creature that is subtly not the one that
%% left.
-define(VERSION, 1).

-type packed() :: #{atom() => integer() | [integer()]}.
-export_type([packed/0]).

-spec version() -> pos_integer().
version() -> ?VERSION.

%%==============================================================================
%% Out
%%==============================================================================

%% @doc Pack a creature for one crossing.
%%
%% ⚠ THE CROSSING ID IS WHAT MAKES AT-MOST-ONCE POSSIBLE, and it belongs to the
%% DEPARTURE rather than to the message. A transport that retries must send the
%% same bytes, so a receiver can tell a retry from a second animal; a sender that
%% minted a fresh id per attempt would defeat the whole mechanism while looking
%% correct.
-spec pack(map(), integer()) -> packed().
pack(C, Crossing) ->
    #{body := Body, brain := Brain} = C,
    #{version => ?VERSION,
      crossing => Crossing,
      %% The heritable animal.
      body => flat_body(Body),
      hidden => flat_rows(maps:get(hidden, Brain)),
      marks => brain:marks(Brain),
      outputs => flat_outputs(maps:get(outputs, Brain)),
      scent => maps:get(scent, C),
      uptake => maps:get(uptake, C),
      mouth => maps:get(mouth, C),
      %% What it is carrying. `energy' and `structure' are the two halves of the
      %% first law and the reason this module has an accounting section at all.
      energy => maps:get(energy, C),
      structure => maps:get(structure, C),
      water => maps:get(water, C),
      owed => maps:get(owed, C),
      memory => maps:get(memory, C),
      %% What it has been. Carried so a lineage survives the crossing and a
      %% behaviour descriptor is not reset by a change of address.
      age => maps:get(age, C),
      lineage => maps:get(lineage, C),
      generation => maps:get(generation, C),
      moved => maps:get(moved, C),
      bred => maps:get(bred, C),
      from_ground => maps:get(from_ground, C),
      from_creatures => maps:get(from_creatures, C)}.

%% `[{Field, Range}]' becomes `[FieldCode, Range, ...]'. A tuple does not survive
%% the encoder cleanly, which is the oldest wire rule here.
flat_body(Body) ->
    lists:append([[field_code(F), R] || {F, R} <- Body]).

flat_rows(Rows) -> lists:append([[length(R) | R] || R <- Rows]).

%% One entry per purpose, in `brain:purposes/0' order, each carrying its own two
%% row lengths. A purpose a creature does not have is absent from the map and is
%% sent as a width of -1, which is distinguishable from a purpose it has with an
%% empty row.
flat_outputs(Outs) ->
    lists:append([entry(maps:find(P, Outs)) || P <- brain:purposes()]).

entry(error) -> [-1];
entry({ok, #{inputs := I, hidden := H}}) -> [length(I)] ++ I ++ [length(H)] ++ H.

field_code(F) -> index_of(F, body:fields()).

index_of(X, List) -> length(lists:takewhile(fun(Y) -> Y =/= X end, List)).

%%==============================================================================
%% In
%%==============================================================================

-spec unpack(packed()) -> {ok, map()} | {error, atom()}.
unpack(#{version := ?VERSION} = P) ->
    checked(maps:with(expected(), P), P);
unpack(#{version := _Other}) ->
    {error, wrong_version};
unpack(_Shapeless) ->
    {error, not_a_migrant}.

expected() ->
    [version, crossing, body, hidden, marks, outputs, scent, uptake, mouth,
     energy, structure, water, owed, memory, age, lineage, generation, moved,
     bred, from_ground, from_creatures].

%% Every key present, or the sender is on a different build and guessing which
%% defaults to invent would be inventing a creature.
checked(Kept, P) when map_size(Kept) =:= 21 -> built(P);
checked(_Short, _P) -> {error, missing_keys}.

built(P) ->
    Body = body_of(maps:get(body, P)),
    Hidden = rows_of(maps:get(hidden, P)),
    Outs = outputs_of(maps:get(outputs, P)),
    assembled(Body, Hidden, Outs, maps:get(marks, P), P).

assembled(bad, _H, _O, _M, _P) -> {error, bad_body};
assembled(_B, bad, _O, _M, _P) -> {error, bad_hidden};
assembled(_B, _H, bad, _M, _P) -> {error, bad_outputs};
assembled(Body, Hidden, Outs, Marks, P) ->
    sane(length(Body), Hidden, Outs, Marks, Body, P).

%% ⚠ THE WIDTH CHECK, AND IT IS THE ONE THAT MATTERS.
%%
%% `brain:fire/3' zips an output's `inputs' row against the input vector, which
%% is one reading per sensor plus `here'. A hidden row also reads the previous
%% tick's activations, so it is `sensors + 1 + nodes' wide. A migrant whose rows
%% disagree with its body does not draw oddly, it CRASHES THE RECEIVING WORLD'S
%% TICK, and anyone who can publish can send one.
sane(Sensors, Hidden, Outs, Marks, Body, P) ->
    Nodes = length(Hidden),
    Fits = lists:all(fun(R) -> length(R) =:= brain:row_width(Sensors, Nodes) end,
                     Hidden)
        andalso lists:all(fun(#{inputs := I, hidden := H}) ->
                                  length(I) =:= Sensors + 1
                                      andalso length(H) =:= Nodes
                          end, maps:values(Outs))
        andalso length(Marks) =:= Nodes
        andalso numbers(P),
    creature(Fits, Body, Hidden, Marks, Outs, P).

creature(false, _B, _H, _M, _O, _P) -> {error, does_not_fit};
creature(true, Body, Hidden, Marks, Outs, P) ->
    {ok, #{body => Body,
           brain => #{hidden => Hidden, marks => Marks, outputs => Outs},
           scent => maps:get(scent, P),
           uptake => maps:get(uptake, P),
           mouth => maps:get(mouth, P),
           energy => maps:get(energy, P),
           structure => maps:get(structure, P),
           water => maps:get(water, P),
           owed => maps:get(owed, P),
           memory => maps:get(memory, P),
           age => maps:get(age, P),
           lineage => maps:get(lineage, P),
           generation => maps:get(generation, P),
           moved => maps:get(moved, P),
           bred => maps:get(bred, P),
           from_ground => maps:get(from_ground, P),
           from_creatures => maps:get(from_creatures, P)}}.

%% A negative store is not a creature, and a structure of zero is not a body.
%% Checked rather than clamped: a clamped migrant is a different animal from the
%% one that left, silently.
numbers(P) ->
    lists:all(fun(K) -> is_integer(maps:get(K, P)) andalso maps:get(K, P) >= 0 end,
              [scent, uptake, mouth, energy, water, owed, age, generation,
               moved, bred, from_ground, from_creatures])
        andalso is_integer(maps:get(structure, P))
        andalso maps:get(structure, P) > 0
        andalso is_integer(maps:get(lineage, P))
        andalso is_integer(maps:get(crossing, P))
        andalso lists:all(fun is_integer/1, maps:get(memory, P)).

body_of(Flat) -> pairs(Flat, length(body:fields()), []).

pairs([], _Fields, Acc) -> lists:reverse(Acc);
pairs([Code, Range | Rest], Fields, Acc)
  when is_integer(Code), Code >= 0, Code < Fields,
       is_integer(Range), Range >= 0 ->
    pairs(Rest, Fields, [{lists:nth(Code + 1, body:fields()), Range} | Acc]);
pairs(_Ragged, _Fields, _Acc) -> bad.

rows_of(Flat) -> rows(Flat, []).

rows([], Acc) -> lists:reverse(Acc);
rows([Len | Rest], Acc) when is_integer(Len), Len >= 0, length(Rest) >= Len ->
    {Row, Tail} = lists:split(Len, Rest),
    row(lists:all(fun is_integer/1, Row), Row, Tail, Acc);
rows(_Ragged, _Acc) -> bad.

row(false, _Row, _Tail, _Acc) -> bad;
row(true, Row, Tail, Acc) -> rows(Tail, [Row | Acc]).

outputs_of(Flat) -> outs(Flat, brain:purposes(), #{}).

outs([], [], Acc) -> Acc;
outs([-1 | Rest], [_P | Ps], Acc) -> outs(Rest, Ps, Acc);
outs([In | Rest], [P | Ps], Acc) when is_integer(In), In >= 0, length(Rest) >= In ->
    {I, Tail} = lists:split(In, Rest),
    with_hidden(Tail, I, P, Ps, Acc);
outs(_Ragged, _Ps, _Acc) -> bad.

with_hidden([Hn | Rest], I, P, Ps, Acc)
  when is_integer(Hn), Hn >= 0, length(Rest) >= Hn ->
    {H, Tail} = lists:split(Hn, Rest),
    whole(lists:all(fun is_integer/1, I ++ H), Tail, I, H, P, Ps, Acc);
with_hidden(_Ragged, _I, _P, _Ps, _Acc) -> bad.

whole(false, _Tail, _I, _H, _P, _Ps, _Acc) -> bad;
whole(true, Tail, I, H, P, Ps, Acc) ->
    outs(Tail, Ps, Acc#{P => #{inputs => I, hidden => H}}).

%%==============================================================================
%% The books
%%==============================================================================

%% @doc EVERY JOULE THIS ANIMAL IS CARRYING, store and structure together.
%%
%% Exported because the two worlds either side of a crossing have to agree on it:
%% the sender subtracts exactly this and the receiver adds exactly this, and a
%% test sums both islands to check the archipelago conserved what one island
%% could not have noticed losing.
-spec energy_of(packed() | map()) -> integer().
energy_of(#{energy := E, structure := S}) -> E + S.
