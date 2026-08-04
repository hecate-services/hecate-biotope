%% @doc The page an island's owner looks at. Cowboy handler for `GET /'.
%%
%% ONE PAGE, SERVED BY THE ISLAND ITSELF, on a machine its owner controls. It
%% exists so somebody can run a world without reading our config files, which is
%% the whole of Phase 2.
%%
%% ⚠ IT SHARES NO LISTENER WITH `/health'. hecate_om serves health on its own
%% port and this runs on another, which is not tidiness: podman decides whether
%% to restart this container by asking `/health', and a page that renders a
%% board of a thousand cells must never be able to make that question slow. A
%% health endpoint behind a UI is a health endpoint that reports the UI.
%%
%% SELF-CONTAINED. No CDN, no font, no analytics, no request that leaves the
%% machine. An island runs behind somebody else's firewall and a page that
%% phones out breaks there and tells us who is watching.
%%
%% ⚠ THE BOARD IS PAINTED, NOT BUILT, AND THAT IS beam-campus-net's TECHNIQUE
%% RATHER THAN A FRESH ONE. The first version of this page sent SVG: 1,261
%% hexagon elements, 161 kilobytes, every second. The public spectator had
%% already made and fixed that mistake at a larger scale, and the whole of the
%% fix is that a particle field is not markup. `island_disc' decides everything
%% about every mark, because those are statements about the physics; the painter
%% below interprets nothing and only draws.
-module(island_page).

-export([init/2, csp/0, js/0]).

init(Req, State) ->
    {ok, cowboy_req:reply(200, headers(), page(), Req), State}.

headers() ->
    #{<<"content-type">> => <<"text/html; charset=utf-8">>,
      %% The picture changes every tick. Nothing here may be cached.
      <<"cache-control">> => <<"no-store">>,
      <<"content-security-policy">> => csp()}.

%% @doc The policy this page is served under. Exported to be tested AGAINST THE
%% SCRIPT ITSELF, because a policy that forbids what the page does is invisible
%% from this side: the server renders a correct page, returns 200, logs nothing,
%% and the browser silently refuses every poll.
-spec csp() -> binary().
csp() ->
      %% No page on this service loads anything from anywhere, so the strictest
      %% policy that still allows an inline style and script is the correct one.
      %%
    %% ⚠ `connect-src' IS NOT OPTIONAL AND ITS ABSENCE IS SILENT. `fetch' falls
    %% under it, and with only `default-src 'none'' every poll was blocked: the
    %% first one threw, the loop disabled itself, and the page served a perfectly
    %% correct FIRST FRAME and then froze. Every number on it was right, so it
    %% read as a slow world rather than as a broken page, and the only visible
    %% symptom was a canvas sitting at its default 300 by 150. Nothing in the
    %% server logs, nothing wrong in the markup, and a SCREENSHOT was what caught
    %% it. `watch_island_tests' now checks the policy against the script.
    <<"default-src 'none'; style-src 'unsafe-inline'; "
      "script-src 'unsafe-inline'; connect-src 'self'">>.

page() ->
    Snap = world_server:snapshot(),
    Pace = world_server:pace(),
    Status = world_server:status(),
    [<<"<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">"
       "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">"
       "<title>">>, island(), <<" &middot; a biotope</title><style>">>,
     css(), <<"</style></head><body><header><h1>">>, island(),
     <<"</h1><p>An island: an open population of creatures whose bodies are "
       "made of organs, and an energy economy that decides which of them get to "
       "reproduce.</p></header><main><div class=\"board\">"
       "<canvas id=\"disc\" width=\"560\" height=\"560\" role=\"img\" "
       "aria-label=\"the island\"></canvas>"
       "<p id=\"waiting\">screening for a viable seed. Most worlds here die, "
       "so the island tries several before it shows you one.</p>"
       "<p class=\"legend\">Each dot is a creature, sized by the <strong>body it "
       "has built</strong>, which is what decides every contest here, and "
       "coloured by <strong id=\"colouring\">feeding rate</strong> &mdash; "
       "<kbd>K</kbd> switches. Pale is gentle feeding and deep is voracious: "
       "feeding slower than the ground recovers holds a cell for good, feeding "
       "harder strips it and forces a move. The green is energy in the ground "
       "and <strong>rose is a cell something died in</strong>. Violet is a scent "
       "trail.</p>"
       "<p class=\"legend\">A mark is a <strong>target, not a dot</strong>. Its "
       "SIZE is the body every contest here is decided on. The <strong>rings "
       "inside it</strong> are how many things it measures, one ring per pair of "
       "senses. The <strong>lit core</strong> means it has a hidden node and "
       "therefore computes rather than merely reacts: fewer than one creature in "
       "two carries one, and a creature without one cannot act on its own state "
       "at all, because its own energy reads the same for every cell it can "
       "reach and cancels out of the comparison.</p>"
       %% ⚠ WHAT THIS IS ACTUALLY ABOUT, ON THE PAGE. Every version of this
       %% legend before now described an ecology and never once said the word
       %% brain, on a page whose entire subject is whether brains evolve. A
       %% spectator could watch for an hour and not learn what was being asked.
       "<p class=\"legend\">Press <kbd>K</kbd> and the dots colour by "
       "<strong>kind</strong> instead. A kind is a <strong>body plan and a "
       "brain</strong>: which of the four things there are to measure this "
       "creature has sensors for, how many hidden nodes it thinks with, and "
       "which of the four things there are to do it can do at all. Nothing "
       "assigns these. A founder is drawn at random and every birth can add a "
       "sensor, drop one, widen its reach, grow a node or gain and lose a "
       "purpose, so <strong>a colour shared by two dots means two creatures "
       "built the same way</strong>. One colour spreading across the disc is a "
       "kind winning. Many colours holding is a world that has not decided."
       "</p></div><div id=\"vitals\">">>,
     island_vitals:html(Snap, Pace, Status),
     <<"</div></main><footer>">>, settings(Pace),
     <<"</footer><div id=\"paused\" role=\"status\">paused &middot; space to "
       "resume</div><script>">>,
     js(), <<"</script></body></html>">>].

island() -> esc(world_facts:island()).

%% ==========================================================================
%% WHAT AN OWNER MAY CHANGE, AND WHAT THEY MAY NOT
%% ==========================================================================
%%
%% THE PACE AND THE NAME. Neither is physics: one is how fast you watch a world
%% and the other is what your island is called. Changing either alters nothing
%% inside any world and no result is affected by them.
%%
%% NOT THE RULES. `island_vitals' shows every constant and this form offers none
%% of them, because an island running rules its owner tuned is a different
%% experiment whose numbers may not be read against another island's.
%%
%% AND IT SAYS PLAINLY THAT IT DOES NOT PERSIST. This container has no volume, so
%% a change made here lasts until the island restarts and then the environment
%% wins. Hiding that would be the worst kind of settings page: one that appears
%% to work and silently reverts. So it shows the line to put in the config file
%% instead, which is the thing the owner actually wanted.
settings(#{ticks_per_slot := TPS, slot_ms := Slot, publish_ms := Pub,
           chart_ms := Chart}) ->
    [<<"<details><summary>Settings</summary>"
       "<form method=\"post\" action=\"/settings\">">>,
     field(<<"name">>, <<"island">>, island(), <<"text">>),
     field(<<"ticks per slot">>, <<"ticks_per_slot">>, num(TPS), <<"number">>),
     field(<<"slot, ms">>, <<"slot_ms">>, num(Slot), <<"number">>),
     field(<<"a fact every, ms">>, <<"publish_ms">>, num(Pub), <<"number">>),
     field(<<"a frame every, ms">>, <<"chart_ms">>, num(Chart), <<"number">>),
     <<"<button type=\"submit\">Apply</button></form>"
       "<p class=\"note\"><strong>Until this island restarts.</strong> There is "
       "no disk here, so the environment wins on the next boot. To keep a "
       "change, put it in the island's config:</p><pre>"
       "HECATE_BIOTOPE_ISLAND=">>, island(),
     <<"\nHECATE_BIOTOPE_TICKS_PER_SLOT=">>, num(TPS),
     <<"\nHECATE_BIOTOPE_SLOT_MS=">>, num(Slot),
     <<"\nHECATE_BIOTOPE_PUBLISH_MS=">>, num(Pub),
     <<"\nHECATE_BIOTOPE_CHART_MS=">>, num(Chart),
     <<"</pre><p class=\"note\">The station this island reaches the mesh "
       "through is <code>MACULA_STATION_SEEDS</code> and takes effect at boot, "
       "so it is not offered here: changing it would mean dropping every link "
       "mid-tick and pretending that was a setting.</p></details>">>].

field(Label, Name, Value, Type) ->
    [<<"<label>">>, Label, <<"<input type=\"">>, Type, <<"\" name=\"">>, Name,
     <<"\" value=\"">>, Value, <<"\" min=\"0\"></label>">>].

%% ==========================================================================
%% Presentation
%% ==========================================================================
%%
%% Two columns that become one on a narrow screen, and it follows the reader's
%% own light or dark setting rather than imposing one. An island is watched on
%% whatever the owner happens to have.
css() ->
    <<":root{--bg:#fbfaf7;--fg:#1a1a17;--card:#fff;--line:#e0ddd4;"
      "--soil:#6b8f3f;--dim:#6a6a60}"
      "@media(prefers-color-scheme:dark){:root{--bg:#12130f;--fg:#eceade;"
      "--card:#1c1e18;--line:#2e3128;--soil:#8fbf5f;--dim:#9a9a8c}}"
      "*{box-sizing:border-box}"
      "body{margin:0;padding:1.5rem;background:var(--bg);color:var(--fg);"
      "font:16px/1.55 ui-sans-serif,system-ui,-apple-system,Segoe UI,sans-serif}"
      "header{max-width:64rem;margin:0 auto 1.5rem}"
      "header h1{margin:0;font-size:1.7rem;letter-spacing:-.02em}"
      "header p{margin:.3rem 0 0;color:var(--dim);max-width:46rem}"
      "main{max-width:64rem;margin:0 auto;display:grid;gap:1.5rem;"
      "grid-template-columns:minmax(0,1.2fr) minmax(0,1fr)}"
      "@media(max-width:52rem){main{grid-template-columns:1fr}}"
      "#disc{width:100%;height:auto;display:block;background:var(--card);"
      "aspect-ratio:1;"
      "border:1px solid var(--line);border-radius:12px}"
      ".legend{color:var(--dim);font-size:.85rem;margin:.6rem 0 0}"
      "#waiting{color:var(--dim);font-size:.85rem;margin:.6rem 0 0;font-style:italic}"
      ".card{background:var(--card);border:1px solid var(--line);"
      "border-radius:12px;padding:1rem 1.1rem;margin:0 0 1rem}"
      ".card h2{margin:0 0 .6rem;font-size:1rem;text-transform:uppercase;"
      "letter-spacing:.08em;color:var(--dim)}"
      ".card h3{margin:1rem 0 .4rem;font-size:.8rem;text-transform:uppercase;"
      "letter-spacing:.08em;color:var(--dim)}"
      ".card.dead{border-color:#a8563c}"
      "dl{display:grid;grid-template-columns:1fr auto;gap:.15rem .8rem;margin:0}"
      "dt{color:var(--dim)}dd{margin:0;text-align:right;"
      "font-variant-numeric:tabular-nums}"
      "dl.econ{font-size:.85rem;max-height:18rem;overflow:auto}"
      ".line{margin:0 0 .6rem;font-style:italic}"
      ".note{color:var(--dim);font-size:.85rem;margin:.7rem 0 0}"
      "footer{max-width:64rem;margin:1.5rem auto 0}"
      "details{background:var(--card);border:1px solid var(--line);"
      "border-radius:12px;padding:.8rem 1.1rem}"
      "summary{cursor:pointer;font-weight:600}"
      "form{display:grid;gap:.6rem;margin:.9rem 0 0;max-width:22rem}"
      "label{display:grid;gap:.2rem;font-size:.85rem;color:var(--dim)}"
      "input{padding:.45rem .6rem;border:1px solid var(--line);border-radius:8px;"
      "background:var(--bg);color:var(--fg);font:inherit}"
      "button{padding:.5rem .9rem;border:0;border-radius:8px;background:var(--fg);"
      "color:var(--bg);font:inherit;font-weight:600;cursor:pointer;"
      "justify-self:start}"
      "pre{background:var(--bg);border:1px solid var(--line);border-radius:8px;"
      "padding:.7rem;overflow:auto;font-size:.8rem}"
      ".said{border-left:3px solid #8B7CE8;}"
      ".said p{font-size:1.02em;line-height:1.5;}"
      "kbd{font:inherit;font-size:.85em;border:1px solid currentColor;"
      "border-radius:3px;padding:0 .3em;opacity:.8;}"
      "#paused{position:fixed;right:1rem;bottom:1rem;padding:.4rem .7rem;"
      "border-radius:999px;background:var(--fg);color:var(--bg);"
      "font-size:.75rem;display:none}">>.

%% @doc The page's own script. Exported so a test can read what it CONNECTS to
%% and check every target against the routing table and the policy above.
%%
%% IT MAKES NO REPEATING REQUEST. The island pushes a frame when it has made
%% one, so a paused world costs nothing and a fast one drops nothing. All this
%% does is paint what arrives.
-spec js() -> binary().
js() ->
    <<"let on=true,kinds=false,was=new Map(),now=new Map(),d=null,started=0,frame=0;"
      "const el=document.getElementById('disc'),c=el.getContext('2d');"
      "const css=v=>'#'+v.toString(16).padStart(6,'0');"
      %% RETINA, or the whole thing looks soft. A canvas has real pixels where
      %% markup had none, so it has to be told how many.
      "const fit=()=>{const p=window.devicePixelRatio||1;el.width=d.size*p;"
      "el.height=d.size*p;c.setTransform(p,0,0,p,0,0);};"
      %% Pointy-top, the same corners the island's own axial-to-pixel mapping
      %% produces: 60 degree steps offset by 30.
      "const hex=(x,y,r)=>{c.beginPath();for(let i=0;i<6;i++){"
      "const a=Math.PI/180*(60*i-30),px=x+r*Math.cos(a),py=y+r*Math.sin(a);"
      "i?c.lineTo(px,py):c.moveTo(px,py);}c.closePath();};"
      "const paint=e=>{if(!d)return;c.clearRect(0,0,d.size,d.size);"
      %% WATER FIRST, UNDER EVERYTHING. Same hexagon primitive as the ground so
      %% a shoreline is a shared edge rather than two shapes that nearly meet.
      "c.globalAlpha=1;c.fillStyle='#2B6CB0';"
      "for(let i=0;i<(d.water||[]).length;i+=2){"
      "hex(d.water[i],d.water[i+1],d.cell);c.fill();}"
      %% THE GROUND IS A FIELD AND GETS A FIELD'S PRIMITIVE. Circles leave gaps
      %% and read as a dot screen; hexagons tile the disc exactly, so grazed
      %% ground reads as bare terrain rather than as holes in something.
      "for(let i=0;i<d.ground.length;i+=4){c.globalAlpha=d.ground[i+3]/100;"
      "c.fillStyle=css(d.ground[i+2]);hex(d.ground[i],d.ground[i+1],d.cell);"
      "c.fill();}"
      "c.fillStyle='#8B7CE8';"
      "for(let i=0;i<d.trails.length;i+=3){c.globalAlpha=d.trails[i+2]/100;"
      "c.beginPath();c.arc(d.trails[i],d.trails[i+1],d.cell*1.2,0,6.284);"
      "c.fill();}"
      %% The living on top, because they are the only thing that decides
      %% anything. The glow separates an object from the field it stands on,
      %% which one shared primitive could never do.
      "c.globalAlpha=1;"
      "for(let i=0;i<d.creatures.length;i+=8){const id=d.creatures[i],"
      "col=css(d.creatures[i+(kinds?5:4)]),r=d.creatures[i+3],"
      "sn=d.creatures[i+6],nd=d.creatures[i+7],"
      "tx=d.creatures[i+1],ty=d.creatures[i+2],f=was.get(id);"
      %% A STREAK IS THE TWEEN PATH DRAWN, so movement and its history are one
      %% thing. Only for a mark that was here last frame: something just born
      %% has no past and must not be given one.
      "if(f&&e<1){c.globalAlpha=0.35*(1-e);c.strokeStyle=col;"
      "c.lineWidth=Math.max(1,r*0.8);c.lineCap='round';c.beginPath();"
      "c.moveTo(f[0],f[1]);c.lineTo(f[0]+(tx-f[0])*e,f[1]+(ty-f[1])*e);"
      "c.stroke();}"
      "const x=f?f[0]+(tx-f[0])*e:tx,y=f?f[1]+(ty-f[1])*e:ty;"
      "c.globalAlpha=f?1:e;c.shadowColor=col;c.shadowBlur=Math.max(2,r);"
      "c.fillStyle=col;c.beginPath();c.arc(x,y,r,0,6.284);c.fill();"
      %% A RING PER PAIR OF SENSES, drawn inside the body rather than around it,
      %% so a well-equipped creature does not grow larger than a bigger one. Size
      %% is body and body alone: it decides every contest and must not be
      %% confounded with what a creature can perceive.
      "c.shadowBlur=0;"
      "if(sn>0){c.strokeStyle='rgba(255,255,255,0.55)';"
      "c.lineWidth=Math.max(0.6,r*0.12);"
      "for(let k=1;k<=Math.min(3,Math.ceil(sn/2));k++){"
      "const rr=r*(1-k*0.24);if(rr>0.6){c.beginPath();"
      "c.arc(x,y,rr,0,6.284);c.stroke();}}}"
      %% A LIT CORE MEANS IT COMPUTES. Well under one creature in two carries a
      %% hidden node, so this picks out the few that think from the many that
      %% react, and it is the single rarest thing on the board.
      "if(nd>0){c.fillStyle='#FFF3B0';c.shadowColor='#FFF3B0';"
      "c.shadowBlur=Math.max(3,r);c.beginPath();"
      "c.arc(x,y,Math.max(0.8,r*0.3),0,6.284);c.fill();c.shadowBlur=0;}}"
      "c.shadowBlur=0;c.globalAlpha=0.35;"
      "c.strokeStyle=getComputedStyle(el).color;c.lineWidth=1;c.beginPath();"
      "for(let i=0;i<d.rim.length;i+=2){i?c.lineTo(d.rim[i],d.rim[i+1]):"
      "c.moveTo(d.rim[0],d.rim[1]);}c.closePath();c.stroke();c.globalAlpha=1;};"
      %% A FRAME ARRIVES AND A CREATURE HAS MOVED ONE CELL, so without this the
      %% board is a slideshow: everything teleports and nothing about which way
      %% anything was going survives the jump. Keyed BY ID, because births and
      %% deaths reshuffle the list every tick. The tween is given the gap the
      %% island actually left, so it finishes as the next frame lands whatever
      %% the pace is set to.
      "const animate=gap=>{cancelAnimationFrame(frame);const step=()=>{"
      "const e=Math.min(1,(performance.now()-started)/gap);paint(e);"
      "if(e<1)frame=requestAnimationFrame(step);};"
      "frame=requestAnimationFrame(step);};"
      "const board=n=>{was=now;const first=!d;d=n;if(first)fit();"
      "now=new Map();for(let i=0;i<d.creatures.length;i+=8){"
      "now.set(d.creatures[i],[d.creatures[i+1],d.creatures[i+2]]);}"
      "const gap=Math.min(2000,Math.max(120,performance.now()-started));"
      "started=performance.now();if(on)animate(gap);"
      "const w=document.getElementById('waiting');if(w)w.remove();};"
      %% RECONNECTS, because an island restarts and a tab left open overnight
      %% should find it again rather than showing a frozen board for ever. Backs
      %% off so a genuinely dead island is not hammered.
      "let wait=500;const open=()=>{"
      "const s=new WebSocket((location.protocol==='https:'?'wss://':'ws://')"
      "+location.host+'/live');"
      "s.onmessage=m=>{const t=m.data[0],b=m.data.slice(1);"
      "if(t==='d')board(JSON.parse(b));"
      "else if(b!=='connected')document.getElementById('vitals').innerHTML=b;};"
      "s.onopen=()=>{wait=500;};"
      "s.onclose=()=>{setTimeout(open,wait);wait=Math.min(15000,wait*2);};};"
      "open();"
      %% Pausing stops the MOTION and not the connection: frames keep arriving
      %% and the numbers keep moving, because watching a world and reading it are
      %% different activities and a board that moves under the cursor cannot be
      %% read.
      "addEventListener('keydown',e=>{if(e.target.tagName==='INPUT')return;"
      "if(e.code==='Space'){e.preventDefault();on=!on;"
      "document.getElementById('paused').style.display=on?'none':'block';"
      "if(on)paint(1);}"
      %% ⚠ K REPAINTS, IT DOES NOT REFETCH. Both colourings arrive in every
      %% frame, so switching is a decision about which of six numbers to read and
      %% costs nothing. A toggle that asked the island for a different picture
      %% would be a second view of one world and could disagree with the first.
      "else if(e.key==='k'||e.key==='K'){kinds=!kinds;"
      "document.getElementById('colouring').textContent="
      "kinds?'kind':'feeding rate';paint(1);}});">>.

num(N) -> integer_to_binary(N).

esc(B) -> binary:replace(
            binary:replace(
              binary:replace(B, <<"&">>, <<"&amp;">>, [global]),
              <<"<">>, <<"&lt;">>, [global]),
            <<">">>, <<"&gt;">>, [global]).
