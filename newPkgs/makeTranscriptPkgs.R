library(AnnotationForge)
csvs <- dir(pattern = "csv$")


version <- "3.13.0" ## this needs to be changed!
## note that the version is borked because we have to follow the versions
## that Arthur Li was using, rather than the BioC convention.

rna <- "mrna_assignment"
dna <- "gene_assignment"

parseCsvFiles <- function(csv){
    dat <- read.csv(csv, comment.char = "#", stringsAsFactors=FALSE, na.string = "---")
    if(!all(c(rna, dna) %in% names(dat)))
        stop("Check the headers for file", csv, "they don't include", rna, "and", dna, "!")
    ## egs <- lapply(strsplit(dat[,dna], " /// "), function(x) sapply(strsplit(x, " // "), "[", 1))
    ## egs <- lapply(egs, function(x) x[!duplicated(x) & x != "---"])

    ## egs <- data.frame(probeids = rep(dat[,1], sapply(egs, length)), egids = unlist(egs))

    ## add back missing probesets
    ## toadd <- data.frame(probeids = dat[!dat[,1] %in% egs[,1],1], egids = rep(NA, sum(!dat[,1] %in% egs[,1])))
    ## egs <- rbind(egs, toadd)

    mrna <- sapply(strsplit(dat[,rna], " // | /// "), function(vals) grep("^[NX][MR]|^[A-G][A-Z][0-9]+|^[A-Z][0-9]+", vals, value = TRUE))
    mrna <- lapply(mrna, function(x) gsub(" [/A-Za-z0-9]+", "", x))
    mrna <- lapply(mrna, function(x) {ind <- grep("\\[|orf|Aug", x); if(length(ind) == 0) return(x) else return(x[-ind])})
    mrna <- lapply(mrna, function(x) gsub("\\..*$", "", x))
    mrna <- lapply(mrna, function(x) gsub("_[1-9]$", "", x))
    mrna <- lapply(mrna, function(x) if(length(x) > 0) x else NA)
    mrna <- data.frame(probeids = rep(dat[,1], sapply(mrna, length)), mrna = I(unlist(mrna)))

    ## add back missing probesets
    toadd <- data.frame(probeids = dat[!dat[,1] %in% mrna[,1],1], mrna = rep(NA, sum(!dat[,1] %in% mrna[,1])))
    mrna <- rbind(mrna, toadd)
    ## Affy is now adding extra cruft to the names
    csv <- gsub("\\.r[13]\\.|\\.a1\\.", ".", csv)
    outname <- gsub("-|_", "", tolower(strsplit(csv, "\\.na3[345678]|st-v")[[1]][1]))
    outsub <- strsplit(csv, "\\.")[[1]]
    outsub <- outsub[length(outsub)-1]
    ##write.table(egs, paste0(outname, "_", outsub, "_eg.txt"), sep = "\t", na = "", row.names = FALSE, col.names = FALSE, quote = FALSE)
    write.table(mrna, paste0(outname, "_", outsub, "_gbNRef.txt"), sep = "\t", na = "", row.names = FALSE, col.names = FALSE, quote = FALSE)
    return(list(outname = outname, outsub = outsub))
}

makePkg <- function(outname, outsub, version){
    toget <- gsub("[0-9]+", "", outname)
    toget <- gsub("clariom[sd]|ht$", "", toget)
    db <- switch(toget,
                 hugene = "HUMANCHIP_DB",
                 mogene = "MOUSECHIP_DB",
                 ragene = "RATCHIP_DB",
                 huex = "HUMANCHIP_DB",
                 moex = "MOUSECHIP_DB",
                 raex = "RATCHIP_DB",
                 hta = "HUMANCHIP_DB",
                 mta = "MOUSECHIP_DB",
                 rta = "RATCHIP_DB",
                 human = "HUMANCHIP_DB",
                 mouse = "MOUSECHIP_DB",
                 rat = "RATCHIP_DB",)
    prefix <- if(length(grep("clariom|hta|mta|rta", outname)) == 0){
                  switch(outsub,
                         transcript = paste0(outname, "st", outsub, "cluster"),
                         probeset = paste0(outname, "st", outsub))
              } else {
                  switch(outsub,
                         transcript = paste0(outname, outsub, "cluster"),
                         probeset = paste0(outname, outsub))
              }
    fileName <- paste0(outname, "_", outsub, "_gbNRef.txt")
    ##otherSrc <- paste0(outname, "_", outsub, "_eg.txt")
    makeDBPackage(db, affy = FALSE, prefix, fileName = fileName, baseMapType = "gbNRef",
                  chipName = outname, manufacturer = "Affymetrix",
                  manufacturerUrl = "http://www.affymetrix.com", version = version,
                  author = "James W. MacDonald", maintainer = "Biocore Package Maintainer <maintainer@bioconductor.org>")
   unlink(c(fileName, paste0(prefix, ".sqlite")), recursive = TRUE)
}

for(i in csvs){
    pv <- parseCsvFiles(i)
    makePkg(pv$outname, pv$outsub, version)
}
