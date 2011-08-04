module Output =
struct

  let setup out = ()
  let teardown out = ()

  let print out =
    List.iter
      ( fun item ->
	  match item with
	    | Expr.LpCode text ->
		Printf.fprintf out "%s" text
	    | Expr.LpComment text ->
		Printf.fprintf out "%s\n" text )

end
