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

type info_t = {
  i_root : string ;
  i_out  : string ;
  i_path : string list;
  i_foot : string
}

class pretty_printer =
object (self)

  method suffix () = ".html"

  method setup out info =
    Printf.fprintf out "<html>\n";
    Printf.fprintf out "<head>\n";
    Printf.fprintf out
      "<link rel=\"stylesheet\" type=\"text/css\" href=\"%s\">\n"
      ( info.i_out ^ "/style.css" );
    Printf.fprintf out "</head>\n<body>";
    Printf.fprintf out "<div id=\"header\">File: %s " info.i_root;
    List.iter
      ( fun item ->
          Printf.fprintf out
	    "&gt; <a href=\"%s\">%s</a>"
	    ( item ^ self # suffix () )
            item )
      ( List.rev info.i_path );
    Printf.fprintf out "</div>"

  method teardown out info =
    Printf.fprintf out "\n<div id=\"footer\">%s</div>" info.i_foot;
    Printf.fprintf out "\n</body>\n</html>"

  method code out txt =
    Printf.fprintf out "\n<pre class=\"code\">%s</pre>" txt

  method doc out items =
    Printf.fprintf out "\n<div class=\"doc\">";
    List.iter
      ( fun item ->
	  match item with
	    | Expr.Normal, txt ->
	        Printf.fprintf out "%s" txt

	    | Expr.Bold, txt ->
	        Printf.fprintf out "<strong>%s</strong>" txt

	    | Expr.Italic, txt ->
	        Printf.fprintf out "<i>%s</i>" txt

	    | Expr.Underline, txt ->
	        Printf.fprintf out "<u>%s</u>" txt

	    | Expr.Verbatim, txt ->
	        Printf.fprintf out "<span class=\"verbatim\">%s</span>" txt

	    | Expr.Section lvl, txt ->
	        let lvl2 = min lvl 3 in
		  Printf.fprintf out "<h%d>%s</h%d>" lvl2 txt lvl2 )
      items;
    Printf.fprintf out "</div>"

end
