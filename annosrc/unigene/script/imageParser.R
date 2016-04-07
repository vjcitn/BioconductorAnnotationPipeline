imageParser <- function(inputFile, outputFile) {
	inputStr <- scan(inputFile, what="character", sep="\n")
	startIndex <- grep("^ID    ", inputStr)
	endIndex <-grep("^//$", inputStr) 
	res <- mapply(
		function(s, e) {
                	entrezStr <- grep("^GENE_ID    ", inputStr[s:e], value=T)
			if (length(entrezStr)>0) {
				entrezID <- sub("^GENE_ID[ ]+([0-9]*)$", "\\1", entrezStr)
                                accStr <- grep("CLONE=IMAGE:[0-9]+", inputStr[s:e], value=T)
                                acc <- gsub("^(.+)CLONE=IMAGE:(\\d+);(.+)", "\\2", accStr, perl = TRUE)
                                r <- paste(entrezID, acc, sep="\t")
			} else {
				r <- NA
			}
			r	
		}, startIndex, endIndex)
	res <- unlist(res)
	res <- res[!is.na(res)]
	res <- paste(res, collapse="\n")
	cat(res, file=outputFile)	
}

