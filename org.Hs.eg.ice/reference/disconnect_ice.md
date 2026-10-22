# Disconnect from the catalog

Disconnect from the catalog

## Usage

``` r
disconnect_ice(con)
```

## Arguments

- con:

  a connection returned by
  [`connect_ice()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/connect_ice.md)
  or
  [`ice_con()`](https://vjcitn.github.io/BioconductorAnnotationPipeline/org.Hs.eg.ice/reference/ice_con.md).

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
disconnect_ice(con)
```
