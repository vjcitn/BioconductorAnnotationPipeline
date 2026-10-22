# Remove the local cache

Remove the local cache

## Usage

``` r
ice_cache_clear()
```

## Value

`TRUE`, invisibly.

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
#> org.Hs.eg.ice: gene -- 193813 rows in 5s
#> org.Hs.eg.ice: pulling go ...
#> org.Hs.eg.ice: go -- 446674 rows in 16.3s
#> org.Hs.eg.ice: pulling pubmed ...
#> org.Hs.eg.ice: pubmed -- 3326577 rows in 10.6s
#> org.Hs.eg.ice: writing gene to local cache ...
#> org.Hs.eg.ice: writing go to local cache ...
#> org.Hs.eg.ice: writing pubmed to local cache ...
#> org.Hs.eg.ice: local cache refreshed at /tmp/RtmphLoDuZ/file23015e17f28f/23016e3a81eb_23016e3a81ebduckdb
ice_cache_clear()
ice_cache_exists()
#> [1] FALSE
options(org.Hs.eg.ice.cache_dir = old)
```
