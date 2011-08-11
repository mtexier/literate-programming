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

  let buffer = Buffer.create 32
}

let blank        = [' ' '\013' '\009' '\012']
let nl           = ['\010']
let not_nl       = [^ '\010']
let blank_nl     = [' ' '\013' '\009' '\012' '\010']
let not_blank_nl = [^ ' ' '\013' '\009' '\012' '\010']

rule main state = parse
  | blank* "/*>" blank_nl* "*/"
      {
	main state lexbuf
      }

  | blank* "/*>" blank_nl*
      {
	let state2 =
	  if Buffer.length buffer > 0 then begin
	    let code = Expr.LpCode (Buffer.contents buffer) in
	    let _ = Buffer.reset buffer in
	    code :: state
	  end else
	    state
	in
	let state3 = (special_comment lexbuf) :: state2 in
	  main state3 lexbuf
      }

  | _ as c
      {
	Buffer.add_char buffer c;
	main state lexbuf
      }

  | eof
      {
	if Buffer.length buffer > 0 then
	  let code = Buffer.contents buffer in
            Buffer.reset buffer;
            (Expr.LpCode code)::state
	else
	  state
      }

and special_comment = parse
  | "*/" nl+
      {
	let com = Expr.LpComment (Buffer.contents buffer) in
	  Buffer.reset buffer;
	  com
      }

  | nl nl+ blank_nl*
      {
  	Buffer.add_string buffer "\n\n";
  	special_comment lexbuf
      }

  | blank_nl+
      {
  	Buffer.add_char buffer ' ';
  	special_comment lexbuf
      }

  | not_blank_nl as c
      {
	Buffer.add_char buffer c;
	special_comment lexbuf
      }

{
}
