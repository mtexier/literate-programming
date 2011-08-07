open Html

let source_dir_string = ref ( Sys.getcwd () )
let output_dir_string = ref !source_dir_string

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

let dump_code out =
  List.iter
    ( fun item ->
	match item with
	  | Expr.LpCode txt ->
	      Printf.fprintf out "%s" txt

	  | _ ->
	      () )

let dump_doc out pp info items =
  pp # setup out info;
  List.iter
    ( fun item ->
	match item with
	  | Expr.LpCode txt ->
	      pp # print_code out txt

	  | Expr.LpComment txt ->
	      let lexbuf = Lexing.from_string txt in
	      let result = Lp_parser.main Lp_lexer.main lexbuf in
		pp # print_doc out result )
    items;
  pp # teardown out info

type ctxt_type = {
  c_root  : string ;
  c_dst   : string ;
  c_paths : string list ;
  c_file  : string
}

let make_path paths file =
  List.fold_left
    ( fun state sub -> Filename.concat sub state )
    file
    paths

let process_file pp ctxt =
  let naked_path = Filename.chop_extension ctxt.c_file in
  let source_path = make_path ctxt.c_paths ctxt.c_file in
  let code_path =
    Filename.concat ctxt.c_dst ( make_path ctxt.c_paths naked_path )
  in
  let doc_path = code_path ^ ( pp # suffix () ) in

  let in_chan = open_in source_path in
  let code_chan = open_out code_path in
  let doc_chan = open_out doc_path in

  let result = split_source in_chan in
  let info = { path = ctxt.c_file; comment = copyright } in
  let _ = dump_code code_chan result in
  let _ = dump_doc doc_chan pp info result in

  let _ = close_in in_chan in
  let _ = close_out code_chan in
  let _ = close_out doc_chan in
    ()

let check_ext path =
  List.fold_left
    ( fun state ext -> state || ( Filename.check_suffix path ext ) )
    false
    [ ".cc.lp"; ".c++.lp"; ".C.lp"; ".cpp.lp" ]

let create_if_not_exists base paths =
  if not ( Sys.file_exists base ) then Unix.mkdir base 0o755;
  let _ =
    List.fold_right
      ( fun item state ->
          let state2 = Filename.concat state item in
            if not ( Sys.file_exists state2 ) then Unix.mkdir state2 0o755;
	    state2 )
      paths
      base
  in
    ()

let rec process_files pp ctxt =
  let _ =
    if not ( Sys.file_exists ctxt.c_root ) then
      invalid_arg ctxt.c_root
  in
  let files = Sys.readdir ctxt.c_root in
    let _ = create_if_not_exists ctxt.c_dst ctxt.c_paths in
    Array.iter
      ( fun file ->
	  if ( Sys.is_directory file ) then
	    let ctxt2 =
	      { ctxt with c_root = ( Filename.concat ctxt.c_root file ) ;
                          c_paths = file :: ctxt.c_paths }
	    in
	      process_files pp ctxt2
	  else
	    if check_ext file then 
	      let ctxt2 = { ctxt with c_file = file  } in
	        process_file pp ctxt2 )
      files

let main () =
  let _ = Arg.parse specs ( fun _ -> () ) usage in
    try
      let pp = new Html.pretty_printer in
      let ctxt = { c_root  = !source_dir_string;
		   c_dst   = !output_dir_string;
		   c_paths = [];
		   c_file  = "" } in
      let _ = process_files pp ctxt in
        ()

    with
      | Parsing.Parse_error ->
	  Printf.fprintf stderr "Error: parsing failed !\n";
	  exit 0
      | Invalid_argument what ->
	  Printf.fprintf stderr "%s\n" what;
	  exit 0

let _ = Printexc.print main ()
