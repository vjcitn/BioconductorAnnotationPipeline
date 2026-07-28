# Plan: Makefile-Based Simplification of BioconductorAnnotationPipeline

## Current State: What Makes This Complex

The existing system has **five implicit phases** driven by four different scripts spread across eleven provider subdirectories, with no dependency tracking between them:

1. `src_download.sh` — calls `<provider>/script/download.sh` for each provider
2. `src_parse.sh` — calls `<provider>/script/getsrc.sh` to produce `*src.sqlite` per-provider
3. `src_build.sh` — calls `<provider>/script/getdb.sh` to assemble per-organism `chipsrc_<species>.sqlite` and `chipmapsrc_<species>.sqlite`, with **implicit ordering requirements** (gene before organism_annotation, GO before KEGG)
4. `newPkgs/makeDbZeros.R` — calls `AnnotationForge::wrapBaseDBPackages()` to produce `human.db0`, `mouse.db0`, etc., which must then be **manually installed** before the next step
5. `newPkgs/makeTerminalDBPkgs.R OrgDb` — calls `AnnotationForge::populateDB()` (via `EGPkgs.R`) to produce the final `org.Hs.eg.db` packages

### Additional Problems

- The **species list is duplicated** in at least 6 places: `gene/script/getsrc.sh`, `ucsc/script/download.sh`, `ucsc/script/getsrc.sh`, `organism_annotation/script/getdb.sh`, `EGPkgs.R`, and `src_parse.sh`
- **Configuration (URLs, build versions) is scattered** across 10+ `env.sh` files
- **Dead code is pervasive**: UniGene is commented out everywhere, KEGG is flagged as deprecated, inparanoid is kept only for one FlyBase mapping, ChipDb packages are entirely gone
- **Hard-coded server paths** (`/home/ubuntu/...`) appear inside R scripts
- There is no way to run a single species or re-run one failed provider without running everything

---

## Proposed Structure

```
BioconductorAnnotationPipeline/
  config/
    species.tsv         # single source of truth for all species
    providers.mk        # shared provider URLs and global variables
  providers/
    gene/               # NCBI Gene (shared, tax-ID filtered per species)
    go/                 # Gene Ontology (shared)
    ucsc/               # UCSC genome builds (species-specific)
    ensembl/            # Ensembl mappings (species-specific)
    yeast/              # SGD (yeast only)
    tair/               # TAIR (Arabidopsis only)
    plasmoDB/           # PlasmoDB (malaria only)
    pfam/               # PFAM (shared)
    flybase/            # FlyBase only (extracted from inparanoid, fly only)
  db/                   # intermediate SQLite files (gitignored)
  packages/             # output R packages (gitignored)
  Makefile              # top-level with download and package targets
  scripts/
    assemble_species.sh # builds chipsrc_<species>.sqlite from provider SQLites
    make_db0.R          # AnnotationForge::wrapBaseDBPackages wrapper
    make_orgdb.R        # AnnotationForge::populateDB wrapper, reads config
```

---

## Phase 1: Consolidate Species Configuration

Create `config/species.tsv` — a single tab-separated file that is the **one source of truth** for all species metadata, replacing all the scattered `env.sh` files and hard-coded lists:

```
name        taxid   ucsc_build  ensembl_name                pkg_prefix    pkg_template
human       9606    hg38        homo_sapiens                org.Hs.eg     HUMAN_DB
mouse       10090   mm39        mus_musculus                org.Mm.eg     MOUSE_DB
rat         10116   rn7         rattus_norvegicus           org.Rn.eg     RAT_DB
fly         7227    dm6         drosophila_melanogaster     org.Dm.eg     FLY_DB
zebrafish   7955    danRer11    danio_rerio                 org.Dr.eg     ZEBRAFISH_DB
yeast       559292  sacCer3     saccharomyces_cerevisiae    org.Sc.sgd    YEAST_DB
worm        6239    ce11        caenorhabditis_elegans      org.Ce.eg     WORM_DB
arabidopsis 3702    NA          arabidopsis_thaliana        org.At.tair   ARABIDOPSIS_DB
bovine      9913    bosTau9     bos_taurus                  org.Bt.eg     BOVINE_DB
canine      9615    canFam6     canis_lupus_familiaris      org.Cf.eg     CANINE_DB
chicken     9031    galGal6     gallus_gallus               org.Gg.eg     CHICKEN_DB
chimp       9598    panTro6     pan_troglodytes             org.Pt.eg     CHIMP_DB
pig         9823    susScr11    sus_scrofa                  org.Ss.eg     PIG_DB
rhesus      9544    rheMac10    macaca_mulatta              org.Mmu.eg    RHESUS_DB
anopheles   7165    anoGam3     anopheles_gambiae           org.Ag.eg     ANOPHELES_DB
xenopus     8355    NA          xenopus_laevis              org.Xl.eg     XENOPUS_DB
malaria     5833    NA          plasmodium_falciparum       org.Pf.plasmo MALARIA_DB
ecoliK12    511145  NA          NA                          org.EcK12.eg  ECOLI_DB
ecoliSakai  386585  NA          NA                          org.EcSakai.eg ECOLI_DB
```

All Makefiles and R scripts read from this file. Adding a new organism means adding one row — nothing else changes.

---

## Phase 2: Provider Makefiles with Explicit File Targets

Each `providers/<name>/Makefile` expresses its work as **file targets**. Make tracks timestamps and skips work that is already current. This replaces the three-script pattern (`download.sh` / `getsrc.sh` / `getdb.sh`) with a single Makefile whose targets naturally encode the dependency chain.

Example structure for the NCBI Gene provider:

```makefile
# providers/gene/Makefile
include ../../config/providers.mk

RAWDIR := raw/$(EGSOURCEDATE)

# Download
$(RAWDIR)/gene_info.gz:
	mkdir -p $(RAWDIR)
	curl --fail --disable-epsv -O --output-dir $(RAWDIR) $(EGSOURCEURL)/gene_info.gz

# Filter to needed taxa during parse (no separate parse step)
$(RAWDIR)/gene_info: $(RAWDIR)/gene_info.gz
	zcat $< | awk -f script/filter_taxa.awk > $@

# Produce provider SQLite
db/genesrc.sqlite: $(RAWDIR)/gene_info ...
	sqlite3 $@ < script/srcdb.sql
	...

download: $(RAWDIR)/gene_info.gz $(RAWDIR)/gene2go.gz ...
.PHONY: download
```

The intermediate parse step becomes an implicit Make target rather than a named pipeline phase. There is no need for a separate `getsrc.sh`.

---

## Phase 3: Top-Level Makefile with `download` and `package` Targets

The top-level `Makefile` exposes exactly two phases, with optional `SPECIES=` filtering:

```makefile
# Top-level Makefile
include config/providers.mk

SPECIES ?= all

# ── Download ─────────────────────────────────────────────────────────────────
download:
	$(MAKE) -C providers/gene     download SPECIES=$(SPECIES)
	$(MAKE) -C providers/go       download
	$(MAKE) -C providers/ucsc     download SPECIES=$(SPECIES)
	$(MAKE) -C providers/ensembl  download SPECIES=$(SPECIES)
	$(MAKE) -C providers/pfam     download
	# species-specific providers included conditionally based on SPECIES

# ── Intermediate assembly (not user-facing; prerequisite for package) ─────────
db/chipsrc_%.sqlite: db/genesrc.sqlite db/gosrc.sqlite db/gpsrc_%.sqlite
	bash scripts/assemble_species.sh $*

# ── Package ───────────────────────────────────────────────────────────────────
package: db/chipsrc_$(SPECIES).sqlite
	Rscript scripts/make_db0.R  \
	    --species $(SPECIES) \
	    --dbpath  db/ \
	    --config  config/species.tsv \
	    --outdir  packages/db0/
	Rscript scripts/make_orgdb.R \
	    --species $(SPECIES) \
	    --config  config/species.tsv \
	    --db0path packages/db0/ \
	    --outdir  packages/orgdb/

.PHONY: download package
```

Example invocations:

```sh
make download                    # download data for all species
make download SPECIES=human      # download only what human needs
make package  SPECIES=human      # produce org.Hs.eg.db (and human.db0)
make package                     # produce all OrgDb packages
```

---

## Phase 4: Clean Up Dead Code

Before or alongside the above, permanently remove:

| What | Where | Reason |
|---|---|---|
| UniGene code | Commented-out blocks in `src_parse.sh`, `src_download.sh`, and 12+ organism stanzas | Deprecated since Bioc 3.13 |
| KEGG provider directory | `annosrc/kegg/` | No longer shipped in Bioconductor OrgDbs |
| Inparanoid infrastructure | `annosrc/inparanoid/` (all except FlyBase download) | Only the FlyBase mapping survives; rename to `providers/flybase/` |
| `blast2go/` directory | `annosrc/blast2go/` | No living downstream consumer |
| `makeTranscriptPkgs.R` | `newPkgs/makeTranscriptPkgs.R` | Affymetrix ChipDb — not built since Bioc 3.3 |
| `getAnnos.R` | `newPkgs/getAnnos.R` | References `AffyCompatible`/`NetAffxResource`, entirely deprecated |
| Hard-coded `/home/ubuntu/` paths | `makeDbZeros.R`, `makeTerminalDBPkgs.R` | Replace with `DB_PATH` variable from `providers.mk` |
| `goext/` download (commented out) | `src_download.sh` | Commented out since at least 2021 |

---

## Phase 5: R Script Simplification

Replace `EGPkgs.R` (one hard-coded `populateDB()` call per species, 131 lines) and `makeTerminalDBPkgs.R` with two thin scripts that read `config/species.tsv`:

### `scripts/make_db0.R`

Loops over the species in the config (or a specified subset) and calls `AnnotationForge::wrapBaseDBPackages()`. No hard-coded species names.

### `scripts/make_orgdb.R`

Loops over the config, reads `pkg_prefix` and `pkg_template` columns, calls `AnnotationForge::populateDB()` and `AnnotationForge::makeAnnDbPkg()`. No hard-coded species names.

Adding a new organism requires only: (1) one new row in `config/species.tsv`, (2) confirming the taxonomy ID is covered by the NCBI Gene filter in `providers/gene/Makefile`.

---

## Summary of Simplifications

| Current | Proposed |
|---|---|
| 5 implicit ordered phases | 2 explicit user-facing phases: `download`, `package` |
| Species list duplicated in 6+ places | Single `config/species.tsv` |
| `download.sh` + `getsrc.sh` + `getdb.sh` per provider | Single `Makefile` per provider with file targets |
| No re-run safety; must run everything on failure | Make skips up-to-date targets automatically |
| Cannot run a single species | `make package SPECIES=human` |
| Hard-coded server paths in R scripts | `DB_PATH` variable in `providers.mk` |
| Dead code throughout (UniGene, KEGG, inparanoid, ChipDb, goext) | Removed |
| Manual db0 install step between phases | Encoded as a Makefile dependency |
| Ordering requirements implicit in comments | Expressed as explicit Make prerequisites |

---

## Open Questions for Team Discussion

1. **Should db0 packages remain a separate artifact?** `AnnotationForge::wrapBaseDBPackages()` requires them to be installed before `makeAnnDbPkg()` can run. We could encode this as a two-step `package` target (`make db0` then `make orgdb`) or keep them as one `package` target with an intermediate install step.

2. **TxDb packages**: `makeTerminalDBPkgs.R TxDb` currently only builds `hg38` and `mm39`. Should TxDb generation be a third top-level target (`make txdb SPECIES=human`), or is it out of scope for this pipeline?

3. **KEGG**: The KEGG provider directory still exists and `src_build.sh` calls it. Is KEGG truly dead for OrgDbs, or does it feed any current packages? This should be confirmed before deletion.

4. **Parallelism**: Once providers are independent Makefile targets, `make -j` gives free parallelism for the download phase. Is this safe on the build machine (bandwidth and disk I/O)?

5. **`config/species.tsv` ownership**: Who is responsible for updating genome build versions (the `ucsc_build` column) at each Bioconductor release? This was previously done by editing `ucsc/script/env.sh` by hand — the same manual step exists, just in one place now.
