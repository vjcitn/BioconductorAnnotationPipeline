# Human genes

`annotation.ncbi__gene`, filtered to human and to currently-valid rows.
Columns: `gene_id` (Entrez GeneID, OrgDb's `ENTREZID`), `symbol`,
`description` (OrgDb's `GENENAME`), `gene_type` (OrgDb's `GENETYPE`),
`chromosome` (OrgDb's `CHR`), `map_location` (OrgDb's `MAP`).

## Usage

``` r
hs_gene(con = ice_con(), cache = FALSE)
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
hs_gene() |> dplyr::filter(symbol == "TP53") |> dplyr::collect()
#> # A tibble: 1 × 9
#>   gene_id taxon_id symbol description       gene_type    chromosome map_location
#>   <chr>      <int> <chr>  <chr>             <chr>        <chr>      <chr>       
#> 1 7157        9606 TP53   tumor protein p53 protein-cod… 17         17p13.1     
#> # ℹ 2 more variables: valid_from <chr>, valid_to <chr>
```
