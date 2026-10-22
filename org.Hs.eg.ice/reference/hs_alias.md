# Human gene synonyms and cross-references

`annotation.identifier_mapping`, filtered to human and to
currently-valid rows. Not just `ALIAS`: every cross-reference namespace
NCBI and Ensembl assert (`ENSEMBL`, `HGNC`, `MIM`, ...) is a row here,
discriminated by `source_namespace`/`target_namespace` – filter further
for a specific one, e.g. `dplyr::filter(target_namespace == "ALIAS")`
for OrgDb's `ALIAS` keytype.

## Usage

``` r
hs_alias(con = ice_con(), cache = FALSE)
```

## Arguments

- con:

  a `DBI` connection; defaults to the package's shared connection,
  [`ice_con()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/ice_con.md).

- cache:

  if `TRUE`, read from the local cache
  ([`ice_cache_refresh()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/ice_cache_refresh.md))
  instead of the live catalog; `con` is ignored. Errors if no cache
  exists yet. See
  [`ice_cache_refresh()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/ice_cache_refresh.md)
  – provisional, Milestone 8.

## Value

A lazy `dplyr` table.

## Examples

``` r
hs_alias() |>
    dplyr::filter(source_id == "7157", target_namespace == "ALIAS") |>
    dplyr::collect()
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/RtmphLoDuZ/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.
#> # A tibble: 5 × 9
#>   source_namespace source_id target_namespace target_id taxon_id source
#>   <chr>            <chr>     <chr>            <chr>        <int> <chr> 
#> 1 ENTREZ           7157      ALIAS            P53           9606 NCBI  
#> 2 ENTREZ           7157      ALIAS            BCC7          9606 NCBI  
#> 3 ENTREZ           7157      ALIAS            BMFS5         9606 NCBI  
#> 4 ENTREZ           7157      ALIAS            TRP53         9606 NCBI  
#> 5 ENTREZ           7157      ALIAS            LFS1          9606 NCBI  
#> # ℹ 3 more variables: confidence <dbl>, valid_from <chr>, valid_to <chr>
```
