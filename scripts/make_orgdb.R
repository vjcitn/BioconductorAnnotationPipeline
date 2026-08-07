## Build OrgDb packages for one or more species.
## Called by the top-level Makefile as:
##   Rscript scripts/make_orgdb.R --species "human mouse ..." \
##       --config config/species.tsv --db0path packages/db0/ \
##       --outdir packages/orgdb/
##
## For each species this script:
##   1. Calls populateDB() to produce org.<Prefix>.eg.sqlite in outdir
##   2. Calls makeAnnDbPkg() to wrap it into an installable R package tarball
##
## metaDataSrc: the schema/version metadata SQLite shipped inside AnnotationForge.

suppressPackageStartupMessages({
    library(AnnotationForge)
    library(AnnotationDbi)
})

## ── Parse args ───────────────────────────────────────────────────────────────
args <- commandArgs(trailingOnly = TRUE)

get_arg <- function(flag, args, default = NULL) {
    idx <- which(args == flag)
    if (length(idx) == 0L) return(default)
    args[idx + 1L]
}

species_str <- get_arg("--species", args)
config      <- get_arg("--config",  args, "config/species.tsv")
db0path     <- get_arg("--db0path", args, "packages/db0/")
outdir      <- get_arg("--outdir",  args, "packages/orgdb/")
dbpath      <- get_arg("--dbpath",  args, "db/")

if (is.null(species_str))
    stop("--species argument is required", call. = FALSE)

species <- strsplit(trimws(species_str), "\\s+")[[1]]
cat("Building OrgDb packages for:", paste(species, collapse = ", "), "\n")

## ── Read species config ───────────────────────────────────────────────────────
cfg <- read.table(config, header = TRUE, sep = "\t", stringsAsFactors = FALSE,
                  quote = "")

## ── Locate metaDataSrc shipped with AnnotationForge ──────────────────────────
meta_candidates <- c(
    system.file("extdata", "metadatasrc.sqlite", package = "AnnotationForge"),
    system.file("scripts", "GentlemanLab", "metadatasrc.sqlite",
                package = "AnnotationForge"),
    file.path(dbpath, "metadatasrc.sqlite")
)
metaDataSrc <- meta_candidates[file.exists(meta_candidates)][1]
if (is.na(metaDataSrc))
    stop("Cannot find metadatasrc.sqlite. Checked:\n",
         paste(" ", meta_candidates, collapse = "\n"), call. = FALSE)
cat("Using metaDataSrc:", metaDataSrc, "\n")

## ── Build packages ────────────────────────────────────────────────────────────
if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

sqlite_dir <- file.path(outdir, "sqlite")
if (!dir.exists(sqlite_dir)) dir.create(sqlite_dir)

pkg_names <- character(0)

for (sp in species) {
    row <- cfg[cfg$name == sp, ]
    if (nrow(row) == 0L) {
        warning("Species '", sp, "' not found in config — skipping", call. = FALSE)
        next
    }
    template  <- row$pkg_template
    prefix    <- row$pkg_prefix
    chip_src  <- file.path(dbpath, paste0("chipsrc_", sp, ".sqlite"))

    if (!file.exists(chip_src)) {
        warning("Missing ", chip_src, " — skipping ", sp, call. = FALSE)
        next
    }

    cat("\n── Building", prefix, ".db (template:", template, ") ──\n")
    tryCatch({
        populateDB(template,
                   prefix      = prefix,
                   chipSrc     = chip_src,
                   metaDataSrc = metaDataSrc,
                   outputDir   = sqlite_dir)
        pkg_names <- c(pkg_names, paste0(prefix, ".db"))
    }, error = function(e) {
        warning("populateDB failed for ", sp, ": ", conditionMessage(e),
                call. = FALSE)
    })
}

if (length(pkg_names) == 0L)
    stop("No packages were produced successfully.", call. = FALSE)

cat("\nBuilding R package tarballs for:", paste(pkg_names, collapse = ", "), "\n")
makeAnnDbPkg(x = pkg_names, dest_dir = outdir)

built <- list.files(outdir, pattern = "\\.tar\\.gz$")
cat("OrgDb packages built:\n")
cat(paste(" ", built, collapse = "\n"), "\n")
