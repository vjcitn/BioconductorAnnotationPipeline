.PHONY: help download model package clean go.db org.Hs.eg.db

help:
	@echo "Targets:"
	@echo "  download   Fetch raw sources"
	@echo "  model      Build reusable intermediates"
	@echo "  package    Build package outputs"
	@echo "  go.db      Build GO.db"
	@echo "  org.Hs.eg.db Build org.Hs.eg.db"
	@echo "  clean      Remove generated artifacts"
	@echo ""
	@echo "See docs/adr/ for the architectural decisions behind this layout."

download:
	@echo "Download stage not yet wired; see docs/adr/0001-build-boundaries.md"

model:
	@echo "Model stage not yet wired; see docs/adr/0001-build-boundaries.md"

package:
	@echo "Package stage not yet wired; see docs/adr/0001-build-boundaries.md"

go.db:
	@echo "GO.db target not yet wired; see docs/adr/0002-annotationdbi-interface.md"

org.Hs.eg.db:
	@echo "org.Hs.eg.db target not yet wired; see docs/adr/0002-annotationdbi-interface.md"

clean:
	@echo "Clean stage not yet wired"
