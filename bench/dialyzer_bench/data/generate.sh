#!/bin/sh
#
# Generates the input of dialyzer_bench: the modules of some Erlang/OTP
# applications, compiled with debug_info, as Erlang/OTP installs them.
#
#   data/plt  the applications from which the benchmark builds a PLT
#   data/otp  the applications it then analyses, with that PLT
#
# The data is committed, so that every version of Erlang/OTP that runs the
# benchmark analyses the same code; this script is only needed to change it.
# The committed data comes from Erlang/OTP 29.1.2.
#
# usage: generate.sh [ERL]    (default: the erl in the path)

set -e

ERL=${1:-erl}

# parsetools is in the PLT, as stdlib refers to its types (yecc).
PLT_APPS="erts kernel stdlib compiler crypto public_key ssl inets asn1
          mnesia xmerl syntax_tools runtime_tools edoc dialyzer wx parsetools"
OTP_APPS="megaco snmp diameter debugger common_test ssh sasl observer tools
          eunit reltool os_mon et"

cd "$(dirname "$0")"

copy() {
    dir=$1; shift
    rm -rf "$dir"
    mkdir "$dir"
    for app in "$@"; do
        ebin=$("$ERL" -noshell -eval \
            "io:format(\"~s\", [filename:join(code:lib_dir($app), \"ebin\")]), halt().")
        cp "$ebin"/*.beam "$dir"/
    done
}

copy plt $PLT_APPS
copy otp $OTP_APPS

# Dialyzer needs the abstract code.
"$ERL" -noshell -eval '
    Missing = [B || B <- filelib:wildcard("{plt,otp}/*.beam"),
                    element(1, beam_lib:chunks(B, [debug_info])) =/= ok],
    case Missing of
        [] -> halt(0);
        _ -> io:format("No debug_info in: ~p~n", [Missing]), halt(1)
    end.'

echo "plt: $(ls plt | wc -l) modules, otp: $(ls otp | wc -l) modules," \
     "from Erlang/OTP $("$ERL" -noshell -eval \
         'io:format("~s", [erlang:system_info(otp_release)]), halt().')"
