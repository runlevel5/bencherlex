%%%----------------------------------------------------------------------
%%% File    : yaws_api.hrl
%%% Author  : Claes Wikstrom <klacke@hyber.org>
%%% Purpose :
%%% Created : 24 Jan 2002 by Claes Wikstrom <klacke@hyber.org>
%%%----------------------------------------------------------------------

-author('klacke@hyber.org').

-record(arg, {
          clisock :: any(),        %% the socket leading to the peer client
          client_ip_port :: any(), %% {ClientIp, ClientPort} tuple
          headers :: any(),        %% headers
          req :: any(),            %% request
          clidata :: any(),        %% The client data (as a binary in POST requests)
          server_path :: any(),    %% The normalized server path
                          %% (pre-querystring part of URI)
          querydata :: any(),      %% For URIs of the form ...?querydata
                          %%  equiv of cgi QUERY_STRING
          appmoddata :: any(),     %% (deprecated - use pathinfo instead) the remainder
                          %% of the path leading up to the query
          docroot :: any(),        %% Physical base location of data for this request
          docroot_mount :: any(),  %% virtual directory e.g /myapp/ that the docroot
                          %%  refers to.
          fullpath :: any(),       %% full deep path to yaws file
          cont :: any(),           %% Continuation for chunked multipart uploads
          state :: any(),          %% State for use by users of the out/1 callback
          pid :: any(),            %% pid of the yaws worker process
          opaque :: any(),         %% useful to pass static data
          appmod_prepath :: any(), %% (deprecated - use prepath instead) path in front
                          %%of: <appmod><appmoddata>
          prepath :: any(),        %% Path prior to 'dynamic' segment of URI.
                          %%  ie http://some.host/<prepath>/<script-point>/d/e
                          %% where <script-point> is an appmod mount point,
                          %% or .yaws,.php,.cgi,.fcgi etc script file.
          pathinfo :: any()        %% Set to '/d/e' when calling c.yaws for the request
                          %% http://some.host/a/b/c.yaws/d/e
                          %%  equiv of cgi PATH_INFO
         }).


-record(http_request, {method :: any(),
                       path :: any(),
                       version :: any()}).

-record(http_response, {version :: any(),
                        status :: any(),
                        phrase :: any()}).

-record(rewrite_response, {status :: any(),
                           headers = [] :: any(),
                           content = <<>> :: any()}).

-record(headers, {
          connection :: any(),
          accept :: any(),
          host :: any(),
          if_modified_since :: any(),
          if_match :: any(),
          if_none_match :: any(),
          if_range :: any(),
          if_unmodified_since :: any(),
          range :: any(),
          referer :: any(),
          user_agent :: any(),
          accept_ranges :: any(),
          cookie = [] :: any(),
          keep_alive :: any(),
          location :: any(),
          content_length :: any(),
          content_type :: any(),
          content_encoding :: any(),
          authorization :: any(),
          transfer_encoding :: any(),
          x_forwarded_for :: any(),
          other = [] :: any()   %% misc other headers
         }).




-record(url,
        {scheme :: any(),          %% undefined means not set
         host :: any(),            %% undefined means not set
         port :: any(),            %% undefined means not set
         path = [] :: any(),
         querypart = [] :: any()}).


-record(setcookie,{
            key :: any(),
            value :: any(),
            quoted :: any(),
            comment :: any(),
            comment_url :: any(),
            discard :: any(),
            domain :: any(),
            max_age :: any(),
            expires :: any(),
            path :: any(),
            port :: any(),
            secure :: any(),
            version :: any()}).


-record(redir_self, {
          host :: any(),        %% string() - our own host
          scheme :: any(),      %% http | https
          scheme_str :: any(),  %% "https://"  | "http://"
          port :: any(),        %% integer()  - our own port
          port_str :: any()     %% "" | ":<int>" - the optional port part
                       %%                 to append to the url
         }).

%% Corresponds to the frame sections as in
%% http://tools.ietf.org/html/draft-ietf-hybi-thewebsocketprotocol-08#section-4
%% plus 'data' and 'ws_state'
-record(ws_frame_info, {
	  fin :: any(),
	  rsv :: any(),
	  opcode :: any(),
	  masked :: any(),
	  masking_key :: any(),
	  length :: any(),
	  payload :: any(),
	  data :: any(),        %% The unmasked payload. Makes payload redundant.
	  ws_state :: any()     %% The ws_state after unframing this frame.
                       %% This is useful for the endpoint to know what type of
                       %% fragment a potentially fragmented message is.
	 }).

%----------------------------------------------------------------------
% The state of a WebSocket connection.
% This is held by the ws owner process and passed in calls to yaws_api.
%----------------------------------------------------------------------
-type frag_type() :: text
		   | binary
		   | none.  %% The WebSocket is not expecting continuation
                            %% of any fragmented message.
-record(ws_state, {
	  vsn :: integer(),                     % WebSocket version number
	  sock :: any(),                                 % gen_tcp or gen_ssl socket
	  frag_type :: frag_type()
	 }).
