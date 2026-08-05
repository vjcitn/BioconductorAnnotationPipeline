.PHONY: help print-config download model package clean GO.db org.Hs.eg.db

STAMP_DIR ?= $(ROOT_DIR)/.build/stamps
PKG_DATE ?= $(shell date +%Y%m%d)
PKG_VERSION ?= 3.23.0
R_BIN ?= R
RSCRIPT_BIN ?= Rscript
ANNOTATIONFORGE_INDEX ?= $(HOME)/R-libraries/AnnotationForge/extdata/GentlemanLab/ANNDBPKG-INDEX.TXT
SANCTIONED_SQLITE_DIR ?= $(ROOT_DIR)/newPkgs/sanctionedSqlite
PACKAGE_OUTPUT_DIR := $(ROOT_DIR)/newPkgs/$(PKG_DATE)_OrgDbs

help:
	@echo "Targets:"
	@echo "  download      Fetch raw sources into annosrc/"
	@echo "  model         Parse and build canonical sqlite intermediates"
	@echo "  package       Build the OrgDb family described in ADR 0001"
	@echo "  GO.db         Alias for the OrgDb family build that includes GO.db"
	@echo "  org.Hs.eg.db  Alias for the OrgDb family build that includes org.Hs.eg.db"
	@echo "  clean         Remove Make stamps and package outputs for PKG_DATE"
	@echo "  print-config  Show the current Make configuration"
	@echo ""
	@echo "Configurable variables: PKG_DATE=$(PKG_DATE) PKG_VERSION=$(PKG_VERSION)"
	@echo "See docs/adr/ for the architectural decisions behind this layout."

print-config:
	@printf 'ROOT_DIR=%s\n' '$(ROOT_DIR)'
	@printf 'STAMP_DIR=%s\n' '$(STAMP_DIR)'
	@printf 'PKG_DATE=%s\n' '$(PKG_DATE)'
	@printf 'PKG_VERSION=%s\n' '$(PKG_VERSION)'
	@printf 'RSCRIPT_BIN=%s\n' '$(RSCRIPT_BIN)'
	@printf 'ANNOTATIONFORGE_INDEX=%s\n' '$(ANNOTATIONFORGE_INDEX)'

download: $(STAMP_DIR)/download.stamp

model: $(STAMP_DIR)/model.stamp

package: $(STAMP_DIR)/package/orgdb.stamp

GO.db: $(STAMP_DIR)/package/GO.db.stamp

org.Hs.eg.db: $(STAMP_DIR)/package/org.Hs.eg.db.stamp

$(STAMP_DIR)/download.stamp:
	@mkdir -p '$(@D)'
	BIOCANNOPIPE_ROOT='$(ROOT_DIR)' sh '$(ROOT_DIR)/scripts/make/download.sh'
	@date '+%Y-%m-%dT%H:%M:%S%z' > '$@'

$(STAMP_DIR)/model.stamp: $(STAMP_DIR)/download.stamp
	@mkdir -p '$(@D)'
	BIOCANNOPIPE_ROOT='$(ROOT_DIR)' sh '$(ROOT_DIR)/scripts/make/model.sh'
	@date '+%Y-%m-%dT%H:%M:%S%z' > '$@'

$(STAMP_DIR)/package/orgdb.stamp: $(STAMP_DIR)/model.stamp
	@mkdir -p '$(@D)'
	BIOCANNOPIPE_ROOT='$(ROOT_DIR)' \
	SANCTIONED_SQLITE_DIR='$(SANCTIONED_SQLITE_DIR)' \
	ANNOTATIONFORGE_INDEX='$(ANNOTATIONFORGE_INDEX)' \
	PACKAGE_OUTPUT_BASE_DIR='$(ROOT_DIR)/newPkgs' \
	PKG_DATE='$(PKG_DATE)' \
	PKG_VERSION='$(PKG_VERSION)' \
	RSCRIPT_BIN='$(RSCRIPT_BIN)' \
	sh '$(ROOT_DIR)/scripts/make/package-orgdb.sh'
	@date '+%Y-%m-%dT%H:%M:%S%z' > '$@'

$(STAMP_DIR)/package/GO.db.stamp: $(STAMP_DIR)/package/orgdb.stamp
	@mkdir -p '$(@D)'
	@cp '$<' '$@'

$(STAMP_DIR)/package/org.Hs.eg.db.stamp: $(STAMP_DIR)/package/orgdb.stamp
	@mkdir -p '$(@D)'
	@cp '$<' '$@'

clean:
	BIOCANNOPIPE_ROOT='$(ROOT_DIR)' \
	STAMP_DIR='$(STAMP_DIR)' \
	SANCTIONED_SQLITE_DIR='$(SANCTIONED_SQLITE_DIR)' \
	PACKAGE_OUTPUT_DIR='$(PACKAGE_OUTPUT_DIR)' \
	sh '$(ROOT_DIR)/scripts/make/clean.sh'