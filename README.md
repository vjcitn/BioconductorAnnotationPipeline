# BioconductorAnnotationPipeline

Generates the Bioconductor annotation packages — `org.Hs.eg.db`, `org.Mm.eg.db`, and analogous OrgDb packages for 19 model organisms — as well as `GO.db`, `PFAM.db`, and selected `TxDb` packages.

## Status

This pipeline is currently being redesigned. See [SIMPLIFY/SIMPLIFICATION_PLAN.md](SIMPLIFY/SIMPLIFICATION_PLAN.md) for the proposed direction:

- Makefile-driven `download` and `package` targets replacing the old `master.sh` / `src_*.sh` system
- A single `config/species.tsv` as the source of truth for all 19 organisms
- Ensembl FTP provider removed (FTP site restructured; Ensembl IDs sourced from NCBI Gene `dbXrefs` for all organisms except yeast — see plan for details)
- Dead code (UniGene, KEGG, inparanoid, ChipDb, goext) removed

The old operational instructions (EC2 instance setup, `malbec1` upload steps, release-to-release artifact carryover) have been retired along with the scripts they described.

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
| FlyBase | Fly-specific gene data |

## Species

19 organisms: human, mouse, rat, fly, zebrafish, yeast, worm, arabidopsis, bovine, canine, chicken, chimp, pig, rhesus, anopheles, xenopus, malaria, ecoliK12, ecoliSakai.
