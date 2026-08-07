## Build OrgDb packages using AnnotationForge::makeOrgPackage().
## Called by the top-level Makefile as:
##   Rscript scripts/make_orgdb.R --species "human mouse ..." \
##       --config config/species.tsv --dbpath db/ --outdir packages/orgdb/
##
## Uses the public makeOrgPackage() API directly from chipsrc_<species>.sqlite.
## No db0 packages, no metadatasrc.sqlite, no internal AnnotationForge paths.

suppressPackageStartupMessages({
    library(AnnotationForge)
    library(DBI)
    library(RSQLite)
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
dbpath      <- get_arg("--dbpath",  args, "db/")
outdir      <- get_arg("--outdir",  args, "packages/orgdb/")

if (is.null(species_str))
    stop("--species argument is required", call. = FALSE)

species_list <- strsplit(trimws(species_str), "\\s+")[[1]]
cat("Building OrgDb packages for:", paste(species_list, collapse = ", "), "\n")

## ── Read species config ───────────────────────────────────────────────────────
cfg <- read.table(config, header = TRUE, sep = "\t", stringsAsFactors = FALSE,
                  quote = "")

if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

## ── Per-species package build ─────────────────────────────────────────────────
for (sp in species_list) {
    row <- cfg[cfg$name == sp, ]
    if (nrow(row) == 0L) {
        warning("Species '", sp, "' not in config — skipping", call. = FALSE)
        next
    }

    chip <- file.path(dbpath, paste0("chipsrc_", sp, ".sqlite"))
    if (!file.exists(chip)) {
        warning("Missing ", chip, " — skipping ", sp, call. = FALSE)
        next
    }

    cat("\n--", paste0(row$pkg_prefix, ".db"), "(", row$genus, row$species, ") --\n")

    db <- dbConnect(SQLite(), chip)

    ## gene_info: GID, SYMBOL, GENENAME
    gene_info <- dbGetQuery(db,
        "SELECT g.gene_id AS GID,
                i.symbol   AS SYMBOL,
                i.gene_name AS GENENAME
         FROM genes g
         JOIN gene_info i ON g._id = i._id")

    ## GO: combined BP/MF/CC with ONTOLOGY column (makeOrgPackage goTable format)
    go_bp <- dbGetQuery(db,
        "SELECT g.gene_id AS GID, b.go_id AS GO,
                b.evidence AS EVIDENCE, 'BP' AS ONTOLOGY
         FROM genes g JOIN go_bp b ON g._id = b._id")
    go_mf <- dbGetQuery(db,
        "SELECT g.gene_id AS GID, b.go_id AS GO,
                b.evidence AS EVIDENCE, 'MF' AS ONTOLOGY
         FROM genes g JOIN go_mf b ON g._id = b._id")
    go_cc <- dbGetQuery(db,
        "SELECT g.gene_id AS GID, b.go_id AS GO,
                b.evidence AS EVIDENCE, 'CC' AS ONTOLOGY
         FROM genes g JOIN go_cc b ON g._id = b._id")
    go_all <- unique(rbind(go_bp, go_mf, go_cc))

    ## chromosome
    chrom <- dbGetQuery(db,
        "SELECT g.gene_id AS GID, c.chromosome AS CHROMOSOME
         FROM genes g JOIN chromosomes c ON g._id = c._id")

    ## chromosome location: CHRLOC = signed start, CHRLOCEND = end
    ## chromosome name lives in the separate 'chromosome' data frame
    chrloc <- dbGetQuery(db,
        "SELECT g.gene_id AS GID,
                cl.start_location AS CHRLOC,
                cl.end_location   AS CHRLOCEND
         FROM genes g JOIN chromosome_locations cl ON g._id = cl._id")

    ## RefSeq accessions
    refseq <- dbGetQuery(db,
        "SELECT g.gene_id AS GID, r.accession AS REFSEQ
         FROM genes g JOIN refseq r ON g._id = r._id")

    ## Ensembl IDs
    ensembl <- dbGetQuery(db,
        "SELECT g.gene_id AS GID, e.ensid AS ENSEMBL
         FROM genes g JOIN ensembl e ON g._id = e._id")

    ## PubMed IDs
    pubmed <- dbGetQuery(db,
        "SELECT g.gene_id AS GID, p.pubmed_id AS PMID
         FROM genes g JOIN pubmed p ON g._id = p._id")

    ## Gene synonyms
    synonym <- dbGetQuery(db,
        "SELECT g.gene_id AS GID, s.symbol AS ALIAS
         FROM genes g JOIN gene_synonyms s ON g._id = s._id")

    ## UniProt (may be empty if provider not yet available)
    uniprot <- dbGetQuery(db,
        "SELECT g.gene_id AS GID, u.uniprot_id AS UNIPROT
         FROM genes g JOIN uniprot u ON g._id = u._id")

    dbDisconnect(db)

    ## Deduplicate all frames (makeOrgPackage rejects duplicate rows)
    gene_info <- unique(gene_info)
    chrom     <- unique(chrom)
    chrloc    <- unique(chrloc)
    refseq    <- unique(refseq)
    pubmed    <- unique(pubmed)
    synonym   <- unique(synonym)
    ensembl   <- unique(ensembl)
    uniprot   <- unique(uniprot)

    ## Assemble named list; drop empty frames to avoid makeOrgPackage errors
    frames <- list(
        gene_info  = gene_info,
        chromosome = chrom,
        chrloc     = chrloc,
        refseq     = refseq,
        pubmed     = pubmed,
        synonym    = synonym
    )
    if (nrow(ensembl) > 0)  frames$ensembl  <- ensembl
    if (nrow(uniprot) > 0)  frames$uniprot  <- uniprot
    ## Store GO as a plain mapping table. goTable=NA because the GO term
    ## hierarchy (parents/offspring) lives in GO.db, which is a separate
    ## package also produced by this pipeline and cannot be a build dep here.
    if (nrow(go_all)  > 0)  frames$gene2go  <- go_all

    ## Diagnostic: report frame dimensions and first column name
    for (nm in names(frames)) {
        cat(sprintf("  frame %-12s  nrow=%-7d  col1=%s\n",
                    nm, nrow(frames[[nm]]), names(frames[[nm]])[1]))
    }

    bioc_ver <- tryCatch(as.character(BiocManager::version()),
                         error = function(e) "3.20.0")

    expected_pkg  <- paste0(row$pkg_prefix, ".db")
    pre_dirs      <- list.dirs(outdir, recursive = FALSE, full.names = TRUE)

    tryCatch({
        do.call(makeOrgPackage, c(
            frames,
            list(
                version    = bioc_ver,
                maintainer = "Bioconductor Package Maintainer <maintainer@bioconductor.org>",
                author     = "Bioconductor Core Team",
                outputDir  = outdir,
                tax_id     = as.character(row$taxid),
                genus      = row$genus,
                species    = row$species,
                goTable    = NA
                ## goTable=NA: GO.db is itself produced by this pipeline.
                ## dbname is not a parameter of makeOrgPackage; it derives the
                ## package name from genus + species (e.g. org.Hsapiens.eg.db).
                ## We rename to the canonical Bioconductor name below.
            )
        ))

        ## Detect the source directory makeOrgPackage created
        post_dirs <- list.dirs(outdir, recursive = FALSE, full.names = TRUE)
        new_dirs  <- setdiff(post_dirs, pre_dirs)

        if (length(new_dirs) != 1L)
            stop("Expected exactly one new package directory, got: ",
                 paste(basename(new_dirs), collapse = ", "), call. = FALSE)

        src_dir      <- new_dirs[1L]
        expected_dir <- file.path(normalizePath(outdir), expected_pkg)

        ## Rename to canonical name and fix DESCRIPTION if makeOrgPackage
        ## used a different name (it uses genus-initial + full-species).
        if (!identical(normalizePath(src_dir), normalizePath(expected_dir))) {
            cat("Renaming", basename(src_dir), "->", expected_pkg, "\n")
            desc_path <- file.path(src_dir, "DESCRIPTION")
            desc      <- readLines(desc_path)
            desc      <- sub("^Package:.*", paste0("Package: ", expected_pkg), desc)
            desc      <- sub("^Title:.*",
                             paste0("Title: Genome wide annotation for ",
                                    row$genus, " ", row$species),
                             desc)
            writeLines(desc, desc_path)
            file.rename(src_dir, expected_dir)
        }

        ## Build the tarball
        cat("Running R CMD build for", expected_pkg, "\n")
        old_wd <- getwd()
        on.exit(setwd(old_wd), add = TRUE)
        setwd(normalizePath(outdir))
        rc <- system(paste("R CMD build --no-build-vignettes",
                           shQuote(expected_pkg)))
        setwd(old_wd)
        if (rc != 0L)
            warning("R CMD build failed for ", sp, call. = FALSE)
        else
            cat("Built:", expected_pkg, "\n")

    }, error = function(e) {
        warning("makeOrgPackage failed for ", sp, ": ", conditionMessage(e),
                call. = FALSE)
    })
}

built <- list.files(outdir, pattern = "\\.tar\\.gz$")
if (length(built) > 0L) {
    cat("\nOrgDb tarballs produced:\n")
    cat(paste(" ", built, collapse = "\n"), "\n")
} else {
    stop("No tarballs were produced.", call. = FALSE)
}
