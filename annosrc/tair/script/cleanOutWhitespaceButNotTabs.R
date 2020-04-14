## This file is a MESS!  But it can be salvage because there are only 3 cols,
## and the 1st two are *always* present.

clnWhiteSpaceFromLocusPub <- function(inputFile, outputFile){
  allData <- read.delim(inputFile, header=FALSE, sep="\t", stringsAsFactors=FALSE, strip.white=TRUE)[,-4]

  ## allData <- allData[1:10,]
  ## notna <- !is.na(allData) ## seems I should be able to make use of this...
  nrows <- dim(allData)[1]
  res <- matrix(nrow=nrows, ncol=3)
  for(i in seq_len(nrows)){
    new <- allData[i,]
    new <- new[!is.na(new)]
    if(length(new) == 2){
      new <- c(new, "")
    }else if(length(new) == 1){
      new <- c(new, "", "")
    }else{
      new <- new
    }
    if(length(new) >3 ){
      warning(new, "is too long!")
    }
    if(length(new) <3 ){
      warning(new, "was too short!")
    }
    if(i>nrows){
      warning(i, "Too few rows were allocated.")
    }
    res[i,] <- new
    
  }
  res <- as.data.frame(res)

  ## Then write the file out
  write.table(res, sep="\t", quote=FALSE, file=outputFile, row.names=FALSE, col.names=FALSE)
}


clnWhiteSpaceFromLocusPub(inputFile="LocusPublished1.txt",
                          outputFile="LocusPublished2.txt")
