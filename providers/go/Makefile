SHELL    := /bin/bash
ROOTDIR  := ../..
DBDIR    := $(ROOTDIR)/db
RAWDIR   := raw

DBDIR_ABS  := $(abspath $(DBDIR))
RAWDIR_ABS := $(abspath $(RAWDIR))

GOSOURCEURL  := http://current.geneontology.org/ontology/go-basic.obo
GOSOURCENAME := Gene Ontology

CURL := curl --fail -L -C - --retry 3 --retry-delay 10

# ── R dependency check ────────────────────────────────────────────────────────
# parseOBO.R requires these packages; fail early with a clear message if any
# are missing rather than discovering it mid-run.
.PHONY: check-r-deps
check-r-deps:
	@Rscript -e "\
	    pkgs <- c('GSEABase','dplyr','tidyr','stringi','graph','RBGL'); \
	    missing <- pkgs[!sapply(pkgs, requireNamespace, quietly=TRUE)]; \
	    if (length(missing)) { \
	        cat('ERROR: missing R packages:', paste(missing, collapse=', '), '\n'); \
	        cat('Install with: BiocManager::install(c(', \
	            paste0('\"', missing, '\"', collapse=','), '))\n'); \
	        quit(status=1) \
	    } else { \
	        cat('R packages OK:', paste(pkgs, collapse=', '), '\n') \
	    }"

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
	$(MAKE) check-r-deps
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
	rm -f $@ $@.tmp
	cd $(RAWDIR) && sqlite3 -bail $(RAWDIR_ABS)/gosrcsrc.sqlite.tmp < ../script/srcdb.sql
	sqlite3 $@.tmp "INSERT INTO metadata VALUES('GOSOURCENAME','$(GOSOURCENAME)');"
	sqlite3 $@.tmp "INSERT INTO metadata VALUES('GOSOURCEURL','$(GOSOURCEURL)');"
	sqlite3 $@.tmp "INSERT INTO metadata VALUES('GOSOURCEDATE','$$(date +%Y-%m-%d)');"
	mv $@.tmp $@

# ── GO.sqlite ─────────────────────────────────────────────────────────────────
# bindb4.sql: ATTACHes gosrcsrc.sqlite; run from raw/ where that file lives.
# bindb5.sql: ATTACHes genesrc.sqlite and metadatasrc.sqlite; run from db/.

$(DBDIR)/GO.sqlite: $(RAWDIR)/gosrcsrc.sqlite $(DBDIR)/genesrc.sqlite \
        script/bindb4.sql script/bindb5.sql
	mkdir -p $(DBDIR_ABS)
	rm -f $@ $@.tmp
	cd $(RAWDIR) && sqlite3 -bail $(DBDIR_ABS)/GO.sqlite.tmp < ../script/bindb4.sql
	cd $(DBDIR_ABS) && sqlite3 -bail GO.sqlite.tmp < $(CURDIR)/script/bindb5.sql
	mv $@.tmp $@

# ── GO_ORGANISM_SPEC.sqlite ───────────────────────────────────────────────────
# bindb1.sql: ATTACHes gosrcsrc.sqlite; run from raw/.
# bindb2.sql: ATTACHes genesrc.sqlite; run from db/.

$(DBDIR)/GO_ORGANISM_SPEC.sqlite: $(RAWDIR)/gosrcsrc.sqlite $(DBDIR)/genesrc.sqlite \
        script/bindb1.sql script/bindb2.sql
	mkdir -p $(DBDIR_ABS)
	rm -f $@ $@.tmp
	cd $(RAWDIR) && sqlite3 -bail $(DBDIR_ABS)/GO_ORGANISM_SPEC.sqlite.tmp < ../script/bindb1.sql
	cd $(DBDIR_ABS) && sqlite3 -bail GO_ORGANISM_SPEC.sqlite.tmp < $(CURDIR)/script/bindb2.sql
	mv $@.tmp $@

# ── gosrc.sqlite ──────────────────────────────────────────────────────────────
# bindb3.sql: ATTACHes GO_ORGANISM_SPEC.sqlite; run from db/.
# This is the file consumed by organism_annotation when building chipsrc_*.sqlite.

$(DBDIR)/gosrc.sqlite: $(DBDIR)/GO_ORGANISM_SPEC.sqlite script/bindb3.sql
	mkdir -p $(DBDIR_ABS)
	rm -f $@ $@.tmp
	cd $(DBDIR_ABS) && sqlite3 -bail gosrc.sqlite.tmp < $(CURDIR)/script/bindb3.sql
	mv $@.tmp $@

# ── Clean ─────────────────────────────────────────────────────────────────────
## Named convenience target so the top-level Makefile can call
## $(MAKE) -C providers/go go-sqlite without needing to resolve paths.
.PHONY: go-sqlite
go-sqlite: $(DBDIR)/GO.sqlite

.PHONY: clean clean-raw clean-db

clean-raw:
	rm -rf $(RAWDIR)

clean-db:
	rm -f $(DBDIR)/gosrc.sqlite $(DBDIR)/GO.sqlite $(DBDIR)/GO_ORGANISM_SPEC.sqlite

clean: clean-raw clean-db
