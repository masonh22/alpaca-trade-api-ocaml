MODULES=common entity client_mine alp_test
OBJECTS=$(MODULES:=.cmo)
MLS=$(MODULES:=.ml)
MLIS=$(MODULES:=.mli)
MAIN=alp_test.byte
TEST=test.byte
OCAMLBUILD=ocamlbuild -use-ocamlfind

default: build
	utop

build:
	$(OCAMLBUILD) $(OBJECTS) $(MAIN)

test:
	$(OCAMLBUILD) -tag 'debug' $(TEST) && ./$(TEST)
	
docs: docs-public docs-private
	
docs-public: build
	mkdir -p doc.public
	ocamlfind ocamldoc -I _build -package yojson,ANSITerminal \
		-html -stars -d doc.public $(MLIS)

docs-private: build
	mkdir -p doc.private
	ocamlfind ocamldoc -I _build -package yojson,ANSITerminal \
		-html -stars -d doc.private \
		-inv-merge-ml-mli -m A $(MLIS) $(MLS)

clean:
	ocamlbuild -clean
	rm -rf doc.public doc.private
