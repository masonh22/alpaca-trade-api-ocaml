type currency = USD | GBP

let currency_of_string = function
  | "GBP" -> GBP
  | _ -> USD

let to_string = function
  | USD -> "USD"
  | GBP -> "GBP"
