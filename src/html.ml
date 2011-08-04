class pretty_printer out =
object

  method setup () =
    Printf.fprintf out
      "<html>%s<body>"
      ( Printf.sprintf
	  "<head><link rel=\"stylesheet\" type=\"text/css\" href=\"%s\"></head>"
	  "style.css" )

  method teardown () =
    Printf.fprintf out "</body></html>\n"

  method print_code txt =
    Printf.fprintf out "<pre class=\"code\">%s</pre>" txt

  method print_doc items =
    Printf.fprintf out "<div class=\"doc\">";
    List.iter
      ( fun item ->
	  match item with
	    | Expr.Normal, txt ->
		Printf.fprintf out "<span class=\"normal\">%s</span>" txt

	    | Expr.Verbatim, txt ->
		Printf.fprintf out "<span class=\"verbatim\">%s</span>" txt )
      items;
    Printf.fprintf out "</div>"

end
