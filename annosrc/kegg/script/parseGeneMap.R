parseGeneMapUtil <- function(inputFile, outputFile, orgid) {
	allData <- read.table(inputFile, sep="\t", as.is=T) 
	pathway <- strsplit(allData[,2], split=" ")
	pathcount <- sapply(pathway, length)
	keggid <- rep(allData[,1], pathcount)
	pathway <- unlist(pathway)
	outData <- paste(orgid, ":", keggid, "\t", orgid, pathway, sep="")
	cat(outData, file=outputFile, sep="\n")
	""
}

parseGeneMap <- function(orgid) {
	inputFile <- paste(orgid, "_gene_map.tab", sep="")
	outputFile <- paste(orgid, "_gene_map2.txt", sep="")
	mapply(parseGeneMapUtil, inputFile, outputFile, orgid)
	""
}

orgList <- c("hsa", "mmu", "rno", "sce", "ath", "dme", "pfa", "dre", "eco", "ecs", "cfa", "bta", "cel", "ssc", "gga", "mcc", "xla", "aga", "ptr")
parseGeneMap(orgList)

	
