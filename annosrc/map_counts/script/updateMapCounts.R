## Each time this script is run a new row is added to all tables 
## in db/map_counts.sqlite. The script visits the map_counts table
## in each organism chipsrc_*.sqlite file and transfers those
## numbers to the common db/map_counts.sqlite.

##1st thing is to list all the sqlite files that start with chipsrc and end
##with sqlite.

files = list.files("../../db/")
ind = grep("^chipsrc_", files, perl=TRUE)
ind2 = grep("^GO.sqlite$", files, perl=TRUE)
ind3 = grep("^KEGG.sqlite$", files, perl=TRUE)
ind4 = grep("^PFAM.sqlite$", files, perl=TRUE)
files = files[c(ind,ind2,ind3,ind4)]


##then I need to open each one of these (close them afterwards) while I have
##it open I will grab out the map_counts data each so that you have the names
##for the fields that you want.

## select map_name from map_counts;
.libPaths("~/R-libraries")
library(DBI)
library("RSQLite")
drv <- dbDriver("SQLite")
db_map_counts <- dbConnect(drv,dbname="../../db/map_counts.sqlite")

#Lock the data/time stamp down to a single value for the entire session
date = date()
date =gsub(" ","_", date)


makeFieldStrs = function(fields){
        fieldStr = character()
        for(j in seq_len(length(fields))){
            if(j<length(fields)){fieldStr = paste(fieldStr,"      ",fields[j], "INTEGER,\n", sep=" ")}
            else fieldStr = paste(fieldStr,"      ",fields[j], "INTEGER\n", sep=" ")
        }
        return(fieldStr)
}



makeTable = function(fields,tableName){
        fieldStr = makeFieldStrs(fields)
    
        ##Then we just need to make a table like this (NOTE don't mess with the spacing)
        sql<- paste("    CREATE TABLE IF NOT EXISTS ",tableName, " (
        date VARCHAR(24) UNIQUE,
",fieldStr,
                    ");", sep="")
        ##And then the easiest thing to do is to probably just try to MAKE the table in a LOCAL DB right on the fly...
        dbExecute(db_map_counts, sql)

}


updateTable  = function(fields, tableName, date, mapCountVals, numRows){
        ##Add a new row:
        valStr = character()
        for(k in seq_len(numRows)){
            rowInd = mapCountVals[,1] %in% fields[k]
            if(k<numRows){valStr = paste(valStr, "'",mapCountVals[rowInd,2],"',", sep="")}
            else{ valStr = paste(valStr,"'",mapCountVals[rowInd,2],"'", sep="")}
        }
        
        ##print(mapCountVals)
        ##print(length(mapCountVals))
        ##Now we just have to add the appropriate content to the current table
        fieldStr = makeFieldStrs(fields)
        fieldStr = gsub("INTEGER\n","",gsub("INTEGER,\n ",",",fieldStr))
        ##print(fieldStr)
        sql <- paste("INSERT INTO ",tableName, "(date,",fieldStr,") VALUES ('",date,"', ",valStr," );", sep="")
        ##print(sql)
        dbExecute(db_map_counts, sql)
}


expandTable = function(tableName, oldFields, newFields){
    ##Compare to learn IDs of the new cols
    ##newFields is always > oldFields
    cols = newFields[!newFields %in% oldFields]
    
    ##Have to add the cols one at a time, so loop.
    for(m in seq_len(length(cols))){
        ##Then format the list of columns
        fieldStr = makeFieldStrs(cols[m])
        ##Use ALTER TABLE to add new cols
        sql <- paste("ALTER TABLE ",tableName," ADD COLUMN ",fieldStr,";",sep="")
        dbExecute(db_map_counts, sql)
    }
}


for(i in seq_len(length(files))){
        ##Connect
        db <- dbConnect(drv,dbname=paste("../../db/",files[i],sep=""))
        ##Create table name and contents
        tableName = sub(".sqlite","",files[i])
        sql <- "select map_name from map_counts;"
        fields = as.character(t(as.matrix(dbGetQuery(db, sql))))

        makeTable(fields, tableName)## something here fails for ecoli..
        
        ##Now we get the stuff from the present map_counts table
        ##Notice that we get things EXPLICITLY here
        ##(because we don't know what order SQL will give us stuff back in...)
        sql <- "SELECT * FROM map_counts;"
        mapCountVals =  dbGetQuery(db, sql)
        numRows = dim(mapCountVals)[1] ##number of rows
        
        ##in the case where a table exists already but has changed size, I will want to remake it...
        sql <- paste("select * from ",tableName,";", sep="")
        oldFields = colnames(dbGetQuery(db_map_counts, sql))
        oldFields = oldFields[-grep("date", oldFields)]
        newFields=as.character(t(as.matrix(mapCountVals[1])))
        if(length(oldFields) < numRows && length(oldFields)!=0){
          ##then we have to remake things so that we have a bigger table that
          ##still holds the old data
            expandTable(tableName, oldFields, newFields)
        }

        ##Then add all the new data to all the tables.
        updateTable(fields, tableName, date,  mapCountVals, numRows)
        
        ##Then we have to close the connection. (IMPORTANT!)
        dbDisconnect(db)
    }




##As part of the design, I want to make sure to check in the results of
##running this script once per major build.  Since there may be some testing
##that occurs in between I may also want to provide a tool that will just yank
##out all the records that match a particular range of dates so that I can
##easily clean up the DB before such a check in.


