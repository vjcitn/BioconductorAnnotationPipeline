## Build db0 packages for one or more species.
## Called by the top-level Makefile as:
##   Rscript scripts/make_db0.R --species "human mouse ..." \
##       --dbpath db/ --config config/species.tsv --outdir packages/db0/
##
## wrapBaseDBPackages() scans dbPath for chipsrc_*.sqlite files and builds
## one db0 package per file. It only processes files that actually exist,
## so a subset species run works without any special casing.

suppressPackageStartupMessages({
    library(AnnotationForge)
})

## ── Parse args ───────────────────────────────────────────────────────────────
args <- commandArgs(trailingOnly = TRUE)

get_arg <- function(flag, args, default = NULL) {
    idx <- which(args == flag)
    if (length(idx) == 0L) return(default)
    args[idx + 1L]
}

species_str <- get_arg("--species", args)
dbpath      <- get_arg("--dbpath",  args, "db/")
config      <- get_arg("--config",  args, "config/species.tsv")
outdir      <- get_arg("--outdir",  args, "packages/db0/")

if (is.null(species_str))
    stop("--species argument is required", call. = FALSE)

species <- strsplit(trimws(species_str), "\\s+")[[1]]
cat("Building db0 packages for:", paste(species, collapse = ", "), "\n")

## ── Validate: ensure each chipsrc_<species>.sqlite exists ───────────────────
missing <- vapply(species, function(sp) {
    !file.exists(file.path(dbpath, paste0("chipsrc_", sp, ".sqlite")))
}, logical(1))

if (any(missing))
    stop("Missing chipsrc sqlite(s): ",
         paste(species[missing], collapse = ", "), call. = FALSE)

## ── Get Bioc version for package versioning ──────────────────────────────────
bioc_ver <- tryCatch(
    as.character(BiocManager::version()),
    error = function(e) "3.20.0"
)

## ── Build db0 packages ───────────────────────────────────────────────────────
if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

cat("Calling wrapBaseDBPackages(dbPath =", dbpath,
    ", destDir =", outdir, ", version =", bioc_ver, ")\n")

wrapBaseDBPackages(dbPath  = dbpath,
                   destDir = outdir,
                   version = bioc_ver)

built <- list.files(outdir, pattern = "\\.tar\\.gz$")
cat("db0 packages built:\n")
cat(paste(" ", built, collapse = "\n"), "\n")
