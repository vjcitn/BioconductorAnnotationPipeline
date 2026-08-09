#!/usr/bin/env Rscript
## Discover spot-check candidates from chipsrc databases and print TSV rows
## ready to append to tests/known_genes.tsv.
##
## For each species, finds the TP53 orthologue (by symbol, case-insensitive)
## and pulls its gene_id, genename, UniProt, and a GO term.
##
## Usage (from repo root):
##   Rscript scripts/discover_spot_checks.R [species ...]
##   Rscript scripts/discover_spot_checks.R bovine canine chicken chimp pig rhesus anopheles xenopus

suppressPackageStartupMessages(library(DBI))
suppressPackageStartupMessages(library(RSQLite))

args <- commandArgs(trailingOnly = TRUE)

root   <- normalizePath(".", mustWork = FALSE)
config <- read.delim(file.path(root, "config", "species.tsv"),
                     stringsAsFactors = FALSE)

species_list <- if (length(args) > 0) args else config$name

## TP53 symbol patterns to try, in order
P53_SYMBOLS <- c("TP53", "Trp53", "tp53", "p53", "cep-1")

cat("species\tgene_id\tsymbol\tgenename_contains\tuniprot\tgo_id\n")

for (sp in species_list) {
    cfg <- config[config$name == sp, ]
    if (nrow(cfg) == 0) {
        message("# ", sp, ": not in config — skipped")
        next
    }

    dbpath <- file.path(root, "db", paste0("chipsrc_", sp, ".sqlite"))
    if (!file.exists(dbpath)) {
        message("# ", sp, ": no chipsrc at ", dbpath, " — skipped")
        next
    }

    con <- dbConnect(SQLite(), dbpath)
    on.exit(dbDisconnect(con), add = TRUE)

    ## Find p53 orthologue
    row <- NULL
    for (sym in P53_SYMBOLS) {
        row <- tryCatch(dbGetQuery(con,
            sprintf("SELECT g.gene_id, i.symbol, i.gene_name
                     FROM genes g
                     JOIN gene_info i ON g._id = i._id
                     WHERE lower(i.symbol) = lower('%s')
                     LIMIT 1", sym)),
            error = function(e) NULL)
        if (!is.null(row) && nrow(row) > 0) break
    }

    if (is.null(row) || nrow(row) == 0) {
        message("# ", sp, ": no TP53 orthologue found by symbol — try manual lookup")
        next
    }

    gene_id  <- row$gene_id[1]
    symbol   <- row$symbol[1]
    genename <- row$gene_name[1]

    ## Shorten genename to a reliable substring (first 20 chars, trim to word)
    gn_sub <- if (!is.na(genename) && nzchar(genename)) {
        s <- substr(genename, 1, 25)
        ## trim to last complete word
        sub("\\s+\\S+$", "", s)
    } else symbol

    ## UniProt
    uniprot <- tryCatch({
        r <- dbGetQuery(con,
            sprintf("SELECT u.UNIPROT FROM genes g
                     JOIN uniprot u ON g._id = u._id
                     WHERE g.gene_id = '%s'
                     LIMIT 1", gene_id))
        if (nrow(r) > 0) r$UNIPROT[1] else NA_character_
    }, error = function(e) NA_character_)

    ## GO term — prefer GO:0006915 (apoptotic process) if present
    go_id <- tryCatch({
        preferred <- dbGetQuery(con,
            sprintf("SELECT go_id FROM go_bp g
                     JOIN genes gs ON g._id = gs._id
                     WHERE gs.gene_id = '%s' AND go_id = 'GO:0006915'
                     LIMIT 1", gene_id))
        if (nrow(preferred) > 0) {
            preferred$go_id[1]
        } else {
            r <- dbGetQuery(con,
                sprintf("SELECT go_id FROM go_bp g
                         JOIN genes gs ON g._id = gs._id
                         WHERE gs.gene_id = '%s'
                         LIMIT 1", gene_id))
            if (nrow(r) > 0) r$go_id[1] else NA_character_
        }
    }, error = function(e) NA_character_)

    cat(sprintf("%s\t%s\t%s\t%s\t%s\t%s\n",
        sp, gene_id, symbol,
        gn_sub,
        if (is.na(uniprot)) "" else uniprot,
        if (is.na(go_id))   "" else go_id))

    dbDisconnect(con)
    on.exit(NULL)
}
