open OUnit2
open Lwt
open Cohttp
open Cohttp_lwt_unix
open Entity
open Alpaca

module TestClient = Make(Env.E)

open TestClient

let _ = close_all_positions ()
let _ = cancel_all_orders ()
let acct = get_account ()
let acct_config = get_account_config ()
let update_acct_config =
  update_account_config
    acct_config.dtbp_check
    acct_config.no_shorting
    acct_config.suspend_trade
    acct_config.trade_confirm_email
let orders = list_orders ()
let new_order = submit_order ~limit_price:1000. "AAPL" 1 "sell" "limit" "gtc"
let fetch_order = get_order new_order.id
let order_by_id = get_order_by_client_order_id "testing_order"
let position_list = list_positions ()
let aapl = get_asset "AAPL"
let barset = get_barset ~limit:50 ["AAPL"; "TSLA"] "minute"
let clock = get_clock ()

let basic = [
  "get order by client id" >::
  (fun _ -> assert_equal order_by_id.client_order_id "testing_order")
]

let suite =
  "test suite api"  >::: List.flatten [
    basic;
  ]

let _ = run_test_tt_main suite