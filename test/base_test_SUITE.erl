-module(base_test_SUITE).
-compile(export_all).
-define(PID, emqx_persistence_plugin).
-define(APP, emqx_persistence_plugin).
-include_lib("emqx/include/emqx.hrl").
-include_lib("eunit/include/eunit.hrl").
-include_lib("common_test/include/ct.hrl").

all() -> emqx_ct:all(?MODULE).

init_per_suite(Config) ->
    emqx_ct_helpers:start_apps([emqx_persistence_plugin]),
    Config.

end_per_suite(_) ->
    emqx_ct_helpers:stop_apps([emqx_persistence_plugin]),
    ok.

t_client_id_test(_Config) ->
    {ok, C1} = emqtt:start_link([{host, "127.0.0.1"} ,
                                 {clientid, <<"clientid1">>},
                                 {username, <<"username">>},
                                 {password, <<"password">>}]),
    {ok, _} = emqtt:connect(C1),
    {ok, C2} = emqtt:start_link([{host, "127.0.0.1"} ,
                                 {clientid, <<"clientid2">>},
                                 {username, <<"username">>},
                                 {password, <<"password">>}]),
    {ok, _} = emqtt:connect(C2),
    emqtt:subscribe(C2, <<"$WITH_CLIENTID/test">>, qos0),
    emqtt:publish(C1, <<"$WITH_CLIENTID/test">>, <<"ok">>, qos2),
    receive
        {publish, #message{topic = <<"$WITH_CLIENTID/test">>,
                           payload = Payload}} -> <<"clientid1#ok">> = Payload;
        _ -> ok
    end,
    emqtt:disconnect(C1),
    emqtt:disconnect(C2).