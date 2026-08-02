%% @doc Supervises this service's own processes.
%%
%% ONE CHILD ALWAYS: the world. It owns this node's biotope and keeps it moving.
%% AND OPTIONALLY A SECOND: the island's own web listener, when
%% `HECATE_BIOTOPE_UI_PORT' is set. Spliced in as a list rather than chosen by a
%% conditional, so an island with no page has no listener at all rather than one
%% that starts and refuses connections.
%%
%% THE UI IS LISTED AFTER THE WORLD, which matters under `one_for_one' only for
%% start order: a page that renders before there is a world to render would fail
%% its first request. The world does not depend on the page in either direction,
%% and a crashing page must never take a world with it.
%%
%% RESTARTING IT LOSES THE WORLD, and that is the honest behaviour rather than an
%% oversight. Nothing is persisted yet, so a crash means the population that was
%% alive is gone and a fresh one is seeded. Making that survive means deciding
%% what a biotope owes the future, which is a real question and not a line of
%% supervisor configuration.
%%
%% one_for_one because of the shape that is coming: creatures will be supervised
%% under the world, and a creature dying is a normal event in an open population
%% that must not restart its siblings.
-module(hecate_biotope_sup).

-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    {ok, {#{strategy => one_for_one, intensity => 5, period => 10},
          [#{id => world_server,
             start => {world_server, start_link, []},
             restart => permanent,
             shutdown => 5000,
             type => worker} | island_ui:child_specs()]}}.
