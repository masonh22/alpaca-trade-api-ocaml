
exception FailID of string

module type Identifier = sig

  type t

  val of_string : string -> t
  val to_string : t -> string

end

module Exchange : Identifier = struct

  type t = AMEX | ARCA | BATS | NYSE | NASDAQ | NYSEARCA

  let of_string s =
    match String.uppercase_ascii s with
    | "AMEX" -> AMEX
    | "ARCA" -> ARCA
    | "BATS" -> BATS
    | "NYSE" -> NYSE
    | "NASDAQ" -> NASDAQ
    | "NYSEARCA" -> NYSEARCA
    | _ -> raise (FailID "Invalid Exchange")

  let to_string = function
    | AMEX -> "AMEX"
    | ARCA -> "ARCA"
    | BATS -> "BATS"
    | NYSE -> "NYSE"
    | NASDAQ -> "NASDAQ"
    | NYSEARCA -> "NYSEARCA"

end