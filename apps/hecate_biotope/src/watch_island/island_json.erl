%% @doc A JSON writer of exactly one shape, and no dependency for it.
%%
%% Everything `island_disc:packed/2' produces is an integer, a float or a flat
%% list of those, BY CONSTRUCTION, so this is a fold and a comma. Pulling in an
%% encoder to serialise four arrays of numbers would be the larger of the two
%% mistakes available.
%%
%% ONE COPY, used by the socket and by `/disc.json'. Two encoders that agree
%% today is `I.6' waiting to happen: an instrument that computes its own version
%% of a rule is correct when written and silently stops agreeing when the rule
%% changes.
%%
%% ⚠ IT ENCODES NO STRINGS AND THAT IS DELIBERATE. A string needs escaping, and
%% the moment this had to escape one it would stop being obviously correct. The
%% socket sends the vitals as a SEPARATE tagged frame for exactly that reason,
%% rather than wrapping HTML inside JSON.
-module(island_json).

-export([encode/1]).

-spec encode(map()) -> iodata().
encode(Map) ->
    [${, lists:join($,, [pair(K, V) || {K, V} <- lists:sort(maps:to_list(Map))]),
     $}].

pair(Key, Value) -> [$", atom_to_binary(Key), $", $:, value(Value)].

value(N) when is_integer(N) -> integer_to_binary(N);
value(F) when is_float(F) -> float_to_binary(F, [{decimals, 2}, compact]);
value(L) when is_list(L) ->
    [$[, lists:join($,, [value(V) || V <- L]), $]].
