################################################################################
## This is just a set of scripts that will get IDs that match with entrez gene
## IDs and then populate them into a DB.

## Call this script from src_build.sh, and AFTER organism_annotation/script.sh

## 1) Get a set of entrez gene IDs for a species (and tax ID) (
## (extract ALL of this information from the relevant chipsrc DB)
.libPaths("~/R-libraries")
library("RSQLite")
library("UniProt.ws")
library("httr")
## keep getting cURL errors intermittently, so try retry package
library(retry)
drv <- dbDriver("SQLite")

## Path to all the Db's.
dir <- file.path("/home/ubuntu/BioconductorAnnotationPipeline/annosrc/db")

## For now just get data for the ones that we have traditionally supported
## I don't even know if the other species are available...
speciesList = c("chipsrc_human.sqlite",
  "chipsrc_rat.sqlite",
  "chipsrc_chicken.sqlite",
  "chipsrc_zebrafish.sqlite",
  "chipsrc_mouse.sqlite",
  "chipsrc_bovine.sqlite")

## Modified to get uniprots where we may not have an IPI
getuniProtAndIPIs <- function(genes, dbFile){

  # split genes into groups of 100,000 since that's the max input for mapUniProt
  splitDat <- split(genes, ceiling(seq_along(genes) / 100000))

  # single output
  singleOut <- lapply(splitDat, function(x) {
    UniProt.ws::mapUniProt(from='GeneID',to='UniProtKB',query=x)
  })

  # concatenate rows
  ups <- do.call(rbind, singleOut)
  rownames(ups) <- NULL
  ## NOW hack in the old IPI data
  baseDir <- "/home/ubuntu/BioconductorAnnotationPipeline/annosrc/uniprot/OLDCHIPSRC"
  con <- dbConnect(drv,dbname=file.path(baseDir, dbFile))
  pf_ipi <- dbGetQuery(con, 'select g.gene_id AS P_ENTREZGENEID, p.ipi_id AS P_IPI from pfam AS p, genes AS g WHERE p._id=g._id')
  ps_ipi <- dbGetQuery(con, 'select g.gene_id AS P_ENTREZGENEID, p.ipi_id AS P_IPI from prosite AS p, genes AS g WHERE p._id=g._id')
  ips <- unique(rbind(pf_ipi, ps_ipi))
  
  ## return as a single frame.
  ## Currently, I use an inner join here b/c DB is gene centric 
  base <- merge(ups, ips, by.x ="From", by.y ="P_ENTREZGENEID", all.x=TRUE)
  colnames(base)[which(names(base) == "From")] <- "P_ENTREZGENEID"
  colnames(base)[which(names(base) == "To")] <- "ACC"
  base
}


getOneToMany <- function(taxId, type=c("pfam","prosite","smart")){ 
  type <- match.arg(type)
  #url <- paste0("http://www.uniprot.org/uniprot/?query=organism_id:",taxId,"&format=tab&columns=id,database(")
  #fullUrl <- paste0(url,type,")")
  #message("Reading in data from UniProt web services.")
  #dat <- read.delim(fullUrl, stringsAsFactors=FALSE)
  #dat <- UniProt.ws:::.tryReadResult(fullUrl)

  temp <- tempfile()
  with_verbose({
    resp <- retry(GET(paste0("https://rest.uniprot.org/uniprotkb/stream?compressed=true&fields=accession%2Cxref_",
                             type,"&format=tsv&query=%28taxonomy_id%3A",taxId,"%29"), write_disk(temp, TRUE)),
                  when = "INTERNAL_ERROR")})
  dat <- read.delim(temp)

  colnames(dat) <- c('ids', 'ids2')
  ## split up the strings
  dat[[2]] <- strsplit( as.character(dat[[2]]), split=";")
  ## get number of things matched to each ID in col 1
  lens <- lengths(dat[[2]])
  ## make factor based on dat[[1]], repeated lens times
  ids <- rep.int(dat[[1]],lens) ## this excludes ones where lens==0
  ids2 <- unlist(dat[[2]], use.names = FALSE)
  if(length(ids)==length(ids2)){
    res <- cbind(ids,ids2)
  }else{
    stop("getOneToMany: ids != ids2")
  }
  
  ## recover dat[[1]] where lens==0
  rem <- dat[lens==0,]
  rem[[2]] <- NA ## these values are all NA
  rbind(res, rem)
}


## Maybe have to stop using getOneToMany here and start with this instead (slower) ???
## taxId(UniProt.ws) <- curTaxId
## k <- keys(UniProt.ws, keytype="UNIPROTKB")
## select(UniProt.ws, k, columns="PFAM", keytype="UNIPROTKB")

getData <- function(dbFile, db){
  ## look up the tax ID
  taxId <- dbGetQuery(db, "SELECT value FROM metadata WHERE name='TAXID'")
  ## look up the entrez gene IDs
  if(dbFile != "chipsrc_arabidopsis.sqlite"){ ## if its not arabidopsis
    genes <- dbGetQuery(db, "SELECT gene_id FROM genes")
  }else{
    genes <- dbGetQuery(db, "SELECT gene_id FROM entrez_genes")
  }
  genes <- as.character(t(genes))

  ## ## get the UniProt and IPI Id's (merged into a table)
  base <- getuniProtAndIPIs(genes, dbFile)
  ## NO MORE IPIs! (temporarily we will populate with values from last time)
  colnames(base)[which(names(base) == "From")] <- "P_ENTREZGENEID"
  colnames(base)[which(names(base) == "Entry")] <- "ACC"


  ## get the pfam Id's
  pfam <- getOneToMany(taxId, type="pfam")
  colnames(pfam) <- c("ACC", "PFAM")
  ## and the prosite Id's.
  prosite <- getOneToMany(taxId, type="prosite")
  colnames(prosite) <- c("ACC", "PROSITE")
  
  
  
  ## merge it all together. # 3 above - then return a list of length two
  ## Currently I am using an inner join here b/c the DB is gene centric, so
  ## there is no benefit fo haveing pfam/UniProt accessions that are not
  ## connected to an entrez gene
  lst <- list()
  lst[[1]] <- merge(base, pfam, by.x="ACC", by.y="ACC") #,all=TRUE)
  lst[[2]] <- merge(base, prosite, by.x="ACC", by.y="ACC") #,all=TRUE)
  names(lst) <- c("pfam","prosite")

## finally, be sure to drop the UniProt IDS?  I think we should keep
## em...  ;) Later on I can make use of them to enhance the devel annots.
  lst
}


## ## make PFAM and Prosite tables
makePFAMandPrositeTables <- function(db){
    dbExecute(db, "DROP TABLE IF EXISTS pfam;")
    sql <-  "CREATE TABLE pfam (
     _id INTEGER REFERENCES genes(_id),
     ipi_id TEXT,
     pfam_id TEXT
    );"
    dbExecute(db, sql)
    sql <-  "CREATE INDEX c20 ON pfam(_id);"
    dbExecute(db, sql)
    dbExecute(db, "DROP TABLE IF EXISTS prosite;")
    sql <-  "CREATE TABLE prosite (
     _id INTEGER REFERENCES genes(_id),
     ipi_id TEXT,
     prosite_id TEXT
    );"
    dbExecute(db, sql)
    sql <-  "CREATE INDEX c21 ON prosite(_id);"
    dbExecute(db, sql)
}


## 4) For each species, get the data, using getData, and then go
## straight to humansrc.sqlite etc and populate the pfam and prosite
## tables. ALSO, be sure to add entries to metadata about where the data came
## from.  (and remove relevant code from the scripts).  - See the bindb.R
## script in ensembl/script.


## Helper for doing inserts from pfam
doInserts <- function(db, table, data){

  ## make a temp pfam table pfamt
  sqlDrop <-paste0("DROP TABLE IF EXISTS ",table,"t;")
  dbExecute(db, sqlDrop)

  sqlCreate <- paste0("CREATE TABLE ",table,"t (
                gene_id TEXT,
                ipi_id TEXT,
                ",table,"_id TEXT);")
  dbExecute(db, sqlCreate)

  
  ## 1st insert for pfam
  sqlIns <- paste0("INSERT into ",table,"t
             (gene_id, ipi_id, ",table,"_id)
             VALUES ($P_ENTREZGENEID,$P_IPI,$",toupper(table),")")
  dbBegin(db)
  values <- c("P_ENTREZGENEID", "P_IPI", toupper(table))
  rset <- dbSendQuery(db, sqlIns, params=unclass(data[values]))
  dbClearResult(rset)
  dbCommit(db)

  ## then insert into the real pfam table
  sqlIns2 <- paste0("INSERT INTO ",table,"
                SELECT DISTINCT g._id as _id, i.ipi_id, i.",table,"_id
                FROM genes as g, ",table,"t as i
                WHERE g.gene_id=i.gene_id
                ORDER BY _id")
  dbExecute(db, sqlIns2)

  
  ## then drop the table
  sqlDrop <- paste0("DROP TABLE ",table,"t")
  dbExecute(db, sqlDrop)
  
}


## So: loop, where we call getData and then just populate the tables
require("RSQLite")

for(species in speciesList){
  ## DB connection
  browser()
  db <- dbConnect(drv,dbname=file.path(dir, species))
  
  message("Getting data for:",species)
  res <- getData(species, db) 

  message("Making tables for pfam and prosite")
  makePFAMandPrositeTables(db)
  
  message("Inserting data for:",species)
  ## Now I need to insert the data:
  doInserts(db, "pfam", res[["pfam"]])
  doInserts(db, "prosite", res[["prosite"]])
  
  ## And then I need to add metadata:
  date <- date()
  url <- "http://www.UniProt.org/"
  name <- "Uniprot"
  
  dbExecute(db, "DELETE FROM metadata where name ='UPSOURCENAME' ")   
  sqlMeta1 <- paste0("INSERT INTO metadata (name,value) VALUES ('UPSOURCENAME','",name,"')")
  dbExecute(db, sqlMeta1)
  
  dbExecute(db, "DELETE FROM metadata where name ='UPSOURCEURL' ")   
  sqlMeta2 <- paste0("INSERT INTO metadata (name,value) VALUES ('UPSOURCEURL','",url,"')")
  dbExecute(db, sqlMeta2)
  
  dbExecute(db, "DELETE FROM metadata where name ='UPSOURCEDATE' ")   
  sqlMeta3 <- paste0("INSERT INTO metadata (name,value) VALUES ('UPSOURCEDATE','",date,"')")
  dbExecute(db, sqlMeta3)
  dbExecute(db,"DELETE FROM metadata WHERE name LIKE 'IPISOURCE%'")

  
  ## And don't forget the map_counts for PROSITE AND PFAM
  dbExecute(db, "DELETE FROM map_counts where map_name ='PFAM' ")   
  sqlmapcnt1 <- "INSERT INTO map_counts
                 SELECT 'PFAM', count(DISTINCT _id)
                 FROM pfam;"
  dbExecute(db, sqlmapcnt1)

  dbExecute(db, "DELETE FROM map_counts where map_name ='PROSITE' ")   
  sqlmapcnt2 <- "INSERT INTO map_counts
                 SELECT 'PROSITE', count(DISTINCT _id)
                 FROM prosite;"
  dbExecute(db, sqlmapcnt2)

  ## ALSO: modify the map_metadata (1st drop the PFAM and prosite entries
  dbExecute(db, "DELETE FROM map_metadata where map_name ='PFAM' ") 
  dbExecute(db, "DELETE FROM map_metadata where map_name ='PROSITE' ")
  ## then put our own entries in...
  sqlPFMM <- paste0( "INSERT INTO map_metadata (map_name, source_name, ",
                    "source_url, source_date) VALUES ('PFAM','",name,
                    "','",url,"','",date,"')")
  dbExecute(db, sqlPFMM)
  sqlPSMM <- paste0( "INSERT INTO map_metadata (map_name, source_name, ",
                    "source_url, source_date) VALUES ('PROSITE','",name,
                    "','",url,"','",date,"')")
  dbExecute(db, sqlPSMM)
  
}

## 5) ALSO: Be sure to also add metadata to each DB as we loop!

## 6) ALSO: Be sure to add map counts for PFAM and PROSITE too.



################################################################################
################################################################################
################################################################################
################################################################################
## Now for special treatment for missing stuff from yeast.
################################################################################
################################################################################
################################################################################
################################################################################

getuniProt <- function(genes, dbFile){
    UniProt.ws::mapUniProt(from='GeneID',to='UniProtKB',query=genes)
}

getYeastData <- function(dbFile, db){
  ## look up the tax ID
  taxId <- dbGetQuery(db, "SELECT value FROM metadata WHERE name='TAXID'")
  ## look up the entrez gene IDs
  genes <- dbGetQuery(db, "SELECT gene_id FROM genes")
  genes <- as.character(t(genes))

  ## ## get the UniProt
  base <- getuniProt(genes, dbFile)
  colnames(base)[which(names(base) == "From")] <- "P_ENTREZGENEID"
  colnames(base)[which(names(base) == "Entry")] <- "ACC"

  ## get the pfam Id's
  pfam <- getOneToMany(taxId, type="pfam")
  colnames(pfam) <- c("ACC", "PFAM")
  pfam <- pfam[!is.na(pfam$PFAM),]
  ## And smart IDs
  smart <- getOneToMany(taxId, type="smart")
  colnames(smart) <- c("ACC", "SMART")
  smart <- smart[!is.na(smart$SMART),]
  
  
  ## merge it all together. # 3 above - then return a list of length two
  ## Currently I am using an inner join here b/c the DB is gene centric, so
  ## there is no benefit fo haveing pfam/UniProt accessions that are not
  ## connected to an entrez gene
  lst <- list()
  lst[[1]] <- merge(base, pfam, by.x="ACC", by.y="ACC") #,all=TRUE)
  lst[[2]] <- merge(base, smart, by.x="ACC", by.y="ACC") #,all=TRUE)
  names(lst) <- c("pfam","smart")

## finally, be sure to drop the UniProt IDS?  I think we should keep
## em...  ;) Later on I can make use of them to enhance the devel annots.
  lst
}



doYeastInserts <- function(db, table, data){

  ## make a temp pfam table pfamt
  sqlDrop <-paste0("DROP TABLE IF EXISTS ",table,"t;")
  dbExecute(db, sqlDrop)

  sqlCreate <- paste0("CREATE TABLE ",table,"t (
                gene_id TEXT,
                ",table,"_id TEXT);")
  dbExecute(db, sqlCreate)
  
  ## 1st insert
  sqlIns <- paste0("INSERT into ",table,"t
             (gene_id, ",table,"_id)
             VALUES ($P_ENTREZGENEID,$",toupper(table),")")
  dbBegin(db)
  values <- c("P_ENTREZGENEID", toupper(table))
  rset <- dbSendQuery(db, sqlIns, params=unclass(data[values]))
  dbClearResult(rset)
  dbCommit(db)

  ## then insert into the real table
  sqlIns2 <- paste0("INSERT INTO ",table,"
                SELECT DISTINCT g._id as _id, i.",table,"_id
                FROM genes as g, ",table,"t as i
                WHERE g.gene_id=i.gene_id
                ORDER BY _id")
  dbExecute(db, sqlIns2)

  ## then drop the table
  sqlDrop <- paste0("DROP TABLE ",table,"t")
  dbExecute(db, sqlDrop)
  
}


## just one more run through to just do what is needed to get pfam into yeast.

species <- 'chipsrc_yeast.sqlite'
## DB connection
db <- dbConnect(drv,dbname=file.path(dir, species))
message("Getting data for:",species)
res <- getYeastData(species, db) 


## Add pfam table
message("Making table for pfam") 

dbExecute(db, "DROP TABLE IF EXISTS pfam;")
sql <-  "CREATE TABLE pfam (
     _id INTEGER NOT NULL,
     pfam_id CHAR(7) NOT NULL,
     FOREIGN KEY (_id) REFERENCES sgd (_id)
    );"
dbExecute(db, sql)
sql <-  "CREATE INDEX pf1 ON pfam(_id);"
dbExecute(db, sql)

## And a smart table too
message("Making table for smart") 
dbExecute(db, "DROP TABLE IF EXISTS smart;")
sql <-  "CREATE TABLE smart (
     _id INTEGER NOT NULL,
     smart_id CHAR(7) NOT NULL,
     FOREIGN KEY (_id) REFERENCES sgd (_id)
    );"
dbExecute(db, sql)
sql <-  "CREATE INDEX sm1 ON smart(_id);"
dbExecute(db, sql)

message("Inserting data for:",species)
## Now I need to insert the data:
doYeastInserts(db, "pfam", res[["pfam"]])
doYeastInserts(db, "smart", res[["smart"]])
  
## And then I need to add metadata:
date <- date()
url <- "http://www.UniProt.org/"
name <- "Uniprot"
  
dbExecute(db, "DELETE FROM metadata where name ='UPSOURCENAME' ")   
sqlMeta1 <- paste0("INSERT INTO metadata (name,value) VALUES ('UPSOURCENAME','",name,"')")
dbExecute(db, sqlMeta1)
  
dbExecute(db, "DELETE FROM metadata where name ='UPSOURCEURL' ")   
sqlMeta2 <- paste0("INSERT INTO metadata (name,value) VALUES ('UPSOURCEURL','",url,"')")
dbExecute(db, sqlMeta2)
  
dbExecute(db, "DELETE FROM metadata where name ='UPSOURCEDATE' ")   
sqlMeta3 <- paste0("INSERT INTO metadata (name,value) VALUES ('UPSOURCEDATE','",date,"')")
dbExecute(db, sqlMeta3)
dbExecute(db,"DELETE FROM metadata WHERE name LIKE 'IPISOURCE%'")

  
## And don't forget the map_counts for PROSITE AND PFAM
dbExecute(db, "DELETE FROM map_counts where map_name ='PFAM' ")   
sqlmapcnt1 <- "INSERT INTO map_counts
                 SELECT 'PFAM', count(DISTINCT _id)
                 FROM pfam;"
dbExecute(db, sqlmapcnt1)

dbExecute(db, "DELETE FROM map_counts where map_name ='SMART' ")   
sqlmapcnt1 <- "INSERT INTO map_counts
                 SELECT 'SMART', count(DISTINCT _id)
                 FROM smart;"
dbExecute(db, sqlmapcnt1)


## ALSO: modify the map_metadata (1st drop the PFAM and prosite entries
dbExecute(db, "DELETE FROM map_metadata where map_name ='PFAM' ") 
## then put our own entries in...
sqlPFMM <- paste0( "INSERT INTO map_metadata (map_name, source_name, ",
                  "source_url, source_date) VALUES ('PFAM','",name,
                  "','",url,"','",date,"')")
dbExecute(db, sqlPFMM)

dbExecute(db, "DELETE FROM map_metadata where map_name ='SMART' ") 
## then put our own entries in...
sqlPFMM <- paste0( "INSERT INTO map_metadata (map_name, source_name, ",
                  "source_url, source_date) VALUES ('SMART','",name,
                  "','",url,"','",date,"')")
dbExecute(db, sqlPFMM)
message("Done with ",species)
