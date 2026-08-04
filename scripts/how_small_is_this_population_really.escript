#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc Ne: HOW MANY CREATURES ARE ACTUALLY BREEDING THIS WORLD'S FUTURE?
%%
%% Usage:  ./scripts/how_small_is_this_population_really.escript [seeds [ticks]]
%%
%% ==========================================================================
%% EVERY SELECTABILITY GATE IN THIS PROJECT HAS GUESSED AT THIS NUMBER
%% ==========================================================================
%%
%% `R.1' says a trait whose selection differential falls below `1 / (2·Ne)' is
%% moved by drift rather than by selection, and world 15 burned forty-eight seeds
%% at twenty thousand ticks discovering that from the wrong end. Every gate since
%% has computed that threshold. **Not one has measured `Ne`.** World 23's, written
%% yesterday, put it at "70 or 35" and said out loud that it was a guess.
%%
%% It matters more than any single world. If the effective population is 10 where
%% the census is 70, the drift floor is 5% instead of 0.7%, and **nearly every
%% trait this project has priced was below it**. Three worlds of "expressible and
%% unused" would have one cause, and it would not be any of the three.
%%
%% `H.13' was the rival explanation and was refuted on 2026-08-04. This is the
%% only candidate left standing.
%%
%% ==========================================================================
%% TWO ESTIMATORS, BECAUSE ONE NUMBER FROM ONE METHOD IS A GUESS WITH ARITHMETIC
%% ==========================================================================
%%
%% ⚠ AND THE FIRST OF THEM IS REPORTED WITH ITS ASSUMPTION BROKEN, WHICH IS SAID
%% HERE RATHER THAN DISCOVERED BY A READER. Crow and Kimura's variance formula
%% assumes DISCRETE, NON-OVERLAPPING generations: everybody breeds, then everybody
%% dies. This world has neither. Creatures breed at any age, live alongside their
%% own great-grandchildren, and the census used for `N' is a harmonic mean over
%% ticks rather than a count of breeders in a generation. **Applied here it
%% returns values below one, which is not a population size.**
%%
%% It is kept in the table because its INPUTS are the finding: a variance in
%% offspring of 20 to 104 against a mean near 1. That ratio is real, it is
%% measured at death over completed lives, and it is what drives `Ne` down
%% however it is combined. **The coalescent estimate is the one to read**, because
%% it integrates over the actual history, overlapping generations and all.
%%
%% VARIANCE IN OFFSPRING. Crow and Kimura's haploid form,
%% `Ne = (N·k̄ − 1) / (k̄ − 1 + Vk/k̄)'. What drives `Ne' below `N' is not the head
%% count but the INEQUALITY of reproduction: if most creatures leave nothing and
%% a few leave many, the future comes from the few. Measured from `bred', which
%% every creature now carries, sampled AT DEATH so each count is a completed
%% life rather than a partial one.
%%
%% COALESCENCE. In an idealised population, `k' lineages take about
%% `2·Ne·(1 − 1/k)' generations to collapse to one. This world starts with forty
%% founding lines and `lineages' reaches 1 in every seed, so the TIME it takes is
%% an independent reading of the same quantity. Generation time is taken from
%% `depth', which counts generations along the deepest living line.
%%
%% ⚠ AND THE TWO WILL NOT AGREE EXACTLY. They measure different things: variance
%% effective size is about one generation's sampling, coalescent effective size
%% integrates over the whole history including every crash. **If they disagree by
%% an order of magnitude that is a finding**, and if they agree the number can be
%% used.
-mode(compile).

main(Args) ->
    Seeds = arg(Args, 1, 12),
    Ticks = arg(Args, 2, 4000),
    io:format("~n~p seeds to ~p ticks. World ~p.~n~n",
              [Seeds, Ticks, maps:get(number, world:ruleset())]),
    io:format("~s~n", [row(["seed", "census N", "deaths", "mean kids",
                            "var kids", "Ne (var)", "coalesced", "gen time",
                            "Ne (coal)"])]),
    Rows = in_parallel(fun(S) -> watch(S, Ticks) end, lists:seq(1, Seeds)),
    lists:foreach(fun print/1, Rows),
    verdict([R || R <- Rows, R =/= dead]).

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.

%% ==========================================================================
%% Walking a world one tick at a time, watching who dies and what they left
%% ==========================================================================
%%
%% A creature's `bred' count is only complete when it is dead, so the previous
%% tick's population is held and diffed against this one. Anybody who has gone
%% contributes their final count. **Sampling the LIVING would count every
%% newborn as childless** and report a variance that is mostly youth, which is
%% the same confound the portraits carry and is avoidable here.
watch(Seed, Ticks) ->
    W = world:new(#{seed => Seed, population => 40}),
    step(W, world:creatures(W), Ticks, [], [], none).

step(W, _Was, 0, Kids, Sizes, Coalesced) ->
    tally(W, Kids, Sizes, Coalesced);
step(W, Was, Left, Kids, Sizes, Coalesced) ->
    alive(world:population(W), W, Was, Left, Kids, Sizes, Coalesced).

alive(0, W, _Was, _Left, Kids, Sizes, Coalesced) -> tally(W, Kids, Sizes, Coalesced);
alive(Pop, W, Was, Left, Kids, Sizes, Coalesced) ->
    W1 = world:tick(W, 1),
    Now = world:creatures(W1),
    Gone = [maps:get(bred, C, 0) || {Id, C} <- maps:to_list(Was),
                                    not maps:is_key(Id, Now)],
    %% ⚠ THE LINEAGE CHECK IS SAMPLED, NOT PER TICK. `world:snapshot/1' computes
    %% the archive, the portraits and forty other things; calling it every tick
    %% to read one field made this instrument slower than the world it watches.
    %% Every twentieth tick is finer resolution than a coalescence time needs.
    step(W1, Now, Left - 1, Gone ++ Kids, [Pop | Sizes],
         watched(Left rem 20, Coalesced, W1)).

watched(0, Coalesced, W) -> collapsed(Coalesced, W);
watched(_Other, Coalesced, _W) -> Coalesced.

%% The tick at which the last founding line but one disappeared.
collapsed(none, W) -> settled(maps:get(lineages, world:snapshot(W)), W);
collapsed(At, _W) -> At.

settled(1, W) -> maps:get(tick, world:snapshot(W));
settled(_Many, _W) -> none.

tally(W, [], _Sizes, _Coalesced) -> deadness(world:population(W));
tally(W, Kids, Sizes, Coalesced) ->
    S = world:snapshot(W),
    #{census => harmonic(Sizes),
      deaths => length(Kids),
      mean => mean(Kids),
      var => variance(Kids),
      ne_var => variance_ne(harmonic(Sizes), Kids),
      coalesced => Coalesced,
      gen => generation(S),
      ne_coal => coalescent_ne(Coalesced, generation(S))}.

deadness(0) -> dead;
deadness(_Pop) -> dead.

%% ==========================================================================
%% Crow and Kimura, haploid: Ne = (N·k̄ − 1) / (k̄ − 1 + Vk/k̄)
%% ==========================================================================
%%
%% Everything is in hundredths, because this world has no floats on purpose and a
%% quantity that runs from 0.3 to 3 needs the resolution.
%% ⚠ EVERY QUANTITY HERE IS IN HUNDREDTHS AND THE SCALINGS DO NOT CANCEL. The
%% first version wrote `N * K' where the formula wants `N · k̄', which in
%% hundredths is `N100 · K100 / 100', and reported an `Ne' a hundred times too
%% large. Worked through once, on paper, with the check below it.
%%
%%   N = 50, k̄ = 0.96, Vk = 9
%%   numerator   = 50·0.96 − 1                = 47.00
%%   denominator = 0.96 − 1 + 9/0.96          =  9.33
%%   Ne          = 47.00 / 9.33               =  5.03
variance_ne(_N, []) -> 0;
variance_ne(N, Kids) ->
    K = mean(Kids),
    top(N * K div 100 - 100, K - 100 + scaled(variance(Kids), K)).

top(Num, D) when D =< 0 -> abs(Num) * 0;
top(Num, D) -> Num * 100 div D.

scaled(_V, 0) -> 0;
scaled(V, K) -> V * 100 div K.

%% ==========================================================================
%% Coalescence: k lineages collapse to one in about 2·Ne·(1 − 1/k) generations
%% ==========================================================================
%%
%% Forty founders, so the factor is 2 · (1 − 1/40) = 1.95.
%% Generations = ticks / generation-time, and `Gen' arrives in hundredths, so the
%% result needs one more factor of a hundred to come out in hundredths itself.
%% Checked by hand: coalesced at tick 601 with a 37.38-tick generation is 16.1
%% generations, and 16.1 / 1.95 is **8.24**, which the first version reported as
%% 0.08.
coalescent_ne(none, _Gen) -> 0;
coalescent_ne(_At, 0) -> 0;
coalescent_ne(At, Gen) -> At * 100 * 100 * 100 div (Gen * 195).

%% Generations along the deepest living line, so ticks per generation is the
%% tick divided by the depth. A LOWER BOUND on generation time, because the
%% deepest line is by definition the fastest-breeding one.
generation(#{depth := 0}) -> 0;
generation(#{depth := D, tick := T}) -> T * 100 div D.

mean([]) -> 0;
mean(Vs) -> lists:sum(Vs) * 100 div length(Vs).

variance([]) -> 0;
variance(Vs) ->
    K = mean(Vs),
    lists:sum([(V * 100 - K) * (V * 100 - K) || V <- Vs])
        div (length(Vs) * 100 * 100) * 100.

%% ⚠ OVER TICKS RATHER THAN GENERATIONS, WHICH IS AN APPROXIMATION AND IS STATED.
%% The textbook quantity is the harmonic mean over GENERATIONS; ticks are used
%% because they are what this world counts, and with ten to twenty ticks per
%% generation the two differ little unless the population moves faster than it
%% breeds.
%%
%% ⚠ THE HARMONIC MEAN, NOT THE ARITHMETIC ONE. A population that crashes to five
%% and recovers to two hundred drifts like five, not like a hundred: the smallest
%% number in the history dominates. Using the arithmetic mean here is the classic
%% way to overstate Ne by an order of magnitude.
harmonic([]) -> 0;
harmonic(Sizes) ->
    Positive = [S || S <- Sizes, S > 0],
    reciprocal(length(Positive),
               lists:sum([100 * 100 div S || S <- Positive])).

%% H = n / Σ(1/x). The reciprocals are accumulated at 10,000x, so the result
%% needs one more factor of a hundred to come out in hundredths. Without it the
%% census read 0.05 where the population was fifty.
reciprocal(0, _Sum) -> 0;
reciprocal(_N, 0) -> 0;
reciprocal(N, Sum) -> N * 100 * 100 * 100 div Sum.

print(dead) -> io:format("~s~n", [row(["-", "died", "-", "-", "-", "-", "-", "-", "-"])]);
print(R) ->
    io:format("~s~n",
              [row(["", hundredths(maps:get(census, R)), maps:get(deaths, R),
                    hundredths(maps:get(mean, R)), hundredths(maps:get(var, R)),
                    hundredths(maps:get(ne_var, R)),
                    at(maps:get(coalesced, R)), hundredths(maps:get(gen, R)),
                    hundredths(maps:get(ne_coal, R))])]).

at(none) -> "never";
at(Tick) -> integer_to_list(Tick).

verdict([]) ->
    io:format("~nEvery seed died before anything could be measured.~n");
%% ⚠ ONLY SEEDS THAT ACTUALLY COALESCED, because the others have no coalescent
%% reading and their census is a harmonic mean dominated by a population dwindling
%% to nothing. Mixing a dying world's bottleneck into the median would report the
%% dying rather than the drift.
verdict(All) ->
    Rows = [R || R <- All, maps:get(ne_coal, R) > 0],
    measured(Rows, All).

measured([], _All) ->
    io:format("~nNo seed coalesced. Run longer: the coalescent estimate needs "
              "the founding lines to collapse.~n");
measured(Rows, All) ->
    io:format("~n~p of ~p seeds coalesced and are the ones read.~n",
              [length(Rows), length(All)]),
    reading(Rows).

reading(Rows) ->
    Var = median([maps:get(ne_var, R) || R <- Rows]),
    Coal = median([maps:get(ne_coal, R) || R <- Rows]),
    Census = median([maps:get(census, R) || R <- Rows]),
    io:format("~nMEDIAN Ne: ~ts by offspring variance, ~ts by coalescence, "
              "against a harmonic census of ~ts.~n~n~ts~n",
              [hundredths(Var), hundredths(Coal), hundredths(Census),
               call(Var, Coal, Census)]).

%% The reading, stated before the numbers: the gates have used 35 to 70, and the
%% question is whether the true figure changes what they concluded.
%% The coalescent figure, not the smaller of the two: the variance estimator's
%% assumption is broken here and taking a minimum would let a number known to be
%% invalid decide the answer.
call(_Var, Coal, Census) -> floor_of(Coal, Census).

floor_of(0, _Census) ->
    "One estimator returned nothing. Read the table rather than this line.";
floor_of(Ne, Census) ->
    Floor = 100 * 100 * 100 div (2 * Ne),
    io_lib:format("The drift floor 1/(2·Ne) is ~ts%, against the ~ts% and ~ts% "
                  "the gates have assumed.~nHarmonic census is ~ts, so Ne is "
                  "~ts of it.~n~n~ts",
                  [hundredths(Floor), <<"1.43">>, <<"0.71">>, hundredths(Census),
                   hundredths(Ne * 100 div max(1, Census div 100)),
                   consequence(Floor)]).

consequence(Floor) when Floor > 300 ->
    "⚠ NEARLY EVERY TRAIT THIS PROJECT HAS PRICED WAS BELOW THE DRIFT FLOOR.\n"
    "A mouth moved the bill by 0.24%, an output by 1.34%, a hidden node's\n"
    "silencing by 10.6%. If the floor is above three percent then world 15 was\n"
    "not an isolated failure, it was the first visible case of a condition every\n"
    "gate since has computed against a number nobody measured.";
consequence(Floor) when Floor > 100 ->
    "The floor is higher than the gates assumed but not catastrophically. The\n"
    "traits priced near one percent were marginal rather than invisible, which\n"
    "is roughly what world 18 measured when it found nothing happening at\n"
    "act_cost 16.";
consequence(_Floor) ->
    "The gates were right and Ne is not the explanation. Both candidates for\n"
    "three consecutive nulls are now refuted, and the cause is elsewhere.".

in_parallel(F, Items) ->
    Parent = self(),
    Refs = [spawn_one(Parent, F, I) || I <- Items],
    [receive {Ref, Result} -> Result end || Ref <- Refs].

spawn_one(Parent, F, Item) ->
    Ref = make_ref(),
    spawn_link(fun() -> Parent ! {Ref, F(Item)} end),
    Ref.

median([]) -> 0;
median(L) -> lists:nth(length(L) div 2 + 1, lists:sort(L)).

hundredths(V) when is_integer(V) -> io_lib:format("~w.~2..0w", [V div 100, V rem 100]);
hundredths(V) -> V.

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).
pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(lists:flatten(C), 11, trailing).
