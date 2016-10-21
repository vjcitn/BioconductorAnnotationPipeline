## parseECUtil <- function(inputFile, outputFile, orgid) {
## 	x <- scan(inputFile, what="character", sep="\n") 
## 	x <- strsplit(x, "\t")
## 	outData <- lapply(x, function(y) {
## 		ec <- sub("^.*\\[EC:([^]]*)\\].*$", "\\1", y[2])
## 		ec <- unlist(strsplit(ec, " "))
## 		paste(orgid, ":", y[1], "\t", ec, sep="")
## 	})
## 	outData <- unlist(outData)	
## 	cat(outData, file=outputFile, sep="\n")
## 	""
## }

parseECUtil <- function(inputFile, outputFile, orgid) {
	x <- scan(inputFile, what="character", sep="\n") 
	x <- strsplit(x, "\t")
	outData <- lapply(x, function(y) {
		## ec <- sub("^.*ec:([^]]*)", "\\1", y[3])
 		## ec <- unlist(strsplit(ec, " "))
                geneId <- gsub(paste(orgid, ":", sep=""), "", y[2])
                z <- unlist(strsplit(y[3]," "))
                ##Then look through the ec IDs
                lapply(z, function(e){
                  if(length(grep("ec:",e))>0){ #ie. if it starts with ec:
                    paste(orgid, ":", geneId, "\t", gsub("ec:","",e), sep="")
                  }
                })             
	})
	outData <- unlist(outData)	
	cat(outData, file=outputFile, sep="\n")
	""
}

parseEC <- function(orgid) {
	inputFile <- paste(orgid, "_ec.txt", sep="")
	outputFile <- paste(orgid, "_ec2.txt", sep="")
	mapply(parseECUtil, inputFile, outputFile, orgid)
	""
}

orgList <- c("hsa", "mmu", "rno", "sce", "ath", "dme", "pfa", "dre", "eco", "ecs", "cfa", "bta", "cel", "ssc", "gga", "mcc", "xla", "aga", "ptr")
parseEC(orgList)

	
