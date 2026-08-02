%% @doc The numbers beside the picture. Pure: snapshot and status in, HTML out.
%%
%% WHAT AN OWNER NEEDS TO KNOW IS NOT WHAT A RESEARCHER NEEDS TO KNOW, and this
%% is the owner's page. It leads with whether the island is alive and whether
%% anyone can hear it, because those are the two things that can be WRONG on a
%% stranger's machine. The census comes after, and the physics after that.
%%
%% EVERY NUMBER HERE IS ALSO ON THE MESH. Nothing is computed for the browser
%% that a spectator could not derive from public facts, so this page cannot
%% become a second, privileged view that disagrees with the published one.
-module(island_vitals).

-export([html/3, deaths/1]).

-spec html(map(), map(), map()) -> iodata().
html(Snap, Pace, Status) ->
    [alive(Snap, Status), door(Status), census(Snap), physics(Snap, Pace)].

%% ==========================================================================
%% IS IT ALIVE
%% ==========================================================================
%%
%% AN ENDED WORLD IS A RESULT AND SAYS SO. Most seeds die in this world, the
%% island begins a fresh run when one does, and a page that quietly showed the
%% new world would hide the single most common thing that happens here.
alive(#{population := 0, extinct_at := At}, #{run := Run}) ->
    [<<"<section class=\"card dead\"><h2>This world has ended</h2><p>Run ">>,
     num(Run), <<" went extinct at tick ">>, num(At),
     <<". The island will begin another shortly, and this one stays ended: "
       "nothing reseeds a world.</p></section>">>];
alive(#{population := Pop, tick := Tick, seed := Seed} = Snap,
      #{run := Run, rejected := Rejected}) ->
    [<<"<section class=\"card\"><h2>Alive</h2><dl>">>,
     item(<<"creatures">>, num(Pop)),
     item(<<"tick">>, num(Tick)),
     item(<<"run">>, num(Run)),
     item(<<"seed">>, num(Seed)),
     item(<<"deepest lineage">>, num(maps:get(depth, Snap, 0))),
     <<"</dl><p class=\"note\">Seed ">>, num(Seed),
     <<" is the whole of this world: anyone can replay it exactly. ">>,
     screened(Rejected), <<"</p></section>">>].

%% A SCREENED FLEET IS A BIASED SAMPLE AND SAYING SO IS THE DIFFERENCE BETWEEN
%% HONEST AND NOT. The island draws candidate seeds and keeps the first still
%% alive at the horizon, so the worlds shown here are not a fair draw from the
%% seed space and the page states the count rather than burying it.
screened(0) ->
    <<"The first seed drawn was viable.">>;
screened(N) ->
    [num(N), <<" earlier seeds were drawn and found dead before this one, so "
               "what you are watching is a SCREENED world and not a fair "
               "draw.">>].

%% ==========================================================================
%% CAN ANYONE HEAR IT
%% ==========================================================================
%%
%% A DARK MESH IS NOT A FAULT and the page must not present it as one. An island
%% whose neighbours are unreachable is still an island and its creatures carry on
%% living, eating and dying. The only thing lost is that nobody hears about it,
%% which is exactly what this says.
door(#{published := Sent, publish_errors := Failed, station := Station}) ->
    [<<"<section class=\"card\"><h2>The door</h2><dl>">>,
     item(<<"station">>, station_name(Station)),
     item(<<"facts sent">>, num(Sent)),
     item(<<"facts that failed">>, num(Failed)),
     <<"</dl><p class=\"note\">">>, door_note(Failed, Sent),
     <<"</p></section>">>].

station_name(undefined) -> <<"cannot see one">>;
station_name(Door) -> esc(maps:get(url, Door, <<"unnamed">>)).

%% ⚠ FAILURES ARE TESTED FIRST AND THAT ORDER IS THE WHOLE POINT. Written the
%% other way round, an island with nothing sent and twenty-two rejected matched
%% "nothing has gone out yet, which is normal on a fresh island" and reported a
%% dark mesh as a healthy one. Measured on the first local boot, which had no
%% station at all. **The reassuring branch must be the narrowest**, or it
%% swallows the case it was written to be distinguished from.
door_note(0, 0) ->
    <<"Nothing has gone out yet. On a fresh island that is normal for the "
      "first few seconds.">>;
door_note(0, _Sent) ->
    <<"Every fact has been accepted. A spectator anywhere can watch this "
      "island.">>;
door_note(_Failed, 0) ->
    <<"Nothing has reached the mesh. The world is unaffected and its creatures "
      "carry on living, but nobody else can see this island: check the station "
      "and the realm secret.">>;
door_note(_Failed, _Sent) ->
    <<"Some facts did not go out. The world is unaffected: creatures carry on "
      "living whether or not anyone is listening.">>.

%% ==========================================================================
%% WHAT THE POPULATION IS MADE OF
%% ==========================================================================
census(Snap) ->
    [<<"<section class=\"card\"><h2>The population</h2><dl>">>,
     item(<<"sensors each">>, hundredths(maps:get(sensor_mean, Snap, 0))),
     item(<<"hidden nodes each">>, hundredths(maps:get(hidden_mean, Snap, 0))),
     item(<<"energy in creatures">>, num(maps:get(energy_total, Snap, 0))),
     item(<<"energy in the ground">>, num(maps:get(ground_total, Snap, 0))),
     item(<<"how patchy the ground is">>, num(maps:get(ground_spread, Snap, 0))),
     item(<<"standing still">>, [num(maps:get(still_pct, Snap, 0)), <<"%">>]),
     <<"</dl><h3>How they died</h3><dl>">>, deaths(Snap),
     <<"</dl></section>">>].

%% @doc Deaths by cause. Exported to be tested, because "the population crashed"
%% is not a finding and three causes sharing one total cannot be told apart
%% afterwards.
-spec deaths(map()) -> iodata().
deaths(Snap) ->
    [item(<<"starved">>, num(maps:get(starved, Snap, 0))),
     item(<<"eaten">>, num(maps:get(consumed, Snap, 0))),
     item(<<"died of old age">>, num(maps:get(aged_out, Snap, 0))),
     item(<<"born">>, num(maps:get(born, Snap, 0)))].

%% ==========================================================================
%% THE RULES, WHICH ARE NOT YOURS TO CHANGE
%% ==========================================================================
%%
%% SHOWN IN FULL AND EDITABLE NOWHERE. An island running rules its owner tuned is
%% a different experiment whose numbers may not be read against anybody else's,
%% and the whole point of a fleet of islands is that they are replicates. The
%% constants travel with the image; the page displays them so an owner can check
%% what they are running rather than trust it.
physics(#{econ := Econ}, Pace) ->
    #{number := N, line := Line} = world:ruleset(),
    [<<"<section class=\"card\"><h2>World ">>, num(N),
     <<"</h2><p class=\"line\">">>, esc(Line),
     <<"</p><details><summary>All ">>, num(map_size(Econ)),
     <<" constants of this world</summary><dl class=\"econ\">">>,
     [item(atom_to_binary(K), num(V))
      || {K, V} <- lists:sort(maps:to_list(Econ))],
     <<"</dl><p class=\"note\">These are the physics. They ship with the image "
       "and no setting on this page can change them, because an island running "
       "rules its owner tuned is a different experiment and could not be read "
       "against any other island.</p></details><dl>">>,
     item(<<"ticks per second">>, num(world_pace:ticks_per_second(Pace))),
     <<"</dl></section>">>].

%% ==========================================================================
%% Bits
%% ==========================================================================
item(Label, Value) ->
    [<<"<dt>">>, Label, <<"</dt><dd>">>, Value, <<"</dd>">>].

%% The census reports these times a hundred, so a mean of 1.75 arrives as 175 and
%% printing it raw would report a creature carrying a hundred and seventy-five
%% sensors.
hundredths(V) ->
    [num(V div 100), <<".">>, pad(V rem 100)].

pad(N) when N < 10 -> [<<"0">>, num(N)];
pad(N) -> num(N).

num(N) when is_integer(N) -> integer_to_binary(N);
num(undefined) -> <<"none">>;
num(B) when is_binary(B) -> B.

%% Everything here is a number or a name this service chose, but a station URL
%% comes off the mesh and an island name comes from an owner, so both are
%% escaped. A page that trusts its own inputs is a page that trusts whoever set
%% them.
esc(B) -> binary:replace(
            binary:replace(
              binary:replace(B, <<"&">>, <<"&amp;">>, [global]),
              <<"<">>, <<"&lt;">>, [global]),
            <<">">>, <<"&gt;">>, [global]).
