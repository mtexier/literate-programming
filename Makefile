# This file is part of LpTool.

# LpTool is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# LpTool is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with LpTool.  If not, see <http://www.gnu.org/licenses/>.

IFACES=\
	src/expr.mli \
	src/lp_parser.mli

SOURCES=\
	src/file_lexer.ml \
	src/lp_parser.ml \
	src/lp_lexer.ml \
	src/dir.ml \
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
LFLAGS=unix.cma

TARGET=lp

all: $(TARGET)

$(TARGET): $(SOBJECTS)
	ocamlc $(OFLAGS) -o $@ $(LFLAGS) $^

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
