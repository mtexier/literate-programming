{
  open Lp_parser
}

let verbatim_begin = "tt{"

let end = "}"

rule main = parse
  | verbatim_begin { VERBATIM }

  | end            { END }

  | _ as str       { CHAR (Lexing.lexeme lexbuf) }

  | eof            { EOF }

{
}
