%%%----------------------------------------------------------------------
%%% File    : yaws.hrl
%%% Author  : Claes Wikstrom <klacke@hyber.org>
%%% Purpose :
%%% Created : 16 Jan 2002 by Claes Wikstrom <klacke@hyber.org>
%%%----------------------------------------------------------------------

-author('klacke@hyber.org').



%% flags for gconfs
-define(GC_TTY_TRACE,                        1).
-define(GC_DEBUG,                            2).
-define(GC_COPY_ERRLOG,                      4).
-define(GC_BACKWARDS_COMPAT_PARSE,           8).
-define(GC_LOG_RESOLVE_HOSTNAME,            16).
-define(GC_FAIL_ON_BIND_ERR,                32).
-define(GC_PICK_FIRST_VIRTHOST_ON_NOMATCH,  64).
-define(GC_USE_FDSRV,                      128).
-define(GC_USE_OLD_SSL,                    256).



-define(GC_DEF, ?GC_FAIL_ON_BIND_ERR).

-define(gc_has_tty_trace(GC),
        ((GC#gconf.flags band ?GC_TTY_TRACE) /= 0)).
-define(gc_has_debug(GC),
        ((GC#gconf.flags band ?GC_DEBUG) /= 0)).
-define(gc_has_copy_errlog(GC),
        ((GC#gconf.flags band ?GC_COPY_ERRLOG) /= 0)).
-define(gc_log_has_resolve_hostname(GC),
        ((GC#gconf.flags band ?GC_LOG_RESOLVE_HOSTNAME) /= 0)).
-define(gc_fail_on_bind_err(GC),
        ((GC#gconf.flags band ?GC_FAIL_ON_BIND_ERR) /= 0)).
-define(gc_pick_first_virthost_on_nomatch(GC),
        ((GC#gconf.flags band ?GC_PICK_FIRST_VIRTHOST_ON_NOMATCH) /= 0)).
-define(gc_use_old_ssl(GC),
        ((GC#gconf.flags band ?GC_USE_OLD_SSL) /= 0)).

-define(gc_set_tty_trace(GC, Bool),
        GC#gconf{flags = yaws:flag(GC#gconf.flags,?GC_TTY_TRACE, Bool)}).
-define(gc_set_debug(GC, Bool),
        GC#gconf{flags = yaws:flag(GC#gconf.flags, ?GC_DEBUG, Bool)}).
-define(gc_set_copy_errlog(GC, Bool),
        GC#gconf{flags = yaws:flag(GC#gconf.flags, ?GC_COPY_ERRLOG, Bool)}).
-define(gc_log_set_resolve_hostname(GC, Bool),
        GC#gconf{flags = yaws:flag(GC#gconf.flags,
                                   ?GC_LOG_RESOLVE_HOSTNAME, Bool)}).
-define(gc_set_fail_on_bind_err(GC, Bool),
        GC#gconf{flags = yaws:flag(GC#gconf.flags,?GC_FAIL_ON_BIND_ERR,Bool)}).
-define(gc_set_pick_first_virthost_on_nomatch(GC, Bool),
        GC#gconf{flags = yaws:flag(GC#gconf.flags,
                                   ?GC_PICK_FIRST_VIRTHOST_ON_NOMATCH,Bool)}).
-define(gc_set_use_old_ssl(GC, Bool),
        GC#gconf{flags = yaws:flag(GC#gconf.flags,?GC_USE_OLD_SSL,Bool)}).



%% global conf
-record(gconf,{yaws_dir :: any(),           %% topdir of Yaws installation
               trace :: any(),              %% false | {true,http}|{true,traffic}
               flags = ?GC_DEF :: any(),    %% boolean flags
               logdir :: any(),
               ebin_dir = [] :: any(),
               runmods = [] :: any(),       %% runmods for entire server
               keepalive_timeout = 30000 :: any(),
               keepalive_maxuses = nolimit :: any(), %% nolimit or non negative integer
               max_num_cached_files = 400 :: any(),
               max_num_cached_bytes = 1000000 :: any(),  %% 1 MEG
               max_size_cached_file = 8000 :: any(),
               max_connections = nolimit :: any(), % max number of TCP connections
               process_options = [] :: any(),  % Override default connection handler
                                    % processes spawn options for
                                    % performance/memory tuning.  [] |
                                    % [{fullsweep_after,Number},
                                    % {min_heap_size, Size}] other options such
                                    % as monitor, link are ignored.
               large_file_chunk_size = 10240 :: any(),
               mnesia_dir = [] :: any(),
               log_wrap_size = 10000000 :: any(),  % wrap logs after 10M
               cache_refresh_secs = 30 :: any(),  % seconds  (auto zero when debug)
               include_dir = [] :: any(),    %% list of inc dirs for .yaws files
               phpexe = "/usr/bin/php-cgi" :: any(),  %% cgi capable php executable
               x_forwarded_for_log_proxy_whitelist = [] :: any(), % list of proxy server
                                    % ips we will replace with the last element
                                    % of the list in the X-Forwarded-For http
                                    % header in logs
               yaws :: any(),                % server string
               id = "default" :: any(),      % string identifying this instance of yaws
               enable_soap = false :: any(), % start yaws_soap_srv iff true
               soap_srv_mods = [] :: any(),  % a list of
                                    % {{Mod, Func}, WsdlFile, Prefix } |
                                    %        {{Mod, Func}, WsdlFile}
                                    % automatically setup in yaws_soap_srv init.
               ysession_mod = yaws_session_server :: any(), % storage module for ysession
               acceptor_pool_size = 8 :: any()              % size of acceptor proc pool
              }).



-record(ssl,
        {
         keyfile :: any(),
         certfile :: any(),
         verify = 0 :: any(),
         fail_if_no_peer_cert :: any(),
         depth = 1 :: any(),
         password :: any(),
         cacertfile :: any(),
         ciphers :: any(),
         cachetimeout :: any()}).


%% flags for sconfs
-define(SC_ACCESS_LOG,          1).
-define(SC_AUTH_LOG,            2).
-define(SC_ADD_PORT,            4).
-define(SC_STATISTICS,          8).
-define(SC_TILDE_EXPAND,        16).
-define(SC_DIR_LISTINGS,        32).
-define(SC_DEFLATE,             64).
-define(SC_DIR_ALL_ZIP,         128).
-define(SC_DAV,                 512).
-define(SC_FCGI_TRACE_PROTOCOL, 1024).
-define(SC_FCGI_LOG_APP_ERROR,  2048).
-define(SC_FORWARD_PROXY,       4096).
-define(SC_AUTH_SKIP_DOCROOT,   8192).



-define(SC_DEF, ?SC_ACCESS_LOG bor ?SC_ADD_PORT bor ?SC_AUTH_LOG).

-define(sc_has_access_log(SC),
        (((SC)#sconf.flags band ?SC_ACCESS_LOG) /= 0)).
-define(sc_has_auth_log(SC),
        (((SC)#sconf.flags band ?SC_AUTH_LOG) /= 0)).
-define(sc_has_add_port(SC),
        (((SC)#sconf.flags band ?SC_ADD_PORT) /= 0)).
-define(sc_has_statistics(SC),
        (((SC)#sconf.flags band ?SC_STATISTICS) /= 0)).
-define(sc_has_tilde_expand(SC),
        (((SC)#sconf.flags band ?SC_TILDE_EXPAND) /= 0)).
-define(sc_has_dir_listings(SC),
        (((SC)#sconf.flags band ?SC_DIR_LISTINGS) /= 0)).
-define(sc_has_deflate(SC),
        (((SC)#sconf.flags band ?SC_DEFLATE) /= 0)).
-define(sc_has_dir_all_zip(SC),
        (((SC)#sconf.flags band ?SC_DIR_ALL_ZIP) /= 0)).
-define(sc_has_dav(SC),
        (((SC)#sconf.flags band ?SC_DAV) /= 0)).
-define(sc_fcgi_trace_protocol(SC),
        (((SC)#sconf.flags band ?SC_FCGI_TRACE_PROTOCOL) /= 0)).
-define(sc_fcgi_log_app_error(SC),
        (((SC)#sconf.flags band ?SC_FCGI_LOG_APP_ERROR) /= 0)).
-define(sc_forward_proxy(SC),
        (((SC)#sconf.flags band ?SC_FORWARD_PROXY) /= 0)).
-define(sc_auth_skip_docroot(SC),
        (((SC)#sconf.flags band ?SC_AUTH_SKIP_DOCROOT) /= 0)).


-define(sc_set_access_log(SC, Bool),
        SC#sconf{flags = yaws:flag(SC#sconf.flags, ?SC_ACCESS_LOG, Bool)}).
-define(sc_set_auth_log(SC, Bool),
        SC#sconf{flags = yaws:flag(SC#sconf.flags, ?SC_AUTH_LOG, Bool)}).
-define(sc_set_add_port(SC, Bool),
        SC#sconf{flags = yaws:flag(SC#sconf.flags, ?SC_ADD_PORT, Bool)}).
-define(sc_set_statistics(SC, Bool),
        SC#sconf{flags = yaws:flag(SC#sconf.flags, ?SC_STATISTICS, Bool)}).
-define(sc_set_ssl(SC, Bool),
        SC#sconf{flags = yaws:flag(SC#sconf.flags, ?SC_SSL, Bool)}).
-define(sc_set_tilde_expand(SC, Bool),
        SC#sconf{flags = yaws:flag(SC#sconf.flags, ?SC_TILDE_EXPAND, Bool)}).
-define(sc_set_dir_listings(SC, Bool),
        SC#sconf{flags = yaws:flag(SC#sconf.flags, ?SC_DIR_LISTINGS, Bool)}).
-define(sc_set_deflate(SC, Bool),
        SC#sconf{flags = yaws:flag(SC#sconf.flags, ?SC_DEFLATE, Bool)}).
-define(sc_set_dir_all_zip(SC, Bool),
        SC#sconf{flags = yaws:flag(SC#sconf.flags, ?SC_DIR_ALL_ZIP, Bool)}).
-define(sc_set_dav(SC, Bool),
        SC#sconf{flags = yaws:flag(SC#sconf.flags, ?SC_DAV, Bool)}).
-define(sc_set_fcgi_trace_protocol(SC, Bool),
        SC#sconf{flags = yaws:flag(SC#sconf.flags, ?SC_FCGI_TRACE_PROTOCOL,
                                   Bool)}).
-define(sc_set_fcgi_log_app_error(SC, Bool),
        SC#sconf{flags = yaws:flag(SC#sconf.flags, ?SC_FCGI_LOG_APP_ERROR,
                                   Bool)}).
-define(sc_set_forward_proxy(SC, Bool),
        SC#sconf{flags = yaws:flag(SC#sconf.flags, ?SC_FORWARD_PROXY, Bool)}).
-define(sc_set_auth_skip_docroot(SC, Bool),
        SC#sconf{flags = yaws:flag(SC#sconf.flags,?SC_AUTH_SKIP_DOCROOT,Bool)}).



%% server conf
-record(sconf,
        {port = 8000 :: any(),                %% which port is this server listening to
         flags = ?SC_DEF :: any(),
         redirect_map=[] :: any(),            %% a list of
                                     %% {Prefix, #url{}, append|noappend}
                                     %% #url{} can be partially populated

         rhost :: any(),                      %% forced redirect host (+ optional port)
         rmethod :: any(),                    %% forced redirect method
         docroot :: any(),                    %% path to the docs
         xtra_docroots = [] :: any(),         %% if we have additional pseudo docroots
         listen = [{127,0,0,1}] :: any(),     %% bind to this IP, {0,0,0,0} is possible
         servername = "localhost" :: any(),   %% servername is what Host: header is
         ets :: any(),                        %% local store for this server
         ssl :: any(),                        %% undefined | #ssl{}
         authdirs = [] :: any(),
         partial_post_size = 10240 :: any(),
         appmods = [] :: any(),
         %%  An item in the appmods list  can be either of the
         %% following, this is all due to backwards compat issues.
         %% 1.  an atom - this is the equivalent to {atom, atom}
         %% 2 . A two tuple {Path, Mod}
         %% 3 A three tuple {Path, Mod, [ExcludeDir ....]}

         expires = [] :: any(),
         errormod_401 = yaws_outmod :: any(),     %% the default 401 error module
         errormod_404 = yaws_outmod :: any(),     %% the default 404 error module
         errormod_crash = yaws_outmod :: any(),   %% use the same module for crashes
         arg_rewrite_mod = yaws :: any(),
         logger_mod = yaws_log :: any(),          %% access/auth logging module
         opaque = [] :: any(),                    %% useful in embedded mode
         start_mod :: any(),                      %% user provided module to be started
         allowed_scripts = [yaws,php,cgi,fcgi] :: any(),
         tilde_allowed_scripts = [] :: any(),
         revproxy = [] :: any(),
         soptions = [] :: any(),
         extra_cgi_vars = [] :: any(),
	 stats :: any(),                       %% raw traffic statistics
         fcgi_app_server :: any(),             %% FastCGI application server {host,port}
         php_handler = {cgi, "/usr/bin/php-cgi"} :: any(),
         shaper :: any()
        }).

%% we cannot compare sconfs directly due to the ets
%% field in #sconf{} use yaws_config:eq_sconfs/2


% Auth conf - from server conf and .yaws_auth
-record(auth,
         {dir = [] :: any(),
          docroot = [] :: any(),
          files = [] :: any(),
          realm = "" :: any(),
          type = "Basic" :: any(),
          headers = [] :: any(),  %% headers to send on 401
          users = [] :: any(),   %% list of {User, Password} tuples
          acl = none :: any(),    %% list of allowed/denies IPs or none
          mod = [] :: any(),     %% authentication module callback
          outmod = [] :: any(),   %% module to handles 401 unauthorized messages
          pam = false :: any()   %% should we use pam to auth a user
         }).



%% this internal record is used and returned by the URL path parser


-record(urltype, {type :: any(),   %% error | yaws | regular | directory |
                          %% forbidden | appmod
                  finfo :: any(),
                  path = [] :: any(),
                  fullpath = [] :: any(), %% deep list (WHY?)
                  dir = [] :: any(),      %% relative dir where the path leads to
                                 %% flat | unflat need flat for authentication
                  data :: any(),          %% type-specific e.g: Binary | FileDescriptor
                                 %% | DirListing | undefined
                  deflate :: any(),       %% undefined | Binary | dynamic
                  mime = "text/html" :: any(),    %% MIME type
                  getpath :: any(),       %% as GET'ed by client
                  pathinfo :: any()
                 }).




%% this record is constructed as we build up
%% the outgoing headers

-record(outh, {
          status :: any(),        %% int status code

          doclose :: any(),       %% bool
          chunked :: any(),       %% bool
          exceedmaxuses=false :: any(),
                         %% bool, true if hit keep-alive max uses
          encoding=identity :: any(),
                         %% identity, deflate
          contlen :: any(),       %% integer
          act_contlen :: any(),   %% actual content length for dynamic pages


                         %% and the total set of out headers we can have
                         %% as actual strings
          connection :: any(),
          server :: any(),
          location :: any(),
          cache_control :: any(),
          expires :: any(),
          date :: any(),
          allow :: any(),
          last_modified :: any(),
          etag :: any(),
          set_cookie :: any(),
          content_range :: any(),
          content_length :: any(),
          content_type :: any(),
          content_encoding :: any(),
          transfer_encoding :: any(),
          www_authenticate :: any(),
          other :: any()     %% misc other headers
}).






%% as read by application:get_env()
-record(env, {debug :: any(),
              trace :: any(),
              traceoutput :: any(),
              conf :: any(),
              runmod :: any(),
              embedded :: any(),
              id :: any()
             }).

%% Typically used in error printouts as in:
%% error_logger:format("Err ~p at ~p~n", [Reason, ?stack()])
-define(stack(), try throw(1) catch _:_ -> erlang:get_stacktrace() end).


%%% The following is for emacs, do not remove
%%% Local Variables:
%%% comment-column: 36
%%% End:
