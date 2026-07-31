%% @doc OTP application entry.
%%
%% hecate_om:boot/1 wires the mesh, the realm identity and health, then starts
%% this service. STORELESS: no store_id/0 or data_dir/0 callback on the service
%% module, so no reckon-db is started.
%%
%% That is a real decision and not an omission. An open population is a running
%% simulation whose state is the creatures currently alive, and putting a store
%% write in the tick loop is the mistake this whole shape exists to avoid. What
%% will eventually deserve durability is narrower: the migrants that arrive from
%% other islands, and whatever the biotope chooses to publish. Adding the two
%% callbacks is the whole migration when that day comes.
-module(hecate_biotope_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_Type, _Args) -> hecate_om:boot(hecate_biotope_service).

stop(_State) -> ok.
