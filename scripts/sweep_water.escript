#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc WORLD 23: HOW MANY HOLES, AND IS IT A PRESSURE OR A SIEVE?
%%
%% Usage:  ./scripts/sweep_water.escript [seeds [ticks]]
%%
%% Breeding requires standing on water. Few big holes concentrate hardest and are
%% furthest away; many small ones are reachable and concentrate least. **That
%% tension is the experiment**, named in `PLAN.md` before any of it was measured,
%% and every value is published.
%%
%% ==========================================================================
%% THE COLUMN THAT DECIDES IT IS `APPROACH`, AND A FILTER IS PREDICTED
%% ==========================================================================
%%
%% Creatures are scattered at random when a world is founded, so the mean
%% distance to the nearest hole AT TICK ZERO is the null. `APPROACH` is how far
%% that distance has fallen by the end, as a percentage.
%%
%%   FALLS   creatures evolved to sense water and go to it. Adaptation.
%%   FLAT    the rule killed whatever was born too far out and selected on
%%           birthplace. **A cull, which would look like a result.**
%%
%% The pre-registration predicts FLAT. At seven holes half the population cannot
%% reach water inside a life at all.
%%
%% ⚠ MEDIANS ARE OVER LIVING WORLDS AND THE DEAD ARE COUNTED SEPARATELY.
%% Commitment 10, added after a median over all seeds read 21 cells where living
%% worlds had reached 76 and nearly confirmed a finding by a factor of five.
-mode(compile).

main(Args) ->
    Seeds = arg(Args, 1, 24),
    Ticks = arg(Args, 2, 8000),
    io:format("~n~p seeds to ~p ticks. World ~p.~n"
              "APPROACH is how much nearer to water the population got than it "
              "was scattered.~nFlat means a cull.~n~n",
              [Seeds, Ticks, maps:get(number, world:ruleset())]),
    io:format("~s~n", [row(["arm", "dead", "pop", "born", "PARCHED%",
                            "at birth", "at end", "APPROACH", "water sens",
                            "NODES min-med-max", "meat%", "depth", "explored",
                            "front"])]),
    %% ⚠ THE CONTROL IS `thirst' AT ZERO, NOT `holes' AT ZERO. With no water
    %% anywhere and the drain running, nothing can ever refill and every creature
    %% dries out: that arm is an extinction, not a baseline. The control has to
    %% be the SAME landscape with the pressure switched off, which is world 22's
    %% physics with water present and inert.
    %%
    %% `I.17' is exactly this mistake made once already: comparing against the
    %% wrong null credits the rule with whatever the world does anyway.
    lists:foreach(fun(A) -> arm(A, Seeds, Ticks) end, arms(Args)),
    io:format("~nwater sens is the share of creatures carrying a sensor for the "
              "water field.~nA cull leaves it at chance; a pressure raises it.~n"
              "Arms marked `ctl' have `thirst' at zero: water is present, "
              "sensible, and harmless.~n").

arg(Args, N, _D) when length(Args) >= N -> list_to_integer(lists:nth(N, Args));
arg(_A, _N, D) -> D.

%% ⚠ THE FULL SWEEP IS THE EXPERIMENT; `narrow' IS FOR POWER AND NOTHING ELSE.
%% A thirst arm leaves three to seven seeds alive out of twenty-four, and the
%% node spread of a CONTROL runs 0.00 to 2.03, so the whole eight-arm table
%% cannot separate a real rise from seed noise however long it runs. `narrow'
%% drops to the control and the three arms that showed the largest response, so
%% the same compute buys many more seeds each.
%%
%% ⚠⚠ AND THAT IS A CHOICE MADE AFTER SEEING THE FIRST TABLE, which is `I.3`'s
%% shape. It is defensible only because the full table is published beside it,
%% the arms were picked for BITE (`parched%') and not for their node figure, and
%% the narrow run can refute the finding as easily as confirm it. Read them
%% together or not at all.
arms(Args) ->
    narrow(lists:member("narrow", Args)).

narrow(true) -> [{61, 0}, {7, dflt}, {19, dflt}, {37, dflt}];
narrow(false) ->
    [{61, 0}, {19, 0},
     {0, dflt}, {1, dflt}, {7, dflt}, {19, dflt}, {37, dflt}, {61, dflt}].

arm({Holes, Thirst}, Seeds, Ticks) ->
    Rows = in_parallel(fun(S) -> run(S, Holes, Thirst, Ticks) end,
                       lists:seq(1, Seeds)),
    Live = [R || #{now := #{population := P}} = R <- Rows, P > 0],
    io:format("~s~n", [row([label(Holes, Thirst), Seeds - length(Live)
                            | summarise(Live)])]).

label(Holes, dflt) -> integer_to_list(Holes);
label(Holes, 0) -> [integer_to_list(Holes), " ctl"].

run(Seed, Holes, Thirst, Ticks) ->
    W = world:new(econ(Holes, Thirst, #{seed => Seed, population => 40})),
    #{was => world:snapshot(W), now => world:snapshot(advance(W, Ticks))}.

%% `dflt' leaves `thirst' out entirely so the arm inherits whatever `world.erl'
%% says. A sweep that named the swept constant's own default would pin it, and
%% commitment 6 forbids a test or a sweep inheriting a value by writing it down.
econ(Holes, dflt, Base) -> Base#{water_holes => Holes};
econ(Holes, Thirst, Base) -> Base#{water_holes => Holes, thirst => Thirst}.

summarise([]) -> lists:duplicate(12, "-");
summarise(Live) ->
    Med = fun(K) -> median([maps:get(K, N) || #{now := N} <- Live]) end,
    Born = Med(born),
    [Med(population), Born, [integer_to_list(parched_pct(Live)), "%"],
     hundredths(median([maps:get(to_water_mean, S) || #{was := S} <- Live])),
     hundredths(Med(to_water_mean)),
     [integer_to_list(approach(Live)), "%"],
     [integer_to_list(sensing(Live)), "%"],
     spread([maps:get(hidden_mean, N) || #{now := N} <- Live]),
     [integer_to_list(Med(from_creatures_pct)), "%"],
     Med(depth), Med(explored), Med(frontier)].

%% ⚠ THE WHOLE RANGE, NOT THE MIDDLE OF IT. A thirst arm has three to seven
%% living seeds where a control has twelve, and `G.10' puts this world's `Ne' at
%% 7.44 with a drift floor of 6.72%. A median over five graveyards' survivors is
%% not a number to hang a finding on without saying how far the seeds disagree,
%% and every one-seed reading this project has trusted has been wrong.
spread([]) -> "-";
spread(Vs) ->
    S = lists:sort(Vs),
    [hundredths(hd(S)), "-", hundredths(median(Vs)), "-",
     hundredths(lists:last(S))].

%% ⚠ THE SHARE OF DEATHS THAT ARE THIRST, and the column that says whether the
%% rule is doing anything at all. `births_dry' stood here and counted births
%% refused for being away from water, which was the WITHDRAWN rule: the script
%% outlived the physics it was written for and crashed on the first arm. That is
%% the stale-instrument hazard the pre-registration keeps a table for, in the one
%% script the pre-registration leans on hardest.
%%
%% Four causes and they are exhaustive: starved, consumed, aged out, parched.
%% Taken per seed and then the median, so one graveyard cannot carry the arm.
parched_pct(Live) ->
    median([of_deaths(maps:get(parched, N), deaths(N)) || #{now := N} <- Live]).

deaths(N) ->
    lists:sum([maps:get(K, N) || K <- [starved, consumed, aged_out, parched]]).

of_deaths(_Part, 0) -> 0;
of_deaths(Part, Whole) -> Part * 100 div Whole.

%% How much nearer the population ended up than it was scattered. Per seed, then
%% the median, so one seed that happened to found itself on a hole cannot carry
%% the arm.
approach(Live) ->
    median([closer(maps:get(to_water_mean, Was), maps:get(to_water_mean, Now))
            || #{was := Was, now := Now} <- Live]).

closer(0, _Now) -> 0;
closer(Was, Now) -> (Was - Now) * 100 div Was.

%% Carriers of a water sensor, out of the population. `body:census/1` reports
%% carriers per field and already existed.
sensing(Live) ->
    median([share(maps:get(water, maps:get(sensors, N), #{}),
                  maps:get(population, N)) || #{now := N} <- Live]).

share(#{carriers := C}, Pop) when Pop > 0 -> C * 100 div Pop;
share(_Absent, _Pop) -> 0.


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
pad(C) -> string:pad(lists:flatten(C), 11, trailing).
