%% @doc The thing that decides. PURE, INTEGER, and now with somewhere to think.
%%
%% A BRAIN PUTS A VALUE ON A PLACE and decides whether to spend itself on a
%% child. It does not choose between named actions, because there are none:
%% going where ground energy is IS grazing, going where creature energy is IS
%% predation, avoiding it IS fleeing, and staying put IS being a plant. None of
%% those words appear anywhere in this code.
%%
%% ==========================================================================
%% WHY THERE IS A HIDDEN LAYER, WHICH WORLD 1 DID NOT HAVE
%% ==========================================================================
%%
%% Own energy is the same number for all seven cells a creature can reach. In a
%% single linear layer it adds equally to every option and CANCELS IN THE
%% COMPARISON, so a linear brain cannot act on self-knowledge at all, however
%% much it has. World 1 therefore had no proprioception and would have gained
%% nothing from any, and this is not a matter of degree: the two are worth
%% nothing apart and something together.
%%
%% A hidden node fixes it by combining a constant with something that varies. Once
%% `self' can be multiplied against what is in a cell, "go where the flesh is, but
%% only while I am the larger" becomes expressible, and that sentence is the
%% difference between predation as a strategy and predation as weather.
%%
%% RECTIFICATION, `max(0, x)', IS THE ONLY NONLINEARITY. Integer, monotone but
%% not linear, and it needs no libm. That keeps a run bit-identical from its seed,
%% which is what lets thousands of ticks be probed offline, and that property has
%% already saved this project a fortnight of work built on a trait that turned out
%% not to move. It is not being traded for a smoother curve that would change the
%% numbers and not the decisions.
%%
%% ==========================================================================
%% THE STRUCTURE, AND THE ONE BUG HERE THAT DOES NOT CRASH
%% ==========================================================================
%%
%% Inputs are the sensor readings, then `here': a 1 for the cell the creature
%% already occupies and 0 for the other six. That replaces world 1's special
%% staying-weight with an ordinary input, so nothing is special-cased, and it is
%% why staying put is expressible at all: movement costs and standing still does
%% not, so a creature that cannot tell where it already is cannot be sedentary on
%% purpose.
%%
%% Every hidden node holds one weight per input. Every output holds one weight per
%% input AND one per hidden node. So a single added sensor must insert a column
%% into every hidden node and every output, and an added hidden node must append a
%% column to every output.
%%
%% GET ANY OF THAT WRONG AND NOTHING CRASHES. The vectors still have plausible
%% lengths, every weight after the insertion point simply reads a different
%% measurement, and the creature behaves like a garbled version of its parent for
%% reasons no test would name. This is the main engineering risk in world 2 and
%% the reason the shape after every kind of change is asserted directly.
-module(brain).

-export([founder/3, inherit/5, evaluate/4, attention/2]).
-export([purposes/0, hidden_count/1, hidden_weights/1, has/2, width/2]).
-export([row_width/2, recall/3]).
-export([output_weights/1, carried/1, live/1, live_per_node/1]).

-type purpose() :: move | breed | grow.
-type output() :: #{inputs := [integer()], hidden := [integer()]}.
-type brain() :: #{hidden := [[integer()]], outputs := #{purpose() => output()}}.
-export_type([purpose/0, brain/0]).

%% What a creature can do. THREE SINCE WORLD 6, and the third arrived because
%% splitting the store from the structure forces a rule for how one becomes the
%% other. "A creature grows when it has a surplus" would be biology written into
%% the physics, the exact shape of the deleted `breed_at'. An output is the same
%% treatment reproduction already gets and is more general: a lineage can evolve
%% to build when it is safe and hoard when it is not.
%%
%% `grow' IS READ AS A QUANTITY rather than a threshold, clamped to what the
%% creature is carrying, so it needs no constant of its own.
%% `eat' JOINED IN WORLD 15 and it is the first purpose that can be REFUSED to
%% the creature: `move', `breed' and `grow' are always available and this one
%% needs an organ. A brain that says eat while carrying no mouth says nothing,
%% exactly as a weight on a sensor a body does not have would.
-define(PURPOSES, [move, breed, grow, eat]).

%% What a hidden node's total is divided by before it is read as a reading.
%% Inputs run to sixty-odd and weights to eight, so a raw total runs to hundreds
%% and would swamp every direct input weight in the outputs. Dividing by the
%% weight range brings a node back into the range of the things it summarises, so
%% an output can weigh a hidden node against a sensor without either drowning the
%% other. A scale constant, and there is no physics that sets it.
-define(HIDDEN_DIVISOR, 8).

-spec purposes() -> [purpose()].
purposes() -> ?PURPOSES.

-spec hidden_count(brain()) -> non_neg_integer().
hidden_count(#{hidden := H}) -> length(H).

%% @doc HOW MUCH WIRE THE HIDDEN LAYER IS, which is what world 16 charges for.
%%
%% `hidden_count/1' counts NODES and is what the census reports, because "how
%% many hidden nodes" is a fact about shape. This counts WEIGHTS, because a node
%% wired to six inputs is six times the apparatus of one wired to a single input
%% and until world 16 they cost the same. `B.3' objected to that and world 13
%% marked it corrected while changing only how the charge was levied.
%%
%% The two must stay separate: charging by weights and reporting by nodes is the
%% whole point, since a brain getting cheaper and a brain getting simpler look
%% identical if you only have one of the numbers.
%% ⚠ WORLD 19: A WEIGHT COSTS ONLY IF IT IS NON-ZERO, and that one word is the
%% whole world. `dot/2` multiplies by it, so a weight of zero contributes exactly
%% zero and a creature behaves identically with or without it. Charging for it
%% was charging for something that does nothing.
%%
%% IT MAKES WIDTH A TRAIT, which is `H.11`: a row is `sensors + 1` long by
%% construction and every structural mutation preserves that, so until now the
%% only way to make a node cheaper was to drop a sensor. World 16 charged a node
%% by its wiring in order to select for narrower brains and got wider ones, for
%% exactly this reason.
%%
%% NO NEW MUTATION OPERATOR. Silencing is what the existing weight drift already
%% does and nothing has ever paid it for doing so: censused before the change,
%% 3.4% to 15.2% of all weights were already exactly zero with no incentive at
%% all. NEAT needs innovation numbers to align genomes for crossover; this world
%% reproduces clonally, so none of that is required.
-spec hidden_weights(brain()) -> non_neg_integer().
hidden_weights(#{hidden := H}) -> lists:sum([live(V) || V <- H]).

%% @doc How many of these weights do anything. Exported to be tested, because
%% "you pay for what you use" is the entire claim of world 19 and it is one
%% predicate away from being false.
-spec live([integer()]) -> non_neg_integer().
live(Row) -> length([W || W <- Row, W =/= 0]).

%% @doc How much wiring the OUTPUTS are, which world 18 charges for.
%%
%% The same shape `hidden_weights/1' has, and for the same reason: a vector's
%% cost is what it reads. An output reads every input and every hidden node, so
%% it is `sensors + 1 + hidden' wide.
%%
%% ⚠ WIDTH IS NOT A TRAIT AND THIS CANNOT SELECT FOR NARROW OUTPUTS, exactly as
%% `H.11' found for hidden nodes. What a creature CAN vary is how many purposes
%% it carries, through `toggle/4'. World 18 is about that count and says so in
%% its pre-registration rather than discovering it afterwards.
%%
%% Order-free: a sum over `maps:values' cannot depend on the order it gets them
%% in, which after `G.6' is worth stating rather than assuming.
-spec output_weights(brain()) -> non_neg_integer().
%% WORLD 19 APPLIES AT EVERY SITE, not only to hidden rows. An output's silent
%% weight is as free to compute as a hidden node's, and pricing one and not the
%% other would be a law applied at one site, which is the shape `C.6`, `B.7` and
%% `B.8` all were.
output_weights(#{outputs := Os}) ->
    lists:sum([live(I) + live(H)
               || #{inputs := I, hidden := H} <- maps:values(Os)]).

%% @doc Which purposes this brain has at all, sorted.
%%
%% SORTED, so a census cannot depend on map order. The purposes are atoms and
%% `G.6' was atom-keyed map iteration reaching the generator; nothing here
%% reaches the generator, and the habit is cheaper than the audit.
%% @doc How wide the hidden nodes actually are, in live weights, times a hundred.
%% THE INSTRUMENT WORLD 19 IS ABOUT, and it did not exist: `H.11` says a narrow
%% brain is inexpressible, so nothing has ever needed to measure narrowness.
%% Zero when there are no hidden nodes, which is not the same as narrow and the
%% census must not confuse them.
-spec live_per_node(brain()) -> non_neg_integer().
live_per_node(#{hidden := []}) -> 0;
live_per_node(#{hidden := H}) ->
    lists:sum([live(V) || V <- H]) * 100 div length(H).

-spec carried(brain()) -> [purpose()].
carried(#{outputs := Os}) -> lists:sort(maps:keys(Os)).

-spec has(purpose(), brain()) -> boolean().
has(Purpose, #{outputs := Os}) -> maps:is_key(Purpose, Os).

%% @doc How many weights a vector over this many sensors needs: one each, and one
%% for `here'.
-spec width(non_neg_integer(), inputs | non_neg_integer()) -> pos_integer().
width(Sensors, inputs) -> Sensors + 1;
width(_Sensors, Hidden) -> Hidden.

%% @doc How wide a HIDDEN row is, which is no longer the same as how wide an
%% output's input vector is.
%%
%% ==========================================================================
%% WORLD 21: A HIDDEN NODE READS WHAT THE HIDDEN LAYER SAID LAST TICK
%% ==========================================================================
%%
%% Layout is `[s1..sN, here, m1..mH]': the sensors, the here-flag, and then one
%% weight per hidden node for what that node computed on the PREVIOUS tick.
%%
%% THAT IS THE WHOLE OF MEMORY AND IT NEEDED NO NEW CONSTANT. The state a
%% creature carries is exactly the activations it just produced, so the size of
%% its memory is the size of its brain, and a creature with no hidden layer
%% carries none and behaves EXACTLY as it did in world 20. Memory and
%% computation are worth nothing apart and something together, which is the same
%% shape as world 2's argument for proprioception and nonlinearity.
%%
%% WHY IT MATTERS MORE THAN ANY PRICE THIS PROJECT HAS SWEPT. Twenty worlds
%% evaluated a brain as a pure function of the current instant. Every strategy of
%% the form "I have been hungry for a while", "I came from over there", "that
%% patch was better than this one" was not unevolved, it was INEXPRESSIBLE. No
%% constant could have made one appear.
%%
%% Outputs deliberately do NOT read memory. They read the inputs and the hidden
%% layer, so what a creature remembers can only reach its behaviour by being
%% computed with, which keeps the claim sharp: memory requires a brain.
-spec row_width(non_neg_integer(), non_neg_integer()) -> pos_integer().
row_width(Sensors, Hidden) -> Sensors + 1 + Hidden.

%%==============================================================================
%% Founding
%%==============================================================================

%% @doc A founding brain: random weights, a random number of hidden nodes, and a
%% random subset of the things it could do.
%%
%% RANDOM RATHER THAN ZERO, and a SUBSET rather than all. A population of zeroed
%% brains values every cell alike and wanders until mutation breaks the tie,
%% wasting the early ticks. Founders drawn this way already contain creatures
%% drawn to ground, drawn to flesh, repelled by both, disinclined to move, and
%% some that cannot reproduce at all, so selection has something to sort from the
%% first tick rather than waiting for mutation to invent variety.
-spec founder(non_neg_integer(), map(), rand:state()) -> {brain(), rand:state()}.
founder(Sensors, Econ, Rng0) ->
    {N, Rng1} = rand:uniform_s(maps:get(founder_max_hidden, Econ) + 1, Rng0),
    {Hidden, Rng2} = draw_rows(N - 1, row_width(Sensors, N - 1), Econ, Rng1,
                               []),
    {Outputs, Rng3} = draw_outputs(?PURPOSES, Sensors, length(Hidden), Econ,
                                   Rng2, #{}),
    {#{hidden => Hidden, outputs => Outputs}, Rng3}.

draw_rows(0, _Width, _Econ, Rng, Acc) -> {Acc, Rng};
draw_rows(N, Width, Econ, Rng0, Acc) ->
    {Row, Rng1} = draw_row(Width, Econ, Rng0),
    draw_rows(N - 1, Width, Econ, Rng1, [Row | Acc]).

draw_row(Width, Econ, Rng0) ->
    Range = maps:get(brain_range, Econ),
    lists:mapfoldl(fun(_I, R) -> draw(Range, R) end, Rng0, lists:seq(1, Width)).

draw(Range, Rng0) ->
    {N, Rng1} = rand:uniform_s(2 * Range + 1, Rng0),
    {N - Range - 1, Rng1}.

draw_outputs([], _Sensors, _Hidden, _Econ, Rng, Acc) -> {Acc, Rng};
draw_outputs([P | Rest], Sensors, Hidden, Econ, Rng0, Acc) ->
    {Coin, Rng1} = rand:uniform_s(2, Rng0),
    {Acc1, Rng2} = maybe_output(Coin, P, Sensors, Hidden, Econ, Rng1, Acc),
    draw_outputs(Rest, Sensors, Hidden, Econ, Rng2, Acc1).

maybe_output(2, _P, _Sensors, _Hidden, _Econ, Rng, Acc) ->
    {Acc, Rng};
maybe_output(1, P, Sensors, Hidden, Econ, Rng0, Acc) ->
    {Ins, Rng1} = draw_row(width(Sensors, inputs), Econ, Rng0),
    {Hids, Rng2} = draw_row(Hidden, Econ, Rng1),
    {Acc#{P => #{inputs => Ins, hidden => Hids}}, Rng2}.

%%==============================================================================
%% Deciding
%%==============================================================================

%% @doc What this creature makes of one place: every output it has, for these
%% readings.
%%
%% The hidden layer is computed ONCE and shared by every output, which is not an
%% optimisation so much as the difference between this world running and not: it
%% is evaluated for seven candidate cells per creature per tick, and a board that
%% can hold a forest holds a great many creatures.
%% ⚠ EVALUATION IS STILL A PURE READ AND MUST STAY ONE. A brain is evaluated
%% about eleven times per creature per tick, seven of them for cells the creature
%% is only CONSIDERING stepping into. If evaluating updated the memory, then
%% asking "what do I make of that cell?" would change the creature, and the order
%% the seven candidates happened to be considered in would decide what it
%% remembered. So memory is READ here and WRITTEN once a tick, by `recall/3',
%% from where the creature actually stands.
-spec evaluate(brain(), [integer()], [integer()], map()) ->
          #{purpose() => integer()}.
evaluate(#{hidden := Hidden, outputs := Outputs}, Inputs, Memory, _Econ) ->
    Acts = [activate(Row, Inputs ++ Memory) || Row <- Hidden],
    maps:map(fun(_P, O) -> fire(O, Inputs, Acts) end, Outputs).

%% @doc What this creature will carry into the next tick: what its hidden layer
%% made of where it is standing now.
%%
%% ONCE PER TICK, AT ONE DEFINED PLACE. Everything else about a tick is a
%% question put to the brain; this is the only answer it keeps.
-spec recall(brain(), [integer()], [integer()]) -> [integer()].
recall(#{hidden := Hidden}, Inputs, Memory) ->
    [activate(Row, Inputs ++ Memory) || Row <- Hidden].

%% Rectified, then held to the range of an ordinary reading so an output can
%% weigh a hidden node against a sensor without either drowning the other.
activate(Row, Inputs) ->
    max(0, min(body:reading_ceiling(), dot(Row, Inputs) div ?HIDDEN_DIVISOR)).

fire(#{inputs := WI, hidden := WH}, Inputs, Acts) ->
    dot(WI, Inputs) + dot(WH, Acts).

dot(Weights, Values) ->
    lists:sum([W * V || {W, V} <- lists:zip(Weights, Values)]).

%% @doc How much total weight each input column carries, across every vector that
%% reads it.
%%
%% A sensor's input is read by every hidden node and by every output, so what it
%% is WORTH to a creature is the sum of what all of them put on it. Zero means
%% the measurement is taken, paid for, and acted on by nothing.
-spec attention(brain(), non_neg_integer()) -> [non_neg_integer()].
attention(#{hidden := Hidden, outputs := Outputs}, Inputs) ->
    Vectors = Hidden ++ [maps:get(inputs, O) || O <- maps:values(Outputs)],
    [column(I, Vectors) || I <- lists:seq(1, Inputs)].

column(I, Vectors) ->
    lists:sum([abs(lists:nth(I, V)) || V <- Vectors, length(V) >= I]).

%%==============================================================================
%% Inheriting
%%==============================================================================

%% @doc A child's brain: its parent's, restructured to match its body, mutated in
%% its own topology, then every weight nudged.
%%
%% THE BODY'S CHANGE IS APPLIED FIRST AND MUST MATCH IT EXACTLY, or every weight
%% past the change point silently reads a different measurement.
%% ⚠ THE SENSOR COUNT IS PASSED IN AND NOT RECOVERED, which it used to be.
%%
%% `inputs_of/1' read the width off the brain's first hidden row, or off any
%% output if there were no hidden rows, **and returned 0 when there was neither**.
%% A brain with no hidden layer and no outputs at all has no shape to recover a
%% shape from, and its comment claimed the opposite: "recovered from the brain's
%% own shape rather than passed in, so it cannot disagree with what the vectors
%% actually are."
%%
%% Then growing a hidden node made a row one weight wide for a creature with
%% three sensors, and the next tick crashed in `dot/2' on lists of different
%% lengths. **The one misalignment in this file that DOES crash**, which is why
%% it was found at all.
%%
%% It has been reachable since world 6, when losing an output became possible:
%% a lineage that shed all four purposes and had no hidden node was one grow away
%% from it. Nothing ever hit it because shedding four outputs takes four separate
%% mutations. World 20 made it common, because a child can fail to inherit all
%% four in a single birth, and that is how it surfaced.
-spec inherit(brain(), none | {added, pos_integer()} | {dropped, pos_integer()},
              non_neg_integer(), map(), rand:state()) -> {brain(), rand:state()}.
inherit(Brain, SensorChange, Sensors, Econ, Rng0) ->
    Followed = follow_body(SensorChange, Brain),
    {Grown, Rng1} = mutate_topology(Followed, Sensors, Econ, Rng0),
    nudge_all(Grown, Econ, Rng1).

%% A GAINED SENSOR ARRIVES WEIGHTED AT ZERO in every vector that reads it, rather
%% than randomly. A random weight makes growing a sensor a large behavioural jump
%% in an arbitrary direction, which is resampling and not inheritance. At zero the
%% child begins by ignoring what it can newly perceive and drift decides over
%% generations whether to attend to it, which is the difference between an organ
%% appearing and an organ being adopted.
follow_body(none, Brain) ->
    Brain;
follow_body({added, Pos}, #{hidden := H, outputs := Os} = Brain) ->
    Brain#{hidden => [insert(Pos, 0, Row) || Row <- H],
           outputs => maps:map(fun(_P, O) -> on_inputs(O, Pos, insert) end, Os)};
follow_body({dropped, Pos}, #{hidden := H, outputs := Os} = Brain) ->
    Brain#{hidden => [remove(Pos, Row) || Row <- H],
           outputs => maps:map(fun(_P, O) -> on_inputs(O, Pos, remove) end, Os)}.

on_inputs(#{inputs := Ins} = O, Pos, insert) -> O#{inputs => insert(Pos, 0, Ins)};
on_inputs(#{inputs := Ins} = O, Pos, remove) -> O#{inputs => remove(Pos, Ins)}.

insert(Pos, Value, List) ->
    {Before, After} = lists:split(Pos - 1, List),
    Before ++ [Value | After].

remove(Pos, List) ->
    {Before, [_Gone | After]} = lists:split(Pos - 1, List),
    Before ++ After.

%% One structural change to the brain's own shape per birth, at the same rate the
%% body changes: grow a hidden node, prune one, or gain or lose the ability to do
%% something at all.
mutate_topology(Brain, Sensors, Econ, Rng0) ->
    {Roll, Rng1} = rand:uniform_s(max(1, maps:get(brain_mutation_structural,
                                                  Econ)), Rng0),
    topology(Roll, Brain, Sensors, Econ, Rng1).

topology(1, Brain, Sensors, Econ, Rng0) ->
    {Kind, Rng1} = rand:uniform_s(3, Rng0),
    restructure(Kind, Brain, Sensors, Econ, Rng1);
topology(_NoMutation, Brain, _Sensors, _Econ, Rng) ->
    {Brain, Rng}.

%% A NEW HIDDEN NODE COMPUTES SOMETHING AND NOTHING LISTENS TO IT. Its own input
%% weights are drawn, so it is not inert, but every output weighs it at zero, so
%% the creature behaves exactly as its parent did until drift connects it. Same
%% argument as a new sensor: the capacity appears first and is adopted later, or
%% never.
restructure(1, #{hidden := H, outputs := Os} = Brain, Sensors, Econ, Rng0) ->
    grow_hidden(length(H) < maps:get(max_hidden, Econ), Brain, H, Os, Sensors,
                Econ, Rng0);
restructure(2, #{hidden := []} = Brain, _Sensors, _Econ, Rng) ->
    {Brain, Rng};
%% ⚠ PRUNING A NODE REMOVES IT FROM THREE PLACES, not two. Its row goes, every
%% output's weight for it goes, and since world 21 every REMAINING ROW's memory
%% weight for it goes too. Miss the third and every recurrent weight after the
%% pruned node reads a different node, silently.
restructure(2, #{hidden := H, outputs := Os} = Brain, Sensors, _Econ, Rng0) ->
    {N, Rng1} = rand:uniform_s(length(H), Rng0),
    Kept = [remove(Sensors + 1 + N, Row) || Row <- remove(N, H)],
    {Brain#{hidden => Kept,
            outputs => maps:map(fun(_P, O) -> on_hidden(O, N) end, Os)}, Rng1};
restructure(3, Brain, Sensors, Econ, Rng0) ->
    {N, Rng1} = rand:uniform_s(length(?PURPOSES), Rng0),
    toggle(lists:nth(N, ?PURPOSES), Brain, Sensors, Econ, Rng1).

grow_hidden(false, Brain, _H, _Os, _Sensors, _Econ, Rng) ->
    {Brain, Rng};
grow_hidden(true, Brain, H, Os, Sensors, Econ, Rng0) ->
    %% EVERY EXISTING NODE GAINS A ZERO for the new one, so nothing already in the
    %% brain listens to it until drift connects them: the same rule as a new
    %% sensor and a new node's outgoing weights. The new node's OWN weights are
    %% drawn, including what it makes of the rest of the layer, so it is not
    %% inert.
    Deaf = [Row0 ++ [0] || Row0 <- H],
    {Row, Rng1} = draw_row(row_width(Sensors, length(H) + 1), Econ, Rng0),
    {Brain#{hidden => Deaf ++ [Row],
            outputs => maps:map(fun(_P, O) -> listen_to_nothing(O) end, Os)},
     Rng1}.

listen_to_nothing(#{hidden := WH} = O) -> O#{hidden => WH ++ [0]}.

on_hidden(#{hidden := WH} = O, N) -> O#{hidden => remove(N, WH)}.

%% LOSING AN OUTPUT IS SURVIVABLE AND USUALLY TERRIBLE, which is the point. A
%% creature with no `move' never moves, and in this world that is a living rather
%% than a death sentence: it takes what gathers where it stands. One with no
%% `breed' leaves no descendants, so its lineage ends there, which is simply very
%% strong selection rather than a rule against it.
toggle(Purpose, #{outputs := Os} = Brain, Sensors, Econ, Rng0) ->
    flip(maps:is_key(Purpose, Os), Purpose, Brain, Sensors, Econ, Rng0).

flip(true, Purpose, #{outputs := Os} = Brain, _Sensors, _Econ, Rng) ->
    {Brain#{outputs => maps:remove(Purpose, Os)}, Rng};
flip(false, Purpose, #{hidden := H, outputs := Os} = Brain, Sensors, Econ,
     Rng0) ->
    {Ins, Rng1} = draw_row(width(Sensors, inputs), Econ, Rng0),
    {Hids, Rng2} = draw_row(length(H), Econ, Rng1),
    {Brain#{outputs => Os#{Purpose => #{inputs => Ins, hidden => Hids}}}, Rng2}.

%% Every weight, by a small symmetric step. Small and everywhere makes a lineage
%% DRIFT through strategy space so intermediate forms exist and selection has a
%% gradient to climb; large and rare makes children unrelated to their parents,
%% which is resampling. Symmetric so nothing pushes weights anywhere on its own.
%% ⚠ SORTED, AND THE SORT IS THE DIFFERENCE BETWEEN ONE SEED AND ONE WORLD.
%% `nudge_outputs' draws a random number per weight and threads the generator
%% through the outputs IN THE ORDER IT IS GIVEN THEM. `maps:to_list' on a map
%% keyed by purpose ATOMS does not promise an order, and the order it happens to
%% give depends on VM-global state rather than on anything in this world: running
%% `brain_tests' first was enough to change a world's energy at TICK ONE, from
%% 14,588 to 14,590, on the same seed with the same beams and the same economy.
%%
%% So a world was a pure function of its seed AND of what the VM had loaded,
%% which is not a pure function of its seed. It held for all seventeen worlds.
%% `same_seed_same_world.escript' reported "repeatable: yes" throughout because
%% it compares two runs INSIDE ONE VM, where the atom table is already fixed.
%%
%% Sorting makes the order a property of the purposes themselves. Register `G.6'.
nudge_all(#{hidden := H, outputs := Os} = Brain, Econ, Rng0) ->
    {Hidden, Rng1} = lists:mapfoldl(fun(Row, R) -> nudge_row(Row, Econ, R) end,
                                    Rng0, H),
    {Outputs, Rng2} = nudge_outputs(lists:sort(maps:to_list(Os)), Econ, Rng1,
                                    #{}),
    {Brain#{hidden => Hidden, outputs => Outputs}, Rng2}.

nudge_outputs([], _Econ, Rng, Acc) -> {Acc, Rng};
nudge_outputs([{P, #{inputs := Ins, hidden := Hids}} | Rest], Econ, Rng0, Acc) ->
    {Ins1, Rng1} = nudge_row(Ins, Econ, Rng0),
    {Hids1, Rng2} = nudge_row(Hids, Econ, Rng1),
    nudge_outputs(Rest, Econ, Rng2, Acc#{P => #{inputs => Ins1,
                                                hidden => Hids1}}).

nudge_row(Row, Econ, Rng0) ->
    Mut = maps:get(brain_mutation, Econ),
    Range = maps:get(brain_range, Econ),
    lists:mapfoldl(fun(W, R) -> nudge(W, Mut, Range, R) end, Rng0, Row).

nudge(W, 0, _Range, Rng) -> {W, Rng};
nudge(W, Mut, Range, Rng0) ->
    {Step, Rng1} = rand:uniform_s(2 * Mut + 1, Rng0),
    {clamp(W + Step - Mut - 1, Range), Rng1}.

%% Bounded, so a long lineage cannot drift to weights that swamp every
%% measurement and turn the brain back into a constant that ignores the world.
clamp(W, Range) -> max(-Range, min(Range, W)).
