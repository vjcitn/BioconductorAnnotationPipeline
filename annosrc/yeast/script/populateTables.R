library("RSQLite")

source("../../prepareData.R")

### This is top-level comment
## this is a comment indented with the code
# end of line comment

### This populates the gene_literature table presently, the db table has to
### have been created by the previous script.  but at least the contract for no
### null values in the pubmed IDs will not be honored 


## Set up the database to be written to.
drv <- dbDriver("SQLite")
con <- dbConnect(drv,dbname="sgdsrc.sqlite")


## The following calls the code in prepareData.R which will allow me to do checks
## checks to ensure that 1) all imported data is clean and formatted correctly
## and 2) log errors when data needs massaging so that I can inform people that
## there were "issues"


### Beginning of table specific code

## Gene Literature
## prepare the data for loading (scrub and log errors)
#clnVals <- prepareData(file="gene_literature.tab", cols=1)
clnVals <- prepareData(file="gene_literature.tab", cols=c(1,2,5,6))
## insert into the DB
sqlIns <- "INSERT into gene_literature
           (pubmed,citation,gene_name,orf,literature_topic,sgd)
           VALUES (?,?,?,?,?,?)"
dbBeginTransaction(con)
rset <- dbSendPreparedQuery(con, sqlIns, clnVals)
dbClearResult(rset)
dbCommit(con)


## SGD Features
clnVals <- prepareData(file="SGD_features.tab", cols=c(1,2))
#Col 4 must have a null value if there is an empty string so use the new func
#clnVals <- setEmptyToNull(data=clnVals, cols=c(4,5), fileName="SGD_features.tab")
clnVals <- setEmptyToNull(data=clnVals, cols=c(1,2,3,4,5,6,16), fileName="SGD_features.tab")
sqlIns <- "INSERT into sgd_features
           (sgd,feature_type,feature_qualifier,feature_name,standard_gene_name,
            alias,parent_feature_name,secondary_sgd,chromosome,
            start_coordinate,stop_coordinate,strand,genetic_position,
            coordinate_version,sequence_version,feature_description)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
dbBeginTransaction(con)
rset <- dbSendPreparedQuery(con, sqlIns, clnVals)
dbClearResult(rset)
dbCommit(con)


## ## registry genenames
## clnVals <- prepareData(file="registry.genenames.tab", cols=c(1,7))
## #Col 2 must have a null value if there is an empty string so use the new func
## clnVals <- setEmptyToNull(data=clnVals, cols=c(2,6), fileName="registry.genenames.tab")
## sqlIns <- "INSERT into registry_genenames
##            (gene_name, alias, gene_description, gene_product, phenotype, orf_name, sgd)
##             VALUES (?,?,?,?,?,?,?)"
## dbBeginTransaction(con)
## rset <- dbSendPreparedQuery(con, sqlIns, clnVals)
## dbClearResult(rset)
## dbCommit(con)
