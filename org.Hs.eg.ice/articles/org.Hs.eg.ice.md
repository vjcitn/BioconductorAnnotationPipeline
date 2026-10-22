# Querying human gene annotation via biocOnIce with org.Hs.eg.ice

## Overview

`org.Hs.eg.ice` is a demonstration package: human gene annotation served
from the [biocOnIce](https://github.com/seandavi/bioc-on-ice) public
Iceberg catalog, queried directly with `dplyr`/`DBI`, with **no
dependency on `AnnotationDbi`** – no `OrgDb` class, no Bimap objects, no
[`select()`](https://rdrr.io/pkg/AnnotationDbi/man/AnnotationDb-class.html)/[`mapIds()`](https://rdrr.io/pkg/AnnotationDbi/man/AnnotationDb-class.html)/[`keytypes()`](https://rdrr.io/pkg/AnnotationDbi/man/AnnotationDb-class.html)
keytype whitelist. See `PlanFor3.24.md` Milestone 7 in the
[BioconductorAnnotationPipeline](https://github.com/vjcitn/BioconductorAnnotationPipeline)
repository for the design rationale, and Milestone 8 for the
local-caching layer shown below.

All code below runs live against the anonymous, unauthenticated
`biocOnIce` endpoint at build time, except one chunk flagged
`eval: false` where it’s explicitly noted why (a full cache refresh
including the ~6.6M-row `alias` table takes ~15 minutes – too slow for a
vignette build, though the code itself is exercised elsewhere with
`skip_alias = TRUE`).

``` r

library(org.Hs.eg.ice)
library(dplyr)
```

## The four accessors

Each accessor is a lazy `dplyr` table, already filtered to human
(`taxon_id = 9606`) and to currently-valid rows. Nothing else – every
join, every column selection, is ordinary `dplyr` written by the caller.

- [`hs_gene()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/hs_gene.md)
  – `annotation.ncbi__gene`: `gene_id`, `symbol`, `description`,
  `gene_type`, `chromosome`, `map_location`.
- [`hs_alias()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/hs_alias.md)
  – `annotation.identifier_mapping`: every cross-reference namespace
  NCBI/Ensembl assert, discriminated by `source_namespace`/
  `target_namespace`.
- [`hs_go()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/hs_go.md)
  – `annotation.ncbi__gene_go`: direct GO annotations, `go_id`/
  `evidence`/`qualifier`/`category`.
- [`hs_pubmed()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/hs_pubmed.md)
  – `annotation.ncbi__gene_pubmed`: `gene_id`/`pubmed_id`.

## The comparison that motivates this package

The `AnnotationDbi` way:

``` r

library(org.Hs.eg.db)
mapIds(org.Hs.eg.db, keys = "TP53", keytype = "SYMBOL", column = "ENTREZID")
```

      TP53
    "7157" 

``` r

select(org.Hs.eg.db, keys = "TP53", keytype = "SYMBOL",
       columns = c("ENTREZID", "GENENAME"))
```

      SYMBOL ENTREZID          GENENAME
    1   TP53     7157 tumor protein p53

The direct way:

`org.Hs.eg.db` loads `AnnotationDbi`, whose
[`select()`](https://rdrr.io/pkg/AnnotationDbi/man/AnnotationDb-class.html)
masks
[`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html) –
qualify explicitly as
[`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html)
from here on in a session that has both packages loaded.

``` r

hs_gene() |>
    filter(symbol == "TP53") |>
    dplyr::select(gene_id, symbol, description) |>
    collect()
```

    duckdb keeps downloaded extensions and secrets in a temporary directory:
    ℹ /tmp/RtmpPvKVR0/duckdb
    This is removed when the R session ends.
    • Extensions are re-downloaded each session.
    • Secrets are lost.
    ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
    ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
    ℹ See ?duckdb_storage for details and alternatives.

    # A tibble: 1 × 3
      gene_id symbol description
      <chr>   <chr>  <chr>
    1 7157    TP53   tumor protein p53

A join
[`select()`](https://rdrr.io/pkg/AnnotationDbi/man/AnnotationDb-class.html)/[`mapIds()`](https://rdrr.io/pkg/AnnotationDbi/man/AnnotationDb-class.html)
cannot express in one call – symbol to its direct GO annotations:

``` r

hs_gene() |>
    filter(symbol == "TP53") |>
    inner_join(hs_go(), by = c("gene_id", "taxon_id")) |>
    dplyr::select(symbol, go_id, go_term, evidence, category) |>
    collect() |>
    head(10)
```

    # A tibble: 10 × 5
       symbol go_id      go_term                                   evidence category
       <chr>  <chr>      <chr>                                     <chr>    <chr>
     1 TP53   GO:2000379 positive regulation of reactive oxygen s… IMP      Process
     2 TP53   GO:0006355 regulation of DNA-templated transcription IEA      Process
     3 TP53   GO:0042771 intrinsic apoptotic signaling pathway in… IDA      Process
     4 TP53   GO:0005654 nucleoplasm                               TAS      Compone…
     5 TP53   GO:0070245 positive regulation of thymocyte apoptot… IEA      Process
     6 TP53   GO:0005739 mitochondrion                             IDA      Compone…
     7 TP53   GO:0005737 cytoplasm                                 IDA      Compone…
     8 TP53   GO:1905856 negative regulation of pentose-phosphate… IMP      Process
     9 TP53   GO:1990841 promoter-specific chromatin binding       IBA      Function
    10 TP53   GO:0000785 chromatin                                 IDA      Compone…

## `GOALL`: the GO ancestor closure as a recursive CTE

OrgDb’s `GOALL` (the ancestor closure over the GO DAG) needs
`ontology.relationship`, a table this package does not wrap – attach it
directly, as `bioc-on-ice`’s own README shows for cell types.

A CTE (**common table expression**) is a named, temporary result set
defined with `WITH name AS (...)` immediately before the query that uses
it. `WITH RECURSIVE` lets the CTE refer to itself, so the query below
starts from one gene’s direct GO terms and repeatedly joins back into
`ontology.relationship` to pick up each term’s `is_a` parents, one level
of the DAG at a time, until no new ancestors are found:

``` r

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
") |>
    head(10)
```

          term_id                                                             name
    1  GO:2000379 positive regulation of reactive oxygen species metabolic process
    2  GO:0005654                                                      nucleoplasm
    3  GO:0070245               positive regulation of thymocyte apoptotic process
    4  GO:1990841                              promoter-specific chromatin binding
    5  GO:0006974                                              DNA damage response
    6  GO:0000122        negative regulation of transcription by RNA polymerase II
    7  GO:0005829                                                          cytosol
    8  GO:0030330   DNA damage response, signal transduction by p53 class mediator
    9  GO:0042981                                  regulation of apoptotic process
    10 GO:0032991                                       protein-containing complex

That query is exactly what `GOALL`/`select(..., columns = "GOALL")` can
never return in one `AnnotationDbi` call – this package doesn’t need to
invent an API for it, because the recursive CTE is already SQL.

## Connecting

``` r

hs_gene()   # opens the shared connection (ice_con()) on first use, anonymous, no token
```

    # A query:  ?? x 9
    # Database: DuckDB 1.5.6 [unknown@Linux 7.0.0-1017-azure:R 4.6.1/:memory:]
       gene_id   taxon_id symbol       description gene_type chromosome map_location
       <chr>        <int> <chr>        <chr>       <chr>     <chr>      <chr>
     1 147911132     9606 GOLGA6GP     golgin A6 … pseudo    15         15q25.1
     2 148057736     9606 CIDEC-AS1    CIDEC anti… ncRNA     3          3p25.3
     3 127270396     9606 LOC127270396 NANOG-H3K2… biologic… 1          <NA>
     4 127270411     9606 LOC127270411 H3K4me1 hE… biologic… 1          <NA>
     5 127270416     9606 LOC127270416 H3K27ac-H3… biologic… 1          <NA>
     6 127270429     9606 LOC127270429 H3K4me1 hE… biologic… 1          <NA>
     7 127270468     9606 LOC127270468 H3K27ac-H3… biologic… 1          <NA>
     8 127270472     9606 LOC127270472 H3K27ac-H3… biologic… 1          <NA>
     9 127270475     9606 LOC127270475 H3K4me1 hE… biologic… 1          <NA>
    10 127270477     9606 LOC127270477 H3K27ac hE… biologic… 1          <NA>
    # ℹ more rows
    # ℹ 2 more variables: valid_from <chr>, valid_to <chr>

Every accessor takes an explicit `con` argument if you want an
independent connection instead of the package’s shared one:

``` r

con <- connect_ice()
```

    duckdb keeps downloaded extensions and secrets in a temporary directory:
    ℹ /tmp/RtmpPvKVR0/duckdb
    This is removed when the R session ends.
    • Extensions are re-downloaded each session.
    • Secrets are lost.
    ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
    ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
    ℹ See ?duckdb_storage for details and alternatives.

``` r

hs_gene(con)
```

    # A query:  ?? x 9
    # Database: DuckDB 1.5.6 [unknown@Linux 7.0.0-1017-azure:R 4.6.1/:memory:]
       gene_id   taxon_id symbol       description gene_type chromosome map_location
       <chr>        <int> <chr>        <chr>       <chr>     <chr>      <chr>
     1 147911132     9606 GOLGA6GP     golgin A6 … pseudo    15         15q25.1
     2 148057736     9606 CIDEC-AS1    CIDEC anti… ncRNA     3          3p25.3
     3 127270396     9606 LOC127270396 NANOG-H3K2… biologic… 1          <NA>
     4 127270411     9606 LOC127270411 H3K4me1 hE… biologic… 1          <NA>
     5 127270416     9606 LOC127270416 H3K27ac-H3… biologic… 1          <NA>
     6 127270429     9606 LOC127270429 H3K4me1 hE… biologic… 1          <NA>
     7 127270468     9606 LOC127270468 H3K27ac-H3… biologic… 1          <NA>
     8 127270472     9606 LOC127270472 H3K27ac-H3… biologic… 1          <NA>
     9 127270475     9606 LOC127270475 H3K4me1 hE… biologic… 1          <NA>
    10 127270477     9606 LOC127270477 H3K27ac hE… biologic… 1          <NA>
    # ℹ more rows
    # ℹ 2 more variables: valid_from <chr>, valid_to <chr>

``` r

disconnect_ice(con)
```

## Local caching (provisional, Milestone 8)

Every accessor above stays live by default. Live-catalog latency is real
– a single filtered query over the network can take seconds, dominated
by S3/catalog metadata overhead rather than result size
(`PlanFor3.24.md` Milestone 8 measured 0.099s against `org.Hs.eg.db`
locally versus 4.15s against a live
[`hs_gene()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/hs_gene.md)/[`hs_pubmed()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/hs_pubmed.md)
join). If that’s a problem for a session,
[`ice_cache_refresh()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/ice_cache_refresh.md)
pulls all four tables once into a local `BiocFileCache`-managed DuckDB
file; pass `cache = TRUE` to any accessor to read from it instead.

The `alias`/`identifier_mapping` table dominates refresh time – 6.59M
rows, ~740s on its own – versus well under two minutes combined for
`gene`, `go`, and `pubmed`. A full refresh is too slow to run at
vignette build time, so it’s shown but not evaluated here:

``` r

ice_cache_refresh()                       # one-time, explicit, ~15 minutes
```

`skip_alias = TRUE` omits that table and keeps the refresh well under
two minutes – this does run at build time:

``` r

system.time(ice_cache_refresh(skip_alias = TRUE))
```

    duckdb keeps downloaded extensions and secrets in a temporary directory:
    ℹ /tmp/RtmpPvKVR0/duckdb
    This is removed when the R session ends.
    • Extensions are re-downloaded each session.
    • Secrets are lost.
    ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
    ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
    ℹ See ?duckdb_storage for details and alternatives.
    org.Hs.eg.ice: pulling gene ...

    org.Hs.eg.ice: gene -- 193813 rows in 2.9s

    org.Hs.eg.ice: pulling go ...

    org.Hs.eg.ice: go -- 446674 rows in 14.4s

    org.Hs.eg.ice: pulling pubmed ...

    org.Hs.eg.ice: pubmed -- 3326577 rows in 22.5s

    org.Hs.eg.ice: writing gene to local cache ...

    org.Hs.eg.ice: writing go to local cache ...

    org.Hs.eg.ice: writing pubmed to local cache ...

    org.Hs.eg.ice: local cache refreshed at /home/runner/.cache/R/org.Hs.eg.ice/29555cfb7bf0_29555cfb7bf0duckdb

       user  system elapsed
     21.220   2.608  44.868 

``` r

hs_gene(cache = TRUE) |>
    filter(symbol == "ORMDL3") |>
    collect()
```

    duckdb keeps downloaded extensions and secrets in a temporary directory:
    ℹ /tmp/RtmpPvKVR0/duckdb
    This is removed when the R session ends.
    • Extensions are re-downloaded each session.
    • Secrets are lost.
    ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
    ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
    ℹ See ?duckdb_storage for details and alternatives.

    # A tibble: 1 × 9
      gene_id taxon_id symbol description          gene_type chromosome map_location
      <chr>      <int> <chr>  <chr>                <chr>     <chr>      <chr>
    1 94103       9606 ORMDL3 ORMDL sphingolipid … protein-… 17         17q21.1
    # ℹ 2 more variables: valid_from <chr>, valid_to <chr>

A real end-to-end run (full refresh, `alias` included) measured **0.090s
cached versus 15.987s live** for a
[`hs_gene()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/hs_gene.md)/[`hs_pubmed()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/hs_pubmed.md)
join on this same gene – about 178x. `hs_alias(cache = TRUE)` errors
cleanly when `alias` was skipped:

``` r

hs_alias(cache = TRUE)
```

    duckdb keeps downloaded extensions and secrets in a temporary directory:
    ℹ /tmp/RtmpPvKVR0/duckdb
    This is removed when the R session ends.
    • Extensions are re-downloaded each session.
    • Secrets are lost.
    ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
    ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
    ℹ See ?duckdb_storage for details and alternatives.

    Error:
    ! No 'alias' table in the local cache -- it was skipped (ice_cache_refresh(skip_alias = TRUE)) or predates this option. Call ice_cache_refresh() without skip_alias = TRUE.

``` r

ice_cache_clear()
ice_cache_exists()
```

    [1] FALSE

Nothing calls
[`ice_cache_refresh()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/ice_cache_refresh.md)
automatically, and nothing expires the cache automatically – call it
again when you want a fresher copy, or
[`ice_cache_clear()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/ice_cache_clear.md)
to remove it.

This caching layer is provisional: it does **not** yet tag the cache
with a `bioc-on-ice` `provenance.release` identifier, and makes no
cross-table-consistency claim beyond what the live catalog itself
provides. See `PlanFor3.24.md` Milestone 8’s open caveat on cross-table
atomicity – row-level versioning is applied per table independently, so
filtering
[`hs_gene()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/hs_gene.md)
and
[`hs_pubmed()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/hs_pubmed.md)
to “the same” nominal release does not, by itself, prove a join between
them is point-in-time consistent.

## AnnotationDbi concept → org.Hs.eg.ice equivalent

| AnnotationDbi concept (`org.Hs.eg.db`) | org.Hs.eg.db | org.Hs.eg.ice |
|----|----|----|
| **Object model** | `OrgDb` S4 class, Bimap objects under the hood | No class at all – four plain [`dplyr::tbl()`](https://dplyr.tidyverse.org/reference/tbl.html) lazy tables |
| **`keytypes(x)`** | Fixed whitelist (`ENTREZID`, `SYMBOL`, `ALIAS`, `ENSEMBL`, `GO`, `PMID`, …) | No such function. “Keytype” is whichever column you [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) on – e.g. `hs_alias() |> filter(target_namespace == "ALIAS")` is OrgDb’s `ALIAS` keytype |
| **`columns(x)`** | Fixed list of retrievable columns | No enumeration function – the columns are whatever’s in the four tables’ schemas |
| **`select(x, keys, keytype, columns)`** | One call does filter + column choice + join | Ordinary [`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html) + [`select()`](https://rdrr.io/pkg/AnnotationDbi/man/AnnotationDb-class.html) + [`left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html)/[`inner_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html) written by the caller |
| **`mapIds(x, keys, keytype, column)`** | Single-valued lookup with `multiVals` logic | No equivalent; [`filter()`](https://dplyr.tidyverse.org/reference/filter.html)+[`select()`](https://rdrr.io/pkg/AnnotationDbi/man/AnnotationDb-class.html)+[`collect()`](https://dplyr.tidyverse.org/reference/compute.html), caller handles 1:many |
| **`ENTREZID`** | Row names / keytype | `hs_gene()$gene_id` |
| **`SYMBOL`** | keytype/column | `hs_gene()$symbol` |
| **`GENENAME`** | column | `hs_gene()$description` |
| **`GENETYPE`** | column | `hs_gene()$gene_type` |
| **`CHR`** | column | `hs_gene()$chromosome` |
| **`MAP`** | column | `hs_gene()$map_location` |
| **`ALIAS`, `ENSEMBL`, `HGNC`, `MIM`, …** | separate keytypes, each its own internal table | all rows of [`hs_alias()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/hs_alias.md), discriminated by `source_namespace`/`target_namespace` |
| **`GO`** (direct) | column | [`hs_go()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/hs_go.md): `go_id`, `evidence`, `qualifier`, `category` |
| **`GOALL`** (ancestor closure) | precomputed column | hand-written `WITH RECURSIVE` CTE over `ontology.relationship`/`ontology.term` (above) |
| **`PMID`** | column | `hs_pubmed()$pubmed_id` |
| **Multi-table joins** | not expressible in one call | ordinary `dplyr` joins across the four lazy tables |
| **Offline / cold-start speed** | instant, local SQLite, ~0.1s/query | live: ~4-16s/query; cached: ~0.09s/query |
| **Local caching** | implicit (the package *is* a local cache) | opt-in [`ice_cache_refresh()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/ice_cache_refresh.md) + `cache = TRUE` (above) |
| **Versioning / reproducibility** | pinned to installed package version | not yet addressed by the cache; open cross-table-atomicity question (Milestone 8) |
| **Dependencies** | `AnnotationDbi`, `RSQLite`, Bioconductor infrastructure | `DBI`, `dbplyr`, `dplyr`, `duckdb`, `BiocFileCache` (cache only) – no `AnnotationDbi` |

## Status

Tests exist: `tests/testthat/test-accessors.R` has live-catalog tests
(`skip`s cleanly if the catalog is unreachable) and offline
signature/cache-state checks. Not yet `R CMD check`ed against the live
catalog, not published. This vignette’s code runs live at build time
(the only exception is `cache-refresh-full` above, flagged `eval: false`
because a full refresh takes ~15 minutes).
