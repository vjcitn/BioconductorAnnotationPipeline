parseEnsemblPepIDs = function(file, fileName ){
    Data <- read.delim(file, sep="", colClasses=c(rep("character", 5)),
                       header=FALSE)
    matchLines <- grep(">",Data[,1])
    Data <- Data[matchLines,]
    ids <- c(1,4)
    IDs <- as.matrix(Data[,ids])
    IDs <- gsub(">EG:", "", IDs)
    IDs <- gsub("gene:", "", IDs)
    if (fileName == "celegans_gene_ensembl_prot.tab")
        IDs[,2] <- gsub("\\.[0-9]", "", IDs[,2])
    else
        IDs <- gsub("\\.[0-9]", "", IDs)
    write.table(IDs, file=fileName, sep="\t", row.names=F, col.names=F, quote=F)
}

parseEnsemblTransIDs = function(file, fileName ){
    Data <- read.delim(file, sep="", colClasses=c(rep("character", 4)),
                       header=FALSE)
    matchLines <- grep(">",Data[,1])
    Data <- Data[matchLines,]
    ids <- c(1,4)
    IDs <- as.matrix(Data[,ids])
    IDs <- gsub(">EG:", "", IDs)
    IDs <- gsub("gene:", "", IDs)    
    if (fileName == "celegans_gene_ensembl_trans.tab")
        IDs[,2] <- gsub("\\.[0-9]", "", IDs[,2])
    else
        IDs <- gsub("\\.[0-9]", "", IDs)
    write.table(IDs, file=fileName, sep="\t", row.names=F, col.names=F, quote=F)
}


## Marc's notes: 
## No run for pigs because nobody exposes entrez geen to ensembl gene IDs
    parseEnsemblPepIDs(file="curHomo_sapiens_pep.fa",
                       fileName="hsapiens_gene_ensembl_prot.tab")
    parseEnsemblPepIDs(file="curRattus_norvegicus_pep.fa", 
                       fileName="rnorvegicus_gene_ensembl_prot.tab")
    parseEnsemblPepIDs(file="curMus_musculus_pep.fa",
                       fileName="mmusculus_gene_ensembl_prot.tab")
    parseEnsemblPepIDs(file="curDanio_rerio_pep.fa",
                       fileName="drerio_gene_ensembl_prot.tab")
    parseEnsemblPepIDs(file="curCanis_familiaris_pep.fa",
                       fileName="cfamiliaris_gene_ensembl_prot.tab")
    parseEnsemblPepIDs(file="curBos_taurus_pep.fa",
                       fileName="btaurus_gene_ensembl_prot.tab")
    parseEnsemblPepIDs(file="curCaenorhabditis_elegans_pep.fa",
                       fileName="celegans_gene_ensembl_prot.tab")
    parseEnsemblPepIDs(file="curGallus_gallus_pep.fa",
                       fileName="ggallus_gene_ensembl_prot.tab")
    parseEnsemblPepIDs(file="curMacaca_mulatta_pep.fa",
                       fileName="mmulatta_gene_ensembl_prot.tab")
    parseEnsemblPepIDs(file="curAnopheles_gambiae_pep.fa",
                       fileName="agambiae_gene_ensembl_prot.tab")
    parseEnsemblPepIDs(file="curPan_troglodytes_pep.fa",
                       fileName="ptroglodytes_gene_ensembl_prot.tab")
    parseEnsemblPepIDs(file="curDrosophila_melanogaster_pep.fa",
                       fileName="dmelanogaster_gene_ensembl_prot.tab")
    parseEnsemblPepIDs(file="curSaccharomyces_cerevisiae_pep.fa",
                       fileName="scerevisiae_gene_ensembl_prot.tab")


#####################################################################
## Now for the transctript IDs

    parseEnsemblTransIDs(file="curHomo_sapiens_cdna.fa",
                         fileName="hsapiens_gene_ensembl_trans.tab")
    parseEnsemblTransIDs(file="curRattus_norvegicus_cdna.fa",
                         fileName="rnorvegicus_gene_ensembl_trans.tab")
    parseEnsemblTransIDs(file="curMus_musculus_cdna.fa",
                         fileName="mmusculus_gene_ensembl_trans.tab")
    parseEnsemblTransIDs(file="curDanio_rerio_cdna.fa",
                         fileName="drerio_gene_ensembl_trans.tab")
    parseEnsemblTransIDs(file="curCanis_familiaris_cdna.fa",
                         fileName="cfamiliaris_gene_ensembl_trans.tab")
    parseEnsemblTransIDs(file="curBos_taurus_cdna.fa",
                         fileName="btaurus_gene_ensembl_trans.tab")
    parseEnsemblTransIDs(file="curCaenorhabditis_elegans_cdna.fa",
                         fileName="celegans_gene_ensembl_trans.tab")
    parseEnsemblTransIDs(file="curGallus_gallus_cdna.fa",
                         fileName="ggallus_gene_ensembl_trans.tab")
    parseEnsemblTransIDs(file="curMacaca_mulatta_cdna.fa",
                         fileName="mmulatta_gene_ensembl_trans.tab")
    parseEnsemblTransIDs(file="curAnopheles_gambiae_cdna.fa",
                         fileName="agambiae_gene_ensembl_trans.tab")
    parseEnsemblTransIDs(file="curPan_troglodytes_cdna.fa",
                         fileName="ptroglodytes_gene_ensembl_trans.tab")
    parseEnsemblTransIDs(file="curDrosophila_melanogaster_cdna.fa",
                       fileName="dmelanogaster_gene_ensembl_trans.tab")
    parseEnsemblTransIDs(file="curSaccharomyces_cerevisiae_cdna.fa",
                       fileName="scerevisiae_gene_ensembl_trans.tab")
