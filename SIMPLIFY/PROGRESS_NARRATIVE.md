# Pipeline Rebuild: Progress Narrative

## Where We Started

The original `BioconductorAnnotationPipeline` was a collection of shell scripts
and R files that had accumulated over fifteen years. It had five implicit ordered
phases, species lists duplicated in six or more places, hard-coded server paths,
and providers (UniGene, KEGG, IPI, Ensembl FTP) that were partially or entirely
broken. There was no way to re-run a single failed step, no dependency tracking,
and no test that a produced package actually installed.

The goal: rebuild it as a clean, Make-driven pipeline that produces installable
Bioconductor OrgDb packages and can be maintained going forward.

---

## Phase 1 — Foundation: Make, Config, Core Providers

The first structural decision was **GNU Make as the dependency engine**. Each
provider got its own `Makefile` with explicit file targets, `.DELETE_ON_ERROR`,
and the `.tmp` → `mv` atomic-write pattern so partial outputs never masquerade
as complete ones. A single `config/species.tsv` replaced the six scattered
species lists.

Three providers were built and verified:

| Provider | Output | Size | Notes |
|---|---|---|---|
| `providers/gene` | `db/genesrc.sqlite` | ~8 GB | All NCBI taxa; filtered per species at assembly |
| `providers/go` | `db/gosrc.sqlite` | ~1.1 GB | GO term hierarchy + gene2go for all taxa |
| `providers/ucsc` | `db/gpsrc.sqlite` | varies | Chromosome lengths, gene locations, UCSC IDs |

Key fixes along the way:
- **PHONY targets as prerequisites** caused every stamp file to rebuild unconditionally. Fixed by moving dependency checks into recipe bodies.
- **Zebrafish UCSC**: the internal UCSC name is `fish`, but our pipeline uses `zebrafish`. Required careful path management and explicit symlink handling in the Makefile.
- **`.tmp` → `mv` pattern** added to all SQLite outputs after a 0-byte `gpsrc.sqlite` silently broke a downstream join.

---

## Phase 2 — Assembly: chipsrc and the OrgDb API

The `scripts/assemble_species.sh` script runs the per-species SQL
(`bindb_human.sql` etc.) to produce `db/chipsrc_<species>.sqlite` — a
self-contained SQLite database with the full annotation schema for one organism.

Getting from `chipsrc` to an installable R package exposed a series of
`AnnotationForge::makeOrgPackage()` surprises:

1. **`dbname` is not a parameter** of the current `makeOrgPackage`. Passing it
   put a character string into `...`, causing the "1st column must always be GID"
   error on every run.

2. **Package naming**: the current `makeOrgPackage` constructs the package name
   as `org.{genus_initial}{full_species}.eg.db` (e.g. `org.Hsapiens.eg.db`).
   The traditional Bioconductor name is `org.Hs.eg.db`. Fixed by passing
   abbreviated codes derived from `pkg_prefix` (`H`, `s`) rather than the full
   scientific name. The full name is written back into DESCRIPTION and the SQLite
   metadata afterward.

3. **SQLite is created read-only** (`0444`). A `Sys.chmod` before the metadata
   UPDATE is required.

4. **GO tables**: `goTable=NA` is mandatory because `GO.db` is itself a product
   of this pipeline — using it as a build dependency would be circular. With
   `goTable=NA`, `makeOrgPackage` stores no GO data. The six GO tables
   (`go_bp`, `go_mf`, `go_cc`, `go_bp_all`, `go_mf_all`, `go_cc_all`) are
   instead written directly into the OrgDb SQLite via SQL `ATTACH` after
   `makeOrgPackage` returns.

5. **Metadata corruption**: the abbreviated genus/species codes and `goTable=NA`
   cause `makeOrgPackage` to set `DBSCHEMA=NOSCHEMA_DB`, `CENTRALID=GID`, and
   `SPECIES=H s`. All four standard entries are corrected post-hoc, and source
   provenance metadata (EGSOURCEDATE, GOSOURCENAME, etc.) is copied from
   `chipsrc` via ATTACH.

---

## What We Can Now Produce

```
make package SPECIES=human    # produces packages/orgdb/org.Hs.eg.db_3.23.tar.gz
make package SPECIES=mouse    # produces packages/orgdb/org.Mm.eg.db_3.23.tar.gz
make package SPECIES="human mouse rat fly zebrafish worm"   # batch
```

Verified `columns(org.Hs.eg.db)` matches the previous Bioconductor release:

```
ACCNUM  ALIAS  CHRLOC  CHRLOCEND  CHROMOSOME  ENSEMBL  ENTREZID
ENZYME  EVIDENCE  EVIDENCEALL  GENENAME  GENETYPE  GO  GOALL
IPI  MAP  OMIM  ONTOLOGY  ONTOLOGYALL  PATH  PFAM  PMID
PROSITE  REFSEQ  SYMBOL  UCSCKG  UNIPROT
```

Columns that advertise but are currently empty: `ENZYME`, `PATH` (KEGG stub),
`PFAM`, `PROSITE`, `IPI` (see below), `UNIPROT`, `ENSEMBLPROT`, `ENSEMBLTRANS`.

---

## Phase 3 — Pfam: A Lesson in Source Selection

The Pfam provider exposed an important lesson about **choosing the right source
file**.

### What we tried first

`Pfam-A.full.gz` — the complete Stockholm multiple-sequence alignment file.

- **Size**: 23.9 GB compressed, ~200 GB uncompressed
- **Processing**: `zcat | awk` streaming pass over 274M lines (~2 hours)
- **Problem**: the `#=GS` (sequence→family) records lose their family context
  when extracted to a flat file. The GS parsing code in the original pipeline
  was entirely commented out. The resulting `PFAM.sqlite` has family metadata
  (descriptions, cross-references) but **no gene→Pfam mapping**.

### What we should use instead

`Pfam-A.regions.tsv.gz` — a pre-joined TSV already available at EBI.

- **Size**: 4.8 GB compressed (5× smaller; future UniProt-only variant ~400 MB)
- **Processing**: `zcat | awk` column extraction → SQLite `.import` (~30 min)
- **Content**: 129M rows of `uniprot_id → pfam_family_accession` directly

This is now in `PFAM.sqlite` as the `uniprot2pfam` table. The full pipeline
diagram is:

```
gene_id ──→ UniProt accession ──→ Pfam family accession
           (UniProt provider)     (uniprot2pfam table)
```

The remaining gap is the UniProt provider (gene ID → UniProt bridge).

---

## Current Pipeline Map

```
NCBI FTP                     Gene Ontology FTP           UCSC FTP
    │                              │                          │
    ▼                              ▼                          ▼
providers/gene              providers/go              providers/ucsc
    │                              │                          │
    ▼                              ▼                          ▼
db/genesrc.sqlite           db/gosrc.sqlite           db/gpsrc.sqlite
         │                        │                        │
         └────────────────────────┴────────────────────────┘
                                  │
                       assemble_species.sh
                    (runs bindb_<species>.sql)
                                  │
                                  ▼
                     db/chipsrc_<species>.sqlite
                                  │
                       scripts/make_orgdb.R
                   (makeOrgPackage + post-processing)
                                  │
                                  ▼
              packages/orgdb/org.Hs.eg.db_3.23.tar.gz  ✓


EBI Pfam FTP
    │
    ├──→ Pfam-A.full.gz (23.9 GB) ──→ PFAM.sqlite (family metadata)
    │
    └──→ Pfam-A.regions.tsv.gz (4.8 GB) ──→ PFAM.sqlite (uniprot2pfam, 129M rows)
                                                    │
                                           [waiting for UniProt provider]
                                                    │
                                                    ▼
                                          PFAM/PROSITE columns populated
```

---

## What We Learned

| Lesson | Impact |
|---|---|
| `makeOrgPackage` API has changed significantly; `dbname` is gone, naming uses full species | Required post-hoc renaming and metadata correction |
| `goTable=NA` is mandatory when GO.db is itself a pipeline product | Avoided circular dependency; GO tables written directly via SQL |
| PHONY targets as Makefile prerequisites cause unconditional rebuilds | Moved all checks into recipe bodies |
| `cd` into a symlinked directory resolves `..` via the physical path on Linux | All script paths switched to absolute `$(SCRIPTDIR)` |
| `Pfam-A.full.gz` does not provide the gene→Pfam mapping we need | Switched to `Pfam-A.regions.tsv.gz` for the actual sequence mapping |
| Source metadata (EGSOURCEDATE, GOSOURCENAME, etc.) lives in chipsrc | Copied via ATTACH rather than hard-coded |

---

## UCSC Provider Gap Discovery (2026-Aug)

While building packages for pig, anopheles, and xenopus, `makeOrgPackage` failed with "missing value where TRUE/FALSE needed". Root cause: the `chromosome_locations` table (CHRLOC/CHRLOCEND genomic coordinates) is absent from those species' chipsrc databases, even though the `chromosomes` table (chromosome names) is present.

Investigation of the UCSC provider revealed:

- The `srcdb_*.sql` files that parse UCSC flat files into per-species `gpsrc.sqlite` are absent from the repository entirely — they existed on the original build machine but were never committed. Without them, no UCSC provider rebuild is possible for any species.
- Pig: `env.sh` and `download.sh` already have the necessary entries (`susScr11`, refGene + chromInfo), but the `bindb.sql` pig block is fully commented out.
- Anopheles: `download.sh` only fetches `chromInfo.txt.gz` (no refGene track in anoGam3), so even with `srcdb_anopheles.sql` the Entrez coordinate bridge would require a non-standard join strategy.
- Xenopus: not present in `download.sh` or `bindb.sql` at all.

**Decision**: switch to NCBI Gene as the coordinate source for these species. NCBI `gene_info` already carries chromosome and map_location; a companion NCBI file provides strand-aware coordinates via RefSeq alignments. This is consistent across all organisms regardless of UCSC coverage. The `chrloc` frame was moved from core to optional in `make_orgdb.R` as an interim fix so packages build while the NCBI coordinate assembly SQL is being added.

See `SIMPLIFICATION_PLAN.md` for the full per-species status table.

---

## What Remains

1. **UniProt provider** — downloads `idmapping_selected.tab.gz`; produces
   `refseq_uniprot` table mapping RefSeq accessions to UniProt IDs; enables
   UNIPROT column and completes the gene→UniProt→Pfam chain
2. **Assembly SQL update** — add Pfam JOIN to `bindb_*.sql` scripts once
   UniProt bridge is available
3. **Ensembl provider** — ENSEMBLPROT, ENSEMBLTRANS (Ensembl FTP restructured;
   need new approach)
4. **Organism-specific providers** — yeast (SGD), arabidopsis (TAIR), fly
   (FlyBase supplemental), malaria (PlasmoDB)
5. **Species validation** — rat, fly, zebrafish, worm, bovine, canine, chicken,
   chimp, pig, rhesus, anopheles, xenopus, ecoliK12, ecoliSakai
