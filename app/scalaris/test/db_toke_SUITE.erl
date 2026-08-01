% @copyright 2010-2011 Zuse Institute Berlin

%   Licensed under the Apache License, Version 2.0 (the "License");
%   you may not use this file except in compliance with the License.
%   You may obtain a copy of the License at
%
%       http://www.apache.org/licenses/LICENSE-2.0
%
%   Unless required by applicable law or agreed to in writing, software
%   distributed under the License is distributed on an "AS IS" BASIS,
%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%   See the License for the specific language governing permissions and
%   limitations under the License.

%%% @author Nico Kruber <kruber@zib.de>
%%% @doc    Unit tests for src/db_toke.erl.
%%% @end
%% @version $Id: db_toke_SUITE.erl 1445 2011-02-23 11:34:29Z kruber@zib.de $
-module(db_toke_SUITE).

-author('kruber@zib.de').
-vsn('$Id: db_toke_SUITE.erl 1445 2011-02-23 11:34:29Z kruber@zib.de $').

-export([all/0, changed_keys/1, check_changes/3, check_changes2/4, check_db/5,
         check_db/6, check_db2/4, check_db2/5, check_entry/6,
         check_entry_in_changed_entries/5,
         check_entry_in_changed_entries_internal/5, check_entry_in_changes/5,
         check_key_in_deleted_internal/5, check_key_in_deleted_no_locks/5,
         check_keys_in_deleted/4, check_stop_record_changes/3,
         count_keys_in_range/2, create_db_entry/5, delete/1, end_per_suite/1,
         get_load_and_middle/1, get_random_interval_from_changes/1,
         inc_readlock/2, init_per_suite/1, max_rw_tests_per_suite/0,
         prop_add_data/1, prop_changed_keys_add_data/2,
         prop_changed_keys_check_db/2, prop_changed_keys_delete/3,
         prop_changed_keys_delete_entries1/3,
         prop_changed_keys_delete_entries2/3,
         prop_changed_keys_delete_entry/3, prop_changed_keys_get_data/2,
         prop_changed_keys_get_entries2/3, prop_changed_keys_get_entries4/3,
         prop_changed_keys_get_entry/3, prop_changed_keys_get_load/2,
         prop_changed_keys_get_load2/3, prop_changed_keys_mult_interval/5,
         prop_changed_keys_read/3, prop_changed_keys_set_entry/3,
         prop_changed_keys_split_data1/3, prop_changed_keys_split_data2/3,
         prop_changed_keys_update_entries/4, prop_changed_keys_update_entry/3,
         prop_changed_keys_write/5, prop_delete/6, prop_delete_chunk3/3,
         prop_delete_entries1/2, prop_delete_entries2/2, prop_delete_entry1/1,
         prop_delete_entry2/2, prop_get_chunk3/3, prop_get_entries2/2,
         prop_get_entries3_1/2, prop_get_entries3_2/2, prop_get_load2/2,
         prop_new/1, prop_reopen/1, prop_set_entry/1, prop_split_data/2,
         prop_stop_record_changes/5, prop_update_entries/2,
         prop_update_entries_helper/3, prop_update_entry/5, prop_write/4,
         read/1, rw_suite_runs/1, split_data/1, suite/0, tester_add_data/1,
         tester_changed_keys_add_data/1, tester_changed_keys_check_db/1,
         tester_changed_keys_delete/1, tester_changed_keys_delete_entries1/1,
         tester_changed_keys_delete_entries2/1,
         tester_changed_keys_delete_entry/1, tester_changed_keys_get_data/1,
         tester_changed_keys_get_entries2/1,
         tester_changed_keys_get_entries4/1, tester_changed_keys_get_entry/1,
         tester_changed_keys_get_load/1, tester_changed_keys_get_load2/1,
         tester_changed_keys_mult_interval/1, tester_changed_keys_read/1,
         tester_changed_keys_set_entry/1, tester_changed_keys_split_data1/1,
         tester_changed_keys_split_data2/1,
         tester_changed_keys_update_entries/1,
         tester_changed_keys_update_entry/1, tester_changed_keys_write/1,
         tester_delete/1, tester_delete_chunk3/1, tester_delete_entries1/1,
         tester_delete_entries2/1, tester_delete_entry1/1,
         tester_delete_entry2/1, tester_get_chunk3/1, tester_get_entries2/1,
         tester_get_entries3_1/1, tester_get_entries3_2/1, tester_get_load2/1,
         tester_new/1, tester_reopen/1, tester_set_entry/1,
         tester_split_data/1, tester_stop_record_changes/1,
         tester_update_entries/1, tester_update_entry/1, tester_write/1,
         tests_avail/0, update_entries/1, various_tests/1, write/1]).

-define(TEST_DB, db_toke).

-include("db_SUITE.hrl").

-ifdef(have_toke).
all() -> lists:append(tests_avail(), [tester_reopen]).
-else.
all() -> [].
-endif.

%% @doc Specify how often a read/write suite can be executed in order not to
%%      hit a timeout (depending on the speed of the DB implementation).
-spec max_rw_tests_per_suite() -> pos_integer().
max_rw_tests_per_suite() ->
    50.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% db_toke:open/1, db_toke getters
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-spec prop_reopen(Key::?RT:key()) -> true.
prop_reopen(Key) ->
    DB = db_toke:new(),
    FileName = db_toke:get_name(DB),
    check_db(DB, {true, []}, 0, [], "check_db_reopen_1"),
    ?equals(db_toke:read(DB, Key), {ok, empty_val, -1}),
    check_entry(DB, Key, db_entry:new(Key), {ok, empty_val, -1}, false, "check_entry_reopen_1"),
    db_toke:close(DB, false),
    DB2 = db_toke:open(FileName),
    check_db(DB2, {true, []}, 0, [], "check_db_reopen_1"),
    ?equals(db_toke:read(DB2, Key), {ok, empty_val, -1}),
    check_entry(DB2, Key, db_entry:new(Key), {ok, empty_val, -1}, false, "check_entry_reopen_1"),
    db_toke:close(DB2),
    true.

tester_reopen(_Config) ->
    tester:test(?MODULE, prop_reopen, 1, rw_suite_runs(10)).
