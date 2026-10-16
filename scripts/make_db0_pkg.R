## Milestone 2 of PlanFor3.24.md: build an OrgDb package from a
## schema-conformant db0 sqlite (produced by scripts/make_db0.sh) via
## AnnotationForge::makeAnnDbPkg(), instead of makeOrgPackage(). This is
## what restores the legacy per-table Bimap objects (org.Hs.egSYMBOL, ...)
## and fixes the modern keys()/select() dispatch for keytypes that
## .definePossibleTables() expects under different table/column names than
## makeOrgPackage()'s own re-extraction used.
##
## Standalone for now (Milestone 2 scope only) — not yet wired into the
## Makefile's `package` target or into make_orgdb.R; that integration is
## Milestone 3.
##
## Usage:
##   Rscript scripts/make_db0_pkg.R --species human --config config/species.tsv \
##       --dbpath db/ --outdir packages/orgdb/ --version 3.24.0

suppressPackageStartupMessages({
    library(AnnotationForge)
})

args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(flag, args, default = NULL) {
    idx <- which(args == flag)
    if (length(idx) == 0L) return(default)
    args[idx + 1L]
}

sp          <- get_arg("--species", args)
config      <- get_arg("--config",  args, "config/species.tsv")
dbpath      <- get_arg("--dbpath",  args, "db/")
outdir      <- get_arg("--outdir",  args, "packages/orgdb/")
bioc_ver    <- get_arg("--version", args)

if (is.null(sp))       stop("--species is required",  call. = FALSE)
if (is.null(bioc_ver)) stop("--version is required (e.g. --version 3.24.0)", call. = FALSE)

cfg <- read.table(config, header = TRUE, sep = "\t", stringsAsFactors = FALSE,
                  quote = "")
row <- cfg[cfg$name == sp, ]
if (nrow(row) == 0L) stop("Species '", sp, "' not in ", config, call. = FALSE)

db0 <- file.path(dbpath, paste0("db0_", sp, ".sqlite"))
if (!file.exists(db0))
    stop("Missing ", db0, " — run 'make ", db0, "' first", call. = FALSE)

## makeAnnDbPkg() requires dbfile's basename to be exactly
## <AnnObjPrefix>.sqlite. Stage a renamed copy in a scratch dir rather than
## renaming db0_<species>.sqlite itself, which the Makefile tracks by its
## own name.
ann_obj_prefix <- row$pkg_prefix                      # e.g. "org.Hs.eg"
stage_dir      <- tempfile("db0pkg_")
dir.create(stage_dir)
on.exit(unlink(stage_dir, recursive = TRUE), add = TRUE)
staged_dbfile  <- file.path(stage_dir, paste0(ann_obj_prefix, ".sqlite"))
file.copy(db0, staged_dbfile)

if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

full_organism <- paste(row$genus, row$species)
## AnnDbPkgSeed's "species" slot must match the sqlite's SPECIES metadata
## row exactly (initWithDbMetada() hard-stops otherwise) -- that row holds
## the capitalized common name (e.g. "Human"), not the binomial, which goes
## in "organism" instead. make_db0.sh derives it the same way: capitalize
## the species.tsv "name" column.
species_tag <- paste0(toupper(substr(sp, 1L, 1L)), substring(sp, 2L))

seed <- new("AnnDbPkgSeed",
    Package         = paste0(ann_obj_prefix, ".db"),
    Title           = paste0("Genome wide annotation for ", full_organism),
    Version         = bioc_ver,
    Author          = "Bioconductor Core Team",
    Maintainer      = "Bioconductor Package Maintainer <maintainer@bioconductor.org>",
    PkgTemplate     = "NCBIORG.DB",
    DBschema        = row$pkg_template,                 # e.g. "HUMAN_DB"
    AnnObjPrefix    = ann_obj_prefix,
    organism        = full_organism,                    # e.g. "Homo sapiens"
    species         = species_tag,                       # e.g. "Human"
    manufacturerUrl = "https://www.ncbi.nlm.nih.gov",
    biocViews       = "annotation")

cat("Building", seed@Package, "from", db0, "via makeAnnDbPkg() ...\n")
makeAnnDbPkg(seed, dbfile = staged_dbfile, dest_dir = outdir)

cat("Done. Package source at:",
    file.path(outdir, paste0(ann_obj_prefix, ".db")), "\n")
