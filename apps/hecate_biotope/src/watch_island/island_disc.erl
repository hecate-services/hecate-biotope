%% @doc The island, packed for painting. A pure function from `world:chart/1' to
%% four arrays of plain integers.
%%
%% ==========================================================================
%% THE SAME TECHNIQUE beam-campus-net USES, AND FOR ITS REASONS
%% ==========================================================================
%%
%% The first version of this file emitted SVG: 1,261 hexagon elements, 161
%% kilobytes, refetched every second. The public spectator had already been
%% there and left, and its note says why better than a fresh argument would:
%%
%%   "This used to be 5,781 SVG circles, 85% of a 711 KB document, rebuilt and
%%    re-diffed on every fact. The fix is not a smaller diff, it is to stop
%%    sending markup for a particle field."
%%
%% SO: NUMBERS GO OVER THE WIRE AND THE CLIENT ONLY PAINTS. Every decision about
%% where a mark goes, how big it is and what colour it is happens HERE, because
%% those are statements about the physics. The canvas in `island_page' interprets
%% nothing.
%%
%% ==========================================================================
%% AND THE SAME PICTURE, DELIBERATELY
%% ==========================================================================
%%
%% An owner's local page and the public spectator must not be two different
%% drawings of one world. The constants below are `biotope_components.ex' in
%% beam-campus-net, mirrored value for value, and each carries the reason that
%% repo recorded for it. **A change to one is a change to both.**
%%
%% Two of them corrected a first version of this file that had reasoned from
%% scratch and got it wrong:
%%
%%   SIZE IS ABSOLUTE, NOT RELATIVE TO THE LARGEST IN FRAME. Scaling to the
%%   biggest creature present makes a board where everything has shrunk look
%%   perfectly ordinary, which hides the result rather than showing it.
%%
%%   COLOUR IS THE FEEDING RATE, NOT THE SIGNATURE. "A signature is a name, and
%%   names only mean something when there are families to name; a feeding rate is
%%   a number, and it means the same thing on every island whether or not
%%   anything has clustered." The signature colouring looked better and said
%%   less.
-module(island_disc).

-export([packed/2, box/2, feeding_rgb/2, radius_for/2, kind_rgb/1]).

%% The board is drawn into a square of this many pixels. The canvas scales it to
%% whatever width the page has, so this is resolution and not layout.
-define(SIZE, 560).

%% The body at which a creature is drawn at full size, well above the 400 a
%% founder starts with, because populations build past 4,000 and the range
%% between them is the whole story.
-define(FRAME_FULL, 2500).

%% A mark at the island's ceiling. Anything fresher is simply as strong as ground
%% gets.
-define(SCENT_FULL, 30).

%% Green for ground, and ROSE ABOVE THE CEILING because ambient supply stops
%% there: no amount of sunlight reaches a cell above it, only a corpse does.
%% "Places became different because things died there" is the one claim this
%% drawing can settle at a glance.
-define(SOIL, 16#2F7D52).
-define(CORPSE, 16#C2557A).

-spec box(map(), non_neg_integer()) -> map().
box(#{radius := Radius}, Size) -> #{radius => Radius, size => Size}.

%% @doc Everything the painter needs, as four arrays and two numbers.
%%
%% STRIDES DIFFER PER ARRAY AND THAT IS DELIBERATE, matching the island's own
%% chart: ground and scent are position-and-amount with nothing running parallel
%% to them, creatures have several lists that do. Mixing the two conventions is
%% how a reader draws a plausible and completely wrong board.
-spec packed(map(), non_neg_integer()) -> map().
packed(Chart, Ceiling) ->
    Box = box(Chart, ?SIZE),
    Cell = cell_radius(Box),
    #{size => ?SIZE,
      cell => Cell,
      %% [x, y, rgb, alpha%]
      ground => flat([soil(M, Box, Ceiling) || M <- marks(maps:get(ground, Chart, []))]),
      %% [x, y, alpha%]
      trails => flat([trail(M, Box) || M <- marks(maps:get(scent, Chart, []))]),
      %% [id, x, y, radius, rgb_feeding, rgb_kind]
      %%
      %% BOTH COLOURINGS TRAVEL IN ONE FRAME, so switching between them is
      %% instant and costs no round trip. They answer different questions and
      %% neither replaces the other: feeding rate is a QUANTITY every island
      %% shares a scale for, and kind is an IDENTITY that only means something
      %% within one world.
      creatures => flat(creatures(Chart, Box, Cell, Ceiling)),
      %% [x, y] around the edge, so the board reads as an object with a rim
      %% rather than as a drawing that happens to stop.
      rim => flat(rim(Box, Cell))}.

%% ==========================================================================
%% The ground
%% ==========================================================================
soil({Q, R, Amount}, Box, Ceiling) ->
    {X, Y} = to_pixel(Q, R, Box),
    [X, Y, soil_colour(Amount, Ceiling), soil_alpha(Amount, Ceiling)].

soil_colour(Amount, Ceiling) when Amount > Ceiling -> ?CORPSE;
soil_colour(_Amount, _Ceiling) -> ?SOIL.

%% THE SQUARE ROOT, because grazing is the story this surface tells and grazing
%% happens at the BOTTOM of the range: a cell at 40 and a cell at 4 are a fed
%% creature and a starved one, and on a straight ramp they differ by four percent
%% of an alpha channel. A root spends the visible range where the population
%% actually lives.
%%
%% A corpse cell is scaled against a far higher mark, because a body returns its
%% whole store and those run to tens of thousands. Without it every enriched cell
%% pins at full and all the graveyards look identical.
soil_alpha(Amount, Ceiling) when Amount > Ceiling ->
    100 * (0.30 + 0.50 * math:sqrt(min(1.0, Amount / max(Ceiling * 20, 1))));
soil_alpha(Amount, Ceiling) ->
    100 * (0.10 + 0.55 * math:sqrt(min(1.0, Amount / max(Ceiling, 1)))).

%% A trail is evidence something passed. Faint on purpose: at full strength it
%% reads as a wall.
trail({Q, R, Strength}, Box) ->
    {X, Y} = to_pixel(Q, R, Box),
    [X, Y, 100 * min(1.0, Strength / ?SCENT_FULL) * 0.30].

%% ==========================================================================
%% The living
%% ==========================================================================
%%
%% WHO EACH MARK IS COMES FIRST. Without an id a viewer can draw one frame and
%% cannot animate between two, because births and deaths reshuffle the list every
%% tick and the mean creature here lives about two of them. Matching by position
%% would slide marks across the board that never moved.
creatures(Chart, Box, Cell, Ceiling) ->
    Ids = maps:get(ids, Chart, []),
    Points = pairs(maps:get(creatures, Chart, [])),
    Frames = maps:get(structures, Chart, []),
    Rates = maps:get(uptakes, Chart, []),
    Kinds = kind_colours(Chart),
    [creature(Id, P, F, U, kind_colour(N, Kinds), Box, Cell, Ceiling)
     || {N, {Id, P, F, U}} <- number(zip4(Ids, Points, Frames, Rates))].

creature(Id, {Q, R}, Frame, Rate, KindRgb, Box, Cell, Ceiling) ->
    {X, Y} = to_pixel(Q, R, Box),
    [Id, X, Y, radius_for(Cell, Frame), feeding_rgb(Rate, Ceiling), KindRgb].

%% ==========================================================================
%% A KIND'S COLOUR COMES FROM WHAT IT IS, NOT FROM WHERE IT SITS IN THE TABLE
%% ==========================================================================
%%
%% `kind_of` is an INDEX into `kind_table`, and the table holds the kinds
%% present, sorted. So the moment a kind appears or dies every index after it
%% shifts, and a colour taken from the index would repaint the entire board for
%% a change to one creature.
%%
%% Hashing the ARCHITECTURE instead gives a kind the same colour for the life of
%% a world, and the same colour in two worlds that evolve the same body plan,
%% which is the comparison worth being able to make by eye.
kind_colours(Chart) ->
    [kind_rgb(K) || K <- records(maps:get(kind_table, Chart, []))].

kind_colour(_N, []) -> 16#888888;
kind_colour(N, Colours) when N < length(Colours) -> lists:nth(N + 1, Colours);
kind_colour(_N, _Colours) -> 16#888888.

%% One record: nsensors, then field and range pairs, then hidden, then the
%% purposes. The same reader `world_tests` keeps, because a format with two
%% definitions has none.
records([]) -> [];
records([NSensors | Rest]) ->
    {Sensors, [Hidden, NPurposes | Rest1]} = lists:split(NSensors * 2, Rest),
    {Purposes, Rest2} = lists:split(NPurposes, Rest1),
    [[NSensors | Sensors] ++ [Hidden | Purposes] | records(Rest2)].

%% @doc A kind as a colour. Exported to be tested: "two creatures of one
%% architecture get one colour, and two architectures rarely collide" is the
%% whole claim this drawing makes about kinds.
%%
%% COSMETIC AND NOT PHYSICS, which is why a hash is acceptable here where `G.6`
%% would forbid one: nothing reads a colour back, so a collision costs a reader a
%% moment's confusion rather than costing a world its determinism.
-spec kind_rgb([integer()]) -> non_neg_integer().
kind_rgb(Record) ->
    hsl(erlang:phash2(Record, 360), 62, 56).

%% Saturation and lightness fixed so every kind reads at the same weight against
%% the ground and the eye sorts them by hue alone.
hsl(H, S, L) ->
    C = (100 - abs(2 * L - 100)) * S,
    X = C * (100 - abs(((H * 100 div 60) rem 200) - 100)) div 10000,
    M = L * 100 - C div 2,
    rgb(H div 60, C div 100, X div 1, M div 100).

rgb(0, C, X, M) -> pack(C + M, X + M, M);
rgb(1, C, X, M) -> pack(X + M, C + M, M);
rgb(2, C, X, M) -> pack(M, C + M, X + M);
rgb(3, C, X, M) -> pack(M, X + M, C + M);
rgb(4, C, X, M) -> pack(X + M, M, C + M);
rgb(_5, C, X, M) -> pack(C + M, M, X + M).

pack(R, G, B) ->
    clamp(R) * 16#10000 + clamp(G) * 16#100 + clamp(B).

clamp(V) -> max(0, min(255, V * 255 div 100)).

number(Items) -> lists:zip(lists:seq(0, length(Items) - 1), Items).

%% @doc THE RADIUS GOES AS THE SQUARE ROOT, so the AREA carries the body rather
%% than the radius: a circle is read by how much of it there is, and a linear
%% radius squares the quantity.
%%
%% A FLOOR AS WELL AS A SCALE, because a creature about to starve is still there
%% and a dot of radius zero is a creature the picture has lost. Exported to be
%% tested against the spectator's copy of the same rule.
-spec radius_for(number(), integer()) -> float().
radius_for(Cell, Frame) when is_integer(Frame), Frame > 0 ->
    Cell * (0.25 + 0.75 * math:sqrt(min(1.0, Frame / ?FRAME_FULL)));
radius_for(Cell, _Frame) -> Cell * 0.25.

%% @doc PALE IS GENTLE AND DEEP IS VORACIOUS. Feed slower than the ground comes
%% back and a cell holds a standing stock you can draw on for good; feed harder,
%% strip it, and move or starve. The colour is the prudent-to-greedy axis read
%% straight off a scale, so a patch of one shade is a patch of creatures making a
%% living the same way.
-spec feeding_rgb(integer(), pos_integer()) -> non_neg_integer().
feeding_rgb(Rate, Ceiling) when is_integer(Rate), Rate >= 0 ->
    T = min(1.0, Rate / max(Ceiling, 1)),
    round(245 - 13 * T) * 16#10000 + round(230 - 146 * T) * 16#100 +
        round(163 - 116 * T);
feeding_rgb(_Absent, _Ceiling) -> 16#F2B142.

%% ==========================================================================
%% Geometry, identical to the spectator's so the two pictures agree
%% ==========================================================================
to_pixel(Q, R, #{size := Size} = Box) ->
    Cell = cell_radius(Box),
    Centre = Size / 2,
    {Centre + Cell * math:sqrt(3) * (Q + R / 2), Centre + Cell * 1.5 * R}.

cell_radius(#{radius := Radius, size := Size}) ->
    Size / (2 * (Radius + 1) * math:sqrt(3)).

rim(#{radius := Radius, size := Size}, Cell) ->
    Centre = Size / 2,
    Reach = math:sqrt(3) * Radius * Cell + Cell,
    [[Centre + Reach * math:cos(math:pi() / 3 * I),
      Centre + Reach * math:sin(math:pi() / 3 * I)] || I <- lists:seq(0, 5)].

%% ==========================================================================
%% Packing
%% ==========================================================================
%%
%% EVERY VALUE IN EVERY ARRAY IS A PLAIN INTEGER and the painter reconstructs
%% what it needs. Colours are 0xRRGGBB, alpha is hundredths, coordinates are
%% whole pixels because the canvas draws to whole pixels anyway.
flat(Rows) -> [round(V) || Row <- Rows, V <- Row].

marks([]) -> [];
marks([Q, R, S | Rest]) -> [{Q, R, S} | marks(Rest)];
marks(_Ragged) -> [].

pairs([]) -> [];
pairs([Q, R | Rest]) -> [{Q, R} | pairs(Rest)];
pairs(_Ragged) -> [].

%% AN ISLAND ON AN OLDER BUILD SENDS SHORTER LISTS, and this page may one day be
%% asked to draw a chart it did not produce. A missing frame or rate falls back
%% rather than crashing: zero draws the floor radius and an absent rate draws the
%% amber every creature used to be.
zip4([], _P, _F, _U) -> [];
zip4(_I, [], _F, _U) -> [];
zip4([Id | Ids], [P | Ps], Frames, Rates) ->
    [{Id, P, head(Frames, 0), head(Rates, absent)}
     | zip4(Ids, Ps, tail(Frames), tail(Rates))].

head([], Default) -> Default;
head([H | _T], _Default) -> H.

tail([]) -> [];
tail([_H | T]) -> T.
