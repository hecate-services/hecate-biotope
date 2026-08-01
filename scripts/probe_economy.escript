#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% Watch the energy economy over time, across several seeds.
%%
%% THIS IS THE INSTRUMENT FOR TUNING THE ECONOMY, and it exists because "the
%% population survived 500 ticks" is a test and not an answer. A run can survive
%% by sitting at the creature cap, by oscillating violently, or by drifting
%% slowly to nothing, and those want three different responses.
%%
%% ==========================================================================
%% TUNE FOR VIABILITY. NEVER FOR AN OUTCOME.
%% ==========================================================================
%%
%% A number in this world may be set by whether the world WORKS:
%%
%%   nothing goes extinct, or extinction is the finding rather than the noise
%%   the population is not pinned against max_creatures
%%   the energy books balance
%%   a sense has something to discriminate, or its organ pays rent for nothing
%%
%% A number may NEVER be set by what EVOLVES in it. "Carnivores appear at this
%% value" is not a reason to choose that value, because the carnivores are the
%% thing being claimed as a discovery. Choosing the rules by the phenotype
%% installs the result and then reports finding it.
%%
%% This rule is written here because this is the file where the mistake gets
%% made. It has been made once already: scent_mutation was set to the value that
%% produced the most carnivores, across five sweeps that all shared that same
%% success criterion, and the number had to be re-derived from a property of the
%% SIGNAL instead. Nothing below privileges one outcome over another, and the
%% summary deliberately reports no headline phenotype at all.
%%
%% Several seeds because one run of a stochastic world tells you about that run.
%% If the seeds disagree about whether anything lives, the economy is on a knife
%% edge and any later result measured in it would be measuring the knife.
%%
%%   scripts/probe_economy.escript                 # defaults, 5 seeds, 2000 ticks
%%   scripts/probe_economy.escript 3000 8          # ticks, seeds
%%   scripts/probe_economy.escript 3000 8 metabolism=2 regrowth_per_tick=6
%%
%% Overrides are `key=integer' and are applied to the economy verbatim, so a
%% typo names a key the world does not have rather than silently doing nothing.

main(Args) ->
    {Ticks, Seeds, Overrides} = parse(Args),
    Econ = maps:merge(world:defaults(), Overrides),
    ok = check_keys(Overrides),
    io:format("~nticks=~p seeds=~p~n", [Ticks, Seeds]),
    io:format("economy: ~p~n~n", [maps:with(maps:keys(Overrides), Econ)]),
    Rows = in_parallel(fun(Seed) -> run(Seed, Ticks, Overrides) end,
                       lists:seq(1, Seeds)),
    report(Rows, Ticks).

%% SEEDS ARE INDEPENDENT, so they run at once. Each is a pure function of its
%% number, sharing no state with any other and reading no clock, so running five
%% together on a machine with cores to spare produces the same five rows in the
%% same order as running them one after another. The results are unchanged; only
%% the waiting is.
%%
%% Order is preserved by collecting on a ref per seed rather than by taking
%% whatever finishes first, because a report whose rows change places between
%% runs cannot be diffed against the last one.
in_parallel(F, Items) ->
    Parent = self(),
    Refs = [spawn_one(Parent, F, I) || I <- Items],
    [receive {Ref, Result} -> Result end || Ref <- Refs].

spawn_one(Parent, F, Item) ->
    Ref = make_ref(),
    spawn_link(fun() -> Parent ! {Ref, F(Item)} end),
    Ref.

parse([]) -> {2000, 5, #{}};
parse([T]) -> {list_to_integer(T), 5, #{}};
parse([T, S | Rest]) ->
    {list_to_integer(T), list_to_integer(S), overrides(Rest, #{})}.

overrides([], Acc) -> Acc;
overrides([KV | Rest], Acc) ->
    [K, V] = string:split(KV, "="),
    overrides(Rest, Acc#{list_to_atom(K) => list_to_integer(V)}).

%% Starting conditions rather than rules. They do not change the physics and do
%% not change the economy fingerprint, so a run using them is the same game from
%% a different opening position, and a result says only what happens FROM THERE.
-define(FOUNDING, [founder_uptake_max]).

%% A key the economy does not have is a typo, and a typo that silently does
%% nothing turns a tuning session into a ghost hunt.
check_keys(Overrides) ->
    Known = maps:keys(world:defaults()) ++ ?FOUNDING,
    case maps:keys(Overrides) -- Known of
        []      -> ok;
        Unknown -> io:format("unknown economy keys: ~p~nknown: ~p~n",
                             [Unknown, lists:sort(Known)]),
                   halt(64)
    end.

%% Sample the trajectory rather than only its end, because a population that
%% ends at 40 having peaked at 900 is not the same animal as one that sat at 40.
run(Seed, Ticks, Overrides) ->
    W0 = world:new(Overrides#{seed => Seed, population => 40}),
    Every = max(1, Ticks div 20),
    {WN, Samples} = sample(W0, Ticks, Every, []),
    Pops = [P || #{population := P} <- Samples],
    #{seed => Seed,
      final => world:snapshot(WN),
      peak => lists:max(Pops),
      trough => lists:min(Pops),
      samples => Samples}.

sample(W, 0, _Every, Acc) -> {W, lists:reverse([world:snapshot(W) | Acc])};
sample(W, Left, Every, Acc) ->
    Step = min(Every, Left),
    sample(world:tick(W, Step), Left - Step, Every,
           [world:snapshot(W) | Acc]).

report(Rows, Ticks) ->
    io:format("~s~n", [row(["seed", "final", "peak", "trough", "ground",
                            "stores", "frames", "born", "starved", "eaten",
                            "aged", "refused"])]),
    lists:foreach(fun print_viability/1, Rows),
    outcomes(Rows),
    census(Rows),
    Finals = [P || #{final := #{population := P}} <- Rows],
    Extinct = length([P || P <- Finals, P =:= 0]),
    io:format("~n~p/~p seeds extinct after ~p ticks~n",
              [Extinct, length(Rows), Ticks]),
    io:format("final population: min ~p median ~p max ~p~n",
              [lists:min(Finals), median(Finals), lists:max(Finals)]),
    shapes(Rows),
    trajectory(hd(Rows)).

%% THE SHAPE OF THE FRAMES, eight buckets from nothing to the largest alive.
%%
%% A MAXIMUM CANNOT ANSWER THE QUESTION WORLD 6 ASKED. "Store and structure
%% diverge" means lineages that carry much and build little, or the reverse, and
%% a single largest tells you nothing about whether the population sits at one
%% size or at several. Everything in one bucket is one size; weight at both ends
%% is two livings.
shapes(Rows) ->
    io:format("~nframe sizes, smallest bucket first (~p buckets to the largest "
              "alive)~n", [8]),
    lists:foreach(fun(#{seed := S, final := #{structure_hist := H,
                                              structure_max := Max}}) ->
                          io:format("seed ~p  max ~p  ~p~n", [S, Max, H])
                  end, Rows).

%% VIABILITY ONLY. Whether the world works, which is the only thing a number may
%% ever be tuned against.
print_viability(#{seed := S, peak := Pk, trough := Tr,
                  final := #{population := P, ground_total := G, born := B,
                             energy_total := Stores, structure_total := Frames,
                             starved := St, consumed := C, aged_out := Ag,
                             births_refused := Rf}}) ->
    io:format("~s~n",
              [row([S, P, Pk, Tr, G, Stores, Frames, B, St, C, Ag, Rf])]).

%% WHAT THE POPULATION TURNED OUT TO BE. Everything that varies, side by side,
%% with NONE OF IT PRIVILEGED: no headline metric and no summary line that picks
%% a winner. A probe that reports one number at the top is a probe that will be
%% run until that number moves, and this project has already made that mistake.
%%
%% `eats' is the population's mean feeding rate, which is world 4's axis. Below
%% what a cell sustains, a lineage holds its ground for good; above it, the cell
%% is stripped and its income collapses to the bare floor. Nothing calls either of
%% those prudence or greed.
%%
%% `store' and `frame' are the largest reserve and the largest BODY alive, and
%% they are two columns rather than one on purpose: world 6 exists to separate
%% them, so adding them together here would report exactly the conflation the
%% world was built to undo. `frame' is what upkeep is charged on and what wins a
%% contest; `store' is nearly free to hold and useless in a fight.
%%
%% THIS TABLE HAS NOW FORGOTTEN AN OBSERVABLE THREE TIMES: the feeding rate,
%% then size, then structure, each time after it was added to the world and
%% before the run that needed it. The failure is always the same shape, so the
%% check is: when a snapshot grows a field, this row grows with it in the same
%% commit or the run measures nothing.
%%
%% `still' is the plant-ness of the population and nothing in the rules calls it
%% that: there are no plants, so a creature that stays where it is and lives off
%% what gathers there simply is one. `gspr' is the share of ground energy in the
%% richest tenth of cells, where ten is flat and above it the landscape has
%% structure that nobody installed. `move' and `bred' are how many creatures can
%% do those things AT ALL, since an absent output is not a weak one.
outcomes(Rows) ->
    io:format("~n~s~n", [row(["seed", "still%", "eats", "store", "frame",
                              "meat%", "meat#", "body", "brain", "move", "bred",
                              "gspr", "tags", "sspr"])]),
    lists:foreach(fun print_outcome/1, Rows).

print_outcome(#{seed := S,
                final := #{still_pct := Still, from_creatures_pct := Meat,
                           sensor_mean := Body, hidden_mean := Brain,
                           fed_by_creatures := MeatN,
                           uptake_mean := Eats, energy_max := Store,
                           structure_max := Frame,
                           movers := Movers, breeders := Breeders,
                           ground_spread := GSpread, scent_tags := Tags,
                           scent_spread := SSpread}}) ->
    io:format("~s~n", [row([S, Still, Eats, Store, Frame, Meat, MeatN, Body,
                            Brain, Movers, Breeders, GSpread, Tags,
                            SSpread])]).

%% WHAT THEY MEASURE, AND WHETHER ANYTHING ACTS ON IT. Carriers then attention,
%% per field, because CARRYING A SENSOR AND USING ONE ARE DIFFERENT THINGS: a
%% creature can pay rent every tick for a measurement nothing in its brain
%% weights, and carriers alone would report that as perception.
census(Rows) ->
    io:format("~n~s~n", [row(["seed", "grnd", "grnd:a", "crea", "crea:a",
                              "scnt", "scnt:a", "self", "self:a"])]),
    lists:foreach(fun print_census/1, Rows).

print_census(#{seed := S, final := #{sensors := Sensors}}) ->
    Cell = fun(F, K) -> maps:get(K, maps:get(F, Sensors, #{}), 0) end,
    io:format("~s~n",
              [row([S,
                    Cell(ground, carriers), Cell(ground, attention),
                    Cell(creatures, carriers), Cell(creatures, attention),
                    Cell(scent, carriers), Cell(scent, attention),
                    Cell(self, carriers), Cell(self, attention)])]).

%% Columns padded by hand. A negative field width on ~p is not accepted, and the
%% failure is a bare "failed to format string" that names no column.
row(Cells) -> [pad(C) || C <- Cells].

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(C, 9, trailing).

%% One seed's shape in full, because the summary above can hide an oscillation.
trajectory(#{seed := S, samples := Samples}) ->
    io:format("~nseed ~p trajectory (tick: population/ground)~n", [S]),
    Line = [io_lib:format("~p:~p/~p  ", [T, P, Pl])
            || #{tick := T, population := P, ground_total := Pl} <- Samples],
    io:format("~s~n", [Line]).

median(L) ->
    Sorted = lists:sort(L),
    lists:nth(max(1, length(Sorted) div 2), Sorted).
