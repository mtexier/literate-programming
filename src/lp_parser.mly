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
