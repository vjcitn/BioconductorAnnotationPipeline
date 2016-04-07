## These functions add the 'ensembl', "ensembl2ncbi', 'ensembl_prot' and
## 'ensembl_trans' tables to the chipsrc_* sqlite dbs.

library("RSQLite")
drv <- dbDriver("SQLite")
## absolute path to ensembl.sqlite
dir <- file.path("/home/ubuntu/cpb_anno/AnnotationBuildPipeline/annosrc/db")
dbe <- file.path(dir,"ensembl.sqlite")

## list of supported species... (Keeping same list as before, but names this
## time are the DB that needs to have content added to it)
speciesList = c("chipsrc_human.sqlite" = "hsapiens_gene_ensembl",
  "chipsrc_rat.sqlite" = "rnorvegicus_gene_ensembl",
  "chipsrc_chicken.sqlite" = "ggallus_gene_ensembl",
  "chipsrc_zebrafish.sqlite" = "drerio_gene_ensembl",
  "chipsrc_worm.sqlite" = "celegans_gene_ensembl",
  "chipsrc_fly.sqlite" = "dmelanogaster_gene_ensembl",
  "chipsrc_mouse.sqlite"  = "mmusculus_gene_ensembl",
  "chipsrc_bovine.sqlite" = "btaurus_gene_ensembl",
  "chipsrc_canine.sqlite" = "cfamiliaris_gene_ensembl",
  "chipsrc_rhesus.sqlite" = "mmulatta_gene_ensembl",
  "chipsrc_chimp.sqlite" = "ptroglodytes_gene_ensembl",
  "chipsrc_anopheles.sqlite" = "agambiae_gene_ensembl")

## Define a functions to connect to other DB and populate tables
## 1st one is most specialized as it has to add a new table and insert into
## another

## Make the ensembl table
makeEnsemblTable = function(db){

  ##Just in case there was no NCBI ensembl data:
  sql<- paste("CREATE TABLE IF NOT EXISTS ensembl(
               _id INTEGER REFERENCES genes(_id),
               ensid TEXT);", sep="")
  dbGetQuery(db, sql)

  ##Two indices per table
  ind1 = paste(table,"_ense",sep="")
  sql<- paste("CREATE INDEX ",ind1," ON ensembl(ensid);",sep="")
  dbGetQuery(db, sql)
  ind2 = paste(table,"_ide",sep="")
  sql<- paste("CREATE INDEX ",ind2," ON ensembl(_id);",sep="")
  dbGetQuery(db, sql)
  
}

## Make the ensembl2ncbi table
popEnsembl2EGTable = function(table){
  
  dbFile = names(table)
  db <- dbConnect(drv,dbname=file.path(dir, dbFile))
  message("joining to the ensembl.sqlite table named:", table)
  ##Drop the old tables if present.
  dbGetQuery(db, "DROP TABLE IF EXISTS ensembl2ncbi;")

  ##Make the table
  message("Creating table: ensembl2ncbi")
  sql<- paste("CREATE TABLE IF NOT EXISTS ensembl2ncbi (
               _id INTEGER REFERENCES genes(_id),
               ensid TEXT);", sep="")
  dbGetQuery(db, sql)

  ## Attach the dbe (ensembl database)
  dbGetQuery(db, paste("ATTACH DATABASE '",dbe,"' AS ens;",sep=""))

  ## Update metadata
  dbGetQuery(db, paste("DELETE FROM metadata WHERE name LIKE 'ENS%';"
                           ,sep=""))  
  dbGetQuery(db, paste("INSERT INTO metadata
                            SELECT * FROM ens.metadata;",sep=""))
  
  ## Insert data
  sqlIns <- paste("INSERT INTO ensembl2ncbi
                   SELECT ltrim(g._id,'>'), ltrim(e.ensid,'>')
                   FROM genes as g CROSS JOIN
                   ens.",table," as e
                   WHERE e.gene_id=g.gene_id", sep="")
  dbGetQuery(db, sqlIns)
  
  ##Two indices per table
  ind1 = paste(table,"_ens2n",sep="")
  sql<- paste("CREATE INDEX ",ind1," ON ensembl2ncbi(ensid);",sep="")
  dbGetQuery(db, sql)
  ind2 = paste(table,"_id2n",sep="")
  sql<- paste("CREATE INDEX ",ind2," ON ensembl2ncbi(_id);",sep="")
  dbGetQuery(db, sql)

  ##check to make sure there is an ensembl table
  test <- dbListTables(db)
  if(!"ensembl" %in% test){makeEnsemblTable(db)}
  
  ##Then fold in the changes to ensembl:
  sqlIns <- paste("INSERT INTO ensembl
                   SELECT ltrim(_id,'>'), ltrim(ensid,'>') FROM ensembl2ncbi;", sep="")
  dbGetQuery(db, sqlIns)

  ##And finally, remove duplicated rows
  sqlIns <- paste("DELETE FROM ensembl
                   WHERE rowid NOT IN
                    (SELECT rowid FROM ensembl
                     GROUP BY _id, ensid
                     HAVING min(rowid));", sep="")
  dbGetQuery(db, sqlIns)

  
  ## EXTRA FILTER STEP to remove strange LRG IDs that have begun appearing.
  if(table == "hsapiens_gene_ensembl"){
    dbGetQuery(db, "DELETE FROM ensembl
                        WHERE ensid like 'LRG%'")
  }			
  
  ##Add MAPCOUNTS for this
  dbGetQuery(db, paste("DELETE FROM map_counts
                            WHERE map_name LIKE 'ENSEMBL%';"
                           ,sep=""))  
  dbGetQuery(db, "INSERT INTO map_counts
                        SELECT 'ENSEMBL', count(DISTINCT _id)
                        FROM ensembl;")    
  dbGetQuery(db, "INSERT INTO map_counts
                        SELECT 'ENSEMBL2GENE', count(DISTINCT ensid)
                        FROM ensembl;")

  ##close out the connection to the DB we just added something to
  dbDisconnect(db)
}

## Make the ensembl_trans table
popEnsembl2TRANSTable = function(table){
  
  dbFile = names(table)
  db <- dbConnect(drv,dbname=file.path(dir, dbFile))
  table <- sub("_gene_","_trans_", table)
  message("joining to the ensembl.sqlite table named:", table)
  ##Drop the old tables if present.
  dbGetQuery(db, "DROP TABLE IF EXISTS ensembl_trans;")

  ##Make the table
  message("Creating table: ensembl_trans")
  sql<- paste("CREATE TABLE IF NOT EXISTS ensembl_trans (
               _id VARCHAR(20) NOT NULL,
               trans_id VARCHAR(20) NOT NULL );", sep="")
  dbGetQuery(db, sql)

  ## Attach the dbe (ensembl database)
  dbGetQuery(db, paste("ATTACH DATABASE '",dbe,"' AS ens;",sep=""))
  
  ## Insert data
  sqlIns <- paste("INSERT INTO ensembl_trans
                   SELECT ltrim(g._id,'>') as _id, ltrim(e.ensid,'>') as trans_id
                   FROM ensembl as g INNER JOIN
                   ens.",table," as e
                   WHERE g.ensid=e.ens_gene_id", sep="")
  dbGetQuery(db, sqlIns)
  
  ##Two indices per table
  ind1 = paste(table,"_enst",sep="")
  sql<- paste("CREATE INDEX ",ind1," ON ensembl_trans(trans_id);",sep="")
  dbGetQuery(db, sql)
  ind2 = paste(table,"_egt",sep="")
  sql<- paste("CREATE INDEX ",ind2," ON ensembl_trans(_id);",sep="")
  dbGetQuery(db, sql)
  
  ##Add MAPCOUNTS for this
  dbGetQuery(db,"DELETE FROM map_counts WHERE map_name='ENSEMBLTRANS'")
  dbGetQuery(db, "INSERT INTO map_counts
                        SELECT 'ENSEMBLTRANS', count(DISTINCT _id)
                        FROM ensembl_trans;")    
  dbGetQuery(db,"DELETE FROM map_counts WHERE map_name='ENSEMBLTRANS2GENE'")
  dbGetQuery(db, "INSERT INTO map_counts
                        SELECT 'ENSEMBLTRANS2GENE', count(DISTINCT trans_id)
                        FROM ensembl_trans;")
  
  ##close out the connection to the DB we just added something to
  dbDisconnect(db)
}

## Make the ensembl_prot table
popEnsembl2PROTTable = function(table){
  
  dbFile = names(table)
  db <- dbConnect(drv,dbname=file.path(dir, dbFile))
  table <- sub("_gene_","_prot_", table)
  message("joining to the ensembl.sqlite table named:", table)
  ##Drop the old tables if present.
  dbGetQuery(db, "DROP TABLE IF EXISTS ensembl_prot;")

  ##Make the table
  message("Creating table: ensembl_prot")
  sql<- paste("CREATE TABLE IF NOT EXISTS ensembl_prot (
               _id VARCHAR(20) NOT NULL,
               prot_id VARCHAR(20) NOT NULL );", sep="")
  dbGetQuery(db, sql)

  ## Attach the dbe
  dbGetQuery(db, paste("ATTACH DATABASE '",dbe,"' AS ens;",sep=""))
 
  ## Insert data
  sqlIns <- paste("INSERT INTO ensembl_prot
                   SELECT ltrim(g._id,'>') as _id, ltrim(e.ensid,'>') as prot_id
                   FROM ensembl as g INNER JOIN
                   ens.",table," as e
                   WHERE g.ensid=e.ens_gene_id", sep="")
  dbGetQuery(db, sqlIns)
        
  ##Two indices per table
  ind1 = paste(table,"_enst",sep="")
  sql<- paste("CREATE INDEX ",ind1," ON ensembl_prot(prot_id);",sep="")
  dbGetQuery(db, sql)
  ind2 = paste(table,"_egt",sep="")
  sql<- paste("CREATE INDEX ",ind2," ON ensembl_prot(_id);",sep="")
  dbGetQuery(db, sql)
  
  ##Add MAPCOUNTS for this
  dbGetQuery(db,"DELETE FROM map_counts WHERE map_name='ENSEMBLPROT'")
  dbGetQuery(db, "INSERT INTO map_counts
                        SELECT 'ENSEMBLPROT', count(DISTINCT _id)
                        FROM ensembl_prot;")    
  dbGetQuery(db,"DELETE FROM map_counts WHERE map_name='ENSEMBLPROT2GENE'")
  dbGetQuery(db, "INSERT INTO map_counts
                        SELECT 'ENSEMBLPROT2GENE', count(DISTINCT prot_id)
                        FROM ensembl_prot;")
  
  ##close out the connection to the DB we just added something to
  dbDisconnect(db)
}

## -----------------------------------------------------------------------
## Create 'ensembl', 'ensembl2ncbi', 'ensembl_prot' and 'ensembl_trans
## -----------------------------------------------------------------------
for (i in seq_len(length(speciesList))) {    
    table = speciesList[i]  #always the value here (not the name)
    popEnsembl2EGTable(table)
    popEnsembl2TRANSTable(table)
    popEnsembl2PROTTable(table)
}

## -----------------------------------------------------------------------
## YEAST
## -----------------------------------------------------------------------
## for structural reasons, the yeast EG data has to be inserted inside of the
## scripts that build the yeast stuff.  But we can add the trans and prot
## stuff here.
popEnsembl2TRANSTable(c("chipsrc_yeast.sqlite" = "scerevisiae_gene_ensembl"))
popEnsembl2PROTTable(c("chipsrc_yeast.sqlite" = "scerevisiae_gene_ensembl"))

## -----------------------------------------------------------------------
## WORM
## -----------------------------------------------------------------------
## Populate 'wormbase' table in chipsrc_worm.sqlite:
library(biomaRt)
mart2 <- useMart(dataset="celegans_gene_ensembl",biomart='ensembl')
wormBase <- getBM(attributes=c("ensembl_gene_id", "entrezgene", "wormbase_gene"), 
                  mart=mart2)

## Add to the table (table already exists)
## Only need to put in the wormbase IDs (matched to _ids).
## Shortest path is to extract the _ids matched to entrez gene IDs 
## then insert only what we need.
wcon <- dbConnect(dbDriver("SQLite"),
                  dbname="/home/ubuntu/cpb_anno/AnnotationBuildPipeline/annosrc/db/chipsrc_worm.sqlite")

## get the _ids values.
dbIds <- dbGetQuery(wcon, 'select * from genes')
## merge (inner join)
wormBase <- merge(dbIds, wormBase, by.x='gene_id', by.y='entrezgene')
## rename
names(wormBase) <- c('gene_id','_id','ensembl','WBid')
## insert
sql <- 'INSERT INTO wormbase values (:_id, :WBid)'
dbBegin(wcon)
dbGetPreparedQuery(wcon, sql, bind.data = wormBase)
dbCommit(wcon)
