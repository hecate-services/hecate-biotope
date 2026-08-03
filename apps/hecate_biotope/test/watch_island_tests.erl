%% @doc The island's own page: what it may change, what it may never change,
%% and the two places it has already told a lie.
-module(watch_island_tests).

-include_lib("eunit/include/eunit.hrl").

%%==============================================================================
%% What an owner may set
%%==============================================================================

%% ⚠ THE ENTIRE POINT OF THE SETTINGS ENDPOINT. The form offers no physics, and
%% that is not what protects them: this is. A browser is not the only thing that
%% can POST, and an island running rules its owner tuned is a different
%% experiment whose numbers may not be read against any other island's.
the_physics_cannot_be_set_test() ->
    Pace = #{ticks_per_slot => 1, slot_ms => 500, publish_ms => 1000,
             chart_ms => 500},
    Posted = [{<<"metabolism">>, <<"0">>},
              {<<"sense_scale">>, <<"63">>},
              {<<"ground_ceiling">>, <<"999999">>},
              {<<"max_creatures">>, <<"1">>}],
    ?assertEqual(Pace, island_settings:pace_from(Posted, Pace)),
    %% And none of those names is even in the accepted list, so this cannot be
    %% quietly loosened by adding a clause elsewhere.
    ?assertEqual([], [K || K <- island_settings:accepted(),
                           maps:is_key(binary_to_atom(K), world:defaults())]).

the_pace_can_be_set_test() ->
    Pace = #{ticks_per_slot => 1, slot_ms => 500, publish_ms => 1000,
             chart_ms => 500},
    Got = island_settings:pace_from([{<<"ticks_per_slot">>, <<"4">>},
                                     {<<"slot_ms">>, <<"125">>}], Pace),
    ?assertEqual(4, maps:get(ticks_per_slot, Got)),
    ?assertEqual(125, maps:get(slot_ms, Got)),
    %% Untouched keys keep their value rather than falling back to a default.
    ?assertEqual(1000, maps:get(publish_ms, Got)).

%% A TYPO IN A TEXT BOX IS A PERSON, and taking down their island over it would
%% be absurd. This is deliberately the OPPOSITE of what the environment does: a
%% typo in a config file is a deployment that must fail loudly.
a_value_that_is_not_a_number_is_ignored_test() ->
    Pace = #{ticks_per_slot => 2, slot_ms => 500, publish_ms => 1000,
             chart_ms => 500},
    ?assertEqual(Pace, island_settings:pace_from(
                         [{<<"ticks_per_slot">>, <<"fast please">>},
                          {<<"slot_ms">>, <<"">>},
                          {<<"publish_ms">>, <<"12abc">>}], Pace)).

%% A world that stops ticking is not a world. Zero is legitimate for a slot and
%% for a chart, and fatal for the number of ticks in one.
a_zero_tick_rate_is_floored_test() ->
    Pace = #{ticks_per_slot => 2, slot_ms => 500, publish_ms => 1000,
             chart_ms => 500},
    Got = island_settings:pace_from([{<<"ticks_per_slot">>, <<"0">>},
                                     {<<"chart_ms">>, <<"0">>}], Pace),
    ?assertEqual(1, maps:get(ticks_per_slot, Got)),
    ?assertEqual(0, maps:get(chart_ms, Got)).

%%==============================================================================
%% Whether there is a page at all
%%==============================================================================

%% OFF UNLESS ASKED FOR. A headless experiment and a fleet node pay nothing for a
%% page nobody opens, and an unparseable port is off rather than a guess.
no_port_means_no_listener_test() ->
    ?assertEqual([], with_port(false, fun island_ui:child_specs/0)),
    ?assertEqual(0, with_port("", fun island_ui:port/0)),
    ?assertEqual(0, with_port("http", fun island_ui:port/0)),
    ?assertEqual(0, with_port("0", fun island_ui:port/0)),
    ?assertEqual(8484, with_port("8484", fun island_ui:port/0)).

a_port_means_one_listener_test() ->
    ?assertMatch([_One], with_port("8484", fun island_ui:child_specs/0)).

%% A ROUTE THAT EXISTS AND IS NEVER MOUNTED IS DEAD CODE, which hecate_om
%% shipped for long enough that every service reported unhealthy to podman. The
%% dispatch is compiled from exactly this list, so asserting the list is
%% asserting what is served.
every_route_is_compilable_test() ->
    Routes = island_ui:routes(),
    ?assertEqual(5, length(Routes)),
    ?assert(lists:keymember("/", 1, Routes)),
    ?assert(lists:keymember("/settings", 1, Routes)),
    %% Compiling is what the supervisor does, and a malformed route only fails
    %% there, at boot, against a live mesh.
    ?assertMatch([_ | _], cowboy_router:compile([{'_', Routes}])).

%%==============================================================================
%% What the page says
%%==============================================================================

%% ⚠ RED BEFORE THE FIX. Written the other way round, "nothing has gone out yet,
%% which is normal on a fresh island" matched an island with nothing sent AND
%% twenty-two rejected, so a dark mesh reported as a healthy one. Caught on the
%% first local boot, which had no station at all.
a_dark_mesh_is_not_reported_as_a_fresh_one_test() ->
    Fresh = iolist_to_binary(island_vitals:deaths(#{})),
    ?assertNotEqual(nomatch, binary:match(Fresh, <<"born">>)),
    Dark = note(22, 0),
    Starting = note(0, 0),
    ?assertNotEqual(Dark, Starting),
    ?assertNotEqual(nomatch, binary:match(Dark, <<"nobody else can see">>)),
    ?assertNotEqual(nomatch, binary:match(Starting, <<"normal">>)).

%% AN ENDED WORLD IS A RESULT AND MUST SAY SO. Most seeds die here, and a page
%% that quietly showed the next world would hide the most common thing that
%% happens on this island.
an_ended_world_says_so_test() ->
    Html = iolist_to_binary(
             island_vitals:html(#{population => 0, extinct_at => 2568,
                                  econ => world:defaults()},
                                pace(), status())),
    ?assertNotEqual(nomatch, binary:match(Html, <<"has ended">>)),
    ?assertNotEqual(nomatch, binary:match(Html, <<"2568">>)).

%% A SCREENED FLEET IS A BIASED SAMPLE AND SAYING SO IS THE DIFFERENCE BETWEEN
%% HONEST AND NOT. World 17 kills most seeds, so an island shows a world that
%% got past the founding phase and the page states how many did not.
screening_is_disclosed_test() ->
    Html = iolist_to_binary(island_vitals:html(alive(), pace(),
                                               (status())#{rejected => 21})),
    ?assertNotEqual(nomatch, binary:match(Html, <<"SCREENED">>)),
    ?assertNotEqual(nomatch, binary:match(Html, <<"21">>)).

%% The census reports these times a hundred, so printing one raw would report a
%% creature carrying a hundred and seventy-five sensors.
a_mean_is_not_printed_as_hundredths_test() ->
    Html = iolist_to_binary(island_vitals:html(
                              (alive())#{sensor_mean => 175,
                                         hidden_mean => 7}, pace(), status())),
    ?assertNotEqual(nomatch, binary:match(Html, <<"1.75">>)),
    ?assertNotEqual(nomatch, binary:match(Html, <<"0.07">>)).

%% An island name comes from an owner and travels into a page. A page that
%% trusts its own inputs trusts whoever set them.
a_station_name_is_escaped_test() ->
    Html = iolist_to_binary(
             island_vitals:html(alive(), pace(),
                                (status())#{station =>
                                                #{url => <<"<script>x</script>">>}})),
    ?assertEqual(nomatch, binary:match(Html, <<"<script>">>)),
    ?assertNotEqual(nomatch, binary:match(Html, <<"&lt;script&gt;">>)).

%%==============================================================================
%% The page and the policy it is served under
%%==============================================================================

%% ⚠ RED BEFORE THE FIX, AND IT COULD NOT HAVE BEEN CAUGHT FROM THE SERVER SIDE.
%% The policy was `default-src 'none'' with no `connect-src', which governs both
%% `fetch' and `WebSocket'. Every poll was blocked in the browser: the first one
%% threw, the loop disabled itself, and the island served a perfectly correct
%% first frame and then froze. Status 200, nothing in the logs, every number on
%% the page right. A SCREENSHOT was what caught it.
%%
%% So the test reads what the script actually connects to and checks it against
%% the policy and the routing table together. Three things that must agree and
%% previously agreed by hand.
the_policy_permits_what_the_page_does_test() ->
    Csp = island_page:csp(),
    Js = island_page:js(),
    ?assertNotEqual(nomatch, binary:match(Csp, <<"connect-src 'self'">>)),
    %% The page connects, so the absence of `connect-src` is fatal and not
    %% merely untidy.
    ?assertNotEqual(nomatch, binary:match(Js, <<"WebSocket">>)),
    %% An inline style and an inline script, both of which this page has.
    ?assertNotEqual(nomatch, binary:match(Csp, <<"style-src 'unsafe-inline'">>)),
    ?assertNotEqual(nomatch, binary:match(Csp, <<"script-src 'unsafe-inline'">>)),
    %% And nothing else may load from anywhere: an island runs behind somebody
    %% else's firewall and a page that phones out breaks there.
    ?assertNotEqual(nomatch, binary:match(Csp, <<"default-src 'none'">>)).

%% EVERY PATH THE SCRIPT NAMES MUST BE A ROUTE. A page that connects to a URL
%% nobody serves is the same silent failure as a policy that forbids it, and both
%% look like a slow world.
every_path_the_page_uses_is_served_test() ->
    Js = island_page:js(),
    Served = [list_to_binary(P) || {P, _M, _O} <- island_ui:routes()],
    Used = [<<"/live">>],
    ?assertEqual([], [P || P <- Used, not lists:member(P, Served)]),
    ?assert(lists:all(fun(P) -> binary:match(Js, P) =/= nomatch end, Used)).

%% THE SOCKET IS THE ONLY THING THE PAGE TALKS TO, which is what makes a paused
%% or slow island cost nothing. A stray poll would put the fixed interval back.
the_page_makes_no_repeating_request_test() ->
    Js = island_page:js(),
    ?assertEqual(nomatch, binary:match(Js, <<"setInterval">>)),
    ?assertEqual(nomatch, binary:match(Js, <<"fetch(">>)).

%%==============================================================================
%% The picture
%%==============================================================================

%% ⚠ THESE PIN CONSTANTS MIRRORED FROM beam-campus-net's `biotope_components.ex'.
%% An owner's local page and the public spectator must not be two drawings of one
%% world, and the two live in different repos and different languages, so nothing
%% but a test connects them. A change to one is a change to both.

%% SIZE IS ABSOLUTE, NOT RELATIVE TO THE LARGEST IN FRAME. A first version of
%% this file scaled to the biggest creature present, which makes a board where
%% everything has shrunk look perfectly ordinary and hides the result rather than
%% showing it.
a_body_is_drawn_on_an_absolute_scale_test() ->
    Cell = 8.0,
    %% The same body draws the same size whatever else is on the board, which is
    %% the whole claim and is not testable from one call.
    ?assertEqual(island_disc:radius_for(Cell, 400),
                 island_disc:radius_for(Cell, 400)),
    ?assert(island_disc:radius_for(Cell, 2500) >
                island_disc:radius_for(Cell, 400)),
    %% Saturates at the full mark rather than growing without bound.
    ?assertEqual(island_disc:radius_for(Cell, 2500),
                 island_disc:radius_for(Cell, 25000)),
    %% AREA carries the body, so radius goes as the root: quadrupling the body
    %% doubles the radius, and a linear radius would have squared the quantity.
    Quarter = island_disc:radius_for(Cell, 625) - Cell * 0.25,
    Full = island_disc:radius_for(Cell, 2500) - Cell * 0.25,
    ?assert(abs(Full - 2 * Quarter) < 0.001).

%% A CREATURE ABOUT TO STARVE IS STILL THERE, and a dot of radius zero is a
%% creature the picture has lost.
a_creature_with_no_body_still_draws_test() ->
    ?assert(island_disc:radius_for(8.0, 0) > 0),
    ?assert(island_disc:radius_for(8.0, absent) > 0).

%% PALE IS GENTLE AND DEEP IS VORACIOUS, read straight off a scale, so a patch of
%% one shade is a patch of creatures making a living the same way.
feeding_runs_pale_to_deep_test() ->
    Ceiling = 400,
    Gentle = island_disc:feeding_rgb(0, Ceiling),
    Greedy = island_disc:feeding_rgb(Ceiling, Ceiling),
    ?assertNotEqual(Gentle, Greedy),
    %% Deeper means less green and less blue: cream to red-orange.
    ?assert((Gentle band 16#00FF00) > (Greedy band 16#00FF00)),
    ?assert((Gentle band 16#0000FF) > (Greedy band 16#0000FF)),
    %% Beyond the ceiling clamps rather than wrapping into another hue.
    ?assertEqual(Greedy, island_disc:feeding_rgb(Ceiling * 9, Ceiling)),
    %% An island on an older build sends no rates, and amber is what every
    %% creature used to be.
    ?assertEqual(16#F2B142, island_disc:feeding_rgb(absent, Ceiling)).

%% THE STRIDES ARE THE CONTRACT WITH THE PAINTER. Ground and scent are position
%% and amount; creatures have several lists running parallel. Mixing the two
%% conventions is how a reader draws a plausible and completely wrong board.
the_packed_strides_are_the_painters_contract_test() ->
    W = world:tick(world:new(#{seed => 7, population => 12, radius => 4}), 20),
    D = island_disc:packed(world:chart(W), 400),
    ?assertEqual(0, length(maps:get(ground, D)) rem 4),
    ?assertEqual(0, length(maps:get(trails, D)) rem 3),
    %% SIX SINCE KINDS: id, x, y, radius, feeding colour, kind colour. Both
    %% colourings travel together so pressing K is a repaint rather than a
    %% refetch, and the painter reads `i+4' or `i+5' off one array.
    %% EIGHT SINCE THE BULLSEYE: id, x, y, radius, feeding colour, kind colour,
    %% senses, hidden nodes. A creature is not one quantity and a mark that shows
    %% one is throwing the rest away.
    ?assertEqual(0, length(maps:get(creatures, D)) rem 8),
    ?assertEqual(12, length(maps:get(rim, D))),
    ?assert(maps:get(cell, D) > 0).

%% EVERY MARK IS INSIDE THE BOX IT IS DRAWN INTO, or the board silently loses its
%% edges and nobody sees which cells went missing.
every_mark_lands_on_the_board_test() ->
    W = world:tick(world:new(#{seed => 7, population => 12, radius => 4}), 20),
    D = island_disc:packed(world:chart(W), 400),
    Size = maps:get(size, D),
    Xs = every(4, 0, maps:get(ground, D)),
    Ys = every(4, 1, maps:get(ground, D)),
    ?assert(lists:all(fun(V) -> V >= 0 andalso V =< Size end, Xs ++ Ys)).

%% ABOVE THE CEILING MEANS SOMETHING DIED HERE. Ambient supply stops at the
%% ceiling, so no amount of sunlight reaches such a cell and only a corpse does.
%% Worth its own colour, because "places became different because things died
%% there" is the one claim this drawing can settle at a glance.
a_corpse_cell_gets_its_own_colour_test() ->
    Normal = island_disc:packed(#{radius => 2, ground => [0, 0, 100],
                                  creatures => [], scent => []}, 400),
    Rich = island_disc:packed(#{radius => 2, ground => [0, 0, 9000],
                                creatures => [], scent => []}, 400),
    ?assertNotEqual(colour_of(Normal), colour_of(Rich)),
    ?assertEqual(16#2F7D52, colour_of(Normal)),
    ?assertEqual(16#C2557A, colour_of(Rich)).

%% Every seed here dies eventually and the page has to survive that without a
%% maximum over an empty list.
an_empty_board_still_packs_test() ->
    D = island_disc:packed(#{radius => 4, ground => [], creatures => [],
                             scent => []}, 400),
    ?assertEqual([], maps:get(creatures, D)),
    ?assertEqual([], maps:get(ground, D)),
    ?assertEqual(12, length(maps:get(rim, D))).

%% An island on an older build sends shorter lists than its positions. A missing
%% body draws the floor radius rather than crashing the page.
a_short_chart_does_not_crash_the_page_test() ->
    D = island_disc:packed(#{radius => 4, ground => [],
                             creatures => [0, 0, 1, 1], ids => [7, 8],
                             structures => [], uptakes => [], scent => []}, 400),
    ?assertEqual(16, length(maps:get(creatures, D))).

%%==============================================================================
%% Colouring by kind
%%==============================================================================

%% ⚠ A KIND'S COLOUR COMES FROM THE ARCHITECTURE AND NOT FROM ITS INDEX, and this
%% test is the whole reason the code does the more expensive thing. `kind_of' is
%% an index into a SORTED table of the kinds present, so one creature dying can
%% shift every index above it by one. A colour taken from the index would repaint
%% the entire board for a change to a single creature, and a viewer would read
%% that as the population turning over.
a_kinds_colour_survives_another_kind_dying_test() ->
    A = [1, 1, 0, 0, 1, 0],
    B = [1, 2, 0, 0, 1, 0],
    ?assertEqual(island_disc:kind_rgb(A), island_disc:kind_rgb(A)),
    ?assertNotEqual(island_disc:kind_rgb(A), island_disc:kind_rgb(B)),
    %% Same architecture, therefore same colour, whatever else is in the world.
    ?assertEqual(island_disc:kind_rgb(B), island_disc:kind_rgb([1, 2, 0, 0, 1, 0])).

%% Every colour is a real colour: in range, and neither black nor white, both of
%% which would vanish against the ground or the glow.
a_kind_colour_is_visible_test() ->
    Colours = [island_disc:kind_rgb([N, 1, 0, 0, 1, 0]) || N <- lists:seq(1, 60)],
    ?assert(lists:all(fun(C) -> C >= 0 andalso C =< 16#FFFFFF end, Colours)),
    ?assert(lists:all(fun(C) -> C > 16#101010 end, Colours)),
    %% And they are not all one colour: sixty architectures should not read as a
    %% single population.
    ?assert(length(lists:usort(Colours)) > 30).

%% Two creatures of one kind get one colour ON THE BOARD, which is the claim the
%% drawing makes and the only one a viewer can check by eye.
%%
%% ⚠ THE FIRST VERSION OF THIS TEST PASSED ON A BROKEN BOARD. It asserted only
%% that no kind wore two colours, and the bug it was meant to catch painted 138
%% of 180 creatures the same fallback grey — which satisfies "one colour per
%% kind" perfectly, because grey is one colour. **A test that only forbids
%% disagreement is passed by uniformity.** It has to assert the converse too: as
%% many colours as there are kinds, and no fallback anywhere.
%% ⚠ AND THE SECOND VERSION PASSED ON THE BROKEN BOARD TOO, for a different
%% reason: it ran a radius-5 world, which holds ONE TO THREE CREATURES, and every
%% one of them was its own kind. Colouring by position and colouring by kind are
%% the same function when no two creatures share a kind, so the world could not
%% tell them apart however the assertions were written.
%%
%% **THE FIXTURE WAS THE FLAW, NOT THE ASSERTION.** It needs a board where kinds
%% are SHARED, so the assertion below states the ratio it needs and the fixture
%% has to earn it. Seed 77 at 600 ticks holds 89 creatures across 14 kinds.
%%
%% ⚠ AND THE GUARD HAS EARNED ITS KEEP THREE TIMES. The fixture was seed 101
%% until world 20, seed 3 until world 21 and seed 55 until historical marking,
%% and each time the changed world left that seed holding a handful of creatures
%% each of its own kind. Every assertion above
%% would have passed on it, vacuously, and the guard is the only thing that
%% noticed. **A world change invalidates every fixture chosen by running the
%% world**, which is a cost of testing against the real thing and worth paying.
one_kind_is_one_colour_on_the_board_test() ->
    W = world:tick(world:new(#{seed => 77, population => 40}), 600),
    Chart = world:chart(W),
    D = island_disc:packed(Chart, 400),
    Kinds = maps:get(kind_of, Chart),
    Painted = every(8, 5, maps:get(creatures, D)),
    ?assertEqual(length(Kinds), length(Painted)),
    Pairs = lists:usort(lists:zip(Kinds, Painted)),
    %% One colour per kind: no kind index appears twice with different colours.
    ?assertEqual(length(lists:usort([K || {K, _C} <- Pairs])), length(Pairs)),
    %% AND AS MANY COLOURS AS KINDS. Distinct architectures must be distinct on
    %% the board or the drawing says less than the census it is drawn from.
    ?assertEqual(length(lists:usort(Kinds)), length(lists:usort(Painted))),
    %% AND NOT ONE FALLBACK. Grey means an index missed a table that has
    %% entries, which is two parallel lists disagreeing rather than a display
    %% case.
    ?assertEqual([], [C || C <- Painted, C =:= 16#888888]),
    %% The fixture itself is asserted, because this test is only worth running on
    %% a board where kinds are shared and the previous two were not.
    ?assert(length(Kinds) > 4 * length(lists:usort(Kinds))).

%% THE MAPPING ALONE, ON A CHART BUILT BY HAND, so the claim is checked without
%% depending on any world evolving a particular shape. Four creatures, two kinds,
%% in the order 1, 0, 1, 0: colouring by POSITION would give four different
%% colours and colouring by KIND gives two, alternating.
%%
%% ⚠ HAND-BUILT CHARTS ARE HOW `C.6' AND `B.7' HID, which is why this sits beside
%% the live-world test and does not replace it. A fixture that agrees with the
%% renderer and not with the island proves only that two of my own functions
%% agree.
the_colour_follows_the_kind_and_not_the_position_test() ->
    D = island_disc:packed(#{radius => 4, ground => [], scent => [],
                             creatures => [0, 0, 1, 0, 0, 1, 1, 1],
                             ids => [1, 2, 3, 4],
                             structures => [40, 40, 40, 40],
                             uptakes => [1, 1, 1, 1],
                             kind_of => [1, 0, 1, 0],
                             kind_table => [1, 1, 0, 0, 1, 0,
                                            1, 2, 0, 0, 1, 0]}, 400),
    [A, B, C, E] = every(8, 5, maps:get(creatures, D)),
    ?assertEqual(A, C),
    ?assertEqual(B, E),
    ?assertNotEqual(A, B),
    ?assertEqual([], [X || X <- [A, B, C, E], X =:= 16#888888]).

%% AN ISLAND ON AN OLDER BUILD SENDS NO KIND TABLE, and grey is what that looks
%% like. This is the one case the fallback is for, so it is pinned: without it
%% the assertion above could be satisfied by deleting the fallback and crashing
%% the page instead.
an_island_that_sends_no_kinds_still_draws_test() ->
    D = island_disc:packed(#{radius => 4, ground => [], scent => [],
                             creatures => [0, 0, 1, 1], ids => [7, 8],
                             structures => [40, 40], uptakes => [1, 1]}, 400),
    ?assertEqual([16#888888, 16#888888], every(8, 5, maps:get(creatures, D))).

colour_of(Packed) -> lists:nth(3, maps:get(ground, Packed)).

every(Stride, Offset, List) ->
    [lists:nth(I + Offset + 1, List)
     || I <- lists:seq(0, length(List) - Stride, Stride)].

%%==============================================================================
%% Fixtures
%%==============================================================================
alive() ->
    #{population => 83, tick => 1200, seed => 4, depth => 40,
      sensor_mean => 219, hidden_mean => 5, energy_total => 4000,
      ground_total => 400000, ground_spread => 43, still_pct => 20,
      starved => 400, consumed => 70, aged_out => 0, born => 500,
      econ => world:defaults()}.

pace() ->
    #{ticks_per_slot => 1, slot_ms => 500, publish_ms => 1000, chart_ms => 500}.

status() ->
    #{run => 1, rejected => 0, published => 10, publish_errors => 0,
      station => undefined, previous_end => undefined}.

note(Failed, Sent) ->
    iolist_to_binary(island_vitals:html(alive(), pace(),
                                        (status())#{published => Sent,
                                                    publish_errors => Failed})).

%% `os:putenv' is process-global, so each case puts the variable back rather than
%% leaving the next one to inherit it. Test pollution through the environment is
%% exactly the shape of `G.6'.
with_port(false, F) ->
    os:unsetenv("HECATE_BIOTOPE_UI_PORT"),
    F();
with_port(Value, F) ->
    os:putenv("HECATE_BIOTOPE_UI_PORT", Value),
    Result = F(),
    os:unsetenv("HECATE_BIOTOPE_UI_PORT"),
    Result.
