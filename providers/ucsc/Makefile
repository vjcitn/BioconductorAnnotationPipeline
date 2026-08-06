SHELL    := /bin/bash
ROOTDIR  := ../..
CONFIG   := $(ROOTDIR)/config/species.tsv
DBDIR    := $(ROOTDIR)/db
RAWDIR   := raw

DBDIR_ABS  := $(abspath $(DBDIR))
RAWDIR_ABS := $(abspath $(RAWDIR))

UCSCBASEURL    := rsync://hgdownload.cse.ucsc.edu/goldenPath
UCSCREFLINKURL := rsync://hgdownload.cse.ucsc.edu/goldenPath/hgFixed/database/refLink.txt.gz

# Species with non-NA UCSC builds (arabidopsis, xenopus, malaria, ecoli* are excluded)
ALL_UCSC_SPECIES := $(shell awk 'NR>1 && $$3 != "NA" {print $$1}' $(CONFIG))

SPECIES ?= all
ifeq ($(SPECIES),all)
  TARGET_SPECIES := $(ALL_UCSC_SPECIES)
else
  TARGET_SPECIES := $(SPECIES)
endif

# Map species.tsv name → UCSC script/directory name where they differ.
# Only zebrafish differs (UCSC scripts call it "fish").
ucsc_name = $(if $(filter zebrafish,$1),fish,$1)

# Look up ucsc_build for a species from config.
ucsc_build = $(shell awk -v sp='$1' 'NR>1 && $$1==sp {print $$3}' $(CONFIG))

.DELETE_ON_ERROR:

# ── refLink (shared, downloaded once into human dir) ─────────────────────────
$(RAWDIR)/human/refLink.txt.gz:
	mkdir -p $(RAWDIR)/human
	rsync -avzP $(UCSCREFLINKURL) $@

# ── Per-species download ──────────────────────────────────────────────────────
# Files vary by species:
#   human       : refGene, cytoBand, chromInfo, knownToLocusLink, refLink
#   mouse       : refGene, cytoBandIdeo→cytoBand, chromInfo, refLink
#   yeast       : chromInfo only
#   anopheles   : chromInfo only
#   all others  : refGene, chromInfo, refLink
#
# rsync is idempotent (skips unchanged files); a stamp records success.

$(RAWDIR)/%/.download_done: $(RAWDIR)/human/refLink.txt.gz
	$(eval SP    := $(patsubst $(RAWDIR)/%/.download_done,%,$@))
	$(eval BUILD := $(call ucsc_build,$(SP)))
	$(eval UNAME := $(call ucsc_name,$(SP)))
	mkdir -p $(RAWDIR)/$(UNAME) $(RAWDIR)/$(SP)
	@case "$(SP)" in \
	human) \
	    rsync -avzP $(UCSCBASEURL)/$(BUILD)/database/refGene.txt.gz          $(RAWDIR)/$(UNAME)/; \
	    rsync -avzP $(UCSCBASEURL)/$(BUILD)/database/chromInfo.txt.gz         $(RAWDIR)/$(UNAME)/; \
	    rsync -avzP $(UCSCBASEURL)/$(BUILD)/database/knownToLocusLink.txt.gz  $(RAWDIR)/$(UNAME)/; \
	    rsync -avzP $(UCSCBASEURL)/$(BUILD)/database/cytoBand.txt.gz          $(RAWDIR)/$(UNAME)/ || \
	        echo "WARNING: cytoBand.txt.gz not available for human — skipping"; \
	    ;; \
	mouse) \
	    rsync -avzP $(UCSCBASEURL)/$(BUILD)/database/refGene.txt.gz           $(RAWDIR)/$(UNAME)/; \
	    rsync -avzP $(UCSCBASEURL)/$(BUILD)/database/chromInfo.txt.gz         $(RAWDIR)/$(UNAME)/; \
	    cp $(RAWDIR)/human/refLink.txt.gz                                      $(RAWDIR)/$(UNAME)/; \
	    rsync -avzP $(UCSCBASEURL)/$(BUILD)/database/cytoBandIdeo.txt.gz      $(RAWDIR)/$(UNAME)/cytoBand.txt.gz || \
	        echo "WARNING: cytoBandIdeo.txt.gz not available for mouse — skipping"; \
	    ;; \
	yeast|anopheles) \
	    rsync -avzP $(UCSCBASEURL)/$(BUILD)/database/chromInfo.txt.gz         $(RAWDIR)/$(UNAME)/; \
	    cp $(RAWDIR)/human/refLink.txt.gz                                      $(RAWDIR)/$(UNAME)/; \
	    ;; \
	*) \
	    rsync -avzP $(UCSCBASEURL)/$(BUILD)/database/refGene.txt.gz           $(RAWDIR)/$(UNAME)/; \
	    rsync -avzP $(UCSCBASEURL)/$(BUILD)/database/chromInfo.txt.gz         $(RAWDIR)/$(UNAME)/; \
	    cp $(RAWDIR)/human/refLink.txt.gz                                      $(RAWDIR)/$(UNAME)/; \
	    rsync -avzP $(UCSCBASEURL)/$(BUILD)/database/cytoBandIdeo.txt.gz      $(RAWDIR)/$(UNAME)/cytoBand.txt.gz || \
	        echo "WARNING: cytoBandIdeo.txt.gz not available for $(SP) — skipping"; \
	    ;; \
	esac
	touch $@

.PHONY: download
download: $(foreach sp,$(TARGET_SPECIES),$(RAWDIR)/$(sp)/.download_done)

# ── Per-species parse → gpsrc.sqlite ─────────────────────────────────────────
# Decompress files, run species-specific srcdb SQL, write gpsrc.sqlite.
# srcdb_*.sql files use the UCSC name (e.g. srcdb_fish.sql for zebrafish).

$(RAWDIR)/%/gpsrc.sqlite: $(RAWDIR)/%/.download_done
	$(eval SP    := $(patsubst $(RAWDIR)/%/gpsrc.sqlite,%,$@))
	$(eval UNAME := $(call ucsc_name,$(SP)))
	$(eval BUILD := $(call ucsc_build,$(SP)))
	$(eval GPURL := $(subst rsync,ftp,$(UCSCBASEURL))/$(BUILD)/database)
	$(eval GPNAME:= UCSC Genome Bioinformatics)
	cd $(RAWDIR)/$(UNAME) && \
	    for f in *.txt.gz; do \
	        [ -f "$$f" ] && gunzip -kf "$$f" && echo "decompressed $$f" \
	        || echo "WARNING: could not decompress $$f — skipping"; \
	    done
	[ -f "$(RAWDIR)/$(UNAME)/cytoBand.txt" ] || \
	    { echo "WARNING: cytoBand.txt not available for $(SP) — creating empty file"; \
	      touch "$(RAWDIR)/$(UNAME)/cytoBand.txt"; }
	mkdir -p $(RAWDIR)/$(SP)
	rm -f $(RAWDIR_ABS)/$(SP)/gpsrc.sqlite
	cd $(RAWDIR)/$(UNAME) && \
	    sqlite3 -bail $(RAWDIR_ABS)/$(SP)/gpsrc.sqlite \
	        < $(CURDIR)/script/srcdb_$(UNAME).sql
	sqlite3 $(RAWDIR_ABS)/$(SP)/gpsrc.sqlite "INSERT INTO metadata VALUES('GPSOURCENAME','$(GPNAME)');"
	sqlite3 $(RAWDIR_ABS)/$(SP)/gpsrc.sqlite "INSERT INTO metadata VALUES('GPSOURCEURL','$(GPURL)');"
	sqlite3 $(RAWDIR_ABS)/$(SP)/gpsrc.sqlite "INSERT INTO metadata VALUES('GPSOURCEDATE','$$(date +%Y-%b%d)');"

# ── db/gpsrc.sqlite (aggregated across all UCSC species) ─────────────────────
# bindb.sql ATTACHes each species' gpsrc.sqlite by relative path.
# Must run from raw/ so ATTACH paths like "human/gpsrc.sqlite" resolve.
# Depends on all per-species SQLites.

ALL_GPSRC := $(foreach sp,$(ALL_UCSC_SPECIES),$(RAWDIR)/$(call ucsc_name,$(sp))/gpsrc.sqlite)

$(DBDIR)/gpsrc.sqlite: $(ALL_GPSRC) script/bindb.sql
	mkdir -p $(DBDIR_ABS)
	rm -f $@
	cd $(RAWDIR_ABS) && sqlite3 -bail $(DBDIR_ABS)/gpsrc.sqlite < $(CURDIR)/script/bindb.sql

# ── Clean ─────────────────────────────────────────────────────────────────────
.PHONY: clean clean-raw clean-db

clean-raw:
	rm -rf $(RAWDIR)

clean-db:
	rm -f $(DBDIR)/gpsrc.sqlite

clean: clean-raw clean-db
