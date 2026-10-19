## Build OrgDb packages, dispatching per species between two pipelines:
## Called by the top-level Makefile as:
##   Rscript scripts/make_orgdb.R --species "human mouse ..." \
##       --config config/species.tsv --dbpath db/ --outdir packages/orgdb/
##
## - DB0_SUPPORTED_SPECIES: the Milestone 1+2 pipeline from PlanFor3.24.md --
##   scripts/make_db0.sh rewrites chipsrc_<species>.sqlite's table/column
##   names to match AnnotationDbi's internal .definePossibleTables() contract,
##   then AnnotationForge::makeAnnDbPkg() builds the package from that
##   conformant sqlite. This restores the legacy per-table Bimap objects
##   (org.Hs.egSYMBOL, ...) and fixes modern keys()/select() dispatch for
##   keytypes makeOrgPackage() alone cannot satisfy (GOALL, PFAM, IPI,
##   ENSEMBL, ...). Currently `human`, `mouse`, `rat`, `zebrafish`,
##   `chimp`, and `bovine`; see PlanFor3.24.md Milestone 5 for
##   generalizing make_db0.sh's rename rules to the rest of
##   config/species.tsv.
## - All other species: the original makeOrgPackage()-based pipeline, kept
##   as-is until each one gets its own make_db0.sh rename rules.
##
## GO tables (go_bp/mf/cc and go_bp/mf/cc_all) are NOT passed through
## makeOrgPackage in the legacy path because GO.db is itself produced by this
## pipeline (circular). Instead they are written directly into the OrgDb
## sqlite via ATTACH after makeOrgPackage creates the package skeleton. The
## db0 path has no such issue -- make_db0.sh's go/go_all views are already
## baked into db0_<species>.sqlite before makeAnnDbPkg() ever runs.

suppressPackageStartupMessages({
    library(AnnotationForge)
    library(DBI)
    library(RSQLite)
})

DB0_SUPPORTED_SPECIES <- c("human", "mouse", "rat", "zebrafish", "chimp", "bovine")

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
cli_version <- get_arg("--version", args)

if (is.null(species_str))
    stop("--species argument is required", call. = FALSE)
if (is.null(cli_version))
    stop("--version is required (e.g. --version 3.24.0)", call. = FALSE)
bioc_ver <- cli_version

run_start    <- Sys.time()
species_list <- strsplit(trimws(species_str), "\\s+")[[1]]
cat("Building OrgDb packages for:", paste(species_list, collapse = ", "), "\n")

## ── Pre-flight: check for completed builds (tarball exists) ──────────────────
## A source directory without a tarball is a failed/partial build and is
## cleaned up automatically. Only block if a tarball already exists, which
## means a prior successful build — require explicit removal to protect it.
if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)
cfg_pre <- read.table(config, header = TRUE, sep = "\t",
                      stringsAsFactors = FALSE, quote = "")
conflicts <- vapply(species_list, function(sp) {
    row <- cfg_pre[cfg_pre$name == sp, ]
    if (nrow(row) == 0L) return("")
    pkg  <- paste0(row$pkg_prefix, ".db")
    tarballs <- list.files(normalizePath(outdir, mustWork = FALSE),
                           pattern = paste0("^", gsub("\\.", "\\\\.", pkg),
                                            "_.*\\.tar\\.gz$"))
    if (length(tarballs) > 0L) pkg else ""
}, character(1))
conflicts <- conflicts[nzchar(conflicts)]
out_abs   <- normalizePath(outdir, mustWork = FALSE)
if (length(conflicts) > 0L) {
    ## Use message() line-by-line to avoid stop() truncating long paths
    message("Completed tarball(s) already exist. Remove before rebuilding:")
    for (pkg in conflicts) {
        message("  rm -rf ", file.path(out_abs, pkg))
        message("  rm -f  ", file.path(out_abs, pkg), "_*.tar.gz")
    }
    quit(status = 1L, save = "no")
}
## Remove any stale source directories from prior failed builds
for (sp in species_list) {
    row <- cfg_pre[cfg_pre$name == sp, ]
    if (nrow(row) == 0L) next
    stale <- file.path(normalizePath(outdir, mustWork = FALSE),
                       paste0(row$pkg_prefix, ".db"))
    if (dir.exists(stale)) {
        message("Removing stale source directory from prior failed build: ",
                basename(stale))
        unlink(stale, recursive = TRUE)
    }
}

## ── Read species config ───────────────────────────────────────────────────────
cfg <- read.table(config, header = TRUE, sep = "\t", stringsAsFactors = FALSE,
                  quote = "")

## ── Helper: run a query, return empty frame on error ─────────────────────────
## "no such table" is expected for species-specific tables (omim is human-only,
## ucsc varies, etc.). Emit a Note: so the user knows it is not a real problem.
## Genuine errors (wrong column name, syntax, corruption) still produce warning().
safe_query <- function(db, sql, sp = NULL, ...) {
    tryCatch(dbGetQuery(db, sql, ...),
             error = function(e) {
                 msg <- conditionMessage(e)
                 prefix <- if (!is.null(sp)) paste0("[", sp, "] ") else ""
                 if (grepl("no such table", msg, ignore.case = TRUE))
                     message("Note: ", prefix, msg, " -- skipped")
                 else
                     warning("Query failed: ", prefix, msg, call. = FALSE)
                 data.frame()
             })
}

## ── db0 pipeline (Milestone 1+2): build via AnnotationForge::makeAnnDbPkg() ──
## Returns the path to the created package source directory.
build_via_db0 <- function(sp, row, chip, dbpath, outdir, bioc_ver) {
    cat("  Building db0_", sp, ".sqlite (schema-conformance pass) ...\n", sep = "")
    ## make_db0.sh resolves its own DATA_ROOT from the environment, not from
    ## an argument -- pass the one implied by --dbpath explicitly (dbpath is
    ## always "<DATA_ROOT>/db/" by this repo's convention) rather than
    ## relying on an ambient DATA_ROOT happening to agree with it.
    data_root <- dirname(normalizePath(dbpath, mustWork = FALSE))
    rc <- system2("bash", c("scripts/make_db0.sh", sp),
                  env = paste0("DATA_ROOT=", shQuote(data_root)))
    if (rc != 0L) stop("make_db0.sh failed for ", sp, call. = FALSE)

    db0 <- file.path(dbpath, paste0("db0_", sp, ".sqlite"))

    ## makeAnnDbPkg() requires dbfile's basename to be exactly
    ## <AnnObjPrefix>.sqlite. Stage a renamed copy rather than renaming
    ## db0_<species>.sqlite itself, which the Makefile tracks by its own name.
    ann_obj_prefix <- row$pkg_prefix                      # e.g. "org.Hs.eg"
    stage_dir      <- tempfile("db0pkg_")
    dir.create(stage_dir)
    on.exit(unlink(stage_dir, recursive = TRUE), add = TRUE)
    staged_dbfile  <- file.path(stage_dir, paste0(ann_obj_prefix, ".sqlite"))
    file.copy(db0, staged_dbfile)

    full_organism <- paste(row$genus, row$species)
    ## AnnDbPkgSeed's "species" slot must match the sqlite's SPECIES metadata
    ## row exactly (initWithDbMetada() hard-stops otherwise) -- the
    ## capitalized common name (e.g. "Human"), not the binomial, which goes
    ## in "organism" instead. make_db0.sh derives it the same way.
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

    cat("  Building", seed@Package, "via makeAnnDbPkg() ...\n")
    makeAnnDbPkg(seed, dbfile = staged_dbfile, dest_dir = outdir)

    pkg_dir <- file.path(normalizePath(outdir, mustWork = FALSE), paste0(ann_obj_prefix, ".db"))
    fix_escaped_rd_underscores(pkg_dir)
    pkg_dir
}

## AnnotationForge's own NCBIORG.DB Rd template (man/REFSEQ.Rd) ships with
## literal "\_" in plain Rd text (e.g. "NG\_XXXXX"), copied verbatim into
## every package built from it -- Rd text never needs underscore escaped,
## so this is flagged by R CMD check as "checkRd: Escaped LaTeX specials:
## \_" and is almost certainly also why the PDF manual's LaTeX render
## fails. Strip the unnecessary escaping from every generated .Rd file
## post-hoc rather than patching AnnotationForge's installed template.
fix_escaped_rd_underscores <- function(pkg_dir) {
    man_dir <- file.path(pkg_dir, "man")
    rd_files <- list.files(man_dir, pattern = "\\.Rd$", full.names = TRUE)
    for (f in rd_files) {
        txt <- readLines(f, warn = FALSE)
        fixed <- gsub("\\\\_", "_", txt, fixed = FALSE)
        if (!identical(txt, fixed)) {
            writeLines(fixed, f)
            cat("  Fixed escaped underscores in", basename(f), "\n")
        }
    }
}

## ── Legacy pipeline: build via AnnotationForge::makeOrgPackage() ─────────────
## Returns the path to the created package source directory.
build_via_make_org_package <- function(sp, row, chip, outdir, bioc_ver) {
    db <- dbConnect(SQLite(), chip)

    ## ── Extract frames from chipsrc ───────────────────────────────────────────

    gene_info <- safe_query(db, sp = sp,
        "SELECT g.gene_id AS GID,
                i.symbol   AS SYMBOL,
                COALESCE(i.gene_name, i.symbol) AS GENENAME
         FROM genes g JOIN gene_info i ON g._id = i._id")

    chrom <- safe_query(db, sp = sp,
        "SELECT g.gene_id AS GID, c.chromosome AS CHROMOSOME
         FROM genes g JOIN chromosomes c ON g._id = c._id")

    chrloc <- safe_query(db, sp = sp,
        "SELECT g.gene_id AS GID,
                cl.start_location AS CHRLOC,
                cl.end_location   AS CHRLOCEND
         FROM genes g JOIN chromosome_locations cl ON g._id = cl._id")

    map_loc <- safe_query(db, sp = sp,
        "SELECT g.gene_id AS GID, m.cytogenetic_location AS MAP
         FROM genes g JOIN cytogenetic_locations m ON g._id = m._id")

    refseq <- safe_query(db, sp = sp,
        "SELECT g.gene_id AS GID, r.accession AS REFSEQ
         FROM genes g JOIN refseq r ON g._id = r._id")

    accnum <- safe_query(db, sp = sp,
        "SELECT g.gene_id AS GID, a.accession AS ACCNUM
         FROM genes g JOIN accessions a ON g._id = a._id")

    pubmed <- safe_query(db, sp = sp,
        "SELECT g.gene_id AS GID, p.pubmed_id AS PMID
         FROM genes g JOIN pubmed p ON g._id = p._id")

    synonym <- safe_query(db, sp = sp,
        "SELECT g.gene_id AS GID, s.symbol AS ALIAS
         FROM genes g JOIN gene_synonyms s ON g._id = s._id")

    genetype <- safe_query(db, sp = sp,
        "SELECT g.gene_id AS GID, t.gene_type AS GENETYPE
         FROM genes g JOIN genetype t ON g._id = t._id")

    omim <- safe_query(db, sp = sp,
        "SELECT g.gene_id AS GID, o.omim_id AS OMIM
         FROM genes g JOIN omim o ON g._id = o._id")

    ensembl <- safe_query(db, sp = sp,
        "SELECT g.gene_id AS GID, e.ensid AS ENSEMBL
         FROM genes g JOIN ensembl e ON g._id = e._id")

    ensembl_pro <- safe_query(db, sp = sp,
        "SELECT g.gene_id AS GID, e.pro_id AS ENSEMBLPROT
         FROM genes g JOIN ensembl_pro e ON g._id = e._id")

    ensembl_trs <- safe_query(db, sp = sp,
        "SELECT g.gene_id AS GID, e.trs_id AS ENSEMBLTRANS
         FROM genes g JOIN ensembl_trs e ON g._id = e._id")

    uniprot <- safe_query(db, sp = sp,
        "SELECT g.gene_id AS GID, u.uniprot_id AS UNIPROT
         FROM genes g JOIN uniprot u ON g._id = u._id")

    path <- safe_query(db, sp = sp,
        "SELECT g.gene_id AS GID, k.path_id AS PATH
         FROM genes g JOIN kegg k ON g._id = k._id")

    enzyme <- safe_query(db, sp = sp,
        "SELECT g.gene_id AS GID, e.ec_number AS ENZYME
         FROM genes g JOIN ec e ON g._id = e._id")

    ucsckg <- safe_query(db, sp = sp,
        "SELECT g.gene_id AS GID, u.ucsc_id AS UCSCKG
         FROM genes g JOIN ucsc u ON g._id = u._id")

    dbDisconnect(db)

    ## Deduplicate all frames
    gene_info <- unique(gene_info)
    ## Yeast and arabidopsis gene names/synonyms contain non-ASCII characters
    ## (Greek letters: alpha, beta, etc.) that fail on C-locale build servers.
    if (sp %in% c("yeast", "arabidopsis")) {
        to_ascii <- function(x) iconv(x, from = "", to = "ASCII", sub = "")
        for (col in names(gene_info)[sapply(gene_info, is.character)])
            gene_info[[col]] <- to_ascii(gene_info[[col]])
        for (col in names(synonym)[sapply(synonym, is.character)])
            synonym[[col]] <- to_ascii(synonym[[col]])
    }
    chrom     <- unique(chrom)
    chrloc    <- unique(chrloc)
    map_loc   <- unique(map_loc)
    refseq    <- unique(refseq)
    accnum    <- unique(accnum)
    pubmed    <- unique(pubmed)
    synonym   <- unique(synonym)
    genetype  <- unique(genetype)
    omim      <- unique(omim)
    ensembl     <- unique(ensembl)
    ensembl_pro <- unique(ensembl_pro)
    ensembl_trs <- unique(ensembl_trs)
    uniprot     <- unique(uniprot)
    path        <- unique(path)
    enzyme      <- unique(enzyme)
    ucsckg      <- unique(ucsckg)

    ## Core frames (always passed — non-empty by construction for any species
    ## with NCBI gene data)
    frames <- list(
        gene_info  = gene_info,
        refseq     = refseq,
        pubmed     = pubmed,
        synonym    = synonym
    )

    ## Optional frames: include only if non-empty.
    ## chromosome (CHR) and chrloc (CHRLOC) are absent for bacteria (ecoliK12,
    ## ecoliSakai) and some non-model species — treat as optional.
    opt <- list(
        chromosome  = chrom,
        chrloc      = chrloc,
        map         = map_loc,
        accnum      = accnum,
        genetype    = genetype,
        omim        = omim,
        ensembl     = ensembl,
        ensembl_pro = ensembl_pro,
        ensembl_trs = ensembl_trs,
        uniprot     = uniprot,
        path        = path,
        enzyme      = enzyme,
        ucsckg      = ucsckg
    )
    for (nm in names(opt)) {
        if (nrow(opt[[nm]]) > 0L) frames[[nm]] <- opt[[nm]]
    }

    ## GO is handled post-hoc via SQL ATTACH (see below); do not pass here.

    full_organism <- paste(row$genus, row$species)

    ## makeOrgPackage names the package:
    ##   paste0("org.", toupper(substr(genus,1,1)), tolower(species), ".eg.db")
    ## Derive genus_code/species_code from pkg_prefix abbreviation so the
    ## created package has the right canonical name from the start.
    ## "org.Hs.eg" -> abbrev "Hs" -> genus_code "H", species_code "s"
    ## -> creates org.Hs.eg.db / inst/extdata/org.Hs.eg.sqlite  (no rename needed)
    abbrev       <- strsplit(row$pkg_prefix, "\\.")[[1L]][2L]
    genus_code   <- substring(abbrev, 1L, 1L)
    species_code <- substring(abbrev, 2L)

    pre_dirs <- list.dirs(outdir, recursive = FALSE, full.names = TRUE)

    do.call(makeOrgPackage, c(
        frames,
        list(
            version    = bioc_ver,
            maintainer = "Bioconductor Package Maintainer <maintainer@bioconductor.org>",
            author     = "Bioconductor Core Team",
            outputDir  = outdir,
            tax_id     = as.character(row$taxid),
            genus      = genus_code,
            species    = species_code,
            goTable    = NA
        )
    ))

    ## Detect the directory makeOrgPackage created
    post_dirs <- list.dirs(outdir, recursive = FALSE, full.names = TRUE)
    new_dirs  <- setdiff(post_dirs, pre_dirs)
    if (length(new_dirs) != 1L)
        stop("Expected one new package directory, got: ",
             paste(basename(new_dirs), collapse = ", "), call. = FALSE)

    src_dir    <- new_dirs[1L]
    src_prefix <- sub("\\.db$", "", basename(src_dir))  # "org.Hs.eg"

    ## makeOrgPackage always produces an .eg. name. For species whose
    ## pkg_prefix ends in something other than .eg (e.g. org.Sc.sgd,
    ## org.At.tair), rename the directory, SQLite, and DESCRIPTION to
    ## match the canonical pkg_prefix name.
    canonical_prefix <- row$pkg_prefix          # e.g. "org.Sc.sgd"
    canonical_dir    <- file.path(outdir, paste0(canonical_prefix, ".db"))
    if (src_prefix != canonical_prefix) {
        old_pkg_name <- paste0(src_prefix, ".db")   # "org.Sc.eg.db"
        new_pkg_name <- paste0(canonical_prefix, ".db") # "org.Sc.sgd.db"

        ## 1. Rename the sqlite inside inst/extdata
        old_sqlite <- file.path(src_dir, "inst", "extdata",
                                paste0(src_prefix, ".sqlite"))
        new_sqlite <- file.path(src_dir, "inst", "extdata",
                                paste0(canonical_prefix, ".sqlite"))
        file.rename(old_sqlite, new_sqlite)

        ## 2. Patch all text files in the package (R/, NAMESPACE, man/,
        ##    DESCRIPTION) — replace both the package name ("org.Sc.eg.db")
        ##    and the bare prefix ("org.Sc.eg", appears in sqlite filename,
        ##    exported symbol names, man page aliases, etc.).
        ##    Replace longer string first to avoid partial substitution.
        all_pkg_files <- list.files(src_dir, recursive = TRUE,
                                    full.names = TRUE)
        for (pf in all_pkg_files) {
            if (file.info(pf)$isdir) next
            txt <- tryCatch(readLines(pf, warn = FALSE), error = function(e) NULL)
            if (is.null(txt)) next
            txt2 <- gsub(old_pkg_name,  new_pkg_name,    txt, fixed = TRUE)
            txt2 <- gsub(src_prefix,    canonical_prefix, txt2, fixed = TRUE)
            if (!identical(txt, txt2)) writeLines(txt2, pf)
        }

        ## 3. Rename the package directory itself
        file.rename(src_dir, canonical_dir)
        src_dir    <- canonical_dir
        src_prefix <- canonical_prefix
        cat("  Renamed package to", basename(src_dir), "\n")
    }

    ## Fix DESCRIPTION (abbreviated codes were used for naming)
    desc_path <- file.path(src_dir, "DESCRIPTION")
    desc <- readLines(desc_path, warn = FALSE)
    desc <- sub("^Package:.*",
                paste0("Package: ", canonical_prefix, ".db"),
                desc)
    desc <- sub("^Title:.*",
                paste0("Title: Genome wide annotation for ", full_organism),
                desc)
    desc <- sub("^Description:.*",
                paste0("Description: Annotation maps for ", full_organism,
                       ", assembled from public repositories."),
                desc)
    writeLines(desc, desc_path)

    ## Open the OrgDb sqlite (chmod first — makeOrgPackage creates it 0444)
    sqlite_path <- file.path(src_dir, "inst", "extdata",
                             paste0(src_prefix, ".sqlite"))
    Sys.chmod(sqlite_path, mode = "0644")
    conn <- dbConnect(SQLite(), sqlite_path)

    ## makeOrgPackage stores the frame's first column name (GID) literally
    ## in the genes table. AnnotationDbi's HUMAN_DB and related schemas
    ## expect the column to be named gene_id for select()/keys() to work.
    ## Rename immediately before any other operations touch the table.
    gp <- dbGetQuery(conn, "PRAGMA table_info(genes)")
    if ("GID" %in% gp$name) {
        dbExecute(conn, "ALTER TABLE genes RENAME COLUMN GID TO gene_id")
    }

    ## ── Fix metadata ──────────────────────────────────────────────────────
    ## 1. Copy source provenance rows from chipsrc (EGSOURCE*, GOSOURCE*,
    ##    KEGGSOURCE*, GPSOURCE*).  INSERT OR IGNORE skips any that already
    ##    exist in the OrgDb metadata table.
    dbExecute(conn,
        paste0("ATTACH DATABASE '", normalizePath(chip), "' AS chipmeta"))
    dbExecute(conn,
        "INSERT OR IGNORE INTO metadata
         SELECT * FROM chipmeta.metadata
         WHERE name LIKE '%SOURCE%' OR name = 'TAXID'")
    dbExecute(conn, "DETACH DATABASE chipmeta")

    ## 2. Correct the standard entries that makeOrgPackage set incorrectly
    ##    because we passed abbreviated genus/species codes for naming, and
    ##    because goTable=NA causes it to write NOSCHEMA_DB / GID defaults.
    centralid   <- toupper(strsplit(row$pkg_prefix, "\\.")[[1L]][3L]) # "EG"
    species_tag <- paste0(toupper(substr(row$name, 1L, 1L)),
                          substr(row$name, 2L, nchar(row$name)))      # "Human"
    for (md in list(
        list("ORGANISM",  full_organism),
        list("SPECIES",   species_tag),
        list("DBSCHEMA",  row$pkg_template),
        list("CENTRALID", centralid)
    )) {
        dbExecute(conn,
            "UPDATE metadata SET value = ? WHERE name = ?",
            params = list(md[[2L]], md[[1L]]))
    }

    ## ── Populate GO tables directly from chipsrc ──────────────────────────
    ## go_bp/mf/cc     -> GO, EVIDENCE, ONTOLOGY
    ## go_bp/mf/cc_all -> GOALL, EVIDENCEALL, ONTOLOGYALL
    ##
    ## The OrgDb genes table gene-ID column name varies by AnnotationForge
    ## version. Discover it via PRAGMA, then use SQL ATTACH for the join
    ## (fast, no R data frames, negligible RAM).

    gp <- dbGetQuery(conn, "PRAGMA table_info(genes)")
    gene_col <- gp$name[grepl("text|char", gp$type, ignore.case = TRUE)][1L]
    if (is.na(gene_col))
        gene_col <- gp$name[gp$name != "_id"][1L]
    cat("  OrgDb genes gene-ID column:", gene_col, "\n")

    dbExecute(conn,
        paste0("ATTACH DATABASE '", normalizePath(chip), "' AS chip"))

    for (ont in c("bp", "mf", "cc")) {
        for (sfx in c("", "_all")) {
            tbl <- paste0("go_", ont, sfx)
            dbExecute(conn, sprintf(
                "CREATE TABLE %s (_id INTEGER, go_id TEXT, evidence TEXT)",
                tbl))
            dbExecute(conn, sprintf(
                'INSERT INTO %s
                 SELECT og.rowid, c.go_id, c.evidence
                 FROM genes og
                 JOIN chip.genes cg ON og."%s" = cg.gene_id
                 JOIN chip.%s c ON cg._id = c._id',
                tbl, gene_col, tbl))
            dbExecute(conn, sprintf(
                "CREATE INDEX %s__id ON %s(_id)", tbl, tbl))
            nr <- dbGetQuery(conn,
                sprintf("SELECT count(*) FROM %s", tbl))[[1L]]
            cat(sprintf("  %s: %d rows\n", tbl, nr))
        }
    }

    ## ── Populate pfam table from chipsrc (if present) ─────────────────────
    ## makeOrgPackage cannot create pfam correctly (schema expects _id +
    ## pfam_id; HUMAN_DB schema requires that exact structure). Inject
    ## post-hoc via ATTACH, same pattern as GO tables.
    chip_tables <- dbGetQuery(conn,
        "SELECT name FROM chip.sqlite_master WHERE type='table'")$name
    if ("pfam" %in% chip_tables) {
        n_pfam_src <- dbGetQuery(conn,
            "SELECT count(*) FROM chip.pfam")[[1L]]
        if (n_pfam_src > 0L) {
            dbExecute(conn,
                "CREATE TABLE pfam (_id INTEGER, pfam_id TEXT)")
            dbExecute(conn, sprintf(
                'INSERT INTO pfam
                 SELECT og.rowid, c.pfam_id
                 FROM genes og
                 JOIN chip.genes cg ON og."%s" = cg.gene_id
                 JOIN chip.pfam c ON cg._id = c._id',
                gene_col))
            dbExecute(conn, "CREATE INDEX pfam__id ON pfam(_id)")
            nr <- dbGetQuery(conn, "SELECT count(*) FROM pfam")[[1L]]
            cat(sprintf("  pfam: %d rows\n", nr))
        }
    }

    dbExecute(conn, "DETACH DATABASE chip")
    dbDisconnect(conn)

    src_dir
}

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

    src_dir <- tryCatch({
        if (sp %in% DB0_SUPPORTED_SPECIES) {
            build_via_db0(sp, row, chip, dbpath, outdir, bioc_ver)
        } else {
            build_via_make_org_package(sp, row, chip, outdir, bioc_ver)
        }
    }, error = function(e) {
        warning("Build failed for ", sp, ": ", conditionMessage(e), call. = FALSE)
        NULL
    })
    if (is.null(src_dir)) next

    expected_pkg <- paste0(row$pkg_prefix, ".db")

    ## Build the tarball
    cat("Running R CMD build for", expected_pkg, "\n")
    old_wd <- getwd()
    setwd(normalizePath(outdir))
    rc <- system(paste("R CMD build --no-build-vignettes",
                       shQuote(basename(src_dir))))
    setwd(old_wd)
    if (rc != 0L)
        warning("R CMD build failed for ", sp, call. = FALSE)
    else
        cat("Built:", expected_pkg, "\n")
}

## Only report tarballs created during this run (not leftovers from prior builds)
all_tarballs  <- list.files(outdir, pattern = "\\.tar\\.gz$", full.names = TRUE)
built <- basename(all_tarballs[file.info(all_tarballs)$mtime >= run_start])
if (length(built) > 0L) {
    cat("\nOrgDb tarballs produced this run:\n")
    cat(paste(" ", built, collapse = "\n"), "\n")
} else {
    stop("No tarballs were produced this run.", call. = FALSE)
}
