# Provisional implementation of PlanFor3.24.md Milestone 8: opt-in local
# caching of the four accessor tables, built on BiocFileCache. Nothing here
# runs unless `ice_cache_refresh()` is called explicitly -- every accessor
# stays live against biocOnIce by default (Milestone 7's ethos unchanged).
# This exists to demonstrate the latency difference a local cache makes;
# it is not the final design (see Milestone 8's open questions -- release
# tagging via provenance.release/resolve_release and the cross-table-
# atomicity caveat are not yet implemented here).

.ice_cache_rname <- "org.Hs.eg.ice_cache"

.ice_cache_dir <- function() {
    getOption("org.Hs.eg.ice.cache_dir",
              tools::R_user_dir("org.Hs.eg.ice", "cache"))
}

.ice_bfc <- function() {
    BiocFileCache::BiocFileCache(.ice_cache_dir(), ask = FALSE)
}

.ice_cache_rid <- function(bfc = .ice_bfc()) {
    hits <- BiocFileCache::bfcquery(bfc, .ice_cache_rname,
                                    field = "rname", exact = TRUE)
    hits$rid
}

#' Refresh the local cache from the live biocOnIce catalog
#'
#' Pulls `hs_gene()`, `hs_alias()`, `hs_go()`, `hs_pubmed()` in full
#' (`collect()`), writes them as tables in a local DuckDB file managed by
#' `BiocFileCache`, replacing any existing cache. This is the only function
#' in this package that writes to the cache -- call it again whenever you
#' want a fresher local copy; nothing refreshes it automatically, and
#' nothing calls it for you.
#'
#' Provisional: does not yet tag the cache with a `bioc-on-ice`
#' `provenance.release` identifier (`PlanFor3.24.md` Milestone 8).
#'
#' The new cache is built in a temporary file and only swapped in once every
#' table has been pulled and written successfully. If the refresh is
#' interrupted or errors partway through, the previous cache (if any) is left
#' exactly as it was -- `ice_cache_exists()` cannot report a half-written
#' cache, and no temporary file is left behind.
#'
#' `alias` (`hs_alias()`/`identifier_mapping`) is by far the largest of the
#' four tables -- on a real refresh it was ~6.6M rows and ~740s, versus well
#' under two minutes combined for the other three. Set `skip_alias = TRUE` to
#' leave it out of the refresh if you don't need cross-reference lookups;
#' `hs_alias(cache = TRUE)` then errors telling you to refresh without
#' skipping it.
#'
#' @param con a `DBI` connection to the live catalog; defaults to `ice_con()`.
#' @param skip_alias if `TRUE`, don't pull/cache the `alias` table -- it
#'   dominates refresh time and isn't needed for gene/GO/pubmed lookups.
#' @return The local cache file path (invisibly).
#' @examples
#' old <- getOption("org.Hs.eg.ice.cache_dir")
#' options(org.Hs.eg.ice.cache_dir = tempfile())
#' ice_cache_refresh(skip_alias = TRUE)
#' ice_cache_exists()
#' hs_gene(cache = TRUE) |> dplyr::filter(symbol == "TP53") |> dplyr::collect()
#' ice_cache_clear()
#' options(org.Hs.eg.ice.cache_dir = old)
#' @export
ice_cache_refresh <- function(con = ice_con(), skip_alias = FALSE) {
    bfc <- .ice_bfc()
    rid <- .ice_cache_rid(bfc)
    path <- if (length(rid) == 0L) {
        BiocFileCache::bfcnew(bfc, .ice_cache_rname, ext = "duckdb")
    } else {
        BiocFileCache::bfcrpath(bfc, rids = rid)
    }

    # Build the new cache in a temporary file next to the real one (so the
    # final rename is same-filesystem) and only replace `path` once every
    # table has been written -- an interrupted/failed refresh then leaves
    # the previous cache, if any, untouched and no temp file behind.
    tmp_path <- tempfile(pattern = "ice_cache_", tmpdir = dirname(path),
                          fileext = ".duckdb")
    cache_con <- DBI::dbConnect(duckdb::duckdb(), dbdir = tmp_path)
    finished <- FALSE
    on.exit({
        if (DBI::dbIsValid(cache_con)) {
            DBI::dbDisconnect(cache_con, shutdown = TRUE)
        }
        if (!finished && file.exists(tmp_path)) file.remove(tmp_path)
    }, add = TRUE)

    pull <- function(label, accessor) {
        message("org.Hs.eg.ice: pulling ", label, " ...")
        t0 <- proc.time()
        out <- dplyr::collect(accessor(con))
        message("org.Hs.eg.ice: ", label, " -- ", nrow(out), " rows in ",
                 round((proc.time() - t0)[["elapsed"]], 1), "s")
        out
    }

    tables <- list(
        gene   = pull("gene",   hs_gene),
        go     = pull("go",     hs_go),
        pubmed = pull("pubmed", hs_pubmed)
    )
    if (!skip_alias) tables$alias <- pull("alias", hs_alias)
    for (nm in names(tables)) {
        message("org.Hs.eg.ice: writing ", nm, " to local cache ...")
        DBI::dbWriteTable(cache_con, nm, tables[[nm]], overwrite = TRUE)
    }

    DBI::dbDisconnect(cache_con, shutdown = TRUE)
    if (file.exists(path)) file.remove(path)
    file.rename(tmp_path, path)
    finished <- TRUE

    message("org.Hs.eg.ice: local cache refreshed at ", path)
    invisible(path)
}

#' Does a local cache currently exist?
#'
#' @return `TRUE`/`FALSE`.
#' @examples
#' old <- getOption("org.Hs.eg.ice.cache_dir")
#' options(org.Hs.eg.ice.cache_dir = tempfile())
#' ice_cache_exists()
#' ice_cache_refresh(skip_alias = TRUE)
#' ice_cache_exists()
#' ice_cache_clear()
#' options(org.Hs.eg.ice.cache_dir = old)
#' @export
ice_cache_exists <- function() {
    rid <- .ice_cache_rid()
    length(rid) > 0L &&
        file.exists(BiocFileCache::bfcrpath(.ice_bfc(), rids = rid))
}

#' Open a connection to the local cache
#'
#' @return A read-only `DBI` connection to the local cache's DuckDB file.
#' @examples
#' old <- getOption("org.Hs.eg.ice.cache_dir")
#' options(org.Hs.eg.ice.cache_dir = tempfile())
#' ice_cache_refresh(skip_alias = TRUE)
#' con <- ice_cache_con()
#' DBI::dbListTables(con)
#' DBI::dbDisconnect(con, shutdown = TRUE)
#' ice_cache_clear()
#' options(org.Hs.eg.ice.cache_dir = old)
#' @export
ice_cache_con <- function() {
    if (!ice_cache_exists())
        stop("No local cache yet -- call ice_cache_refresh() first.",
             call. = FALSE)
    rid  <- .ice_cache_rid()
    path <- BiocFileCache::bfcrpath(.ice_bfc(), rids = rid)
    DBI::dbConnect(duckdb::duckdb(), dbdir = path, read_only = TRUE)
}

.ice_cache_require_table <- function(cache_con, table) {
    if (!(table %in% DBI::dbListTables(cache_con))) {
        hint <- if (identical(table, "alias")) {
            paste0(" -- it was skipped (ice_cache_refresh(skip_alias = TRUE)) ",
                   "or predates this option. Call ice_cache_refresh() ",
                   "without skip_alias = TRUE.")
        } else {
            paste0(" -- the local cache is missing or predates this table. ",
                   "Call ice_cache_refresh() again.")
        }
        stop("No '", table, "' table in the local cache", hint, call. = FALSE)
    }
    dplyr::tbl(cache_con, table)
}

#' Remove the local cache
#'
#' @return `TRUE`, invisibly.
#' @examples
#' old <- getOption("org.Hs.eg.ice.cache_dir")
#' options(org.Hs.eg.ice.cache_dir = tempfile())
#' ice_cache_refresh(skip_alias = TRUE)
#' ice_cache_clear()
#' ice_cache_exists()
#' options(org.Hs.eg.ice.cache_dir = old)
#' @export
ice_cache_clear <- function() {
    bfc <- .ice_bfc()
    rid <- .ice_cache_rid(bfc)
    if (length(rid) > 0L) BiocFileCache::bfcremove(bfc, rid)
    invisible(TRUE)
}
