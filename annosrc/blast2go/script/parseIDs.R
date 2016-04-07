parseGOIDs = function(file, fileName ){
       Data <- read.delim(file, sep="", header=F, col.names = c(1,2,3,4,5,6,7,8)) #Cols listed to trick read.delim into reading in ALL of the cols even if 1st line is missing some fields...
       RSLines <- matchLines <- grep("refseq",Data[,4])
       RSData <- Data[RSLines,c(3,2)] #Cols 2 and 3 have what we want
       write.table(RSData, file=paste(fileName, "_RS.tab" , sep=""), sep="\t", row.names=F, col.names=F, quote=F)
       
       GBLines <- matchLines <- grep("genbank",Data[,4])
       GBData <- Data[GBLines,c(6,2)] #Cols 2 and 6 have what we want
       #The extensions ".X" have to be stripped off of the GBData keys as well
       GBData[,1] <- sub("\\.\\d+?$", "", GBData[,1], perl = TRUE)
       write.table(GBData, file=paste(fileName, "_GB.tab" , sep=""), sep="\t", row.names=F, col.names=F, quote=F)
}

    parseGOIDs(file="Canis_familiaris_9615.annot", fileName="CfIDs")
    parseGOIDs(file="Sus_Scrofa_9823.annot", fileName="SscIDs")
    
    parseGOIDs(file="Anopheles_gambiae_180454.annot", fileName="AgaIDs")
    parseGOIDs(file="Xenopus_laevis_8355.annot", fileName="XlIDs")
    parseGOIDs(file="Macaca_mulatta_9544.annot", fileName="MmuIDs")
    parseGOIDs(file="Pan_troglodytes_9598.annot", fileName="PtrIDs")

