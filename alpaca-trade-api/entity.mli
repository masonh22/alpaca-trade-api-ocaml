(** The type [account] represents the Account object returned
    by the Alpaca Trading API 
    https://alpaca.markets/docs/api-documentation/api-v2/account/#account-entity
*)
type account

(** The type [asset] represents the Asset object returned
    by the Alpaca Trading API 
    https://alpaca.markets/docs/api-documentation/api-v2/assets/#asset-entity
*)
type asset

(** The type [order] represents the Order object returned
    by the Alpaca Trading API
    https://alpaca.markets/docs/api-documentation/api-v2/assets/#asset-entity
*)
type order

(** The type [config] represents the AccountConfigurations
    object returned by the Alpaca Trading API 
    https://alpaca.markets/docs/api-documentation/api-v2/account-configuration/#accountconfigurations-entity
*)
type config

(** The type [position] represents the Position object returned
    by the Alpaca Trading API 
    https://alpaca.markets/docs/api-documentation/api-v2/positions/#position-entity
*)
type position

(** The type [bars] represents the Bars object returned
    by the Alpaca Trading API 
    https://alpaca.markets/docs/api-documentation/api-v2/market-data/bars/#bars-entity
*)
type bar

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