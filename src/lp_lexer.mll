{
  open Lp_parser
}

let digit = ['0'-'9']+

let verbatim_begin = "tt{"
let bold_begin     = "b{"
let italic_begin   = "i{"
let underl_begin   = "u{"

let sect_begin    = "s"

let end = "}"

rule main = parse
  | verbatim_begin { VERBATIM }
  | bold_begin     { BOLD }
  | italic_begin   { ITALIC }
  | underl_begin   { UNDERLINE }

  | sect_begin ( digit as level ) "{" { SECT ( int_of_string level ) }

  | end            { END }

  | _              { CHAR (Lexing.lexeme lexbuf) }

  | eof            { EOF }

{
}
