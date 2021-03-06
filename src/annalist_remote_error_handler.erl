-module(annalist_remote_error_handler).

-behaviour(gen_event).

-export([
	add_handler/1, add_handler/2,
	delete_handler/0
]).

-export([
	init/1,
	handle_event/2,
	handle_call/2,
	handle_info/2,
	code_change/3,
	terminate/2
]).

init({Node, Keys}) ->
    {ok, [{keys, Keys}, {node, Node}]}.

terminate(_Args, _State) ->
	ok.

add_handler(Node) ->
	error_logger:add_report_handler(?MODULE, {Node, [<<"error">>]}).

add_handler(Node, Keys) ->
	error_logger:add_report_handler(?MODULE, {Node, Keys}).

delete_handler() ->
	error_logger:delete_report_handler(?MODULE).

handle_event({error, _, _}, State = [{keys, Keys}, {node, Node}]) ->
	rpc:call(Node, annalist, count, [Keys]),
	{ok, State};

handle_event(_, State) ->
	{ok, State}.

handle_call(_Request, State) ->
    {ok, undefiend , State, hibernate}.

handle_info(_Msg, State) ->
    {ok, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
