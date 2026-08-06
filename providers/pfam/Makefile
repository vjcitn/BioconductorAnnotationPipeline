SHELL    := /bin/bash
ROOTDIR  := ../..
DBDIR    := $(ROOTDIR)/db
RAWDIR   := raw

DBDIR_ABS  := $(abspath $(DBDIR))
RAWDIR_ABS := $(abspath $(RAWDIR))

PFAMSOURCEURL  := ftp://ftp.ebi.ac.uk/pub/databases/Pfam/current_release
PFAMSOURCENAME := PFAM IDs

CURL := curl --fail -L -C - --retry 3 --retry-delay 10

# Remove partial targets on recipe failure so the next make retries cleanly.
# .tmp download files are not targets and survive failures for curl to resume.
.DELETE_ON_ERROR:

# ── R dependency check ────────────────────────────────────────────────────────
# parseIDs.R uses only base R; this confirms Rscript is callable.
.PHONY: check-r-deps
check-r-deps:
	@Rscript -e "cat(R.version.string, 'OK\n')" || \
	    { echo "ERROR: Rscript not found or not working"; exit 1; }

# ── Download ──────────────────────────────────────────────────────────────────
# Pfam-A.full.gz is ~4GB; -C - resumes interrupted downloads.

.PHONY: download
download: $(RAWDIR)/Pfam-A.full.gz

$(RAWDIR)/Pfam-A.full.gz:
	mkdir -p $(RAWDIR)
	$(CURL) --disable-epsv -o $@.tmp $(PFAMSOURCEURL)/Pfam-A.full.gz
	mv $@.tmp $@

# ── Step 1: extract GF/GS records into ID text files ─────────────────────────
# simplifyToIds.sh streams through Pfam-A.full.gz via zcat+awk and writes:
# Pfam-A.GF, Pfam-A.GS, DR_IDs.txt, DE_IDs.txt, ID_IDs.txt,
# TP_IDs.txt, RM_IDs.txt, PDB_IDs.txt

$(RAWDIR)/.simplify_done: $(RAWDIR)/Pfam-A.full.gz script/simplifyToIds.sh
	cd $(RAWDIR) && bash ../script/simplifyToIds.sh
	touch $@

# ── Step 2: parse ID text files into .tab files (R) ──────────────────────────
# parseIDs.R reads the text files and writes one .tab file per ID type.
# Uses only base R; stamp file covers all outputs at once.

$(RAWDIR)/.parseids_done: $(RAWDIR)/.simplify_done script/parseIDs.R
	$(MAKE) check-r-deps
	cd $(RAWDIR) && Rscript ../script/parseIDs.R
	touch $@

# ── PFAM.sqlite ───────────────────────────────────────────────────────────────
# srcdb_pfam.sql imports all .tab files from the raw directory.
# The resulting PFAM.sqlite is placed in db/ for organism_annotation to ATTACH.

$(DBDIR)/PFAM.sqlite: $(RAWDIR)/.parseids_done script/srcdb_pfam.sql
	mkdir -p $(DBDIR_ABS)
	rm -f $@
	cd $(RAWDIR) && sqlite3 -bail $(DBDIR_ABS)/PFAM.sqlite < ../script/srcdb_pfam.sql
	sqlite3 $@ "INSERT INTO metadata VALUES('PFAMSOURCENAME','$(PFAMSOURCENAME)');"
	sqlite3 $@ "INSERT INTO metadata VALUES('PFAMSOURCEURL','$(PFAMSOURCEURL)');"
	sqlite3 $@ "INSERT INTO metadata VALUES('PFAMSOURCEDATE','$$(date +%Y-%b%d)');"

# ── Clean ─────────────────────────────────────────────────────────────────────
.PHONY: clean clean-raw clean-db

clean-raw:
	rm -rf $(RAWDIR)

clean-db:
	rm -f $(DBDIR)/PFAM.sqlite

clean: clean-raw clean-db
