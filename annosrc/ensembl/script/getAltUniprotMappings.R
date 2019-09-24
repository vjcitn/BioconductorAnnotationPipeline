##R script attempting to get the latest uniprot to Entrez Gene mappings from biomaRt...
.libPaths("~/R-3.6.1")
library(biomaRt)

## No filters
## attributes = listAttributes(ensembl)
## attributes
## Just the following two attributes:
## "Ensembl Gene ID": ensembl_gene_id
## "EntrezGene ID": entrezgene

##To get more species that you can support see what is avaiable here:
##listDatasets(ensembl)


## ensembl=useMart("ensembl")

speciesList = c("dmelanogaster_gene_ensembl"="fly_eg2uniprot",
                "agambiae_eg_gene" = "anopheles_eg2uniprot")

martList = c("ensembl","metazoa_mart_8")
speciesFrame = data.frame(speciesList, martList, stringsAsFactors=FALSE)


getData = function(species,mart){
    ##For now we only need flies...
    ##ensembl = useMart("ensembl",dataset="dmelanogaster_gene_ensembl")
    ensembl = useMart(mart,dataset=species)
    
    ## listAttributes(ensembl)
    ## 51                             uniprot_sptrembl - maybe it.
    ## 52                   uniprot_sptrembl_predicted - um nothing???
    ## 53                            uniprot_swissprot - NOT it
    ## 54                  uniprot_swissprot_accession - maybe it (a lot less stuff)    
    ## 51                            UniProt/TrEMBL Accession
    ## 52                            UniProt/TrEMBL predicted
    ## 53                                UniProt/SwissProt ID
    ## 54                         UniProt/SwissProt Accession

    
    data = getBM(c("entrezgene", "uniprot_sptrembl"), mart = ensembl)
    
    ##This data seems to be correct (at least for flies)

    ##Drop NA rows.. from either side...
    data = data[!is.na(data[,1]),]
    data = data[!is.na(data[,2]),]
    ##No blank lines either...
    data = data[data[,1]!="",]
    data = data[data[,2]!="",]

    ##fileName = "fly_eg2uniprot"
    fileName = speciesList[[species]]
    write.table(data, file =paste(fileName,"_ensembl_Data.tab",sep=""), quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
}

for(i in seq_len(dim(speciesFrame)[1])){
    getData(rownames(speciesFrame)[i], mart=speciesFrame[i,2]) #use rowname
}


##For the time being... Lets put this data into an extra table in ensembl.sqlite.

##load libs
library("DBI")
library("RSQLite")

##Connect to the DB
drv <- dbDriver("SQLite")
db <- dbConnect(drv,dbname="ensembl.sqlite")


##Define a function to create and populate a table.
popTable = function(table, db){
    ##Make the table
    message(cat(paste("Creating table: ",table,sep="")))
    sql<- paste("    CREATE TABLE IF NOT EXISTS ",table, " (
        gene_id VARCHAR(20) NOT NULL,
        uniprot_id VARCHAR(15) NOT NULL )
    ;", sep="")
    dbGetQuery(db, sql)

    ##Populate that table  -- chenge this to import from FILE
    file = paste(table,"_ensembl_Data.tab",sep="")
    data = read.delim(file=file, header=FALSE, sep="\t")

    sqlIns <- paste("INSERT INTO ",table,"(gene_id,uniprot_id) VALUES (?,?);", sep="")
    dbBegin(db)
    rslt <- dbSendQuery(db, sqlIns, params=unclass(unname(data)))
    dbClearResult(rslt)
    dbCommit(db)

    ##Two indices per table
    ind1 = paste(table,"_gene",sep="")
    sql<- paste("CREATE INDEX ",ind1," ON ",table,"(gene_id);",sep="")
    dbGetQuery(db, sql)
    ind2 = paste(table,"_uniprot",sep="")
    sql<- paste("CREATE INDEX ",ind2," ON ",table,"(uniprot_id);",sep="")
    dbGetQuery(db, sql)
}



##Make the table
## table = "fly_eg2uniprot"
## popTable(table, db)

for(i in seq_len(dim(speciesFrame)[1])){
    table = speciesFrame[i,1]
    popTable(table,db)
}

