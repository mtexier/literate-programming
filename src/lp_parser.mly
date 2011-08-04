%{
  let line = ref 1
%}

%token <string> CHAR

%token VERBATIM
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
    VERBATIM string END  { (Expr.Verbatim,$2) }
;

string:
                { "" }
  | CHAR string { $1 ^ $2 }
;

%%
