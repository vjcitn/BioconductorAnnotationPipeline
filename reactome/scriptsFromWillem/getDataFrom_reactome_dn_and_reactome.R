
## This is the SQL used from mySQL
## SELECT DISTINCT p2e.DB_ID, e2i.indirectIdentifier FROM reactome_dn.Pathway_2_hasEveryComponent AS p2e, reactome_dn.Event_2_indirectIdentifier AS e2i WHERE e2i.DB_ID = p2e.hasEveryComponent AND e2i.indirectIdentifier LIKE "%Entrez%" INTO OUTFILE "/tmp/pathway2gene.txt";

## SELECT DB_ID, indirectIdentifier FROM reactome_dn.Event_2_indirectIdentifier WHERE indirectIdentifier LIKE "%go%" INTO OUTFILE "/tmp/reactome2go.txt";

## SELECT DISTINCT(do.DB_ID), do2._displayName, do._displayName FROM reactome.DatabaseObject AS do, reactome.Event_2_species AS e2s, reactome.DatabaseObject AS do2 WHERE do._class = "Pathway" AND e2s.DB_ID = do.DB_ID AND do2.DB_ID = e2s.species INTO OUTFILE "/tmp/pathway2name.txt";


###############################################################################
## Now for the R code:

p2gSQL <- "SELECT DISTINCT p2e.DB_ID, e2i.indirectIdentifier FROM Pathway_2_hasEveryComponent AS p2e, Event_2_indirectIdentifier AS e2i WHERE e2i.DB_ID = p2e.hasEveryComponent AND e2i.indirectIdentifier LIKE '%Entrez%'"

r2goSQL <- "SELECT DB_ID, indirectIdentifier FROM Event_2_indirectIdentifier WHERE indirectIdentifier LIKE '%GO%'"


## This one may require hitting the original DB...  For the devel version, lets just use this as is...
p2nSQL <- "SELECT DISTINCT(do.DB_ID), do2._displayName, do._displayName FROM DatabaseObject AS do, Event_2_species AS e2s, DatabaseObject AS do2 WHERE do._class = 'Pathway' AND e2s.DB_ID = do.DB_ID AND do2.DB_ID = e2s.species"

## This just makes the files that are used by the next script.
library(RSQLite)
con <- dbConnect(SQLite(), "../reactome_dn.sqlite")
p2g <- dbGetQuery(con, p2gSQL)
p2g[,2] <- gsub("EntrezGene:","",p2g[,2])
head(p2g)
write.table(p2g, file="pathway2gene.txt", sep="\t", quote=FALSE, col.names=FALSE, row.names=FALSE)
r2go <- dbGetQuery(con, r2goSQL)
write.table(r2go, file="reactome2go.txt", sep="\t", quote=FALSE, col.names=FALSE, row.names=FALSE)

con2 <- dbConnect(SQLite(), "../reactome.sqlite")
p2n <- dbGetQuery(con2, p2nSQL)
p2nf <- cbind(p2n[,1], paste(p2n[,2], p2n[,3], sep=": "))

write.table(p2nf, file="pathway2name.txt", sep="\t", quote=FALSE, col.names=FALSE, row.names=FALSE)
