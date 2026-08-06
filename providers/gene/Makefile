SHELL    := /bin/bash
ROOTDIR  := ../..
CONFIG   := $(ROOTDIR)/config/species.tsv
DBDIR    := $(ROOTDIR)/db
RAWDIR   := raw

EGSOURCEURL := ftp://ftp.ncbi.nlm.nih.gov/gene/DATA
TAXDUMP_URL := ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/new_taxdump/new_taxdump.tar.gz

# Absolute path to db/ so sqlite3 can be invoked from $(RAWDIR)
DBDIR_ABS := $(abspath $(DBDIR))

CURL := curl --fail -C - --retry 3 --retry-delay 10

# ── R dependency check ────────────────────────────────────────────────────────
# parseAlias.R uses only base R; this target confirms R itself is callable.
.PHONY: check-r-deps
check-r-deps:
	@Rscript -e "cat(R.version.string, 'OK\n')" || \
	    { echo "ERROR: Rscript not found or not working"; exit 1; }

# Remove partial targets on recipe failure so the next make retries cleanly.
# .tmp download files are not targets and survive failures for curl to resume.
.DELETE_ON_ERROR:

# ── Download ──────────────────────────────────────────────────────────────────
# All files are downloaded once and shared across all species; per-species
# filtering happens in the parse step using taxids from config/species.tsv.

GZ_DOWNLOADS := gene_info gene2go gene2pubmed gene2refseq \
                gene2accession gene_refseq_uniprotkb_collab gene_orthologs

.PHONY: download
download: $(foreach f,$(GZ_DOWNLOADS),$(RAWDIR)/$(f).gz) \
          $(RAWDIR)/mim2gene_medgen.raw \
          $(RAWDIR)/new_taxdump.tar.gz

$(RAWDIR)/%.gz:
	mkdir -p $(RAWDIR)
	$(CURL) --disable-epsv -o $@.tmp $(EGSOURCEURL)/$(notdir $@)
	mv $@.tmp $@

$(RAWDIR)/mim2gene_medgen.raw:
	mkdir -p $(RAWDIR)
	$(CURL) --disable-epsv -o $@.tmp $(EGSOURCEURL)/mim2gene_medgen
	mv $@.tmp $@

$(RAWDIR)/new_taxdump.tar.gz:
	mkdir -p $(RAWDIR)
	$(CURL) --disable-epsv -o $@.tmp $(TAXDUMP_URL)
	mv $@.tmp $@

# ── Taxid filter ──────────────────────────────────────────────────────────────
# Generates an awk script from species.tsv so taxids are never hard-coded here.

$(RAWDIR)/taxid_filter.awk: $(CONFIG)
	mkdir -p $(RAWDIR)
	( echo 'BEGIN{'; \
	  tail -n +2 $< | awk '{printf "    val[%s]\n", $$2}'; \
	  echo '}'; \
	  echo '$$1 in val' ) > $@

# ── Parsed text tables ────────────────────────────────────────────────────────

# gene2go, gene2pubmed: strip comments and filter by taxid
$(RAWDIR)/gene2go $(RAWDIR)/gene2pubmed: $(RAWDIR)/%: $(RAWDIR)/%.gz $(RAWDIR)/taxid_filter.awk
	zcat $< | awk '!/^#/' | awk -f $(RAWDIR)/taxid_filter.awk > $@

# gene2refseq, gene2accession: filter by taxid, then strip accession version numbers
$(RAWDIR)/gene2refseq $(RAWDIR)/gene2accession: $(RAWDIR)/%: $(RAWDIR)/%.gz $(RAWDIR)/taxid_filter.awk
	zcat $< | awk '!/^#/' | awk -f $(RAWDIR)/taxid_filter.awk | \
	    sed 's/\.[0-9]*\t/\t/g' > $@

# gene_info: filter by taxid, then fix MT gene symbols (col 3 → col 11 when they differ)
$(RAWDIR)/gene_info: $(RAWDIR)/gene_info.gz $(RAWDIR)/taxid_filter.awk
	zcat $< | awk '!/^#/' | awk -f $(RAWDIR)/taxid_filter.awk | \
	    awk -F'\t' 'BEGIN{OFS=FS} {if($$3 != $$11 && $$11 != "-") $$3 = $$11; print}' > $@

# gene_refseq_uniprotkb_collab: keep 2 columns, strip version numbers
$(RAWDIR)/gene_refseq_uniprotkb_collab: $(RAWDIR)/gene_refseq_uniprotkb_collab.gz
	zcat $< | awk '!/^#/' | cut -f1-2 | sed 's/\.[0-9]*\t/\t/g' > $@

# gene_orthologs: build bidirectional pairs (A→B and B→A both present)
$(RAWDIR)/gene_orthologs: $(RAWDIR)/gene_orthologs.gz
	zcat $< | awk '!/^#/' | cut -f1,2,4,5 > $(RAWDIR)/_orth_fwd
	awk '{print $$3"\t"$$4"\t"$$1"\t"$$2}' $(RAWDIR)/_orth_fwd > $(RAWDIR)/_orth_rev
	cat $(RAWDIR)/_orth_fwd $(RAWDIR)/_orth_rev > $@
	rm -f $(RAWDIR)/_orth_fwd $(RAWDIR)/_orth_rev

# names.txt: scientific names from NCBI taxonomy dump (uppercased, spaces→underscore)
$(RAWDIR)/names.txt: $(RAWDIR)/new_taxdump.tar.gz
	tar -xzf $< -C $(RAWDIR) names.dmp
	awk -F'|' '{if($$4 ~ /scientific name/) print toupper($$1$$2)}' $(RAWDIR)/names.dmp | \
	    tr -s '\t' | sed 's/"//g' | sed 's/ /_/g' | cut -f1-2 > $@

# mim2gene_medgen: strip comment lines so sqlite3 can import cleanly
$(RAWDIR)/mim2gene_medgen: $(RAWDIR)/mim2gene_medgen.raw
	grep -v '^#' $< > $@

# ── Alias tables (parseAlias.R) ───────────────────────────────────────────────
# parseAlias.R reads gene_info from its working directory and writes four tab
# files: gene_cytogenetic.tab, gene_chromosome.tab, gene_synonym.tab,
# gene_dbXrefs.tab. A stamp file records completion so Make doesn't re-run
# the R script once for each output file.

$(RAWDIR)/.alias_tabs_done: $(RAWDIR)/gene_info script/parseAlias.R
	$(MAKE) check-r-deps
	cd $(RAWDIR) && Rscript ../script/parseAlias.R
	touch $@

ALIAS_TABS := $(addprefix $(RAWDIR)/,gene_cytogenetic.tab gene_chromosome.tab \
                                      gene_synonym.tab gene_dbXrefs.tab)

$(ALIAS_TABS): $(RAWDIR)/.alias_tabs_done

# ── genesrc.sqlite ────────────────────────────────────────────────────────────
GENESRC_DEPS := \
    $(RAWDIR)/gene_info \
    $(RAWDIR)/gene2go \
    $(RAWDIR)/gene2pubmed \
    $(RAWDIR)/gene2refseq \
    $(RAWDIR)/gene2accession \
    $(RAWDIR)/gene_refseq_uniprotkb_collab \
    $(RAWDIR)/mim2gene_medgen \
    $(ALIAS_TABS) \
    script/srcdb.sql

$(DBDIR)/genesrc.sqlite: $(GENESRC_DEPS)
	mkdir -p $(DBDIR_ABS)
	rm -f $@
	cd $(RAWDIR) && sqlite3 -bail $(DBDIR_ABS)/genesrc.sqlite < ../script/srcdb.sql
	sqlite3 $@ "INSERT INTO metadata VALUES('EGSOURCEDATE','$$(date +%Y-%b%d)');"
	sqlite3 $@ "INSERT INTO metadata VALUES('EGSOURCENAME','Entrez Gene');"
	sqlite3 $@ "INSERT INTO metadata VALUES('EGSOURCEURL','$(EGSOURCEURL)');"

# ── Orthology.eg.sqlite ───────────────────────────────────────────────────────
$(DBDIR)/Orthology.eg.sqlite: $(RAWDIR)/gene_orthologs $(RAWDIR)/names.txt script/src_orthology.sql
	mkdir -p $(DBDIR_ABS)
	rm -f $@
	cd $(RAWDIR) && sqlite3 -bail $(DBDIR_ABS)/Orthology.eg.sqlite < ../script/src_orthology.sql
	sqlite3 $@ "INSERT INTO metadata VALUES('EGSOURCEDATE','$$(date +%Y-%b%d)');"
	sqlite3 $@ "INSERT INTO metadata VALUES('EGSOURCENAME','Entrez Gene');"
	sqlite3 $@ "INSERT INTO metadata VALUES('EGSOURCEURL','$(EGSOURCEURL)');"

# ── Clean ─────────────────────────────────────────────────────────────────────
.PHONY: clean clean-raw clean-db

clean-raw:
	rm -rf $(RAWDIR)

clean-db:
	rm -f $(DBDIR)/genesrc.sqlite $(DBDIR)/Orthology.eg.sqlite

clean: clean-raw clean-db
