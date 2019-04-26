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

helper_strSplitUtil <- function(col, comp) {
	if (comp)
		strsplit(col, split=,"( and )|( or )|([ ]*;[ ]*)|([ ]*,[ ]*)|([ ]*\\|[ ]*)", fixed=F)
	else
		strsplit(col, split="[ ]*\\|[ ]*", fixed=F)
}

newSplitStrUtil <- function() {
	idx <- 5:8
	file_names <- c("gene_synonym.tab", "gene_dbXrefs.tab", "gene_chromosome.tab", "gene_cytogenetic.tab")
	comp <- c(FALSE, FALSE, FALSE, TRUE)
	
	colClasses <- rep("NULL", 14)
	colClasses2 <- colClasses
	colClasses2[2] <- NA
	col2 <- read.table("gene_info", sep="\t", stringsAsFactors=FALSE, quote="", comment.char="",
				colClasses = colClasses2)
	col2 <- col2[,1]
	for( i in seq_len(4)) {
		colClasses_temp <- colClasses
		colClasses_temp[idx[i]] <- NA
		col <- read.table("gene_info", sep="\t", stringsAsFactors=FALSE, quote="",
					comment.char="", colClasses=colClasses_temp)
		col <- col[,1]

		val <- helper_strSplitUtil(col, comp[i])
		key <- rep(col2, lengths(val))
		val <- unlist(val)
		data <- paste(key, val, sep="\t")
		cat(data, file=file_names[i], sep="\n")
	}
}

#newSplitStrUtil( )

splitStrUtil( ) 
