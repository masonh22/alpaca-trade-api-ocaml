open OUnit2
open Lwt
open Cohttp
open Cohttp_lwt_unix
open Entity
open Client_mine

module TestClient = Client_mine.Make(Env.E)

open TestClient

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
let order_by_id = get_order_by_client_order_id "order_for_testing"
let replaced_order = replace_order ~qty:2 new_order.id
let position_list = list_positions ()
let aapl = get_asset "AAPL"
let barset = get_barset ~limit:50 ["AAPL"; "TSLA"] "minute"
let clock = get_clock ()

let basic = [
  "update order test" >:: (fun _ -> assert_equal replaced_order.qty 2)
]

let suite =
  "test suite api"  >::: List.flatten [
    basic;
  ]

let _ = run_test_tt_main suite