%% @doc The island's own web listener: routes, port, and whether to run at all.
%%
%% ⚠ A SECOND LISTENER, NOT hecate_om's. The plan assumed this would extend the
%% surface that already serves `/health', and hecate_om 0.9.0 compiles a fixed
%% dispatch with no way for a service to contribute a route. Adding one is the
%% right change to that library and it is a hex release, which is not this
%% repo's to fire.
%%
%% AND SEPARATE IS BETTER ANYWAY, which is why this is not recorded as a
%% workaround. Podman decides whether to restart this container by asking
%% `/health'. A page that renders a board of a thousand cells, on a Celeron,
%% while the world ticks twice a second, must never be able to make that question
%% slow. A health endpoint sharing an acceptor pool with a UI is a health
%% endpoint that reports on the UI.
%%
%% OFF BY DEFAULT ON A PORT THAT IS SET, not on a port that is guessed. An
%% unset `HECATE_BIOTOPE_UI_PORT' means no listener at all, so a headless
%% experiment and a fleet node pay nothing for a page nobody opens, and turning
%% it on is one line in a node's own config.
-module(island_ui).

-export([child_specs/0, routes/0, port/0]).

-define(NAME, hecate_biotope_ui_http).

%% @doc Zero or one child. Returned as a list so the supervisor can splice it
%% without a conditional, the same shape hecate_om uses for its health listener.
-spec child_specs() -> [supervisor:child_spec()].
child_specs() -> listener(port()).

listener(0) -> [];
listener(Port) ->
    [ranch:child_spec(?NAME, ranch_tcp, [{port, Port}], cowboy_clear,
                      #{env => #{dispatch => cowboy_router:compile(
                                               [{'_', routes()}])}})].

%% @doc The four things this island serves. Exported to be tested: a route that
%% exists and is never mounted is dead code, and hecate_om shipped exactly that
%% for long enough that every service reported unhealthy to podman.
-spec routes() -> [{string(), module(), term()}].
routes() ->
    [{"/", island_page, []},
     {"/disc.json", island_fragment, disc},
     {"/vitals", island_fragment, vitals},
     {"/settings", island_settings, []}].

%% @doc Which port, or 0 for "do not serve". Exported to be tested, because a
%% service that silently declines to start a listener and a service that starts
%% one on the wrong port look identical from inside.
-spec port() -> non_neg_integer().
port() -> parse(os:getenv("HECATE_BIOTOPE_UI_PORT")).

parse(false) -> 0;
parse("") -> 0;
parse(Str) -> parsed(string:to_integer(string:trim(Str))).

parsed({N, ""}) when is_integer(N), N > 0 -> N;
parsed(_Anything) -> 0.
