test_that("accessors default to the shared connection, cache off", {
    for (fn in list(hs_gene, hs_alias, hs_go, hs_pubmed)) {
        expect_identical(names(formals(fn)), c("con", "cache"))
        expect_identical(deparse(formals(fn)$con), "ice_con()")
        expect_identical(formals(fn)$cache, FALSE)
    }
})

test_that("ice_cache_exists() is FALSE with no cache present", {
    withr::local_options(org.Hs.eg.ice.cache_dir = withr::local_tempdir())
    expect_false(ice_cache_exists())
})

test_that("cache accessors error before ice_cache_refresh() has run", {
    withr::local_options(org.Hs.eg.ice.cache_dir = withr::local_tempdir())
    expect_error(ice_cache_con(), "ice_cache_refresh")
    expect_error(hs_gene(cache = TRUE), "ice_cache_refresh")
})

test_that("live catalog: ice_cache_refresh() round-trips hs_gene()", {
    skip_on_cran()
    con <- tryCatch(connect_ice(), error = function(e) NULL)
    skip_if(is.null(con), "biocOnIce catalog unreachable")
    on.exit(disconnect_ice(con))

    withr::local_options(org.Hs.eg.ice.cache_dir = withr::local_tempdir())
    ice_cache_refresh(con)
    expect_true(ice_cache_exists())

    live  <- hs_gene(con) |> dplyr::filter(symbol == "TP53") |> dplyr::collect()
    cached <- hs_gene(cache = TRUE) |>
        dplyr::filter(symbol == "TP53") |> dplyr::collect()
    expect_equal(cached$gene_id, live$gene_id)

    ice_cache_clear()
    expect_false(ice_cache_exists())
})

test_that("live catalog: hs_gene() finds TP53", {
    skip_on_cran()
    con <- tryCatch(connect_ice(), error = function(e) NULL)
    skip_if(is.null(con), "biocOnIce catalog unreachable")
    on.exit(disconnect_ice(con))

    tp53 <- hs_gene(con) |>
        dplyr::filter(symbol == "TP53") |>
        dplyr::collect()

    expect_equal(nrow(tp53), 1)
    expect_equal(tp53$gene_id, "7157")
})
