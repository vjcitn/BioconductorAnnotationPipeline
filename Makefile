SHELL        := /bin/bash
CONFIG       := config/species.tsv
BIOC_PKG_VERSION := 3.24.0

# Set SPECIES=<name> to operate on one organism; default runs all 19.
SPECIES ?= all

ALL_SPECIES := $(shell tail -n +2 $(CONFIG) | awk '{print $$1}')

ifeq ($(SPECIES),all)
  TARGET_SPECIES := $(ALL_SPECIES)
else
  TARGET_SPECIES := $(SPECIES)
endif

# ── Help ──────────────────────────────────────────────────────────────────────
.PHONY: help
help:
	@echo "Usage:"
	@echo "  make check-r-deps          # verify all required R packages are installed"
	@echo "  make download              # download data for all species"
	@echo "  make download SPECIES=human  # download only what human needs"
	@echo "  make package  SPECIES=human  # build org.Hs.eg.db (and human.db0)"
	@echo "  make package               # build all OrgDb packages"
	@echo "  make clean-raw             # remove downloaded files (preserves built SQLites)"
	@echo "  make clean-db              # remove built SQLites (preserves downloads)"
	@echo "  make clean                 # remove everything"
	@echo ""
	@echo "Species defined in $(CONFIG):"
	@tail -n +2 $(CONFIG) | awk '{printf "  %-14s taxid=%-8s ucsc=%s\n", $$1, $$2, $$3}'

# ── R dependency check ───────────────────────────────────────────────────────
# Run before any build to verify all required R packages are present.
.PHONY: check-r-deps
check-r-deps:
	$(MAKE) -C providers/gene check-r-deps
	$(MAKE) -C providers/go   check-r-deps
	@Rscript -e "\
	    pkgs <- c('AnnotationForge','AnnotationDbi','BiocManager'); \
	    missing <- pkgs[!sapply(pkgs, requireNamespace, quietly=TRUE)]; \
	    if (length(missing)) { \
	        cat('ERROR: missing R packages:', paste(missing, collapse=', '), '\n'); \
	        cat('Install with: BiocManager::install(c(', \
	            paste0('\"', missing, '\"', collapse=','), '))\n'); \
	        quit(status=1) \
	    } else { \
	        cat('R packages OK:', paste(pkgs, collapse=', '), '\n') \
	    }"

# ── Download ──────────────────────────────────────────────────────────────────
# Shared providers always run; per-species and organism-specific providers
# are filtered by TARGET_SPECIES.

.PHONY: download
download: _download_shared _download_ucsc _download_organism_specific

.PHONY: _download_shared
_download_shared:
	$(MAKE) -C providers/gene    download
	$(MAKE) -C providers/go      download
	$(MAKE) -C providers/pfam    download
	$(MAKE) -C providers/uniprot download

.PHONY: _download_ucsc
_download_ucsc:
	$(MAKE) -C providers/ucsc download SPECIES="$(TARGET_SPECIES)"

.PHONY: _download_organism_specific
_download_organism_specific:
	@for sp in $(TARGET_SPECIES); do \
	    case $$sp in \
	        yeast)       $(MAKE) -C providers/yeast    download ;; \
	        arabidopsis) $(MAKE) -C providers/tair     download ;; \
	        malaria)     $(MAKE) -C providers/plasmoDB download ;; \
	        fly)         $(MAKE) -C providers/flybase  download ;; \
	    esac; \
	done

# ── Intermediate assembly ─────────────────────────────────────────────────────
# Builds db/chipsrc_<species>.sqlite from the provider SQLite files.
# scripts/assemble_species.sh wraps the per-species SQL from organism_annotation/.

# uniprot.sqlite and PFAM.sqlite are optional; include as dependencies only
# when they exist so Make rebuilds chipsrc when either provider completes.
UNIPROT_DEP := $(wildcard db/uniprot.sqlite)
PFAM_DEP    := $(wildcard db/PFAM.sqlite)

db/chipsrc_%.sqlite: db/genesrc.sqlite db/gosrc.sqlite $(UNIPROT_DEP) $(PFAM_DEP)
	@mkdir -p db
	bash scripts/assemble_species.sh $*

# ── Package ───────────────────────────────────────────────────────────────────
# Builds OrgDb packages directly via AnnotationForge::makeOrgPackage().
# Reads genus/species/prefix from config/species.tsv; no hard-coded names.
# No db0 intermediate step required.

.PHONY: package
package: $(foreach sp,$(TARGET_SPECIES),db/chipsrc_$(sp).sqlite)
	@mkdir -p packages/orgdb
	Rscript scripts/make_orgdb.R \
	    --species "$(TARGET_SPECIES)" \
	    --config  $(CONFIG) \
	    --dbpath  db/ \
	    --outdir  packages/orgdb/ \
	    --version $(BIOC_PKG_VERSION)

# ── GO.db package ─────────────────────────────────────────────────────────────
# Builds GO.db from db/GO.sqlite (produced by providers/go/).
# Run `cd providers/go && make` first if db/GO.sqlite does not exist.

.PHONY: godb
godb:
	@mkdir -p packages/godb
	$(MAKE) -C providers/go go-sqlite
	Rscript scripts/make_godb.R \
	    --input   db/GO.sqlite \
	    --outdir  packages/godb/ \
	    --version $(BIOC_PKG_VERSION)

# ── Check ─────────────────────────────────────────────────────────────────────
# Validates a built OrgDb tarball against its chipsrc ground truth.
# Requires SPECIES= and that the tarball already exists in packages/orgdb/.

.PHONY: check
check:
	@for sp in $(TARGET_SPECIES); do \
	    tarball=$$(ls packages/orgdb/$$(awk -v s=$$sp '$$1==s{print $$4}' $(CONFIG)).db_*.tar.gz 2>/dev/null | tail -1); \
	    if [ -z "$$tarball" ]; then \
	        echo "ERROR: no tarball found for $$sp — run 'make package SPECIES=$$sp' first"; \
	        exit 1; \
	    fi; \
	    echo "Checking $$sp ($$tarball) ..."; \
	    Rscript tests/check_orgdb.R \
	        --species $$sp \
	        --dbpath  db/ \
	        --tarball $$tarball \
	    || exit 1; \
	done

# ── Clean ─────────────────────────────────────────────────────────────────────
.PHONY: clean clean-raw clean-db clean-packages

clean-raw:
	@for p in providers/*/; do \
	    [ -f $$p/Makefile ] && $(MAKE) -C $$p clean-raw || true; \
	done

clean-db:
	rm -f db/*.sqlite
	@for p in providers/*/; do \
	    [ -f $$p/Makefile ] && $(MAKE) -C $$p clean-db || true; \
	done

clean: clean-raw clean-db

clean-packages:
	rm -rf packages/orgdb/
