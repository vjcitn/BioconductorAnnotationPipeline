# org.Hs.eg.ice

A demonstration package: human gene annotation from the
[biocOnIce](https://github.com/seandavi/bioc-on-ice) public Iceberg catalog,
queried directly with `dplyr`/`DBI`, with **no dependency on `AnnotationDbi`**
— no `OrgDb` class, no Bimap objects, no `select()`/`mapIds()`/`keytypes()`
keytype whitelist. See `PlanFor3.24.md` Milestone 7 in the
[BioconductorAnnotationPipeline](https://github.com/vjcitn/BioconductorAnnotationPipeline)
repository for why.

Four accessors, each a lazy `dplyr` table already filtered to human
(`taxon_id = 9606`) and to currently-valid rows:

- `hs_gene()` — `annotation.ncbi__gene`: `gene_id`, `symbol`, `description`,
  `gene_type`, `chromosome`, `map_location`.
- `hs_alias()` — `annotation.identifier_mapping`: every cross-reference
  namespace NCBI/Ensembl assert, discriminated by `source_namespace`/
  `target_namespace`.
- `hs_go()` — `annotation.ncbi__gene_go`: direct GO annotations, `go_id`/
  `evidence`/`qualifier`/`category`.
- `hs_pubmed()` — `annotation.ncbi__gene_pubmed`: `gene_id`/`pubmed_id`.

Each one adds nothing beyond that filter — every join, every column
selection, is ordinary `dplyr` written by the caller against the lazy table.

## The comparison this package exists to make

The `AnnotationDbi` way:

```r
library(org.Hs.eg.db)
mapIds(org.Hs.eg.db, keys = "TP53", keytype = "SYMBOL", column = "ENTREZID")
select(org.Hs.eg.db, keys = "TP53", keytype = "SYMBOL",
       columns = c("ENTREZID", "GENENAME"))
```

The direct way:

```r
library(org.Hs.eg.ice)
library(dplyr)

hs_gene() |>
    filter(symbol == "TP53") |>
    select(gene_id, symbol, description) |>
    collect()
```

A join `select()`/`mapIds()` cannot express in one call — symbol to its
direct GO annotations:

```r
hs_gene() |>
    filter(symbol == "TP53") |>
    inner_join(hs_go(), by = c("gene_id", "taxon_id")) |>
    select(symbol, go_id, go_term, evidence, category) |>
    collect()
```

OrgDb's `GOALL` (the ancestor closure over the GO DAG) needs
`ontology.relationship`, a table this package does not wrap — attach it
directly, as `bioc-on-ice`'s own README shows for cell types:

```r
con <- ice_con()
DBI::dbGetQuery(con, "
    WITH RECURSIVE ancestors(go_id) AS (
        SELECT go_id FROM bioc.annotation.ncbi__gene_go
        WHERE gene_id = '7157' AND taxon_id = 9606 AND valid_to IS NULL
        UNION
        SELECT r.object_id
        FROM bioc.ontology.relationship r
        JOIN ancestors a ON r.subject_id = a.go_id
        WHERE r.predicate = 'is_a' AND r.ontology = 'go' AND r.valid_to IS NULL
    )
    SELECT DISTINCT t.term_id, t.name
    FROM ancestors a
    JOIN bioc.ontology.term t ON t.term_id = a.go_id AND t.valid_to IS NULL;
")
```

That query is exactly what `GOALL`/`select(..., columns = "GOALL")` can
never return in one `AnnotationDbi` call — this package doesn't need to
invent an API for it, because the recursive CTE is already SQL.

## AnnotationDbi concept &rarr; org.Hs.eg.ice equivalent

| AnnotationDbi concept (`org.Hs.eg.db`) | org.Hs.eg.db | org.Hs.eg.ice |
|---|---|---|
| **Object model** | `OrgDb` S4 class, Bimap objects under the hood | No class at all — four plain `dplyr::tbl()` lazy tables (`hs_gene()`, `hs_alias()`, `hs_go()`, `hs_pubmed()`) |
| **`keytypes(x)`** | Returns fixed whitelist (`ENTREZID`, `SYMBOL`, `ALIAS`, `ENSEMBL`, `GO`, `PMID`, ...) | No such function/concept. "Keytype" is just whichever column you `filter()` on — e.g. `hs_alias() \|> filter(target_namespace == "ALIAS")` is OrgDb's `ALIAS` keytype, `filter(target_namespace == "ENSEMBL")` is `ENSEMBL`, etc. |
| **`columns(x)`** | Fixed list of retrievable columns | No enumeration function — the columns are whatever's in the four tables' schemas (visible via `colnames()`/`glimpse()` on the lazy table itself) |
| **`select(x, keys, keytype, columns)`** | One call does filter + column choice + join across internal tables | No equivalent call; it's ordinary `dplyr::filter()` + `select()` + `left_join()`/`inner_join()` written by the caller against the lazy tables |
| **`mapIds(x, keys, keytype, column)`** | Single-valued key→value lookup, with multiVals disambiguation logic | No equivalent; same `filter()`+`select()`+`collect()` pattern, caller handles 1:many themselves (e.g. `nrow()>1` just means multiple rows come back) |
| **`ENTREZID`** | Row names / keytype | `hs_gene()$gene_id` |
| **`SYMBOL`** | keytype/column | `hs_gene()$symbol` |
| **`GENENAME`** | column | `hs_gene()$description` |
| **`GENETYPE`** | column | `hs_gene()$gene_type` |
| **`CHR`** | column | `hs_gene()$chromosome` |
| **`MAP`** | column | `hs_gene()$map_location` |
| **`ALIAS`, `ENSEMBL`, `HGNC`, `MIM`, ...** | separate keytypes, each its own internal mapping table | all rows of `hs_alias()` (`annotation.identifier_mapping`), discriminated by `source_namespace`/`target_namespace` rather than being separate keytypes |
| **`GO`** (direct annotations) | column, via `select(..., columns="GO")` | `hs_go()`: `go_id`, `evidence`, `qualifier`, `category` |
| **`GOALL`** (ancestor closure over the GO DAG) | precomputed column, one `select()` call | not precomputed — a hand-written `WITH RECURSIVE` CTE over `ontology.relationship`/`ontology.term` (above); the DAG walk is explicit SQL, not a library feature |
| **`PMID`** | column | `hs_pubmed()$pubmed_id` |
| **Multi-table joins** (e.g. symbol → GO → PubMed in one call) | not expressible in a single `select()`/`mapIds()` call — requires multiple calls and manual merging | ordinary `dplyr` joins across the four lazy tables in one pipeline, same as joining any other tables |
| **Offline / cold-start speed** | instant, local SQLite, ~0.1s/query | live: ~4–16s/query (S3/catalog metadata overhead per call, independent of result size) |
| **Local caching** | implicit — the whole package *is* a local cache (a shipped SQLite file) | opt-in: `ice_cache_refresh()` materializes all four tables into a local `BiocFileCache`-managed DuckDB file; `cache = TRUE` on any accessor reads from it (~0.09s/query once refreshed, see Milestone 8 below) |
| **Versioning / reproducibility** | pinned to the installed package version | not yet addressed by the cache; live data reflects `bioc-on-ice`'s row-level `valid_from`/`valid_to`/`provenance.release` model — open question (`PlanFor3.24.md` Milestone 8) whether joins across tables are point-in-time consistent |
| **Dependencies** | `AnnotationDbi`, `RSQLite`, Bioconductor infrastructure | `DBI`, `dbplyr`, `dplyr`, `duckdb`, `BiocFileCache` (cache only) — no `AnnotationDbi` dependency at all |

The throughline: `org.Hs.eg.db` hides its schema behind a fixed
keytype/column API that `select()`/`mapIds()` interpret; `org.Hs.eg.ice`
exposes the schema directly as lazy tables and leaves the "keytype" logic
(which column, which namespace) to ordinary `dplyr` verbs the caller writes.

## Connecting

```r
library(org.Hs.eg.ice)
hs_gene()   # opens the shared connection (ice_con()) on first use, anonymous, no token
```

Every accessor takes an explicit `con` argument if you want an independent
connection instead of the package's shared one:

```r
con <- connect_ice()
hs_gene(con)
disconnect_ice(con)
```

## Local caching (provisional, Milestone 8)

Every accessor above stays live by default. If the live-catalog latency is a
problem for a session, `ice_cache_refresh()` pulls all four tables once into
a local `BiocFileCache`-managed DuckDB file; pass `cache = TRUE` to any
accessor to read from it instead of the live catalog:

```r
library(org.Hs.eg.ice)
ice_cache_refresh()                       # one-time, explicit, slow call

hs_gene(cache = TRUE) |>
    dplyr::filter(symbol == "ORMDL3") |>
    dplyr::left_join(hs_pubmed(cache = TRUE), by = "gene_id") |>
    dplyr::collect()
```

Nothing calls `ice_cache_refresh()` automatically, and nothing expires the
cache automatically -- call it again when you want a fresher copy, or
`ice_cache_clear()` to remove it. This is a provisional implementation of
`PlanFor3.24.md` Milestone 8, built to demonstrate the latency difference;
it does **not** yet tag the cache with a `bioc-on-ice` `provenance.release`
identifier, and makes no cross-table-consistency claim beyond what the live
catalog itself provides (see Milestone 8's open caveat on that).

A real end-to-end run (2026-10-22) confirmed the speedup:
`hs_gene(cache=TRUE) |> filter(symbol=="ORMDL3") |> collect()` took 0.090s
versus 15.987s live. The refresh itself took ~869s total, almost entirely
`alias`/`identifier_mapping` (6.59M rows, ~739s) -- `gene`, `go`, and
`pubmed` together took well under two minutes. `ice_cache_refresh()`
prints per-table progress (`pulling ...` / `N rows in Ns`) since this isn't
fast enough to run silently. If you don't need `hs_alias()` (cross-reference
lookups), `ice_cache_refresh(skip_alias = TRUE)` skips it and cuts the
refresh to well under two minutes; `hs_alias(cache = TRUE)` then errors
telling you to refresh again without `skip_alias`.

## Status

Skeleton only (`PlanFor3.24.md` Milestone 7's demo package), plus a
provisional local cache (Milestone 8, above). Not published, not
`R CMD check`ed against the live catalog yet. `tests/testthat/
test-accessors.R` has live-catalog tests (`skip`s cleanly if the catalog
is unreachable) and offline signature/cache-state checks.
