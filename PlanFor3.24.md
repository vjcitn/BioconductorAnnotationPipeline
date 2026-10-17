# Plan: Restore `db0` + `makeAnnDbPkg()` for the 3.24 OrgDb Build

## Why

Two bugs that looked separate turn out to share one root cause:

1. The legacy per-table Bimap objects (`org.Hs.egSYMBOL`, `org.Hs.egCHRLOC`, ...)
   are missing from freshly-built packages. `AnnotationForge::makeOrgPackage()`
   (used today by `scripts/make_orgdb.R`) only produces the modern single
   `OrgDb` S4 object; it never generates the legacy Bimap suite.
2. Even the *modern* API is broken for most keytypes. `keys(org.Hs.eg.db,
   keytype="GOALL")`, `"PFAM"`, `"IPI"`, `"ENSEMBL"`, etc. fail with raw SQL
   errors (`no such table: go_all`, `no such table: pfam`, `no such column:
   ensembl_id`).

Investigation traced (2) to an internal, **unexported** function,
`AnnotationDbi:::.definePossibleTables(class, species)`. It is a hardcoded
table/column map keyed only by `class` ("OrgDb") and the literal `ORGANISM`
string ("Homo sapiens", with per-organism exception blocks baked into the
function body — e.g. Human gets `OMIM`/`UCSCKG` added). It is **not** driven
by the `DBSCHEMA` metadata field at all — setting `DBSCHEMA="HUMAN_DB"` (as
`make_orgdb.R` does today) has no effect on which tables `keys()`/`select()`
actually query. Confirmed: `AnnotationForge:::filterSeeds()`, which decides
which legacy Bimap objects `makeAnnDbPkg()` generates, calls this exact same
`.definePossibleTables()` — so the legacy-object gap and the modern-API gap
are the same contract, checked in two places.

Comparing `.definePossibleTables("OrgDb", "Homo sapiens")` against the
actual tables in a freshly built package
(`accnum, genes, go_cc_all, map_metadata, synonym, chrloc, genetype,
metadata, ucsckg, ensembl, go_bp_all, map, pubmed, gene_info, go_bp,
map_counts, refseq, chromosome, go_cc, go_mf, omim`):

| Keytype | Expected table.column | Actual | Status |
|---|---|---|---|
| ENTREZID | `genes.gene_id` | `genes.gene_id` (renamed from `GID` by `make_orgdb.R`) | OK |
| SYMBOL / GENENAME | `gene_info.symbol` / `.gene_name` | matches | OK |
| PMID | `pubmed.pubmed_id` | matches | OK |
| REFSEQ | `refseq.accession` | matches | OK |
| GENETYPE | `genetype.gene_type` | table matches; column name TBD | OK (verify column) |
| OMIM | `omim.omim_id` | matches | OK |
| ACCNUM | `accessions.accession` | table is `accnum` | BROKEN (table renamed) |
| ALIAS2EG | `alias.alias_symbol` | table is `synonym` | BROKEN (table renamed) |
| CHR | `chromosomes.chromosome` | table is `chromosome` (singular vs plural) | BROKEN |
| MAP | `cytogenetic_locations.cytogenetic_location` | table is `map` | BROKEN |
| CHRLOC / CHRLOCEND | `chromosome_locations.{start,end}_location` | table is `chrloc`, column names unverified | BROKEN |
| ENZYME | `ec.ec_number` | no `ec` table present | BROKEN (table missing) |
| PATH | `kegg.path_id` | no `kegg` table present | BROKEN (table missing) |
| ENSEMBL | `ensembl.ensembl_id` | table matches; column is not literally `ensembl_id` (built via `e.ensid AS ENSEMBL`) | BROKEN (column name) |
| ENSEMBLPROT / ENSEMBLTRANS | `ensembl_prot.prot_id` / `ensembl_trans.trans_id` | tables absent | BROKEN (missing) |
| UNIPROT | `uniprot.uniprot_id` | table absent | BROKEN (missing) |
| UCSCKG | `ucsc.ucsc_id` | table is `ucsckg` | BROKEN (table renamed) |
| PFAM / IPI | `pfam.{pfam_id,ipi_id}` | table absent entirely (confirmed absent even from `chipsrc_human.sqlite` upstream — Pfam data never made it into assembly) | BROKEN (missing, upstream gap) |
| PROSITE | `prosite.{ipi_id,prosite_id}` | table absent | BROKEN (missing) |
| GO / GOALL / EVIDENCE* / ONTOLOGY* | `.definePossibleTables()` says literal tables `go` / `go_all` | we have the ontology-split `go_bp`/`go_cc`/`go_mf` (+ `_all`) tables, no unified `go`/`go_all`, no `ontology` column anywhere | **Partially a false alarm** — see "GO is special" below |

### GO is special — legacy Bimaps already handle the split tables correctly

`filterSeeds()` only uses `.definePossibleTables()` to decide *which* object
names to generate, not how to query them. The actual `GO` seed is a
`Go3AnnDbBimap`, and its real table list comes from a separate function,
`AnnotationDbi:::Go3tablenames()`, which returns exactly `go_bp`/`go_cc`/
`go_mf` (and `_all` variants) — i.e. the split-by-ontology layout we already
produce. So **the legacy `org.Hs.egGO`/`org.Hs.egGOALL` Bimap objects, once
restored via `makeAnnDbPkg()`, will work against our existing tables with no
schema change.** It is only the *modern*, Bimap-free `select()`/`keys()`
dispatch on the bare `OrgDb` object that falls through to the generic
`.definePossibleTables()` literal-table lookup and breaks on `GOALL`. This
needs to be confirmed empirically once the db0 package is built (see
Milestone 4) — if the `OrgDb` wrapper produced by `makeAnnDbPkg()` also
degrades to the generic path for `GOALL`, we likely need to also create a
literal `go`/`go_all` view (`CREATE VIEW go AS SELECT _id, go_id, evidence,
NULL AS ontology FROM go_bp UNION ALL SELECT ... go_cc ... UNION ALL SELECT
... go_mf ...`) purely to satisfy that fallback path.

## Decision

Restore the `db0` → `AnnotationForge::makeAnnDbPkg()` pipeline, but
streamlined: skip the historical heavy Perl/`makeDBPackage()` scaffolding.
Concretely, "db0" becomes nothing more than:

1. A `chipsrc_<species>.sqlite`-shaped SQLite file whose table/column names
   are rewritten to literally match what `.definePossibleTables("OrgDb",
   <organism>)` expects (same renaming work needed either way — this isn't
   extra cost over patching `make_orgdb.R`'s `makeOrgPackage()` output).
2. A `metadata` table with exactly the columns `(name, value)` and a
   `DBSCHEMA` row (required by `AnnotationForge:::initWithDbMetada`, which
   hard-stops if `DBSCHEMA` is absent — but see note below, the value itself
   is largely cosmetic for query purposes).
3. One call to `AnnotationForge::makeAnnDbPkg()` with an `AnnDbPkgSeed`
   pointing at the `NCBIORG.DB` template (the Entrez-Gene-centric OrgDb
   template shipped inside `AnnotationForge`, confirmed present locally at
   `.../AnnotationForge/AnnDbPkg-templates/NCBIORG.DB/`), which:
   - Auto-generates all legacy Bimap objects whose `.definePossibleTables()`
     entry resolves to a table that exists in the sqlite (so partial
     conformance degrades gracefully, same as now, but for *more* keytypes
     as each table gets renamed/added).
   - Writes the package skeleton, `NAMESPACE`, man pages, and `zzz.R` for us
     — no hand-rolled `zzz.R` shim needed.

This fixes both bugs in one pass instead of (a) writing a `zzz.R` shim to
paper over the legacy-object gap and (b) separately patching
`make_orgdb.R`'s raw SQL to satisfy the modern dispatch table names — those
would have been two fixes converging on the same underlying table-naming
work anyway.

## Scope note: per-species, not just human

`config/species.tsv` has 18 rows, each with a `pkg_template` column
(`HUMAN_DB`, `MOUSE_DB`, `RAT_DB`, `FLY_DB`, `ZEBRAFISH_DB`, `YEAST_DB`,
`WORM_DB`, `ARABIDOPSIS_DB`, `BOVINE_DB`, `CANINE_DB`, `CHICKEN_DB`,
`CHIMP_DB`, `PIG_DB`, `RHESUS_DB`, `ANOPHELES_DB`, `XENOPUS_DB`,
`ECOLI_DB` ×2). `.definePossibleTables()` has a per-organism exception
block for each of these (e.g. yeast gets a completely different table set:
`gene2systematic`, `chromosome_features`, `sgd`, `interpro`, `smart`; fly
gets `FLYBASE`/`FLYBASECG`/`FLYBASEPROT`; worm gets `WORMBASE`; etc.) — this
is a real per-organism cost, not a one-time human-only fix. **Recommend
scoping the first implementation pass to `human` only** (prove the pipeline
end-to-end, validate against `AnnotationDbi::checkMappedkeys`/manual spot
checks), then generalize table-renaming logic per organism using the same
`.definePossibleTables()` introspection used to build this plan, rather than
hand-writing 18 separate cases.

## Milestones

### 1. Add a schema-conformance layer — DONE (`scripts/make_db0.sh`)
Re-reading `annosrc/organism_annotation/script/bindb_human.sql` (the actual
SQL that builds `chipsrc_human.sqlite`, as opposed to re-deriving names from
`make_orgdb.R`'s re-extraction) showed the mismatch list was much shorter
than the table in this doc's "Why" section implied — `chipsrc_human.sqlite`
itself already uses most of the official names (`accessions`, `chromosomes`,
`cytogenetic_locations`, `omim`, `refseq`, `pubmed`, `genetype`, `ec`,
`kegg`, `ucsc`, `uniprot` all already match `.definePossibleTables()`
exactly). The mismatches `make_orgdb.R` was papering over with ad hoc
aliases (`accnum`, `synonym`, `chromosome`, `map`, `ucsckg`, `chrloc`) don't
actually originate in `chipsrc`; they were introduced by `make_orgdb.R`'s
own re-extraction SQL. Building `db0` from `chipsrc` directly, rather than
through that re-extraction, sidesteps most of the renaming work entirely.

New script `scripts/make_db0.sh <species>` copies
`db/chipsrc_<species>.sqlite` to `db/db0_<species>.sqlite` and applies only
the renames `chipsrc_human.sqlite` actually needs:
- `gene_synonyms` → `alias`, column `symbol` → `alias_symbol` (backs `ALIAS2EG`/`ALIAS2PROBE`)
- `chromosome_locations` column `chromosome` → `seqname` (backs `CHRLOCCHR`; `start_location`/`end_location` already matched)
- `ensembl` column `ensid` → `ensembl_id`
- `ensembl_pro`/`pro_id` → `ensembl_prot`/`prot_id`, `ensembl_trs`/`trs_id` → `ensembl_trans`/`trans_id` **if present** (only exist when `assemble_species.sh`'s optional UniProt enrichment ran); otherwise stub empty tables with the right column names so the keytype returns `character(0)` instead of erroring
- `pfam` gets an added `ipi_id` column (NULL — no IPI data source exists yet) if present, else stubbed empty
- `prosite`/`unigene` stubbed empty (no data source in this pipeline)
- `go_bp`/`go_cc`/`go_mf`(`_all`) left untouched — legacy `GO`/`GOALL` Bimaps use these directly per the "GO is special" note; no literal `go`/`go_all` table created yet (deferred to Milestone 4's empirical check of the modern dispatch path)
- Sets the `DBSCHEMA` metadata row (`HUMAN_DB`), required by `makeAnnDbPkg()`'s `initWithDbMetada()` in Milestone 2/3

Wired into the top-level `Makefile` as `$(DATA_ROOT)/db/db0_%.sqlite:
$(DATA_ROOT)/db/chipsrc_%.sqlite`. Only `human` has rename rules; other
species `exit 1` with a pointer to this doc's Milestone 5. Verified against
a synthetic `chipsrc_human.sqlite` (both the "enrichment ran" and
"enrichment didn't run" branches) — correct output schema confirmed; not
yet run against a real build (no local `DATA_ROOT` data; needs validation
on the build server next).

### 2. Build a minimal "db0" wrapper — DONE (`scripts/make_db0_pkg.R`)
New standalone script `scripts/make_db0_pkg.R --species human --config
config/species.tsv --dbpath db/ --outdir packages/orgdb/ --version 3.24.0`
stages a renamed copy of `db0_<species>.sqlite` (basename must equal
`<AnnObjPrefix>.sqlite` exactly — `makeAnnDbPkg()` hard-stops otherwise)
and calls `makeAnnDbPkg()` with an `AnnDbPkgSeed` pointed at the
`NCBIORG.DB` template. Not yet wired into the Makefile's `package` target
or `make_orgdb.R` (Milestone 3).

Getting an actual package to build and load correctly surfaced several
more undocumented requirements beyond what Milestone 1 anticipated — all
now handled by `make_db0.sh`, since they're schema-level facts about the
sqlite, not packaging-script details:
- A `metadata` row `'Db type'` = `'OrgDb'` — `.makeAnnDbPkg()` reads this
  directly (not via `initWithDbMetada()`) to decide whether to resolve a
  ChipDb's org-package dependency; missing/empty crashes with "argument is
  of length zero" before any other error reporting.
- `map_metadata` rows for `ALIAS2EG`, `ENSEMBLPROT`, `ENSEMBLTRANS` — **a
  real gap in `bindb_meta.sql`**, not a synthetic-test artifact: it
  populates `ALIAS2GENE` (not `ALIAS2EG`) and never touches
  `ENSEMBLPROT`/`ENSEMBLTRANS` at all, so man-page generation for the real
  `chipsrc_human.sqlite` would hit the same `cpSubsCon` "UNRESOLVED
  SYMBOLS: @ALIAS2EGSOURCE@" crash this plan's testing hit. Backfilled by
  copying source provenance from `ACCNUM`/`ENSEMBL` respectively, the same
  pattern `bindb_meta.sql` already uses for `OMIM`/`UCSCKG`.
- `metadata` rows `DBSCHEMAVERSION` (`'2.1'`), `'Supporting package'`
  (`'AnnotationDbi'`), and `TAXID` (from `config/species.tsv`) — not
  checked by `makeAnnDbPkg()` itself but required by the *built package's*
  `.onLoad()` (`dbmeta(dbconn, "DBSCHEMAVERSION")`), so their absence only
  surfaces when `R CMD INSTALL`ing and loading the result, not at build
  time.
- `metadata` rows `ORGANISM`/`SPECIES`/`CENTRALID` — the single biggest
  find. `AnnotationDbi::species()` reads `ORGANISM` straight from the
  sqlite's `metadata` table at *query* time; `makeAnnDbPkg()` never writes
  it there itself (the `AnnDbPkgSeed`'s `organism`/`species` slots only
  drive man-page text). Without it, `species(x)` silently returns
  `character(0)`, which starves `.definePossibleTables()`'s per-organism
  exception block — every organism-specific keytype (`ENSEMBL`, `PFAM`,
  `OMIM`, `UCSCKG`, ...) vanishes from `keytypes()`/`columns()` even though
  the corresponding legacy Bimap objects exist and work fine. This is why
  the "Why" table's per-keytype comparison must be re-validated against a
  *loaded* package, not just a built one — the build step and the load
  step check different, non-overlapping subsets of the metadata contract.
  `AnnDbPkgSeed@species` must also match the sqlite's `SPECIES` value
  exactly (`initWithDbMetada()` hard-stops on mismatch) — it wants the
  capitalized common name (`"Human"`), not the binomial.
- `go`/`go_all` views — resolves the "GO is special" open question
  empirically (see below).

End-to-end validated: built the synthetic `db0_human.sqlite` → package →
`R CMD INSTALL` → `library(org.Hs.eg.db)` → confirmed both the legacy
Bimap suite (`org.Hs.egSYMBOL`, `org.Hs.egALIAS2EG`, `org.Hs.egENSEMBL`,
`org.Hs.egGO`, `org.Hs.egPFAM`, `org.Hs.egUCSCKG`, `org.Hs.egOMIM` all
exist and query correctly) and the modern API
(`keys(org.Hs.eg.db, keytype="ENSEMBL"/"PFAM"/"IPI"/"GOALL")` and
`select(..., columns="ENSEMBL")` all succeed) — i.e. **both of the
originally-diagnosed bugs are fixed**, against synthetic data. Real-data
validation on the build server is the next step before calling Milestones
1–2 fully proven.

### GO is special — resolved empirically
The modern bare-`OrgDb` dispatch for `GOALL` does fall through to the
generic `.definePossibleTables()` literal-table lookup exactly as
predicted: `keys(x, keytype="GOALL")` failed with `"no such table:
go_all"` until `make_db0.sh` added `go`/`go_all` views (`UNION ALL` across
the ontology-split tables, with a literal `ontology` column). Also
confirmed: legacy `org.Hs.egGOALL` does **not** exist as a Bimap even
after `makeAnnDbPkg()` runs — `NCBIORG.DB`'s template has no `GOALL.Rd`,
matching production `org.*.eg.db` packages, where `GOALL` has always been
select()-only. `GO` itself works via both paths without the view (Bimap
first), but the view is harmless and was added for both names for
consistency/future-proofing.

### 3. Rewrite `scripts/make_orgdb.R`'s packaging step — DONE
Split the per-species body into two functions, dispatched by a
`DB0_SUPPORTED_SPECIES` vector (currently just `"human"`, extended as
Milestone 5 generalizes `make_db0.sh`):
- `build_via_db0()`: invokes `scripts/make_db0.sh <sp>` itself (so `make
  package` has no separate `db0_%.sqlite` prerequisite — it's called
  internally, only for supported species), then runs the `AnnDbPkgSeed` +
  `makeAnnDbPkg()` call from Milestone 2. No post-build directory/metadata
  patching needed at all (unlike the legacy path) — the canonical package
  name and all metadata come from the conformant db0 sqlite and the seed
  directly.
- `build_via_make_org_package()`: the original `makeOrgPackage()` logic,
  verbatim, for every other species — unchanged until each one migrates.
Both return a package source directory path; the `R CMD build` tarball
step is now shared, run once after the dispatch regardless of which path
built the source tree.

### 4. Validate against both APIs — DONE for human, against real data; harness extended
Ran the full Milestone 1+2 pipeline end to end on the build server against
the real `chipsrc_human.sqlite` (not just the synthetic fixture used to
develop Milestones 1-2): `make db0_human.sqlite` → `make_db0_pkg.R` →
`R CMD INSTALL` → `library(org.Hs.eg.db)`.

Both APIs confirmed working with real, non-trivial data:
- Legacy: `org.Hs.egSYMBOL`, `org.Hs.egALIAS2EG`, `org.Hs.egENSEMBL`,
  `org.Hs.egENSEMBLPROT`, `org.Hs.egENSEMBLTRANS`, `org.Hs.egGO`,
  `org.Hs.egPFAM`, `org.Hs.egUCSCKG`, `org.Hs.egOMIM` all exist.
- Modern: `keys()` counts — `ENSEMBL` 38267, `ENSEMBLPROT` 116363,
  `ENSEMBLTRANS` 116359, `PFAM` 8868, `GOALL` 21341 — and
  `select(org.Hs.eg.db, columns=c("SYMBOL","PFAM","ENSEMBL"))` returns
  correct joined rows (e.g. A2M → 7 Pfam domains). `IPI` returns 0, which
  is correct, not a bug: the International Protein Index was discontinued
  years ago, so modern UniProt-sourced Pfam data has no `ipi_id` to
  populate.
- `PFAM`/`ENSEMBLPROT`/`ENSEMBLTRANS` only got real (non-stub) data after
  also building `providers/pfam` and `providers/uniprot` — these are
  optional enrichment sources (`make`'s `UNIPROT_DEP`/`PFAM_DEP` wildcards
  only pull them into `chipsrc`'s prerequisite list if
  `db/uniprot.sqlite`/`db/PFAM.sqlite` already exist when `chipsrc` is
  assembled). On a from-scratch build, run
  `make -C providers/pfam all && make -C providers/uniprot all` *before*
  `make chipsrc_human.sqlite`, or the stub tables Milestone 1 creates as a
  fallback will stay empty.

`tests/check_orgdb.R` now has a 5th section ("Modern API coverage") that
walks every `keytypes(x)` entry and asserts both `keys(x, keytype=kt)` and
a small `select(x, keys=..., keytype=kt, columns="SYMBOL")` round-trip
succeed without error — this is exactly the bug class Milestones 1-2 fixed
(a keytype listed by `keytypes()`/`columns()` but erroring with a raw SQL
error when actually queried). A keytype returning 0 keys is not treated as
a failure (e.g. `IPI` — discontinued identifier system, correctly empty);
only `keys()`/`select()` throwing an error fails the check. Verified
against the Milestone 1-3 synthetic `chipsrc_human.sqlite` fixture: all 24
keytypes pass both checks (44 new PASS results). The harness's pre-existing
spot-check failures against that fixture (missing `TAXID` metadata row,
synthetic data lacking the real TP53/BRCA1/EGFR landmark genes) are
unrelated fixture limitations, confirmed unchanged by running the harness
before and after this edit.

### 5. Generalize to remaining species
Once human is proven, build the same renaming map for each
`pkg_template` value by diffing `.definePossibleTables("OrgDb", <organism>)`
against each organism's current `chipsrc_<species>.sqlite` tables (the same
process used in this document), prioritizing species with existing
production consumers.

## Open questions carried forward
- ~~Does `makeAnnDbPkg()`'s generated `OrgDb` object route `GOALL` through
  the Bimap-aware path or the generic `.definePossibleTables()` fallback?~~
  Resolved: generic fallback only, no legacy `GOALL` Bimap exists even in
  production packages; needs the `go`/`go_all` views (see "GO is special"
  under Milestone 2). Confirmed on real data in Milestone 4.
- ~~Where should Pfam/Prosite/Ensembl-protein/Ensembl-transcript/UniProt
  data come from for `chipsrc_human.sqlite`?~~ Resolved: `providers/pfam`
  and `providers/uniprot` already produce this data, but are optional
  enrichment sources that must be built *before* `chipsrc_human.sqlite` is
  assembled (see Milestone 4) — not a missing-provider gap, just a build
  ordering one. `Prosite` is still unaddressed (no provider currently
  populates it; `make_db0.sh` only creates an empty stub).
- `GENETYPE`'s expected column name (`gene_type` vs. our actual column name)
  was not explicitly re-verified in this pass — confirm before relying on it
  staying "OK".
