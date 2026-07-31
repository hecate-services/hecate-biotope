%% @doc What a creature smells LIKE, as opposed to how strongly it smells. PURE.
%%
%% A mark left on the ground carries a strength and a signature. The strength
%% says how recently something passed; the signature says what KIND of thing it
%% was, and it is heritable, so a parent and its children smell nearly alike and
%% two long-separated lineages do not.
%%
%% EIGHT BITS, READ AS A HAMMING DISTANCE. A real scent is a blend of compounds
%% rather than a single number, and kinship shows up as a shared blend, so the
%% natural comparison is how many compounds differ rather than how far apart two
%% integers are. It also makes mutation obvious: flipping one bit changes one
%% component, and a lineage drifts through signature space one compound at a time
%% instead of jumping to an unrelated smell.
%%
%% A CREATURE READS A TRAIL BY HOW UNLIKE ITSELF IT IS. That one rule does two
%% jobs at once. It subsumes the self-check that had to be special-cased before,
%% because your own mark is at distance zero and reads as nothing. And it hands
%% the world kin recognition for free, because your children are at distance zero
%% or one and are very nearly as invisible to you as you are.
%%
%% THE KIN BLINDNESS IS THE POINT, AND IT IS A HYPOTHESIS BEING TESTED. Every
%% predatory collapse measured here, and the ones the Flatland experiments found
%% before it, has the same shape: hunters eat each other and their own young, so
%% a predatory lineage destroys the population it lives in and then itself. One
%% seed lost 84 of its 92 deaths to predation and finished with 217 plants and
%% nobody to eat them. A lineage that cannot track its own kin cannot drive
%% itself extinct that way, and can specialise on the OTHER lineage. Whether that
%% is enough to make a carnivore niche stable is exactly what the probe is for.
%%
%% WHAT THIS DOES NOT DO: protect kin from being EATEN. Tracking is kin-blind,
%% striking is not. A creature that can see the fattest thing in reach knows
%% nothing about signatures, so families still eat each other at close quarters.
%% That is a deliberate limit on this increment rather than an oversight.
-module(scent).

-export([founder/2, inherit/3, perceived/2, strangeness/2, bits/0, spread/1]).

-type tag() :: non_neg_integer().
-type mark() :: {pos_integer(), tag()}.
-export_type([tag/0, mark/0]).

-define(BITS, 8).

%% @doc How many components a signature has. The maximum possible strangeness.
-spec bits() -> pos_integer().
bits() -> ?BITS.

%% @doc A founding signature, drawn uniformly.
%%
%% SPREAD RATHER THAN SHARED, for the same reason founding bodies and brains are
%% spread. A population that starts as one signature is a population in which
%% nothing can track anything, because everyone is everyone's kin, and the whole
%% sense would sit dead until mutation slowly pulled two lineages apart.
-spec founder(map(), rand:state()) -> {tag(), rand:state()}.
founder(_Econ, Rng0) ->
    {N, Rng1} = rand:uniform_s(1 bsl ?BITS, Rng0),
    {N - 1, Rng1}.

%% @doc A child's signature: its parent's, occasionally one component different.
%%
%% ONE BIT AT A TIME, so that a lineage DRIFTS through signature space and
%% intermediate degrees of kinship exist. A signature redrawn at random each
%% generation would make every creature a stranger to its own parent, which is
%% the opposite of what a heritable smell is for.
-spec inherit(tag(), map(), rand:state()) -> {tag(), rand:state()}.
inherit(Tag, Econ, Rng0) ->
    Rate = maps:get(scent_mutation, Econ),
    {Roll, Rng1} = rand:uniform_s(max(1, Rate), Rng0),
    mutate(Roll, Tag, Rng1).

mutate(1, Tag, Rng0) ->
    {Bit, Rng1} = rand:uniform_s(?BITS, Rng0),
    {Tag bxor (1 bsl (Bit - 1)), Rng1};
mutate(_NoMutation, Tag, Rng) ->
    {Tag, Rng}.

%% @doc How unlike two signatures are: 0 for identical, 8 for opposite.
-spec strangeness(tag(), tag()) -> non_neg_integer().
strangeness(A, B) -> differing(A bxor B).

differing(0) -> 0;
differing(N) -> (N band 1) + differing(N bsr 1).

%% @doc How strongly a mark registers on a creature with this signature.
%%
%% Scaled by strangeness, so a stranger's fresh trail reads at full strength, a
%% cousin's reads faint, and your own reads as nothing at all. A creature is not
%% told the signature it is smelling, only how foreign it is: this is a nose, not
%% a name tag, and there is nothing here for a brain to learn to recognise.
-spec perceived(mark(), tag()) -> non_neg_integer().
perceived({Strength, Theirs}, Mine) ->
    Strength * strangeness(Mine, Theirs) div ?BITS.

%% @doc How unlike two randomly chosen members of a population smell, as a
%% percentage of the maximum. The information content of the signature.
%%
%% THIS IS A PROPERTY OF THE SIGNAL AND NOT OF WHAT ANYTHING EVOLVED TO DO WITH
%% IT, and that distinction is the reason this function exists. The mutation rate
%% has to be set somehow, and setting it by which value produced the diet we were
%% hoping for is circular: it installs the result and then reports discovering
%% it. This is the honest criterion instead. A signature everyone shares carries
%% no information, so a nose is being charged rent for a sense that cannot
%% discriminate, and that is a defect in the world whatever ends up living in it.
%%
%% Zero for a population too small to have a pair, rather than a crash or a
%% nonsense average.
%%
%% Counted per component rather than per pair: if K of N carry a component then
%% exactly K*(N-K) pairs differ on it. Same answer as comparing every pair, in
%% time proportional to the population rather than its square.
-spec spread([tag()]) -> non_neg_integer().
spread(Tags) -> across(length(Tags), Tags).

across(N, _Tags) when N < 2 -> 0;
across(N, Tags) ->
    Differing = lists:sum([split(Bit, N, Tags) || Bit <- lists:seq(0, ?BITS - 1)]),
    Differing * 100 div (?BITS * (N * (N - 1) div 2)).

split(Bit, N, Tags) ->
    Set = length([T || T <- Tags, (T bsr Bit) band 1 =:= 1]),
    Set * (N - Set).
