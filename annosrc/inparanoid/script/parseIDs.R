.libPaths("~/R-3.6.1")
library("XML")

splitStrUtil <- function(xmlfile) {
    gene_id_path <- "/protein/related_feature[1]/related_feature[1]/id"
    kv <- new.env(parent=emptyenv())
    extra <- new.env()
    extra[["count"]] <- 0L
    protein_fun <- function(node) {
        uname <- unlist(xpathApply(xmlDoc(node),
                                   "/protein/id[1]", xmlValue))
        acc <- unlist(xpathApply(xmlDoc(node),
                                 gene_id_path, xmlValue))
        kv[[uname]] <- acc
        cc <- extra[["count"]]
        extra[["count"]] <- cc + 1L
        if (cc %% 1000 == 0 && cc > 0) message("processed ", cc, " proteins")

    }

    xmlEventParse(xmlfile, branches=list(protein = protein_fun))
    kv
}

writeFromEnv <- function(e, outfile)
{
    dd <- as.list(e)
    df <- data.frame(pId = names(dd),
                     gId = unlist(dd, use.names = FALSE),
                     stringsAsFactors = FALSE)
    write.table(df, file = outfile, quote = FALSE, sep = "\t",
                row.names = FALSE, col.names = FALSE)
}

env = splitStrUtil("curFBpp.xml.gz")
writeFromEnv(env, "FBIDs.tab")
