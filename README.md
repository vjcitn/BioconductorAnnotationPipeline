# BioconductorAnnotationPipeline

Generates the Bioconductor annotation packages — `org.Hs.eg.db`, `org.Mm.eg.db`, and analogous OrgDb packages for 19 model organisms — as well as `GO.db`.

## Status

This pipeline is currently being redesigned. See [SIMPLIFY/SIMPLIFICATION_PLAN.md](SIMPLIFY/SIMPLIFICATION_PLAN.md) for the proposed direction:

- Makefile-driven `download` and `package` targets replacing the old `master.sh` / `src_*.sh` system
- A single `config/species.tsv` as the source of truth for all 19 organisms
- Ensembl FTP provider removed (FTP site restructured; Ensembl IDs sourced from NCBI Gene `dbXrefs` for all organisms except yeast — see plan for details)
- Dead code (UniGene, KEGG, inparanoid, ChipDb, goext) removed

The old operational instructions (EC2 instance setup, `malbec1` upload steps, release-to-release artifact carryover) have been retired along with the scripts they described.

### org.Hs.eg.ice

A demonstration package (see `PlanFor3.24.md` Milestone 7) offering thin dplyr/DuckDB
accessors over the public [bioc-on-ice](https://github.com/seandavi/bioc-on-ice) Iceberg
catalog, as a less-interventional alternative to AnnotationDbi's query surface.
Reference/vignette site: https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/

## Data Sources

| Provider | What it supplies |
|---|---|
| NCBI Gene | Core gene mappings, aliases, Ensembl cross-references |
| Gene Ontology | GO annotations |
| UCSC | Chromosome/position mappings |
| SGD | Yeast-specific data |
| TAIR | Arabidopsis-specific data |
| PlasmoDB | Malaria-specific data |
| PFAM | Protein family domains |
| UniProt | UniProt accessions; also enriches ENSEMBLPROT/ENSEMBLTRANS |
| FlyBase | Fly-specific gene data |

## Species

19 organisms: human, mouse, rat, fly, zebrafish, yeast, worm, arabidopsis, bovine, canine, chicken, chimp, pig, rhesus, anopheles, xenopus, malaria, ecoliK12, ecoliSakai.

## Build order / gotchas

- **PFAM and UniProt are optional enrichment sources, not auto-built.**
  `chipsrc_<species>.sqlite`'s Makefile rule only pulls in `db/PFAM.sqlite`
  and `db/uniprot.sqlite` as prerequisites if those files *already exist*
  at the time chipsrc is assembled (`Makefile`'s `UNIPROT_DEP`/`PFAM_DEP`
  are `$(wildcard ...)`, evaluated once at parse time). On a from-scratch
  build, `make package` will succeed without them, silently producing a
  package with no `PFAM`/`ENSEMBLPROT`/`ENSEMBLTRANS` data. Build them
  first if you want that data:
  ```sh
  make -C providers/pfam all
  make -C providers/uniprot all
  make package SPECIES=<species> ...
  ```
- **`GO.db` must be installed (not just built) before building any
  species on the `makeOrgPackage()`/`NOSCHEMA_DB` path** (i.e. any species
  *not* in `make_orgdb.R`'s `DB0_SUPPORTED_SPECIES` — currently `human`,
  `mouse`, `rat`, `zebrafish`, `chimp`, `bovine`). That script's GO/Pfam
  generation runs through `makeOrgPackage()`'s `goTable` argument, which
  needs `GO.db`'s ancestor mappings (`GOBPANCESTOR`/etc.) at build time.
  Run `make godb` and `R CMD INSTALL` the resulting tarball first.
- **UniProt-derived mapping counts (`UNIPROT`/`ENSEMBLPROT`/`ENSEMBLTRANS`
  keys) can shrink substantially between builds through no fault of this
  pipeline.** As of 2026-11-11, a human `idmapping_selected.tab.gz` pull
  yielded only ~39,700 GeneID cross-references, versus ~116,900 seen in an
  earlier (March 2026) build from a different source pipeline. Independent
  re-parsing of the downloaded file confirmed the pipeline faithfully
  reflects what UniProt currently publishes — this isn't a parsing bug.
  UniProt has precedent for periodic mass "redundancy reduction" passes
  over its TrEMBL records (e.g. the 2015_03 release dropped TrEMBL from
  ~92M to ~47M entries); see
  https://ftp.uniprot.org/pub/databases/uniprot/knowledgebase/idmapping/README
  for the current archived-release notes describing this practice. Treat
  large swings in UniProt key counts as expected upstream volatility, not
  a build defect.
