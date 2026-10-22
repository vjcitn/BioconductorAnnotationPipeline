# Human gene-to-publication links

`annotation.ncbi__gene_pubmed`, filtered to human and to currently-valid
rows. Columns: `gene_id`, `pubmed_id` (OrgDb's `PMID`).

## Usage

``` r
hs_pubmed(con = ice_con(), cache = FALSE)
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
hs_pubmed() |> dplyr::filter(gene_id == "7157") |> dplyr::collect()
#> # A tibble: 20,400 × 5
#>    gene_id taxon_id pubmed_id valid_from valid_to
#>    <chr>      <int> <chr>     <chr>      <chr>   
#>  1 7157        9606 7811761   2026.08    NA      
#>  2 7157        9606 7887414   2026.08    NA      
#>  3 7157        9606 8016121   2026.08    NA      
#>  4 7157        9606 8134127   2026.08    NA      
#>  5 7157        9606 8221889   2026.08    NA      
#>  6 7157        9606 8395834   2026.08    NA      
#>  7 7157        9606 8402617   2026.08    NA      
#>  8 7157        9606 8557038   2026.08    NA      
#>  9 7157        9606 8623534   2026.08    NA      
#> 10 7157        9606 8639538   2026.08    NA      
#> # ℹ 20,390 more rows
```
