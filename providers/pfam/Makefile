SHELL    := /bin/bash
ROOTDIR  := ../..

# Set by the top-level Makefile (exported); defaults to <repo>/data when
# this Makefile is invoked standalone.
DATA_ROOT ?= $(abspath $(ROOTDIR)/data)
DBDIR    := $(DATA_ROOT)/db
RAWDIR   := $(DATA_ROOT)/raw/pfam

DBDIR_ABS   := $(abspath $(DBDIR))
RAWDIR_ABS  := $(abspath $(RAWDIR))
SCRIPTDIR   := $(abspath script)

PFAMSOURCEURL  := ftp://ftp.ebi.ac.uk/pub/databases/Pfam/current_release
PFAMSOURCENAME := PFAM IDs

CURL := curl --fail -L -C - --retry 3 --retry-delay 10

# Remove partial targets on recipe failure so the next make retries cleanly.
# .tmp download files are not targets and survive failures for curl to resume.
.DELETE_ON_ERROR:

.PHONY: all
all: $(RAWDIR)/.regions_done

# ── Download ──────────────────────────────────────────────────────────────────
# Pfam-A.regions.tsv.gz (~5GB) directly provides the uniprot_id -> pfam_id
# mapping needed for OrgDb assembly; it's the only Pfam data this pipeline
# consumes downstream (see SIMPLIFY/SIMPLIFICATION_PLAN.md). The much larger
# Pfam-A.full.gz (~24GB) was previously parsed into family-level
# cross-reference tables (cazy, interpro, prosite, etc.) that nothing in the
# organism-assembly or OrgDb-build steps ever reads; that chain was removed.

.PHONY: download
download: $(RAWDIR)/Pfam-A.regions.tsv.gz

$(RAWDIR)/Pfam-A.regions.tsv.gz:
	mkdir -p $(RAWDIR)
	$(CURL) --disable-epsv -o $@.tmp $(PFAMSOURCEURL)/Pfam-A.regions.tsv.gz
	mv $@.tmp $@

# ── PFAM.sqlite: UniProt -> Pfam family mapping ──────────────────────────────
# load_regions.sh creates PFAM.sqlite (if needed) and loads uniprot2pfam
# directly from the regions TSV.

$(RAWDIR)/.regions_done: $(RAWDIR)/Pfam-A.regions.tsv.gz \
                          script/load_regions.sh
	mkdir -p $(DBDIR_ABS)
	bash $(SCRIPTDIR)/load_regions.sh \
	    $(DBDIR_ABS)/PFAM.sqlite \
	    $(RAWDIR_ABS)/Pfam-A.regions.tsv.gz
	sqlite3 $(DBDIR_ABS)/PFAM.sqlite "CREATE TABLE IF NOT EXISTS metadata (name TEXT, value TEXT);"
	sqlite3 $(DBDIR_ABS)/PFAM.sqlite "DELETE FROM metadata WHERE name LIKE 'PFAMSOURCE%';"
	sqlite3 $(DBDIR_ABS)/PFAM.sqlite "INSERT INTO metadata VALUES('PFAMSOURCENAME','$(PFAMSOURCENAME)');"
	sqlite3 $(DBDIR_ABS)/PFAM.sqlite "INSERT INTO metadata VALUES('PFAMSOURCEURL','$(PFAMSOURCEURL)');"
	sqlite3 $(DBDIR_ABS)/PFAM.sqlite "INSERT INTO metadata VALUES('PFAMSOURCEDATE','$$(date +%Y-%b%d)');"
	touch $@

# ── Clean ─────────────────────────────────────────────────────────────────────
.PHONY: clean clean-raw clean-db

clean-raw:
	rm -rf $(RAWDIR)

clean-db:
	rm -f $(DBDIR)/PFAM.sqlite

clean: clean-raw clean-db
