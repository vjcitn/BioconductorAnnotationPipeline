# Human direct GO annotations

`annotation.ncbi__gene_go`, filtered to human and to currently-valid
rows. Columns: `gene_id`, `go_id`, `evidence` (OrgDb's `EVIDENCE`),
`qualifier`, `go_term`, `category` (OrgDb's `ONTOLOGY`, spelled
Function/Process/ Component). Direct annotations only – joining
`ontology.relationship` for the `is_a` closure gets you OrgDb's `GOALL`;
see the package README.

## Usage

``` r
hs_go(con = ice_con(), cache = FALSE)
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
hs_go() |> dplyr::filter(gene_id == "7157") |> dplyr::collect()
#> # A tibble: 214 × 9
#>    gene_id taxon_id go_id      evidence qualifier   go_term  category valid_from
#>    <chr>      <int> <chr>      <chr>    <chr>       <chr>    <chr>    <chr>     
#>  1 7157        9606 GO:2000379 IMP      involved_in positiv… Process  2026.08   
#>  2 7157        9606 GO:0006355 IEA      involved_in regulat… Process  2026.08   
#>  3 7157        9606 GO:0042771 IDA      involved_in intrins… Process  2026.08   
#>  4 7157        9606 GO:0005654 TAS      located_in  nucleop… Compone… 2026.08   
#>  5 7157        9606 GO:0070245 IEA      involved_in positiv… Process  2026.08   
#>  6 7157        9606 GO:0005739 IDA      located_in  mitocho… Compone… 2026.08   
#>  7 7157        9606 GO:0005737 IDA      located_in  cytopla… Compone… 2026.08   
#>  8 7157        9606 GO:1905856 IMP      involved_in negativ… Process  2026.08   
#>  9 7157        9606 GO:1990841 IBA      enables     promote… Function 2026.08   
#> 10 7157        9606 GO:0000785 IDA      located_in  chromat… Compone… 2026.08   
#> # ℹ 204 more rows
#> # ℹ 1 more variable: valid_to <chr>
```
