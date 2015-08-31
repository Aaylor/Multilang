OCAMLC          = ocamlc
OCAMLDOC	= ocamldoc
OCAMLOPT        = ocamlopt
OCAMLMKLIB      = ocamlmklib
OCAMLFIND       = ocamlfind
FOLDERS_OPT     = -I $(SOURCES_FOLDER)
OCAMLC_FLAGS    = $(FOLDERS_OPT) -w @1..8 -w @10..26 -w @28..31 -w @39..49 -annot
OCAMLFIND_FLAGS =

OCAMLDOC_FLAGS  = -html -d $(OCAMLDOC_FOLDER) -t Multilang \
			-colorize-code -short-functors
OCAMLDOC_FOLDER = doc

LIB_FOLDER = lib
LIB_NAME   = Multilang
LIB_DIST   = $(LIB_FOLDER)/$(LIB_NAME)
LIB_DIST_NATIVE = $(LIB_DIST).cmxa
LIB_DIST_BYTECODE = $(LIB_DIST).cma

SOURCES_FOLDER=src
SOURCES=$(shell find $(SOURCES_FOLDER) -name "*.ml")
SOURCES_MLI=$(SOURCES:.ml=.mli)
SOURCES_CMI=$(SOURCES:.ml=.cmi)
SOURCES_OBJ_BYT=$(SOURCES:.ml=.cmo)
SOURCES_OBJ_NAT=$(SOURCES:.ml=.cmx)

.PHONY: all
all: lexer depend $(LIB_DIST_NATIVE) $(LIB_DIST_BYTECODE)


# Library compilation
COMPILATION_ORDER = lexer.cmx multilang.cmx
COMPILATION_ORDER_BYT=$(COMPILATION_ORDER:.cmx=.cmo)

$(LIB_DIST_NATIVE): $(SOURCES_OBJ_NAT) $(SOURCES_OBJ_BYT)
	@ mkdir -p $(LIB_FOLDER)
	$(OCAMLFIND) $(OCAMLOPT) $(FOLDERS_OPT) $(OCAMLFIND_FLAGS) \
		-a -o $(LIB_DIST_NATIVE) $(COMPILATION_ORDER)

$(LIB_DIST_BYTECODE): $(SOURCES_OBJ_NAT) $(SOURCES_OBJ_BYT)
	@ mkdir -p $(LIB_FOLDER)
	$(OCAMLFIND) $(OCAMLC) $(FOLDERS_OPT) $(OCAMLFIND_FLAGS) \
		-a -o $(LIB_DIST_BYTECODE) $(COMPILATION_ORDER_BYT)


.PHONY: doc
doc:
	mkdir -p $(OCAMLDOC_FOLDER)
	$(OCAMLFIND) $(OCAMLDOC) $(OCAMLDOC_FLAGS) \
		$(FOLDERS_OPT) $(SOURCES_MLI)



# Opam

PACKAGE = $(LIB_NAME)
INSTALL = META $(LIB_BYTECODE) $(LIB_NATIVE) $(SOURCES_ML) $(SOURCES_MLI) \
		  $(SOURCES_OBJ_BYT) $(SOURCES_OBJ_NAT) $(SOURCES_CMI) \
		  $(LIB_DIST).cmxa $(LIB_DIST).a

install: $(LIB_BYTECODE) $(LIB_NATIVE)
	ocamlfind install $(PACKAGE) $(INSTALL)

.PHONY: uninstall
uninstall:
	ocamlfind remove $(PACKAGE)

.PHONY: reinstall
reinstall:
	$(MAKE) uninstall
	$(MAKE)
	$(MAKE) install


# Others

.PHONY: clean
clean:
	find . \( -name "*.cm*" -o -name "*.o" -o -name "*.a" \
		-o -name "*.ml.*" -o -name "dump_*" -o -name "*.annot" \) \
		-delete
	rm -rf $(OCAMLDOC_FOLDER)



.PHONY: lexer
lexer:
	ocamllex src/lexer.mll

.SUFFIXES: .ml .mll .mli .cmo .cmi .cmx

.ml.cmo:
	$(OCAMLFIND) $(OCAMLC) $(OCAMLC_FLAGS) $(OCAMLFIND_FLAGS) -c $<

.mli.cmi:
	$(OCAMLFIND) $(OCAMLC) $(OCAMLC_FLAGS) $(OCAMLFIND_FLAGS) -c $<

.ml.cmx:
	$(OCAMLFIND) $(OCAMLOPT) $(OCAMLC_FLAGS) $(OCAMLFIND_FLAGS) -c $<

.PHONY: depend
depend:
	ocamldep $(FOLDERS_OPT) $(SOURCES_MLI) $(SOURCES) > .depend
-include .depend
