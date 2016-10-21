## So I need to 'get the blast2Go data now from UniProt instead of
## from blast2Go.  

## This simplifies things a LOT since I no longer will need to
## preprocess out .tab files OR map things based on refseq and genbank
## (I will already have entrez gene IDs).


## So now this script will 1) call makeOrgPackageFromNCBI() and then
## 2) use the tax IDs for the organisms of interest to just get the
## direct entrez gene to GO mappings extracted out and the put those
## tables right into the appropriate databases (with correct
## metadata).  3) remove all references to blast2GO from metadata
## inserts etc.

## Note: the code in makeOrgPackageFromNCBI already exists for
## flattening the GO data before inserting it into the appropriate
## downstream place.

library("DBI")
library("RSQLite")

scriptDir = "/home/ubuntu/cpb_anno/AnnotationBuildPipeline/annosrc/BioconductorAnnotationPipeline/annosrc/blast2go/script"
setwd(scriptDir)

## get the raw data from uniprot it and populate it into the DB.
if (!file.exists("uniprot2go.sqlite")) {
    message("This will take a long while we download a LOT of GO anotations")
    ##Connect to the new DB
    drv <- dbDriver("SQLite")
    db <- dbConnect(drv,dbname="uniprot2go.sqlite")
    AnnotationForge:::.downloadAndPopulateAltGOData(db, scriptDir, rebuildCache=TRUE)
} else {
    ##Connect to the new DB
    drv <- dbDriver("SQLite")
    db <- dbConnect(drv,dbname="uniprot2go.sqlite")
}

## make simple sub-tables that contain the data bases from these organisms:
taxIDList = c("Canis_familiaris"="9615",
                "Sus_Scrofa"="9823",
                "Anopheles_gambiae"="180454",
                "Xenopus_laevis"="8355",
                "Macaca_mulatta"="9544",
                "Pan_troglodytes"="9598")


## name = names(taxIDList)[[1]]
## taxId = taxIDList[[1]]

## put tables in it that contain GO2EG mappings (Here we might reuse the
## two charactter vectors that list both the species names and the
## filenamed for the chipMapSrc DBs... - but the usage would be quite different from what I started at)

## the tables need to look like this (at a minimum)
## eg_id       go_id     
## ----------  ----------
## 1267437     GO:0005829
## 1267437     GO:0010821

## and be named like this: Anopheles_gambiae_eg2go


## helper to split a two column data.frame by splitting either column...
splitBy <- function(data, splitCol=1){
    splits <- strsplit(data[[splitCol]],split="; ")
    splitLens <- unlist(lapply(splits, length))

    if(splitCol==1){
        dups <- rep(data[[2]], times=splitLens)
        data <- data.frame(eg_id=unlist(splits), go_id=dups,
                           stringsAsFactors=FALSE)
    }
    if(splitCol==2){
        dups <- rep(data[[1]], times=splitLens)
        data <- data.frame(eg_id=dups, go_id=unlist(splits),
                           stringsAsFactors=FALSE)
    }
    data
}

makeGOTable <- function(taxId, name, db){

    ## extract and unpack the data
    sql <- paste0("SELECT EntrezGene, GO FROM altGO WHERE NCBItaxon = '",
                  taxId,"'")
    res <- dbGetQuery(db, sql)
    
## 1st fix: DROP values where there is no entrez gene ID
    res <- res[res$EntrezGene!="",]
    
## new helper to split two column data frames at will...
    data <- splitBy(res, splitCol=2)
## then split it the other way too fully expand it:
    data <- splitBy(data, splitCol=1)

    
    ## Then make a new table with the correct table name
    tableName <- paste0(name, "_eg2go")
    sql <- paste0("CREATE TABLE ",tableName,
                  " (eg_id VARCHAR(20) NOT NULL, go_id VARCHAR(20) NOT NULL)")
    dbGetQuery(db, sql)
   
    ## then populate table
    sqlIns <- paste("INSERT INTO ",tableName,
                    " (eg_id, go_id) VALUES (?,?);", sep="")
    dbBegin(db)
    rslt <- dbSendPreparedQuery(db, sqlIns, data)
    dbClearResult(rslt)
    dbCommit(db)

    ## and index both columns
    sql1<- paste("CREATE INDEX ",tableName,"_eg ON ",tableName,
                "(eg_id);",sep="")
    dbGetQuery(db, sql1)
    sql2<- paste("CREATE INDEX ",tableName,"_go ON ",tableName,
                "(go_id);",sep="")
    dbGetQuery(db, sql2)    
}

## call that function using mapply()
mapply(makeGOTable, taxId=taxIDList, name=names(taxIDList),
       MoreArgs=list(db=db))



## And then put some metadata in too.
dbGetQuery(db, "CREATE TABLE metadata (name TEXT, value TEXT)")

dbGetQuery(db, "INSERT INTO metadata VALUES('UNIPROTGOSOURCENAME', 'UNIPROTGO')")
 
dbGetQuery(db, paste0("INSERT INTO metadata VALUES('UNIPROTGOSOURCEDATE', '",date(),"')"))

dbGetQuery(db, "INSERT INTO metadata VALUES('UNIPROTGOSOURCEURL', 'ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping_selected.tab.gz')")


## put the file into /db
file.copy("uniprot2go.sqlite", "../../db", overwrite=TRUE)

## But also back up the original DL file into a dir with an
## appropriate datestamp.
## make a dir
date <- unlist(strsplit(date(),split=" "))
date <- date[c(1:3, 5)] ## remove the time
date  <- paste(date, collapse="_")
dirName <- paste0("../UniprotToGOData",date)
dir.create(dirName)
## then copy that gigantic file into it
file.copy("idmapping_selected.tab.gz", dirName, overwrite=TRUE)
file.remove("idmapping_selected.tab.gz")
file.copy("uniprot2go.sqlite", dirName, overwrite=TRUE)
file.remove("uniprot2go.sqlite")
