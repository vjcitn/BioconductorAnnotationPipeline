## This script will just cycle through tables, and for each one, extract the
## data, add one to the starts (but not the ends) and then drop and recreate
## those same tables with the new values.


## but before I even do that, I also need to fix up the ensembl mappings so
## that I never get any "LRG" IDs in there either. - DONE

## So I have an immediate need to fix up the off by ones, and a longer term
## need to both filter out LRG IDs and to fix off-by-ones automatically next
## time.

##load libs
library("RSQLite")
##Connect to the DB
drv <- dbDriver("SQLite")

##absolute path for now to the expected location of ensembl.sqlite
dir <- file.path("/home/ubuntu/cpb_anno/AnnotationBuildPipeline/annosrc/db")
dbucsc <- file.path(dir,"gpsrc.sqlite")
db <- dbConnect(drv,dbname=dbucsc)

## list of the tables to edit:
tblList <- c("chrloc_human",
             "chrloc_mouse",
             "chrloc_rat",
             "chrloc_fly",
             "chrloc_fish",
             "chrloc_canine",
             "chrloc_bovine",
             "chrloc_worm",
            # "chrloc_pig",
             "chrloc_chicken",
             "chrloc_rhesus",
            # "chrloc_anopheles",
             "chrloc_chimp")

fixCounts = function(table){

  ## Get the schema out:
  schema <-  paste("CREATE TABLE ",table,
                   "( gene_id TEXT, chrom, start, end)", sep="")

  ## Get the data out:
  data <- dbGetQuery(db, paste("SELECT * FROM ", table, sep=""))

  ## drop the old table:
  dbGetQuery(db, paste("DROP TABLE ",table,sep=""))
  ## remake the table (now will be empty):
  dbGetQuery(db, schema)

  ## Add one to the start column ONLY (add one REGARDLESS of the +/- sign!)
  data[["start"]] <- data[["start"]] + ifelse(data[["start"]]>0, 1L, -1L)

  ## repopulate the table:
  sql <- paste("INSERT INTO", table,"VALUES ($gene_id, $chrom, $start, $end)")
  dbBegin(db)
  res <- dbSendQuery(db,sql)
  dbBind(res, data)
  dbFetch(res)
  dbClearResult(res)
  dbCommit(db)              
  
  ##ReCreate an index for each table
  ind1 = paste(table,"_gene_id_Ind",sep="")
  sql<- paste("CREATE INDEX ",ind1," ON ",table,"(gene_id);",sep="")
  dbGetQuery(db, sql)
}

for(i in seq_len(length(tblList))){
  table <- tblList[[i]]
  fixCounts(table)
}
