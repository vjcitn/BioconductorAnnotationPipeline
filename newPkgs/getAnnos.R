## code to get csv files to remake ChipDb packages
## this was written for Bioc 3.13, since we removed the UniGene
## tables and had to rebuild the ChipDb packages. Might not
## ever need to be run again?

library(AffyCompatible)
library(AnnotationForge)
library(affy)
rsrc <- NetAffxResource("jmacdon@med.umich.edu","wibble")
nam <- names(rsrc)

## maybe easier to just give a numeric vector
## these are the 'usual' ones

schemanames <- grep("CHIP", available.dbschemas(), value = TRUE)

ind <- c(1,2,64,72,73,76,79,106,107,109,130:142,147:156,160:164,
         177:184,209,210,212:216,229:231,234:236,239,241,251,275,276,
         279)
d.f <- data.frame(nam = nam[ind], shortnam = gsub("cdf", "", cleancdfname(nam[ind])),
                  whichchip = schemanames[c(1,1,2,3,3,12,4,6,6,5,rep(7,18),
                                            9,9,9,11,11,rep(7,5),rep(9,15),10,
                                            rep(11,8),13,13,14)])

## some weirdness with HG-U219, so remove
d.f <- d.f[-17,]

getFile <- function(theurl){
    sname <- paste0("tmp_download/", sapply(strsplit(theurl, "/"), function(x) x[length(x)]))
    if(!file.exists("tmp_download")) dir.create("tmp_download")
    if(!file.exists(sname)){
        download.file(theurl, sname)
        unzip(sname, exdir = "tmp_download")
    }
    return(gsub("\\.zip$", "", sname))
}

buildThatDog <- function(d.frame, affsrc){
    for(i in seq_len(nrow(d.frame))){
        string <- "Annotations, CSV format"
        url <- AffyCompatible:::.Data(affxUrl(affxFile(rsrc[[d.frame[i,1],string]])[[1]])[[1]])
        fn <- getFile(url)
        if(d.frame[i,3] %in% c("ARABIDOPSISCHIP_DB","YEASTCHIP_DB")){
            makeDBPackage(d.frame[i,3], affy = TRUE, prefix = d.frame[i,2],
                          fileName = fn, outputDir = "20210517_ChipDbs",
                          version = "3.13.0", manufacturer = "Affymetrix",
                          chipName = paste("Affymetrix", d.frame[i,1], "Array"),
                          manufacturerUrl = "http://www.affymetrix.com")
        } else {
             makeDBPackage(d.frame[i,3], affy = TRUE, prefix = d.frame[i,2],
                          fileName = fn, outputDir = "20210517_ChipDbs",
                          version = "3.13.0", manufacturer = "Affymetrix",
                          chipName = paste("Affymetrix", d.frame[i,1], "Array"),
                          manufacturerUrl = "http://www.affymetrix.com", baseMapType = "gbNRef")
        }
    }
}

dir.create("20210517_ChipDbs")
buildThatDog(d.f, rsrc)
