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

%{
  let line = ref 1
%}

%token <string> CHAR

%token VERBATIM BOLD ITALIC UNDERLINE
%token <int> SECT
%token END

%token EOF

%start main
%type <( Expr.cattr * string ) list> main

%%

main:
    string main    { (Expr.Normal,$1)::$2 }
  | formatted main { $1::$2 }
  | EOF            { [] }
;

formatted:
    BOLD string END      { (Expr.Bold,$2) }
  | ITALIC string END    { (Expr.Italic,$2) }
  | UNDERLINE string END { (Expr.Underline,$2) }
  | VERBATIM string END  { (Expr.Verbatim,$2) }
  | SECT string END      { (Expr.Section $1,$2) }
;

string:
                { "" }
  | CHAR string { $1 ^ $2 }
;

%%
