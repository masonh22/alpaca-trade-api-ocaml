(** An [Environment] contains the private keys and URL for an
    Alpaca account *)
module type Environment = sig
  val key_id : string
  val secret_key : string
  val base_url : string
end

(** [AlpacaInterface] is an interface between OCaml and the Alpaca API *)
module type AlpacaInterface = sig

  exception APIError of string

  val get_account : unit -> Entity.account
  val get_account_config : unit -> Entity.config
  val update_account_config : string -> bool -> bool -> string -> Entity.config
  val list_orders :
    ?status:string ->
    ?limit:int ->
    ?after:string ->
    ?until:string ->
    ?direction:string -> ?nested:string -> unit -> Entity.order list
  val get_order : string -> Entity.order
  val get_order_by_client_order_id : string -> Entity.order
  val submit_order :
    ?limit_price:float ->
    ?stop_price:float ->
    ?extended_hours:bool ->
    ?client_order_id:string ->
    string -> int -> string -> string -> string -> Entity.order
  val replace_order :
    ?qty:int ->
    ?time_in_force:string ->
    ?limit_price:float ->
    ?stop_price:float -> ?client_order_id:string -> string -> Entity.order
  val cancel_order : string -> unit
  val cancel_all_orders : unit -> unit
  val list_positions : unit -> Entity.position list
  val get_position : string -> Entity.position
  val close_position : string -> Entity.order
  val close_all_positions : unit -> string
  val list_assets :
    ?status:string ->
    ?asset_class:string -> unit -> Entity.asset list
  val get_asset : string -> Entity.asset
  val get_barset : 
    ?limit:int ->
    ?start:string ->
    ?endt:string ->
    ?after:string ->
    ?until:string -> string list -> string -> (string * Entity.bar list) list
  val get_clock : unit -> Entity.clock

end

(** A [Starter] is a functor that takes an environment and  *)
module type Starter =
  functor (E : Environment) -> AlpacaInterface

module Make : Starter