# The package's shared connection

Every accessor in this package
([`hs_gene()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/hs_gene.md),
[`hs_alias()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/hs_alias.md),
...) takes a `con` argument defaulting to this function, so a script
that just wants to query never has to call
[`connect_ice()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/connect_ice.md)
itself. The connection is opened on first use and reused after that;
call
[`connect_ice()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/connect_ice.md)
directly instead if you want an independent connection (e.g. a second
one pointed at a different `endpoint`).

## Usage

``` r
ice_con()
```

## Value

A `DBI` connection with the catalog attached as `bioc`.

## Examples

``` r
ice_con() |> DBI::dbGetQuery("SELECT * FROM bioc.annotation.ncbi__gene LIMIT 3;")
#>     gene_id taxon_id       symbol
#> 1 116784092   296741        ESCO2
#> 2 116784097   296741       SCARA3
#> 3 116784105   296741 LOC116784105
#>                                                        description
#> 1 establishment of sister chromatid cohesion N-acetyltransferase 2
#> 2                              scavenger receptor class A member 3
#> 3                      vicilin-like seed storage protein At2g18540
#>        gene_type chromosome map_location valid_from valid_to
#> 1 protein-coding          3         <NA>    2026.09     <NA>
#> 2 protein-coding          3         <NA>    2026.09     <NA>
#> 3 protein-coding          3         <NA>    2026.09     <NA>
```
