#This is a stupid hack.  Something bad is being caused by perl, but I don't know exactly what yet

readWrite <- function() {
    data <- read.delim("GS_DRs.tab", sep="\t", header=F)
    write.table(data, file="GS_DRs.tab", sep="\t", row.names=F, col.names=F, quote=F)
}

readWrite()
