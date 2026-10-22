## Diagnose the "no such table: ensembl" gap reported for org.Ag.eg.db,
## org.Ce.eg.db, org.Dm.eg.db, org.EcK12.eg.db, org.EcSakai.eg.db,
## org.Ss.eg.db, org.Xl.eg.db.
##
## Two questions this answers, per species:
##   1. Does chipsrc_<species>.sqlite actually have a populated `ensembl`
##      table (and the related ensembl_pro/ensembl_trs)? If it's present but
##      empty, make_orgdb.R's optional-frame logic (nrow(opt[[nm]]) > 0L)
##      is why the final package never gets the table -- not a bug in the
##      extraction SQL itself, which is identical across species.
##   2. If genesrc.sqlite is available, what dbXref prefixes actually exist
##      for this species' genes? The working hypothesis is that NCBI's
##      gene_info dbXref field for these organisms carries FlyBase/WormBase/
##      VectorBase/EcoGene/Xenbase-prefixed IDs rather than "Ensembl:"-
##      prefixed ones, which would make the 'Ensembl:' LIKE filter in
##      bindb_<species>.sql correctly find zero rows -- a real data
##      characteristic, not a pipeline bug.
##
## Usage (from repo root):
##   Rscript scripts/diagnose_ensembl_gap.R --dbpath db/
##   Rscript scripts/diagnose_ensembl_gap.R --dbpath db/ --species fly worm anopheles ecoliK12 ecoliSakai pig xenopus
##
## With no --species, every chipsrc_*.sqlite found under --dbpath is checked.

suppressPackageStartupMessages({
    library(DBI)
    library(RSQLite)
})

args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(flag, args, default = NULL) {
    idx <- which(args == flag)
    if (length(idx) == 0L) return(default)
    ## collect all non-flag tokens following `flag` up to the next `--...`
    rest <- args[(idx + 1L):length(args)]
    stop_at <- which(startsWith(rest, "--"))
    end <- if (length(stop_at) == 0L) length(rest) else stop_at[1L] - 1L
    if (end < 1L) return(default)
    rest[seq_len(end)]
}

dbpath  <- get_arg("--dbpath", args, "db/")[1L]
species <- get_arg("--species", args, NULL)
genesrc_override <- get_arg("--genesrc", args, NULL)[1L]

config_path <- "config/species.tsv"
cfg <- if (file.exists(config_path)) {
    read.delim(config_path, stringsAsFactors = FALSE)
} else {
    NULL
}

if (is.null(species)) {
    chip_files <- list.files(dbpath, pattern = "^chipsrc_.*\\.sqlite$")
    species <- sub("^chipsrc_", "", sub("\\.sqlite$", "", chip_files))
}
if (length(species) == 0L) {
    stop("No chipsrc_*.sqlite found under ", dbpath,
         " and no --species given.", call. = FALSE)
}

cat(sprintf("Found %d species to check: %s\n\n",
            length(species), paste(species, collapse = ", ")))

table_rowcount <- function(con, table) {
    exists <- tryCatch(
        DBI::dbExistsTable(con, table),
        error = function(e) FALSE)
    if (!exists) return(NA_integer_)
    tryCatch(
        DBI::dbGetQuery(con, sprintf("SELECT count(*) AS n FROM %s", table))$n,
        error = function(e) NA_integer_)
}

fmt_n <- function(n) {
    if (is.na(n)) "absent" else as.character(n)
}

genesrc_path <- if (!is.null(genesrc_override)) genesrc_override else file.path(dbpath, "genesrc.sqlite")
have_genesrc <- file.exists(genesrc_path)
if (!have_genesrc)
    cat("NOTE  genesrc.sqlite not found at", genesrc_path,
        "-- pass --genesrc <path> to point at the real one\n\n")
genesrc_con  <- if (have_genesrc) dbConnect(SQLite(), genesrc_path, flags = SQLITE_RO) else NULL
if (have_genesrc) on.exit(dbDisconnect(genesrc_con), add = TRUE)

optional_tables <- c("ensembl", "ensembl_pro", "ensembl_trs",
                      "gene_synonyms", "genetype",
                      "cytogenetic_locations", "chromosome_locations",
                      "uniprot")

for (sp in species) {
    chip_path <- file.path(dbpath, paste0("chipsrc_", sp, ".sqlite"))
    cat("===", sp, "===\n")
    if (!file.exists(chip_path)) {
        cat("  chipsrc not found:", chip_path, "-- skipped\n\n")
        next
    }

    con <- dbConnect(SQLite(), chip_path, flags = SQLITE_RO)
    on.exit(dbDisconnect(con), add = TRUE)

    n_genes <- table_rowcount(con, "genes")
    cat(sprintf("  genes: %s\n", fmt_n(n_genes)))

    for (tbl in optional_tables) {
        n <- table_rowcount(con, tbl)
        flag <- if (is.na(n)) "  [NO TABLE]"
                else if (n == 0L) "  [TABLE PRESENT, 0 ROWS]"
                else ""
        cat(sprintf("  %-22s %8s%s\n", tbl, fmt_n(n), flag))
    }

    dbDisconnect(con)

    ## dbXref prefix distribution from genesrc, if available and species is
    ## in config/species.tsv (need taxid to filter genesrc's genes table).
    if (have_genesrc && !is.null(cfg)) {
        row <- cfg[cfg$name == sp, ]
        if (nrow(row) == 1L) {
            taxid <- row$taxid[1L]
            has_dbxref <- tryCatch(
                DBI::dbExistsTable(genesrc_con, "gene_dbXref"),
                error = function(e) FALSE)
            has_genesrc_genes <- tryCatch(
                DBI::dbExistsTable(genesrc_con, "gene_info"),
                error = function(e) FALSE)
            if (has_dbxref && has_genesrc_genes) {
                qry <- sprintf(
                    "SELECT substr(x.dbXref, 1, instr(x.dbXref, ':') - 1) AS prefix,
                            count(*) AS n
                     FROM gene_dbXref x
                     JOIN gene_info g ON g.gene_id = x.gene_id
                     WHERE g.tax_id = %s AND x.dbXref != '-' AND instr(x.dbXref, ':') > 0
                     GROUP BY prefix
                     ORDER BY n DESC
                     LIMIT 10", taxid)
                prefixes <- tryCatch(
                    dbGetQuery(genesrc_con, qry),
                    error = function(e) NULL)
                if (!is.null(prefixes) && nrow(prefixes) > 0L) {
                    cat("  dbXref prefixes (taxid", taxid, "), top 10:\n")
                    for (i in seq_len(nrow(prefixes)))
                        cat(sprintf("    %-15s %d\n", prefixes$prefix[i], prefixes$n[i]))
                } else {
                    cat("  NOTE  no dbXref rows found in genesrc for taxid", taxid, "\n")
                }
            } else {
                cat("  NOTE  genesrc.sqlite missing gene_dbXref/gene_info table -- skipping prefix check\n")
            }
        } else {
            cat("  NOTE  species not found in", config_path, "-- skipping dbXref prefix check\n")
        }
    } else if (!have_genesrc) {
        cat("  NOTE  genesrc.sqlite not found at", genesrc_path, "-- skipping dbXref prefix check\n")
    }

    cat("\n")
}
