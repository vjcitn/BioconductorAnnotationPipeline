# Thin dplyr accessors over the biocOnIce catalog, scoped to human (taxon
# 9606). Each one returns a lazy table: a `filter()` to the current taxon and
# to current (non-retired) rows, nothing else. All the actual query work --
# which columns, which joins, which further filters -- is left to the caller,
# same as any other dplyr/dbplyr table. See PlanFor3.24.md Milestone 7: the
# point of this package is that it adds no query surface of its own.

HS_TAXON <- 9606L

#' Human genes
#'
#' `annotation.ncbi__gene`, filtered to human and to currently-valid rows.
#' Columns: `gene_id` (Entrez GeneID, OrgDb's `ENTREZID`), `symbol`,
#' `description` (OrgDb's `GENENAME`), `gene_type` (OrgDb's `GENETYPE`),
#' `chromosome` (OrgDb's `CHR`), `map_location` (OrgDb's `MAP`).
#'
#' @param con a `DBI` connection; defaults to the package's shared
#'   connection, `ice_con()`.
#' @param cache if `TRUE`, read from the local cache (`ice_cache_refresh()`)
#'   instead of the live catalog; `con` is ignored. Errors if no cache
#'   exists yet. See `ice_cache_refresh()` -- provisional, Milestone 8.
#' @return A lazy `dplyr` table.
#' @examples
#' hs_gene() |> dplyr::filter(symbol == "TP53") |> dplyr::collect()
#' @export
hs_gene <- function(con = ice_con(), cache = FALSE) {
    if (cache) return(.ice_cache_require_table(ice_cache_con(), "gene"))
    dplyr::tbl(con, "bioc.annotation.ncbi__gene") |>
        dplyr::filter(taxon_id == HS_TAXON, is.na(valid_to))
}

#' Human gene synonyms and cross-references
#'
#' `annotation.identifier_mapping`, filtered to human and to currently-valid
#' rows. Not just `ALIAS`: every cross-reference namespace NCBI and Ensembl
#' assert (`ENSEMBL`, `HGNC`, `MIM`, ...) is a row here, discriminated by
#' `source_namespace`/`target_namespace` -- filter further for a specific one,
#' e.g. `dplyr::filter(target_namespace == "ALIAS")` for OrgDb's `ALIAS`
#' keytype.
#'
#' @inheritParams hs_gene
#' @return A lazy `dplyr` table.
#' @examples
#' hs_alias() |>
#'     dplyr::filter(source_id == "7157", target_namespace == "ALIAS") |>
#'     dplyr::collect()
#' @export
hs_alias <- function(con = ice_con(), cache = FALSE) {
    if (cache) return(.ice_cache_require_table(ice_cache_con(), "alias"))
    dplyr::tbl(con, "bioc.annotation.identifier_mapping") |>
        dplyr::filter(taxon_id == HS_TAXON, is.na(valid_to))
}

#' Human direct GO annotations
#'
#' `annotation.ncbi__gene_go`, filtered to human and to currently-valid rows.
#' Columns: `gene_id`, `go_id`, `evidence` (OrgDb's `EVIDENCE`), `qualifier`,
#' `go_term`, `category` (OrgDb's `ONTOLOGY`, spelled Function/Process/
#' Component). Direct annotations only -- joining `ontology.relationship` for
#' the `is_a` closure gets you OrgDb's `GOALL`; see the package README.
#'
#' @inheritParams hs_gene
#' @return A lazy `dplyr` table.
#' @examples
#' hs_go() |> dplyr::filter(gene_id == "7157") |> dplyr::collect()
#' @export
hs_go <- function(con = ice_con(), cache = FALSE) {
    if (cache) return(.ice_cache_require_table(ice_cache_con(), "go"))
    dplyr::tbl(con, "bioc.annotation.ncbi__gene_go") |>
        dplyr::filter(taxon_id == HS_TAXON, is.na(valid_to))
}

#' Human gene-to-publication links
#'
#' `annotation.ncbi__gene_pubmed`, filtered to human and to currently-valid
#' rows. Columns: `gene_id`, `pubmed_id` (OrgDb's `PMID`).
#'
#' @inheritParams hs_gene
#' @return A lazy `dplyr` table.
#' @examples
#' hs_pubmed() |> dplyr::filter(gene_id == "7157") |> dplyr::collect()
#' @export
hs_pubmed <- function(con = ice_con(), cache = FALSE) {
    if (cache) return(.ice_cache_require_table(ice_cache_con(), "pubmed"))
    dplyr::tbl(con, "bioc.annotation.ncbi__gene_pubmed") |>
        dplyr::filter(taxon_id == HS_TAXON, is.na(valid_to))
}
