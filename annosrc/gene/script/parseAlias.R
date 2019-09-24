### Create 4 tab files:
### 'gene_cytogenetic.tab', 'gene_chromosome.tab', 'gene_synonym.tab' and 'gene_dbXrefs.tab'

splitStrUtil <- function() {
	allData <- read.table("gene_info", sep="\t", stringsAsFactors=FALSE, quote="", comment.char="") 
	cyto <- strsplit(allData[,8], 
			split="( and )|( or )|([ ]*;[ ]*)|([ ]*,[ ]*)|([ ]*\\|[ ]*)", 
			fixed=F)
	chr <- strsplit(allData[,7], split="[ ]*\\|[ ]*", fixed=F)
	synonym <- strsplit(allData[,5], split="[ ]*\\|[ ]*", fixed=F)
        dbXref <- strsplit(allData[,6], split="[ ]*\\|[ ]*", fixed=F)
        
	cytoKey <- rep(allData[,2], lengths(cyto))
	chrKey <- rep(allData[,2], lengths(chr))
	synonymKey <- rep(allData[,2], lengths(synonym))
        dbXrefKey <- rep(allData[,2], lengths(dbXref))

	## garbage collection step; otherwise this process may be killed early.
        rm(allData)
        gc()
        
	cyto <- unlist(cyto)
	chr <- unlist(chr)
	synonym <- unlist(synonym)
        dbXref <- unlist(dbXref)
        
	cytoData <- paste(cytoKey, cyto, sep="\t")
	chrData <- paste(chrKey, chr, sep="\t")
	synonymData <- paste(synonymKey, synonym, sep="\t")
        dbXrefData <- paste(dbXrefKey, dbXref, sep="\t")
        
	cat(cytoData, file="gene_cytogenetic.tab", sep="\n")
	cat(chrData, file="gene_chromosome.tab", sep="\n")
	cat(synonymData, file="gene_synonym.tab", sep="\n")
	cat(dbXrefData, file="gene_dbXrefs.tab", sep="\n")
	""
}

splitStrUtil( ) 
