{
(*
 * Copyright 2011 (c) Julien Peeters <contact@julienpeeters.net>
 *
 * This file is part of LpTool.

 * LpTool is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * LpTool is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with LpTool.  If not, see <http://www.gnu.org/licenses/>
 *
 * Author:
 *   Julien Peeters <contact@julienpeeters.net>
 *)

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
