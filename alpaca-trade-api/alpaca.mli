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

  (** [get_account ()] is the Alpaca account object *)
  val get_account : unit -> Entity.account

  (** [get_account_config ()] is the current account configuration *)
  val get_account_config : unit -> Entity.config

  (** [update_account_config] updates the account configuration *)
  val update_account_config : string -> bool -> bool -> string -> Entity.config
  val list_orders :
    ?status:string ->
    ?limit:int ->
    ?after:string ->
    ?until:string ->
    ?direction:string -> ?nested:string -> unit -> Entity.order list

  (** [get_order id] is the order with order id [id] *)
  val get_order : string -> Entity.order

  (** [get_order_by_client_id id] is the order with client id [id] *)
  val get_order_by_client_order_id : string -> Entity.order

  (** [submit_order] submits an order *)
  val submit_order :
    ?limit_price:float ->
    ?stop_price:float ->
    ?extended_hours:bool ->
    ?client_order_id:string ->
    string -> int -> string -> string -> string -> Entity.order

  (** [replace_order id] replaces the order with order id [id]
      with updated parameters *)
  val replace_order :
    ?qty:int ->
    ?time_in_force:string ->
    ?limit_price:float ->
    ?stop_price:float -> ?client_order_id:string -> string -> Entity.order

  (** [cancel_order id] cancels the order with order id [id] *)
  val cancel_order : string -> unit

  (** [cancel_all_orders ()] cancells all orders *)
  val cancel_all_orders : unit -> unit

  (** [list_positions ()] is a list of all open positions *)
  val list_positions : unit -> Entity.position list

  (** [get_position symbol] is the current position on [symbol] *)
  val get_position : string -> Entity.position

  (** [close_position symbol] attempts to close the position on symbol *)
  val close_position : string -> Entity.order

  (** [close_all_positions ()] attempts to close all positions *)
  val close_all_positions : unit -> unit

  (** [list_assets ()] is a master list of all assets available from Alpaca *)
  val list_assets :
    ?status:string ->
    ?asset_class:string -> unit -> Entity.asset list

  (** [get_asset id] is the asset with id or symbol [id] *)
  val get_asset : string -> Entity.asset

  (** [get_barset] retrieves a list of bars for each requested symbol
      in ascending order by time *)
  val get_barset : 
    ?limit:int ->
    ?start:string ->
    ?endt:string ->
    ?after:string ->
    ?until:string -> string list -> string -> (string * Entity.bar list) list

  (** [get_clock ()] is a clock object for the current time *)
  val get_clock : unit -> Entity.clock

end

(** A [Starter] is a functor that takes an environment and creates
    a module to interface with the Alpaca API *)
module type Starter =
  functor (E : Environment) -> AlpacaInterface

(** [Make] is a functor that creates a module to interface
    with the Alpaca API *)
module Make : Starter