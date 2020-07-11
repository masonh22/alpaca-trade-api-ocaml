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

(* these should not be returning abstract types *)
module type Rest = sig

  exception APIError of string

  val get_account : unit -> Entity.account
  val get_account_config : unit -> Entity.config
  val list_orders : ?status:string ->
    ?limit:int ->
    ?after:string ->
    ?until:string ->
    ?direction:string -> ?nested:bool -> unit -> Entity.order list
  val get_order : string -> Entity.order
  val get_order_by_client_order_id : string -> Entity.order
  val submit_order : ?limit_price:float ->
    ?stop_price:float ->
    ?extended_hours:bool ->
    ?client_order_id:string ->
    string -> int -> string -> string -> string -> Entity.order
  val replace_order : ?qty:int ->
    ?time_in_force:string ->
    ?limit_price:float ->
    ?stop_price:float -> ?client_order_id:string -> string -> Entity.order
  val cancel_order : string -> unit
  val cancel_all_orders : unit -> unit
  val list_positions : unit -> Entity.position list
  val get_position : string -> Entity.position
  val close_position : string -> Entity.order
  val close_all_positions : unit -> string
  val list_assets : ?status:string ->
    ?asset_class:string -> unit -> Entity.asset list
  val get_asset : string -> Entity.asset
  val get_bar : 
    ?limit:int ->
    ?start:string ->
    ?endt:string ->
    ?after:string ->
    ?until:string -> string list -> string -> (string * Entity.bar list) list
  val get_clock : unit -> Entity.clock

end

module type Starter =
  functor (E : Environment) -> Rest

module Make : Starter = functor (E : Environment) -> struct

  exception APIError of string

  let base_url = E.base_url ^ "/v2/"

  let data_url = "https://data.alpaca.markets/v1/"

  let header = Header.add_list (Header.init_with "allow_redirects" "False")
      [("APCA-API-KEY-ID", E.key_id);
       ("APCA-API-SECRET-KEY", E.secret_key)]

  let print_rsp (head, body) =
    let code = head |> Response.status |> Code.code_of_status in
    Printf.printf "Response code: %d\n" code;
    Printf.printf "Headers:\n%s\n" (head |> Response.headers |> Header.to_string);
    body |> Cohttp_lwt.Body.to_string >|= fun body ->
    if code > 399 then raise (APIError body) else
      Printf.printf "Body of length: %d\n" (String.length body); body

  let json_array json = [json] |> Util.flatten

  let params = String.concat "&"

  let get uri =
    Client.get ~headers:header uri >>= print_rsp

  let post body uri =
    Client.post ~headers:header ~body:body uri >>= print_rsp

  let patch body uri =
    Client.patch ~headers:header ~body:body uri >>= print_rsp

  let delete uri =
    Client.delete ~headers:header uri >>= print_rsp

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
    and body = Cohttp_lwt__.Body.of_string
        ("{\"no_shorting\":\"" ^ string_of_bool no_shorting
         ^ "\",\"suspend_trade\":\"" ^ string_of_bool suspend_trade
         ^ "\",\"trade_confirm_email\":\"" ^ trade_confirm_email
         ^ "\",\"dtbp_check\":\"" ^ dtbp_check ^ "\"}") in
    let rsp = Lwt_main.run (patch body uri) in
    rsp |> from_string |> Entity.config_of_json

  let list_orders
      ?status:(s="open")
      ?limit:(l=(0))
      ?after:(a="")
      ?until:(u="")
      ?direction:(d="desc")
      ?nested:(n=false)
      () =
    let query = (if u <> "" then List.cons ("until=" ^ u) else Fun.id)
        ["status=" ^ s;
         "limit=" ^ string_of_int l;
         "direction=" ^ d;
         "nested=" ^ string_of_bool n] |>
                (if a <> "" then List.cons ("after=" ^ a) else Fun.id) in
    let uri = Uri.of_string (base_url ^ "orders?" ^ params query) in
    let rsp = Lwt_main.run (get uri) in
    List.map Entity.order_of_json (rsp |> from_string |> json_array)

  let make_body 
      ?symbol:(sym="")
      ?qty:(q=(-1))
      ?side:(s="")
      ?typ:(t="")
      ?time_in_force:(tif="")
      ?limit_price:(lp=(-1.))
      ?stop_price:(sp=(-1.))
      ?extended_hours:(e=false)
      ?client_order_id:(id="")
      () =(*UGLY FIX THSI*)
    let lst =
      (if sym <> "" then
         List.cons ("\"symbol\":\"" ^ sym ^ "\"")
       else Fun.id) []
      |> (if q > -1 then
            List.cons ("\"qty\":\"" ^ string_of_int q ^ "\"")
          else Fun.id)
      |> (if s <> "" then
            List.cons ("\"side\":\"" ^ s ^ "\"")
          else Fun.id)
      |> (if t <> "" then
            List.cons ("\"type\":\"" ^ t ^ "\"")
          else Fun.id)
      |> (if tif <> "" then
            List.cons ("\"time_in_force\":\"" ^ tif ^ "\"")
          else Fun.id)
      |> (if lp > -1. then
            List.cons ("\"limit_price\":\"" ^ string_of_float lp ^ "\"")
          else Fun.id)
      |> (if sp > -1. then
            List.cons ("\"stop_price\":\"" ^ string_of_float sp ^ "\"")
          else Fun.id)
      |> (if e then
            List.cons ("\"extended_hours\":\"true\"")
          else Fun.id)
      |> (if id <> "" then
            List.cons ("\"client_order_id\":\"" ^ id ^ "\"")
          else Fun.id)
    in
    let str = "{" ^ String.concat "," lst ^ "}" in
    Cohttp_lwt__.Body.of_string str

  let submit_order
      ?limit_price:(lp=(-1.))
      ?stop_price:(sp=(-1.))
      ?extended_hours:(e=false)
      ?client_order_id:(id="")
      symbol qty side typ time_in_force =
    let uri = Uri.of_string (base_url ^ "orders")
    and body = make_body ~symbol:symbol ~qty:qty ~side:side
        ~typ:typ ~time_in_force:time_in_force (*UGLY FIX THIS*)
        ~limit_price:lp ~stop_price:sp
        ~extended_hours:e ~client_order_id:id () in
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
      ?qty:(q=(-1))
      ?time_in_force:(tif="")
      ?limit_price:(lp=(-1.))
      ?stop_price:(sp=(-1.))
      ?client_order_id:(c_id="")
      order_id =
    let uri = Uri.of_string (base_url ^ "orders/" ^ order_id)
    and body =
      make_body ~qty:q ~time_in_force:tif ~limit_price:lp (*UGLY FIX THIS*)
        ~stop_price:sp ~client_order_id:c_id () in
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

  (*figure out api return body*)
  let close_all_positions () =
    let uri = Uri.of_string (base_url ^ "positions") in
    let rsp = Lwt_main.run (delete uri) in
    rsp

  let list_assets
      ?status:(s="")
      ?asset_class:(a="us_equity") () =
    let query = (if s <> "" then ["status=" ^ s] else [])
                @ ["asset_class=" ^ a] in
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

  let get_bar
      ?limit:(l=100)
      ?start:(s="")
      ?endt:(e="")
      ?after:(a="") (*difference between start end, after until?*)
      ?until:(u="")
      symbols timeframe =
    let query =
      (if s <> "" then List.cons ("start=" ^ s) else Fun.id)
        ["symbols=" ^ String.concat "," symbols; "limit=" ^ string_of_int l]
      |> (if e <> "" then List.cons ("end=" ^ e) else Fun.id)
      |> (if a <> "" then List.cons ("after=" ^ a) else Fun.id)
      |> (if u <> "" then List.cons ("until=" ^ u) else Fun.id)
    in
    let uri =
      Uri.of_string (data_url ^ "bars/" ^ timeframe ^ "?" ^ params query) in
    let rsp = Lwt_main.run (get uri) in
    parse_bar symbols (from_string rsp)

  let get_clock () =
    let uri = Uri.of_string (base_url ^ "clock") in
    let rsp = Lwt_main.run (get uri) in
    rsp |> from_string |> Entity.clock_of_json


end