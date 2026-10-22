# Plan: Restore `db0` + `makeAnnDbPkg()` for the 3.24 OrgDb Build

## TODO (prominent, still open on the new instance): build `GO.db_3.24.0.tar.gz`

The build/check logic is done (see Milestone 4.6 below) — this is just the
"run it on the fresh 400GB instance" step, not yet done there as of
2026-10-19.

```sh
cd ~/BioconductorAnnotationPipeline      # or wherever the clone lives
which sqlite3 || sudo apt-get update && sudo apt-get install -y sqlite3
make check-r-deps
make godb
```

`make godb` (top-level `Makefile`) does, in order:
1. `make -C providers/go go-sqlite` — downloads `go-basic.obo`, parses it,
   builds `data/db/GO.sqlite` (needs `data/db/genesrc.sqlite`, so it will
   also trigger `providers/gene`'s download/build chain if that hasn't run
   yet).
2. `Rscript scripts/make_godb.R --input data/db/GO.sqlite --outdir
   data/packages/godb/ --version 3.24.0` — hand-assembles the `GO.db`
   package and runs `R CMD build --no-build-vignettes GO.db`.

Result: `data/packages/godb/GO.db_3.24.0.tar.gz` (override the location with
`DATA_ROOT=...` if building outside the repo tree, same as `make package`).

If it already partially ran and `data/packages/godb/GO.db/` or the tarball
exists from a prior attempt, `make_godb.R` refuses to overwrite — `rm -rf
data/packages/godb/GO.db data/packages/godb/GO.db_3.24.0.tar.gz` first.

To verify: `R CMD check --no-manual data/packages/godb/GO.db_3.24.0.tar.gz`
should come back clean except for the one accepted `.onLoad`/
`packageStartupMessage` NOTE (see Milestone 4.6).

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

Then run against the **real** build-server `chipsrc_human.sqlite`/package
(`make check SPECIES=human`): 85 passed, 6 failed — every modern-API
keytype check passed against real data, confirming Milestone 4's intent
end to end. The 6 failures were all in the pre-existing spot-check
section: `gene_info`/`uniprot` column-name lookups were hardcoded to the
legacy `makeOrgPackage()` path's uppercase aliases (`GENENAME`,
`UNIPROT`), but `db0`-built packages (human) use the lowercase
schema-conformant names `.definePossibleTables()` expects (`gene_name`,
`uniprot_id`) — confirmed directly via `.schema gene_info`/`.schema
uniprot` on the server. `SYMBOL`/`symbol` happened to still match
(SQLite column lookups are case-insensitive), masking the bug for that
one column. Fixed by discovering the real column name via `PRAGMA
table_info()` against a candidate list covering both naming
conventions, instead of hardcoding either.

### 4.5 Make `R CMD check` pass clean — DONE for human
`make check`/`check_orgdb.R` validate data correctness but don't run
`R CMD check`, which exercises a different path: every `.Rd` example,
including `AnnotationDbi::checkMAPCOUNTS()` (from the auto-generated
`MAPCOUNTS.Rd`), which `get()`s every name listed in the package's
exported `MAPCOUNTS` vector and compares it against the live Bimap's
mapped-key count. Running it on the real server-built
`org.Hs.eg.db_3.24.0.tar.gz` surfaced three real, fixable bugs, all
inherited from the legacy `bindb_meta.sql`/`assemble_species.sh`
pipeline rather than introduced by Milestones 1-3, discovered one at a
time as each fix unmasked the next `checkMAPCOUNTS()` failure:

1. **Phantom `ENTREZID` entry.** `bindb_meta.sql` inserts a
   `map_counts` row `'ENTREZID' = count(*) FROM genes`, and
   `AnnotationDbi:::createMAPCOUNTS()` builds `MAPCOUNTS` straight from
   that table — but ENTREZID is the central gene ID, not a separate
   map, so no Bimap object by that name is ever created.
   `checkMAPCOUNTS()` special-cases `PFAM`/`PROSITE` this way but not
   `ENTREZID`, so it `get()`s a nonexistent object and aborts.
2. **Six more phantom entries, same root cause.** `bindb_meta.sql`
   also records several reverse-map rows under the old,
   pre-AnnotationDbi env-package naming convention (`ENZYME2GENE`,
   `GO2GENE`, `GO2ALLGENES`, `PATH2GENE`, `PMID2GENE`,
   `SYNONYM2GENE`) instead of the modern Bimap names AnnotationDbi
   actually creates (`ENZYME2EG`, `GO2EG`, `GO2ALLEGS`, `PATH2EG`,
   `PMID2EG`, `ALIAS2EG`). Found the complete set in one shot via
   `setdiff(names(org.Hs.egMAPCOUNTS), ls(getNamespace("org.Hs.eg.db")))`
   against a built package, rather than discovering them one slow
   `R CMD check` run at a time.
3. **Stale `UNIPROT` count.** `bindb_meta.sql` computes
   `map_counts('UNIPROT')` early, against the empty stub `uniprot`
   table that exists at that point. `assemble_species.sh`'s UniProt
   enrichment step later `DELETE`s and repopulates `uniprot` with real
   gene→UniProt mappings (19457 genes, for human) but never refreshed
   `map_counts` to match, so `checkMAPCOUNTS()` hard-stopped
   ("count1 and count0 differ").

All three fixed by deleting/refreshing the relevant `map_counts` rows
in `scripts/make_db0.sh` (phantoms 1-2) and `scripts/assemble_species.sh`
(stale UNIPROT count, 3), right at the point each is produced.

Separately, `R CMD check` also flagged a Rd NOTE (`checkRd: Escaped
LaTeX specials: \_`) and a PDF-manual `ERROR`/`WARNING`, both traced to
literal `"\_"` text baked into AnnotationForge's own shipped
`NCBIORG.DB` Rd template (`man/REFSEQ.Rd`) — not something generated
from our data, and not fixable by editing our sqlite. Fixed by
post-processing every generated `.Rd` file in `make_orgdb.R` right
after `makeAnnDbPkg()` writes them, stripping the unnecessary escape.

Left alone: the `.onLoad calls: packageStartupMessage(...)` NOTE. This
comes from `AnnotationDbi:::annoStartupMessages()`, called from the
package's own auto-generated `zzz.R` — a style NOTE present on
essentially every Bioconductor annotation package, not an `ERROR`, and
not something this pipeline controls or should suppress (the message
may be wanted later).

Verified on the server: `R CMD check` on the rebuilt
`org.Hs.eg.db_3.24.0.tar.gz` runs clean except for that one accepted
NOTE.

### 4.6 `GO.db` — `R CMD check` pass clean — DONE
`GO.db` is built by a separate script, `scripts/make_godb.R`, which
hand-assembles the package skeleton (DESCRIPTION, NAMESPACE, `R/zzz.R`)
rather than going through `AnnotationForge::makeAnnDbPkg()`'s seed-driven
template substitution the way `make_orgdb.R` does. Its `man/` pages were
copied verbatim from AnnotationForge's `GO.DB` Rd templates
(`AnnDbPkg-templates/GO.DB/man/`) — which ship with literal, unsubstituted
`@TOKEN@` placeholders (`@ANNOBJPREFIX@`, `@PKGNAME@`, and several
`@*SOURCE@` provenance tokens), e.g. `\name{@ANNOBJPREFIX@TERM}` and
`columns(@ANNOBJPREFIX@.db)`. A real `R CMD check` run on
`GO.db_3.24.0.tar.gz` surfaced two bugs, both in `make_godb.R` itself
(not inherited from upstream data, unlike the org.Hs.eg.db fixes above):

1. **Unsubstituted template placeholders.** Explained all three
   remaining findings at once: the `\name should not contain !, | or @`
   warning (17 files), the undocumented-code-objects warning (Rd
   `\name` no longer matched the real object names like `GOTERM`/
   `GOBPANCESTOR`), and a hard parse `ERROR` in the auto-generated
   `GO.db-Ex.R` (`unexpected '@'` at `columns(@` — a literal `@` is not
   valid R). Fixed by adding a `placeholder_map` covering all 16 tokens
   present in the real installed template and substituting them via
   `gsub()` on every copied file, with a warning if any `@WORD@`-shaped
   token survives (none do, verified against the real AnnotationForge
   templates). The PDF-manual `ERROR`/`WARNING` cleared up as a
   byproduct, same as the REFSEQ.Rd fix did for org.Hs.eg.db — both were
   downstream of malformed Rd, not a separate bug.
2. **Invalid man-page filename.** Even after (1), `GO_dbconn`/
   `_dbfile`/`_dbInfo`/`_dbschema` stayed undocumented: the template file
   is named `_dbconn.Rd`, and `R CMD build` silently excludes any
   `man/` file starting with `_` ("Subdirectory 'man' contains invalid
   file names"), dropping it from the built tarball entirely even
   though its content was otherwise fine. Fixed by renaming it to
   `<annobj>_dbconn.Rd` (`GO_dbconn.Rd`) on copy.

Left alone, same reasoning as org.Hs.eg.db: the `.onLoad calls:
packageStartupMessage(...)` NOTE.

Verified on the server: `R CMD check` on the rebuilt
`GO.db_3.24.0.tar.gz` runs clean except for that one accepted NOTE.

### 5. Generalize to remaining species — `mouse`, `rat`, `zebrafish`, `chimp`, `bovine` DONE
Once human is proven, build the same renaming map for each
`pkg_template` value by diffing `.definePossibleTables("OrgDb", <organism>)`
against each organism's current `chipsrc_<species>.sqlite` tables (the same
process used in this document), prioritizing species with existing
production consumers.

**`mouse` added.** `AnnotationDbi:::.definePossibleTables("OrgDb", "Mus
musculus")` differs from the human entry by exactly two things: it adds
`MGI = c("mgi", "mgi_id")` and drops `MAP` (no `MAP`/`UCSCKG` for mouse;
no `OMIM` either — human's exception block is the only one that adds
those two). Diffing `annosrc/organism_annotation/script/bindb_mouse.sql`
against `bindb_human.sql` showed every table/column this pipeline
renames (`gene_synonyms.symbol`, `ensembl.ensid`,
`chromosome_locations.chromosome`, `ensembl_pro`/`ensembl_trs`, `pfam`,
`kegg`, `ec`, ...) is named identically in both — mouse only *adds*
`mgi`/`mgi_id` (already conformant as-is, confirmed against
`.definePossibleTables()`'s expected name — no rename needed) and omits
`omim`/`ucsc` (never referenced by `make_db0.sh` anyway, since neither is
a mouse keytype). `bindb_extra_meta_mouse.sql` (already run by
`assemble_species.sh` for mouse) backfills the `map_metadata` rows for
`MGI`/`MGI2GENE` the same way `bindb_OMIM.sql`/`bindb_meta_ucsc.sql` do
for human's `OMIM`/`UCSCKG` — so Milestone 2's man-page-generation gap
doesn't recur for mouse. `AnnotationForge`'s `NCBIORG.DB` template (the
one `PkgTemplate` value used by `build_via_db0()` for every species) has
an `MGI.Rd`, so no template work was needed either — this template is
not species-specific; `.definePossibleTables()`/`filterSeeds()` alone
decide which of its Rd pages apply to a given species' seed.

Net result: the per-species renaming SQL in `make_db0.sh` needed **no
changes at all** for mouse — it was already written against table/column
names `bindb_mouse.sql` happens to share with `bindb_human.sql`. Only
two things were added: a `mouse) DBSCHEMA="MOUSE_DB" ;;` case arm in
`make_db0.sh`, and `"mouse"` in `make_orgdb.R`'s `DB0_SUPPORTED_SPECIES`.
`build_via_db0()` itself required no change — it already reads
`pkg_prefix`/`pkg_template`/`genus`/`species` generically from
`config/species.tsv` per row. Not yet run against real server data —
next step is `make db0_mouse.sqlite` (needs `chipsrc_mouse.sqlite` built
first) → `make package SPECIES=mouse` → `make check SPECIES=mouse` →
`R CMD check` on the resulting `org.Mm.eg.db` tarball, the same
validation sequence Milestones 4/4.5 ran for human.

**`rat` added.** Smaller delta than mouse, as predicted:
`AnnotationDbi:::.definePossibleTables("OrgDb", "Rattus norvegicus")`
only drops `MAP` — no additions at all (no `MGI`-equivalent). Diffing
`bindb_rat.sql` against `bindb_human.sql` confirmed every renamed
table/column (`gene_synonyms.symbol`, `ensembl.ensid`,
`chromosome_locations.chromosome`) is identical, and `rat` has no
`mgi`/`omim`/`ucsc` tables at all (expected — none are rat keytypes).
`assemble_species.sh`'s meta dispatch for rat runs only `bindb_meta.sql`
(no extra per-species meta script, unlike mouse's
`bindb_extra_meta_mouse.sql`), so no new `map_metadata` backfill gap
exists either. Added `rat) DBSCHEMA="RAT_DB"; HAS_MAP=0` to
`make_db0.sh` and `"rat"` to `DB0_SUPPORTED_SPECIES` — no other code
changes needed. Not yet run against real server data.

**`zebrafish` added.** First species in this milestone that needed an
actual new rename rule, not just a case-arm/flag addition.
`AnnotationDbi:::.definePossibleTables("OrgDb", "Danio rerio")` adds
`ZFIN = c("zfin", "zfin_id")` and drops `MAP` and `GENETYPE` (confirmed
`bindb_zebrafish.sql` has no `genetype` table at all, consistent with the
drop). Diffing `bindb_zebrafish.sql` against `bindb_human.sql` showed the
usual renamed tables/columns (`gene_synonyms.symbol`, `ensembl.ensid`,
`chromosome_locations.chromosome`, ...) are identical, but the new `zfin`
table itself is defined as `zfin(_id, ZFid)` — unlike mouse's `mgi`/
`mgi_id` (already conformant), zebrafish's ID column is named `ZFid`, not
the `zfin_id` `.definePossibleTables()` expects. Added
`ALTER TABLE zfin RENAME COLUMN ZFid TO zfin_id;` to `make_db0.sh`, gated
on `has_table zfin` (not `$SPECIES`) since no other currently-supported
species has this table — same pattern as the existing
`ensembl_pro`/`ensembl_trs` stubs.

Also found that zebrafish's `assemble_species.sh` meta dispatch runs
`bindb_meta.sql` *and* a species-specific `bindb_meta_fish.sql` (unlike
rat, which only runs `bindb_meta.sql`). `bindb_meta_fish.sql` already (a)
`DROP TABLE cytogenetic_locations` outright — confirmed `make_db0.sh`'s
existing unconditional SQL never references that table, so this is safe
— (b) deletes the phantom `MAP` `map_counts`/`map_metadata` rows itself,
and (c) backfills a correct `ZFIN` `map_counts` row and a `map_metadata`
row (copying `ACCNUM`'s provenance, same pattern `bindb_meta.sql` uses
for `OMIM`/`UCSCKG`). So unlike mouse/rat, zebrafish's `MAP`-phantom
problem is already solved upstream of `make_db0.sh` — the `HAS_MAP=0`
case-arm setting added for consistency is a harmless no-op here (the
`DELETE ... WHERE map_name = 'MAP'` matches zero rows). Added
`zebrafish) DBSCHEMA="ZEBRAFISH_DB"; HAS_MAP=0` to `make_db0.sh` and
`"zebrafish"` to `DB0_SUPPORTED_SPECIES`. Not yet run against real server
data.

**`chimp` added.** Even simpler than rat — no new rename rules, and its
meta script was already favorable like zebrafish's.
`AnnotationDbi:::.definePossibleTables("OrgDb", "Pan troglodytes")` drops
`ALIAS`, `ALIAS2PROBE`, `MAP`, `GENETYPE`, `PFAM`, `IPI`, `PROSITE` and
adds nothing. `bindb_chimp.sql` has no `cytogenetic_locations`, `omim`,
`genetype`, `ucsc`, or (uncommented) `pfam` table at all — consistent
with the drops — and its `gene_synonyms`/`ensembl`/`chromosome_locations`
tables use the exact same names as human's, so the existing unconditional
rename rules apply cleanly with no changes. Unlike `bindb_human.sql`/
`bindb_mouse.sql`/`bindb_rat.sql`, chimp's meta script
(`bindb_meta_chimp.sql`, run standalone — chimp does *not* also run the
shared `bindb_meta.sql`) is a wholesale self-contained replacement that
simply never inserts a `MAP` `map_counts`/`map_metadata` row to begin
with, so — like zebrafish — the `HAS_MAP=0` case-arm setting is a
harmless no-op here rather than a fix for an actual phantom entry. It
does already create `map_counts`/`map_metadata` with the same
legacy-name entries (`ENZYME2GENE`, `GO2GENE`, etc.) the universal
phantom-entry cleanup already handles, so no new backfill logic was
needed either. Added `chimp) DBSCHEMA="CHIMP_DB"; HAS_MAP=0` to
`make_db0.sh` and `"chimp"` to `DB0_SUPPORTED_SPECIES` — no other code
changes. Not yet run against real server data.

**`bovine` added.** Like chimp, no new rename rules needed — but unlike
chimp (and like mouse/rat), the `HAS_MAP=0` setting is a real fix here,
not a no-op. `AnnotationDbi:::.definePossibleTables("OrgDb", "Bos
taurus")` drops only `MAP` (keeps `GENETYPE`, unlike chimp). Diffing
`bindb_bovine.sql` against `bindb_human.sql` confirmed identical naming
for `gene_synonyms`/`ensembl`/`chromosome_locations`, and bovine *does*
have a `cytogenetic_locations` table and a `genetype` table (consistent
with `GENETYPE` staying a keytype). Its standalone meta script
(`bindb_meta_bovine.sql`, run instead of the shared `bindb_meta.sql`,
same pattern as chimp's) *does* insert a real `MAP` `map_counts`/
`map_metadata` row from `cytogenetic_locations` — a genuine phantom
entry for bovine since `.definePossibleTables()` drops `MAP`, so
`HAS_MAP=0`'s conditional `DELETE` actually does something here (same
failure class as mouse/rat, not zebrafish/chimp's already-solved-upstream
case). The legacy map_counts names (`ENZYME2GENE`, `GO2GENE`, etc.) bovine's
meta script inserts are already covered by the existing universal cleanup.
Added `bovine) DBSCHEMA="BOVINE_DB"; HAS_MAP=0` to `make_db0.sh` and
`"bovine"` to `DB0_SUPPORTED_SPECIES` — no other code changes. Not yet
run against real server data.

The next easiest species to generalize, by the same diff-against-
`.definePossibleTables()` method: `chicken`/`canine`/`rhesus` (each drops
a handful of keytypes but adds none, so no new table names to reconcile,
just confirming `bindb_<species>.sql` already uses the retained ones'
expected names). Species that *add* genuinely new tables not covered by
`NCBIORG.DB`'s template — `fly` (FLYBASE/FLYBASECG/FLYBASEPROT), `worm`
(WORMBASE), `yeast` (ORF/DESCRIPTION/COMMON/INTERPRO/SMART/SGD — also a
wholesale table-set replacement, not an addition), `arabidopsis`
(TAIR/ARACYC/ARACYCENZYME, also wholesale replacement) — should wait
until `NCBIORG.DB`'s Rd templates are confirmed to actually carry those
object names (not yet checked); if they don't, `AnnotationForge` likely
expects a different `PkgTemplate` for those organisms, which would be
new work rather than a `make_db0.sh` rename-rule addition.

### 6. Source gene/GO/GO.db data from `bioc-on-ice` instead of direct downloads — PROPOSED, not started

`bioc-on-ice/` (a separate git repo, vendored as a sibling directory in this
checkout — see its own `README.md`/`SPEC.md`/`AGENTS.md`) publishes NCBI
Gene, GO, and related annotation as public Apache Iceberg tables, queryable
anonymously via DuckDB (`INSTALL iceberg; LOAD iceberg; ATTACH ... TYPE
ICEBERG, AUTHORIZATION_TYPE 'none'`) against
`https://icegate-bioconice.seandavi.workers.dev`. This milestone explores
replacing the NCBI-gene and GO portions of this pipeline's download/parse
chain with queries against that catalog.

**Why this is attractive, specifically for this repo:** biocOnIce's
NCBI-derived tables (`annotation.ncbi__gene`, `annotation.identifier_mapping`,
`annotation.ncbi__gene_go`, `annotation.ncbi__gene_pubmed`) are already
uniform across all 51,796 NCBI taxa — one schema, keyed by `taxon_id`, with
no per-species table-naming differences. That is exactly the problem
Milestone 5 exists to paper over (`make_db0.sh`'s growing per-species
`case` block of rename rules, diffed by hand against
`.definePossibleTables()` for each new organism). A biocOnIce-backed source
for the gene/GO tables would make the *rest* of Milestone 5 (`chicken`,
`canine`, `rhesus`, `fly`, `worm`, `yeast`, `arabidopsis`) unnecessary: one
query parameterized by `taxon_id` instead of N more rename-rule diffs.
`config/species.tsv`'s existing `taxid` column is already the exact join
key needed — no new config.

**Keytype mapping** (traced against `bioc-on-ice/src/bioconice/schemas.py`):

| `db0`/OrgDb keytype | biocOnIce source |
| --- | --- |
| `ENTREZID` | `annotation.ncbi__gene.gene_id` |
| `SYMBOL` | `annotation.ncbi__gene.symbol` |
| `GENENAME` | `annotation.ncbi__gene.description` |
| `GENETYPE` | `annotation.ncbi__gene.gene_type` |
| `CHR` | `annotation.ncbi__gene.chromosome` |
| `MAP` | `annotation.ncbi__gene.map_location` |
| `ALIAS` | `annotation.identifier_mapping` WHERE `source_namespace='ENTREZ' AND target_namespace='ALIAS'` |
| `ENSEMBL` | `annotation.identifier_mapping`, ENSEMBL↔ENTREZ rows |
| `GO` / `EVIDENCE` / `ONTOLOGY` | `annotation.ncbi__gene_go` (`go_id`, `evidence`, `category`) |
| `PMID` | `annotation.ncbi__gene_pubmed` |
| `GO.db` itself | `ontology.term` / `ontology.relationship` (filtered to `ontology='go'`), replacing `providers/go`'s OBO download+parse chain |

**Hard gaps — not optional, must stay on the current path:**

1. **PFAM/UniProt/IPI/PROSITE domain columns are explicitly out of scope
   for biocOnIce.** Its own `README.md` states: "Knowingly not served: ...
   the legacy protein-domain columns of OrgDb." `providers/pfam` and
   `providers/uniprot` would have to keep running exactly as today, feeding
   those columns into whatever a biocOnIce-sourced build produces. This is
   a hybrid architecture, not a full replacement — biocOnIce covers the
   gene/GO core only.
2. **UCSC `chrlength`/`refGene`** (today's `providers/ucsc`, which feeds
   `gpsrc.sqlite`, a hard dependency of every `chipsrc_<species>.sqlite`)
   has no biocOnIce equivalent yet. Their genome-feature tables
   (`annotation.gene`/`transcript`/`exon`) are Ensembl-only, and their own
   README calls the TxDb/EnsDb-equivalent R-facing layer "Milestone 2, not
   built yet." `providers/ucsc` stays as-is regardless of how far this
   milestone goes.
3. **New external runtime dependency.** This trades "download NCBI/GO
   files directly from their own hosts" for "depend on
   `icegate-bioconice.seandavi.workers.dev` being up, and on *their*
   re-ingest cadence" — a third-party service this repo doesn't control.
   biocOnIce's `provenance.release` table (keyed `(release, source,
   artifact)`) can pin a specific snapshot per Bioconductor release, the
   same way retrieval dates are tracked today, but the uptime/SLA is
   external.
4. **Tooling**: no need for their Python `bioconice` CLI/package — DuckDB's
   R client (CRAN `duckdb`) supports `ATTACH ... TYPE ICEBERG` directly, so
   this is one new, fairly light R dependency (DuckDB + its `iceberg`/
   `httpfs` extensions), not a Python/`uv` toolchain addition.

**Staged plan:**

1. **Proof of concept, human only, additive.** New
   `scripts/make_db0_from_ice.R`, taking `--taxid` (read straight from
   `config/species.tsv`), `ATTACH`es the public catalog via DuckDB-R and
   writes `db0_<species>.sqlite` directly in the schema
   `.definePossibleTables()` expects — skipping `chipsrc_<species>.sqlite`
   and `make_db0.sh` entirely for the gene/GO tables. `providers/pfam`,
   `providers/uniprot`, `providers/ucsc` stay unchanged and get merged in
   as today. Validate against human with `tests/check_orgdb.R`, diffing
   row-for-row against the currently-built `org.Hs.eg.db` (same validation
   pattern as Milestones 4/4.5), and explicitly enumerate every difference
   as either expected (PFAM/IPI/PROSITE gone, or kept via the legacy path)
   or a bug.
2. **`GO.db`.** Replace `providers/go`'s OBO download/parse chain with a
   query against `bioc.ontology.term`/`bioc.ontology.relationship`, either
   reproducing `GO.sqlite`'s current shape (smaller change to
   `make_godb.R`) or rewriting `make_godb.R` to read from biocOnIce
   directly.
3. **Generalize by `taxid`.** Once human passes, extend step 1 to every
   other species in `config/species.tsv` by `taxid` — this *replaces* the
   remaining Milestone 5 species-by-species work (`chicken`/`canine`/
   `rhesus`/`fly`/`worm`/`yeast`/`arabidopsis`) rather than extending it,
   since there is no more per-species table-naming reconciliation to do
   for any species biocOnIce's NCBI ingest covers.
4. **Fallback behavior.** Decide what happens if
   `icegate-bioconice.seandavi.workers.dev` is unreachable at build time.
   Likely: keep today's direct-download path as the default, make
   biocOnIce opt-in via an env var (e.g. `GENE_SOURCE=bioconice`), not a
   silent replacement.

Not yet started: no code written for this milestone yet (as of
2026-10-21); the mapping and gap analysis above have been traced against
`bioc-on-ice`'s schema source and README but not run against live data.

### 7. A less-interventional, tidyverse/SQL-native access layer — PROPOSED, not started

Depends on Milestone 6 existing (or at least the `ATTACH ... TYPE ICEBERG`
connection it establishes). `AnnotationDbi::select()`/`mapIds()`/
`keytypes()`/`columns()` impose a bespoke query DSL bounded by
`.definePossibleTables()`'s per-organism keytype whitelist — the same
whitelist that makes Milestones 1/5/6 as laborious as they are. Once the
data actually lives in Iceberg tables (ordinary rows, joinable by any
column, in SQL), routing every query back through that keytype matrix
throws away exactly the generality Milestone 6 buys.

**Objective, stated narrowly on purpose:** expose the biocOnIce tables as
dbplyr lazy tables over the same DuckDB `ATTACH ... TYPE ICEBERG`
connection Milestone 6 uses, so ordinary `dplyr` verbs (`filter()`,
`select()`, `inner_join()`, `collect()`) or raw SQL work directly against
`annotation.ncbi__gene`, `annotation.identifier_mapping`,
`annotation.ncbi__gene_go`, `ontology.term`/`relationship`, etc. — any
column as a join key, any species by `taxon_id`, any join across tables
that a keytype-bounded `select()` call could never express in one call
(e.g. gene → GO → ontology ancestor closure via a recursive CTE, as
`bioc-on-ice`'s own README demonstrates). DuckDB does the query pushdown;
this layer adds no query engine of its own.

**Thinness is the objective, not a constraint to work around.** Explicitly
in scope: a connection helper and documentation pointing at the tables
directly. Explicitly out of scope, to guard against scope creep: no new
query abstraction, no reimplementing `select()`'s semantics with different
syntax, no caching/materialization layer — if dbplyr or raw SQL can already
say it, this milestone does not wrap it again.

**Transitional compatibility, not replacement.** `AnnotationDbi::select()`/
`mapIds()`/`keytypes()`/`columns()` stay working throughout — as thin
wrappers translating to the same underlying SQL, not as a parallel
implementation — so existing scripts and packages depending on this
pipeline's output are not broken while the direct-table path is adopted.
Retiring the compatibility shim, if ever, is a separate future decision,
not part of this milestone.

Not yet started: no code written; depends on Milestone 6 landing first.

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
