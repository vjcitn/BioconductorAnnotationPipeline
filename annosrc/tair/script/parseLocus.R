splitStrUtil <- function(inputFile, outputFile, splitCol, delimiter, keyCol) {
	allData <- read.table(inputFile, sep="\t", stringsAsFactors=F, quote="", comment.char="") 
	theCol<- strsplit(allData[,splitCol], split=delimiter, fixed=T)
	theCount <- sapply(theCol, length)
	theKey <- rep(allData[,keyCol], theCount)
	theCol <- unlist(theCol)
	outData <- paste(theKey, theCol, sep="\t")
	cat(outData, file=outputFile, sep="\n")
	""
}

splitStrUtil( inputFile="affy_AG_array_elements1.txt", 
		outputFile="affy_AG_array_elements1.txt", 
		splitCol=5, 
		delimiter=";", 
		keyCol=1)

splitStrUtil( inputFile="affy_ATH1_array_elements1.txt", 
		outputFile="affy_ATH1_array_elements1.txt", 
		splitCol=5, 
		delimiter=";", 
		keyCol=1)

splitStrUtil( inputFile="aracyc_dump1", 
		outputFile="locus_enzymes.txt", 
		splitCol=6, ## was th col
		delimiter="||", 
		keyCol=7)  ## was 4th col
	
