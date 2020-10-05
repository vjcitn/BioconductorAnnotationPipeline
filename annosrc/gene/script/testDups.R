## check for duplicate rows in chipmapsrc databases

.libPaths("~/R-libraries")
library(RSQLite)

dbs <- dir(".", "^chipmapsrc")

checkForDups <- function(dbcon, table){
    cols <- paste(dbListFields(dbcon, table), collapse = " ,")
    sql <- paste("select * from", table, "where rowid not in",
                 "(select rowid from", table, "group by",
                 cols, "having min(rowid));")
    dbGetQuery(dbcon, sql)
}

runOneDb <- function(dbname){
    con <- dbConnect(SQLite(), dbname)
    tables <- dbListTables(con)
    testvals <- sapply(tables, function(x) nrow(checkForDups(con, x)) > 0)
    dbDisconnect(con)
    if(any(testvals))
        cat(paste(gsub("\\.sqlite", "", dbname), names(testvals)[testvals]), sep = "\n")
}

tests <- sapply(dbs, runOneDb)


