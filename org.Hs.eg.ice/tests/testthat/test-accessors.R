test_that("accessors default to the shared connection", {
    for (fn in list(hs_gene, hs_alias, hs_go, hs_pubmed)) {
        expect_identical(names(formals(fn)), "con")
        expect_identical(deparse(formals(fn)$con), "ice_con()")
    }
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
