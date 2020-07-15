
exception FailID of string

(** An [Identifier] is a module that constrains strings to a set of values *)
module type Identifier = sig

  type t

  val of_string : string -> t
  val to_string : t -> string

end

(** [Exchange] represents different exchanges *)
module Exchange : Identifier