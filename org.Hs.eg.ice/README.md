# org.Hs.eg.ice

A demonstration package: human gene annotation from the
[biocOnIce](https://github.com/seandavi/bioc-on-ice) public Iceberg catalog,
queried directly with `dplyr`/`DBI`, with **no dependency on `AnnotationDbi`**
— no `OrgDb` class, no Bimap objects, no `select()`/`mapIds()`/`keytypes()`
keytype whitelist. See `PlanFor3.24.md` Milestone 7 in the
[BioconductorAnnotationPipeline](https://github.com/vjcitn/BioconductorAnnotationPipeline)
repository for why.

Four accessors, each a lazy `dplyr` table already filtered to human
(`taxon_id = 9606`) and to currently-valid rows:

- `hs_gene()` — `annotation.ncbi__gene`: `gene_id`, `symbol`, `description`,
  `gene_type`, `chromosome`, `map_location`.
- `hs_alias()` — `annotation.identifier_mapping`: every cross-reference
  namespace NCBI/Ensembl assert, discriminated by `source_namespace`/
  `target_namespace`.
- `hs_go()` — `annotation.ncbi__gene_go`: direct GO annotations, `go_id`/
  `evidence`/`qualifier`/`category`.
- `hs_pubmed()` — `annotation.ncbi__gene_pubmed`: `gene_id`/`pubmed_id`.

Each one adds nothing beyond that filter — every join, every column
selection, is ordinary `dplyr` written by the caller against the lazy table.

## The comparison this package exists to make

The `AnnotationDbi` way:

```r
library(org.Hs.eg.db)
mapIds(org.Hs.eg.db, keys = "TP53", keytype = "SYMBOL", column = "ENTREZID")
select(org.Hs.eg.db, keys = "TP53", keytype = "SYMBOL",
       columns = c("ENTREZID", "GENENAME"))
```

The direct way:

```r
library(org.Hs.eg.ice)
library(dplyr)

hs_gene() |>
    filter(symbol == "TP53") |>
    select(gene_id, symbol, description) |>
    collect()
```

A join `select()`/`mapIds()` cannot express in one call — symbol to its
direct GO annotations:

```r
hs_gene() |>
    filter(symbol == "TP53") |>
    inner_join(hs_go(), by = c("gene_id", "taxon_id")) |>
    select(symbol, go_id, go_term, evidence, category) |>
    collect()
```

OrgDb's `GOALL` (the ancestor closure over the GO DAG) needs
`ontology.relationship`, a table this package does not wrap — attach it
directly, as `bioc-on-ice`'s own README shows for cell types:

```r
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
")
```

That query is exactly what `GOALL`/`select(..., columns = "GOALL")` can
never return in one `AnnotationDbi` call — this package doesn't need to
invent an API for it, because the recursive CTE is already SQL.

## Connecting

```r
library(org.Hs.eg.ice)
hs_gene()   # opens the shared connection (ice_con()) on first use, anonymous, no token
```

Every accessor takes an explicit `con` argument if you want an independent
connection instead of the package's shared one:

```r
con <- connect_ice()
hs_gene(con)
disconnect_ice(con)
```

## Status

Skeleton only (`PlanFor3.24.md` Milestone 7's demo package). Not published,
not `R CMD check`ed against the live catalog yet. `tests/testthat/
test-accessors.R` has one live-catalog test (`skip`s cleanly if the catalog
is unreachable) and one offline signature check.
