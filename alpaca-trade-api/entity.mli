type account

type order

type config

type position

type asset

val account_of_json : Yojson.Basic.t -> account

val order_of_json : Yojson.Basic.t -> order

val config_of_json : Yojson.Basic.t -> config

val position_of_json : Yojson.Basic.t -> position

val asset_of_json : Yojson.Basic.t -> asset

val string_of_account : account -> string

val string_of_order : order -> string

val string_of_config : config -> string

val string_of_position : position -> string

val string_of_asset : asset -> string