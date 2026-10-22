# Refresh the local cache from the live biocOnIce catalog

Pulls
[`hs_gene()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/hs_gene.md),
[`hs_alias()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/hs_alias.md),
[`hs_go()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/hs_go.md),
[`hs_pubmed()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/hs_pubmed.md)
in full
([`collect()`](https://dplyr.tidyverse.org/reference/compute.html)),
writes them as tables in a local DuckDB file managed by `BiocFileCache`,
replacing any existing cache. This is the only function in this package
that writes to the cache – call it again whenever you want a fresher
local copy; nothing refreshes it automatically, and nothing calls it for
you.

## Usage

``` r
ice_cache_refresh(con = ice_con(), skip_alias = FALSE)
```

## Arguments

- con:

  a `DBI` connection to the live catalog; defaults to
  [`ice_con()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/ice_con.md).

- skip_alias:

  if `TRUE`, don't pull/cache the `alias` table – it dominates refresh
  time and isn't needed for gene/GO/pubmed lookups.

## Value

The local cache file path (invisibly).

## Details

Provisional: does not yet tag the cache with a `bioc-on-ice`
`provenance.release` identifier (`PlanFor3.24.md` Milestone 8).

The new cache is built in a temporary file and only swapped in once
every table has been pulled and written successfully. If the refresh is
interrupted or errors partway through, the previous cache (if any) is
left exactly as it was –
[`ice_cache_exists()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/ice_cache_exists.md)
cannot report a half-written cache, and no temporary file is left
behind.

`alias`
([`hs_alias()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/hs_alias.md)/`identifier_mapping`)
is by far the largest of the four tables – on a real refresh it was
~6.6M rows and ~740s, versus well under two minutes combined for the
other three. Set `skip_alias = TRUE` to leave it out of the refresh if
you don't need cross-reference lookups; `hs_alias(cache = TRUE)` then
errors telling you to refresh without skipping it.

## Examples

``` r
old <- getOption("org.Hs.eg.ice.cache_dir")
options(org.Hs.eg.ice.cache_dir = tempfile())
ice_cache_refresh(skip_alias = TRUE)
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/RtmphLoDuZ/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.
#> org.Hs.eg.ice: pulling gene ...
#> org.Hs.eg.ice: gene -- 193813 rows in 2.4s
#> org.Hs.eg.ice: pulling go ...
#> org.Hs.eg.ice: go -- 446674 rows in 4.1s
#> org.Hs.eg.ice: pulling pubmed ...
#> org.Hs.eg.ice: pubmed -- 3326577 rows in 6.2s
#> org.Hs.eg.ice: writing gene to local cache ...
#> org.Hs.eg.ice: writing go to local cache ...
#> org.Hs.eg.ice: writing pubmed to local cache ...
#> org.Hs.eg.ice: local cache refreshed at /tmp/RtmphLoDuZ/file2301d537fdb/23016fd2853f_23016fd2853fduckdb
ice_cache_exists()
#> [1] TRUE
hs_gene(cache = TRUE) |> dplyr::filter(symbol == "TP53") |> dplyr::collect()
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/RtmphLoDuZ/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.
#> # A tibble: 1 × 9
#>   gene_id taxon_id symbol description       gene_type    chromosome map_location
#>   <chr>      <int> <chr>  <chr>             <chr>        <chr>      <chr>       
#> 1 7157        9606 TP53   tumor protein p53 protein-cod… 17         17p13.1     
#> # ℹ 2 more variables: valid_from <chr>, valid_to <chr>
ice_cache_clear()
options(org.Hs.eg.ice.cache_dir = old)
```
