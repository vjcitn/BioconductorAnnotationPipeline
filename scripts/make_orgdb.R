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
                goTable    = NA,
                dbname     = row$pkg_prefix
            )
        ))
        cat("Built:", row$pkg_prefix, ".db\n")
    }, error = function(e) {
        warning("makeOrgPackage failed for ", sp, ": ", conditionMessage(e),
                call. = FALSE)
    })
}

built <- list.files(outdir, pattern = "\\.tar\\.gz$")
if (length(built) > 0) {
    cat("\nOrgDb packages built:\n")
    cat(paste(" ", built, collapse = "\n"), "\n")
} else {
    stop("No packages were produced.", call. = FALSE)
}
