
module type SignatChangethisname = sig

  type t

  val of_string : string -> t
  val to_string : t -> string

end

module Currency : SignatChangethisname = struct

  type t = USD | GBP

  let of_string s =
    match String.uppercase_ascii s with
    | "GBP" -> GBP
    | "USD" -> USD
    | _ -> failwith "COME UP WITH AN ERROR FOR THIS"

  let to_string = function
    | USD -> "USD"
    | GBP -> "GBP"

end

module Exchange : SignatChangethisname = struct

  type t = AMEX | ARCA | BATS | NYSE | NASDAQ | NYSEARCA

  let of_string s =
    match String.uppercase_ascii s with
    | "AMEX" -> AMEX
    | "ARCA" -> ARCA
    | "BATS" -> BATS
    | "NYSE" -> NYSE
    | "NASDAQ" -> NASDAQ
    | "NYSEARCA" -> NYSEARCA
    | _ -> failwith "COME UP WITH AN ERROR FOR THIS"

  let to_string = function
    | AMEX -> "AMEX"
    | ARCA -> "ARCA"
    | BATS -> "BATS"
    | NYSE -> "NYSE"
    | NASDAQ -> "NASDAQ"
    | NYSEARCA -> "NYSEARCA"

end