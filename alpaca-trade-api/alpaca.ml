open Lwt
open Cohttp
open Cohttp_lwt_unix
open Yojson.Basic

module type Environment = sig
  val key_id : string
  val secret_key : string
  val base_url : string
  (*val api_version : api only support v2 *)
end

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
  val close_all_positions : unit -> unit
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

module type Starter =
  functor (E : Environment) -> AlpacaInterface

module Make : Starter = functor (E : Environment) -> struct

  exception APIError of string

  (* CONSTANTS *)
  let base_url = E.base_url ^ "/v2/"

  let data_url = "https://data.alpaca.markets/v1/"

  let header = Header.add_list (Header.init_with "allow_redirects" "False")
      [("APCA-API-KEY-ID", E.key_id);
       ("APCA-API-SECRET-KEY", E.secret_key)]

  (* HELPERS *)
  let do_rsp (head, body) =
    let code = head |> Response.status |> Code.code_of_status in
    (*Printf.printf "Response code: %d\n" code;
      Printf.printf "Headers:\n%s\n" (head |> Response.headers |> Header.to_string);*)
    body |> Cohttp_lwt.Body.to_string >|= fun body ->
    if code > 399 then raise (APIError body) else
      (*Printf.printf "Body of length: %d\n" (String.length body);*)
      body

  let json_array json = [json] |> Util.flatten

  let params = String.concat "&"

  let get uri =
    Client.get ~headers:header uri >>= do_rsp

  let post body uri =
    Client.post ~headers:header ~body:body uri >>= do_rsp

  let patch body uri =
    Client.patch ~headers:header ~body:body uri >>= do_rsp

  let delete uri =
    Client.delete ~headers:header uri >>= do_rsp

  let make_option_list f acc (k, v) =
    match v with 
    | Some x -> (f k x) :: acc
    | _ -> acc

  let param_format k v = k ^ "=" ^ v

  let body_format k v = "\"" ^ k ^ "\":\"" ^ v ^ "\""

  let make_order
      ?symbol
      ?side
      ?typ
      ?extended_hours:(e=None)
      qty
      time_in_force
      limit_price
      stop_price
      client_order_id
    =
    let lst = [("symbol", symbol);
               ("qty", Option.map string_of_int qty);
               ("side", side);
               ("type", typ);
               ("time_in_force", time_in_force);
               ("limit_price", Option.map string_of_float limit_price);
               ("stop_price", Option.map string_of_float stop_price);
               ("extended_hours", Option.map string_of_bool e);
               ("client_order_id", client_order_id)]
    in
    let body = List.fold_left (make_option_list body_format) [] lst in
    let str = "{" ^ String.concat "," body ^ "}" in
    Cohttp_lwt__.Body.of_string str

  (* FUNCTIONS *)
  let get_account () =
    let uri = Uri.of_string (base_url ^ "account") in
    let rsp = Lwt_main.run (get uri) in
    rsp |> from_string |> Entity.account_of_json

  let get_account_config () =
    let uri = Uri.of_string (base_url ^ "account/configurations") in
    let rsp = Lwt_main.run (get uri) in
    rsp |> from_string |> Entity.config_of_json

  let update_account_config
      dtbp_check
      no_shorting
      suspend_trade
      trade_confirm_email =
    let uri = Uri.of_string (base_url ^ "account/configurations")
    and body =
      let str = 
        ("{\"no_shorting\":" ^ string_of_bool no_shorting
         ^ ",\"suspend_trade\":" ^ string_of_bool suspend_trade
         ^ ",\"trade_confirm_email\":\"" ^ trade_confirm_email
         ^ "\",\"dtbp_check\":\"" ^ dtbp_check ^ "\"}") in
      Cohttp_lwt__.Body.of_string str
    in
    let rsp = Lwt_main.run (patch body uri) in
    rsp |> from_string |> Entity.config_of_json

  let list_orders
      ?status:(s="open")
      ?limit:(l=(50))
      ?after
      ?until
      ?direction:(d="desc")
      ?nested
      () =
    let l1 = ["status=" ^ s; "limit=" ^ string_of_int l; "direction=" ^ d]
    and l2 = [("after", after); ("until", until); ("nested", nested)]
    in
    let query = List.fold_left (make_option_list param_format) l1 l2 in
    let uri = Uri.of_string (base_url ^ "orders?" ^ params query) in
    let rsp = Lwt_main.run (get uri) in
    List.map Entity.order_of_json (rsp |> from_string |> json_array)

  let submit_order
      ?limit_price
      ?stop_price
      ?extended_hours
      ?client_order_id
      symbol qty side typ time_in_force =
    let uri = Uri.of_string (base_url ^ "orders")
    and body =
      make_order
        ~symbol:symbol
        ~side:side
        ~typ:typ
        ~extended_hours:extended_hours
        (Some qty)
        (Some time_in_force)
        limit_price
        stop_price
        client_order_id
    in
    let rsp = Lwt_main.run (post body uri) in
    rsp |> from_string |> Entity.order_of_json

  let get_order id =
    let uri = Uri.of_string (base_url ^ "orders/" ^ id) in
    let rsp = Lwt_main.run (get uri) in
    rsp |> from_string |> Entity.order_of_json

  let get_order_by_client_order_id id =
    let uri = Uri.of_string
        (base_url ^ "orders:by_client_order_id?client_order_id=" ^ id) in
    let rsp = Lwt_main.run (get uri) in
    rsp |> from_string |> Entity.order_of_json

  let replace_order
      ?qty
      ?time_in_force
      ?limit_price
      ?stop_price
      ?client_order_id
      order_id =
    let uri = Uri.of_string (base_url ^ "orders/" ^ order_id)
    and body =
      make_order
        qty
        time_in_force
        limit_price
        stop_price
        client_order_id
    in
    let rsp = Lwt_main.run (patch body uri) in
    rsp |> from_string |> Entity.order_of_json

  let cancel_order id =
    let uri = Uri.of_string (base_url ^ "orders/" ^ id) in
    let _ = Lwt_main.run (delete uri) in ()

  let cancel_all_orders () =
    let uri = Uri.of_string (base_url ^ "orders") in
    let _ = Lwt_main.run (delete uri) in ()

  let list_positions () =
    let uri = Uri.of_string (base_url ^ "positions") in
    let rsp = Lwt_main.run (get uri) in
    List.map Entity.position_of_json (rsp |> from_string |> json_array)

  let get_position symbol = 
    let uri = Uri.of_string (base_url ^ "positions/" ^ symbol) in
    let rsp = Lwt_main.run (get uri) in
    rsp |> from_string |> Entity.position_of_json

  let close_position symbol =
    let uri = Uri.of_string (base_url ^ "positions/" ^ symbol) in
    let rsp = Lwt_main.run (delete uri) in
    rsp |> from_string |> Entity.order_of_json

  let close_all_positions () =
    let uri = Uri.of_string (base_url ^ "positions") in
    ignore (Lwt_main.run (delete uri))

  let list_assets
      ?status
      ?asset_class:(a="us_equity") () =
    let query =
      (match status with Some s -> List.cons ("status=" ^ s) | _ -> Fun.id)
        ["asset_class=" ^ a] in
    let uri = Uri.of_string (base_url ^ "assets?" ^ params query) in
    let rsp = Lwt_main.run (get uri) in
    List.map Entity.asset_of_json (rsp |> from_string |> json_array)

  let get_asset id =
    let uri = Uri.of_string (base_url ^ "assets/" ^ id) in
    let rsp = Lwt_main.run (get uri) in
    rsp |> from_string |> Entity.asset_of_json

  let parse_bar symbols json =
    let get_bar symbol =
      let lst = 
        [json]
        |> Util.filter_member symbol
        |> Util.flatten
        |> List.map Entity.bar_of_json
      in
      (symbol, lst)
    in
    List.map get_bar symbols

  let get_barset
      ?limit:(l=100)
      ?start
      ?endt
      ?after (*difference between start end, after until?*)
      ?until
      symbols
      timeframe =
    let l1 =
      ["symbols=" ^ String.concat "," symbols; "limit=" ^ string_of_int l]
    and l2 = [("start", start);
              ("end", endt);
              ("after", after);
              ("until", until)]
    in
    let query = List.fold_left (make_option_list param_format) l1 l2 in
    let uri =
      Uri.of_string (data_url ^ "bars/" ^ timeframe ^ "?" ^ params query) in
    let rsp = Lwt_main.run (get uri) in
    parse_bar symbols (from_string rsp)

  let get_clock () =
    let uri = Uri.of_string (base_url ^ "clock") in
    let rsp = Lwt_main.run (get uri) in
    rsp |> from_string |> Entity.clock_of_json

end