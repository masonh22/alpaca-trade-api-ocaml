(** The type [account] represents the Account object returned
    by the Alpaca Trading API 
    https://alpaca.markets/docs/api-documentation/api-v2/account/#account-entity
*)
type account = {
  id: string;
  created_at: string;
  account_number: string;
  status: string;
  currency: Common.Currency.t;
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

(** The type [asset] represents the Asset object returned
    by the Alpaca Trading API 
    https://alpaca.markets/docs/api-documentation/api-v2/assets/#asset-entity
*)
type asset = {
  id: string;
  asset_class: string; (*class*)
  exchange: Common.Exchange.t;
  symbol: string;
  status: string; (*make variant*)
  tradable: bool;
  marginable: bool;
  shortable: bool;
  easy_to_borrow: bool;
}

(** The type [bars] represents the Bars object returned
    by the Alpaca Trading API 
    https://alpaca.markets/docs/api-documentation/api-v2/market-data/bars/#bars-entity
*)
type bar  = {
  t: int;
  o: float;
  h: float;
  l: float;
  c: float;
  v: int;
}

(** The type [clock] represents the Clock object returned
    by the Alpaca Trading API 
    https://alpaca.markets/docs/api-documentation/api-v2/clock/#clock-entity
*)
type clock = {
  timestamp: string;
  is_open: bool;
  next_open: string;
  next_close: string;
}

(** The type [config] represents the AccountConfigurations
    object returned by the Alpaca Trading API 
    https://alpaca.markets/docs/api-documentation/api-v2/account-configuration/#accountconfigurations-entity
*)
type config = {
  dtbp_check: string;
  no_shorting: bool;
  suspend_trade: bool;
  trade_confirm_email: string;
}

(** The type [order] represents the Order object returned
    by the Alpaca Trading API
    https://alpaca.markets/docs/api-documentation/api-v2/orders/#order-entity
*)
type order = {
  id: string;
  client_order_id: string;
  created_at: string;
  updated_at: string option;
  submitted_at: string option;
  filled_at: string option;
  expired_at: string option;
  cancelled_at: string option;
  failed_at: string option;
  replaced_at: string option;
  replaced_by: string option;
  replaces: string option;
  asset_id: string;
  symbol: string;
  asset_class: string;
  qty: int;
  filled_qty: int;
  filled_avg_price: float option;
  typ: string;
  side: string;
  time_in_force: string;
  limit_price: float option;
  stop_price: float option;
  status: string;
  extended_hours: bool;
  legs: order list;
}

(** The type [position] represents the Position object returned
    by the Alpaca Trading API 
    https://alpaca.markets/docs/api-documentation/api-v2/positions/#position-entity
*)
type position = {
  asset_id: string;
  symbol: string;
  exchange: Common.Exchange.t;
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

(** [account_of_json j] is the account that [j] represents *)
val account_of_json : Yojson.Basic.t -> account

(** [order_of_json j] is the order that [j] represents *)
val order_of_json : Yojson.Basic.t -> order

(** [config_of_json j] is the account-config that [j] represents *)
val config_of_json : Yojson.Basic.t -> config

(** [position_of_json j] is the position that [j] represents *)
val position_of_json : Yojson.Basic.t -> position

(** [asset_of_json j] is the asset that [j] represents *)
val asset_of_json : Yojson.Basic.t -> asset

(** [bar_of_json j] is the bar that [j] represents *)
val bar_of_json : Yojson.Basic.t -> bar

(** [clock_of_json j] is the clock that [j] represents *)
val clock_of_json : Yojson.Basic.t -> clock

(** [string_of_account act] is the account [act] represented as a string *)
val string_of_account : account -> string

(** [string_of_order ord] is the order [ord] represented as a string *)
val string_of_order : order -> string

(** [string_of_config cfg] is the account-config [cfg] represented
    as a string *)
val string_of_config : config -> string

(** [string_of_position psn] is the position [psn] represented as a string *)
val string_of_position : position -> string

(** [string_of_asset a] is the asset [a] represented as a string *)
val string_of_asset : asset -> string

(** [string_of_bar bar] is the bar [bar] represented as a string *)
val string_of_bar : bar -> string