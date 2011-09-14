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

let blkl = "^\n" 
    
let verbatim_begin = "tt{"
let bold_begin     = "b{"
let italic_begin   = "i{"
let underl_begin   = "u{"
let link_begin     = "l"

let sect_begin    = "s"

(* CWEB Rules *)
let cweb_section = "@*"
let cweb_section1 = "@ "
let cweb_code_section_begin = "@<"
let cweb_code_section_end = ">@"
let cweb_code_section_end_decl = ">@="
let cweb_verbatim = "|"
let cweb_macro = "@d"
let cweb_arobase = "@@"
let cweb_format_short = "@f"
let cweb_format_long = "@s"


let end = "}"

rule main = parse
  | verbatim_begin { VERBATIM }
  | bold_begin     { BOLD }
  | italic_begin   { ITALIC }
  | underl_begin   { UNDERLINE }

  | sect_begin ( digit as level ) "{" { SECT ( int_of_string level ) }
  | link_begin ( digit as level ) "{" { LINK ( int_of_string level ) }

  | cweb_code_section_begin  { CWEB_CODE_SECTION }
  | cweb_code_section_end { CWEB_CODE_SECTION_END }
  | cweb_code_section_end_decl { CWEB_CODE_SECTION_END_DECL }

  | end            { END }

  | _              { CHAR (Lexing.lexeme lexbuf) }

  | eof            { EOF }

  | blkl            { EOL }

{
}
