open Yojson.Basic.Util
open Lwt
open Cohttp
open Cohttp_lwt_unix

type cards = {deck_id: string; remaining: int; shuffled: bool}

let query_deck query =
  let base_uri = Uri.of_string "https://deckofcardsapi.com/api/deck" in
  Uri.add_query_param base_uri ("q", [query])

let shuffle_cards num =
  let base_uri = Uri.of_string "https://deckofcardsapi.com/api/deck/new/shuffle/" in
  Uri.add_query_param base_uri ("deck_count", [string_of_int num])

let deck_from_json json =
  if member "success" json |> to_bool then
    Some ({deck_id = json |> member "deck_id" |> to_string;
           remaining = json |> member "remaining" |> to_int;
           shuffled = json |> member "shuffled" |> to_bool})
  else None

let get_shuffled_deck () =
  Client.get (shuffle_cards 1) >>= fun (_, body) ->
  Cohttp_lwt.Body.to_string body >|= fun body ->
  deck_from_json (Yojson.Basic.from_string body)

let () = let body = Lwt_main.run (get_shuffled_deck ()) in
  match body with
  | None -> print_endline "query failed"
  | Some x -> print_endline x.deck_id