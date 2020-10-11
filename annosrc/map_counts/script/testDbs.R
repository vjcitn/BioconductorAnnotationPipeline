library(RSQLite)
dbs <- dir("../../db", "chipsrc", full.names = TRUE)
dbs <- dbs[-grep("NCBI", dbs)]

## check for missing column data

checkMissDat <- function(db){
    con <- dbConnect(SQLite(), db)
    ## just tables with > 1 column
    tables <- dbListTables(con)
    tabtest <- sapply(tables, function(x) length(dbListFields(con, x)) > 1L)
    tables <- tables[tabtest]
    tables <- tables[-grep("metadata|sqlite", tables)]
    misrow <- sapply(tables, function(x) {
        cols <- dbListFields(con, x)
        cols <- paste0(cols[-1], "=''")
        if(length(cols) > 1L) cols <- paste(cols, collapse = " AND ") 
        nrow(dbGetQuery(con, paste0("select * from ", x, " where ", cols)))
    })
    dbDisconnect(con)
    tables[misrow > 0]
}

dblst <- lapply(dbs, checkMissDat)
names(dblst) <- dbs
dblst <- dblst[sapply(dblst, length) > 0] 

if(length(dblst) > 0){
    cat(paste("\n NOTE: There are", length(dblst), "databases that have missing data in one or more tables.\n",
              "This should be investigated before going forward.\nThe databases and the problematic",
              "tables are as follows:\n\n"))
    dblst
}
