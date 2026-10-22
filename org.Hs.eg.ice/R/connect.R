#' Connect to the public biocOnIce Iceberg catalog
#'
#' Opens an anonymous, read-only DuckDB connection with the biocOnIce catalog
#' `ATTACH`ed as `bioc`, served by icegate. No account or token is needed.
#'
#' @param endpoint icegate URL. Defaults to the public biocOnIce deployment.
#' @return A `DBI` connection with the catalog attached as `bioc`.
#' @export
connect_ice <- function(endpoint = "https://icegate-bioconice.seandavi.workers.dev") {
    con <- DBI::dbConnect(duckdb::duckdb())
    DBI::dbExecute(con, "INSTALL iceberg; LOAD iceberg;")
    DBI::dbExecute(con, sprintf(
        "ATTACH 'bioconice' AS bioc (TYPE ICEBERG, ENDPOINT '%s', AUTHORIZATION_TYPE 'none');",
        endpoint
    ))
    con
}

#' Disconnect from the catalog
#'
#' @param con a connection returned by `connect_ice()` or `ice_con()`.
#' @export
disconnect_ice <- function(con) {
    DBI::dbDisconnect(con, shutdown = TRUE)
}

.ice_env <- new.env(parent = emptyenv())

#' The package's shared connection
#'
#' Every accessor in this package (`hs_gene()`, `hs_alias()`, ...) takes a
#' `con` argument defaulting to this function, so a script that just wants to
#' query never has to call `connect_ice()` itself. The connection is opened on
#' first use and reused after that; call `connect_ice()` directly instead if
#' you want an independent connection (e.g. a second one pointed at a
#' different `endpoint`).
#'
#' @return A `DBI` connection with the catalog attached as `bioc`.
#' @export
ice_con <- function() {
    if (is.null(.ice_env$con) || !DBI::dbIsValid(.ice_env$con)) {
        .ice_env$con <- connect_ice()
    }
    .ice_env$con
}
