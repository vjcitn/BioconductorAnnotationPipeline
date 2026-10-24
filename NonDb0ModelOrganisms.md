# Finding: non-db0 species fail modern `keys()`/`select()` API despite correct data

## Status: diagnosed, not yet fixed — discuss before changing `scripts/make_orgdb.R`

## Summary

Every species outside `DB0_SUPPORTED_SPECIES` (human, mouse, rat, zebrafish,
chimp, bovine, chicken, canine) is built via the legacy
`AnnotationForge::makeOrgPackage()` path in `scripts/make_orgdb.R`
(`build_via_make_org_package()`, starting at line 198). `make check` on
worm (`org.Ce.eg.db`) surfaced **37 passed, 18 failed** — but every failure
is a `keys(keytype = X)` call throwing a raw SQL error
(`no such table: ...` / `no such column: ...`), not a data problem. All
structural, count-consistency, referential-integrity, and spot-check layers
of `tests/check_orgdb.R` pass cleanly:

- Gene count matches chipsrc exactly (46,927 vs 46,927)
- GO row count matches exactly (92,449 vs 92,449), 21% GO coverage
- UniProt mapping 40% coverage
- Landmark gene (172616 / cep-1) spot-checks correct, including UniProt
  `Q20646` and GO term `GO:0008630`

The data is right. The package's modern `keys()`/`select()` dispatch is
broken for 18 of ~20 keytypes:

| Keytype(s) | Error |
|---|---|
| ACCNUM | `no such table: accessions` |
| ALIAS | `no such table: alias` |
| ENSEMBL | `no such table: ensembl` |
| ENSEMBLPROT | `no such table: ensembl_prot` |
| ENSEMBLTRANS | `no such table: ensembl_trans` |
| ENZYME | `no such table: ec` |
| EVIDENCE / GO / ONTOLOGY | `no such table: go` |
| EVIDENCEALL / GOALL / ONTOLOGYALL | `no such table: go_all` |
| GENENAME | `no such column: gene_name` |
| PATH | `no such table: kegg` |
| PMID | `no such column: pubmed_id` |
| REFSEQ | `no such column: accession` |
| UNIPROT | `no such column: uniprot_id` |
| WORMBASE | `no such table: wormbase` |

Only ENTREZID and SYMBOL pass, by coincidence (both schemas happen to agree
on `gene_id`/`SYMBOL`).

## Root cause

`build_via_make_org_package()` unconditionally sets `DBSCHEMA` in the
package metadata to `row$pkg_template` (`scripts/make_orgdb.R:467`):

```r
list("DBSCHEMA", row$pkg_template),   # "WORM_DB" for worm, from config/species.tsv
```

`DBSCHEMA` is the flag AnnotationDbi's `keys()`/`select()` generics use to
pick which S4 schema-dispatch methods to use. `WORM_DB` is the schema class
written for the **original, historically-published** `org.Ce.eg.db` — built
long ago via AnnotationDbi's direct-SQLite pipeline, which uses a specific
fixed table layout: a unified `go`/`go_all` table, and dedicated
`accessions`/`alias`/`ensembl`/`ensembl_prot`/`ensembl_trans`/`ec`/`kegg`/
`wormbase` tables with lowercase columns (`gene_name`, `pubmed_id`,
`accession`, `uniprot_id`).

But `makeOrgPackage()` in this pipeline builds tables named after whatever
R data frames are handed to it. The frames assembled in
`build_via_make_org_package()` (lines 203–273) produce tables named
`gene_info`/`refseq`/`pubmed`/`synonym`/`accnum`/`ensembl`/`ensembl_pro`/
`ensembl_trs`/`uniprot`, with **uppercase** columns (`SYMBOL`, `GENENAME`,
`REFSEQ`, `PMID`, `ALIAS`, `ACCNUM`, `ENSEMBL`, `ENSEMBLPROT`,
`ENSEMBLTRANS`, `UNIPROT`) — the literal `AS` aliases used in the
`safe_query()` SQL. GO and Pfam are injected post-hoc (lines 475–536) as
split `go_bp`/`go_mf`/`go_cc` (+ `_all`) tables and a `pfam` table, not a
unified `go` table.

So: labeling the built sqlite `WORM_DB` tells AnnotationDbi "query this as
if it had the legacy schema," but the actual tables/columns are the
makeOrgPackage-native ones. Every keytype whose backing name differs
between the two conventions breaks.

This is the same bug class that Milestones 1–2 fixed for the 8 db0 species
— `tests/check_orgdb.R`'s own comment on the "Modern API coverage" section
(lines 430–463) names it directly: "this is exactly the bug Milestones 1-2
fixed (GOALL/PFAM/IPI/ENSEMBL listed but erroring with raw SQL errors on
keys()/select())." The db0 path avoids it because `scripts/make_db0.sh`
rewrites the chipsrc data into a `db0_<species>.sqlite` that conforms
exactly to the target `*_DB` schema *before* `AnnotationForge::makeAnnDbPkg()`
ever runs. The legacy path has no equivalent rewrite step — it just slaps
the legacy schema label on a package shaped differently.

**This is not a defect in `makeOrgPackage()` itself.** Used normally
(leaving `DBSCHEMA` as whatever `makeOrgPackage()` naturally assigns), it
would dispatch `keys()`/`select()` against the tables it actually created,
and work correctly. The bug is specific to this pipeline's extra
`DBSCHEMA` override.

## Why this matters for the "advocate `makeOrgPackage()` to external users" question

This was raised as an open strategic question: could Bioconductor stop
distributing prebuilt packages for model organisms outside the current 8
and just tell users with other-organism needs to run `makeOrgPackage()`
themselves?

This finding is good news for that question, with a caveat:

- **If a user calls `AnnotationForge::makeOrgPackage()` normally** (not
  forcing `DBSCHEMA` to a legacy package name the way this pipeline does),
  there's no reason to expect this breakage — `makeOrgPackage()` is
  designed to produce a self-consistent, queryable package on its own.
  The burden discussion from before (large shared downloads: full NCBI gene
  corpus, ~7GB UniProt idmapping, ~5GB Pfam regions, UCSC gpsrc fetching
  all species) still applies, but the *resulting package's API* should be
  fine.
- **This pipeline's own non-db0 builds are currently broken** in a way that
  would mislead anyone relying on them (`columns()`/`keytypes()` list the
  keytype; `keys()`/`select()` then fail) — this needs to be fixed or
  clearly flagged before any non-db0 package from this pipeline is
  distributed or demonstrated to users. (See below: the break is
  self-inflicted by this pipeline's `DBSCHEMA` override and bypass of
  `makeOrgPackage()`'s native GO support — not an inherent limitation of
  `makeOrgPackage()` itself.)

## What `NOSCHEMA_DB` is, and whether it already covers this

Investigated directly in the installed `AnnotationForge`/`AnnotationDbi`
sources (`~/AnnotationForge/R/makeOrgPackage.R`,
`~/BIOC_SOURCES/AnnotationDbi/R/methods-geneCentricDbs.R` and
`methods-geneCentricDbs-keys.R`).

`NOSCHEMA_DB` is **not** a fallback or edge case — it is
`AnnotationForge::.addEssentialMetadata()`'s own default
(`makeOrgPackage.R:71`, `schema = "NOSCHEMA_DB"`), and this pipeline's
`goTable = NA` call already leaves `makeOrgPackage()` writing exactly that
value before the pipeline's own post-processing overwrites it with the
legacy template name. In other words: **every out-of-the-box
`makeOrgPackage()`-built package, from any user, is `NOSCHEMA_DB` unless
something deliberately changes it.** It is the normal, supported mode for
custom (non-Bioconductor-curated) OrgDb packages — the legacy `*_DB` names
(`WORM_DB`, `HUMAN_DB`, ...) are reserved for the fixed, hand-written
schemas used by historically-published packages and by this pipeline's own
`make_db0.sh` + `makeAnnDbPkg()` path.

`NOSCHEMA_DB` dispatch is introspective, not table-name-hardcoded:
`.deriveTableNameFromField()` (`methods-geneCentricDbs-keys.R:126-143`)
scans every data table in the sqlite (`dbListTables`, excluding
`metadata`/`map_metadata`/`map_counts`) and finds whichever one has a
column matching the requested keytype name exactly — no fixed table list
needed. `.noSchemaKeys()`/`.noSchemaSelect()`/`.noSchemaCols()` build on
top of that. This means it would correctly resolve 12 of the current 18
failures as-is, because those keytypes are each backed by one
uniquely-named frame/table with a uniquely-named column matching the
keytype (`accnum`/`ACCNUM`, `synonym`/`ALIAS`, `ensembl`/`ENSEMBL`,
`ensembl_pro`/`ENSEMBLPROT`, `ensembl_trs`/`ENSEMBLTRANS`, `enzyme`/
`ENZYME`, `gene_info`/`GENENAME`, `path`/`PATH`, `pubmed`/`PMID`,
`refseq`/`REFSEQ`, `uniprot`/`UNIPROT`, and — if a `wormbase`-named frame
were added — `WORMBASE`). Just reverting the `DBSCHEMA` override would fix
these.

**The remaining 6 (`GO`/`GOALL`/`EVIDENCE`/`EVIDENCEALL`/`ONTOLOGY`/
`ONTOLOGYALL`) would NOT be fixed by that alone.**
`.deriveTableNameFromField()` has an explicit exclusion
(`methods-geneCentricDbs-keys.R:138`):

```r
colTabs <- colTabs[grep("go_[mcb].+", names(colTabs), invert = TRUE)]
```

This deliberately hides any table matching `go_bp`/`go_mf`/`go_cc` (and
their `_all` variants) from field lookup — exactly the split tables this
pipeline injects post-hoc (`make_orgdb.R:492-511`). Reverting `DBSCHEMA`
alone would leave GO-family keytypes failing, just with a different error.

The actual fix for GO is to stop bypassing `makeOrgPackage()`'s own GO
support. `AnnotationForge::makeOrgDbFromDataFrames()`
(`makeOrgPackage.R:159-168`, via `.makeNewGOTables()`) has a dedicated,
native path: pass a data frame with columns `GID`/`GO`/`EVIDENCE` as the
`goTable` argument, and it builds unified `go`/`go_all` tables (also
filtering out GO IDs too new for the installed `GO.db` — a correctness
check this pipeline's own post-hoc injection doesn't do) under names that
`NOSCHEMA_DB` *can* see, since `go`/`go_all` don't match the exclusion
regex. This pipeline currently passes `goTable = NA` and does its own raw
SQL `go_bp`/`go_mf`/`go_cc` injection instead (comment at line 336: "GO is
handled post-hoc via SQL ATTACH ... do not pass here"), apparently written
to match the legacy `WORM_DB`-style split-table shape rather than
`makeOrgPackage()`'s own native mechanism.

## Two fixes, now better scoped — **not yet implemented, pending discussion**

1. **Revert the `DBSCHEMA` override** — stop forcing it to
   `row$pkg_template` for non-db0 species; let `makeOrgPackage()`'s own
   `NOSCHEMA_DB` assignment stand. Fixes 12 of 18 failing keytypes on its
   own (everything except the GO family). This is where "nontrivial
   Makefile/script complexity" may still show up — need to check whether
   any downstream step (`tests/check_orgdb.R`'s own schema-aware
   `pick_col()` helper, packaging, or `config/species.tsv`'s
   `pkg_template` column itself) assumes the legacy `DBSCHEMA` name is
   present for non-db0 species.
2. **Route GO through `makeOrgPackage()`'s native `goTable` argument**
   instead of the current post-hoc `go_bp`/`go_mf`/`go_cc` SQL injection
   (`make_orgdb.R:475-511`). Needs a `GID`/`GO`/`EVIDENCE` frame built
   from chipsrc (straightforward — equivalent data this pipeline already
   extracts, just reshaped) passed as `goTable` before calling
   `makeOrgPackage()`, instead of injected afterward. Likely *removes*
   code (the manual `CREATE TABLE go_bp...`/`go_mf...`/`go_cc...` loop)
   rather than adding it.

Together, (1) and (2) should resolve all 18 failures using
`AnnotationForge`/`AnnotationDbi` mechanisms that already exist and are
already exercised by every ordinary `makeOrgPackage()` user — no new
schema-mapping logic needed in this pipeline.

3. **Alternative, more laborious option** (already scoped as Milestone 5
   in `PlanFor3.24.md`): extend the `make_db0.sh`-style rewrite to these
   species too, for full schema fidelity with the historically-published
   package layout. More work per species; not needed if (1)+(2) above
   turn out sufficient.

## Affected species

All species in `config/species.tsv` not in `DB0_SUPPORTED_SPECIES`: worm
(Ce), pig (Ss), xenopus (Xl), fly, yeast, arabidopsis, anopheles, rhesus,
and both ecoli strains. Worm is the only one empirically checked so far;
the mechanism (unconditional `DBSCHEMA` override in
`build_via_make_org_package()`) applies identically to all of them.
