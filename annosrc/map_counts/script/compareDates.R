##Finally, I will also need to write a little utility to compare two dates
##(two most recent can be the default), and see if there are any major
##changes.  THEN I will be done with the 1st version of this task.

library(DBI)
library("RSQLite")
drv <- dbDriver("SQLite")
db_map_counts <- dbConnect(drv,dbname="../../db/map_counts.sqlite")


##just grab the dates from the KEGG table (any table should work)
sql <- "SELECT date from KEGG;"
dates = as.character(t(as.matrix(dbGetQuery(db_map_counts, sql))))


##THEN, figure out which dates are the oldest.

cdates = gsub("_"," ", dates)
## Dates = as.Date(dates, "%a %b %d")


##1st part will format the date portion
## format(Sys.Date(), "%a %b %d")
##once formatted to be of class "Date" instead of strings, we can compare them


##append some fakey dates for testing.
## foo = "Wed Jun 10 18:01:16 2010"
## bar = "Wed Jun 22 18:01:16 2009"
## sna = "Mon May 03 18:01:16 2009"
## dates = c(dates,foo, bar, sna)


subDates = paste(substr(cdates,5,10),substr(cdates,21,24))
Dates = as.Date(subDates, "%b %d %Y")

sortedDates = sort(Dates)
mostRecentDate = max(Dates)
nextMostRecentDate = sortedDates[length(sortedDates)-1]

mRInd = Dates %in% mostRecentDate
nMRInd = Dates %in% nextMostRecentDate

mRdate = dates[mRInd]
nMRdate = dates[nMRInd]

message("Comparing data from ",mRdate," to data from ",nMRdate,".")


##FIXME: Of course this could all break if the last two dates are on the same day...




##And then I have to compare the values from the two most recent dates to see if things have changed by a large amount
##I need to get a list of the tableNames
sqlTables <- "SELECT name FROM sqlite_master WHERE type='table';"
tables = as.character(t(as.matrix(dbGetQuery(db_map_counts, sqlTables))))

##Check each table for anything suspicious.
for(i in seq_len(length(tables))){

    tableName = tables[i]
    
    sqlmR <- paste("SELECT * FROM ",tableName," WHERE date = '",mRdate,"';", sep="")
    sqlnMR <- paste("SELECT * FROM ",tableName," WHERE date = '",nMRdate,"';", sep="")

    mRData = dbGetQuery(db_map_counts, sqlmR)
    nMRData = dbGetQuery(db_map_counts, sqlnMR)

    ##As long as the relevant nMRData is not NA, then we can compare the two...
    ##I have to 1st make sure that these two rows are sorted the same however.
    comboData = rbind( mRData[,sort(names(mRData))], nMRData[,sort(names(nMRData))]) 
    
    for(n in seq_len(dim(comboData)[2])){
        mR = comboData[1,n]
        nMR = comboData[2,n]
        ## print(paste("mR is: ", mR, sep=""))
        ## print(paste("nMR is: ", nMR, sep=""))
        if(!is.na(nMR) && names(comboData)[n]!="date"){
            ratio = mR/nMR
            ## print(paste("ratio is: " ,ratio, sep = ""))
            if(!is.na(ratio) && ratio < (9/10)){## If less than 90% of the stuff that was here last time is not here this time: then cry wolf.
                warning(paste("Ratio of new to old mappings is only: ",ratio," in ", colnames(comboData)[n], " on database: ", tableName, sep=""))
            }
        }
    }
}


