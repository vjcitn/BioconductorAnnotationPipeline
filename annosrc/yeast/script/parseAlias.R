splitStrUtil <- function(inputFile, outputFile, splitCol, delimiter, keyCol) {
	allData <- read.delim(inputFile, sep="\t", stringsAsFactors=F, quote="") 
	theCol<- strsplit(allData[,splitCol], split=delimiter, fixed=T)
	theCount <- sapply(theCol, length)
	theKey <- rep(allData[,keyCol], theCount)
	theCol <- unlist(theCol)
	outData <- paste(theKey, theCol, sep="\t")
	cat(outData, file=outputFile, sep="\n")
	""
}

## splitStrUtil( inputFile="registry.genenames.tab", 
## 		outputFile="gene2alias.tab", 
## 		splitCol=2, 
## 		delimiter="|", 
## 		keyCol=7)

splitStrUtil( inputFile="SGD_features.tab", 
		outputFile="gene2alias.tab", 
		splitCol=6, 
		delimiter="|", 
		keyCol=1)
	
