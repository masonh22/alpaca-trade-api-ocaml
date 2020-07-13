
module type SignatChangethisname = sig

  type t

  val of_string : string -> t
  val to_string : t -> string

end

module Currency : SignatChangethisname

module Exchange : SignatChangethisname