SHELL    := /bin/bash
ROOTDIR  := ../..
DBDIR    := $(ROOTDIR)/db
RAWDIR   := raw

DBDIR_ABS   := $(abspath $(DBDIR))
RAWDIR_ABS  := $(abspath $(RAWDIR))
SCRIPTDIR   := $(abspath script)

UPSOURCEURL  := https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping
UPSOURCENAME := UniProt

# -C - resumes interrupted downloads; .tmp files survive failures for curl to resume.
CURL := curl --fail -L -C - --retry 3 --retry-delay 10

.DELETE_ON_ERROR:

.PHONY: all
all: $(DBDIR)/uniprot.sqlite

.PHONY: download
download: $(RAWDIR)/idmapping_selected.tab.gz

$(RAWDIR)/idmapping_selected.tab.gz:
	mkdir -p $(RAWDIR)
	$(CURL) -o $@.tmp $(UPSOURCEURL)/idmapping_selected.tab.gz
	mv $@.tmp $@

# ── Build uniprot.sqlite ──────────────────────────────────────────────────────
# Single awk pass over idmapping_selected.tab.gz extracts four mappings:
#   gene2uniprot        (uniprot_id, gene_id, taxon_id)   -> UNIPROT column
#   refseq2uniprot      (refseq_id,  uniprot_id)          -> legacy bridge
#   uniprot2ensembl_pro (uniprot_id, ensembl_pro_id)      -> ENSEMBLPROT
#   uniprot2ensembl_trs (uniprot_id, ensembl_trs_id)      -> ENSEMBLTRANS
# Temp TSV files land in RAWDIR so a symlink to large storage works.

$(DBDIR)/uniprot.sqlite: $(RAWDIR)/idmapping_selected.tab.gz script/build_uniprot.sh
	mkdir -p $(DBDIR_ABS)
	rm -f $@
	bash $(SCRIPTDIR)/build_uniprot.sh \
	    $(DBDIR_ABS)/uniprot.sqlite \
	    $(RAWDIR_ABS)/idmapping_selected.tab.gz \
	    $(RAWDIR_ABS)

# ── Clean ─────────────────────────────────────────────────────────────────────
.PHONY: clean clean-raw clean-db
clean-raw:
	rm -rf $(RAWDIR)
clean-db:
	rm -f $(DBDIR)/uniprot.sqlite
clean: clean-raw clean-db
