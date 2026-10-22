# Connect to the public biocOnIce Iceberg catalog

Opens an anonymous, read-only DuckDB connection with the biocOnIce
catalog `ATTACH`ed as `bioc`, served by icegate. No account or token is
needed.

## Usage

``` r
connect_ice(endpoint = "https://icegate-bioconice.seandavi.workers.dev")
```

## Arguments

- endpoint:

  icegate URL. Defaults to the public biocOnIce deployment.

## Value

A `DBI` connection with the catalog attached as `bioc`.

## Examples

``` r
con <- connect_ice()
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/RtmphLoDuZ/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.
DBI::dbGetQuery(con, "SELECT * FROM bioc.annotation.ncbi__gene LIMIT 3;")
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
disconnect_ice(con)
```
