STAMP_DIR ?= $(ROOT_DIR)/.build/stamps
PKG_DATE ?= $(shell date +%Y%m%d)
PKG_VERSION ?= 3.23.0
R_BIN ?= R
RSCRIPT_BIN ?= Rscript
ANNOTATIONFORGE_INDEX ?= $(HOME)/R-libraries/AnnotationForge/extdata/GentlemanLab/ANNDBPKG-INDEX.TXT
SANCTIONED_SQLITE_DIR ?= $(ROOT_DIR)/newPkgs/sanctionedSqlite
PACKAGE_OUTPUT_DIR := $(ROOT_DIR)/newPkgs/$(PKG_DATE)_OrgDbs
DOWNLOAD_SOURCES := go gene ucsc yeast ensembl plasmoDB pfam inparanoid tair
DOWNLOAD_STAMPS := $(addprefix $(STAMP_DIR)/download/,$(addsuffix .stamp,$(DOWNLOAD_SOURCES)))
MODEL_PARSE_SOURCES := go gene goext ucsc yeast ensembl plasmoDB pfam inparanoid tair
MODEL_PARSE_STAMPS := $(addprefix $(STAMP_DIR)/model/parse/,$(addsuffix .stamp,$(MODEL_PARSE_SOURCES)))
MODEL_BUILD_SOURCES := chrlength gene blast2go go-db1 go-db2 kegg ucsc organism_annotation yeast plasmoDB inparanoid ensembl uniprot tair
MODEL_BUILD_STAMPS := $(addprefix $(STAMP_DIR)/model/build/,$(addsuffix .stamp,$(MODEL_BUILD_SOURCES)))

.PHONY: help print-config download model package clean GO.db org.Hs.eg.db \
	model-parse model-build \
	$(addprefix download-,$(DOWNLOAD_SOURCES)) \
	$(addprefix model-parse-,$(MODEL_PARSE_SOURCES)) \
	$(addprefix model-build-,$(MODEL_BUILD_SOURCES))

.NOTPARALLEL:

help:
	@echo "Targets:"
	@echo "  download      Fetch raw sources into annosrc/"
	@echo "  download-<source> Fetch one download source and stamp it"
	@echo "  model         Parse and build canonical sqlite intermediates"
	@echo "  model-parse   Parse all model inputs with per-source stamps"
	@echo "  model-build   Build all model sqlite outputs with per-source stamps"
	@echo "  model-parse-<source> Run one parse source"
	@echo "  model-build-<source> Run one build source"
	@echo "  package       Build the OrgDb family described in ADR 0001"
	@echo "  GO.db         Alias for the OrgDb family build that includes GO.db"
	@echo "  org.Hs.eg.db  Alias for the OrgDb family build that includes org.Hs.eg.db"
	@echo "  clean         Remove Make stamps and package outputs for PKG_DATE"
	@echo "  print-config  Show the current Make configuration"
	@echo ""
	@echo "Configurable variables: PKG_DATE=$(PKG_DATE) PKG_VERSION=$(PKG_VERSION)"
	@echo "Download sources: $(DOWNLOAD_SOURCES)"
	@echo "Model parse sources: $(MODEL_PARSE_SOURCES)"
	@echo "Model build sources: $(MODEL_BUILD_SOURCES)"
	@echo "See docs/adr/ for the architectural decisions behind this layout."

print-config:
	@printf 'ROOT_DIR=%s\n' '$(ROOT_DIR)'
	@printf 'STAMP_DIR=%s\n' '$(STAMP_DIR)'
	@printf 'PKG_DATE=%s\n' '$(PKG_DATE)'
	@printf 'PKG_VERSION=%s\n' '$(PKG_VERSION)'
	@printf 'RSCRIPT_BIN=%s\n' '$(RSCRIPT_BIN)'
	@printf 'ANNOTATIONFORGE_INDEX=%s\n' '$(ANNOTATIONFORGE_INDEX)'

download: $(STAMP_DIR)/download.stamp

$(addprefix download-,$(DOWNLOAD_SOURCES)): download-%: $(STAMP_DIR)/download/%.stamp

model: $(STAMP_DIR)/model.stamp

model-parse: $(STAMP_DIR)/model/parse.stamp

model-build: $(STAMP_DIR)/model/build.stamp

$(addprefix model-parse-,$(MODEL_PARSE_SOURCES)): model-parse-%: $(STAMP_DIR)/model/parse/%.stamp

$(addprefix model-build-,$(MODEL_BUILD_SOURCES)): model-build-%: $(STAMP_DIR)/model/build/%.stamp

package: $(STAMP_DIR)/package/orgdb.stamp

GO.db: $(STAMP_DIR)/package/GO.db.stamp

org.Hs.eg.db: $(STAMP_DIR)/package/org.Hs.eg.db.stamp


$(STAMP_DIR)/download.stamp: $(DOWNLOAD_STAMPS)
	@mkdir -p '$(@D)'
	@echo "==> [download] stage complete"
	@date '+%Y-%m-%dT%H:%M:%S%z' > '$@'

$(STAMP_DIR)/download/%.stamp:
	@mkdir -p '$(@D)'
	@echo "==> [download] starting source: $*"
	BIOCANNOPIPE_ROOT='$(ROOT_DIR)' sh '$(ROOT_DIR)/scripts/make/download-source.sh' '$*' || { echo "!! [download] failed source: $*"; exit 1; }
	@echo "==> [download] finished source: $*"
	@date '+%Y-%m-%dT%H:%M:%S%z' > '$@'

$(STAMP_DIR)/model/parse.stamp: $(MODEL_PARSE_STAMPS)
	@mkdir -p '$(@D)'
	@echo "==> [model] parse stage complete"
	@date '+%Y-%m-%dT%H:%M:%S%z' > '$@'

$(STAMP_DIR)/model/parse/%.stamp: $(STAMP_DIR)/download.stamp
	@mkdir -p '$(@D)'
	@echo "==> [model:parse] starting source: $*"
	BIOCANNOPIPE_ROOT='$(ROOT_DIR)' sh '$(ROOT_DIR)/scripts/make/model-parse-source.sh' '$*' || { echo "!! [model:parse] failed source: $*"; exit 1; }
	@echo "==> [model:parse] finished source: $*"
	@date '+%Y-%m-%dT%H:%M:%S%z' > '$@'

$(STAMP_DIR)/model/build.stamp: $(MODEL_BUILD_STAMPS)
	@mkdir -p '$(@D)'
	@echo "==> [model] build stage complete"
	@date '+%Y-%m-%dT%H:%M:%S%z' > '$@'

$(STAMP_DIR)/model/build/%.stamp: $(STAMP_DIR)/model/parse.stamp
	@mkdir -p '$(@D)'
	@echo "==> [model:build] starting source: $*"
	BIOCANNOPIPE_ROOT='$(ROOT_DIR)' sh '$(ROOT_DIR)/scripts/make/model-build-source.sh' '$*' || { echo "!! [model:build] failed source: $*"; exit 1; }
	@echo "==> [model:build] finished source: $*"
	@date '+%Y-%m-%dT%H:%M:%S%z' > '$@'

$(STAMP_DIR)/model.stamp: $(STAMP_DIR)/model/build.stamp
	@mkdir -p '$(@D)'
	@echo "==> [model] stage complete"
	@date '+%Y-%m-%dT%H:%M:%S%z' > '$@'

$(STAMP_DIR)/package/orgdb.stamp: $(STAMP_DIR)/model.stamp
	@mkdir -p '$(@D)'
	@echo "==> [package] starting OrgDb family build"
	BIOCANNOPIPE_ROOT='$(ROOT_DIR)' \
	SANCTIONED_SQLITE_DIR='$(SANCTIONED_SQLITE_DIR)' \
	ANNOTATIONFORGE_INDEX='$(ANNOTATIONFORGE_INDEX)' \
	PACKAGE_OUTPUT_BASE_DIR='$(ROOT_DIR)/newPkgs' \
	PKG_DATE='$(PKG_DATE)' \
	PKG_VERSION='$(PKG_VERSION)' \
	RSCRIPT_BIN='$(RSCRIPT_BIN)' \
	sh '$(ROOT_DIR)/scripts/make/package-orgdb.sh' || { echo "!! [package] failed OrgDb family build"; exit 1; }
	@echo "==> [package] finished OrgDb family build"
	@date '+%Y-%m-%dT%H:%M:%S%z' > '$@'

$(STAMP_DIR)/package/GO.db.stamp: $(STAMP_DIR)/package/orgdb.stamp
	@mkdir -p '$(@D)'
	@cp '$<' '$@'

$(STAMP_DIR)/package/org.Hs.eg.db.stamp: $(STAMP_DIR)/package/orgdb.stamp
	@mkdir -p '$(@D)'
	@cp '$<' '$@'

clean:
	@echo "==> [clean] removing build stamps and generated package artifacts"
	BIOCANNOPIPE_ROOT='$(ROOT_DIR)' \
	STAMP_DIR='$(STAMP_DIR)' \
	SANCTIONED_SQLITE_DIR='$(SANCTIONED_SQLITE_DIR)' \
	PACKAGE_OUTPUT_DIR='$(PACKAGE_OUTPUT_DIR)' \
	sh '$(ROOT_DIR)/scripts/make/clean.sh'