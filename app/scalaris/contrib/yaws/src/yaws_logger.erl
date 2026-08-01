%%%----------------------------------------------------------------------
%%% File    : yaws_logger.erl
%%% Author  : Christopher Faulet <christopher@yakaz.com>
%%% Purpose :
%%% Created : 14 Dec 2010 by Christopher Faulet <christopher@yakaz.com>
%%%----------------------------------------------------------------------

-module(yaws_logger).
-author('christopher@yakaz.com').
-include_lib("kernel/include/file.hrl").


-export([behaviour_info/1]).

%% API
-export([
         open_log/3,
         close_log/2,
         close_logs/0,
         rotate/1,

         accesslog/6,
         authlog/4
        ]).


-include("../include/yaws.hrl").
-include("../include/yaws_api.hrl").
-include("yaws_debug.hrl").


-record(log, {id, amod, data}).

%%%----------------------------------------------------------------------
%%% API
%%%----------------------------------------------------------------------
behaviour_info(callbacks) ->
    [{open_log,3}, {close_log,3}, {wrap_log,4}, {write_log,4}];
behaviour_info(_Other) ->
    undefined.


open_log(SConf, auth, Dir) when ?sc_has_auth_log(SConf) ->
    do_open_log(SConf, auth, Dir);
open_log(SConf, access, Dir) when ?sc_has_access_log(SConf) ->
    do_open_log(SConf, access, Dir);
open_log(_, _, _) ->
    false.


close_log(SConf, Type) ->
    case ets:lookup(yaws_log, {Type, SConf#sconf.servername}) of
        [AL] ->
            do_close_log(AL),
            ets:delete(yaws_log, {Type, SConf#sconf.servername}),
            ok;
        [] ->
            ok
    end.


close_logs() ->
    do_close_logs(ets:first(yaws_log)),
    ets:delete_all_objects(yaws_log),
    ok.


rotate(LogWrapSize) ->
    do_rotate(ets:first(yaws_log), LogWrapSize).


accesslog(#sconf{servername=Srv}, Ip, Req, InH, OutH, Time) ->
    case ets:lookup(yaws_log, {access, Srv}) of
        [#log{amod=Mod, data=Data}] ->
            try Mod:write_log(Srv, access, Data, {Ip, Req, InH, OutH, Time}) catch throw:CaughtT1 -> CaughtT1; error:CaughtR1:CaughtS1 -> {'EXIT', {CaughtR1, CaughtS1}}; exit:CaughtR1 -> {'EXIT', CaughtR1} end;
        _ ->
            ok
    end.

authlog(#sconf{servername=Srv}, IP, Path, Item) ->
    case ets:lookup(yaws_log, {auth, Srv}) of
        [#log{amod=Mod, data=Data}] ->
            try Mod:write_log(Srv, auth, Data, {IP, Path, Item}) catch throw:CaughtT2 -> CaughtT2; error:CaughtR2:CaughtS2 -> {'EXIT', {CaughtR2, CaughtS2}}; exit:CaughtR2 -> {'EXIT', CaughtR2} end;
        _ ->
            ok
    end.

%%%----------------------------------------------------------------------
%%% Internal functions
%%%----------------------------------------------------------------------
do_open_log(#sconf{servername=Srv, logger_mod=Mod}, Type, Dir) ->
    case try Mod:open_log(Srv, Type, Dir) catch throw:CaughtT3 -> CaughtT3; error:CaughtR3:CaughtS3 -> {'EXIT', {CaughtR3, CaughtS3}}; exit:CaughtR3 -> {'EXIT', CaughtR3} end of
        {true, Data} ->
            AL = #log{id={Type, Srv}, amod=Mod, data=Data},
            ets:insert(yaws_log, AL),
            true;
        _ ->
            false
    end.


do_close_log(#log{id={Type, Srv}, amod=Mod, data=Data}) ->
    try Mod:close_log(Srv, Type, Data) catch throw:CaughtT4 -> CaughtT4; error:CaughtR4:CaughtS4 -> {'EXIT', {CaughtR4, CaughtS4}}; exit:CaughtR4 -> {'EXIT', CaughtR4} end.


do_close_logs('$end_of_table') ->
    ok;
do_close_logs(Id) ->
    [AL] = ets:lookup(yaws_log, Id),
    do_close_log(AL),
    do_close_logs(ets:next(yaws_log, Id)).


do_rotate('$end_of_table', _) ->
    ok;
do_rotate(Id, LogWrapSize) ->
    [#log{id={Type, Srv}, amod=Mod, data=Data}=AL] = ets:lookup(yaws_log, Id),
    Data1 = Mod:wrap_log(Srv, Type, Data, LogWrapSize),
    ets:insert(yaws_log, AL#log{data=Data1}).
