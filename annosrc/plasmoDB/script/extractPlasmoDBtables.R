#
#	extract GeneIDs and GO terms from a raw PlasmoDB annotation file
#
#	ver 1.00	3/20/08		Bob Morrison

extractPlasmoDBtables <- function(
#		srcFile="PfalciparumGene_plasmoDB-5.4.txt",
                srcFile="../23-Mar-2016/PlasmoDB-28_Pfalciparum3D7Gene.txt",
                srcURL=NULL,
		GOfile="../processedFiles/GOtable.txt",
		ALIASfile="../processedFiles/ALIAStable.txt",
		SYMBOLfile="../processedFiles/SYMBOLtable.txt",
		row.names=FALSE) {
			
	setup()
	addRowNames <<- row.names

	# if URL, use it
	if ( !is.null(srcURL)) {
		cat("\n Extracting from URL: ", srcURL)
		f <- url( srcURL, open="rt")
	} else {
		cat("\n Extracting from local file: ", srcFile)
		f <- file( srcFile, open="rt")
	}
	on.exit( close(f))
	
	repeat {
		curLine <- readLines( f, n=1)
		if (length(curLine) < 1) break
		processLine( curLine)
	}
	cleanup( GOfile, ALIASfile, SYMBOLfile)
}


setup <- function() {
	nLinesRead <<- 0
	inGene <<- FALSE
	curGene <<- NULL
	nGenesFound <<- 0
	geneBeginFlag <<- "Gene ID:"
	geneEndFlag <<- "-----"
	
	inWantedTable <<- FALSE
	curTable <<- NULL
	tableBeginFlag <<- "TABLE:"
	tableEndFlag <<- ""
	
	wantedTables <<- c("GO Terms", "Names, Previous Identifiers, and Aliases")
	GOout <<- vector()
	ALIASout <<- vector()
	
	wantedKeyLines <<- c("Product Description:")
	SYMBOLout <<- vector()
}


cleanup <- function( GOfile, ALfile, SYfile) {
	# write out results
	cat( "\n GO Terms found:  ", (length(GOout)-1))
	writeLines( GOout, con=GOfile)
	cat( "\n Wrote File:      ", GOfile)
	cat( "\n Aliases found:  ", (length(ALIASout)-1))
	writeLines( ALIASout, con=ALfile)
	cat( "\n Wrote File:      ", ALfile)
	cat( "\n Symbols found:  ", (length(SYMBOLout)-1))
	writeLines( SYMBOLout, con=SYfile)
	cat( "\n Wrote File:      ", SYfile)
	
	# remove my global variables
	rm( GOout, ALIASout, SYMBOLout, pos=.GlobalEnv)
	rm( curGene, inGene, geneBeginFlag, geneEndFlag, nGenesFound, pos=.GlobalEnv)
	rm( curTable, inWantedTable, tableBeginFlag, tableEndFlag, pos=.GlobalEnv)
	rm( nLinesRead, wantedTables, wantedKeyLines, addRowNames, pos=.GlobalEnv)
}

processLine <- function( line) {

	# show some life...
	nLinesRead <<- nLinesRead + 1
	if ( nLinesRead %% 50000 == 0) {
		cat("\nLines: ", nLinesRead, "Genes:", nGenesFound, "  GOterms:", length(GOout),
		"  Aliases:", length(ALIASout))
	}
	
	# watch for state change into a gene...
	if ( !inGene) {
		checkForGeneBegin( line )
		return()
	}
	
	# watch for wanted Key Lines
	checkForKeyLine( line)
	
	# watch for state change into a wanted table
	if ( !inWantedTable) {
		checkForWantedTable( line)
		return()
	}
	processTableEntry( line)
}


checkForGeneBegin <- function( line) {
	# looking for a Gene: xxxx
	lenOfFlag <- nchar(geneBeginFlag)
	if ( nchar(line) < lenOfFlag) return()
	if ( substr(line,1,lenOfFlag) != geneBeginFlag) return()
	
	# yes, it is a new gene
	terms <- strsplit( line, split=": ", fixed=TRUE)
	curGene <<- as.character( terms[[1]][2])
	inGene <<- TRUE
	nGenesFound <<- nGenesFound + 1
	return()
}


checkForKeyLine <- function( line) {
	# the key word is up to the first colon
	icolon <- regexpr( ":", line, fixed=TRUE)
	if (icolon < 2) return()
	term <- substr(line,1,icolon)
	if ( !(term %in% wantedKeyLines)) return()
	
	# do that Key Word line
	rest <- substr( line, (icolon+2), nchar(line))
	switch (term,
		"Product Description:"={
## 			if (length(SYMBOLout) < 1) {
## 				out <- paste( "GeneID", "Description", sep="\t")
## 				SYMBOLout[1] <<- out
## 			}
			nNow <- length(SYMBOLout) + 1
			out <- paste( curGene, rest, sep="\t")
			if (addRowNames) out <- paste( nNow, out, sep="\t")
			SYMBOLout[nNow] <<- out
		},
		"default"={
		}
	)
	return()
}


checkForWantedTable <- function( line) {
	
	# looking for a Table: but watch for other needed transitions
	len <- nchar( line)
	if (len < 5) return()
	# end of gene?
	if ( substr(line,1,5) == geneEndFlag) {
		inGene <<- FALSE
		curGene <<- NULL
		return()
	}
	lenOfFlag <- nchar(tableBeginFlag)
	if ( len < lenOfFlag) return()
	if ( substr(line,1,lenOfFlag) != tableBeginFlag) return()
	
	# yes, it is a new table, everything after "Table: " is the name
	tableName <- substr( line, (lenOfFlag+2), len)
	if ( !(tableName %in% wantedTables)) return()
	
	# yes, its a table we want
	curTable <<- tableName
	inWantedTable <<- TRUE
	return()
}


processTableEntry <- function( line) {
	len <- nchar( line)
	if (line == tableEndFlag) {
		inWantedTable <<- FALSE
		curTable <<- NULL
		return()
	}
	
	switch (curTable,
		"GO Terms" = {
			processGOentry( line)
		},
		"Names, Previous Identifiers, and Aliases" = {
			processALIASentry( line)
		},
		"default" ={}
	)
}


processGOentry <- function( line) {
	
	#if very first line ever, make a column names entry from the current line
## 	if (length(GOout) == 0) {
## 		out <- gsub( "[", "", line, fixed=TRUE)
## 		out <- gsub( "]", "", out, fixed=TRUE)
## 		# there is an unwanted "Is Not"
## 		out <- sub( "Is Not\t", "", out, fixed=TRUE)
## 		out <- paste( "GeneID", out, sep="\t")
## 		out <- dropFinalTab( out)
## 		GOout[1] <<- out
## 		return()
## 	}
	
	# each table starts with a headings line that we don't want to keep
	if ( substr( line,1,1) == "[") return()
	
	# append one more line, it already starts with a tab, so don't add one
	nNow <- length(GOout) + 1
	out <- paste( curGene, line, sep="\t")
	out <- dropFinalTab( out)
	if (addRowNames) out <- paste( nNow, out, sep="\t")
	GOout[nNow] <<- out
	return()
}


processALIASentry <- function( line) {
	
	#if very first line ever, make a column names entry
## 	if (length(ALIASout) < 1) {
## 		out <- paste( "GeneID", "Alias", sep="\t")
## 		ALIASout[1] <<- out
## 		return()
## 	}
	
	# each table starts with a headings line that we don't want to keep
	if ( substr( line,1,1) == "[") return()
	
	# append one more alias line
	nNow <- length(ALIASout) + 1
	out <- paste( curGene, line, sep="\t")
	out <- dropFinalTab( out)
	if (addRowNames) out <- paste( nNow, out, sep="\t")
	ALIASout[nNow] <<- out
	return()
}


dropFinalTab <- function( lineIn ) {
	# the raw file seems to have every table line end with a tab.
	# remove if found
	len <- nchar( lineIn)
	lineOut <- lineIn
	if (substr( lineIn, len, len) == "\t") {
		lineOut <- substr( lineOut, 1, (len-1))
	}
	return( lineOut)
}


#gots to call the function!
extractPlasmoDBtables()
