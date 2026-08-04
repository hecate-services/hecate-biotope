#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc H.13, PUT TO THE TEST: IF THEY LIVED LONGER, WOULD THEY USE ANYTHING?
%%
%% Usage:  ./scripts/does_a_longer_life_buy_a_brain.escript [seeds [ticks]]
%%
%% ==========================================================================
%% THE CLAIM THIS EXISTS TO FALSIFY
%% ==========================================================================
%%
%% `H.13' says nothing lives long enough to execute a strategy. `max_age' is 600
%% and the mean life is about TEN TICKS: at tick 3,000 of a live world, of 31,877
%% born, 20,498 were eaten, 11,228 starved and NINE died of old age.
%%
%% If that is the constraint, then three worlds of results are about the clock
%% rather than about the capacities they measured. Memory is worth nothing to a
%% creature that will not see a second situation (world 21). Width must be re-won
%% every generation against drift, and a generation is ten ticks (world 19).
%%
%% ⚠ IT WAS DERIVED FROM ARITHMETIC ON ONE WORLD'S NUMBERS AND IS NOT YET A
%% FINDING. This is the measurement that makes it one or withdraws it.
%%
%% ==========================================================================
%% THE INDEPENDENT VARIABLE IS THE ACHIEVED LIFE, NOT THE CONSTANT
%% ==========================================================================
%%
%% Two levers are swept because neither is obviously the right one and the point
%% is to move LIFESPAN, not to move a constant:
%%
%%   metabolism   the flat cost of existing. Lower means less starvation.
%%   radius       a bigger board means fewer encounters, and 64% of deaths here
%%                are predation rather than starvation.
%%
%% **A lever that does not move the life column has answered a different
%% question**, and `eaten%' and `starved%' are reported beside it so the
%% mechanism is visible rather than inferred. Cheaper living produces more
%% survivors, more crowding and more predation, so lifespan may not rise at all.
%% That would itself be the finding: life is not controllable by the obvious
%% lever.
%%
%% ⚠ NOTHING HERE SETS A DEFAULT. Every value is published and no constant is
%% chosen by which one gave a nicer answer, which is the rule this project holds
%% hardest.
-mode(compile).

%% ⚠ THE THRESHOLD, STATED BEFORE THE RUN AND NAMED AS A CONVENTION.
%%
%% `H.13' is supported if the longer-lived half of the arms carries at least
%% TWICE the hidden nodes of the shorter-lived half. Two is a convention and not
%% a derivation: nothing about this world says what a real response should look
%% like, and picking the multiple after seeing the numbers is how a result gets
%% chosen rather than measured.
%%
%% **Both halves are printed whatever it decides**, so a reader who thinks two is
%% the wrong number can apply their own to the same figures. The smoke run came
%% out at 1.85 and was called a refutation, which is the threshold doing its job
%% rather than a verdict to be argued with afterwards.
-define(RESPONSE, 2).

%% And a run whose life column barely moved has not applied its own treatment.
%% Under this, the experiment says nothing either way, which is a worse outcome
%% than a refutation and must not be mistaken for one.
-define(MIN_LIFE_SPREAD_PCT, 30).

main(Args) ->
    Seeds = arg(Args, 1, 24),
    Ticks = arg(Args, 2, 6000),
    io:format("~n~p seeds to ~p ticks. World ~p.~n"
              "H.13 predicts nodes RISE with the life column. Flat means H.13 is "
              "wrong.~n~n",
              [Seeds, Ticks, maps:get(number, world:ruleset())]),
    io:format("~s~n", [row(["lever", "value", "dead", "LIFE", "pop", "eaten%",
                            "starved%", "NODES", "width", "sens", "explored",
                            "frontier"])]),
    Metab = [arm(metabolism, V, Seeds, Ticks) || V <- [20, 15, 10, 7, 5, 3, 1]],
    io:format("~n"),
    Radius = [arm(radius, V, Seeds, Ticks) || V <- [10, 20, 30, 40]],
    verdict(Metab ++ Radius).

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.

arm(Lever, Value, Seeds, Ticks) ->
    Rows = in_parallel(fun(S) -> run(S, Lever, Value, Ticks) end,
                       lists:seq(1, Seeds)),
    Live = [R || #{population := P} = R <- Rows, P > 0],
    report(Lever, Value, Seeds - length(Live), Live, Ticks).

run(Seed, Lever, Value, Ticks) ->
    Opts = maps:put(Lever, Value, #{seed => Seed, population => 40}),
    world:snapshot(advance(world:new(Opts), Ticks)).

report(Lever, Value, Dead, [], _Ticks) ->
    io:format("~s~n", [row([Lever, Value, Dead | lists:duplicate(9, "-")])]),
    #{life => 0, nodes => 0, dead => Dead};
report(Lever, Value, Dead, Live, Ticks) ->
    Med = fun(K) -> median([maps:get(K, S) || S <- Live]) end,
    Life = median([life(S, Ticks) || S <- Live]),
    Nodes = Med(hidden_mean),
    io:format("~s~n",
              [row([Lever, Value, Dead, hundredths(Life), Med(population),
                    pct(consumed, Live), pct(starved, Live),
                    hundredths(Nodes), hundredths(Med(hidden_width)),
                    hundredths(Med(sensor_mean)), Med(explored),
                    Med(frontier)])]),
    #{life => Life, nodes => Nodes, dead => Dead}.

%% The project's existing estimate: creature-ticks per death, times a hundred.
life(#{population := Pop, born := Born}, Ticks) ->
    scaled(Pop * Ticks * 100, Born + 40 - Pop).

scaled(_Num, D) when D =< 0 -> 0;
scaled(Num, D) -> Num div D.

%% What share of deaths this cause accounts for, so the mechanism is visible.
pct(Cause, Live) ->
    Of = lists:sum([maps:get(Cause, S) || S <- Live]),
    All = lists:sum([maps:get(starved, S) + maps:get(consumed, S)
                         + maps:get(aged_out, S) || S <- Live]),
    [integer_to_list(Of * 100 div max(1, All)), "%"].

%% ==========================================================================
%% THE READING, STATED BEFORE THE NUMBERS ARE SEEN
%% ==========================================================================
%%
%% `H.13' is supported if hidden nodes rise with the achieved life and refuted if
%% they do not. Nothing else in the table decides it: population, deaths and the
%% frontier are context.
%%
%% ⚠ AND A LEVER THAT DID NOT MOVE THE LIFE COLUMN CANNOT REFUTE ANYTHING. If
%% life is flat across every setting, this experiment failed to apply its own
%% treatment and says nothing about `H.13' either way, which is a different and
%% more embarrassing outcome than a refutation.
verdict(Rows) ->
    Live = [R || #{life := L} = R <- Rows, L > 0],
    io:format("~n~s~n", [read(Live)]).

%% A guard cannot call a local function, so the comparison is made here and the
%% clauses below take a plain boolean.
read([]) -> call(false, []);
read(Live) ->
    Spread = spread(Live, life),
    call(Spread * 100 < lowest_life(Live) * ?MIN_LIFE_SPREAD_PCT, Live).

spread([], _Key) -> 0;
spread(Rows, Key) ->
    Values = [maps:get(Key, R) || R <- Rows],
    lists:max(Values) - lists:min(Values).

call(_Flat, []) ->
    "Every arm died. Nothing to read.";
call(true, _Live) ->
    "⚠ THE TREATMENT DID NOT TAKE. The life column barely moved across every\n"
    "setting of both levers, so this run cannot say anything about H.13. What it\n"
    "DOES say is that lifespan is not controllable by either obvious lever, which\n"
    "is worth its own register entry: something else is setting it.";
call(false, Live) ->
    linked(correlated(Live)).

lowest_life(Live) -> lists:min([maps:get(life, R) || R <- Live]).

%% Do the longest-lived arms carry more computation than the shortest-lived?
correlated(Live) ->
    Sorted = lists:sort([{maps:get(life, R), maps:get(nodes, R)} || R <- Live]),
    Half = max(1, length(Sorted) div 2),
    {Short, Long} = lists:split(Half, Sorted),
    {mean([N || {_L, N} <- Short]), mean([N || {_L, N} <- Long])}.

mean([]) -> 0;
mean(Vs) -> lists:sum(Vs) div length(Vs).

linked({Short, Long}) when Long >= Short * ?RESPONSE ->
    io_lib:format("H.13 SUPPORTED. The longer-lived half carries ~s hidden nodes\n"
                  "against ~s in the shorter-lived half, clearing the ~p-fold\n"
                  "response stated before the run. Three worlds of\n"
                  "'expressible and unused' are about the clock, and each should\n"
                  "be re-read as a fact about how long a creature gets rather\n"
                  "than about what it was offered.",
                  [hundredths(Long), hundredths(Short)]);
linked({Short, Long}) ->
    io_lib:format("H.13 REFUTED, and it is withdrawn. The longer-lived half\n"
                  "carries ~s hidden nodes against ~s in the shorter-lived half,\n"
                  "short of the ~p-fold response stated before the run. Something other than the clock is\n"
                  "keeping computation out of these creatures, and Ne is the\n"
                  "remaining candidate: it has never been measured and every\n"
                  "selectability gate has guessed at it.",
                  [hundredths(Long), hundredths(Short), ?RESPONSE]).

advance(W, 0) -> W;
advance(W, Left) ->
    Step = min(500, Left),
    going(world:population(W) > 0, world:tick(W, Step), Left - Step).

going(false, W, _Left) -> W;
going(true, W, Left) -> advance(W, Left).

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

hundredths(V) -> io_lib:format("~w.~2..0w", [V div 100, V rem 100]).

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).
pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) when is_atom(C) -> pad(atom_to_list(C));
pad(C) -> string:pad(lists:flatten(C), 11, trailing).
