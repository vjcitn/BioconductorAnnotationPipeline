## get taxIDs matched to full species names
library(UniProt.ws)
taxSpec <- availableUniprotSpecies()
## get inparanoid data
inpSpec <- read.table('species.mapping.inparanoid8',sep="\t", stringsAsFactors=FALSE)
## drop the .fasta suffixes to release the tax IDs
inpSpec$V1 <- sub(".fasta$","",inpSpec$V1)
res <- merge(x=inpSpec, y=taxSpec, by.x='V1', by.y='taxon ID', all.x=TRUE, sort=FALSE)
## remove all strain info from species col
res$'Species name' <- sub(" \\(.*","",res$'Species name', perl=TRUE)
## remove all serogroups
res$'Species name' <- sub(" serogroup.*","",res$'Species name', perl=TRUE)
## remove all sub species
res$'Species name' <- sub(" subsp\\..*","",res$'Species name', perl=TRUE)
## remove all variants
res$'Species name' <- sub(" var\\..*","",res$'Species name', perl=TRUE)

#write out the file
write.table(res, file="taxID_INP_species_mapping", sep="\t", quote=FALSE, row.name=FALSE, col.names=FALSE)

## Then some will STILL be missing (but at least these are the minority)
## MANUAL edits ensued here to replace long names that were STILL missing.

## After editing, there may be too many '\t's in someplaces.
## test:
bar = read.table('taxID_INP_species_mapping', sep='\t')
## run the following:
res = readLines('taxID_INP_species_mapping')
foo = sub("\t\t","\t",res)

colnames(foo) <- c('taxID','inparanoidSpecies','GenusAndSpecies')
write.table(foo, file="taxID_INP_species_mapping", sep="\t", quote=FALSE, row.name=FALSE, col.names=TRUE)

## AND NOW I just leared that 1) I need to add in a collumn for the
## legacy 5 letter codes AND ALSO another column because the names
## used INSIDE the tables are not always the simple 1 letter genus
## plus species that are used for the file names...  (ARGH).

## So 1st lets grab the legacy 5 letter codes...
fives <- AnnotationDbi:::.makeFiveLetterMapping()
fives <- data.frame(fives, names(fives), stringsAsFactors=FALSE)
colnames(fives) <- c('fives', 'GenusAndSpecies')
## get rid of underscores
fives$GenusAndSpecies <- gsub("_"," ", fives$GenusAndSpecies)
## get the data so far
res <- read.table("taxID_INP_species_mapping", sep='\t',header=TRUE)
## merge in the new column
res2 <- merge(res, fives, by='GenusAndSpecies', all.x=TRUE)

## BUT (somehow), we lost some...
## table(is.na(res2$fives))    ## :(
## missing ones:
## missing = fives[!(fives$GenusAndSpecies %in% res$GenusAndSpecies),]
## mStrs = missing$GenusAndSpecies
## mStrs = sub(".+ ","",mStrs)
## mStrs = substr(mStrs, start=1, stop=4)

## So for at least some of these, the old species has ACTUALLY been dropped! 
## res2[grepl(mStrs[1],res2$GenusAndSpecies),]
## get data on the whole set:
lapply(mStrs, function(x){res2[grepl(x,res2$GenusAndSpecies),]})

## So lets manually replace the 'off' ones.  And then save the truly missing ones.
write.table(missing, file="possibleMissing", sep="\t", quote=FALSE, row.name=FALSE, col.names=TRUE)
## And also write out the res2
write.table(res2, file="4Col_species_mapping", sep="\t", quote=FALSE, row.name=FALSE, col.names=TRUE)

## After editing all that I CAN, I get the following 
res <- read.table("4Col_species_mapping", sep='\t',header=TRUE)
## I am basically still missing 7 of these old five letter codes (indeterminate or just plain missing)


## Now I have to go after the new short names (for the intra-table stuff).
## So for this I am going to make a test database (so I can get all
## the short names that are used inside the tables)


library("RSQLite")
con = dbConnect(SQLite(),dbname='/mnt/cpb_anno/mcarlson/proj/mcarlson/sqliteGen/annosrc/inparanoid/TEST/Aedes_aegypti.sqlite')
tabs = dbListTables(con)
## make all the sql queries
sqls <- paste0('SELECT distinct species FROM ', tabs)
#sqliteQuickSQL(con, sql)
possibleShortNames = unique(unlist(lapply(sqls, sqliteQuickSQL, con=con)))

names <- lapply(sqls, sqliteQuickSQL, con=con)
names(names) <- tabs
## now drop all the extra "A.aegypti" names 
names <- lapply(names, function(x){res=x$species; res[!(res %in% 'A.aegypti')]})
names <- unlist(names, use.names=TRUE)

## now make to a data.frame
names <- data.frame(shortInpName=names, tableNames=names(names),stringsAsFactors=FALSE)
rownames(names) = NULL


## now load the 4Cols stuff
res <- read.table("4Col_species_mapping", sep='\t',header=TRUE)

## Tricky part is, I want to keep records like this one with their
## hyphens and or periods intact.  Simplest code is to add a 6th
## column.

res <- data.frame(res, tableNames=gsub(" ", "_", gsub("-","_", gsub("\\.","",res$GenusAndSpecies))))


## now merge
res <- merge(res, names, by='tableNames', all.x=TRUE)
## and put in the one missing entry (because we search a DB for "A.aegypti")
res[res$GenusAndSpecies=='Aedes aegypti','shortInpName'] <- "A.aegypti"

## AND save:
write.table(res, file="Full_species_mapping", sep="\t", quote=FALSE, row.name=FALSE, col.names=TRUE)

## Now it looks like (after all that) inparanoidSpecies and
## shortInpName wound up being the same after all.
## table(res$inparanoidSpecies==res$shortInpName)

