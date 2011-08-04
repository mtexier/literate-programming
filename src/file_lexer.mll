{
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
