## 1st use wget to get the following file:
## ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping_selected.tab.gz

## Then you can wrangle it into sqlite like this:

## Get the two data columns we need by reading it in...
data <- read.table('idmapping_selected.tab', sep='\t', row.names = NULL, colClasses=c("NULL","NULL","character","NULL","NULL","NULL","character","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL"),stringsAsFactors=FALSE)



## Now lets split it up so that we can have one GO ID per gene ID...
## load(data)
listGOs <- strsplit(data$V7, "; ")
names(listGOs) <- data$V3


## Then lets unlist and make into a data.frame (this will take a minute)
library(AnnotationDbi)
result <- unlist2(listGOs)
data2 <- data.frame(gene_id = names(result), GO_id = result)


## Then insert these into a DB for fast access..

library("RSQLite")
#drv <- dbDriver("SQLite")

db <- dbConnect(SQLite(),dbname='gene2GO.sqlite')
## make a table to hold the data
sqlCreate <- "CREATE TABLE gene2GO (
                gene_id TEXT,
                GO_id TEXT);"
dbGetQuery(db, sqlCreate)
sqlCreateInd <- "CREATE INDEX g2g_gene ON gene2GO(gene_id);"
dbGetQuery(db, sqlCreateInd)

## Insert the data  etc.
sqlIns <- paste0("INSERT into gene2GO (gene_id, GO_id) VALUES ($gene_id,$GO_id)")
dbBegin(db)
rset <- dbSendPreparedQuery(db, sqlIns, data2)
dbClearResult(rset)
dbCommit(db)



## The trouble here is (anecdotally from looking at a few genes in pigs): I seem to be getting far fewer GO IDs paired with each gene from UniProt than I got from blast2GO...
## For Pigs, there are now annotations at NCBI (so I should use those).  I may also find other annotations for other organisms there now...  UNFORTUNATELY: the file for gene2go (NCBI file), has only grown from 84 megs to 115 megs in FIVE YEARS.  So: not a lot of change there.  :(
