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

open Html

let source_dir_string = ref ""
let output_dir_string = ref ( Sys.getcwd () )

let specs = [
  ( "-src", Arg.Set_string source_dir_string, "Name of source dir." ) ;
  ( "-out", Arg.Set_string output_dir_string, "Name of the output dir." )
]

let usage =
  "\n###############################\n"
  ^ "# Literate Programming parser #\n"
  ^ "###############################\n\n"
  ^ "Options\n"

let copyright =
  "Literate programming tool by"
  ^ " Julien Peeters &lt;contact@julienpeeters.net&gt;"

let split_source in_chan =
  let lexbuf = Lexing.from_channel in_chan in
    List.rev (File_lexer.main [] lexbuf)

let dump out pp info items =
  pp # setup out info;
  List.iter
    ( fun item ->
	match item with
	  | Expr.LpCode txt ->
	      pp # code out txt

	  | Expr.LpComment txt ->
	      let lexbuf = Lexing.from_string txt in
	      let result = Lp_parser.main Lp_lexer.main lexbuf in
		pp # doc out result )
    items;
  pp # teardown out info

let abs_path path =
  if Filename.is_relative path then
    Filename.concat ( Sys.getcwd () ) path
  else
    path

let process_file pp path_list =
  let source_path =
    List.fold_right
      ( fun item state -> Filename.concat state item )
      path_list
      !source_dir_string
  in
  let doc_path =
    List.fold_right
      ( fun item state -> Filename.concat state item )
      path_list
      !output_dir_string
  in
  let doc_path2 = doc_path ^ ( pp # suffix () ) in

  let in_chan = open_in source_path in
  let doc_chan = open_out doc_path2 in

  let result = split_source in_chan in
  let info = { i_root = abs_path !source_dir_string;
               i_out  = abs_path !output_dir_string;
               i_path = path_list;
               i_foot = copyright } in
  let _ = dump doc_chan pp info result in

  let _ = close_in in_chan in
  let _ = close_out doc_chan in
    ()

let check_ext path =
  List.fold_left
    ( fun state ext -> state || ( Filename.check_suffix path ext ) )
    false
    [ ".cc"; ".c++"; ".C"; ".cpp" ]

let walk f path =
  let rec walk_rec paths =
    let path_str =
      List.fold_right
	( fun item state -> Filename.concat state item )
	paths
	path
    in
    let files,dirs,_ = Dir.list path_str in
    let process f entry = f ( entry :: paths ) in
    let _ = List.iter ( process f ) files in
    let _ = List.iter ( process walk_rec ) dirs in
      ()
  in
  walk_rec []

let rec make_dirs list base =
  match list with
    | [] -> ()
    | _ :: tl ->
      make_dirs tl base;
      let path =
	List.fold_right
	  ( fun item state -> Filename.concat state item )
	  list
	  base
      in
        if not ( Sys.file_exists path ) then Unix.mkdir path 0o755

let main () =
  let _ = Arg.parse specs ( fun _ -> () ) usage in
    try
      if !source_dir_string = "" then
	Arg.usage specs ( "\nerror: missing source directory\n" ^ usage );

      if not ( Sys.file_exists !source_dir_string ) then
	invalid_arg !source_dir_string;
      if not ( Sys.file_exists !output_dir_string ) then
	make_dirs [ !output_dir_string ] "";

      let pp = new Html.pretty_printer in
	walk
	  ( fun list ->
	      match list with
		| [] -> ()
		| hd :: [] -> if check_ext hd then process_file pp list
		| hd :: tl ->
		    if check_ext hd then begin
                      make_dirs tl !output_dir_string;
                      process_file pp list
		    end )
	  !source_dir_string
    with
      | Parsing.Parse_error ->
	  Printf.fprintf stderr "Error: parsing failed !\n";
	  exit 0
      | Invalid_argument what ->
	  Printf.fprintf stderr "%s\n" what;
	  exit 0

let _ = Printexc.print main ()
