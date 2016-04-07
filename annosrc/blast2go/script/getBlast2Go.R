## This script has 3 roles.
## 1) DL and parse the blast2GO IDs
## 2) create a blast2GO db populate it with the refseq and Genbank tables
## 3) copy the blast2GO db to /db and then join with the appropriate chipmapsrc
## packages to retrieve EGs for both the refseq and GB IDs so that we can make
## a new eg2go table from each of the other pairs (refseq2go and genbank2go) of
## tables for each species.


######################################################################################
##Some setup:
######################################################################################
scriptDir = "/mnt/cpb_anno/mcarlson/proj/mcarlson/sqliteGen/annosrc/blast2go/script"
setwd(scriptDir)

##Get the date for the build dir (we make this dir by hand for now - but it would be better to move that code here too)
env = readLines("env.sh")
dateLine = grep("BL2GOSOURCEDATE",env, value=TRUE)
date = sub("^.+=","",dateLine, perl=TRUE)


######################################################################################
##1st role is get the data:
######################################################################################

##list of supported species...
taxIDList = c("Canis_familiaris"="9615",
                "Sus_Scrofa"="9823",
                "Anopheles_gambiae"="180454",
                "Xenopus_laevis"="8355",
                "Macaca_mulatta"="9544",
                "Pan_troglodytes"="9598")
##                 "Escherichia_coli_K12"="511145")


##There is no way to derive the chipmapsrc list names from the species names.  So I just have to use the another char vector here (for now)
##Ultimately, it would make more sense to actually draw this information from the metadata.sqlite DB (along with the information on tax IDs etc.

chipMapSrcList = c("Canis_familiaris"="chipmapsrc_canine.sqlite",
                   "Sus_Scrofa"="chipmapsrc_pig.sqlite",
                   "Anopheles_gambiae"="chipmapsrc_anopheles.sqlite",
                   "Xenopus_laevis"="chipmapsrc_xenopus.sqlite",
                   "Macaca_mulatta"="chipmapsrc_rhesus.sqlite",
                   "Pan_troglodytes"="chipmapsrc_chimp.sqlite")
##                    "Escherichia_coli_K12"="chipmapsrc_ecoliK12.sqlite")


## example
## http://www.blast2go.org/_media/species:data:180454.annot?id=species%3A180454&cache=cache
## example of zipped format
## http://www.blast2go.org/_media/species:data:9615.annot.zip?id=species%3A9615&cache=cache
## MOVED in June of 09. NEW example:
## http://bioinfo.cipf.es/b2gfar/_media/species:data:9913.annot.zip?id=species%3A9913&cache=cache 
## MOVED AGAIN: in Sept 2012
## http://www.b2gfar.org/_media/species:data:9913.annot.zip?id=species%3A9913&cache=cache
#################################################################################################
## Warning: this web site is quite slow!  You will have to wait a while for this step...
## 
## May want to Temporarily disable the Downloads
##
##move to the data dir
setwd(paste("../",date,sep=""))
downloadBL2GOData = function(id){
##     url = paste("http://www.blast2go.org/_media/species:data:",id,".annot.zip?id=species%3A",id,"&cache=cache",sep="")
##    url = paste("http://bioinfo.cipf.es/b2gfar/_media/species:data:",
##      id,".annot.zip?id=species%3A",id,"&cache=cache",sep="")
   url = paste("http://www.b2gfar.org/_media/species:data:",
     id,".annot.zip?id=species%3A",id,"&cache=cache",sep="")
    file = paste(names(id),"_",id,".annot",sep="") ##name we desire for final output
    filez = paste(file,".zip",sep="") ##name of our zip file
    fileName = paste(id,".annot",sep="") ##name of thing in the zip file we just DL'ed
    download.file(url, filez) ##DL that sucker now
    conn = unz(description=filez,filename=fileName) ##Make a connection to the specific file in our DLed zip file
    content = read.delim(conn, header=FALSE)
    write.table(content, file = file,  sep="\t",
                row.names=FALSE, col.names=FALSE, quote=FALSE)
}

##Then loop thru to get everything (not needed today since I have this stuff already)
## for(i in seq_len(length(taxIDList))){
##     downloadBL2GOData(taxIDList[i])
## }

##Then put the wd back
setwd(scriptDir)


##Lets do the DL and parse on separate loops because it can get messy to debug these processes (and frequently they will need it as the sources change)
##So next we will do the parsing.
parseGOIDs = function(id){
       ##Derive file name
       file = paste(names(id),"_",id,".annot",sep="") ## eg "Canis_familiaris_9615.annot"

       ##Read in data
       Data <- read.delim(file, sep="", header=FALSE, col.names = c(1,2,3,4,5,6,7,8)) #Cols listed to trick read.delim into reading in ALL of the cols even if 1st line is missing some fields...
       RSLines <- matchLines <- grep("refseq",Data[,4])
       RSData <- Data[RSLines,c(3,2)] #Cols 2 and 3 have what we want
       write.table(RSData, file=paste(names(id),
                             "_rs.tab" , sep=""),
                   sep="\t", row.names=F, col.names=F, quote=F)

       GBLines <- matchLines <- grep("genbank",Data[,4])
       GBData <- Data[GBLines,c(6,2)] #Cols 2 and 6 have what we want
       #The extensions ".X" have to be stripped off of the GBData keys as well
       GBData[,1] <- sub("\\.\\d+?$", "", GBData[,1], perl = TRUE)
       write.table(GBData, file=paste(names(id),
                             "_gb.tab" , sep=""),
                   sep="\t", row.names=F, col.names=F, quote=F)
}

##Set the working directory to the value in env.sh
setwd(paste("../",date,sep=""))

##Then loop thru to parse everything 
for(i in seq_len(length(taxIDList))){
    id = taxIDList[i]
    parseGOIDs(id)
}




##############################################################################################
##2nd role is to load the data into a table in the blast2go DB
##############################################################################################

##load libs
library("DBI")
library("RSQLite")

##Connect to the DB
drv <- dbDriver("SQLite")
db <- dbConnect(drv,dbname="blast2go.sqlite")


##Define a function to create and populate a table.
popGOTable = function(id, idLong, idShort, db){
    ##Derive the table name
    table = paste(names(id),"_",idLong,"2go",sep="")
    
    ##Make the table
    message(cat(paste("Creating table: ",table,sep="")))
    sql<- paste("    CREATE TABLE IF NOT EXISTS ",table, " (
        ",idShort,"_id VARCHAR(20) NOT NULL,
        go_id VARCHAR(20) NOT NULL )
    ;", sep="")
    dbGetQuery(db, sql)

    ##Populate that table
    importFile = file=paste(names(id), "_", idShort ,".tab" , sep="")
    data = read.delim(file=importFile, header=FALSE, sep="\t")

    sqlIns <- paste("INSERT INTO ",table,"(",idShort,
                    "_id,go_id) VALUES (?,?);", sep="")
    dbBeginTransaction(db)
    rslt <- dbSendPreparedQuery(db, sqlIns, data)
    dbClearResult(rslt)
    dbCommit(db)

    ##Two indices per table
    ind1 = paste(table,"_",idShort,"",sep="")
    sql<- paste("CREATE INDEX ",ind1," ON ",table,"(",idShort,"_id);",sep="")
    dbGetQuery(db, sql)
    ind2 = paste(table,"_go",sep="")
    sql<- paste("CREATE INDEX ",ind2," ON ",table,"(go_id);",sep="")
    dbGetQuery(db, sql)
}



##Loop again, and this time we want to call popTable for each.
for(i in seq_len(length(taxIDList))){
    id = taxIDList[i]       
    popGOTable(id, "genbank", "gb", db)  
    popGOTable(id, "refseq", "rs", db)    
}
##NOTE: the downstream function depends on these tables being about "refseq" and "genbank".
##more to the point, the downstream function depends on these parameters being set to these specific values.

dbDisconnect(db)




##############################################################################################
##3rd role is to join the data with chipmapsrc files to form new eg2go tables
##############################################################################################

## 1st we have to cp the db to another dir
file.remove("../../db/blast2go.sqlite")
file.copy("blast2go.sqlite", "../../db/")

##Switch to that dir ourselves
setwd("../../db")

##Connect to the DB
drv <- dbDriver("SQLite")
db <- dbConnect(drv,dbname="blast2go.sqlite")

##Define a function to create a table based on a join with the correct chipmapsrc.
popEG2GOTable = function(id, chipSrc, db){

    ##Derive the table name
    table = paste(names(id),"_eg2go",sep="")
    
    ##Make the table
    message(cat(paste("Creating table: ",table,sep="")))
    sql<- paste("    CREATE TABLE IF NOT EXISTS ",table, " (
        eg_id VARCHAR(20) NOT NULL,
        go_id VARCHAR(20) NOT NULL )
    ;", sep="")
    dbGetQuery(db, sql)


    ##Attach the other DB
    sql<- paste("ATTACH DATABASE '",chipSrc,"' AS chipSrc;",sep="")
    dbGetQuery(db, sql)

    ##Then do TWO inserts from each source (refseq and genbank)
    refseqTable = paste(names(id),"_refseq2go",sep="")
    message(cat(paste("refseq tablename: ",refseqTable,sep="")))
    ##1st insert from refseq
    sql<- paste("INSERT INTO ",table,"
                 SELECT map.gene_id, go.go_id
                 FROM chipSrc.refseq AS map, ",refseqTable," as go
                 WHERE map.accession = go.rs_id;")
    dbGetQuery(db, sql)

    genbankTable = paste(names(id),"_genbank2go",sep="")
    message(cat(paste("genbank tablename: ",genbankTable,sep="")))
    ##then insert from genbank
    sql<- paste("INSERT INTO ",table,"
                 SELECT map.gene_id, go.go_id
                 FROM chipSrc.accession AS map, ",genbankTable," as go
                 WHERE map.accession = go.gb_id;")
    dbGetQuery(db, sql)
        
    ##After doing these two inserts, it is a good idea to remove duplicate entries...
    sql<- paste("DELETE FROM ",table,"
                 WHERE rowid NOT IN (SELECT rowid
                 FROM ",table,"
                 GROUP BY eg_id, go_id
                 HAVING min(rowid));")
    dbGetQuery(db, sql)

    
    ##Two indices per table
    ind1 = paste(table,"_eg",sep="")
    sql<- paste("CREATE INDEX ",ind1," ON ",table,"(eg_id);",sep="")
    dbGetQuery(db, sql)
    ind2 = paste(table,"_go",sep="")
    sql<- paste("CREATE INDEX ",ind2," ON ",table,"(go_id);",sep="")
    dbGetQuery(db, sql)

    ##Detach the other DB
    sql<- paste("DETACH DATABASE chipSrc;",sep="")
    dbGetQuery(db, sql)
}


for(i in seq_len(length(taxIDList))){
    id = taxIDList[i]
    chipSrc = chipMapSrcList[i]
    if(names(id) != names(chipSrc)){##Safety check
        stop("There is something very wrong about your taxIDList and chipMapSrcList (they should always line up perfectly)")
    }
    popEG2GOTable(id, chipSrc, db)
}



 
dbDisconnect(db)


