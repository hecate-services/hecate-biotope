#!/usr/bin/env escript
%%! -pa _build/default/lib/hecate_biotope/ebin
%% @doc Does perception belong to a PRICE, or to a WAY OF LIFE?
%%
%% WHY THIS EXISTS. World 13 swept the price of neural tissue over five seeds and
%% reported the MEDIAN, which at the control price was 0.00 sensors per creature.
%% The three live islands are running the same physics at the same price and read
%% 1.92, 0.00 and 2.50. A median over five cannot be wrong about its five, so the
%% two readings are not in conflict: the distribution is not unimodal and the
%% median threw away the finding.
%%
%% World 12 already knew the shape and did not connect it to this. It found two
%% stable states from identical rules, a world of many small creatures and a
%% world of few enormous ones, and called that its clearest result. What the
%% fleet adds is that ONE OF THE TWO CAN SEE AND THE OTHER CANNOT.
%%
%% THE MECHANISM UNDER TEST, stated so it can fail. A sensor of reach R costs
%% `10 * (R + 1)' a tick no matter who carries it, and income is bounded by
%% `min(uptake, frame, what is in the cell)', which rises with the body. So the
%% same bill is most of a small creature's surplus and a rounding error to a
%% large one. If that is right, sensors appear where bodies are large and the two
%% columns move together across seeds. If sensors turn up independent of body
%% size, the mechanism is wrong and the fleet reading is something else.
%%
%% NO MEDIANS AND NO SCREENING. Every seed gets a row including the dead ones,
%% because the question is about the shape of the distribution and a summary
%% statistic is what hid it the first time.
-mode(compile).

-define(TICKS, 4000).
-define(SEEDS, 24).

%% The control: worlds 2 to 12 exactly, and what all three islands are running.
-define(NEURAL, 330).

main(_) ->
    io:format("~nticks=~p seeds=~p neural_cost=~p (worlds 2-12), 100% efficiency~n~n",
              [?TICKS, ?SEEDS, ?NEURAL]),
    Rows = in_parallel(fun run/1, lists:seq(1, ?SEEDS)),
    io:format("~s~n", [row(["seed", "pop", "body", "biggest", "store", "sens",
                            "attn", "brain", "still%", "meat%", "depth",
                            "ground"])]),
    Alive = [R || #{population := P} = R <- Rows, P > 0],
    lists:foreach(fun print/1, lists:sort(fun by_body/2, Alive)),
    io:format("~n~p of ~p seeds dead by tick ~p, left out above.~n",
              [?SEEDS - length(Alive), ?SEEDS, ?TICKS]),
    correlate(Alive),
    io:format("~nbody = mean structure. store = mean energy held per creature. "
              "sens and~nbrain are per creature, times a hundred. attn is the "
              "mean weight the brain~nputs on a carried sensor, also times a "
              "hundred: it separates an organ that is~nREAD from one that is "
              "merely paid for.~n").

print(#{seed := Seed, population := Pop} = S) ->
    io:format("~s~n", [row([Seed, Pop, mean(structure_total, S), maps:get(structure_max, S),
                            mean(energy_total, S), maps:get(sensor_mean, S),
                            attention(S), maps:get(hidden_mean, S),
                            maps:get(still_pct, S), maps:get(from_creatures_pct, S),
                            maps:get(depth, S), per_cell(S)])]).

%% MEAN STANDING STOCK PER CELL, which is where the two regimes are supposed to
%% sit either side of a line. Bare ground gains `max(ground_seed, stock * pct)',
%% so below `ground_seed * 100 / pct' a cell is living on the floor and above it
%% on its own compounding. At the configured 12 and 6 that crossover is 200.
per_cell(#{ground_total := G, radius := R}) -> G div cells(R).

cells(R) -> 1 + 3 * R * (R + 1).

%% THE ONE NUMBER THIS IS FOR. Split the seeds at the median body size and report
%% perception either side. If the mechanism holds, the two halves are different
%% worlds; if it does not, they read alike and the fleet needs another
%% explanation.
correlate(Rows) when length(Rows) < 4 ->
    io:format("~nToo few survivors to split.~n");
correlate(Rows) ->
    Sorted = lists:sort(fun by_body/2, Rows),
    {Big, Small} = lists:split(length(Sorted) div 2, Sorted),
    io:format("~n~s~n", [row(["half", "seeds", "body", "sens", "attn", "still%"])]),
    io:format("~s~n", [row(["larger", length(Big) | half(Big)])]),
    io:format("~s~n", [row(["smaller", length(Small) | half(Small)])]).

half(Rows) ->
    [avg([mean(structure_total, R) || R <- Rows]),
     avg([maps:get(sensor_mean, R) || R <- Rows]),
     avg([attention(R) || R <- Rows]),
     avg([maps:get(still_pct, R) || R <- Rows])].

by_body(A, B) -> mean(structure_total, A) >= mean(structure_total, B).

mean(_Key, #{population := 0}) -> 0;
mean(Key, #{population := Pop} = S) -> maps:get(Key, S) div Pop.

%% Averaged over the fields anybody carries, so a world whose creatures all watch
%% the ground is not diluted by three fields nobody has. Zero carriers everywhere
%% is zero, which is the right answer rather than a division by nothing.
attention(#{sensors := Sensors}) ->
    Carried = [F || F <- maps:values(Sensors), maps:get(carriers, F, 0) > 0],
    avg([maps:get(attention, F, 0) || F <- Carried]).

avg([]) -> 0;
avg(L) -> lists:sum(L) div length(L).

run(Seed) ->
    W = world:tick(world:new(#{seed => Seed, population => 40,
                               transfer_efficiency => 100,
                               neural_cost => ?NEURAL}),
                   ?TICKS),
    (world:snapshot(W))#{seed => Seed}.

%%==============================================================================

in_parallel(F, Items) ->
    Parent = self(),
    Refs = [spawn_one(Parent, F, I) || I <- Items],
    [receive {Ref, Result} -> Result end || Ref <- Refs].

spawn_one(Parent, F, Item) ->
    Ref = make_ref(),
    spawn_link(fun() -> Parent ! {Ref, F(Item)} end),
    Ref.

row(Cells) -> lists:flatten([pad(C) || C <- Cells]).

pad(C) when is_integer(C) -> pad(integer_to_list(C));
pad(C) -> string:pad(C, 9, trailing).
