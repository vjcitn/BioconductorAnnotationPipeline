## Makes OrgDbs, TxDbs
## NOTE: Install new db0 packages before running this script.
## ALSO NOTE: run this code using Rscript. Something like
## Rscript makeTerminalDBPkgs.R <ARGS GO HERE>
args <- commandArgs(trailingOnly = TRUE)

if(length(args) == 0L)
    stop(paste("Usage: Rscript makeTerminalDBPkgs.R <OrgDb/TxDb> <dateDir> <version>\n",
               "\t\tARGUMENTS:\n",
               "\t\tOrgDb/TxDb: If OrgDb, build the GO.db, KEGG.db and OrgDb packages\n",
               "\t\t\tif TxDb, build the TxDb packages\n",
               "\t\t\tThese are mutually exclusive arguments, and should be run\n",
               "\t\t\tin that order (OrgDb first then TxDb).\n\n",
               "\t\tdateDir: Directory to use for the output. Format is e.g. 20200910 for Sept 10, 2020\n\n",
               "\t\tVersion: Version number for TxDb packages (ignored for OrgDb, which is already set\n",
               "\t\t\tin AnnotationForge package). Format is e.g., 3.12.0\n\n",
               "\t\tAn example would be Rscript makeTerminalDBPkgs.R OrgDb 20200910 3.12.0\n\n"), call. = FALSE)
if(length(args) != 3L)
    stop(paste("This script requires three arguments! Run this script without any arguments\n",
               "to get the help.\n\n"), call. = FALSE)

whattype <- tolower(args[1])
wheretoput <- args[2]
theversion <- args[3]

if(isTRUE(is.nan(as.numeric(wheretoput))))
    stop(paste("The second argument was", wheretoput, "but should instead be something like 20200910"),
         call. = FALSE)


if(length(grep("^[0-9]+\\.[0-9]+\\.[0-9]+$", theversion)) != 1L)
    stop(paste("The third argument was",theversion,"but should instead be something like 3.11.0"),
         call. = FALSE)
              

switch(whattype, orgdb = {
    ## -----------------------------------------------------------------------
    ## Make OrgDb:
    ## -----------------------------------------------------------------------
    .libPaths("~/R-libraries")
    library(AnnotationForge)
    library(AnnotationDbi)
    
    ## 1. run copyLatest.sh to move KEGG, GO, PFAM, and YEAST to sanctionedSqlite
    
    ## 2. Create *.sqlite files in 'sanctionedSqlite'
    outDir <- "sanctionedSqlite"
    if (!file.exists(outDir))
        dir.create(outDir)
    dbBaseDir <- "/home/ubuntu/BioconductorAnnotationPipeline/annosrc/db/"
    metaDataSrc <- paste0(dbBaseDir, "metadatasrc.sqlite")
    source("EGPkgs.R")
    
    ## 3. Edit version numbers (and path if necessary) in
    ## AnnotationForge/inst/scripts/GentlemanLab/ANNDBPKG-INDEX.TXT
    ## The .TXT file has the version and location to the *.sqlite files hard coded
    ## and must be edited by hand before generating the final packages.
    ## Currently the path points to sanctionedSqlite/ so the intermediate sqlite
    ## files must be created there (done in step 2).
    
    ## Create packages in 'orgdbDir' from the *.sqlite files in 'sanctionedSqlite'
    dateDir = wheretoput
    orgdbDir <- paste(dateDir,"_OrgDbs",sep="")
    if (!file.exists(orgdbDir))
        dir.create(orgdbDir)
    sqlitefiles <- list.files(outDir, pattern="^org")
    packages <- paste(substr(sqlitefiles, 1, nchar(sqlitefiles)-7), ".db", sep="")
    ## include GO.db, PFAM.db
    packages <- c(packages, "GO.db", "PFAM.db", "Orthology.eg.db")
    makeAnnDbPkg(x=packages, dest_dir=orgdbDir)
},
txdb = {
    ## -----------------------------------------------------------------------
    ## Make TxDb:
    ## -----------------------------------------------------------------------
    library(GenomicFeatures)
    library(GenomeInfoDb)
    maintainer <- "Bioconductor Package Maintainer <maintainer@bioconductor.org>"
    author <- "Bioconductor Core Team"
    dateDir = wheretoput
    txdbDir <- paste(dateDir,"_TxDbs",sep="")
    if (!file.exists(txdbDir))
        dir.create(txdbDir)
    version <- theversion
    ##source(system.file("script","makeTxDbs.R", package="GenomicFeatures"))
    ## Do this here rather than some file in GenomicFeatures
    speciesList <- c("ce11")
    tableList <- c("ensGene")
    circ_seqs <- sapply(speciesList, function(x) {
        tmp <- getChromInfoFromUCSC(x)
        tmp[is.na(tmp[,4]),4] <- FALSE
        return(tmp[tmp[,4],1])})
    for(i in seq(along = speciesList)){
        cat(paste("Building", speciesList[i], "\n"))
        makeTxDbPackageFromUCSC(version =  version,
                                maintainer = maintainer,
                                author = author,
                                destDir = txdbDir,
                                genome = speciesList[i],
                                tablename = tableList[i],
                                circ_seqs = circ_seqs[i])
    }
    
    ## TxDbPackagesForRelease(version=version, 
    ##                        destDir=txdbDir,
    ##                        maintainer= paste0("Bioconductor Package Maintainer ",
    ##                                           "<maintainer@bioconductor.org>"),
    ##                        author="Bioconductor Core Team",
    ##                        circ_seqs = circ_seqs)

},
stop("The first argument should be either OrgDb or TxDb~", call. = FALSE))


## -----------------------------------------------------------------------
## Make ChipDb packages:
## -----------------------------------------------------------------------
## ChipDb are no longer built as of Bioconductor 3.3
#affyBaseDir <- "/home/ubuntu/cpb_anno/AnnotationBuildPipeline/srcFiles/"
#source("humanPkgs.R")
#source("mousePkgs.R")
#source("ratPkgs.R") 
#source("flyPkgs.R")
#source("arabidopsisPkgs.R")
#source("yeastPkgs.R")  
#source("eclecticChipPkgs.R")

## -----------------------------------------------------------------------
## Marc's notes:
## this last script is out of repair (but we need a new solution for tRNAs anyways)
## source(system.file("script","maketRNAFDb.R", package="GenomicFeatures"))
## TODO: I need to edit the following script so that it makes it in the
## TxDbOutDir...
## I think this has been superceded by something better (AnnotationHub)
## source(system.file("script","maketRNAFDb.R", package="GenomicFeatures"))
