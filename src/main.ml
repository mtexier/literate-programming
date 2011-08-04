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

let process_file pp path =
  let code_path = Filename.chop_suffix path ".lp" in
  let doc_path = code_path ^ ( pp # suffix () ) in
  let in_chan = open_in path in
  let code_chan = open_out code_path in
  let doc_chan = open_out doc_path in
  let result = split_source in_chan in
  let info = { path = code_path; comment = copyright } in
  let _ = dump_code code_chan result in
  let _ = dump_doc doc_chan pp info result in
  let _ = close_in in_chan in
  let _ = close_out code_chan in
  let _ = close_out doc_chan in
    ()

let process_files pp path =
  let _ = if not ( Sys.file_exists path ) then invalid_arg path in
  let files = Sys.readdir path in
    Array.iter ( process_file pp ) files

let main () =
  let _ = Arg.parse specs ( fun _ -> () ) usage in
    try
      let pp = new Html.pretty_printer in
      let _ = process_files pp !source_dir_string in
        ()

    with
      | Parsing.Parse_error ->
	  Printf.fprintf stderr "Error: parsing failed !\n";
	  exit 0
      | Invalid_argument what ->
	  Printf.fprintf stderr "%s\n" what;
	  exit 0

let _ = Printexc.print main ()
