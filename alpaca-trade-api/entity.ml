open Yojson.Basic.Util
open Fieldslib

type account = {
  id: string;
  created_at: string; (* time type? *)
  account_number: string;
  status: string;
  currency: Common.currency;
  cash: float;
  portfolio_value: float;
  pattern_day_trader: bool;
  trade_suspended_by_user: bool;
  trading_blocked: bool;
  transfers_blocked: bool;
  account_blocked: bool;
  shorting_enabled: bool;
  long_market_value: float;
  short_market_value: float;
  equity: float;
  last_equity: float;
  multiplier: int;
  buying_power: float;
  initial_margin: float;
  maintenance_margin: float;
  last_maintenance_margin: float;
  sma: int;
  daytrade_count: int;
  daytrading_buying_power: float;
  regt_buying_power: float;
}

type order = {
  id: string; (*uuid*)
  client_order_id: string;
  created_at: string;
  updated_at: string option;
  submitted_at: string option;
  filled_at: string option;
  expired_at: string option;
  cancelled_at: string option;
  failed_at: string option;
  replaced_at: string option;
  replaced_by: string option; (*uuid*)
  replaces: string option; (*uuid*)
  asset_id: string; (*uuid*)
  symbol: string;
  asset_class: string;
  qty: int;
  filled_qty: int;
  filled_avg_price: float option;
  typ: string; (*order type*)
  side: string; (*side*)
  time_in_force: string; (*time in force*)
  limit_price: float option;
  stop_price: float option;
  status: string; (*ord status*)
  extended_hours: bool;
  legs: order list; (*non-simple orders associated with*)
}

type config = {
  dtbp_check: string;
  no_shorting: bool;
  suspend_trade: bool;
  trade_confirm_email: string;
}

type position = {
  asset_id: string;
  symbol: string;
  exchange: string;
  asset_class: string;
  avg_entry_price: float;
  qty: int;
  side: string;
  market_value: float;
  cost_basis: float;
  unrealized_pl: float;
  unrealized_plpc: float;
  unrealized_intraday_pl: float;
  unrealized_intraday_plpc: float;
  current_price: float;
  lastday_price: float;
  change_today: float;
}

type asset = {
  id: string;
  asset_class: string; (*class*)
  exchange: string; (*make variant*)
  symbol: string;
  status: string; (*make variant*)
  tradable: bool;
  marginable: bool;
  shortable: bool;
  easy_to_borrow: bool;
}

type bar = {
  t: int;
  o: float;
  h: float;
  l: float;
  c: float;
  v: int;
}

type clock = {
  timestamp: string;
  is_open: bool;
  next_open: string;
  next_close: string;
}

let member_to_string j id =
  member id j |> to_string

let member_to_int j id =
  member id j |> to_int

let member_to_float j id =
  member id j |> to_number

let member_to_bool j id =
  member id j |> to_bool

let member_to_int_string j id =
  member id j |> to_string |> int_of_string

let member_to_float_string j id =
  member id j |> to_string |> float_of_string

let member_to_float_string_option j id =
  match member id j |> to_string_option with
  | Some str -> Some (float_of_string str)
  | None -> None

let member_to_string_option j id =
  member id j |> to_string_option

let account_of_json j = {
  id =
    member_to_string j "id";
  created_at =
    member_to_string j "created_at";
  account_number =
    member_to_string j "account_number";
  status =
    member_to_string j "status";
  currency =
    member_to_string j "currency" |> Common.currency_of_string;
  cash =
    member_to_float_string j "cash";
  portfolio_value =
    member_to_float_string j "portfolio_value";
  pattern_day_trader =
    member_to_bool j "pattern_day_trader";
  trade_suspended_by_user =
    member_to_bool j "trade_suspended_by_user";
  trading_blocked =
    member_to_bool j "trading_blocked";
  transfers_blocked =
    member_to_bool j "transfers_blocked";
  account_blocked =
    member_to_bool j "account_blocked";
  shorting_enabled =
    member_to_bool j "shorting_enabled";
  long_market_value =
    member_to_float_string j "long_market_value";
  short_market_value =
    member_to_float_string j "short_market_value";
  equity =
    member_to_float_string j "equity";
  last_equity =
    member_to_float_string j "last_equity";
  multiplier =
    member_to_int_string j "multiplier";
  buying_power =
    member_to_float_string j "buying_power";
  initial_margin =
    member_to_float_string j "initial_margin";
  maintenance_margin =
    member_to_float_string j "maintenance_margin";
  last_maintenance_margin =
    member_to_float_string j "last_maintenance_margin";
  sma =
    member_to_int_string j "sma";
  daytrade_count =
    member_to_int j "daytrade_count";
  daytrading_buying_power =
    member_to_float_string j "daytrading_buying_power";
  regt_buying_power =
    member_to_float_string j "regt_buying_power";
}

let order_of_json j = {
  id =
    member_to_string j "id";
  client_order_id =
    member_to_string j "client_order_id";
  created_at =
    member_to_string j "created_at";
  updated_at =
    member_to_string_option j "updated_at";
  submitted_at =
    member_to_string_option j "submitted_at";
  filled_at =
    member_to_string_option j "filled_at";
  expired_at =
    member_to_string_option j "expired_at";
  cancelled_at =
    member_to_string_option j "cancelled_at";
  failed_at =
    member_to_string_option j "failed_at";
  replaced_at =
    member_to_string_option j "replaced_at";
  replaced_by =
    member_to_string_option j "replaced_by";
  replaces =
    member_to_string_option j "replaces";
  asset_id =
    member_to_string j "asset_id";
  symbol =
    member_to_string j "symbol";
  asset_class =
    member_to_string j "asset_class";
  qty =
    member_to_int_string j "qty";
  filled_qty =
    member_to_int_string j "filled_qty";
  filled_avg_price =
    member_to_float_string_option j "filled_avg_price";
  typ =
    member_to_string j "type";
  side =
    member_to_string j "side";
  time_in_force =
    member_to_string j "time_in_force";
  limit_price =
    member_to_float_string_option j "limit_price";
  stop_price =
    member_to_float_string_option j "stop_price";
  status =
    member_to_string j "status";
  extended_hours =
    member_to_bool j "extended_hours";
  legs =
    []; (*for now*)
}

let config_of_json j = {
  dtbp_check =
    member_to_string j "dtbp_check";
  no_shorting =
    member_to_bool j "no_shorting";
  suspend_trade =
    member_to_bool j "suspend_trade";
  trade_confirm_email =
    member_to_string j "trade_confirm_email";
}

let position_of_json j = {
  asset_id =
    member_to_string j "asset_id";
  symbol =
    member_to_string j "symbol";
  exchange =
    member_to_string j "exchange";
  asset_class =
    member_to_string j "asset_class";
  avg_entry_price =
    member_to_float_string j "avg_entry_price";
  qty =
    member_to_int_string j "qty";
  side =
    member_to_string j "side";
  market_value =
    member_to_float_string j "market_value";
  cost_basis =
    member_to_float_string j "cost_basis";
  unrealized_pl =
    member_to_float_string j "unrealized_pl";
  unrealized_plpc =
    member_to_float_string j "unrealized_plpc";
  unrealized_intraday_pl =
    member_to_float_string j "unrealized_intraday_pl";
  unrealized_intraday_plpc =
    member_to_float_string j "unrealized_intraday_plpc";
  current_price =
    member_to_float_string j "current_price";
  lastday_price =
    member_to_float_string j "lastday_price";
  change_today =
    member_to_float_string j "change_today";
}

let asset_of_json j = {
  id =
    member_to_string j "id";
  asset_class =
    member_to_string j "class";
  exchange =
    member_to_string j "exchange";
  symbol =
    member_to_string j "symbol";
  status =
    member_to_string j "status";
  tradable =
    member_to_bool j "tradable";
  marginable =
    member_to_bool j "marginable";
  shortable =
    member_to_bool j "shortable";
  easy_to_borrow =
    member_to_bool j "easy_to_borrow";
}

let bar_of_json j = {
  t = member_to_int j "t";
  o = member_to_float j "o";
  h = member_to_float j "h";
  l = member_to_float j "l";
  c = member_to_float j "c";
  v = member_to_int j "v";
}

let clock_of_json j = {
  timestamp = member_to_string j "timestamp";
  is_open = member_to_bool j "is_open";
  next_open = member_to_string j "next_open";
  next_close = member_to_string j "next_close";
}

let strip_str = function
  | Some str -> str
  | None -> "null"

let strip_float = function
  | Some float -> string_of_float float
  | None -> "null"

let string_of_account (act : account) =
  "id: " ^ act.id
  ^ "\ncreated at: " ^ act.created_at
  ^ "\naccount number: " ^ act.account_number
  ^ "\nstatus: " ^ act.status
  ^ "\ncurrency: " ^ Common.to_string act.currency
  ^ "\ncash: " ^ string_of_float act.cash
  ^ "\nportfolio value: " ^ string_of_float act.portfolio_value
  ^ "\npattern day trader: " ^ string_of_bool act.pattern_day_trader
  ^ "\ntrade suspended by user: " ^ string_of_bool act.trade_suspended_by_user
  ^ "\ntrading blocked: " ^ string_of_bool act.trading_blocked
  ^ "\ntransfers blocked: " ^ string_of_bool act.transfers_blocked
  ^ "\naccount blocked: " ^ string_of_bool act.account_blocked
  ^ "\nshorting enabled: " ^ string_of_bool act.shorting_enabled
  ^ "\nlong market value: " ^ string_of_float act.long_market_value
  ^ "\nshort market value: " ^ string_of_float act.short_market_value
  ^ "\nequity: " ^ string_of_float act.equity
  ^ "\nlast equity: " ^ string_of_float act.last_equity
  ^ "\nmultiplier: " ^ string_of_int act.multiplier
  ^ "\nbuying power: " ^ string_of_float act.buying_power
  ^ "\ninitial margin: " ^ string_of_float act.initial_margin
  ^ "\nmaintenance margin: " ^ string_of_float act.maintenance_margin
  ^ "\nlast maintenance margin: " ^ string_of_float act.last_maintenance_margin
  ^ "\nsma: " ^ string_of_int act.sma
  ^ "\ndaytrade count: " ^ string_of_int act.daytrade_count
  ^ "\ndaytrading buying power: " ^ string_of_float act.daytrading_buying_power
  ^ "\nregt buying power: " ^ string_of_float act.regt_buying_power

let string_of_order (ord : order) =
  "id: " ^ ord.id
  ^ "\nclient order id: " ^ ord.client_order_id
  ^ "\ncreated at: " ^ ord.created_at
  ^ "\nupdated at: " ^ strip_str ord.updated_at
  ^ "\nsubmitted at: " ^ strip_str ord.submitted_at
  ^ "\nfilled at: " ^ strip_str ord.filled_at
  ^ "\nexpired at: " ^ strip_str ord.expired_at
  ^ "\ncancelled at: " ^ strip_str ord.cancelled_at
  ^ "\nfailed at: " ^ strip_str ord.failed_at
  ^ "\nreplaced at: " ^ strip_str ord.replaced_at
  ^ "\nreplaced by: " ^ strip_str ord.replaced_by
  ^ "\nreplaces: " ^ strip_str ord.replaces
  ^ "\nasset id: " ^ ord.asset_id
  ^ "\nsymbol: " ^ ord.symbol
  ^ "\nasset class: " ^ ord.asset_class
  ^ "\nqty: " ^ string_of_int ord.qty
  ^ "\nfilled qty: " ^ string_of_int ord.filled_qty
  ^ "\nfilled avg price: " ^ strip_float ord.filled_avg_price
  ^ "\ntype: " ^ ord.typ
  ^ "\nside: " ^ ord.side
  ^ "\ntime in force: " ^ ord.time_in_force
  ^ "\nlimit price: " ^ strip_float ord.limit_price
  ^ "\nstop price: " ^ strip_float ord.stop_price
  ^ "\nstatus: " ^ ord.status
  ^ "\nextended hours: " ^ string_of_bool ord.extended_hours
  ^ "\nlegs: " ^ "not implemented"

let string_of_config (cfg : config) =
  "dtbp check: " ^ cfg.dtbp_check
  ^ "\nno shorting: " ^ string_of_bool cfg.no_shorting
  ^ "\nsuspend trade: " ^ string_of_bool cfg.suspend_trade
  ^ "\ntrade_confirm_email: " ^ cfg.trade_confirm_email

let string_of_position (psn : position) =
  "asset id: " ^ psn.asset_id
  ^ "\nsymbol: " ^ psn.symbol
  ^ "\nexchange: " ^ psn.exchange
  ^ "\nasset class: " ^ psn.asset_class
  ^ "\navg entry price: " ^ string_of_float psn.avg_entry_price
  ^ "\nqty: " ^ string_of_int psn.qty
  ^ "\nside: " ^ psn.side
  ^ "\nmarket value: " ^ string_of_float psn.market_value
  ^ "\ncost basis: " ^ string_of_float psn.cost_basis
  ^ "\nunrealized_pl: " ^ string_of_float psn.unrealized_pl
  ^ "\nunrealized_plpc: " ^ string_of_float psn.unrealized_plpc
  ^ "\nunrealized_plpc: " ^ string_of_float psn.unrealized_plpc
  ^ "\nunrealized intraday pl: " ^ string_of_float psn.unrealized_intraday_pl
  ^ "\nunrealized intraday plpc: " ^ string_of_float psn.unrealized_intraday_plpc
  ^ "\ncurrent price: " ^ string_of_float psn.current_price
  ^ "\nlastday price: " ^ string_of_float psn.lastday_price
  ^ "\nchange today: " ^ string_of_float psn.change_today

let string_of_asset (ass : asset) =
  "id: " ^ ass.id
  ^ "\nclass: " ^ ass.asset_class
  ^ "\nexchange: " ^ ass.exchange
  ^ "\nsymbol: " ^ ass.symbol
  ^ "\nstatus: " ^ ass.status
  ^ "\ntradable: " ^ string_of_bool ass.tradable
  ^ "\nmarginable: " ^ string_of_bool ass.marginable
  ^ "\nshortable: " ^ string_of_bool ass.shortable
  ^ "\neasy to borrow: " ^ string_of_bool ass.easy_to_borrow

let string_of_bar (bar : bar) =
  "t: " ^ string_of_int bar.t
  ^ "\no: " ^ string_of_float bar.o
  ^ "\nh: " ^ string_of_float bar.h
  ^ "\nl: " ^ string_of_float bar.l
  ^ "\nc: " ^ string_of_float bar.c
  ^ "\nv: " ^ string_of_int bar.v