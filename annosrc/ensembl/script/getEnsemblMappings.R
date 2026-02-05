## Populate the org-specific _gene_, _trans_ and _prot_ tables
## in ensembl.sqlite

## Get the latest ensembl to Entrez Gene mappings from biomaRt
## - no filters
## - two attributes:
##   -- "Ensembl Gene ID": ensembl_gene_id
##   -- "EntrezGene ID": entrezgene
#.libPaths("~/R-libraries")
library(biomaRt)
library(DBI)
library(RSQLite)
options(timeout = 1e5)
## -----------------------------------------------------------------------
## helpers

## Create and populate EGTable 
popEGTable = function(table, db) {    
    ##Make the table
    message(cat(paste("Creating table: ",table,sep="")))
    sql<- paste("    CREATE TABLE IF NOT EXISTS ",table, " (
        ensid VARCHAR(20) NOT NULL,
        gene_id VARCHAR(15) NOT NULL )
    ;", sep="")
    dbExecute(db, sql)

    ##Populate that table  -- change this to import from FILE
    file = paste(table,"EnsEG.tab",sep="")
    data = read.delim(file=file, header=FALSE, sep="\t",
                      colClasses=c(rep("character", 2)),
                      stringsAsFactors=FALSE)  

    sqlIns <- paste("INSERT INTO ",table,"(ensid,gene_id) VALUES (?,?);",
                    sep="")

    dbExecute(db, sqlIns, params=unclass(unname(data)))
        
    ##Two indices per table
    ind1 = paste(table,"_ens",sep="")
    sql<- paste("CREATE INDEX ",ind1," ON ",table,"(ensid);",sep="")
    dbExecute(db, sql)
    ind2 = paste(table,"_eg",sep="")
    sql<- paste("CREATE INDEX ",ind2," ON ",table,"(gene_id);",sep="")
    dbExecute(db, sql)
}


## Create and populate TRANSTable
popTRANSTable = function(table, db) {
    ##Make the table
    atable = sub("_gene_","_trans_", table)
    message(cat(paste("Creating table: ",atable,sep="")))
    sql<- paste("    CREATE TABLE IF NOT EXISTS ",atable, " (
        ensid VARCHAR(20) NOT NULL,
        ens_gene_id VARCHAR(15) NOT NULL )
    ;", sep="")
    dbExecute(db, sql)

    ## Populate that table
    file = paste(table,"_trans.tab",sep="")
    data = read.delim(file=file, header=FALSE, sep="\t",
                      colClasses=c(rep("character", 2)),
                      stringsAsFactors=FALSE)  

    sqlIns <- paste("INSERT INTO ",atable,"(ensid,ens_gene_id) VALUES (?,?);",
                    sep="")

    dbExecute(db, sqlIns, params=unclass(unname(data)))
    
        
    ##Two indices per table
    indt1 = paste(atable,"_ens",sep="")
    sql<- paste("CREATE INDEX ",indt1," ON ",atable,"(ensid);",sep="")
    dbExecute(db, sql)
    indt2 = paste(atable,"_ensgn",sep="")
    sql<- paste("CREATE INDEX ",indt2," ON ",atable,"(ens_gene_id);",sep="")
    dbExecute(db, sql)    
}

## Create and populate PROTTable 
popPROTTable = function(table, db) {
    ##Make the table
    atable = sub("_gene_","_prot_", table)
    message(cat(paste("Creating table: ",atable,sep="")))
    sql<- paste("    CREATE TABLE IF NOT EXISTS ",atable, " (
        ensid VARCHAR(20) NOT NULL,
        ens_gene_id VARCHAR(15) NOT NULL )
    ;", sep="")
    dbExecute(db, sql)

    file = paste(table,"_prot.tab",sep="")
    data = read.delim(file=file, header=FALSE, sep="\t",
                      colClasses=c(rep("character", 2)),
                      stringsAsFactors=FALSE)  

    sqlIns <- paste("INSERT INTO ",atable,"(ensid,ens_gene_id) VALUES (?,?);",
                    sep="")
    
    dbExecute(db, sqlIns, params=unclass(unname(data)))
    
        
    ##Two indices per table
    indp1 = paste(atable,"_ens",sep="")
    sql<- paste("CREATE INDEX ",indp1," ON ",atable,"(ensid);",sep="")
    dbExecute(db, sql)
    indp2 = paste(atable,"_ensgn",sep="")
    sql<- paste("CREATE INDEX ",indp2," ON ",atable,"(ens_gene_id);",sep="")
    dbExecute(db, sql)
}  
## -----------------------------------------------------------------------

## Supported species data.frame
dataset <- c("hsapiens_gene_ensembl", "rnorvegicus_gene_ensembl",
             "ggallus_gene_ensembl", "drerio_gene_ensembl",
             "celegans_gene_ensembl", "dmelanogaster_gene_ensembl",
             "mmusculus_gene_ensembl", "btaurus_gene_ensembl",
             "clfamiliaris_gene_ensembl", "scerevisiae_gene_ensembl",
             "mmulatta_gene_ensembl", "ptroglodytes_gene_ensembl",
             "agambiae_eg_gene")
sqlitetable <- c(head(dataset, n=-1), "agambiae_gene_ensembl") 
mart <-  c(rep("ENSEMBL_MART_ENSEMBL", length(dataset) - 1L), "metazoa_mart")
host <-  c(rep("https://www.ensembl.org", length(dataset) - 1L), "https://metazoa.ensembl.org")
speciesFrame <- data.frame(dataset=dataset, host=host, mart=mart,
                           sqlitetable=sqlitetable, stringsAsFactors=FALSE)

## Download from biomart and create *EnsEG.tab files:
## NOTE: This function previously (years ago?) created transdata 
##       (transcript IDs) and protdata (protein IDs) tables

## The connection to Biomart can be fraught, so harden that step
getMart <- function(biomart, host = "https://www.ensembl.org") {
    e <- simpleError("")
    while(is(e, "simpleError")) {
        e <- tryCatch(useMart(biomart, host = host), error = function(x) x)
        Sys.sleep(5)
    }
    e
}

message("creating EnsEG.tab files ...")
## apply(speciesFrame, 1, 
##       function(x) {
##     tryCatch({
## 	    if(x["host"] == "metazoa.ensembl.org")
##         egdata <- getBM(c("ensembl_gene_id", "entrezgene_id"),
##                         mart = useMart(x["mart"], x["dataset"], x["host"]))
##     else
##         egdata <- getBM(attributes=c("ensembl_gene_id", "entrezgene_id"), 
##                         mart=useEnsembl(biomart=x["mart"], dataset=x["dataset"]))
##     if (nrow(egdata) == 0L)
##         warning(paste0("no biomaRt data for ", x["dataset"]))
##     ## Remove rows with entrezgene=NA
##     egdata <- egdata[!is.na(egdata[, 2]), ]
##     write.table(egdata, 
##                 file =paste(x["sqlitetable"], "EnsEG.tab", sep=""), 
##                 quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
##    }, error = function(e) {
##     message(x["host"], " ", x["dataset"], " failed: ", conditionMessage(e))
##     }
##     )
## })

## the connection seems to be the problem, so we make one mart object and
## switch to different datasets. Except for the metazoa mart
mart <- getMart("ensembl")

apply(speciesFrame, 1, function(x) {
    if(x["host"] == "https://metazoa.ensembl.org") {
        mart2 <- getMart(x["mart"], x["host"])
        mart2 <- useDataset(x["dataset"], mart2) 
    } else {
        mart2 <- useDataset(x["dataset"], mart)
    }
    cat(x["dataset"], "\n")
    egdata <- getBM(attributes=c("ensembl_gene_id", "entrezgene_id"), mart = mart2)
    if(nrow(egdata) == 0L) warning(paste("No biomaRt data for", x["dataset"]))
    egdata <- subset(egdata, !is.na(entrezgene_id))
    write.table(egdata, file = paste0(x["sqlitetable"], "EnsEG.tab"),
                quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
})

    

## Call pop*Table for each species which adds org-specific tables to ensembl.sqlite 
drv <- dbDriver("SQLite")
db <- dbConnect(drv, dbname="ensembl.sqlite")
apply(speciesFrame, 1,
    function(x) {
        table <- x["sqlitetable"] 
        popEGTable(table, db)
        popTRANSTable(table, db)
        popPROTTable(table, db)
    })

## Marc's notes:
## Then we will have to add the tables (but NOT by adding this to the LOCAL
## bindb scripts!!!)- it needs to be present when we build organism_annotation
## stuff (so add to the bindb in organims_annotation).   All this is so that
## things end up in the .db0 pkgs...
## 
## Then eventually, things have to be added to the annotation pkgs too (add some
## code to SQLForge), so that we get 3 tables where instead there used to only be
## one.
## 
## The mappings for these packages should remain be the same (use the original
## table "ensembl" for the hybrid mapping...)  BUT I will have to add some
## comments to the documentation.
