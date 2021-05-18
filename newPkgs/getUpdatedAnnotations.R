library(AffyCompatible)

rsrc <- NetAffxResource("jmacdon@med.umich.edu","wibble")
nam <- names(rsrc)
namind <- grep("HuGene|HuEx|MoGene|MoEx|RaGene|RaEx|Clariom|HTA|MTA|RTA", nam, value = T)

annos <- lapply(namind, function(x) rsrc[[x]])

annos2 <- lapply(annos, function(x){
    ind <- grep("Annotations", names(x))
    ind2 <- lapply(ind, function(y) AffyCompatible:::.Data(affxUrl(affxFile(affxAnnotation(x)[[y]])[[1]])[[1]]))
    return(ind2)})

annos2 <- unlist(annos2)
fnames <- sapply(strsplit(annos2, "/"), function(x) x[length(x)])
flshere <- dir(".", "csv$")

getind <- !gsub("\\.zip", "", fnames) %in% flshere

if(all(getind)) unlink(flshere) else unlink(flshere[!flshere %in% gsub("\\.zip", "", fnames)])

annos2 <- annos2[getind]
fnames <- fnames[getind]


for(i in annos2) download.file(i, sapply(strsplit(i, "/"), function(x) x[length(x)]), mode = "wb")
