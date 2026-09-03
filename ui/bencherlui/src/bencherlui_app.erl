%% The web interface of the benchmark suite: serves the pages in priv/www,
%% the static files in priv/static and the results as JSON.

-module(bencherlui_app).
-behaviour(application).

-export([start/2, stop/1]).

start(_Type, _Args) ->
    {ok, Port} = application:get_env(bencherlui, port),
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", cowboy_static, {priv_file, bencherlui, "www/index.html"}},
            {"/index", cowboy_static, {priv_file, bencherlui, "www/index.html"}},
            {"/results", cowboy_static, {priv_file, bencherlui, "www/results.html"}},
            {"/results/:query", bencherlui_results_handler, []},
            {"/static/[...]", cowboy_static, {priv_dir, bencherlui, "static"}}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(bencherlui_http, [{port, Port}],
                                 #{env => #{dispatch => Dispatch}}),
    bencherlui_sup:start_link().

stop(_State) ->
    cowboy:stop_listener(bencherlui_http).
