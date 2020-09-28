## 1st download the GFF file.  (this should happen up front in download.sh) so
## I won't actually do it HERE.  IOW at this point it has already happened.

## Now load rtracklayer so we can process this file...
.libPaths("~/R-libraries")
library(rtracklayer)
data <- import.gff3("TAIR10_GFF3_genes.gff")
## so then just grab all the mRNA features.
res <- data[data$type=="mRNA",]
res <- as.data.frame(res)
## Then we only want these columns:
res <- res[,c("seqnames","ID","Parent")]
res[[1]] <- as.character(res[[1]])
res[[2]] <- as.character(res[[2]])
res[[3]] <- as.character(res[[3]])
## remove "chr" from the chromosome values
res[[1]] <- sub("Chr","",res[[1]])


## Now we can just put these into a DB
library("RSQLite")
drv <- dbDriver("SQLite")
con <- dbConnect(drv,dbname="tairsrc.sqlite")

sqlCreate <- "CREATE TABLE locusToGene (
                chromosome TEXT,
                gene_name TEXT,
                locus TEXT);"

dbExecute(con, sqlCreate)


sqlIns <- "INSERT into locusToGene
           (chromosome, gene_name, locus)
           VALUES (?,?,?)"
dbBegin(con)
rset <- dbSendStatement(con, sqlIns, params=unclass(unname(res)))
dbClearResult(rset)
dbCommit(con)

sqlIdx <- "CREATE INDEX lg1 on locusToGene(gene_name);"
dbExecute(con, sqlIdx)

## a little more sql to just massage things into the other table.
sqlSeqGenes <- "CREATE TABLE sequenced_genes (
 locus TEXT,
 gene_name TEXT,
 coding TEXT,
 protein_name TEXT,
 chromosome TEXT,
 description TEXT,
 associated_func TEXT
);"
dbExecute(con, sqlSeqGenes)


## then insert the values into that table matching based on gene_name
sqlIns2 <- "INSERT INTO sequenced_genes (locus, gene_name, coding,
               protein_name, chromosome, description, associated_func)
             SELECT lg.locus AS locus, sg.gene_name AS gene_name,
                     sg.coding AS coding, sg.protein_name AS protein_name,
                     lg.chromosome AS chromsome, sg.description AS description,
                     sg.associated_func AS associated_func
              FROM sequenced_genest AS sg LEFT OUTER JOIN 
                   locusToGene AS lg USING (gene_name)"
dbExecute(con, sqlIns2)

## Then drop old table
sqlDrop <- "DROP TABLE sequenced_genest;"
dbExecute(con, sqlDrop)

## Then make an index for locus
sqlIdx <- "CREATE INDEX sg2 on sequenced_genes(locus);"
dbExecute(con, sqlIdx)

