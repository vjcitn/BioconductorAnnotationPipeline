## Pipeline validation: verify a built OrgDb package against its source SQLites.
##
## Usage (from repo root):
##   Rscript tests/check_orgdb.R \
##       --species  human \
##       --dbpath   db/ \
##       --tarball  packages/orgdb/org.Hs.eg.db_3.24.0.tar.gz
##
## Installs the tarball to a temp library, loads the package, then runs
## three layers of checks:
##   1. Structural   — expected columns present, metadata correct
##   2. Consistency  — package counts match chipsrc (ground truth)
##   3. Integrity    — referential consistency across tables
##   4. Spot checks  — landmark genes from tests/known_genes.tsv
##
## Exit code 0 = all tests passed; non-zero = failures present.

suppressPackageStartupMessages({
    library(AnnotationDbi)
    library(DBI)
    library(RSQLite)
})

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0L || is.na(x[1L])) y else x

## ── Argument parsing ──────────────────────────────────────────────────────────
args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(flag, args, default = NULL) {
    idx <- which(args == flag)
    if (length(idx) == 0L) return(default)
    args[idx + 1L]
}

sp      <- get_arg("--species", args)
dbpath  <- get_arg("--dbpath",  args, "db/")
tarball <- get_arg("--tarball", args)

if (is.null(sp))      stop("--species required", call. = FALSE)
if (is.null(tarball)) stop("--tarball required",  call. = FALSE)
if (!file.exists(tarball)) stop("Tarball not found: ", tarball, call. = FALSE)

chip_path <- file.path(dbpath, paste0("chipsrc_", sp, ".sqlite"))
if (!file.exists(chip_path))
    stop("chipsrc not found: ", chip_path, call. = FALSE)

## ── Simple test harness ───────────────────────────────────────────────────────
pass_count <- 0L
fail_count <- 0L
failures   <- character(0)

check <- function(label, expr) {
    result <- tryCatch(isTRUE(expr), error = function(e) FALSE)
    if (result) {
        cat(sprintf("  PASS  %s\n", label))
        pass_count <<- pass_count + 1L
    } else {
        cat(sprintf("  FAIL  %s\n", label))
        fail_count <<- fail_count + 1L
        failures   <<- c(failures, label)
    }
}

check_near <- function(label, got, expected, tol = 0.01) {
    ## passes if |got - expected| / expected <= tol
    result <- tryCatch(
        abs(got - expected) / max(expected, 1L) <= tol,
        error = function(e) FALSE
    )
    if (result) {
        cat(sprintf("  PASS  %s  [%d vs %d]\n", label, got, expected))
        pass_count <<- pass_count + 1L
    } else {
        cat(sprintf("  FAIL  %s  [got %d, expected ~%d]\n", label, got, expected))
        fail_count <<- fail_count + 1L
        failures   <<- c(failures, label)
    }
}

## ── Install tarball to temp library ──────────────────────────────────────────
cat("\n=== Installing", basename(tarball), "(may take a minute for large SQLite) ===\n")
t0 <- proc.time()
tmp_lib <- tempfile("orgdb_check_lib")
dir.create(tmp_lib)
on.exit(unlink(tmp_lib, recursive = TRUE), add = TRUE)

install.packages(tarball, lib = tmp_lib, repos = NULL, type = "source",
                 quiet = TRUE)
cat(sprintf("  installed in %.0f s\n", (proc.time() - t0)[["elapsed"]]))

pkg_name <- sub("_.*\\.tar\\.gz$", "", basename(tarball))
suppressPackageStartupMessages(
    library(pkg_name, lib.loc = tmp_lib, character.only = TRUE)
)
org <- get(pkg_name)
cat("Loaded:", pkg_name, "\n")

## ── Open chipsrc for ground-truth queries ─────────────────────────────────────
cat("Opening chipsrc:", basename(chip_path), "\n")
chip <- dbConnect(SQLite(), chip_path)
on.exit(dbDisconnect(chip), add = TRUE)

## ── 1. STRUCTURAL CHECKS ─────────────────────────────────────────────────────
cat("\n--- 1. Structural checks ---\n")

## CHROMOSOME/CHRLOC/CHRLOCEND are in the package but not exposed via columns()
## under the HUMAN_DB schema — they are accessed via eg.CHRLOC-style objects.
required_cols <- c("ENTREZID","SYMBOL","GENENAME","ALIAS","REFSEQ",
                   "GO","GOALL","EVIDENCE","EVIDENCEALL",
                   "ONTOLOGY","ONTOLOGYALL",
                   "MAP","PMID","ACCNUM","GENETYPE")
pkg_cols <- tryCatch(columns(org), error = function(e) character(0))

for (col in required_cols) {
    check(paste0("columns() contains ", col), col %in% pkg_cols)
}

## Metadata
meta_val <- function(key) {
    tryCatch({
        conn <- AnnotationDbi::dbconn(org)
        res  <- DBI::dbGetQuery(conn,
            paste0("SELECT value FROM metadata WHERE name='", key, "'"))
        res[[1L]]
    }, error = function(e) NA_character_)
}
check("ORGANISM metadata is not empty",    nzchar(meta_val("ORGANISM") %||% ""))
check("DBSCHEMA is not NOSCHEMA_DB",       meta_val("DBSCHEMA") != "NOSCHEMA_DB")
check("CENTRALID is EG (not GID)",         meta_val("CENTRALID") == "EG")
check("EGSOURCEDATE is present",           nzchar(meta_val("EGSOURCEDATE") %||% ""))

## ── 2. COUNT CONSISTENCY ─────────────────────────────────────────────────────
cat("\n--- 2. Count consistency (package vs chipsrc) ---\n")

cat("  querying chipsrc gene count ...\n")
n_chip_genes <- dbGetQuery(chip, "SELECT count(*) FROM genes")[[1L]]

## Use direct SQL on the package sqlite — AnnotationDbi method dispatch
## via keys()/select() can fail in temp-lib context.
org_conn <- tryCatch(AnnotationDbi::dbconn(org), error = function(e) NULL)
if (is.null(org_conn))
    stop("Cannot open package sqlite connection — package did not load correctly",
         call. = FALSE)

cat("  querying package gene count ...\n")
n_pkg_genes <- tryCatch(
    dbGetQuery(org_conn, "SELECT count(*) FROM genes")[[1L]],
    error = function(e) -1L)
check_near("gene count matches chipsrc", n_pkg_genes, n_chip_genes, tol = 0)

cat("  querying chipsrc GO row count ...\n")
n_chip_go <- dbGetQuery(chip,
    "SELECT count(*) FROM (
       SELECT _id,go_id,evidence FROM go_bp
       UNION ALL SELECT _id,go_id,evidence FROM go_mf
       UNION ALL SELECT _id,go_id,evidence FROM go_cc)")[[1L]]

cat("  querying package GO row count ...\n")
n_pkg_go <- if (!is.null(org_conn)) {
    tryCatch(dbGetQuery(org_conn,
        "SELECT count(*) FROM (
           SELECT _id,go_id,evidence FROM go_bp
           UNION ALL SELECT _id,go_id,evidence FROM go_mf
           UNION ALL SELECT _id,go_id,evidence FROM go_cc)")[[1L]],
        error = function(e) -1L)
} else { -1L }
check_near("GO direct annotation rows match chipsrc", n_pkg_go, n_chip_go, tol = 0)

cat("  querying GOALL row count ...\n")
n_pkg_goall <- if (!is.null(org_conn)) {
    tryCatch(dbGetQuery(org_conn,
        "SELECT count(*) FROM (
           SELECT _id,go_id,evidence FROM go_bp_all
           UNION ALL SELECT _id,go_id,evidence FROM go_mf_all
           UNION ALL SELECT _id,go_id,evidence FROM go_cc_all)")[[1L]],
        error = function(e) 0L)
} else { 0L }
check("GOALL has more rows than GO (ancestors propagated)",
      n_pkg_goall > n_pkg_go)

cat("  querying GO coverage ...\n")
n_genes_with_go <- if (!is.null(org_conn)) {
    tryCatch({
        r <- dbGetQuery(org_conn,
            "SELECT count(DISTINCT _id) AS n FROM go_bp
             UNION ALL SELECT count(DISTINCT _id) FROM go_mf
             UNION ALL SELECT count(DISTINCT _id) FROM go_cc")
        max(r$n)
    }, error = function(e) 0L)
} else { 0L }
## Use chipsrc gene count as safe denominator (pkg count may be -1 on error)
denom  <- if (n_pkg_genes > 0L) n_pkg_genes else n_chip_genes
pct_go <- round(100 * n_genes_with_go / max(denom, 1L))
check(sprintf(">=20%% of genes have GO annotations (%d%%)", pct_go), pct_go >= 20L)

## ── 3. REFERENTIAL INTEGRITY ─────────────────────────────────────────────────
cat("\n--- 3. Referential integrity (chipsrc) ---\n")
cat("  checking go_bp orphans ...\n")
orphan_go_bp <- tryCatch(
    dbGetQuery(chip,
        "SELECT count(*) FROM go_bp
         WHERE _id NOT IN (SELECT _id FROM genes)")[[1L]],
    error = function(e) -1L)
check("go_bp: no orphan _ids (all reference genes table)", orphan_go_bp == 0L)

orphan_go_mf <- tryCatch(
    dbGetQuery(chip,
        "SELECT count(*) FROM go_mf
         WHERE _id NOT IN (SELECT _id FROM genes)")[[1L]],
    error = function(e) -1L)
check("go_mf: no orphan _ids", orphan_go_mf == 0L)

orphan_go_cc <- tryCatch(
    dbGetQuery(chip,
        "SELECT count(*) FROM go_cc
         WHERE _id NOT IN (SELECT _id FROM genes)")[[1L]],
    error = function(e) -1L)
check("go_cc: no orphan _ids", orphan_go_cc == 0L)

## Every gene_id in package exists in genesrc (spot-check via chipsrc metadata)
## chipsrc genes come from genesrc filtered by taxid — verify taxid is present
taxid_in_meta <- tryCatch(
    dbGetQuery(chip, "SELECT value FROM metadata WHERE name='TAXID'")[[1L]],
    error = function(e) "")
check("chipsrc metadata contains TAXID", nzchar(taxid_in_meta))

## chromosome_locations _ids all in genes
orphan_chrloc <- tryCatch(
    dbGetQuery(chip,
        "SELECT count(*) FROM chromosome_locations
         WHERE _id NOT IN (SELECT _id FROM genes)")[[1L]],
    error = function(e) -1L)
check("chromosome_locations: no orphan _ids", orphan_chrloc == 0L)

## uniprot _ids all in genes (if table non-empty)
n_uniprot <- tryCatch(
    dbGetQuery(chip, "SELECT count(*) FROM uniprot")[[1L]],
    error = function(e) 0L)
if (n_uniprot > 0L) {
    orphan_uni <- dbGetQuery(chip,
        "SELECT count(*) FROM uniprot WHERE _id NOT IN (SELECT _id FROM genes)")[[1L]]
    check("uniprot: no orphan _ids", orphan_uni == 0L)
    pct_uni <- round(100 * dbGetQuery(chip,
        "SELECT count(DISTINCT _id) FROM uniprot")[[1L]] / max(n_chip_genes, 1L))
    ## ~10% expected: human has ~193k gene IDs but only ~20k protein-coding
    ## genes have UniProt entries; ncRNA/pseudogenes have no UniProt mappings.
    check(sprintf(">=5%% of genes have UniProt mapping (%d%%)", pct_uni), pct_uni >= 5L)
} else {
    cat("  NOTE  uniprot table empty — UniProt provider not yet run\n")
}

## ── 4. SPOT CHECKS ───────────────────────────────────────────────────────────
cat("\n--- 4. Spot checks (known landmark genes) ---\n")

known_file <- "tests/known_genes.tsv"

if (file.exists(known_file)) {
    known <- read.table(known_file, header = TRUE, sep = "\t",
                        stringsAsFactors = FALSE, quote = "")
    sp_known <- known[known$species == sp, ]

    if (nrow(sp_known) > 0L) {
        for (i in seq_len(nrow(sp_known))) {
            row <- sp_known[i, ]
            gid <- as.character(row$gene_id)

            ## All spot checks query the package sqlite directly (bypasses
            ## AnnotationDbi method dispatch which can fail in temp-lib context)

            ## Symbol
            sym <- tryCatch(dbGetQuery(org_conn, sprintf(
                "SELECT gi.symbol FROM genes g
                 JOIN gene_info gi ON g._id = gi._id
                 WHERE g.gene_id = '%s'", gid))[[1L]][1L],
                error = function(e) NA_character_)
            check(sprintf("gene %s SYMBOL == %s", gid, row$symbol),
                  isTRUE(sym == row$symbol))

            ## GENENAME contains expected substring
            gname <- tryCatch(dbGetQuery(org_conn, sprintf(
                "SELECT gi.gene_name FROM genes g
                 JOIN gene_info gi ON g._id = gi._id
                 WHERE g.gene_id = '%s'", gid))[[1L]][1L],
                error = function(e) NA_character_)
            check(sprintf("gene %s GENENAME contains '%s'", gid, row$genename_contains),
                  isTRUE(grepl(row$genename_contains, gname, ignore.case = TRUE)))

            ## UniProt
            if (nzchar(row$uniprot %||% "")) {
                uni <- tryCatch(dbGetQuery(org_conn, sprintf(
                    "SELECT u.uniprot_id FROM genes g
                     JOIN uniprot u ON g._id = u._id
                     WHERE g.gene_id = '%s'", gid))[[1L]],
                    error = function(e) character(0))
                check(sprintf("gene %s has UniProt %s", gid, row$uniprot),
                      row$uniprot %in% uni)
            }

            ## GO term present (check direct annotations only)
            if (nzchar(row$go_id %||% "")) {
                go_res <- tryCatch(dbGetQuery(org_conn, sprintf(
                    "SELECT go_id FROM go_bp
                       WHERE _id = (SELECT _id FROM genes WHERE gene_id='%s')
                         AND go_id = '%s'
                     UNION
                     SELECT go_id FROM go_mf
                       WHERE _id = (SELECT _id FROM genes WHERE gene_id='%s')
                         AND go_id = '%s'
                     UNION
                     SELECT go_id FROM go_cc
                       WHERE _id = (SELECT _id FROM genes WHERE gene_id='%s')
                         AND go_id = '%s'",
                    gid, row$go_id, gid, row$go_id, gid, row$go_id))[[1L]],
                    error = function(e) character(0))
                check(sprintf("gene %s has GO term %s", gid, row$go_id),
                      row$go_id %in% go_res)
            }
        }
    } else {
        cat("  NOTE  no known_genes entries for species:", sp, "\n")
    }
} else {
    cat("  NOTE  tests/known_genes.tsv not found — skipping spot checks\n")
}

## ── Summary ───────────────────────────────────────────────────────────────────
cat(sprintf("\n=== Results: %d passed, %d failed ===\n", pass_count, fail_count))
if (fail_count > 0L) {
    cat("Failed checks:\n")
    cat(paste0("  - ", failures, collapse = "\n"), "\n")
    quit(status = 1L)
}

