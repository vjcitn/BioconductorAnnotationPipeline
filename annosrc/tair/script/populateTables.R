library("RSQLite")

source("../../prepareData.R")

### This populates the gene_literature table presently, the db table has to
### have been created by the previous script.  but at least the cotnract for no
### null values in the pubmed IDs will not be honored (even if it takes 10
### mins...)


## Set up the database to be written to.
drv <- dbDriver("SQLite")
con <- dbConnect(drv,dbname="tairsrc.sqlite")

## The following calls the code in prepareData.R which will allow me to do checks
## checks to ensure that 1) all imported data is clean and formatted correctly
## and 2) log errors when data needs massaging so that I can inform people that
## there were "issues"







### Beginning of table specific code

## Gene Literature
## prepare the data for loading (scrub and log errors)
clnVals <- prepareData(file="LocusPublished2.txt", cols=3)
## insert into the DB
## Formerly (locus,gene_name,tair_acc,pubmed_id)
sqlIns <- "INSERT into pmid
           (locus,tair_acc,pubmed_id)
           VALUES (?,?,?)"
dbBegin(con)
rset <- dbSendQuery(con, sqlIns, params=unclass(unname(clnVals)))
dbClearResult(rset)
dbCommit(con)


## Enzymes this may not be needed, but its good to have a promise that things won't break...
## prepare the data for loading (scrub and log errors)
clnVals <- prepareData(file="locus_enzymes.txt", cols=2)
clnVals <- setEmptyToNull(data=clnVals, cols=c(1,2), fileName="locus_enzymes.txt")
## insert into the DB
sqlIns <- "INSERT into enzyme
           (locus,enzyme_name)
           VALUES (?,?)"
dbBegin(con)
rset <- dbSendQuery(con, sqlIns, params=unclass(unname(clnVals)))
dbClearResult(rset)
dbCommit(con)

