SHELL    := /bin/bash
ROOTDIR  := ../..
DBDIR    := $(ROOTDIR)/db
RAWDIR   := raw

DBDIR_ABS  := $(abspath $(DBDIR))
RAWDIR_ABS := $(abspath $(RAWDIR))

GOSOURCEURL  := http://current.geneontology.org/ontology/go-basic.obo
GOSOURCENAME := Gene Ontology

CURL := curl --fail -C - --retry 3 --retry-delay 10

# Remove partial targets on recipe failure so the next make retries cleanly.
# .tmp download files are not targets and survive failures for curl to resume.
.DELETE_ON_ERROR:

# ── Download ──────────────────────────────────────────────────────────────────

.PHONY: download
download: $(RAWDIR)/go-basic.obo

$(RAWDIR)/go-basic.obo:
	mkdir -p $(RAWDIR)
	$(CURL) -o $@.tmp $(GOSOURCEURL)
	mv $@.tmp $@

# ── Parse: OBO → 5 text tables ───────────────────────────────────────────────
# parseOBO.R is run from raw/goterm/ so it writes its output files there.
# It reads go-basic.obo one directory up (../go-basic.obo relative to goterm/).
# A stamp file prevents re-running the R script once per output file.

GOTERM_DIR := $(RAWDIR)/goterm
GOTERM_TXT := $(addprefix $(GOTERM_DIR)/,\
    term.txt term2term.txt term_definition.txt term_synonym.txt graph_path.txt)

$(RAWDIR)/.goterm_done: $(RAWDIR)/go-basic.obo script/parseOBO.R
	mkdir -p $(GOTERM_DIR)
	cd $(GOTERM_DIR) && Rscript ../../script/parseOBO.R
	touch $@

$(GOTERM_TXT): $(RAWDIR)/.goterm_done

# ── gosrcsrc.sqlite (intermediate) ───────────────────────────────────────────
# Built from the 5 text tables; consumed by the bindb steps below.
# Runs from raw/ so that ".read ../script/term.sql" and
# ".import goterm/term.txt" resolve correctly.

SCHEMA_SQL := $(addprefix script/,\
    term.sql term_synonym.sql term_definition.sql term2term.sql graph_path.sql)

$(RAWDIR)/gosrcsrc.sqlite: $(GOTERM_TXT) script/srcdb.sql $(SCHEMA_SQL)
	rm -f $@
	cd $(RAWDIR) && sqlite3 -bail $(RAWDIR_ABS)/gosrcsrc.sqlite < ../script/srcdb.sql
	sqlite3 $@ "INSERT INTO metadata VALUES('GOSOURCENAME','$(GOSOURCENAME)');"
	sqlite3 $@ "INSERT INTO metadata VALUES('GOSOURCEURL','$(GOSOURCEURL)');"
	sqlite3 $@ "INSERT INTO metadata VALUES('GOSOURCEDATE','$$(date +%Y-%m-%d)');"

# ── GO.sqlite ─────────────────────────────────────────────────────────────────
# bindb4.sql: ATTACHes gosrcsrc.sqlite; run from raw/ where that file lives.
# bindb5.sql: ATTACHes genesrc.sqlite and metadatasrc.sqlite; run from db/.

$(DBDIR)/GO.sqlite: $(RAWDIR)/gosrcsrc.sqlite $(DBDIR)/genesrc.sqlite \
        script/bindb4.sql script/bindb5.sql
	mkdir -p $(DBDIR_ABS)
	rm -f $@
	cd $(RAWDIR) && sqlite3 -bail $(DBDIR_ABS)/GO.sqlite < ../script/bindb4.sql
	cd $(DBDIR_ABS) && sqlite3 -bail GO.sqlite < $(CURDIR)/script/bindb5.sql

# ── GO_ORGANISM_SPEC.sqlite ───────────────────────────────────────────────────
# bindb1.sql: ATTACHes gosrcsrc.sqlite; run from raw/.
# bindb2.sql: ATTACHes genesrc.sqlite; run from db/.

$(DBDIR)/GO_ORGANISM_SPEC.sqlite: $(RAWDIR)/gosrcsrc.sqlite $(DBDIR)/genesrc.sqlite \
        script/bindb1.sql script/bindb2.sql
	mkdir -p $(DBDIR_ABS)
	rm -f $@
	cd $(RAWDIR) && sqlite3 -bail $(DBDIR_ABS)/GO_ORGANISM_SPEC.sqlite < ../script/bindb1.sql
	cd $(DBDIR_ABS) && sqlite3 -bail GO_ORGANISM_SPEC.sqlite < $(CURDIR)/script/bindb2.sql

# ── gosrc.sqlite ──────────────────────────────────────────────────────────────
# bindb3.sql: ATTACHes GO_ORGANISM_SPEC.sqlite; run from db/.
# This is the file consumed by organism_annotation when building chipsrc_*.sqlite.

$(DBDIR)/gosrc.sqlite: $(DBDIR)/GO_ORGANISM_SPEC.sqlite script/bindb3.sql
	mkdir -p $(DBDIR_ABS)
	rm -f $@
	cd $(DBDIR_ABS) && sqlite3 -bail gosrc.sqlite < $(CURDIR)/script/bindb3.sql

# ── Clean ─────────────────────────────────────────────────────────────────────
.PHONY: clean
clean:
	rm -rf $(RAWDIR)
	rm -f $(DBDIR)/gosrc.sqlite $(DBDIR)/GO.sqlite $(DBDIR)/GO_ORGANISM_SPEC.sqlite
