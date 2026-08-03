%% @doc The one impure function in the slice: it talks to a model.
%%
%% ==========================================================================
%% ONE FUNCTION, ON PURPOSE, BECAUSE THIS IS THE PART THAT SHOULD MOVE
%% ==========================================================================
%%
%% An island holding an API key is the wrong long-term shape. `serve_llm' in the
%% daemon already announces model capabilities as facts on the mesh, so the right
%% version of this asks the MESH for a model and an island on a stranger's
%% machine needs no key at all, no account and no registration desk, which is
%% what the join page promises about everything else.
%%
%% That path does not exist yet. So this is deliberately ONE function with a
%% narrow signature: when the mesh path arrives, this file is what gets replaced,
%% and nothing else in the slice has to know.
%%
%% ==========================================================================
%% OFF UNLESS ASKED, AND SILENT WHEN OFF
%% ==========================================================================
%%
%% No key, no narrator. An island runs identically without one and simply
%% publishes no remarks, exactly as `HECATE_BIOTOPE_UI_PORT' leaves the local
%% page off. A feature that made a key REQUIRED would break the one-container
%% promise this whole service is built around.
%%
%% ⚠ AND A FAILED CALL IS NOT AN ERROR CONDITION. The model is unreachable, the
%% key expired, the quota ran out: the world carries on, creatures carry on
%% living, and the only thing lost is a sentence. That is the same judgement the
%% vitals page already makes about a dark mesh, and it is why every path here
%% returns `silent' rather than raising.
-module(ask_a_model).

-export([configured/0, describe/2]).

%% Both providers speak the OpenAI chat shape, so the default fits either and
%% the URL is the only thing that has to change.
-define(DEFAULT_URL, "https://api.melious.ai/v1/chat/completions").
%% ⚠ A MODEL NAME THAT WAS VERIFIED TO EXIST, which the first one was not. The
%% default was `mistral-small-latest' and Melious answers that with a 404 and
%% `model_not_found', which this module turns into `silent' exactly as it does an
%% expired key or an unreachable host. **An island shipped with a default that
%% could only ever be quiet**, and quiet is indistinguishable from working here
%% by design.
-define(DEFAULT_MODEL, "mistral-small-3.2-24b-instruct").
%% ⚠ GENEROUS, BECAUSE A LOCAL MODEL IS NOT A CLOUD MODEL. A 7B running on a
%% machine in the same room takes about twenty seconds for this many tokens
%% where a hosted 70B takes two. The first attempt at pointing this at Ollama
%% timed out at exactly 20,000ms and reported `silent', which is this module's
%% word for "the model had nothing to say" and was in fact "I hung up on it".
%%
%% Nothing waits on this: the call runs in its own process and the world ticks on
%% regardless, so a slow answer costs nothing and a missed one costs a sentence.
%% Overridable because whoever points it at their own hardware knows better than
%% this constant does.
-define(DEFAULT_TIMEOUT_MS, 90000).

%% ⚠ SHORT, AND THE LENGTH IS NOT WHAT KEEPS IT SHORT. Told to "write two or
%% three sentences", both 7B models enumerated the entire brief and were cut off
%% mid-word at the token limit; a hosted 70B picked out the one striking figure
%% and stopped. **The instruction that worked was not a length but a TASK**: pick
%% the three most striking figures and say only those. Choosing is a different
%% job from summarising, and a small model can do the first if you ask for it.
%%
%% The limit is still here as a backstop, and set high enough that hitting it is
%% a symptom rather than the mechanism.
-define(MAX_TOKENS, 220).

%% ==========================================================================
%% THE INSTRUCTION, AND THE ONE RULE IT ENFORCES
%% ==========================================================================
%%
%% SAY WHAT YOU SEE. NEVER SAY WHY.
%%
%% "Most creatures graze and almost none hunt" is reading the numbers out loud
%% and is always checkable. "They graze because hunting stopped paying" is a
%% guess wearing the clothes of a fact, and this project's entire method is that
%% a guess has to name an instrument before it is written down. A narrator
%% producing confident causal sentences at two a minute would fill the record
%% with claims nobody measured.
%%
%% The prompt is one half of that. The other half is `world_brief', which hands
%% over nothing but numbers, so there is very little to build a cause out of even
%% if the instruction is ignored.
%%
%% ⚠ AND IT GIVES VOCABULARY, NEVER A CONCLUSION. An earlier version helpfully
%% explained "when new ways in the last thousand ticks is zero, the world has
%% stopped finding new ways to make a living." A 7B model then wrote exactly that
%% sentence on a world whose figure was FOUR, twice, confidently, about the single
%% most important number in the brief.
%%
%% **An if-then handed to a small model is an invitation to fire the THEN without
%% checking the IF.** A hosted 70B did not take the bait, which made it look like
%% a question of model quality when it was a question of what the prompt taught.
%% Definitions only now, and an explicit instruction not to recite them.
-define(SYSTEM,
        <<"You are a narrator for a live artificial-life world. A spectator is "
          "looking at a page of numbers and wants to know what they are seeing.\n"
          "\n"
          "PICK THE THREE MOST STRIKING FIGURES AND SAY ONLY THOSE. You are not "
          "summarising the list; you are choosing what a person would notice. "
          "Exactly three short sentences of plain English, then stop. No "
          "headings, no lists, no markdown.\n"
          "\n"
          "SAY WHAT THE NUMBERS SAY. Do not say why anything happened. Do not "
          "guess at causes, motives, strategies or trends. If a number is "
          "striking, say it is striking; do not explain it. You are describing a "
          "photograph, not telling a story.\n"
          "\n"
          "Never invent a number you were not given. Never mention a creature, "
          "organ or behaviour that is not in the figures.\n"
          "\n"
          "Vocabulary, not conclusions: a 'kind' is what a creature is built "
          "like. A 'way of living' is what it actually does. "
          "new_ways_last_1000_ticks counts ways of living first seen recently. "
          "Read every figure off the list; do not recite these definitions.">>).

%% @doc Whether an island has been given what it needs to narrate.
-spec configured() -> boolean().
configured() -> key() =/= false.

%% @doc Two or three sentences about this brief, or `silent'.
-spec describe(map(), binary()) -> {ok, binary(), binary()} | silent.
describe(Brief, Island) ->
    speak(key(), Brief, Island).

speak(false, _Brief, _Island) -> silent;
speak(Key, Brief, Island) ->
    Model = env("HECATE_BIOTOPE_NARRATOR_MODEL", ?DEFAULT_MODEL),
    sent(post(Key, Model, prompt(Brief, Island)), list_to_binary(Model)).

sent({ok, Text}, Model) -> {ok, Text, Model};
sent(silent, _Model) -> silent.

%% ⚠ THE ISLAND'S NAME IS THE ONLY THING HERE AN OUTSIDER CHOSE, and it is
%% carried as a plain label rather than woven into the instruction, then cut to
%% a length nothing can hide in. An owner who names their island a paragraph of
%% instructions gets a truncated label and not a narrator that follows them.
prompt(Brief, Island) ->
    [<<"island: ">>, binary:part(Island, 0, min(byte_size(Island), 40)),
     <<"\n">>, world_brief:lines(Brief)].

%% ==========================================================================
%% The wire
%% ==========================================================================
post(Key, Model, Prompt) ->
    %% ⚠ A BINARY, NOT AN IOLIST. `httpc:request/4' takes `string() | binary()'
    %% for a body and returns `{error, _}' for anything else, which this module
    %% turns into `silent' like every other failure. So the first live call
    %% produced a perfectly quiet nothing, on a request that was never sent.
    %% **Silence is the right behaviour for an unreachable model and the worst
    %% possible behaviour for a bug**, which is why the escript that exercises
    %% this prints the reason.
    Body = iolist_to_binary(body(Model, Prompt)),
    Url = env("HECATE_BIOTOPE_NARRATOR_URL", ?DEFAULT_URL),
    Headers = [{"authorization", "Bearer " ++ Key}],
    answered(httpc:request(post,
                           {Url, Headers, "application/json", Body},
                           [{timeout, timeout()}], [{body_format, binary}])).

timeout() ->
    milliseconds(os:getenv("HECATE_BIOTOPE_NARRATOR_TIMEOUT_MS")).

milliseconds(false) -> ?DEFAULT_TIMEOUT_MS;
milliseconds(Value) -> parsed(string:to_integer(Value)).

parsed({Ms, ""}) when Ms > 0 -> Ms;
parsed(_Unparseable) -> ?DEFAULT_TIMEOUT_MS.

answered({ok, {{_V, 200, _R}, _H, Body}}) -> first_choice(Body);
answered(_Anything) -> silent.

%% Hand-rolled rather than pulling a JSON dependency in for two shapes. The
%% request is built from values this module chose; the response is picked apart
%% with one regex and anything unexpected is `silent'.
body(Model, Prompt) ->
    [<<"{\"model\":\"">>, Model,
     <<"\",\"max_tokens\":">>, integer_to_binary(?MAX_TOKENS),
     <<",\"temperature\":0.2,\"messages\":[">>,
     <<"{\"role\":\"system\",\"content\":\"">>, escape(?SYSTEM),
     <<"\"},{\"role\":\"user\",\"content\":\"">>,
     escape(iolist_to_binary(Prompt)), <<"\"}]}">>].

first_choice(Body) ->
    found(re:run(Body, "\"content\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*)\"",
                 [{capture, [1], binary}])).

found({match, [Text]}) -> {ok, unescape(Text)};
found(_NoMatch) -> silent.

escape(B) ->
    lists:foldl(fun({From, To}, Acc) ->
                        binary:replace(Acc, From, To, [global])
                end,
                B,
                [{<<"\\">>, <<"\\\\">>}, {<<"\"">>, <<"\\\"">>},
                 {<<"\n">>, <<"\\n">>}, {<<"\r">>, <<"">>},
                 {<<"\t">>, <<" ">>}]).

unescape(B) ->
    lists:foldl(fun({From, To}, Acc) ->
                        binary:replace(Acc, From, To, [global])
                end,
                B,
                [{<<"\\n">>, <<"\n">>}, {<<"\\\"">>, <<"\"">>},
                 {<<"\\\\">>, <<"\\">>}]).

%% ==========================================================================
%% Where the key comes from
%% ==========================================================================
%%
%% A PATH, NOT A VALUE, WHEN THERE IS A CHOICE. A key in an environment variable
%% is in the process table and in every crash dump; a key in a file the container
%% mounts is read once and stays where it was put. Both are accepted because a
%% variable is what most people will reach for, and neither is ever logged.
key() ->
    from_file(os:getenv("HECATE_BIOTOPE_NARRATOR_KEY_FILE")).

from_file(false) -> from_env(os:getenv("HECATE_BIOTOPE_NARRATOR_KEY"));
from_file(Path) -> read(file:read_file(Path)).

from_env(false) -> false;
from_env("") -> false;
from_env(Key) -> Key.

read({ok, Bin}) -> trimmed(string:trim(binary_to_list(Bin)));
read({error, _Why}) -> false.

trimmed("") -> false;
trimmed(Key) -> Key.

env(Name, Default) -> defaulted(os:getenv(Name), Default).

defaulted(false, Default) -> Default;
defaulted("", Default) -> Default;
defaulted(Value, _Default) -> Value.
