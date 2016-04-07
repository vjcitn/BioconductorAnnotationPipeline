##This little R script just exists to read in the contents of the
##../12-Jul-2007/IPDATA/ dir, and then for each file, it takes the
##name of that file, reads splits the name into two parts, and then
##makes a table based on the name of the file, then that file is
##loaded up into the table.

#In script I will call this by just going to the current dir with the
#IPDATA dir (eg above) and just running it.


library("RSQLite")

prepareData <- function(file, cols) {
    ## read in the data
    message("reading in ", file)
    insVals <- read.delim(file=file, header=FALSE, sep="\t", quote="",
                          colClasses=c("integer", rep("character", 5)),
                          stringsAsFactors=FALSE)
    
    ## check to see if any critical stuff is missing
    countCol <- function(col){
        numNA <- sum(is.na(col))
    }
    critVals <- insVals[, cols]
    ## FIXME: don't need to coerce to matrix to get column count of NAs
    ## should be sapply(critVals, countCol)
    NAColCnts <- apply(as.matrix(critVals), 2, countCol)

    ## Then we need to make log entries for flaws that we find...
    clnVals <- insVals
    for(i in 1:length(NAColCnts)){             
        if(NAColCnts[i]>0){
            cat(paste("CRITICAL TABLE FLAW!  There were ",NAColCnts[i],
             " NAs inside of critical col ",cols[i]," inside the file named ",
             file,'\n',sep=""),file="BADINPSrcFiles.log", append=TRUE)
            ## then scrub out the bad data rows (on crit cols)  
            clnVals <- clnVals[!is.na(insVals[, cols[i]]), ]
        }
    }
    clnVals
}

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

popInpTable = function(con, file, species, dataDir){

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
    dbGetQuery(con, sql)
    
    ##Populate it with the contents of the filename
    message(cat(paste("Populating table: ",species[1],"_",species[2],sep="")))
    clnVals <- prepareData(file=paste(dataDir,file,sep=""))

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
    dbGetPreparedQuery(con, sql, clnVals)
    dbCommit(con)
    
}




############################################################
## Let's proceed to set up a DB

makeSrcDB <- function(dataDir="./29-Apr-2009/IPDATA/"){
  ##remove old DB
  file.remove("inparanoid.sqlite")

  ## Make some generic tables to start.
  drv <- dbDriver("SQLite")
  con <- dbConnect(drv,dbname="inparanoid.sqlite")

  sql<- paste("    CREATE TABLE IF NOT EXISTS metadata (
      name VARCHAR(80) PRIMARY KEY,
      value VARCHAR(255))
    ;")
  dbGetQuery(con, sql)
  
  sql<- paste("
    INSERT INTO metadata VALUES('DBSCHEMAVERSION', '2.0');
     ")
  dbGetQuery(con, sql)

  ##Then we have to loop and make all the bread N Butter tables
  fileNames = list.files(path=dataDir)

  abbrev = function(list){
    list = lapply(list,function(x){
      x = unlist(strsplit(x," "))
      x = paste(substr(x[1],1,1),".",x[2],sep="")
    })
    unlist(list)
  }

  ##read in the speciesList file
  names = as.vector(read.delim(system.file("extdata", "speciesList.txt",
                                 package="InparanoidBaseBuilder"),
    header=FALSE, sep="\t")[,1])
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
    
    popInpTable(con, file, species,dataDir)    
  }
  
}


