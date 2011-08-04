type cattr =
    Normal
  | Verbatim

type lp =
    LpComment of string
  | LpCode of string

type t =
    CodeStmt of (int * string) list
  | DocStmt of (cattr * string) list
