%% @doc Supervises this service's own processes.
%%
%% NO CHILDREN YET, and an empty child list is the honest scaffold rather than a
%% placeholder. There is no world to run, so there is nothing to supervise, and
%% inventing a process that ticks and does nothing is how swai ended up with an
%% AIWorker that was an empty heartbeat for a year.
%%
%% one_for_one is chosen now because of the shape that is coming: a biotope will
%% supervise a world and, under it, creatures. A creature that dies is a normal
%% event in an open population and must not restart its siblings.
-module(hecate_biotope_sup).

-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    {ok, {#{strategy => one_for_one, intensity => 5, period => 10}, []}}.
