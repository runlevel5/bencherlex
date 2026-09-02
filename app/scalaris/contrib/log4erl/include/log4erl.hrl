-define(ROTATION_CHECK, 10).

-define(DEFAULT_CONF,"log4erl.conf").

-define(DEFAULT_FORMAT, "[%L] %l%n").

-define(DEFAULT_LEVEL, warn).

-define(DEFAULT_LOGGER, default_logger).
-define(DEFAULT_LOGGER_GUARD, default_logger_guard).

-define(FILE_OPTIONS,[write, raw, binary, delayed_write]).
-define(FILE_OPTIONS_ROTATE,[write, raw, binary, delayed_write]).

%-define(DEBUG, true).

-ifdef(DEBUG).
-define(LOG(X), io:format("~p: " ++ X,[?MODULE])).
-define(LOG2(X,D), io:format("~p: " ++ X,[?MODULE | D])).
-else.
-define(LOG(_X), ok).
-define(LOG2(_X,_D), ok).
-endif.


%% type = time | size
%% max = seconds (for time) | or kiloBytes (for size)
-record(log_type,{type :: any(), max :: any(), timer :: any()}).

%% file_name = the name of the file without counter 
%% fd = the descriptior for the file
%% counter = current counter, used for appending to file_name in case of rotation
%% log_type is a log_type record
%% rotation = number of rotation before the logger wraps around the coutner (>1)
%% suffix = suffix of file name (e.g. txt)
%% The filename of a log is file_name ++ "_" ++ counter ++ "." ++ suffix
%% e.g. log_1.txt
%% tokens = format tokens generated from log_formatter:parse/1
-record(file_appender, {dir :: any(), file_name :: any(), fd :: any(), counter :: any(), log_type :: any(), rotation :: any(), suffix :: any(), level :: any(), format=?DEFAULT_FORMAT :: any()}).

-record(console_appender, {level=?DEFAULT_LEVEL :: any(), format=?DEFAULT_FORMAT :: any()}).

-record(rotation_state, {state :: any(), timer :: any()}).

-record(smtp_appender, {level=?DEFAULT_LEVEL :: any(), srvr_opts :: any(), auth_opts :: any(), msg_opts :: any()}).
-record(srvr_opts, {ip :: any(), port :: any()}).
-record(auth_opts, {username :: any(), password :: any()}).
-record(msg_opts, {from :: any(), to :: any(), title :: any(), msg=?DEFAULT_FORMAT :: any()}).

-record(syslog_appender, {level=?DEFAULT_LEVEL :: any(), facility=user :: any(),host :: any(),port=415 :: any(), socket :: any(), format=?DEFAULT_FORMAT :: any()}).

%% log record
-record(log, {level :: any(), msg :: any(), data :: any(), time :: any(), millis :: any()}).
