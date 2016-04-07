###ID_IDs.txt starts oddly and so needs to be handled on its own.
parseID_IDs <- function() {

    data <- read.delim("ID_IDs.txt", sep="\t", header=F)
    ID="foo"
    AC="bar"
    out = matrix(nrow=dim(data)[1]/2,ncol=2)
    count=0
    for(i in 1:dim(data)[1]){        
        if(data[i,1]=="ID"){
            ID = as.character(data[i,2])
        }
        if(data[i,1]=="AC"){
            AC = as.character(data[i,2])
            count = count +1
           out[count,1] = AC
           out[count,2] = ID
        }
    }

    write.table(out, file="IDs.tab", sep="\t", row.names=F, col.names=F, quote=F)
}
cat("parseID_ID step \n")
parseID_IDs( )


###parser for simple one to one IDs (use for DE and TP IDs) (this should be faster than subsequent ones)
parseSimple_IDs <- function(IDtype, fileName) {

    data <- read.delim(fileName, sep="\t", header=F)
    ID="foo"
    AC="bar"
    out = matrix(nrow=dim(data)[1]/2,ncol=2)
    count=0
    for(i in 1:dim(data)[1]){        
        if(data[i,1]=="AC"){
            AC = as.character(data[i,2])
        }
        if(data[i,1]==IDtype){
            ID = as.character(data[i,2])
            count = count +1
           out[count,1] = AC
           out[count,2] = ID
        }        
    }

    write.table(out, file=paste(IDtype,"s.tab",sep=""), sep="\t", row.names=F, col.names=F, quote=F)
}

cat("parseSimple_IDs step \n")
parseSimple_IDs("DE","DE_IDs.txt" )
parseSimple_IDs("TP","TP_IDs.txt" )



###parser for simple one to many IDs (use for RM and other IDs where things are not one to one.)
parseOneMany_IDs <- function(IDtype, fileName) {
    data <- read.delim(fileName, sep="\t", header=F)
    ID="foo"
    AC="bar"
    out = matrix(nrow=dim(data)[1],ncol=2)  #divide by two no longer flys so clean up NAs later
    count=0
    for(i in 1:dim(data)[1]){        
        if(data[i,1]=="AC"){
            AC = as.character(data[i,2])
        }
        if(data[i,1]==IDtype){
            ID = as.character(data[i,2])
            count = count +1
           out[count,1] = AC
           out[count,2] = ID
        }        
    }
    #clean out the NAs
    out = out[!is.na(out[,1]),]
    write.table(out, file=paste(IDtype,"s.tab",sep=""), sep="\t", row.names=F, col.names=F, quote=F)
}
cat("parseOneMany_IDs step \n")
parseOneMany_IDs("RM","RM_IDs.txt" )



###Fortuitously, a minor variant of this parser should also probably work for separating the DR items out
parseComplex_IDs <- function(IDtype, fileName) {

    data <- read.delim(fileName, sep="\t", header=F)
    ID="foo"
    ID2="foo2"
    AC="bar"
    out = matrix(nrow=dim(data)[1],ncol=dim(data)[2])  #divide by two no longer flys so clean up NAs later
    count=0
    for(i in 1:dim(data)[1]){        
        if(data[i,1]=="AC"){
            AC = as.character(data[i,2])
        }
        if(data[i,2]==paste(IDtype,";",sep="")){
            ID = sub(";","",as.character(data[i,3]))
            if(as.character(data[i,4]) != ""){
              ID2 = sub(";","",as.character(data[i,4]))
            }
            count = count +1
           out[count,1] = AC
           out[count,2] = ID
           if(!is.na(ID2) && ID2 != "foo2"){
               out[count,3] = ID2
           }
        }        
    }
    #clean out the NAs
    out = out[!is.na(out[,1]),]
    if (nrow(out) == 0L)
        warning(paste0("no data for ", IDtype))
    else
        out = out[,!is.na(out[1,])]
    write.table(out, 
                file=paste(IDtype,"s.tab",sep=""), sep="\t", row.names=F, 
                col.names=F, quote=F)
}

cat("parseComplex_IDs step \n")
parseComplex_IDs("CAZY","DR_IDs.txt" )
parseComplex_IDs("HOMSTRAD","DR_IDs.txt" )
parseComplex_IDs("INTERPRO","DR_IDs.txt" )
parseComplex_IDs("LOAD","DR_IDs.txt" )
parseComplex_IDs("MEROPS","DR_IDs.txt" )
parseComplex_IDs("MIM","DR_IDs.txt" )
## parseComplex_IDs("PFAMB","DR_IDs.txt" )
parseComplex_IDs("PRINTS","DR_IDs.txt" )
parseComplex_IDs("PROSITE","DR_IDs.txt" )
parseComplex_IDs("PROSITE_PROFILE","DR_IDs.txt" )
parseComplex_IDs("SCOP","DR_IDs.txt" )
parseComplex_IDs("SMART","DR_IDs.txt" )
parseComplex_IDs("TC","DR_IDs.txt" )
parseComplex_IDs("URL","DR_IDs.txt" )



parsePDB_IDs <- function(IDtype, fileName) { #data is formatted differently so need an alt parser

    data <- read.delim(fileName, sep="\t", header=F)
    ID="foo"
    ID2="foo2"
    ID3="foo3"
    AC="bar"
    out = matrix(nrow=dim(data)[1],ncol=dim(data)[2])  #divide by two no longer flys so clean up NAs later
    count=0
    for(i in 1:dim(data)[1]){        
        if(data[i,1]=="AC"){
            AC = as.character(data[i,2])
        }
        if(data[i,1]==IDtype){
            ID = as.character(data[i,2])
            if(!is.na(data[i,3])){
              ID2 = as.character(data[i,3])
            }
            if(!is.na(data[i,4])){
              ID3 = as.character(data[i,4])
            }
            
            count = count +1
           out[count,1] = AC
           out[count,2] = ID
           if(!is.na(ID2) && ID2 != "foo2"){
               out[count,3] = ID2
           }
           if(!is.na(ID3) && ID2 != "foo3"){
               out[count,4] = ID3
           }            
        }        
    }
    #clean out the NAs
    out = out[!is.na(out[,1]),]
    out = out[,!is.na(out[1,])]
    write.table(out, file=paste(IDtype,"s.tab",sep=""), sep="\t", row.names=F, col.names=F, quote=F)
}

cat("parsePDB_IDs step \n")
parsePDB_IDs("PDB","PDB_IDs.txt" )
