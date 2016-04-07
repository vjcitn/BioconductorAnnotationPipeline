### This is the code to check/prpare/write error logs for low level file importing.
### When you got ghosts in your data sources and you got to get rid of them...
### - who you gonna call?

## The following just takes a set of cols and a file to read in, and then checks
## the cols.  If the cols are missing and values, then the function removes them
## so that they will NOT attempt to be inserted into the DB.  It also records
## this event into a log file so that later on I can track down the clowns who
## gave us a BAD FILE....  


prepareData <- function(file, cols) {
    ## read in the data
    message("reading in ", file)
    insVals <- read.delim(file=file, header=FALSE, sep="\t", quote="")    
    
    
    ## check to see if any critical stuff is missing
    countCol <- function(col){
        numNA <- sum(is.na(col))
    }
    critVals <- insVals[, cols]
    NAColCnts <- apply(as.matrix(critVals), 2, countCol)

    ## Then we need to make log entries for flaws that we find...
    clnVals <- insVals
    for(i in 1:length(NAColCnts)){             
        if(NAColCnts[i]>0){
            cat(paste("CRITICAL TABLE FLAW!  There were ",NAColCnts[i],
                  " NAs inside of critical col ",cols[i]," inside the file named ",
                  file,'\n',sep=""),file="../../BADSrcFiles.log", append=TRUE)

            ## then scrub out the bad data rows (on crit cols)  
            clnVals <- clnVals[!is.na(insVals[, cols[i]]), ]
        }
    }
    clnVals
}


setEmptyToNull <- function(data, cols, fileName){

    ## check if there are any empty Vals
    countCol <- function(col){
        numEmp <- sum(col[1:length(col)]=="")
    }

    critVals <- data[, cols]
    emptColCnts <- apply(as.matrix(critVals), 2, countCol) 

    ## Create warnings to record that we have changed these vals to nulls
    newVals <- data
    for(i in 1:length(emptColCnts)){
        if(emptColCnts[i]>0){
            cat(paste("WARNING There were ",emptColCnts[i],
                  " empty strings inside of col ",cols[i],
                  " inside the file named ",fileName,
                  " These values have now been set to NULL.",'\n',
                  sep=""),file="../../BADSrcFiles.log", append=TRUE)

            ## then change the values of "" to NA on requested cols
            assignNAs <- function(col){
                col[col==""]=NA
                col
            }
            newVals[cols[i]] <- lapply(newVals[cols[i]], assignNAs)
        }
    }
    newVals    
}


#Just a utility to prevent empty IDs from ever causing any more mayhem
cleanSrcMap <- function(file) {
    insVals <- read.delim(file=file, header=FALSE, sep="\t", quote="")
    blnkLines <- insVals[insVals[,1]=='',]
    if(dim(as.matrix(blnkLines))[1] > 0){
        cat(paste("ID Source TABLE FLAW.  There were ",dim(as.matrix(blnkLines))[1],
        " blank values inside the file named ", file,'\n',sep="")
        ,file="../../../BADSrcFiles.log", append=TRUE)
    }
    insVals <- insVals[insVals[,1]!='',]
}
