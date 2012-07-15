-module(annalist_sup).

-behaviour(supervisor).

%% API
-export([start_link/1]).

%% Supervisor callbacks
-export([init/1]).

%% ===================================================================
%% API functions
%% ===================================================================

-spec start_link(list()) -> {ok, pid()} | {error, string()}.
start_link(ElevelDBDir) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [ElevelDBDir]).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

-spec init([list()]) -> {ok, {tuple(), [tuple()]}}.
init([ElevelDBDir]) ->
	Handle = uplevel:handle(ElevelDBDir),
	AnnalistAPIServer =
		{annalist_api_server, {annalist_api_server, start_link, [Handle]},
			permanent, 1000, worker, [annalist, uplevel, eleveldb]},
	AnnalistCounterServer =
		{annalist_counter_server, {annalist_counter_server, start_link, [Handle]},
			permanent, 1000, worker, [annalist, cpunter, uplevel, eleveldb]},
	AnnalistRecorderServer =
		{annalist_recorder_server, {annalist_recorder_server, start_link, [Handle]},
			permanent, 1000, worker, [annalist, cpunter, uplevel, eleveldb]},
    {ok, { {one_for_one, 5, 10}, [AnnalistAPIServer, AnnalistCounterServer, AnnalistRecorderServer]} }.