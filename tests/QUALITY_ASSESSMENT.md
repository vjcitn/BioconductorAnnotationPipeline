# Quality Assessment

## How to run

```sh
make check SPECIES=human          # validate one species
make check SPECIES="human mouse"  # validate several
make check                        # validate all built species
```

The check target finds the most recent tarball in `packages/orgdb/` for each
species, installs it to a temporary library, and runs `tests/check_orgdb.R`
against it.

---

## What is tested

### Layer 1 — Structural

Verify the package loads and exposes the expected schema.

| Check | What it catches |
|---|---|
| All required columns present in `columns()` | makeOrgPackage API change dropping a table; GO tables not injected |
| `DBSCHEMA` is not `NOSCHEMA_DB` | metadata post-processing regression |
| `CENTRALID` is `EG` (not `GID`) | metadata post-processing regression |
| `EGSOURCEDATE` present | source provenance not copied from chipsrc |

### Layer 2 — Count consistency (package vs chipsrc)

The chipsrc SQLite is the ground truth — the package should faithfully represent
it. These checks compare counts directly.

| Check | Tolerance | What it catches |
|---|---|---|
| Gene count matches chipsrc exactly | 0 | Taxon filter failure; makeOrgPackage silently dropping genes |
| GO direct annotation rows match chipsrc | 0 | GO injection failure; wrong chipsrc attached |
| GOALL > GO row count | — | Ancestor propagation not run; go_bp_all tables empty |
| ≥20% of genes have at least one GO annotation | — | GO provider failure; wrong taxid in assembly |

### Layer 3 — Referential integrity

Verify internal consistency of the chipsrc itself.

| Check | What it catches |
|---|---|
| `go_bp`, `go_mf`, `go_cc`: no orphan `_id` values | Assembly SQL join failure introducing spurious gene IDs |
| `chromosome_locations`: no orphan `_id` values | UCSC provider mismatch; wrong species data |
| `uniprot`: no orphan `_id` values | UniProt enrichment step using wrong taxid |
| `uniprot`: ≥30% of genes mapped (if non-empty) | Partial UniProt provider run; idmapping file truncated |
| `TAXID` present in metadata | Assembly SQL misconfiguration |

### Layer 4 — Spot checks (known landmark genes)

A small set of well-characterised genes with known properties.
Defined in `tests/known_genes.tsv`.

| Check | What it catches |
|---|---|
| Symbol matches expected | Wrong organism data; gene ID mapping failure |
| GENENAME contains expected substring | Gene info table corruption |
| Expected UniProt accession present | UniProt provider producing wrong mappings |
| Expected GO term present | GO annotation failure for specific gene |

---

## Lessons learned during development

| Issue | Root cause | Fix applied |
|---|---|---|
| `select()`/`keys()` failed with "no such column: gene_id" | makeOrgPackage stores the frame first column name (`GID`) literally in the genes table; AnnotationDbi HUMAN_DB schema expects `gene_id` | `make_orgdb.R` now renames `genes.GID → genes.gene_id` via `ALTER TABLE` immediately after opening the sqlite |
| `columns()` shows `MAP` for human but not mouse | `cytogenetic_locations` table only populated for species that have cytogenetic band data (human yes, mouse no) | MAP check made conditional on `cytogenetic_locations` being non-empty in chipsrc |
| UNIPROT spot check queried wrong column name (`uniprot_id`) | makeOrgPackage stores column names from frames as-is; frame column was `UNIPROT` not `uniprot_id` | Query updated to use `u.UNIPROT` |
| GO coverage showed 1953100% | `keys()` was returning -1 (failure) so denominator became 1; fixed by querying package sqlite directly | Use `dbGetQuery(org_conn, "SELECT count(*) FROM genes")` instead of `keys()` |
| TP53 GENENAME expected 'tumor suppressor' | Actual NCBI gene name is "tumor protein p53" | `known_genes.tsv` corrected to `tumor protein` |
| `DBSCHEMA: NOSCHEMA_DB`, `CENTRALID: GID` in built packages | `goTable=NA` causes makeOrgPackage to write these defaults; abbreviated genus/species codes corrupt ORGANISM/SPECIES | `make_orgdb.R` post-processing corrects all four metadata entries |
| UniProt coverage ~10% for human (not 30%) | Human NCBI gene set includes ~193k IDs (ncRNA, pseudogenes, etc.); only ~20k protein-coding genes have UniProt entries | Threshold lowered to 5%; 10% is correct and expected |
| GO coverage threshold 20% too high | Same reason — many gene IDs are non-coding and have no GO annotations | Threshold lowered to 5% |

---

## What is NOT tested

| Gap | Reason | Possible future addition |
|---|---|---|
| **Currency of source data** | A 2-year-old cached download passes all tests | Compare EGSOURCEDATE in metadata to current NCBI date |
| **Correctness of upstream data** | We trust NCBI, GO, UniProt | N/A — not our responsibility |
| **Coverage gaps outside spot-checked genes** | We only verify ~3 genes per species | Random sample of 100 genes; compare symbol to genesrc |
| **All 19 species** | Tests written for 9 species in known_genes.tsv | Add rows to known_genes.tsv as species are validated |
| **Pfam/PROSITE columns** | Not yet populated; will test once assembly SQL is updated | Add spot checks for known domain-containing proteins |
| **Chromosome-level correctness** | CHRLOC values not spot-checked | Verify TP53 location is on chromosome 17 |
| **ENSEMBLPROT/ENSEMBLTRANS** | Depend on UniProt provider; not yet in known_genes.tsv | Add ENSP*/ENST* expected values for landmark genes |

---

## Results log

Update this table after each build cycle.

| Date | Species | BIOC_PKG_VERSION | Pass | Fail | Notes |
|---|---|---|---|---|---|
| 2026-Aug-09 | human | 3.24.0 | 42 | 0 | clean |
| 2026-Aug-09 | mouse | 3.24.0 | 37 | 0 | NOTE:MAP(schema) |
| 2026-Aug-09 | rat | 3.24.0 | 33 | 0 | NOTE:MAP(no data) |
| 2026-Aug-09 | fly | 3.24.0 | 34 | 0 | clean |
| 2026-Aug-09 | zebrafish | 3.24.0 | 32 | 0 | NOTE:GENETYPE(no data); NOTE:MAP(no data) |
| 2026-Aug-09 | worm | 3.24.0 | 32 | 0 | NOTE:GENETYPE(schema); NOTE:MAP(no data) |
| 2026-Aug-09 | bovine | 3.24.0 | 29 | 0 | NOTE:MAP(schema); NOTE:spot-checks(none defined) |
| 2026-Aug-09 | canine | 3.24.0 | 29 | 0 | NOTE:MAP(no data); NOTE:spot-checks(none defined) |
| 2026-Aug-09 | chicken | 3.24.0 | 29 | 0 | NOTE:MAP(no data); NOTE:spot-checks(none defined) |
| 2026-Aug-09 | chimp | 3.24.0 | 27 | 0 | NOTE:ALIAS(schema); NOTE:GENETYPE(no data); NOTE:MAP(no data); NOTE:spot-checks(none defined) |
| 2026-Aug-09 | pig | 3.24.0 | 29 | 0 | NOTE:MAP(schema); NOTE:spot-checks(none defined) |
| 2026-Aug-09 | rhesus | 3.24.0 | 28 | 0 | NOTE:ALIAS(schema); NOTE:MAP(no data); NOTE:spot-checks(none defined) |
| 2026-Aug-09 | anopheles | 3.24.0 | 27 | 0 | NOTE:ALIAS(schema); NOTE:GENETYPE(schema); NOTE:MAP(no data); NOTE:spot-checks(none defined) |
| 2026-Aug-09 | xenopus | 3.24.0 | 28 | 0 | NOTE:ALIAS(schema); NOTE:MAP(no data); NOTE:spot-checks(none defined) |

---

## Adding new spot checks

Edit `tests/known_genes.tsv`. Columns:

| Column | Description |
|---|---|
| `species` | Must match `name` column in `config/species.tsv` |
| `gene_id` | Entrez Gene ID |
| `symbol` | Expected SYMBOL (exact match) |
| `genename_contains` | Substring expected in GENENAME (case-insensitive) |
| `uniprot` | Expected UniProt accession (checked if UNIPROT column present) |
| `go_id` | GO term expected in GO column (e.g. `GO:0006915`) |

Leave a field empty to skip that check for a gene.

---

## Known limitations and trade-offs

**Count consistency at tolerance 0**: gene and GO row counts are checked for
exact equality between the package and chipsrc. This is strict by design —
any discrepancy indicates a real problem. If a future makeOrgPackage version
deduplicates differently, this check will catch it and the tolerance may need
adjustment with a documented reason.

**20% GO coverage threshold**: chosen conservatively. Human is ~80%, even
poorly-annotated organisms exceed 20%. If a species legitimately has low GO
coverage (e.g. a novel organism), document the exception here.

**30% UniProt coverage threshold**: human is ~90%, most model organisms >50%.
Prokaryotes may fall below 30% — add species-specific overrides if needed.

**GENETYPE column**: the `genetype` table is absent from some species chipsrc assemblies (e.g. zebrafish). Check is conditional on the table existing in chipsrc.

**Schema-level column gaps (ALIAS, MAP, GENETYPE)**: Several AnnotationDbi
schemas omit table definitions that are present in the data, causing those
columns to be absent from `columns()` even when the underlying chipsrc table
is populated. The check emits a NOTE rather than failing in these cases.
Known instances as of Bioc 3.24:

| Column | Species with schema gap |
|---|---|
| MAP | mouse, bovine, pig (schema gap); rat, canine, chicken, zebrafish, worm, chimp, rhesus, anopheles, xenopus (no cytogenetic data) |
| ALIAS | chimp, rhesus, anopheles, xenopus (schema gap) |
| GENETYPE | worm, anopheles (schema gap); zebrafish, chimp (no genetype data) |

Mouse cytogenetic notation (`6 F3`, `11 81.43 cM`) also differs from human
(`19q13.43`) and would need normalisation to be useful to end users.
