#!/usr/bin/env Rscript
## Build the GO.db R package from db/GO.sqlite.
##
## Usage (from repo root):
##   Rscript scripts/make_godb.R --input db/GO.sqlite \
##       --outdir packages/godb/ --version 3.24.0

suppressPackageStartupMessages({
    library(DBI)
    library(RSQLite)
})

## ── CLI args ──────────────────────────────────────────────────────────────────
get_arg <- function(flag, args, default = NULL) {
    i <- which(args == flag)
    if (length(i) && i < length(args)) args[[i + 1L]] else default
}

args       <- commandArgs(trailingOnly = TRUE)
input_db   <- get_arg("--input",   args)
outdir     <- get_arg("--outdir",  args, "packages/godb")
bioc_ver   <- get_arg("--version", args)

if (is.null(input_db)) stop("--input <path/to/GO.sqlite> is required", call. = FALSE)
if (!file.exists(input_db)) stop("GO.sqlite not found: ", input_db, call. = FALSE)
if (is.null(bioc_ver))  stop("--version is required (e.g. --version 3.24.0)", call. = FALSE)

dir.create(outdir, recursive = TRUE, showWarnings = FALSE)

pkg_name   <- "GO.db"
pkg_dir    <- file.path(outdir, pkg_name)
annobj     <- "GO"          # exported AnnObj prefix
dbschema   <- "GO_DB"
dbfile     <- "GO.sqlite"
maintainer <- "Bioconductor Package Maintainer <maintainer@bioconductor.org>"
author     <- "Bioconductor Core Team"

## ── Pre-flight ────────────────────────────────────────────────────────────────
tarball <- file.path(outdir, paste0(pkg_name, "_", bioc_ver, ".tar.gz"))
if (file.exists(tarball)) {
    message("Tarball already exists — remove before rebuilding:")
    message("  rm -f ", tarball)
    message("  rm -rf ", pkg_dir)
    quit(status = 1L)
}
if (dir.exists(pkg_dir)) {
    message("Package directory exists (stale build?) — remove before rebuilding:")
    message("  rm -rf ", pkg_dir)
    quit(status = 1L)
}

## ── Read source metadata from GO.sqlite ───────────────────────────────────────
conn <- dbConnect(SQLite(), input_db)
meta <- tryCatch(
    setNames(dbGetQuery(conn, "SELECT name, value FROM metadata")$value,
             dbGetQuery(conn, "SELECT name, value FROM metadata")$name),
    error = function(e) stop("Cannot read metadata from GO.sqlite: ", e$message, call. = FALSE))
dbDisconnect(conn)

go_source_date <- meta[["GOSOURCEDATE"]] %||% Sys.Date()
n_terms <- tryCatch({
    c2 <- dbConnect(SQLite(), input_db)
    n  <- dbGetQuery(c2, "SELECT count(*) FROM go_term")[[1L]]
    dbDisconnect(c2)
    n
}, error = function(e) "?")

cat(sprintf("Building %s v%s from %s (%s GO terms)\n",
            pkg_name, bioc_ver, basename(input_db), n_terms))

## ── Helper ────────────────────────────────────────────────────────────────────
`%||%` <- function(a, b) if (!is.null(a) && !is.na(a) && nzchar(a)) a else b

## ── Create package skeleton ───────────────────────────────────────────────────
dirs <- c(file.path(pkg_dir, "R"),
          file.path(pkg_dir, "man"),
          file.path(pkg_dir, "inst", "extdata"))
for (d in dirs) dir.create(d, recursive = TRUE, showWarnings = FALSE)

## Copy GO.sqlite into inst/extdata/
dest_sqlite <- file.path(pkg_dir, "inst", "extdata", dbfile)
file.copy(input_db, dest_sqlite)
Sys.chmod(dest_sqlite, mode = "0644")

## ── DESCRIPTION ───────────────────────────────────────────────────────────────
annodbi_ver <- as.character(packageVersion("AnnotationDbi"))
writeLines(c(
    paste0("Package: ", pkg_name),
    paste0("Title: A set of annotation maps describing the entire Gene Ontology"),
    paste0("Description: A set of annotation maps describing the entire Gene Ontology"),
    paste0("    assembled using data from GO (", go_source_date, ")."),
    paste0("Version: ", bioc_ver),
    paste0("Author: ", author),
    paste0("Maintainer: ", maintainer),
    paste0("Depends: R (>= 2.7.0), methods, AnnotationDbi (>= ", annodbi_ver, ")"),
    "Suggests: DBI",
    "License: Artistic-2.0",
    "biocViews: GO, Annotation"
), file.path(pkg_dir, "DESCRIPTION"))

## ── NAMESPACE ─────────────────────────────────────────────────────────────────
writeLines(c(
    "import(methods)",
    "import(AnnotationDbi)",
    "export(",
    paste0("    ", annobj, ","),
    paste0("    ", annobj, "_dbconn,"),
    paste0("    ", annobj, "_dbfile,"),
    paste0("    ", annobj, "_dbschema,"),
    paste0("    ", annobj, "_dbInfo"),
    ")"
), file.path(pkg_dir, "NAMESPACE"))

## ── R/zzz.R ───────────────────────────────────────────────────────────────────
writeLines(c(
    'datacache <- new.env(hash=TRUE, parent=emptyenv())',
    '',
    paste0(annobj, ' <- function() showQCData("', annobj, '", datacache)'),
    paste0(annobj, '_dbconn <- function() dbconn(datacache)'),
    paste0(annobj, '_dbfile <- function() dbfile(datacache)'),
    paste0(annobj, '_dbschema <- function(file="", show.indices=FALSE) dbschema(datacache, file=file, show.indices=show.indices)'),
    paste0(annobj, '_dbInfo <- function() dbInfo(datacache)'),
    '',
    '.onLoad <- function(libname, pkgname)',
    '{',
    paste0('    dbfile <- system.file("extdata", "', dbfile, '", package=pkgname, lib.loc=libname)'),
    '    assign("dbfile", dbfile, envir=datacache)',
    '    dbconn <- dbFileConnect(dbfile)',
    '    assign("dbconn", dbconn, envir=datacache)',
    '    sPkgname <- sub(".db$", "", pkgname)',
    '    txdb <- loadDb(system.file("extdata", paste0(sPkgname, ".sqlite"),',
    '                   package=pkgname, lib.loc=libname), packageName=pkgname)',
    paste0('    dbNewname <- AnnotationDbi:::dbObjectName(pkgname, "GODb")'),
    '    ns <- asNamespace(pkgname)',
    '    assign(dbNewname, txdb, envir=ns)',
    '    namespaceExport(ns, dbNewname)',
    paste0('    ann_objs <- createAnnObjs.SchemaChoice("', dbschema, '", "', annobj, '", "GOID", dbconn, datacache)'),
    '    mergeToNamespaceAndExport(ann_objs, pkgname)',
    paste0('    packageStartupMessage(AnnotationDbi:::annoStartupMessages("', annobj, '.db"))'),
    '}',
    '',
    '.onUnload <- function(libpath)',
    '{',
    paste0('    dbFileDisconnect(', annobj, '_dbconn())'),
    '}'
), file.path(pkg_dir, "R", "zzz.R"))

## ── man pages: copy from AnnotationForge template ────────────────────────────
template_dir <- system.file("AnnDbPkg-templates", "GO.DB", "man",
                             package = "AnnotationForge")
if (nzchar(template_dir) && dir.exists(template_dir)) {
    man_files <- list.files(template_dir, full.names = TRUE)
    for (mf in man_files) file.copy(mf, file.path(pkg_dir, "man", basename(mf)))
    cat(sprintf("  Copied %d man pages from AnnotationForge template\n", length(man_files)))
} else {
    ## Minimal fallback man page
    writeLines(c(
        "\\name{GO.db}",
        "\\alias{GO.db}",
        "\\title{Gene Ontology annotation maps}",
        "\\description{Gene Ontology annotation maps built from GO OBO data.}",
        "\\keyword{datasets}"
    ), file.path(pkg_dir, "man", "GO.db.Rd"))
}

## ── R CMD build ───────────────────────────────────────────────────────────────
cat("Running R CMD build for", pkg_name, "\n")
old_wd <- getwd()
on.exit(setwd(old_wd))
setwd(normalizePath(outdir))
rc <- system(paste("R CMD build --no-build-vignettes", shQuote(pkg_name)))
setwd(old_wd)

if (rc != 0L) {
    warning("R CMD build failed for GO.db", call. = FALSE)
} else {
    cat("Built: GO.db\n")
    cat("Tarball:", tarball, "\n")
}
