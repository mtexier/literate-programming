open Html

let lp_file_string   = ref ""
let code_file_string = ref ""
let doc_file_string = ref ""

let lp_file () = !lp_file_string

let code_file () =
  if !code_file_string = "" then
    let filename = lp_file () in
    let len = String.length filename in
      String.sub filename 0 ( len - 3 )
  else
    !code_file_string

let doc_file () =
  if !doc_file_string = "" then
    let filename = lp_file () in
    let len = String.length filename in
      ( String.sub filename 0 ( len - 3 ) ) ^ ".html"
  else
    !doc_file_string

let specs = [
  ( "-f", Arg.Set_string lp_file_string,   "Name of file to parse" ) ;
  ( "-c", Arg.Set_string code_file_string, "Output code file" ) ;
  ( "-d", Arg.Set_string doc_file_string,  "Output doc file" )
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

let dump_doc info pp items =
  pp # setup info;
  List.iter
    ( fun item ->
	match item with
	  | Expr.LpCode txt ->
	      pp # print_code txt

	  | Expr.LpComment txt ->
	      let lexbuf = Lexing.from_string txt in
	      let result = Lp_parser.main Lp_lexer.main lexbuf in
		pp # print_doc result )
    items;
  pp # teardown info

let main () =
  let _ = Arg.parse specs ( fun _ -> () ) usage in
    try
      let _ = if lp_file () = "" then
	invalid_arg ( "Invalid filename: " ^ ( lp_file () ) )
      in

      let input = open_in ( lp_file () ) in
      let code_output = open_out ( code_file () ) in
      let doc_output = open_out ( doc_file () ) in

      let result = split_source input in
      let info = { path = lp_file (); comment = copyright } in
      let pp = new Html.pretty_printer doc_output in

      let _ = dump_code code_output result in
      let _ = dump_doc info pp result in

	close_in input;
	close_out code_output;
	close_out doc_output

    with
      | Parsing.Parse_error ->
	  Printf.fprintf stderr "Error: parsing failed !\n";
	  exit 0
      | Invalid_argument what ->
	  Printf.fprintf stderr "%s\n" what;
	  exit 0

let _ = Printexc.print main ()
