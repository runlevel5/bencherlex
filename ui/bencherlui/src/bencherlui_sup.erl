%% The application's supervisor. Cowboy supervises the web server, so there
%% is nothing to supervise here.

-module(bencherlui_sup).
-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    {ok, {#{strategy => one_for_one}, []}}.
