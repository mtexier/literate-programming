IFACES=\
	src/expr.mli \
	src/lp_parser.mli

SOURCES=\
	src/file_lexer.ml \
	src/lp_parser.ml \
	src/lp_lexer.ml \
	src/debug.ml \
	src/html.ml \
	src/main.ml

TARGET=lp

IOBJECTS=$(IFACES:.mli=.cmi)
SOBJECTS=$(SOURCES:.ml=.cmo)
GENERATED=\
	src/file_lexer.ml \
	src/lp_lexer.ml \
	src/lp_parser.mli \
	src/lp_parser.ml

OFLAGS=-I src

TARGET=lp

$(TARGET): $(SOBJECTS)
	ocamlc $(OFLAGS) -o $@ $^

%.cmi: %.mli
	ocamlc $(OFLAGS) -c $<

%.cmo: %.ml
	ocamlc $(OFLAGS) -c $<

%.ml: %.mll
	ocamllex $<

%.mli %.ml: %.mly
	ocamlyacc $<

src/file_lexer.cmo: src/expr.cmi src/file_lexer.ml

src/lp_lexer.ml: src/lp_parser.mli
src/lp_lexer.cmo: src/expr.cmi src/lp_parser.cmi src/lp_lexer.ml
src/lp_parser.cmo: src/expr.cmi src/lp_parser.cmi src/lp_parser.ml

clean:
	find . -name "*~" | xargs rm -rf
	rm -rf src/*.cm[io]
	rm -rf $(GENERATED)
	rm -rf $(TARGET)
