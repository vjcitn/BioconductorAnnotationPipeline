flyBackCompat <- function() {
	allData <- read.table("dme_gene_map.tab", sep="\t", as.is=T) 
	outData <- paste("dme:", allData[,1], "\t", allData[,1], sep="")
	cat(outData, file="dme_dme.list", sep="\n")
	""
}

flyBackCompat()
	
