%% Serves the results of benchmark runs, read from the results directory, as
%% JSON:
%%
%%   /results/benchmark_runs_json      the runs, newest first
%%   /results/benchmarks_for_run       the benchmarks of run=Run
%%   /results/measurement_files        the measurement files of run=Run and
%%                                     benchmark=Benchmark
%%   /results/benchmark_results        the contents of measurementFile=File

-module(bencherlui_results_handler).

-export([init/2]).

init(Req0, State) ->
    Query = cowboy_req:binding(query, Req0),
    Params = cowboy_req:parse_qs(Req0),
    Req = try reply(Query, Params) of
              {ok, Json} ->
                  cowboy_req:reply(200,
                                   #{<<"content-type">> => <<"application/json">>},
                                   Json, Req0);
              not_found ->
                  cowboy_req:reply(404, Req0)
          catch
              throw:bad_name ->
                  cowboy_req:reply(400, Req0)
          end,
    {ok, Req, State}.

reply(<<"benchmark_runs_json">>, _) ->
    {ok, rfc4627:encode({obj, [{benchmark_runs, benchmark_run_list()}]})};
reply(<<"benchmarks_for_run">>, Params) ->
    {ok, rfc4627:encode(benchmark_list_for_name(param(<<"run">>, Params)))};
reply(<<"measurement_files">>, Params) ->
    MeasurementDir = measurement_dir(Params),
    {ok, rfc4627:encode(
           [list_to_binary(lists:sublist(Name, length(Name) - length(".time")))
            || Name <- measurement_file_list(MeasurementDir)])};
reply(<<"benchmark_results">>, Params) ->
    FileName = filename:join(measurement_dir(Params),
                             param(<<"measurementFile">>, Params) ++ ".time"),
    {ok, result_file_to_json_text(FileName)};
reply(_, _) ->
    not_found.

%% A parameter naming a file or directory in the results directory. It must
%% be a plain name, so that requests cannot reach other files.
param(Key, Params) ->
    case proplists:get_value(Key, Params) of
        Value when is_binary(Value) ->
            Name = binary_to_list(Value),
            case Name =/= "" andalso Name =/= "." andalso Name =/= ".."
                 andalso not lists:member($/, Name) of
                true -> Name;
                false -> throw(bad_name)
            end;
        _ ->
            throw(bad_name)
    end.

results_dir() ->
    {ok, Dir} = application:get_env(bencherlui, results_dir),
    Dir.

measurement_dir(Params) ->
    filename:join([results_dir(), param(<<"run">>, Params),
                   param(<<"benchmark">>, Params), "measurements"]).

list_of_files_in_dir(DirPath) ->
    FileNameList =
        case file:list_dir(DirPath) of
            {ok, FNList} -> FNList;
            {error, _} -> []
        end,
    lists:filter(
             fun(Name) -> Name /= ".gitignore" end,
             FileNameList).

string_date_to_date_tuple(String) ->
    DatePattern = "^(\\d\\d)\.(\\d\\d)\.(\\d\\d)\.-(\\d\\d)\.(\\d\\d)\.(\\d\\d)",
    case re:run(String, DatePattern) of
        {match, [_|Positions]} ->
            [Day,Month,Year,Hour,Minute,Second] =
                [element(1,
                         string:to_integer(lists:sublist(String, Start+1, Len)))
                 || {Start, Len} <- Positions],
            {ok, {Year,Month,Day,Hour,Minute,Second}};
        _ ->
            {not_date_string, String}
    end.

benchmark_run_list() ->
    UnsortedListOfFiles = list_of_files_in_dir(results_dir()),
    SortedListOfFiles =
        lists:sort(
          fun(A,B) ->
                  string_date_to_date_tuple(A) > string_date_to_date_tuple(B)
          end,
          UnsortedListOfFiles),
    [list_to_binary(Name) || Name <- SortedListOfFiles].

benchmark_list_for_name(RunName) ->
    UnsortedFileList = list_of_files_in_dir(filename:join(results_dir(), RunName)),
    SortedFileList = lists:sort(UnsortedFileList),
    [list_to_binary(Name) || Name <- SortedFileList].

add_line_to_dict(Line, Dict) ->
    Toks = re:split(Line, [$\t], [{return,list}]),
    [Name, Params, SchedsStr | Times ] = Toks,
    [TimeStr | _ ] = Times,
    {Scheds, _} = string:to_integer(SchedsStr),
    {Time, _} = string:to_float(TimeStr),
    orddict:append(Name++Params, [Scheds, Time], Dict).

result_file_to_dict(FileName) ->
    Lines = readlines(FileName),
    lists:foldl(
      fun(Line, Dict) ->
              add_line_to_dict(Line, Dict)
      end,
      orddict:new(),
      Lines).

result_file_to_json_text(FileName) ->
    Dict = result_file_to_dict(FileName),
    List = lists:map(
             fun({Label, Data}) ->
                     dict:append_list(
                       data, Data,
                       dict:append_list(
                         label, binary:replace(list_to_binary(Label),<<"\"">>, <<"'">>, [global]),
                         dict:new()))
             end,
             orddict:to_list(Dict)),
    rfc4627:encode(List).

count_periods_in_string([]) ->
    0;
count_periods_in_string([$.|Rest]) ->
    1 + count_periods_in_string(Rest);
count_periods_in_string([_|Rest]) ->
    count_periods_in_string(Rest).

measurement_file_list(MeasurementDir) ->
    {ok, FileNameList} =
        file:list_dir(MeasurementDir),
    FilteredList = lists:filter(
                     fun(Name) ->
                             case re:run(Name, "time$") of
                                 {match, _} -> true;
                                 _ -> false
                             end
                     end,
                     FileNameList),
    lists:sort(
          fun(A,B) ->
                  NrOfPeriodsA = count_periods_in_string(A),
                  NrOfPeriodsB = count_periods_in_string(B),
                  case {NrOfPeriodsA, NrOfPeriodsB} of
                      {C1, C2} when C1 =:= C2 -> A < B;
                      {C1, C2} -> C1 < C2
                  end
          end,
          FilteredList).

readlines(FileName) ->
    {ok, Device} = file:open(FileName, [read]),
    try get_all_lines(Device)
    after file:close(Device)
    end.

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof  -> [];
        Line -> [Line|get_all_lines(Device)]
    end.
