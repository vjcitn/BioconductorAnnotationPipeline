##This little R script just exists to read in the contents of the
##../12-Jul-2007/IPDATA/ dir, and then for each file, it takes the
##name of that file, reads splits the name into two parts, and then
##makes a table based on the name of the file, then that file is
##loaded up into the table.

#In script I will call this by just going to the current dir with the
#IPDATA dir (eg above) and just running it.
.libPaths("~/R-3.6.1")
library("RSQLite")
source("./script/prepareData.R")
file.remove("inparanoid.sqlite")

##Make some generic tables to start.
drv <- dbDriver("SQLite")
con <- dbConnect(drv,dbname="inparanoid.sqlite")

sql<- paste("    CREATE TABLE IF NOT EXISTS metadata (
      name VARCHAR(80) PRIMARY KEY,
      value VARCHAR(255))
    ;")
sqliteQuickSQL(con, sql)

sql<- paste("
    INSERT INTO metadata VALUES('DBSCHEMAVERSION', '2.0');
     ")
sqliteQuickSQL(con, sql)



##Then we have to loop and make all the bread N Butter tables
fileNames = list.files(path="29-Apr-2009/IPDATA")


## An alternate way to do cleanup 
cleanArabid = function(row){
    if(row[3]=="modARATH.fa"){
        row[5] <- gsub("\\.[1:9]$","", row[5], perl=TRUE)
    }
    row[4] <- gsub("1.0000","1.0", row[4], perl=TRUE)
    row
}

##For some reason the cast to a matrix inserts a number of whitespace
##characters just before the 1st column
cleanBSWhiteSpace = function(row){
    row[1] <- gsub("^\\s+","", row[1], perl=TRUE)
    row
}

popInpTable = function(file, species){

    ##Make a table
    message(paste("Creating table: ",species[1],"_",species[2],sep=""))
    sql<- paste("    CREATE TABLE IF NOT EXISTS ",species[1],"_",species[2], " (
        clust_id INTEGER NOT NULL,
        clu2 VARCHAR(10) NOT NULL,
        species VARCHAR(15) NOT NULL,
        score VARCHAR(6) NOT NULL,
        ID VARCHAR(30) NOT NULL,  
        seed_status CHAR(4))
    ;",sep="")
    ##message(cat(paste("SQL:",sql)))
    sqliteQuickSQL(con, sql)
    
    ##Populate it with the contents of the filename
    message(cat(paste("Populating table: ",species[1],"_",species[2],sep="")))
    clnVals <- prepareData(file=paste("29-Apr-2009/IPDATA/",file,sep=""))

    ##Here is one place where I might be able to do some cleanup
    ##For example, in the tables with arabidopsis IDs, I want to
    ##remove the decimal from the end.
    if(species[1]=="arath" || species[2]=="arath"){
        clnVals = as.matrix(clnVals)
        clnVals = t(apply(clnVals,1,cleanArabid))
        clnVals = t(apply(clnVals,1,cleanBSWhiteSpace))
        clnVals = as.data.frame(clnVals)
    }

    sql<- paste("    INSERT into ",species[1],"_",species[2],
       " (clust_id,clu2,species,score,ID,seed_status) VALUES
        (?,?,?,?,?,?)",sep="")
    dbBeginTransaction(con)
    dbSendQuery(con, sql, data=unclass(unname(clnVals)))
    dbCommit(con)

## print(file)
## print(species)
    
}



abbrev = function(list){
  list = lapply(list,function(x){
    x = unlist(strsplit(x," "))
    x = paste(substr(x[1],1,1),".",x[2],sep="")
  })
  unlist(list)
}
names = as.vector(read.delim("script/speciesList.txt", header=FALSE, sep="\t")[,1])
names(names) = abbrev(names)


##Then loop through all the file names.
for(i in 1:length(fileNames)){
    file = fileNames[i]
    species = sub("sqltable.","",file)
    species = gsub(".fa-","-",species)
    species = gsub(".fa$","",species)
    species = unlist(strsplit(species,"\\-"))

    species[1] = gsub(" ", "_",names[[species[1]]])
    species[2] = gsub(" ", "_",names[[species[2]]])

    popInpTable(file, species)    
}


##To call
##R --slave < ../script/srcdb1.R


##Now is when we need to do any cleanup.  For example, the tair IDs all end with a decimal and a number.  We need to clean the stuff off of there.  (and it goes as high as .8)
##So we have to loop through all the tables (in as generic a way as possible) and clean up the IDs where species = "modARATH.fa".










##test loop

## files = fileNames[grep("graminis", fileNames)]

## for(i in seq_len(length(files))){
##   file = paste("./IPDATA/",files[i],sep="")
##   message(file)
##   insVals <- read.delim(file=file, header=FALSE, sep="\t", quote="")
##   message(head(insVals))
## }

