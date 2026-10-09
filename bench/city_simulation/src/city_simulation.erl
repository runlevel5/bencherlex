-module(city_simulation).

-export([bench_args/2, run/3]).

bench_args(Version, _Conf) ->
	case Version of
		short -> [[tiny, brief]];
		intermediate -> [[small, short]];
		long -> [[medium, medium]]
	end.

%% Sim-Diasca stops its computing nodes at the end of each simulation, so each
%% iteration starts them first, with the script that pre_bench wrote, in a run
%% whose time is not recorded.
run([nodes_started,S,D|_], _, _) ->
	city_benchmarking_loading_test:run(S, D),
	{{done, standard}, ok};
run(_, _, Conf) ->
	{_, DataDir} = lists:keyfind(datadir, 1, Conf),
	Root = filename:dirname(filename:dirname(filename:dirname(DataDir))),
	Script = filename:join([Root, "scratch", "city_simulation_nodes.sh"]),
	"" = os:cmd(Script ++ " > /dev/null 2>&1 || echo failed"),
	{{continue, ignore}, nodes_started}.
