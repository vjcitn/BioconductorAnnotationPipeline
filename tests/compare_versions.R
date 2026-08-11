#!/usr/bin/env Rscript
## Compare two installed versions of an OrgDb package to verify that key
## select() and mapIds() operations are consistent across rebuilds.
##
## Usage:
##   Rscript tests/compare_versions.R <pkg> <lib1> <lib2>
##
## Example:
##   Rscript tests/compare_versions.R org.Hs.eg.db /tmp/lib_old /tmp/lib_new
##
## Both libraries must have the package installed. The script reports any
## differences in key lookups rather than requiring exact equality of all
## rows (gene counts may differ across NCBI release dates).

suppressPackageStartupMessages({
    library(AnnotationDbi)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3L)
    stop("Usage: compare_versions.R <pkg> <lib1> <lib2>", call. = FALSE)

pkg  <- args[1L]
lib1 <- args[2L]
lib3 <- args[3L]   # named lib3 internally to avoid collision with lib1

cat("Comparing", pkg, "\n")
cat("  lib1:", lib1, "\n")
cat("  lib2:", lib3, "\n\n")

pass <- 0L
fail <- 0L

check <- function(label, ok) {
    if (isTRUE(ok)) {
        cat("  PASS ", label, "\n")
        pass <<- pass + 1L
    } else {
        cat("  FAIL ", label, "\n")
        fail <<- fail + 1L
    }
}

note <- function(label) cat("  NOTE ", label, "\n")

## Load both instances under different names
db1 <- tryCatch(
    loadDb(system.file("extdata", paste0(sub("\\.db$","",pkg), ".sqlite"),
                       package = pkg, lib.loc = lib1)),
    error = function(e) stop("Cannot load from lib1: ", e$message, call. = FALSE))

db2 <- tryCatch(
    loadDb(system.file("extdata", paste0(sub("\\.db$","",pkg), ".sqlite"),
                       package = pkg, lib.loc = lib3)),
    error = function(e) stop("Cannot load from lib2: ", e$message, call. = FALSE))

## ── 1. columns() consistency ──────────────────────────────────────────────────
cat("--- 1. columns() ---\n")
cols1 <- sort(columns(db1))
cols2 <- sort(columns(db2))

only1 <- setdiff(cols1, cols2)
only2 <- setdiff(cols2, cols1)

if (length(only1) == 0L && length(only2) == 0L) {
    check("columns() identical", TRUE)
} else {
    if (length(only1)) note(paste("only in lib1:", paste(only1, collapse=", ")))
    if (length(only2)) note(paste("only in lib2:", paste(only2, collapse=", ")))
    check("columns() identical", FALSE)
}

## ── 2. Gene count ─────────────────────────────────────────────────────────────
cat("\n--- 2. Gene count ---\n")
n1 <- length(keys(db1, keytype = "ENTREZID"))
n2 <- length(keys(db2, keytype = "ENTREZID"))
cat(sprintf("  lib1: %d genes   lib2: %d genes\n", n1, n2))
pct_diff <- abs(n1 - n2) / max(n1, n2) * 100
if (pct_diff == 0) {
    check("Gene counts identical", TRUE)
} else if (pct_diff < 5) {
    note(sprintf("Gene counts differ by %.1f%% — likely different NCBI release dates", pct_diff))
} else {
    check(sprintf("Gene counts within 5%% (%.1f%% difference)", pct_diff), FALSE)
}

## ── 3. Landmark gene spot checks ─────────────────────────────────────────────
cat("\n--- 3. Landmark gene spot checks ---\n")

landmark_genes <- list(
    list(id = "7157",  symbol = "TP53",  col = "SYMBOL"),
    list(id = "672",   symbol = "BRCA1", col = "SYMBOL"),
    list(id = "1956",  symbol = "EGFR",  col = "SYMBOL")
)

for (g in landmark_genes) {
    r1 <- tryCatch(
        mapIds(db1, keys = g$id, column = g$col, keytype = "ENTREZID"),
        error = function(e) NA_character_)
    r2 <- tryCatch(
        mapIds(db2, keys = g$id, column = g$col, keytype = "ENTREZID"),
        error = function(e) NA_character_)
    check(sprintf("gene %s %s: lib1=%s lib2=%s", g$id, g$col, r1, r2),
          identical(r1, r2) && !is.na(r1))
}

## ── 4. select() consistency on landmark genes ────────────────────────────────
cat("\n--- 4. select() on landmark genes ---\n")

test_cols <- intersect(c("SYMBOL","GENENAME","REFSEQ","GO","UNIPROT","PFAM"),
                       intersect(cols1, cols2))

landmark_ids <- c("7157", "672", "1956")

for (col in test_cols) {
    r1 <- tryCatch(
        select(db1, keys = landmark_ids, columns = col, keytype = "ENTREZID"),
        error = function(e) NULL)
    r2 <- tryCatch(
        select(db2, keys = landmark_ids, columns = col, keytype = "ENTREZID"),
        error = function(e) NULL)

    if (is.null(r1) || is.null(r2)) {
        note(paste(col, "— query failed in one or both libs"))
        next
    }

    ## Compare as sorted sets (order may differ)
    s1 <- sort(unique(paste(r1[[1L]], r1[[2L]])))
    s2 <- sort(unique(paste(r2[[1L]], r2[[2L]])))
    only_r1 <- setdiff(s1, s2)
    only_r2 <- setdiff(s2, s1)

    if (length(only_r1) == 0L && length(only_r2) == 0L) {
        check(paste(col, "rows identical for landmark genes"), TRUE)
    } else {
        n_diff <- length(only_r1) + length(only_r2)
        note(sprintf("%s: %d row(s) differ (lib1 only: %d, lib2 only: %d)",
                     col, n_diff, length(only_r1), length(only_r2)))
        if (length(only_r1) && length(only_r1) <= 5)
            note(paste("  lib1 only:", paste(head(only_r1, 5), collapse="; ")))
        if (length(only_r2) && length(only_r2) <= 5)
            note(paste("  lib2 only:", paste(head(only_r2, 5), collapse="; ")))
        check(paste(col, "rows identical for landmark genes"), FALSE)
    }
}

## ── 5. mapIds() reproducibility ───────────────────────────────────────────────
cat("\n--- 5. mapIds() reproducibility ---\n")

map_tests <- list(
    list(keys = "7157",   from = "ENTREZID", to = "UNIPROT"),
    list(keys = "TP53",   from = "SYMBOL",   to = "ENTREZID"),
    list(keys = "P04637", from = "UNIPROT",  to = "SYMBOL")
)

for (t in map_tests) {
    if (!t$from %in% cols1 || !t$to %in% cols1) {
        note(paste(t$from, "->", t$to, "not in columns() — skipped"))
        next
    }
    r1 <- tryCatch(
        sort(mapIds(db1, keys = t$keys, column = t$to,
                    keytype = t$from, multiVals = "list")[[1L]]),
        error = function(e) NA_character_)
    r2 <- tryCatch(
        sort(mapIds(db2, keys = t$keys, column = t$to,
                    keytype = t$from, multiVals = "list")[[1L]]),
        error = function(e) NA_character_)
    check(sprintf("mapIds %s->%s for '%s'", t$from, t$to, t$keys),
          identical(r1, r2))
}

## ── Summary ───────────────────────────────────────────────────────────────────
cat(sprintf("\n=== Results: %d passed, %d failed ===\n", pass, fail))
if (fail > 0L) {
    cat("Versions differ in the checks above.\n")
    quit(status = 1L)
}
